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
  bool _isLoading = true;
  Map<String, List<String>> deviceCategories = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('email') ?? 'Unknown';

      await _fetchData(); // Fetch device data after loading user data

      setState(() {});
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _fetchData() async {
    if (userEmail == null) return;

    final url =
        'https://ln8b1r7ld9.execute-api.us-east-1.amazonaws.com/default/Cloudsense_user_devices?email_id=$userEmail';
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
        print('Failed to load devices. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    } finally {
      setState(() {
        _isLoading = false; // Update loading state
      });
    }
  }

  Future<void> _deleteAccount() async {
    // Show confirmation dialog before deleting the account
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
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
      if (userEmail == null) return;

      final url =
          'https://g69z053bif.execute-api.us-east-1.amazonaws.com/default/CloudSense_users_delete_function?email_id=$userEmail&action=delete_user';

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
    // Show confirmation dialog before deleting the devices
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Devices'),
        content: Text(
            'Are you sure you want to delete all associated devices? This action cannot be undone.'),
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
      if (userEmail == null) return;

      final url =
          'https://g69z053bif.execute-api.us-east-1.amazonaws.com/default/CloudSense_users_delete_function?email_id=$userEmail&action=delete_devices';

      try {
        final response = await http.delete(Uri.parse(url));

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Devices deleted successfully."),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            deviceCategories.clear(); // Clear the device list after deletion
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete devices. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
          print(
              'Failed to delete devices. Status Code: ${response.statusCode}');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error occurred while deleting devices."),
            backgroundColor: Colors.red,
          ),
        );
        print('Error deleting devices: $error');
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
                Text(
                  'Email ID : ${userEmail ?? "Loading..."}',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                SizedBox(height: 2),
                _isLoading
                    ? CircularProgressIndicator()
                    : deviceCategories.isNotEmpty
                        ? Expanded(
                            child: ListView(
                              children: deviceCategories.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ' Sensor Associated : ${entry.key}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    for (var device in entry.value)
                                      Text('   Device ID - $device'),
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                        : Text(
                            'No devices found',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                SizedBox(height: 50),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _deleteDevices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Delete Devices'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Delete Account'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
