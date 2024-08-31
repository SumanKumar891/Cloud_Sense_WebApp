import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AddDevice.dart';
import 'DeviceGraphPage.dart';
import 'HomePage.dart'; // Import your HomePage here
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class DataDisplayPage extends StatefulWidget {
  @override
  _DataDisplayPageState createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  bool _isLoading = true;
  Map<String, List<String>> _deviceCategories = {};
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      setState(() {
        _email = email;
      });
      _fetchData();
    } else {
      // Handle case where email is not found, e.g., navigate to sign-in page
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  Future<void> _fetchData() async {
    if (_email == null) return;

    final url =
        'https://ln8b1r7ld9.execute-api.us-east-1.amazonaws.com/default/Cloudsense_user_devices?email_id=$_email';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        setState(() {
          _deviceCategories = {
            for (var key in result.keys)
              if (key != 'device_id' && key != 'email_id')
                _mapCategory(key): List<String>.from(result[key] ?? [])
          };
        });
      }
    } catch (error) {
      // Handle errors appropriately
      print('Error fetching data: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _mapCategory(String key) {
    switch (key) {
      case 'CL':
      case 'BD':
        return 'Chlorine Sensors';
      case 'WD':
        return 'Weather Sensors';
      default:
        return key;
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email'); // Clear the saved email
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), // Navigate to HomePage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgroundd.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.4), // Optional overlay for readability
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              AppBar(
                title: Text('Your Chosen Devices'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  TextButton.icon(
                    onPressed: () async {
              try {
                await Amplify.Auth.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('email');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              } catch (e) {
                // Handle error during logout if necessary
              }
            },// Logout function
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      'Log out',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Quote Text
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 70.0, left: 16.0, right: 16.0),
                              child: Text(
                                "Select a device to unlock insights into temperature, humidity, light, and more—your complete environmental toolkit awaits.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    5), // Space between quote and device cards
                            Expanded(
                              child: _deviceCategories.isNotEmpty
                                  ? _buildDeviceCards()
                                  : _buildNoDevicesCard(),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCards() {
    List<Widget> cardList = _deviceCategories.keys.map((category) {
      return Container(
        width: 300,
        height: 300,
        margin: EdgeInsets.all(10),
        child: Card(
          color: _getCardColor(category),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Text(
                  category,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _deviceCategories[category]?.length ?? 0,
                    itemBuilder: (context, index) {
                      // Generate a sequential name like "Chlorine Sensor 1"
                      String sequentialName =
                          '${category.split(" ").first} Sensor ${index + 1}';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black, // Text color
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          onPressed: () {
                            String sequentialName = '${category.split(" ").first} Sensor ${index + 1}';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeviceGraphPage(
                                  deviceName: sequentialName, // Pass the formatted name
                                     
                                ),
                              ),
                            );
                          },
                          child: Text(
                            sequentialName,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();

    // Add the "Add Devices" button as a card
    cardList.add(
      Container(
        width: 300,
        height: 300,
        margin: EdgeInsets.all(10),
        child: Card(
          color: const Color.fromARGB(255, 167, 158, 172),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Plus sign above the button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.add,
                  size: 80,
                  color: Colors.black,
                ),
              ),
              // Add Devices button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScannerPage(),
                    ),
                  );
                },
                child: Text(
                  'Add Devices',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 245, 241, 240)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cardList,
      ),
    );
  }

  Widget _buildNoDevicesCard() {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        margin: EdgeInsets.all(10),
        child: Card(
          color: const Color.fromARGB(255, 167, 158, 172),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Message Text
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No devices found.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: const Color.fromARGB(255, 235, 28, 28),
                  ),
                ),
              ),
              // Plus sign above the button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.add,
                  size: 80,
                  color: Colors.black,
                ),
              ),
              // Add Devices button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScannerPage(),
                    ),
                  );
                },
                child: Text(
                  'Add Devices',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 245, 241, 240)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCardColor(String category) {
    switch (category) {
      case 'Chlorine Sensors':
        return const Color.fromARGB(255, 167, 158, 172);
      case 'Weather Sensors':
        return const Color.fromARGB(255, 167, 158, 172);
      default:
        return const Color.fromARGB(255, 167, 158, 172);
    }
  }
}
