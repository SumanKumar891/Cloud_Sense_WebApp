import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  // Future<void> _fetchDevices() async {
  //   try {
  //     final response = await http.get(Uri.parse(
  //         'https://c27wvohcuc.execute-api.us-east-1.amazonaws.com/default/beehive_activity_api'));

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       print("Fetched data: $data"); // Debugging output

  //       if (data is List) {
  //         final List<String> fetchedDevices = data.map<String>((device) {
  //           // Ensure 'deviceId' is the correct key; adjust if necessary
  //           return device['deviceId'] != null ? device['deviceId'].toString() : 'Unknown';
  //         }).toList();
  //         setState(() {
  //           devices = fetchedDevices;
  //           isLoading = false;
  //         });
  //       } else {
  //         setState(() {
  //           errorMessage = 'Unexpected data format.';
  //           isLoading = false;
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         errorMessage = 'Failed to load devices. Status code: ${response.statusCode}';
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = 'Error fetching devices: $e';
  //       isLoading = false;
  //     });
  //   }
  // }
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
          return device['deviceId'] != null ? device['deviceId'].toString() : 'Unknown';
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
        errorMessage = 'Failed to load devices. Status code: ${response.statusCode}';
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
          padding: const EdgeInsets.only(left: 20, top: 40.0),
          child: GestureDetector(
            onTap: () {
              _showDeviceListPopup(context);
            },
            child: Text(
              "Your Chosen Devices",
              style: TextStyle(
                color: const Color.fromARGB(255, 56, 56, 56),
                fontSize: 25,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
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
                          return ListTile(
                            title: Text(device),
                            onTap: () {
                              Navigator.of(context).pop();
                              _navigateToDeviceGraphPage(context, device);
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