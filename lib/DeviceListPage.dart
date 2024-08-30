
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
      case 'BD':
        return 'Biodiversity Sensors';
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
