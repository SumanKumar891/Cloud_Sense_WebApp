// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'LoginPage.dart'; // Make sure to import your login page file

// class AccountInfoPage extends StatefulWidget {
//   @override
//   _AccountInfoPageState createState() => _AccountInfoPageState();
// }

// class _AccountInfoPageState extends State<AccountInfoPage> {
//   String? userId;
//   String? userEmail;
//   String? device_id;
//   bool _isLoading = true;
//   Map<String, List<String>> deviceCategories = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       userEmail = prefs.getString('email') ?? 'Unknown';

//       await _fetchData(); // Fetch device data after loading user data

//       setState(() {});
//     } catch (e) {
//       print('Error loading user data: $e');
//     }
//   }

//   Future<void> _fetchData() async {
//     if (userEmail == null) return;

//     final url =
//         'https://ln8b1r7ld9.execute-api.us-east-1.amazonaws.com/default/Cloudsense_user_devices?email_id=$userEmail';
//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final result = json.decode(response.body);

//         setState(() {
//           deviceCategories = {
//             for (var key in result.keys)
//               if (key != 'device_id' && key != 'email_id')
//                 key: List<String>.from(result[key] ?? [])
//           };
//         });
//       } else {
//         print('Failed to load devices. Status Code: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching data: $error');
//     } finally {
//       setState(() {
//         _isLoading = false; // Update loading state
//       });
//     }
//   }

//   Future<void> _deleteAccount() async {
//     // Show confirmation dialog before deleting the account
//     bool? confirmed = await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Account'),
//         content: Text(
//             'Are you sure you want to delete your account? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             child: Text('Cancel'),
//             onPressed: () => Navigator.pop(context, false),
//           ),
//           TextButton(
//             child: Text('Delete'),
//             onPressed: () => Navigator.pop(context, true),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       if (userEmail == null) return;

//       final url =
//           'https://25e5bsdhwd.execute-api.us-east-1.amazonaws.com/default/CloudSense_users_delete_function?email_id=$userEmail&action=delete_user';

//       try {
//         final response = await http.delete(Uri.parse(url));

//         if (response.statusCode == 200 || response.statusCode == 404) {
//           // Success or account already deleted
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Account deleted successfully."),
//               backgroundColor: Colors.green,
//             ),
//           );

//           try {
//             await Amplify.Auth.deleteUser();
//           } catch (e) {
//             print("Error deleting user from Cognito: $e");
//           }

//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.remove('email'); // Clear the saved email

//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => SignInSignUpScreen()),
//             (Route<dynamic> route) => false,
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Failed to delete account. Please try again."),
//               backgroundColor: Colors.red,
//             ),
//           );
//           print(
//               'Failed to delete account. Status Code: ${response.statusCode}');
//           print('Response Body: ${response.body}');
//         }
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error occurred while deleting account."),
//             backgroundColor: Colors.red,
//           ),
//         );
//         print('Error deleting account: $error');
//       }
//     }
//   }

//   Future<void> _deleteDevices() async {
//     if (deviceCategories.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("No devices available to delete."),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // Create a map to track selected devices
//     Map<String, List<bool>> selectedDevices = {
//       for (var key in deviceCategories.keys)
//         key: List<bool>.filled(deviceCategories[key]!.length, false),
//     };

//     // Show dialog for device selection
//     bool? confirmed = await showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Text('Delete Devices'),
//             content: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: deviceCategories.entries.map((entry) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Sensor : ${entry.key}',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       ...List.generate(entry.value.length, (index) {
//                         return CheckboxListTile(
//                           title: Text('Device ID - ${entry.value[index]}'),
//                           value: selectedDevices[entry.key]![index],
//                           onChanged: (value) {
//                             setState(() {
//                               selectedDevices[entry.key]![index] =
//                                   value ?? false;
//                             });
//                           },
//                         );
//                       }),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: Text('Delete'),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     if (confirmed == true) {
//       // Collect selected device IDs
//       List<String> devicesToDelete = [];
//       selectedDevices.forEach((sensor, selections) {
//         for (int i = 0; i < selections.length; i++) {
//           if (selections[i]) {
//             devicesToDelete.add(deviceCategories[sensor]![i]);
//           }
//         }
//       });

//       if (devicesToDelete.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("No devices selected for deletion."),
//             backgroundColor: Colors.orange,
//           ),
//         );
//         return;
//       }

//       // Prepare the API call
//       try {
//         for (var deviceId in devicesToDelete) {
//           final url =
//               'https://25e5bsdhwd.execute-api.us-east-1.amazonaws.com/default/CloudSense_users_delete_function?email_id=$userEmail&action=delete_devices&device_id=$deviceId';

