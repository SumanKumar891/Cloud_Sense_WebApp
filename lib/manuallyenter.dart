import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_sense_webapp/DeviceListPage.dart';
import 'shareddevice.dart'; // Shared utilities file

class ManualEntryPage extends StatefulWidget {
  final Map<String, List<String>> devices;

  ManualEntryPage({required this.devices});

  @override
  _ManualEntryPageState createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<ManualEntryPage> {
  TextEditingController deviceIdController = TextEditingController();
  String? _email;
  String message = "";
  Color messageColor = Colors.teal;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  @override
  void dispose() {
    deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      setState(() {
        _email = email;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  Future<void> _showSuccessMessage() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message,
              style: TextStyle(
                color: messageColor,
                fontSize: 16,
              )),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DataDisplayPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addDevice(String deviceID) async {
    final String apiUrl =
        "https://ymfmk699j5.execute-api.us-east-1.amazonaws.com/default/Cloudsense_user_add_devices?email_id=$_email&device_id=$deviceID";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          message = "Device added successfully.";
          messageColor = Colors.green;
        });
      } else {
        setState(() {
          message = "Failed to add device. Please try again.";
          messageColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        message = "An error occurred: $e";
        messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Device Manually'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40),
            TextField(
              controller: deviceIdController,
              decoration: InputDecoration(
                labelText: 'Enter Device ID',
                border: OutlineInputBorder(),
                helperText: 'Enter the device ID (e.g., WD101, CL102, TH200)',
              ),
            ),
            SizedBox(height: 20),
            Center(
              // Centering the button
              child: SizedBox(
                width: 150, // Set width to make it smaller
                child: ElevatedButton(
                  onPressed: () {
                    String deviceId = deviceIdController.text.trim();
                    if (deviceId.isNotEmpty) {
                      DeviceUtils.showConfirmationDialog(
                        context: context,
                        deviceId: deviceId,
                        devices: widget.devices,
                        onConfirm: () async {
                          await _addDevice(deviceId);
                          await _showSuccessMessage();
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a valid device ID'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Add Device'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
