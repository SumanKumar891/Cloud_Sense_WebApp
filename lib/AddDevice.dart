import 'package:cloud_sense_webapp/DeviceListPage.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QRScannerPage extends StatefulWidget {
  final Map<String, List<String>> devices;

  QRScannerPage({
    required this.devices,
  });

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? scannedQRCode;
  String message = "Position the QR code inside the scanner";
  late MobileScannerController _controller;
  String? _email;
  Color messageColor = Colors.teal;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    _loadEmail();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void resetScanner() {
    setState(() {
      scannedQRCode = null;
      message = "Position the QR code inside the scanner";
      _controller.stop();
      _controller.start();
    });
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

  Future<void> _showConfirmationDialog(String scannedQRCode) async {
    bool deviceExists = false;
    String sensorType = '';
    String sensorPrefix = '';
    int sensorNumber = 0;

    if (scannedQRCode.startsWith('WD')) {
      sensorType = 'Weather Sensor';

      sensorNumber = (widget.devices['Weather Sensors']?.length ?? 0) + 1;
    } else if (scannedQRCode.startsWith('CL') ||
        scannedQRCode.startsWith('BD')) {
      sensorType = 'Chlorine Sensor';

      sensorNumber = (widget.devices['Chlorine Sensors']?.length ?? 0) + 1;
    } else if (scannedQRCode.startsWith('SS')) {
      sensorType = 'Soil Sensor';

      sensorNumber = (widget.devices['Soil Sensors']?.length ?? 0) + 1;
    } else if (scannedQRCode.startsWith('WQ')) {
      sensorType = 'Water Quality Sensor';

      sensorNumber = (widget.devices['Water Quality Sensors']?.length ?? 0) + 1;
    } else if (scannedQRCode.startsWith('WS')) {
      sensorType = 'Water Sensor';

      sensorNumber = (widget.devices['Water Sensors']?.length ?? 0) + 1;
    } else if (scannedQRCode.startsWith('DO')) {
      sensorType = 'DO Sensor';

      sensorNumber = (widget.devices['DO Sensors']?.length ?? 0) + 1;
    } else if (scannedQRCode.startsWith('LU')) {
      sensorType = 'LU Sensor';
      sensorNumber = (widget.devices['Lux Sensors']?.length ?? 0) + 1;
    } else if (scannedQRCode.startsWith('TE')) {
      sensorType = 'TE Sensor';
      sensorNumber = (widget.devices['Temperature Sensors']?.length ?? 0) + 1;
    } else if (scannedQRCode.startsWith('AC')) {
      sensorType = 'AC Sensor';
      sensorNumber = (widget.devices['Accelerometer Sensors']?.length ?? 0) + 1;
    } else {
      sensorType = 'Unknown Sensor';
      sensorNumber = (widget.devices['Unknown Sensors']?.length ?? 0) + 1;
    }

    deviceExists = widget.devices.values
        .any((deviceList) => deviceList.contains(scannedQRCode));

    if (deviceExists) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Device Already Exists'),
            content: Text('This $sensorType is already added to your account.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      // // Get all sensors under "CPS Lab Sensors"
      // List<String> cpsLabSensors = widget.devices['CPS Lab Sensors'] ?? [];

      // // Determine the number of existing sensors with the same prefix
      // List<String> specificSensors = cpsLabSensors
      //     .where((device) => device.startsWith(sensorPrefix))
      //     .toList();

      // // Sensor number is determined by the count of existing sensors + 1
      // sensorNumber = specificSensors.length + 1;

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Device Addition'),
            content: Text(
                'Do you want to add $sensorType $sensorNumber to your account?'),
            actions: <Widget>[
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  await _addDevice(scannedQRCode);
                  // Update the devices map to include the new sensor under "CPS Lab Sensors"
                  setState(() {
                    widget.devices.putIfAbsent('CPS Lab Sensors', () => []);
                    widget.devices['CPS Lab Sensors']?.add(scannedQRCode);
                  });
                  Navigator.pop(context);
                  await _showSuccessMessage();
                },
              ),
            ],
          );
        },
      );
    }
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
        title: Text('QR Scanner'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                    setState(() {
                      scannedQRCode = code;
                      message = "Detected QR Code";
                    });
                    _controller.stop();
                    _showConfirmationDialog(code);
                  } else {
                    setState(() {
                      message = "No valid QR Code detected";
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 20),
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
    );
  }
}
