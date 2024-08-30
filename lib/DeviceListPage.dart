// // import 'dart:convert';
// // import 'dart:ui'; // Import for ImageFilter

// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'DeviceGraphPage.dart';

// // class DeviceListPage extends StatefulWidget {
// //   @override
// //   _DeviceListPageState createState() => _DeviceListPageState();
// // }

// // class _DeviceListPageState extends State<DeviceListPage> {
// //   List<String> devices = [];
// //   bool isLoading = true;
// //   String errorMessage = '';

// //   // Notifier for hover state
// //   final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchDevices();
// //   }

// //   Future<void> _fetchDevices() async {
// //     try {
// //       final response = await http.get(Uri.parse(
// //           'https://c27wvohcuc.execute-api.us-east-1.amazonaws.com/default/beehive_activity_api'));

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         print("Fetched data: $data"); // Debugging output

// //         if (data is List) {
// //           final List<String> fetchedDevices = data.map<String>((device) {
// //             print("Device: $device"); // Debugging each device
// //             return device['deviceId'] != null
// //                 ? device['deviceId'].toString()
// //                 : 'Unknown';
// //           }).toList();

// //           if (fetchedDevices.isEmpty) {
// //             print("No devices found in the data.");
// //           }

// //           setState(() {
// //             devices = fetchedDevices;
// //             isLoading = false;
// //           });
// //         } else {
// //           setState(() {
// //             errorMessage = 'Unexpected data format.';
// //             isLoading = false;
// //           });
// //           print('Unexpected data format: $data');
// //         }
// //       } else {
// //         setState(() {
// //           errorMessage =
// //               'Failed to load devices. Status code: ${response.statusCode}';
// //           isLoading = false;
// //         });
// //         print('Failed to load devices. Status code: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       setState(() {
// //         errorMessage = 'Error fetching devices: $e';
// //         isLoading = false;
// //       });
// //       print('Error fetching devices: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       extendBodyBehindAppBar: true,
// //       appBar: AppBar(
// //         title: Padding(
// //           padding: const EdgeInsets.only(left: 20, top: 20.0),
// //           child: MouseRegion(
// //             onEnter: (_) => _isHovered.value = true,
// //             onExit: (_) => _isHovered.value = false,
// //             child: ValueListenableBuilder<bool>(
// //               valueListenable: _isHovered,
// //               builder: (context, isHovered, child) {
// //                 return ElevatedButton(
// //                   onPressed: () {
// //                     _showDeviceListPopup(context);
// //                   },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color.fromARGB(255, 12, 12, 12),
// //                     elevation: 0,
// //                     padding: const EdgeInsets.symmetric(
// //                         horizontal: 20, vertical: 20), // Reduced padding
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(30),
// //                     ),
// //                   ),
// //                   child: Text(
// //                     "Choose Your Device",
// //                     style: TextStyle(
// //                       color: isHovered ? Colors.blue : Colors.white,
// //                       fontSize: 20, // Slightly reduced font size
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ),
// //         toolbarHeight: 100, // Increased height of the AppBar
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //       ),
// //       body: Stack(
// //         children: [
// //           Container(
// //             decoration: const BoxDecoration(
// //               image: DecorationImage(
// //                 image: AssetImage('assets/backgroundd.jpg'),
// //                 fit: BoxFit.cover,
// //               ),
// //             ),
// //             child: BackdropFilter(
// //               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
// //               child: Container(
// //                 color: Colors.black.withOpacity(0.4),
// //               ),
// //             ),
// //           ),
// //           Center(
// //             child: Padding(
// //               padding: const EdgeInsets.all(20.0),
// //               child: Text(
// //                 "Select a device to unlock insights into temperature, humidity, light, and more—your complete environmental toolkit awaits.",
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(
// //                   fontFamily: 'OpenSans',

// //                   fontSize: 55,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,

// //                   // backgroundColor: Colors.black54,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _showDeviceListPopup(BuildContext context) {
// //     if (isLoading) {
// //       // Show loading indicator if data is still being fetched
// //       showDialog(
// //         context: context,
// //         builder: (context) {
// //           return AlertDialog(
// //             title: const Text("Devices"),
// //             content: const Center(
// //               child: CircularProgressIndicator(),
// //             ),
// //           );
// //         },
// //       );
// //     } else {
// //       showDialog(
// //         context: context,
// //         builder: (context) {
// //           return AlertDialog(
// //             title: const Text("Devices"),
// //             content: errorMessage.isNotEmpty
// //                 ? Text(errorMessage)
// //                 : devices.isNotEmpty
// //                     ? Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: devices.map((device) {
// //                           return ListTile(
// //                             title: Text(device),
// //                             onTap: () {
// //                               Navigator.of(context).pop();
// //                               _navigateToDeviceGraphPage(context, device);
// //                             },
// //                           );
// //                         }).toList(),
// //                       )
// //                     : const Text('No devices available.'),
// //             actions: [
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.of(context).pop();
// //                 },
// //                 child: const Text("Close"),
// //               ),
// //             ],
// //           );
// //         },
// //       );
// //     }
// //   }

// //   void _navigateToDeviceGraphPage(BuildContext context, String deviceName) {
// //     Navigator.of(context).push(
// //       MaterialPageRoute(
// //         builder: (context) => DeviceGraphPage(deviceName: deviceName),
// //       ),
// //     );
// //   }
// // }

// // import 'dart:convert';
// // import 'dart:ui'; // Import for ImageFilter

// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'DeviceGraphPage.dart';

// // class DeviceListPage extends StatefulWidget {
// //   @override
// //   _DeviceListPageState createState() => _DeviceListPageState();
// // }

// // class _DeviceListPageState extends State<DeviceListPage> {
// //   List<String> devices = [];
// //   bool isLoading = true;
// //   String errorMessage = '';

// //   // Notifier for hover state
// //   final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchDevices();
// //   }

// //   Future<void> _fetchDevices() async {
// //     try {
// //       final response = await http.get(Uri.parse(
// //           'https://c27wvohcuc.execute-api.us-east-1.amazonaws.com/default/beehive_activity_api'));

// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         print("Fetched data: $data"); // Debugging output

// //         if (data is List) {
// //           final List<String> fetchedDevices = data.map<String>((device) {
// //             print("Device: $device"); // Debugging each device
// //             return device['deviceId'] != null
// //                 ? device['deviceId'].toString()
// //                 : 'Unknown';
// //           }).toList();

// //           if (fetchedDevices.isEmpty) {
// //             print("No devices found in the data.");
// //           }

// //           setState(() {
// //             devices = fetchedDevices;
// //             isLoading = false;
// //           });
// //         } else {
// //           setState(() {
// //             errorMessage = 'Unexpected data format.';
// //             isLoading = false;
// //           });
// //           print('Unexpected data format: $data');
// //         }
// //       } else {
// //         setState(() {
// //           errorMessage =
// //               'Failed to load devices. Status code: ${response.statusCode}';
// //           isLoading = false;
// //         });
// //         print('Failed to load devices. Status code: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       setState(() {
// //         errorMessage = 'Error fetching devices: $e';
// //         isLoading = false;
// //       });
// //       print('Error fetching devices: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       extendBodyBehindAppBar: true,
// //       appBar: AppBar(
// //         title: Padding(
// //           padding: const EdgeInsets.only(left: 20, top: 20.0),
// //           child: MouseRegion(
// //             onEnter: (_) => _isHovered.value = true,
// //             onExit: (_) => _isHovered.value = false,
// //             child: ValueListenableBuilder<bool>(
// //               valueListenable: _isHovered,
// //               builder: (context, isHovered, child) {
// //                 return ElevatedButton(
// //                   onPressed: () {
// //                     _showDeviceListPopup(context);
// //                   },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color.fromARGB(255, 12, 12, 12),
// //                     elevation: 0,
// //                     padding: const EdgeInsets.symmetric(
// //                         horizontal: 20, vertical: 20), // Reduced padding
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(30),
// //                     ),
// //                   ),
// //                   child: Text(
// //                     "Choose Your Device",
// //                     style: TextStyle(
// //                       color: isHovered ? Colors.blue : Colors.white,
// //                       fontSize: 20, // Slightly reduced font size
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ),
// //         toolbarHeight: 100, // Increased height of the AppBar
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //       ),
// //       body: Stack(
// //         children: [
// //           Container(
// //             decoration: const BoxDecoration(
// //               image: DecorationImage(
// //                 image: AssetImage('assets/backgroundd.jpg'),
// //                 fit: BoxFit.cover,
// //               ),
// //             ),
// //             child: BackdropFilter(
// //               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
// //               child: Container(
// //                 color: Colors.black.withOpacity(0.4),
// //               ),
// //             ),
// //           ),
// //           Center(
// //             child: Padding(
// //               padding: const EdgeInsets.all(20.0),
// //               child: Text(
// //                 "Select a device to unlock insights into temperature, humidity, light, and more—your complete environmental toolkit awaits.",
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(
// //                   fontFamily: 'OpenSans',

// //                   fontSize: 55,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,

// //                   // backgroundColor: Colors.black54,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _showDeviceListPopup(BuildContext context) {
// //     if (isLoading) {
// //       // Show loading indicator if data is still being fetched
// //       showDialog(
// //         context: context,
// //         builder: (context) {
// //           return AlertDialog(
// //             title: const Text("Devices"),
// //             content: const Center(
// //               child: CircularProgressIndicator(),
// //             ),
// //           );
// //         },
// //       );
// //     } else {
// //       showDialog(
// //         context: context,
// //         builder: (context) {
// //           return AlertDialog(
// //             title: const Text("Devices"),
// //             content: errorMessage.isNotEmpty
// //                 ? Text(errorMessage)
// //                 : devices.isNotEmpty
// //                     ? Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: devices.map((device) {
// //                           return ListTile(
// //                             title: Text(device),
// //                             onTap: () {
// //                               Navigator.of(context).pop();
// //                               _navigateToDeviceGraphPage(context, device);
// //                             },
// //                           );
// //                         }).toList(),
// //                       )
// //                     : const Text('No devices available.'),
// //             actions: [
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.of(context).pop();
// //                 },
// //                 child: const Text("Close"),
// //               ),
// //             ],
// //           );
// //         },
// //       );
// //     }
// //   }

// //   void _navigateToDeviceGraphPage(BuildContext context, String deviceName) {
// //     Navigator.of(context).push(
// //       MaterialPageRoute(
// //         builder: (context) => DeviceGraphPage(deviceName: deviceName),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'AddDevice.dart';

// class DataDisplayPage extends StatefulWidget {
//   final String email;

//   DataDisplayPage({required this.email});

//   @override
//   _DataDisplayPageState createState() => _DataDisplayPageState();
// }

// class _DataDisplayPageState extends State<DataDisplayPage> {
//   bool _isLoading = true;
//   List<String> _deviceIds = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     final url =
//         'https://ln8b1r7ld9.execute-api.us-east-1.amazonaws.com/default/Cloudsense_user_devices?email_id=${widget.email}';
//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);
//         setState(() {
//           _deviceIds = List<String>.from(result['device_id'] ?? []);
//         });
//       }
//     } catch (error) {
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Devices'),
//       ),
//       body: Center(
//         child: _isLoading
//             ? CircularProgressIndicator()
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: _deviceIds.isNotEmpty
//                         ? _buildDeviceList()
//                         : Center(
//                             child: Text('No devices found.'),
//                           ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => QRScannerPage(),

//                             //QRScannerPage(),
//                           ),
//                         );
//                       },
//                       child: Text('Add Devices'),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildDeviceList() {
//     return ListView.builder(
//       itemCount: _deviceIds.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(_deviceIds[index]),
//         );
//       },
//     );
//   }
// }

// import 'package:cloud_sense_webapp/DeviceGraphPage.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'DeviceGraphPage.dart';

// import 'AddDevice.dart';
// // Import the new page

// class DataDisplayPage extends StatefulWidget {
//   final String email;

//   DataDisplayPage({required this.email});

//   @override
//   _DataDisplayPageState createState() => _DataDisplayPageState();
// }

// class _DataDisplayPageState extends State<DataDisplayPage> {
//   bool _isLoading = true;
//   Map<String, List<String>> _deviceCategories = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     final url =
//         'https://ln8b1r7ld9.execute-api.us-east-1.amazonaws.com/default/Cloudsense_user_devices?email_id=${widget.email}';
//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);

//         setState(() {
//           // Extract categories like Biodiversity Sensor, Weather Sensor, etc.
//           _deviceCategories = {
//             for (var key in result.keys)
//               if (key != 'device_id' && key != 'email_id')
//                 _mapCategory(key): List<String>.from(result[key] ?? [])
//           };
//         });
//       }
//     } catch (error) {
//       // Handle errors appropriately
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   String _mapCategory(String key) {
//     switch (key) {
//       case 'BD':
//         return 'Biodiversity Sensor';
//       case 'WD':
//         return 'Weather Sensor';
//       default:
//         return key;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Chosen Devices'),
//         backgroundColor: const Color.fromARGB(169, 46, 88, 151),
//       ),
//       body: Center(
//         child: _isLoading
//             ? CircularProgressIndicator()
//             : Column(
//                 children: [
//                   Expanded(
//                     child: _deviceCategories.isNotEmpty
//                         ? _buildDeviceCards()
//                         : Center(
//                             child: Text('No devices found.'),
//                           ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                         backgroundColor: const Color.fromARGB(169, 46, 88, 151),
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => QRScannerPage(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         'Add Devices',
//                         style: TextStyle(
//                             color: const Color.fromARGB(255, 245, 241, 240)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildDeviceCards() {
//     return ListView(
//       children: _deviceCategories.keys.map((category) {
//         return Card(
//           color: _getCardColor(category),
//           margin: EdgeInsets.all(30),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   category,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 ..._deviceCategories[category]!.map((deviceId) {
//                   return InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => DeviceGraphPage(
//                             deviceName: deviceId,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Text(
//                       deviceId,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Color _getCardColor(String category) {
//     switch (category) {
//       case 'Biodiversity Sensor':
//         return Colors.blue;
//       case 'Weather Sensor':
//         return Colors.green;
//       // Add more categories with their colors here
//       default:
//         return Colors.grey;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AddDevice.dart';
import 'DeviceGraphPage.dart';

class DataDisplayPage extends StatefulWidget {
  final String email;

  DataDisplayPage({required this.email});

  @override
  _DataDisplayPageState createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  bool _isLoading = true;
  Map<String, List<String>> _deviceCategories = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final url =
        'https://ln8b1r7ld9.execute-api.us-east-1.amazonaws.com/default/Cloudsense_user_devices?email_id=${widget.email}';
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
      appBar: AppBar(
        title: Text('Your Chosen Devices'),
        backgroundColor: const Color.fromARGB(169, 46, 88, 151),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _deviceCategories.isNotEmpty
                        ? _buildDeviceCards()
                        : Center(
                            child: Text('No devices found.'),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: const Color.fromARGB(169, 46, 88, 151),
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
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDeviceCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _deviceCategories.keys.map((category) {
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
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: _deviceCategories[category]!.map((deviceId) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeviceGraphPage(
                                    deviceName: deviceId,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              deviceId,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getCardColor(String category) {
    switch (category) {
      case 'Biodiversity Sensors':
        return Colors.blue;
      case 'Weather Sensors':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