//           final response = await http.get(Uri.parse(url));

//           if (response.statusCode == 200) {
//             final data = json.decode(response.body);
//             print('Response: $data');

//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(data['message']),
//                 backgroundColor: Colors.green,
//               ),
//             );

//             setState(() {
//               // Remove deleted devices from local state
//               deviceCategories.forEach((sensor, devices) {
//                 devices.remove(deviceId);
//               });
//               deviceCategories.removeWhere((key, value) => value.isEmpty);
//             });
//           } else {
//             print('Response Status Code: ${response.statusCode}');
//             print('Response Body: ${response.body}');
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text("Failed to delete device ID $deviceId."),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         }
//       } catch (error) {
//         print('Exception occurred: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error occurred while deleting devices."),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text(
//           'Account Info',
//           style: TextStyle(
//             fontSize: MediaQuery.of(context).size.width < 800 ? 16 : 32,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/accountinfo.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//               child: Container(
//                 color: Colors.black.withOpacity(0.3),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 80),
//                 Text(
//                   'Email ID : ${userEmail ?? "Loading..."}',
//                   style: TextStyle(
//                       fontSize:
//                           MediaQuery.of(context).size.width < 800 ? 16 : 24,
//                       color: Colors.black),
//                 ),
//                 SizedBox(height: 60),
//                 _isLoading
//                     ? CircularProgressIndicator()
//                     : deviceCategories.isNotEmpty
//                         ? Expanded(
//                             child: SingleChildScrollView(
//                               scrollDirection: Axis.vertical,
//                               child: Table(
//                                 border: TableBorder.all(
//                                   color: Colors.black,
//                                   width: 1.5,
//                                 ), // Optional for table borders
//                                 children: [
//                                   // Table header row for sensors
//                                   TableRow(
//                                     decoration:
//                                         BoxDecoration(color: Colors.blue),
//                                     children:
//                                         deviceCategories.keys.map((sensorKey) {
//                                       return Padding(
//                                         padding: const EdgeInsets.all(16.0),
//                                         child: Text(
//                                           sensorKey.trim(),
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: MediaQuery.of(context)
//                                                         .size
//                                                         .width <
//                                                     800
//                                                 ? 13
//                                                 : 22,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       );
//                                     }).toList(),
//                                   ),
//                                   // Table rows for devices associated with each sensor
//                                   TableRow(
//                                     children: deviceCategories.values
//                                         .map((deviceList) {
//                                       return Padding(
//                                         padding: const EdgeInsets.all(36.0),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: deviceList.map((device) {
//                                             return Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 // Bullet
//                                                 Text(
//                                                   '• ',
//                                                   style: TextStyle(
//                                                     fontSize:
//                                                         MediaQuery.of(context)
//                                                                     .size
//                                                                     .width <
//                                                                 800
//                                                             ? 10
//                                                             : 20,
//                                                     height: 1.5,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                                 // Device ID
//                                                 Expanded(
//                                                   child: Text(
//                                                     'Device ID - $device',
//                                                     style: TextStyle(
//                                                       fontSize:
//                                                           MediaQuery.of(context)
//                                                                       .size
//                                                                       .width <
//                                                                   800
//                                                               ? 10
//                                                               : 20,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             );
//                                           }).toList(),
//                                         ),
//                                       );
//                                     }).toList(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                         : Text(
//                             'No devices found',
//                             style: TextStyle(fontSize: 18, color: Colors.black),
//                           ),
//                 SizedBox(height: 50),
//                 Center(
//                   child: Column(
//                     children: [
//                       ElevatedButton(
//                         onPressed: _deleteDevices,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           foregroundColor: Colors.black,
//                         ),
//                         child: Text('Delete Devices'),
//                       ),
//                       SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: _deleteAccount,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           foregroundColor: Colors.black,
//                         ),
//                         child: Text('Delete Account'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'LoginPage.dart'; // Make sure to import your login page file

class AccountInfoPage extends StatefulWidget {
  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  String? userId;
  String? userEmail;
  String? device_id;
  bool _isLoading = true;
  Map<String, List<String>> deviceCategories = {};
  TextEditingController _emailController =
      TextEditingController(); // Controller for email input

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('email') ?? 'Unknown';
      _emailController.text =
          userEmail ?? ''; // Pre-fill email field with the stored email

      await _fetchData(); // Fetch device data after loading user data

