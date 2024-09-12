import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'dart:html' as html;

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
  String _currentStatus = 'Unknown';
  String _dataReceivedTime = 'Unknown';
  List<ChartData> temperatureData = [];
  List<ChartData> humidityData = [];
  List<ChartData> lightIntensityData = [];
  List<ChartData> windSpeedData = [];
  List<ChartData> rainIntensityData = [];
  List<ChartData> solarIrradianceData = [];
  List<ChartData> windDirectionData = [];
  List<ChartData> chlorineData = [];
  int _selectedDeviceId = 0; // Variable to hold the selected device ID

  ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
    enablePinching: true,
    enablePanning: true,
    zoomMode: ZoomMode.x, // Enable zooming on the X-axis
  );
// Add the zoom control buttons
  Widget _buildZoomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.zoom_in),
          onPressed: () {
            _zoomPanBehavior.zoomIn();
          },
        ),
        IconButton(
          icon: Icon(Icons.zoom_out),
          onPressed: () {
            _zoomPanBehavior.zoomOut();
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            _zoomPanBehavior.reset(); // Reset zoom and pan
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchDeviceDetails();
    fetchData();
  }

  Future<void> _fetchDeviceDetails() async {
    try {
      final response = await http.get(Uri.parse(
          // 'https://c27wvohcuc.execute-api.us-east-1.amazonaws.com/default/beehive_activity_api'
          'https://xa9ry8sls0.execute-api.us-east-1.amazonaws.com/CloudSense_device_activity_api_function'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // final selectedDevice = data.firstWhere(
        //     (device) => device['DeviceId'] == 101,
        // //     orElse: () => null);
        // final chloritroneData = data['chloritrone_data'] ?? [];
        // print('Chloritrone Data: ${chloritroneData}'); // Print chloritrone data

        // final selectedDevice = chloritroneData.firstWhere(
        //     (device) => device['DeviceId'] == '101', // Ensure string comparison
        //     orElse: () => null);

        final devices = data['chloritrone_data'] ?? [];
        final selectedDevice = devices.firstWhere(
            (device) => device['DeviceId'] == _selectedDeviceId.toString(),
            orElse: () => null);

        if (selectedDevice != null) {
          setState(() {
            _currentStatus =
                _getDeviceStatus(selectedDevice['lastReceivedTime']);
            _dataReceivedTime = selectedDevice['lastReceivedTime'] ?? 'Unknown';
          });
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
  String _message = "";
  String _lastWindDirection = "";

  Future<void> fetchData() async {
    final startdate = _formatDate(_selectedDay);
    final enddate = startdate;
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
    } else {
      setState(() {
        _message = "Unknown device type";
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

            // Prepare data for CSV

            rows = [
              ["Timestamp", "Chlorine"],
              ...chlorineData.map(
                  (entry) => [formatter.format(entry.timestamp), entry.value])
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

            // Extract the last wind direction from the data
            if (data['items'].isNotEmpty) {
              lastWindDirection = data['items'].last['WindDirection'];
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
            _message = "No data available for download.";
          } else {
            _message = ""; // Clear the message if data is available
          }
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error fetching data: $e';
      });
    }
  }

  // Function to download CSV
  void downloadCSV() {
    if (_csvRows.isEmpty) {
      setState(() {
        _message = "No data available for download.";
      });
      return;
    }

    // Convert rows to CSV
    String csvData = const ListToCsvConverter().convert(_csvRows);

    // Trigger download in web
    final blob = html.Blob([csvData], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "SensorData.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
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
    final List<dynamic> items = data['items'] ?? [];
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
        'yyyy-MM-dd hh:mm:ss'); // Ensure this matches your date format
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

    //   try {
    //     final dateTimeParts = lastReceivedTime.split(' ');
    //     final datePart = dateTimeParts[0].split('-');
    //     final timePart = dateTimeParts[1].split(':');

    //     final day = int.parse(datePart[2]);
    //     final month = int.parse(datePart[1]);
    //     final year = int.parse(datePart[0]);

    //     final hour = int.parse(timePart[0]);
    //     final minute = int.parse(timePart[1]);

    //     final lastReceivedDate = DateTime(year, month, day, hour, minute);
    //     final currentTime = DateTime.now();
    //     final difference = currentTime.difference(lastReceivedDate);

    //     if (difference.inMinutes <= 7) {
    //       return 'Active';
    //     } else {
    //       return 'Inactive';
    //     }
    //   } catch (e) {
    //     return 'Inactive';
    //   }
    // }
    try {
      // Adjust this format to match the actual format of lastReceivedTime
      final dateFormat = DateFormat(
          'yyyy-MM-dd hh:mm a'); // Change to 'HH:mm' for 24-hour format

      final lastReceivedDate = dateFormat.parse(lastReceivedTime);
      final currentTime = DateTime.now();
      final difference = currentTime.difference(lastReceivedDate);

      if (difference.inMinutes <= 7) {
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

    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
        chlorineData.clear();
        fetchData(); // Fetch data for the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the background image based on the device type
    String backgroundImagePath = widget.deviceName.startsWith('WD')
        ? 'assets/tree.jpg'
        : 'assets/Chloritron.PNG';

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
                "Graphs for ${widget.sequentialName}",
                style: TextStyle(color: Colors.white),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Device ID: ${widget.sequentialName}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.013,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Status: $_currentStatus',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.013,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Received: $_dataReceivedTime',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.013,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      20), // Space between status and buttons

                              // Row for Date Picker and Download CSV button aligned to the left
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Date Picker button
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ElevatedButton(
                                      onPressed: _selectDate,
                                      child: Text(
                                        'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
                                      ),
                                    ),
                                  ),
                                  // Download CSV button
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ElevatedButton(
                                      onPressed: downloadCSV,
                                      child: Text('Download CSV'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      20), // Space between buttons and Wind Direction

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
                    SizedBox(height: 20),
                    Text(
                      _message,
                      style: TextStyle(color: Colors.red),
                    ),
                    _buildChartContainer('Chlorine', chlorineData,
                        'chlorine (mg/L)', ChartType.line),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(String title, List<ChartData> data,
      String yAxisTitle, ChartType chartType) {
    return data.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 400,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text(
                      '$title Graph', // Displaying the chart's title
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SfCartesianChart(
                      plotAreaBackgroundColor: Colors.white,
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat('hh:mm a'),
                        title: AxisTitle(
                          text: 'Time',
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        labelRotation: 70,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(
                          text: yAxisTitle,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        axisLine: AxisLine(width: 1),
                        majorGridLines: MajorGridLines(width: 1),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <ChartSeries<ChartData, DateTime>>[
                        _getChartSeries(chartType, data, title),
                      ],
                    ),
                  ),
                  // Add zoom control buttons
                ],
              ),
            ),
          )
        : Container(); // Return empty container if no data
  }

  ChartSeries<ChartData, DateTime> _getChartSeries(
      ChartType chartType, List<ChartData> data, String title) {
    switch (chartType) {
      case ChartType.line:
        return LineSeries<ChartData, DateTime>(
          markerSettings: const MarkerSettings(
            height: 2.0,
            width: 2.0,
            borderColor: Colors.blue,
            isVisible: true,
          ),
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: title,
          color: Colors.blue,
        );

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

  factory ChartData.fromJson(Map<String, dynamic> json, String type) {
    final dateFormat = DateFormat('yyyy-MM-dd hh:mm a'); // Match this format
    return ChartData(
      timestamp: dateFormat.parse(json['HumanTime']),
      value: json[type] != null
          ? double.tryParse(json[type].toString()) ?? 0.0
          : 0.0,
    );
  }
}
