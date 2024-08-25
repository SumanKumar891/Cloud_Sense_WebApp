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

class DeviceGraphPage extends StatelessWidget {
  final String deviceName;

  DeviceGraphPage({required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Graphs for $deviceName"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildGraphCard("Temperature", "Temperature graph goes here"),
            _buildGraphCard("Humidity", "Humidity graph goes here"),
            _buildGraphCard("Light Intensity", "Light Intensity graph goes here"),
            _buildGraphCard("Solar Irradiance", "Solar Irradiance graph goes here"),
            _buildGraphCard("Wind Speed", "Wind Speed graph goes here"),
            _buildGraphCard("Wind Direction", "Wind Direction graph goes here"),
            _buildGraphCard("Rain Detection", "Rain Detection graph goes here"),
            _buildGraphCard("Rain Speed", "Rain Speed graph goes here"),
            _buildGraphCard("Rain Time", "Rain Time graph goes here"),
            _buildGraphCard("Soil Sensor Node", "Soil Sensor Node graph goes here"),
            _buildGraphCard("Atmospheric Pressure", "Atmospheric Pressure graph goes here"),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphCard(String title, String graphDescription) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(graphDescription),
      ),
    );
  }
}