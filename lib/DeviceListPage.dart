import 'dart:ui';
import 'package:cloud_sense_webapp/LoginPage.dart';
import 'package:cloud_sense_webapp/buffalodata.dart';
import 'package:cloud_sense_webapp/cowdata.dart';
import 'package:cloud_sense_webapp/manuallyenter.dart';
import 'package:cloud_sense_webapp/GPS.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AddDevice.dart';
import 'DeviceGraphPage.dart';
import 'HomePage.dart';
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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadEmail();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');

    try {
      var currentUser = await Amplify.Auth.getCurrentUser();
      if (currentUser.username.trim().toLowerCase() ==
          "05agriculture.05@gmail.com") {
        // Redirect to DeviceInfoPage if this is the special user
        Navigator.pushReplacementNamed(context, '/deviceinfo');
        return; // Exit further execution
      }
      // Else continue on DeviceListPage normally
      setState(() {
        _email = savedEmail ?? currentUser.username;
      });
      _fetchData();
    } catch (e) {
      // No signed-in user — clear prefs & navigate to login screen
      await Amplify.Auth.signOut();
      await prefs.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInSignUpScreen()),
        (route) => false,
      );
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

        // Group LU, TE, and AC sensors under a single "CPS Lab Sensors" category
        Map<String, List<String>> groupedDevices = {};

        result.forEach((key, value) {
          if (key != 'device_id' && key != 'email_id') {
            String category = _mapCategory(key);

            // Group LU, TE, and AC sensors under "CPS Lab Sensors"
            if (key == 'LU' || key == 'TE' || key == 'AC') {
              category = 'CPS Lab Sensors';
            }

            if (groupedDevices[category] == null) {
              groupedDevices[category] = [];
            }

            groupedDevices[category]?.addAll(List<String>.from(value ?? []));
          }
        });

        setState(() {
          _deviceCategories = groupedDevices;
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
      case 'SS':
        return 'Soil Sensors';
      case 'WQ':
        return 'Water Quality Sensors';
      case 'DO':
        return 'DO Sensors';
      case 'IT':
        return 'IIT Bombay Weather Sensors';
      case 'WS':
        return 'Water Sensors';
      case 'LU':
      case 'TE':
      case 'AC':
        return 'CPS Lab Sensors'; // All grouped under CPS Lab Sensors
      case 'BF':
        return 'Buffalo Sensors';
      case 'CS':
        return 'Cow Sensors';
      case 'TH':
        return 'Temperature Sensors';
      case 'NH':
        return 'Ammonia Sensors';
      case 'FS':
        return 'Forest Sensors (Bhopal)';
      case 'SM':
        return 'SSMET Sensors';
      case 'CF':
        return 'SEKHU Farm Sensors';
      case 'SV':
        return 'SVPU Sensors (Meerut)';
      case 'CB':
        return 'COD/BOD Sensors';
      case 'WF':
        return 'WF Sensors';
      case 'KD':
        return 'Kargil Sensors';
      case 'VD':
        return 'Vanix Sensors';
      case 'NA':
        return 'NARL Sensors';
      case 'CP':
        return 'Campus Sensors (IIT Ropar)';
      default:
        return 'Rain Sensors';
    }
  }

  Future<void> _handleLogout() async {
    try {
      print("[Logout] Starting logout process.");

      await Amplify.Auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("[Logout] User signed out and preferences cleared.");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("[Logout] Primary logout failed: $e");
      // Fallback logout
      try {
        await Amplify.Auth.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print("[Logout] Fallback logout success.");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );
      } catch (logoutError) {
        print("[Logout] Fallback logout failed: $logoutError");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black,
            size: MediaQuery.of(context).size.width < 800
                ? 16
                : 32), // back arrow color
        title: Text(
          'Your Chosen Devices',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: MediaQuery.of(context).size.width < 800 ? 16 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _handleLogout,
            icon: Icon(
              Icons.logout,
              color: isDarkMode ? Colors.white : Colors.black,
              size: MediaQuery.of(context).size.width < 800 ? 16 : 24,
            ),
            label: Text(
              'Log out',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: MediaQuery.of(context).size.width < 800 ? 12 : 24,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height, // full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    const Color.fromARGB(255, 192, 185, 185)!,
                    const Color.fromARGB(255, 123, 159, 174)!,
                  ]
                : [
                    const Color.fromARGB(255, 126, 171, 166)!,
                    const Color.fromARGB(255, 54, 58, 59)!,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 90.0, left: 16.0, right: 16.0),
                            child: Text(
                              "Select a device to unlock insights into data.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize:
                                    MediaQuery.of(context).size.width < 800
                                        ? 30
                                        : 45,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          _deviceCategories.isNotEmpty
                              ? _buildDeviceCards()
                              : _buildNoDevicesCard(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCards() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Separate counters for each sensor type
    int luxSensorCount = 0;
    int tempSensorCount = 0;
    int accelerometerSensorCount = 0;

    List<Widget> cardList = _deviceCategories.keys.map((category) {
      return Container(
          width: 300,
          height: 300,
          margin: EdgeInsets.all(10),
          child: Card(
            color: _getCardColor(category),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                      color: _getCardTextColor(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _deviceCategories[category]?.length ?? 0,
                      itemBuilder: (context, index) {
                        String sensorName = _deviceCategories[category]![index];
                        String sequentialName = '';

                        if (category == 'CPS Lab Sensors') {
                          if (sensorName.contains('LU')) {
                            luxSensorCount++;
                            sequentialName = 'Lux Sensor $luxSensorCount';
                          } else if (sensorName.contains('TE')) {
                            tempSensorCount++;
                            sequentialName =
                                'Temperature Sensor $tempSensorCount';
                          } else if (sensorName.contains('AC')) {
                            accelerometerSensorCount++;
                            sequentialName =
                                'Accelerometer Sensor $accelerometerSensorCount';
                          }
                        } else {
                          sequentialName =
                              '${category.split(" ").first} Sensor ${index + 1}';
                        }
                        // ✅ Only for the button text
                        String buttonLabel = '$sequentialName ($sensorName)';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: isDarkMode
                                  ? Colors.white
                                  : Colors.black, // text color
                              backgroundColor: isDarkMode
                                  ? Colors.black
                                  : Colors.white, // background
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            onPressed: () {
                              if (sensorName.startsWith('BF')) {
                                String numericNodeId =
                                    sensorName.replaceAll(RegExp(r'\D'), '');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BuffaloData(
                                      startDateTime: DateTime.now(),
                                      endDateTime:
                                          DateTime.now().add(Duration(days: 1)),
                                      nodeId: numericNodeId,
                                    ),
                                  ),
                                );
                              } else if (sensorName.startsWith('CS')) {
                                String numericNodeId =
                                    sensorName.replaceAll(RegExp(r'\D'), '');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CowData(
                                      startDateTime: DateTime.now(),
                                      endDateTime:
                                          DateTime.now().add(Duration(days: 1)),
                                      nodeId: numericNodeId,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeviceGraphPage(
                                      deviceName:
                                          _deviceCategories[category]![index],
                                      sequentialName: sequentialName,
                                      backgroundImagePath:
                                          'assets/backgroundd.jpg',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              buttonLabel,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ));
    }).toList();

    // Add the "Add Devices" button as a card
    cardList.add(
      Container(
        width: 300,
        height: 300,
        margin: EdgeInsets.all(10),
        child: Card(
          color: _getCardColor('AddDevice'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add New Device',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  backgroundColor: isDarkMode ? Colors.black : Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        QRScannerPopup(devices: _deviceCategories),
                  );
                },
                child: Text(
                  'Scan QR Code',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  backgroundColor: isDarkMode ? Colors.black : Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ManualEntryPopup(devices: _deviceCategories),
                  );
                },
                child: Text(
                  'Add Manually',
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 6,
      radius: const Radius.circular(8),
      interactive: true,
      child: Container(
        // 🔹 Transparent container so gradient is visible under scrollbar
        color: Colors.transparent,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            _scrollController.jumpTo(
              _scrollController.offset - details.delta.dx,
            );
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            padding:
                const EdgeInsets.only(bottom: 15.0, left: 12.0, right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: cardList,
            ),
          ),
        ),
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
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "No devices found." message
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No Device Found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 235, 28, 28),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // "Add New Device" heading
              Text(
                'Add New Device',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    backgroundColor: Colors.black),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        QRScannerPopup(devices: _deviceCategories),
                  );
                },
                child: Text(
                  'Scan QR Code',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ManualEntryPopup(devices: _deviceCategories),
                  );
                },
                child: Text(
                  'Add Manually',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _getCardColor(String category) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? Colors.grey[200]! : Colors.blueGrey[900]!;
  }

  Color _getCardTextColor() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? Colors.black : Colors.white;
  }
}
