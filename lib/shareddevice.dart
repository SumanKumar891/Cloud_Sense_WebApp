import 'package:flutter/material.dart';

class DeviceUtils {
  static String getSensorType(String deviceId) {
    if (deviceId.startsWith('WD')) return 'Weather Sensor';
    if (deviceId.startsWith('CL') || deviceId.startsWith('BD'))
      return 'Chlorine Sensor';
    if (deviceId.startsWith('SS')) return 'Soil Sensor';
    if (deviceId.startsWith('WQ')) return 'Water Quality Sensor';
    if (deviceId.startsWith('WS')) return 'Water Sensor';
    if (deviceId.startsWith('DO')) return 'DO Sensor';
    if (deviceId.startsWith('LU')) return 'LU Sensor';
    if (deviceId.startsWith('TE')) return 'TE Sensor';
    if (deviceId.startsWith('AC')) return 'AC Sensor';
    if (deviceId.startsWith('BF')) return 'BF Sensor';
    if (deviceId.startsWith('CS')) return 'Cow Sensor';
    if (deviceId.startsWith('TH')) return 'Temperature Sensor';
    return 'Unknown Sensor';
  }

  static String getSensorPrefix(String deviceId) {
    if (deviceId.length < 2) return '';
    String prefix = deviceId.substring(0, 2);
    // List of valid sensor prefixes
    List<String> validPrefixes = [
      'WD',
      'CL',
      'BD',
      'SS',
      'WQ',
      'WS',
      'DO',
      'LU',
      'TE',
      'AC',
      'BF',
      'CS',
      'TH'
    ];
    // Return 'UN' for unknown sensors
    return validPrefixes.contains(prefix) ? prefix : 'UN';
  }

  static Future<void> showConfirmationDialog({
    required BuildContext context,
    required String deviceId,
    required Map<String, List<String>> devices,
    required Function onConfirm,
  }) async {
    String sensorType = getSensorType(deviceId);
    String sensorPrefix = getSensorPrefix(deviceId);

    // Calculate sensor number
    final categoryDevices = devices.values
        .expand((deviceList) => deviceList)
        .where((device) =>
            // For known sensors, match prefix
            // For unknown sensors, exclude all known prefixes
            sensorPrefix == 'UN'
                ? !validPrefixes.any((prefix) => device.startsWith(prefix))
                : device.startsWith(sensorPrefix))
        .toList();
    int sensorNumber = categoryDevices.length + 1;

    // Check if device exists
    bool deviceExists =
        devices.values.any((deviceList) => deviceList.contains(deviceId));

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
                },
              ),
            ],
          );
        },
      );
    } else {
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
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
              ),
            ],
          );
        },
      );
    }
  }

  // List of valid sensor prefixes
  static final List<String> validPrefixes = [
    'WD',
    'CL',
    'BD',
    'SS',
    'WQ',
    'WS',
    'DO',
    'LU',
    'TE',
    'AC',
    'BF',
    'CS',
    'TH'
  ];
}
