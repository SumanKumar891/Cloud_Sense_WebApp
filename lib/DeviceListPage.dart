import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'DeviceGraphPage.dart';

class DeviceListPage extends StatefulWidget {
  final String emailId;

  DeviceListPage({required this.emailId}); // Add emailId as a parameter

  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<Map<String, dynamic>> devices = []; // List of devices with details
  bool isLoading = true;
  String errorMessage = '';

  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    final url =
        'https://ln8b1r7ld9.execute-api.us-east-1.amazonaws.com/default/Cloudsense_user_devices?email_id=${widget.emailId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Fetched data: $data");

        if (data is List) {
          final List<Map<String, dynamic>> fetchedDevices =
              List<Map<String, dynamic>>.from(data);

          setState(() {
            devices = fetchedDevices;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Unexpected data format.';
            isLoading = false;
          });
          print('Unexpected data format: $data');
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load devices. Status code: ${response.statusCode}';
          isLoading = false;
        });
        print('Failed to load devices. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching devices: $e';
        isLoading = false;
      });
      print('Error fetching devices: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20.0),
          child: MouseRegion(
            onEnter: (_) => _isHovered.value = true,
            onExit: (_) => _isHovered.value = false,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isHovered,
              builder: (context, isHovered, child) {
                return ElevatedButton(
                  onPressed: () {
                    _showDeviceListPopup(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 12, 12, 12),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Choose Your Device",
                    style: TextStyle(
                      color: isHovered ? Colors.blue : Colors.white,
                      fontSize: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        toolbarHeight: 100, // Increased height of the AppBar
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background image with blur effect
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/backgroundd.jpg',
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(
                    color: Colors.black.withOpacity(
                        0.4), // Optional: To darken the blurred image
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Select a device to unlock insights into temperature, humidity, light, and \n more—your complete environmental toolkit awaits.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Changed text color for better contrast
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceListPopup(BuildContext context) {
    if (isLoading) {
      // Show loading indicator if data is still being fetched
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Devices"),
            content: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Devices"),
            content: errorMessage.isNotEmpty
                ? Text(errorMessage)
                : devices.isNotEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: devices.map((device) {
                          final deviceId = device['deviceId'] ?? 'Unknown';
                          final deviceName =
                              device['deviceName'] ?? 'Unnamed Device';
                          return ListTile(
                            title: Text(deviceName),
                            subtitle: Text(deviceId),
                            onTap: () {
                              Navigator.of(context).pop();
                              _navigateToDeviceGraphPage(context, deviceName);
                            },
                          );
                        }).toList(),
                      )
                    : Text('No devices available.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToDeviceGraphPage(BuildContext context, String deviceName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeviceGraphPage(deviceName: deviceName),
      ),
    );
  }
}
