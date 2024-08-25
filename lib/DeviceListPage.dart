import 'package:flutter/material.dart';
import 'DeviceGraphPage.dart';

class DeviceListPage extends StatelessWidget {
  final List<String> devices = ["Device1", "Device2", "Device3"];

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
                  _navigateToDeviceGraphPage(context, device);
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

  void _navigateToDeviceGraphPage(BuildContext context, String deviceName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeviceGraphPage(deviceName: deviceName),
      ),
    );
  }
}