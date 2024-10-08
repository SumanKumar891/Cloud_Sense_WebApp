import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html; //import 'dart:html' as html;
import 'dart:io' as io;
// import 'dart:ui' as ui;

import 'package:intl/intl.dart';

class DeviceGraphPage extends StatefulWidget {
  final String deviceName;
  final sequentialName;

  DeviceGraphPage(
      {required this.deviceName,
      required this.sequentialName,
      required String backgroundImagePath});

  @override
  _DeviceGraphPageState createState() => _DeviceGraphPageState();
}

class _DeviceGraphPageState extends State<DeviceGraphPage> {
  DateTime _selectedDay = DateTime.now();
  List<ChartData> temperatureData = [];
  List<ChartData> humidityData = [];
  List<ChartData> lightIntensityData = [];
  List<ChartData> windSpeedData = [];
  List<ChartData> rainIntensityData = [];
  List<ChartData> solarIrradianceData = [];
  List<ChartData> windDirectionData = [];
  List<ChartData> chlorineData = [];
  List<ChartData> electrodeSignalData = [];
  List<ChartData> hypochlorousData = [];
  List<ChartData> temppData = [];
  List<ChartData> residualchlorineData = [];
  List<ChartData> tempData = [];
  List<ChartData> tdsData = [];
  List<ChartData> codData = [];
  List<ChartData> bodData = [];
  List<ChartData> pHData = [];
  List<ChartData> doData = [];
  List<ChartData> ecData = [];

  int _selectedDeviceId = 0; // Variable to hold the selected device ID
  bool _isHovering = false; // Track hover state
  String? _activeButton; // Add this variable
  String _currentChlorineValue = '0.00';
  bool _isLoading = false;

//   void _onRangeSelected(String range) {
//     setState(() {
//       _fetchDataForRange(range);
// // Fetch data based on the selected range
//     });
//   }

  @override
  void initState() {
    super.initState();
    _fetchDeviceDetails();
    // fetchData();
    _fetchDataForRange('single');
  }

// To toggle current data visibility

