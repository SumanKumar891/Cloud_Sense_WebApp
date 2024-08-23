import 'package:flutter/material.dart';

class DeviceListPage extends StatelessWidget {
  final List<String> devices = ["Device 1", "Device 2", "Device 3"];

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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Devices"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: devices.map((device) {
              return ListTile(
                title: Text(device),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeviceDetails(context, device);
                },
              );
            }).toList(),
          ),
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

  void _showDeviceDetails(BuildContext context, String deviceName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Device Details"),
          content: Text("Details for $deviceName"),
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