      setState(() {});
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _fetchData() async {
    final email = _emailController.text.trim(); // Get the entered email
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid email."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      deviceCategories.clear(); // Clear old data
    });

    final url =
        'https://ln8b1r7ld9.execute-api.us-east-1.amazonaws.com/default/Cloudsense_user_devices?email_id=$email';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        setState(() {
          deviceCategories = {
            for (var key in result.keys)
              if (key != 'device_id' && key != 'email_id')
                key: List<String>.from(result[key] ?? [])
          };
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load devices. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        print('Failed to load devices. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching data."),
          backgroundColor: Colors.red,
        ),
      );
      print('Error fetching data: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    // Get the email ID entered by the user
    String emailToDelete = _emailController.text.trim();

    if (emailToDelete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter an email ID to delete."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog before deleting the account
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
            'Are you sure you want to delete the account associated with $emailToDelete? This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final url =
          'https://25e5bsdhwd.execute-api.us-east-1.amazonaws.com/default/CloudSense_users_delete_function?email_id=$emailToDelete&action=delete_user';

      try {
        final response = await http.delete(Uri.parse(url));

        if (response.statusCode == 200 || response.statusCode == 404) {
          // Success or account already deleted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account deleted successfully."),
              backgroundColor: Colors.green,
            ),
          );

          // If the deleted account is the currently logged-in user, log them out
          if (emailToDelete == userEmail) {
            try {
              await Amplify.Auth.deleteUser();
            } catch (e) {
              print("Error deleting user from Cognito: $e");
            }

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('email'); // Clear the saved email

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignInSignUpScreen()),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete account. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
          print(
              'Failed to delete account. Status Code: ${response.statusCode}');
          print('Response Body: ${response.body}');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error occurred while deleting account."),
            backgroundColor: Colors.red,
          ),
        );
        print('Error deleting account: $error');
      }
    }
  }

  Future<void> _deleteDevices() async {
    if (deviceCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No devices available to delete."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create a map to track selected devices
    Map<String, List<bool>> selectedDevices = {
      for (var key in deviceCategories.keys)
        key: List<bool>.filled(deviceCategories[key]!.length, false),
    };

    // Show dialog for device selection
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Delete Devices'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: deviceCategories.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sensor : ${entry.key}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...List.generate(entry.value.length, (index) {
                        return CheckboxListTile(
                          title: Text('Device ID - ${entry.value[index]}'),
                          value: selectedDevices[entry.key]![index],
                          onChanged: (value) {
                            setState(() {
                              selectedDevices[entry.key]![index] =
                                  value ?? false;
                            });
                          },
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true) {
      // Collect selected device IDs
      List<String> devicesToDelete = [];
      selectedDevices.forEach((sensor, selections) {
        for (int i = 0; i < selections.length; i++) {
          if (selections[i]) {
            devicesToDelete.add(deviceCategories[sensor]![i]);
          }
        }
      });

      if (devicesToDelete.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No devices selected for deletion."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Prepare the API call
      try {
        for (var deviceId in devicesToDelete) {
          final url =
              'https://25e5bsdhwd.execute-api.us-east-1.amazonaws.com/default/CloudSense_users_delete_function?email_id=$userEmail&action=delete_devices&device_id=$deviceId';

          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('Response: $data');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message']),
                backgroundColor: Colors.green,
              ),
            );

            setState(() {
              // Remove deleted devices from local state
              deviceCategories.forEach((sensor, devices) {
                devices.remove(deviceId);
              });
              deviceCategories.removeWhere((key, value) => value.isEmpty);
            });
          } else {
            print('Response Status Code: ${response.statusCode}');
            print('Response Body: ${response.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to delete device ID $deviceId."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (error) {
        print('Exception occurred: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error occurred while deleting devices."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Account Info',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 800 ? 16 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/accountinfo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter Email ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _fetchData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Fetch Devices"),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : deviceCategories.isNotEmpty
                        ? Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Table(
                                border: TableBorder.all(
                                  color: Colors.black,
                                  width: 1.5,
                                ), // Optional for table borders
                                children: [
                                  // Table header row for sensors
                                  TableRow(
                                    decoration:
                                        BoxDecoration(color: Colors.blue),
                                    children:
                                        deviceCategories.keys.map((sensorKey) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          sensorKey.trim(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    800
                                                ? 13
                                                : 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  // Table rows for devices associated with each sensor
                                  TableRow(
                                    children: deviceCategories.values
                                        .map((deviceList) {
                                      return Padding(
                                        padding: const EdgeInsets.all(36.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: deviceList.map((device) {
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Bullet
                                                Text(
                                                  '• ',
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                800
                                                            ? 10
                                                            : 20,
                                                    height: 1.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // Device ID
                                                Expanded(
                                                  child: Text(
                                                    'Device ID - $device',
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  800
                                                              ? 10
                                                              : 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Text(
                            'No devices found',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                Spacer(), // Pushes the buttons to the bottom
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _deleteDevices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Delete Devices"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Delete Account"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