  Future<void> _fetchDeviceDetails() async {
    try {
      final response = await http.get(Uri.parse(
          'https://xa9ry8sls0.execute-api.us-east-1.amazonaws.com/CloudSense_device_activity_api_function'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final devices = data['chloritrone_data'] ?? data['weather_data'] ?? [];
        final selectedDevice = devices.firstWhere(
            (device) => device['DeviceId'] == _selectedDeviceId.toString(),
            orElse: () => null);

        if (selectedDevice != null) {
          setState(() {});
        } else {
          print('Device ${widget.deviceName} not found.');
        }
      } else {
        throw Exception('Failed to load device details');
      }
    } catch (e) {
      print('Error fetching device details: $e');
    }
  }

  List<List<dynamic>> _csvRows = [];
  String _lastWindDirection = "";

  Future<void> _fetchDataForRange(String range) async {
    setState(() {
      _isLoading = true; // Start loading
      _csvRows.clear();
      chlorineData.clear();
      temperatureData.clear();
      humidityData.clear();
      lightIntensityData.clear();
      windSpeedData.clear();
      rainIntensityData.clear();
      solarIrradianceData.clear();
      windDirectionData.clear();
      electrodeSignalData.clear();
      hypochlorousData.clear();
      temppData.clear();
      residualchlorineData.clear();
      tempData.clear();
      tdsData.clear();
      codData.clear();
      bodData.clear();
      pHData.clear();
      doData.clear();
      ecData.clear();
    });
    DateTime startDate;
    DateTime endDate = DateTime.now();

    switch (range) {
      case '7days':
        startDate = endDate.subtract(Duration(days: 7));
        break;
      case '30days':
        startDate = endDate.subtract(Duration(days: 30)); // 30 days range
        break;
      case '3months':
        startDate = endDate.subtract(Duration(days: 90)); // Roughly 3 months
        break;
      case 'single':
        startDate = _selectedDay; // Use the selected day as startDate
        endDate = startDate; // Single day means endDate is same as startDate
        break;
      default:
        startDate = endDate; // Default to today
    }

    final startdate = _formatDate(startDate);
    final enddate = _formatDate(endDate);
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    int deviceId =
        int.parse(widget.deviceName.replaceAll(RegExp(r'[^0-9]'), ''));

    setState(() {
      _selectedDeviceId = deviceId; // Set the selected device ID
    });

    String apiUrl;
    if (widget.deviceName.startsWith('WD')) {
      apiUrl =
          'https://62f4ihe2lf.execute-api.us-east-1.amazonaws.com/CloudSense_Weather_data_api_function?DeviceId=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('CL') ||
        (widget.deviceName.startsWith('BD'))) {
      apiUrl =
          'https://b0e4z6nczh.execute-api.us-east-1.amazonaws.com/CloudSense_Chloritrone_api_function?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('WQ')) {
      apiUrl =
          'https://oy7qhc1me7.execute-api.us-west-2.amazonaws.com/default/k_wqm_api?deviceid=${widget.deviceName}&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('WS')) {
      apiUrl =
          'https://xjbnnqcup4.execute-api.us-east-1.amazonaws.com/default/CloudSense_Water_quality_api_function?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else {
      setState(() {});
      setState(() {
        _isLoading = false; // Stop loading
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<List<dynamic>> rows = [];
        String lastWindDirection = 'Unknown';

        if (widget.deviceName.startsWith('CL') ||
            widget.deviceName.startsWith('BD')) {
          setState(() {
            chlorineData = _parseBDChartData(data, 'chlorine');
            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainIntensityData = [];
            solarIrradianceData = [];
            tempData = [];
            tdsData = [];
            codData = [];
            bodData = [];
            pHData = [];
            doData = [];
            ecData = [];

            // Update current chlorine value
            if (chlorineData.isNotEmpty) {
              _currentChlorineValue =
                  chlorineData.last.value.toStringAsFixed(2);
            }

            // Prepare data for CSV

            rows = [
              ["Timestamp", "Chlorine"],
              ...chlorineData.map(
                  (entry) => [formatter.format(entry.timestamp), entry.value])
            ];
          });
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('WQ')) {
          setState(() {
            tempData = _parseWaterChartData(data, 'temperature');
            tdsData = _parseWaterChartData(data, 'TDS');
            codData = _parseWaterChartData(data, 'COD');
            bodData = _parseWaterChartData(data, 'BOD');
            pHData = _parseWaterChartData(data, 'pH');
            doData = _parseWaterChartData(data, 'DO');
            ecData = _parseWaterChartData(data, 'EC');
            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainIntensityData = [];
            solarIrradianceData = [];
            chlorineData = [];

            rows = [
              [
                "Timestamp",
                "temperature",
                "TDS ",
                "COD",
                "BOD",
                "pH",
                "DO",
                "EC"
              ],
              for (int i = 0; i < tempData.length; i++)
                [
                  formatter.format(tempData[i].timestamp),
                  tempData[i].value,
                  tdsData[i].value,
                  codData[i].value,
                  bodData[i].value,
                  pHData[i].value,
                  doData[i].value,
                  ecData[i].value,
                ]
            ];
          });
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('WS')) {
          setState(() {
            temppData = _parsewaterChartData(data, 'Temperature');
            electrodeSignalData =
                _parsewaterChartData(data, 'Electrode_signal');
            residualchlorineData = _parsewaterChartData(data, 'Chlorine_value');
            hypochlorousData = _parsewaterChartData(data, 'Hypochlorous_value');

            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainIntensityData = [];
            solarIrradianceData = [];
            chlorineData = [];

            rows = [
              [
                "Timestamp",
                "Temperature",
                "Electrode Signal ",
                "Chlorine",
                "HypochlorouS",
              ],
              for (int i = 0; i < temppData.length; i++)
                [
                  formatter.format(temppData[i].timestamp),
                  temppData[i].value,
                  electrodeSignalData[i].value,
                  residualchlorineData[i].value,
                  hypochlorousData[i].value,
                ]
            ];
          });
          await _fetchDeviceDetails();
        } else {
          setState(() {
            temperatureData = _parseChartData(data, 'Temperature');
            humidityData = _parseChartData(data, 'Humidity');
            lightIntensityData = _parseChartData(data, 'LightIntensity');
            windSpeedData = _parseChartData(data, 'WindSpeed');
            rainIntensityData = _parseChartData(data, 'RainIntensity');
            solarIrradianceData = _parseChartData(data, 'SolarIrradiance');
            chlorineData = [];
            tempData = [];
            tdsData = [];
            codData = [];
            bodData = [];
            pHData = [];
            doData = [];
            ecData = [];

            // Extract the last wind direction from the data
            if (data['weather_items'].isNotEmpty) {
              lastWindDirection = data['weather_items'].last['WindDirection'];
            }

            // Prepare data for CSV
            rows = [
              [
                "Timestamp",
                "Temperature",
                "Humidity",
                "LightIntensity",
                "WindSpeed",
                "RainIntensity",
                "SolarIrradiance"
              ],
              for (int i = 0; i < temperatureData.length; i++)
                [
                  formatter.format(temperatureData[i].timestamp),
                  temperatureData[i].value,
                  humidityData[i].value,
                  lightIntensityData[i].value,
                  windSpeedData[i].value,
                  rainIntensityData[i].value,
                  solarIrradianceData[i].value,
                ]
            ];
          });
          // Fetch device details specifically for Weather data
          await _fetchDeviceDetails();
        }

        // Store CSV rows for download later
        setState(() {
          _csvRows = rows;
          _lastWindDirection =
              lastWindDirection; // Store the last wind direction

          if (_csvRows.isEmpty) {
          } else {
// Clear the message if data is available
          }
        });
      }
    } catch (e) {
      setState(() {});
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void downloadCSV(BuildContext context) async {
    if (_csvRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No data available for download.")),
      );
      return;
    }

    String csvData = const ListToCsvConverter().convert(_csvRows);
    String fileName = _generateFileName(); // Generate a dynamic filename

    if (kIsWeb) {
      final blob = html.Blob([csvData], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName) // Use the generated filename
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloading"),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      try {
        // Check storage permission status
        if (io.Platform.isAndroid) {
          if (await Permission.storage.isGranted) {
            // If already granted, continue with the download
            await saveCSVFile(
                csvData, fileName); // Pass filename to saveCSVFile
          } else {
            // For Android 11 and above, use MANAGE_EXTERNAL_STORAGE
            if (await Permission.manageExternalStorage.request().isGranted) {
              await saveCSVFile(
                  csvData, fileName); // Pass filename to saveCSVFile
            } else if (await Permission
                .manageExternalStorage.isPermanentlyDenied) {
              // If permanently denied, prompt to enable from settings
              await openAppSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text("Please enable storage permission from settings")),
              );
            }
          }
        } else {
          // Handle for other platforms (iOS)
          await saveCSVFile(csvData, fileName); // Pass filename to saveCSVFile
        }
      } catch (e) {
        // Catch errors during download
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading: $e")),
        );
      }
    }
  }

  String _generateFileName() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'SensorData_$timestamp.csv';
  }

  Future<void> saveCSVFile(String csvData, String fileName) async {
    final directory = await getExternalStorageDirectory();
    final downloadsDirectory = Directory('/storage/emulated/0/Download');

    if (downloadsDirectory.existsSync()) {
      final filePath = '${downloadsDirectory.path}/$fileName';
      final file = File(filePath);
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
  }

  List<ChartData> _parseBDChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(
            timestamp: DateTime.now(), value: 0.0); // Provide default value
      }
      return ChartData(
        timestamp: _parseBDDate(item['human_time']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parseChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['weather_items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(
            timestamp: DateTime.now(), value: 0.0); // Provide default value
      }
      return ChartData(
        timestamp: _parseDate(item['HumanTime']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parsewaterChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(
            timestamp: DateTime.now(), value: 0.0); // Provide default value
      }
      return ChartData(
        timestamp: _parsewaterDate(item['HumanTime']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parseWaterChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(
            timestamp: DateTime.now(), value: 0.0); // Provide default value
      }
      return ChartData(
        timestamp: _parseWaterDate(item['time_stamp']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

// Calculate average, min, and max values
  Map<String, List<double?>> _calculateStatistics(List<ChartData> data) {
    if (data.isEmpty) {
      return {
        'average': [null],
        'min': [null],
        'max': [null],
      };
    }
    double sum = 0.0;
    double min = double.infinity;
    double max = double.negativeInfinity;

    for (var entry in data) {
      sum += entry.value;
      if (entry.value < min) min = entry.value;
      if (entry.value > max) max = entry.value;
    }

    double avg = data.isNotEmpty ? sum / data.length : 0.0;
    return {
      'average': [avg],
      'min': [min],
      'max': [max],
    };
  }

  // Create a table displaying statistics
  Widget buildStatisticsTable() {
    final tempStats = _calculateStatistics(tempData);
    final tdsStats = _calculateStatistics(tdsData);
    final codStats = _calculateStatistics(codData);
    final bodStats = _calculateStatistics(bodData);
    final pHStats = _calculateStatistics(pHData);
    final doStats = _calculateStatistics(doData);
    final ecStats = _calculateStatistics(ecData);

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 800 ? 13 : 16;
    double headerFontSize = screenWidth < 800 ? 16 : 22;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withOpacity(0.6),
        ),
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(8),
        width: screenWidth < 800 ? double.infinity : 500,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth < 800 ? screenWidth - 32 : 500,
            ),
            child: DataTable(
              horizontalMargin: 16,
              columnSpacing: 16,
              columns: [
                DataColumn(
                  label: Text(
                    'Parameter',
                    style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Avg',
                    style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Min',
                    style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Max',
                    style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
              ],
              rows: [
                buildDataRow('Temp', tempStats, fontSize),
                buildDataRow('TDS', tdsStats, fontSize),
                buildDataRow('COD', codStats, fontSize),
                buildDataRow('BOD', bodStats, fontSize),
                buildDataRow('pH', pHStats, fontSize),
                buildDataRow('DO', doStats, fontSize),
                buildDataRow('EC', ecStats, fontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow buildDataRow(
      String parameter, Map<String, List<double?>> stats, double fontSize) {
    return DataRow(cells: [
      DataCell(Text(parameter,
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          stats['average']?[0] != null
              ? stats['average']![0]!.toStringAsFixed(2)
              : '-',
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          stats['min']?[0] != null ? stats['min']![0]!.toStringAsFixed(2) : '-',
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          stats['max']?[0] != null ? stats['max']![0]!.toStringAsFixed(2) : '-',
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
    ]);
  }

  DateTime _parseBDDate(String dateString) {
    final dateFormat = DateFormat(
        'yyyy-MM-dd hh:mm a'); // Ensure this matches your date format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  DateTime _parseDate(String dateString) {
    final dateFormat = DateFormat(
        'yyyy-MM-dd HH:mm:ss'); // Ensure this matches your date format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  DateTime _parseWaterDate(String dateString) {
    final dateFormat = DateFormat(
        'yyyy-MM-dd HH:mm:ss'); // Ensure this matches your date format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  DateTime _parsewaterDate(String dateString) {
    final dateFormat = DateFormat(
        'yyyy-MM-dd HH:mm:ss'); // Ensure this matches your date format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _getDeviceStatus(String lastReceivedTime) {
    if (lastReceivedTime == 'Unknown') return 'Unknown';
    try {
      // Adjust this format to match the actual format of lastReceivedTime
      final dateFormat = DateFormat(
          'yyyy-MM-dd hh:mm a'); // Change to 'HH:mm' for 24-hour format

      final lastReceivedDate = dateFormat.parse(lastReceivedTime);
      final currentTime = DateTime.now();
      final difference = currentTime.difference(lastReceivedDate);

      if (difference.inMinutes <= 62) {
        return 'Active';
      } else {
        return 'Inactive';
      }
    } catch (e) {
      print('Error parsing date: $e');
      return 'Inactive'; // Fallback status in case of error
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(1970),
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      setState(() {
        _selectedDay = picked;

        _fetchDataForRange('single'); // Fetch data for the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the background image based on the device type
    String backgroundImagePath;

    // Check the device name and assign the appropriate image
    if (widget.deviceName.startsWith('WD')) {
      backgroundImagePath = 'assets/tree.jpg';
    } else if (widget.deviceName.startsWith('CL')) {
      backgroundImagePath = 'assets/Chloritronn.png';
    } else {
      // For water quality sensor
      backgroundImagePath = 'assets/water_quality.jpg';
    }
    String _selectedRange = 'ee';
    // : 'assets/soil.jpg';

    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 202, 213, 223), // Blue background color for the entire page
      body: Stack(
        children: [
          // Background image with blur effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImagePath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black
                        .withOpacity(0.3), // Add a semi-transparent overlay
                    BlendMode.darken,
                  ),
                ),
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.width < 800 ? 400 : 500,
            ),
          ),
          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "${widget.sequentialName}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width < 800 ? 20 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          // Main content
          Positioned(
            top: AppBar()
                .preferredSize
                .height, // Position content below the AppBar
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: 16), // Adjust padding as needed
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              // Display Device ID, Status, and Received time
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text(
                              //       'Status: $_currentStatus',
                              //       style: TextStyle(
                              //         fontWeight: FontWeight.bold,
                              //         fontSize:
                              //             MediaQuery.of(context).size.width *
                              //                 0.011,
                              //         color: Colors.white,
                              //       ),
                              //     ),
                              //   ],
                              // ),

                              SizedBox(height: 20),

                              // Space between status and buttons
                              SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: MediaQuery.of(context).size.width < 800
                                    ? Container(
                                        width: 200,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: const Color.fromARGB(
                                              150, 0, 0, 0),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                hint: Text(
                                                    'Select a time period'),
                                                dropdownColor: Colors.black
                                                    .withOpacity(0.5),
                                                value: _selectedRange,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedRange = value!;
                                                    if (value == 'date') {
                                                      _selectDate(); // Your date picker function
                                                    } else if (value ==
                                                        '7days') {
                                                      _fetchDataForRange(
                                                          '7days'); // Fetch data for 7 days
                                                    } else if (value ==
                                                        '30days') {
                                                      _fetchDataForRange(
                                                          '30days'); // Fetch data for 30 days
                                                    } else if (value ==
                                                        '3months') {
                                                      _fetchDataForRange(
                                                          '3months'); // Fetch data for 3 months
                                                    }
                                                  });
                                                },
                                                items: [
                                                  DropdownMenuItem(
                                                    child: Text(
                                                      'Select Time Period',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white),
                                                    ),
                                                    value: 'ee',
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text(
                                                      'Select One Day',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white),
                                                    ),
                                                    value: 'date',
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text(
                                                      'Last 7 Days',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white),
                                                    ),
                                                    value: '7days',
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text(
                                                      'Last 30 Days',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white),
                                                    ),
                                                    value: '30days',
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text(
                                                      'Last 3 months',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white),
                                                    ),
                                                    value: '3months',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            color: const Color.fromARGB(
                                                150, 0, 0, 0),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Date Picker button
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    _selectDate(); // Your date picker function
                                                    setState(() {
                                                      // _selectedRange =
                                                      //     'date'; // Mark this button as selected
                                                      _activeButton =
                                                          'date'; // Set the active button
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 36,
                                                            vertical: 28),
                                                    side: _activeButton ==
                                                            'date'
                                                        ? BorderSide(
                                                            color: Colors.white,
                                                            width: 2)
                                                        : BorderSide.none,
                                                  ),
                                                  child: Text(
                                                    'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: _activeButton ==
                                                              'date'
                                                          ? Colors.blue
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              // 7 Days button
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    _fetchDataForRange(
                                                        '7days'); // Fetch data for 7 days range
                                                    setState(() {
                                                      _activeButton = '7days';
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 36,
                                                            vertical: 28),
                                                    side: _activeButton ==
                                                            '7days'
                                                        ? BorderSide(
                                                            color: Colors.white,
                                                            width: 2)
                                                        : BorderSide.none,
                                                  ),
                                                  child: Text(
                                                    'Last 7 Days',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: _activeButton ==
                                                              '7days'
                                                          ? Colors.blue
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              // 30 Days button
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    _fetchDataForRange(
                                                        '30days'); // Fetch data for 30 days range
                                                    setState(() {
                                                      _activeButton = '30days';
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 36,
                                                            vertical: 28),
                                                    side: _activeButton ==
                                                            '30days'
                                                        ? BorderSide(
                                                            color: Colors.white,
                                                            width: 2)
                                                        : BorderSide.none,
                                                  ),
                                                  child: Text(
                                                    'Last 30 Days',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: _activeButton ==
                                                              '30days'
                                                          ? Colors.blue
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              // 3 Months button
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    _fetchDataForRange(
                                                        '3months'); // Fetch data for 3 months range
                                                    setState(() {
                                                      _activeButton = '3months';
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 36,
                                                            vertical: 28),
                                                    side: _activeButton ==
                                                            '3months'
                                                        ? BorderSide(
                                                            color: Colors.white,
                                                            width: 2)
                                                        : BorderSide.none,
                                                  ),
                                                  child: Text(
                                                    'Last 3 months',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: _activeButton ==
                                                              '3months'
                                                          ? Colors.blue
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                              SizedBox(
                                  height:
                                      20), // Space between buttons and the next section
                              // Wind Direction widget in the center
                              if (widget.deviceName.startsWith('WD'))
                                Column(
                                  children: [
                                    Icon(
                                      Icons.wind_power,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Wind Direction: $_lastWindDirection',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Check if the device is a chlorine sensor device
                          if (widget.deviceName.startsWith('CL'))
                            _buildCurrentValue('Chlorine Level',
                                _currentChlorineValue, 'mg/L'),
                        ],
                      ),
                    ),

                    if (widget.deviceName.startsWith('WQ'))
                      buildStatisticsTable(),

                    // Display charts for various parameters
                    _buildChartContainer('Chlorine', chlorineData,
                        'Chlorine (mg/L)', ChartType.line),
                    _buildChartContainer('Temperature', temperatureData,
                        'Temperature (°C)', ChartType.line),
                    _buildChartContainer('Humidity', humidityData,
                        'Humidity (%)', ChartType.line),
                    _buildChartContainer('Light Intensity', lightIntensityData,
                        'Light Intensity (Lux)', ChartType.line),
                    _buildChartContainer('Wind Speed', windSpeedData,
                        'Wind Speed (m/s)', ChartType.line),
                    _buildChartContainer('Rain Intensity', rainIntensityData,
                        'Rain Intensity (mm/h)', ChartType.line),
                    _buildChartContainer(
                        'Solar Irradiance',
                        solarIrradianceData,
                        'Solar Irradiance (W/M^2)',
                        ChartType.line),
                    _buildChartContainer(' Temperature ', tempData,
                        'Temperature (°C)', ChartType.line),
                    _buildChartContainer(
                        ' TDS ', tdsData, 'TDS (ppm)', ChartType.line),
                    _buildChartContainer(
                        'COD ', bodData, 'COD (mg/L)', ChartType.line),
                    _buildChartContainer(
                        ' BOD ', codData, 'BOD (mg/L)', ChartType.line),
                    _buildChartContainer('pH ', pHData, 'pH()', ChartType.line),
                    _buildChartContainer(
                        ' DO ', doData, 'DO (mg/L)', ChartType.line),
                    _buildChartContainer(
                        ' EC ', ecData, 'EC (mS/cm)', ChartType.line),
                    _buildChartContainer(' Temperature ', temppData,
                        'Temperature (°C)', ChartType.line),
                    _buildChartContainer(
                        ' Electrode Signal ',
                        electrodeSignalData,
                        ' Electrode Signal ()',
                        ChartType.line),
                    _buildChartContainer(' Chlorine ', residualchlorineData,
                        'Chlorine  (mg/L)', ChartType.line),
                    _buildChartContainer(' Hypochlorous ', hypochlorousData,
                        ' Hypochlorous  (mg/L)', ChartType.line),
                  ],
                ),
              ),
            ),
          ),

          // Loader overlay
          if (_isLoading) // Show loader only when _isLoading is true
            Positioned.fill(
              child: Container(
                color: Colors.black
                    .withOpacity(0.5), // Dark semi-transparent background
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 16,
            right: 16,
            child: MouseRegion(
              onEnter: (_) =>
                  setState(() => _isHovering = true), // Change hover state
              onExit: (_) => setState(() => _isHovering = false),
              child: ElevatedButton(
                onPressed: () {
                  downloadCSV(context);
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(
                        255, 40, 41, 41) // Button background color
                    ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download,
                      color: _isHovering ? Colors.blue : Colors.white,
                    ), // Download icon
                    SizedBox(width: 8),
                    Text(
                      'Download CSV',
                      style: TextStyle(
                        color: _isHovering
                            ? Colors.blue
                            : Colors.white, // Change color on hover
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentValue(
      String parameterName, String currentValue, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the top
        children: [
          // Display both parameter and value together in a single text widget
          Text(
            '$parameterName: $currentValue $unit',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(
    String title,
    List<ChartData> data,
    String yAxisTitle,
    ChartType chartType,
  ) {
    return data.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width < 800 ? 400 : 500,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: const Color.fromARGB(150, 0, 0, 0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text(
                      '$title Graph', // Displaying the chart's title
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width < 800 ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  if (widget.deviceName.startsWith('CL'))
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Builder(
                        builder: (BuildContext context) {
                          final screenWidth = MediaQuery.of(context).size.width;

                          // Define common properties
                          double boxSize;
                          double textSize;
                          double spacing;

                          if (screenWidth < 800) {
                            // For smaller screens (e.g., mobile devices)
                            boxSize = 15.0;
                            textSize = 15.0;
                            spacing = 12.0;

                            // Row layout for small screens
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildColorBox(Colors.white, '< 0.01 ',
                                      boxSize, textSize),
                                  SizedBox(width: spacing),
                                  _buildColorBox(Colors.green, '> 0.01 - 0.5',
                                      boxSize, textSize),
                                  SizedBox(width: spacing),
                                  _buildColorBox(Colors.yellow, '> 0.5 - 1.0',
                                      boxSize, textSize),
                                  SizedBox(width: spacing),
                                  _buildColorBox(Colors.orange, '> 1.0 - 4.0',
                                      boxSize, textSize),
                                  SizedBox(width: spacing),
                                  _buildColorBox(Colors.red, ' Above 4.0',
                                      boxSize, textSize),
                                ],
                              ),
                            );
                          } else {
                            // For larger screens (e.g., PCs and laptops)
                            boxSize = 20.0;
                            textSize = 16.0;
                            spacing = 45.0;

                            // Row layout for larger screens
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildColorBox(Colors.white, '< 0.01 ',
                                      boxSize, textSize),
                                  SizedBox(width: spacing),
                                  _buildColorBox(Colors.green, '> 0.01 - 0.5',
                                      boxSize, textSize),
                                  SizedBox(width: spacing),
                                  _buildColorBox(Colors.yellow, '> 0.5 - 1.0',
                                      boxSize, textSize),
                                  SizedBox(width: spacing),
                                  _buildColorBox(Colors.orange, '> 1.0 - 4.0',
                                      boxSize, textSize),
                                  SizedBox(width: spacing),
                                  _buildColorBox(Colors.red, ' Above 4.0',
                                      boxSize, textSize),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  Expanded(
                    child: SfCartesianChart(
                      plotAreaBackgroundColor:
                          const Color.fromARGB(100, 0, 0, 0),
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat('MM/dd hh:mm a'),
                        title: AxisTitle(
                          text: 'Time',
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        labelStyle: TextStyle(color: Colors.white),
                        labelRotation: 70,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        intervalType: DateTimeIntervalType
                            .minutes, // Adjust based on your data frequency

                        majorGridLines: MajorGridLines(width: 1.0),
                        // interval: 10,
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: TextStyle(color: Colors.white),
                        title: AxisTitle(
                          text: yAxisTitle,
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w200, color: Colors.white),
                        ),
                        axisLine: AxisLine(width: 1),
                        majorGridLines: MajorGridLines(width: 0),
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        builder: (dynamic data, dynamic point, dynamic series,
                            int pointIndex, int seriesIndex) {
                          final ChartData chartData = data as ChartData;
                          return Container(
                            padding: EdgeInsets.all(8),
                            color: const Color.fromARGB(127, 0, 0, 0),
                            constraints: BoxConstraints(
                              maxWidth: 200, // Adjust the max width as needed
                              maxHeight: 60, // Adjust the max height as needed
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${chartData.timestamp}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Value: ${chartData.value}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      zoomPanBehavior: ZoomPanBehavior(
                        zoomMode: ZoomMode.x,
                        enablePanning: true,
                        enablePinching: true,
                        enableMouseWheelZooming: true,
                      ),
                      series: <ChartSeries<ChartData, DateTime>>[
                        _getChartSeries(chartType, data, title),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(); // Return empty container if no data
  }

  Widget _buildColorBox(
      Color color, String range, double boxSize, double textSize) {
    return Row(
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          color: color,
        ),
        SizedBox(width: 8), // Fixed width between box and text
        Text(
          range,
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
          ),
        ),
      ],
    );
  }

  ChartSeries<ChartData, DateTime> _getChartSeries(
      ChartType chartType, List<ChartData> data, String title) {
    switch (chartType) {
      case ChartType.line:
        if (widget.deviceName.startsWith('CL')) {
          // Chlorine sensor
          return LineSeries<ChartData, DateTime>(
            markerSettings: const MarkerSettings(
              height: 6.0,
              width: 6.0,
              isVisible: true,
            ),
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.timestamp,
            yValueMapper: (ChartData data, _) => data.value,
            name: title,
            color: Colors.blue,
            pointColorMapper: (ChartData data, _) {
              // Color range for chlorine sensor
              if (data.value >= 0.01 && data.value <= 0.5) {
                return Colors.green;
              } else if (data.value > 0.5 && data.value <= 1.0) {
                return Colors.yellow;
              } else if (data.value > 1.0 && data.value <= 4.0) {
                return Colors.orange;
              } else if (data.value > 4.0) {
                return Colors.red;
              }
              return Colors.white; // Default color
            },
          );
        } else {
          // Other devices
          return LineSeries<ChartData, DateTime>(
            markerSettings: const MarkerSettings(
              height: 6.0,
              width: 6.0,
              isVisible: true,
            ),
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.timestamp,
            yValueMapper: (ChartData data, _) => data.value,
            name: title,
            color: Colors.blue, // Single color for non-chlorine sensors
          );
        }

      default:
        return LineSeries<ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: title,
          color: Colors.blue,
        );
    }
  }
}

enum ChartType {
  line,
}

class ChartData {
  final DateTime timestamp;
  final double value;

  ChartData({required this.timestamp, required this.value});
}
