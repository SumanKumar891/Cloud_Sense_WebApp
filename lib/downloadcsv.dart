import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // For converting data to CSV format
import 'dart:io' as io;
import 'package:intl/intl.dart'; // Import intl for formatting dates
import 'package:universal_html/html.dart' as html; //import 'dart:html' as html;

class CsvDownloader extends StatefulWidget {
  final String deviceName;

  CsvDownloader({
    required this.deviceName,
  });

  @override
  _CsvDownloaderState createState() => _CsvDownloaderState();
}

class _CsvDownloaderState extends State<CsvDownloader> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<List<dynamic>> _csvRows = [];
  @override
  void initState() {
    super.initState();
    // Automatically show the date range dialog when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCustomDateRangeDialog(context);
    });
  }

  Future<void> _downloadCsv() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    // Clear previous CSV rows
    _csvRows.clear();
    String startDate =
        "${_startDate!.day.toString().padLeft(2, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.year}";
    String endDate =
        "${_endDate!.day.toString().padLeft(2, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.year}";
    int deviceId =
        int.parse(widget.deviceName.replaceAll(RegExp(r'[^0-9]'), ''));

    String apiUrl;

    if (widget.deviceName.startsWith('WD')) {
      apiUrl =
          'https://62f4ihe2lf.execute-api.us-east-1.amazonaws.com/CloudSense_Weather_data_api_function?DeviceId=$deviceId&startdate=$startDate&enddate=$endDate';
    } else if (widget.deviceName.startsWith('CL') ||
        widget.deviceName.startsWith('BD')) {
      apiUrl =
          'https://b0e4z6nczh.execute-api.us-east-1.amazonaws.com/CloudSense_Chloritrone_api_function?deviceid=$deviceId&startdate=$startDate&enddate=$endDate';
    } else if (widget.deviceName.startsWith('WQ')) {
      apiUrl =
          'https://63jeajtwf8.execute-api.us-west-2.amazonaws.com/default/wqm_csv_dwnld_api?deviceId=${widget.deviceName}&startdate=$startDate&enddate=$endDate';
    } else if (widget.deviceName.startsWith('IT')) {
      apiUrl =
          'https://7a3bcew3y2.execute-api.us-east-1.amazonaws.com/default/IIT_Bombay_API_func?deviceid=$deviceId&startdate=$startDate&enddate=$endDate';
    } else if (widget.deviceName.startsWith('WS')) {
      apiUrl =
          'https://xjbnnqcup4.execute-api.us-east-1.amazonaws.com/default/CloudSense_Water_quality_api_function?deviceid=$deviceId&startdate=$startDate&enddate=$endDate';
    } else if (widget.deviceName.startsWith('FS')) {
      apiUrl =
          'https://w7w21t8s23.execute-api.us-east-1.amazonaws.com/default/SSMet_Forest_API_func?deviceid=$deviceId&startdate=$startDate&enddate=$endDate';
    } else if (widget.deviceName.startsWith('DO')) {
      apiUrl =
          'https://br2s08as9f.execute-api.us-east-1.amazonaws.com/default/CloudSense_Water_quality_api_2_function?deviceId=$deviceId&startdate=$startDate&enddate=$endDate';
    } else if (widget.deviceName.startsWith('TH')) {
      apiUrl =
          'https://5s3pangtz0.execute-api.us-east-1.amazonaws.com/default/CloudSense_TH_Data_Api_function?deviceid=$deviceId&startdate=$startDate&enddate=$endDate';
    } else if (widget.deviceName.startsWith('NH')) {
      apiUrl =
          'https://qgbwurafri.execute-api.us-east-1.amazonaws.com/default/CloudSense_NH_Data_Api_function?deviceid=$deviceId&startdate=$startDate&enddate=$endDate';
    } else if (widget.deviceName.startsWith('LU') ||
        widget.deviceName.startsWith('TE') ||
        widget.deviceName.startsWith('AC')) {
      apiUrl =
          'https://2bftil5o0c.execute-api.us-east-1.amazonaws.com/default/CloudSense_sensor_api_function?DeviceId=$deviceId&startdate=$startDate&enddate=$endDate';
    } else {
      setState(() {});
      return;
    }

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<List<dynamic>> rows = [];

      // Prepare data for CSV based on device type
      if (widget.deviceName.startsWith('CL') ||
          widget.deviceName.startsWith('BD')) {
        _csvRows.add(['Timestamp', 'Chlorine']); // Add headers
        data['items'].forEach((item) {
          _csvRows.add([item['human_time'], item['chlorine']]);
        });
      } else if (widget.deviceName.startsWith('WQ')) {
        _csvRows.add([
          'Timestamp',
          'Temperature',
          'TDS',
          'COD',
          'BOD',
          'pH',
          'DO',
          'EC'
        ]);
        data.forEach((item) {
          _csvRows.add([
            item['time_stamp'],
            item['temperature'],
            item['TDS'],
            item['COD'],
            item['BOD'],
            item['pH'],
            item['DO'],
            item['EC'],
          ]);
        });
      } else if (widget.deviceName.startsWith('IT')) {
        _csvRows.add([
          "Timestamp",
          "Temperature",
          "Pressure ",
          "Humidity",
          "Radiation",
          "Visibility",
          "Wind Direction",
          "Wind Speed"
        ]);
        data['items'].forEach((item) {
          _csvRows.add([
            item['timestamp'],
            item['temperature'],
            item['pressure'],
            item['humidity'],
            item['radiation'],
            item['visibility'],
            item['wind_direction'],
            item['wind_speed'],
          ]);
        });
      } else if (widget.deviceName.startsWith('FS')) {
        _csvRows.add([
          "Timestamp",
          "Temperature",
          "Humidity ",
          "RFD",
          "RFS",
        ]);
        data['items'].forEach((item) {
          _csvRows.add([
            item['timestamp'],
            item['temperature'],
            item['humidity'],
            item['RFD'],
            item['RFS'],
          ]);
        });
      } else if (widget.deviceName.startsWith('WS')) {
        _csvRows.add([
          'Timestamp',
          'Temperature',
          'Electrode_signal',
          'Chlorine_value',
          'Hypochlorous_value'
        ]);
        data['items'].forEach((item) {
          _csvRows.add([
            item['HumanTime'],
            item['temperature'],
            item['Electrode_signal'],
            item['Chlorine_value'],
            item['Hypochlorous_value'],
          ]);
        });
      } else if (widget.deviceName.startsWith('DO')) {
        _csvRows.add([
          "Timestamp",
          "Temperature",
          "DO Value ",
          "DO Percentage",
        ]);
        data['items'].forEach((item) {
          _csvRows.add([
            item['HumanTime'],
            item['Temperature'],
            item['DO Value'],
            item['DO Percentage'],
          ]);
        });
      } else if (widget.deviceName.startsWith('TH')) {
        _csvRows.add(["Timestamp", "Temperature", "Humidity"]);

        // Assuming 'data' is a list of JSON objects
        data['items'].forEach((item) {
          _csvRows.add([
            item['HumanTime'], // Correct key reference
            item['Temperature'], // Correct key reference
            item['Humidity'], // Correct key reference
          ]);
        });
      } else if (widget.deviceName.startsWith('NH')) {
        _csvRows.add(
            ['Timestamp', 'Ammonia', "Temperature", "Humidity"]); // Add headers
        data['items'].forEach((item) {
          _csvRows.add([
            item['HumanTime'], item['AmmoniaPPM'],
            item['Temperature'], // Correct key reference
            item['Humidity'],
          ]);
        });
      } else if (widget.deviceName.startsWith('LU')) {
        _csvRows.add([
          "Timestamp",
          "Lux",
        ]);
        data['sensor_data_items'].forEach((item) {
          _csvRows.add([
            item['HumanTime'],
            item['Lux'],
          ]);
        });
      } else if (widget.deviceName.startsWith('TE')) {
        _csvRows.add(["Timestamp", "Temperature", "Humidity"]);
        data['sensor_data_items'].forEach((item) {
          _csvRows.add([
            item['HumanTime'],
            item['Temperature'],
            item['Humidity'],
          ]);
        });
      } else {
        _csvRows.add([
          "Timestamp",
          "Temperature",
          "Humidity",
          "LightIntensity",
          "SolarIrradiance",
        ]);
        data['weather_items'].forEach((item) {
          _csvRows.add([
            item['HumanTime'],
            item['Temperature'],
            item['Humidity'],
            item['LightIntensity'],
            item['SolarIrradiance'],
          ]);
        });
      }

      await _generateCsvFile(); // Generate CSV after preparing data
    }
  }

  String _generateFileName() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'SensorData_$timestamp.csv';
  }

  Future<void> _generateCsvFile() async {
    String csvData = const ListToCsvConverter().convert(_csvRows);
    String fileName = _generateFileName(); // Generate unique filename

    if (kIsWeb) {
      final blob = html.Blob([csvData], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName) // Use the generated file name
        ..click();
      html.Url.revokeObjectUrl(url); // Clean up the URL object

      // Show Snackbar and pop the page after a delay
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloading $fileName"),
          duration: Duration(seconds: 1),
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    } else {
      try {
        // Use Storage Access Framework for non-web platforms
        await saveCSVFile(csvData, fileName);
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File downloaded: $fileName")),
        );

        // Navigate back to the previous screen after a short delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading: $e")),
        );
      }
    }
  }

  Future<void> saveCSVFile(String csvData, String fileName) async {
    try {
      // Get the Downloads directory.
      final downloadsDirectory = Directory('/storage/emulated/0/Download');
      if (downloadsDirectory.existsSync()) {
        final filePath = '${downloadsDirectory.path}/$fileName';
        final file = File(filePath);

        // Ensure the directory is writable and save the file.
        await file.writeAsString(csvData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File downloaded to $filePath"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to find Downloads directory")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving file: $e")),
      );
    }
  }

// Method to show the custom date range dialog
  Future<void> _showCustomDateRangeDialog(BuildContext context) async {
    DateTime? startDate;
    DateTime? endDate;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Date Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start Date Picker
                  ListTile(
                    title: Text(
                      'Start Date: ${startDate != null ? startDate!.toLocal().toString().split(' ')[0] : 'Select a start date'}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedStartDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (pickedStartDate != null) {
                        setState(() {
                          startDate = pickedStartDate;
                        });
                      }
                    },
                  ),
                  // End Date Picker
                  ListTile(
                    title: Text(
                      'End Date: ${endDate != null ? endDate!.toLocal().toString().split(' ')[0] : 'Select an end date'}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedEndDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (pickedEndDate != null) {
                        setState(() {
                          endDate = pickedEndDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                // Show Download button only when both dates are selected
                if (startDate != null && endDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = startDate;
                        _endDate = endDate;
                      });
                      Navigator.of(context).pop();
                      _downloadCsv();
                    },
                    child: const Text('Download'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 217, 231, 238),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
