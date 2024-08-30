import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with WidgetsBindingObserver {
  String? scannedQRCode;
  String message = "Position the QR code inside the scanner";
  late MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController();
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
      _controller.start();
    } else if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  void resetScanner() {
    setState(() {
      scannedQRCode = null;
      message = "Position the QR code inside the scanner";
      _controller.stop();
      Future.delayed(Duration(milliseconds: 500), () {
        _controller.start();
      });
    });
  }

  Future<bool> _onWillPop() async {
    _controller.stop();
    return true;
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
                    if (code != null) {
                      setState(() {
                        scannedQRCode = code;
                        message = "Detected QR Code: $scannedQRCode";
                      });
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
