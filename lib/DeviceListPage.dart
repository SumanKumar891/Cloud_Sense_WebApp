import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AddDevice.dart';
import 'DeviceGraphPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/backgroundd.jpg'), // Update with your image path
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black
                    .withOpacity(0.4), // Optional overlay for readability
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
                                  : Center(
                                      child: Text('No devices found.'),
                                    ),
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
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceGraphPage(
                                deviceName: _deviceCategories[category]![index],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          sequentialName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
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
