import 'dart:convert';
import 'dart:ui'; // Import for ImageFilter

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'DeviceGraphPage.dart';

class DeviceListPage extends StatefulWidget {
  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<String> devices = [];
  bool isLoading = true;
  String errorMessage = '';

  // Notifier for hover state
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    try {
      final response = await http.get(Uri.parse(
          'https://c27wvohcuc.execute-api.us-east-1.amazonaws.com/default/beehive_activity_api'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Fetched data: $data"); // Debugging output

        if (data is List) {
          final List<String> fetchedDevices = data.map<String>((device) {
            print("Device: $device"); // Debugging each device
            return device['deviceId'] != null
                ? device['deviceId'].toString()
                : 'Unknown';
          }).toList();

          if (fetchedDevices.isEmpty) {
            print("No devices found in the data.");
          }

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
                        horizontal: 20, vertical: 20), // Reduced padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Choose Your Device",
                    style: TextStyle(
                      color: isHovered ? Colors.blue : Colors.white,
                      fontSize: 20, // Slightly reduced font size
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
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Select a device to unlock insights into temperature, humidity, light, and more—your complete environmental toolkit awaits.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'OpenSans',

                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,

                  // backgroundColor: Colors.black54,
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
            title: const Text("Devices"),
            content: const Center(
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
            title: const Text("Devices"),
            content: errorMessage.isNotEmpty
                ? Text(errorMessage)
                : devices.isNotEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: devices.map((device) {
                          return ListTile(
                            title: Text(device),
                            onTap: () {
                              Navigator.of(context).pop();
                              _navigateToDeviceGraphPage(context, device);
                            },
                          );
                        }).toList(),
                      )
                    : const Text('No devices available.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
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
