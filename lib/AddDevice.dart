import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with WidgetsBindingObserver {
  String? scannedQRCode;
  String message = "Position the QR code inside the scanner";
  late MobileScannerController _controller;
  String? _email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController();
    _loadEmail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (scannedQRCode == null) {
        _controller.start();
      }
    } else if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  void resetScanner() {
    setState(() {
      scannedQRCode = null;
      message = "Position the QR code inside the scanner";
      _controller.start(); // Resume the scanner
    });
  }

  Future<bool> _onWillPop() async {
    _controller.stop();
    return true;
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      setState(() {
        _email = email;
      });
    } else {
      // Handle case where email is not found, e.g., navigate to sign-in page
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  Future<void> _showConfirmationDialog(String scannedQRCode) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Device Addition'),
          content: Text('Do you want to add this device'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _addDevice(scannedQRCode); // Call the API
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
          message = "Device ID updated successfully.";
        });
      } else {
        setState(() {
          message = "Failed to add device. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        message = "An error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('QR Scanner'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 4),
                ),
                child: MobileScanner(
                  controller: _controller,
                  allowDuplicates: false,
                  onDetect: (barcode, args) {
                    final String? code = barcode.rawValue;
                    if (code != null && code != scannedQRCode) {
                      // If a new QR code is scanned, process it
                      setState(() {
                        scannedQRCode = code;
                        message = "Detected QR Code";
                      });
                      _controller.stop(); // Stop the scanner
                      _showConfirmationDialog(code); // Show confirmation dialog
                    } else {
                      setState(() {
                        message = "No valid QR Code detected";
                      });
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  message,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: resetScanner,
                child: Text('Scan Again'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
