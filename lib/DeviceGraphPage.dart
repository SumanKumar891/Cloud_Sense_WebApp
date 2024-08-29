import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class DeviceGraphPage extends StatefulWidget {
  final String deviceName;

  DeviceGraphPage({required this.deviceName});

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

  @override
  void initState() {
    super.initState();
    _fetchDeviceDetails();
    fetchData();
  }

  Future<void> _fetchDeviceDetails() async {
    try {
      final response = await http.get(Uri.parse(
          'https://c27wvohcuc.execute-api.us-east-1.amazonaws.com/default/beehive_activity_api'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final selectedDevice = data.firstWhere(
            (device) => device['deviceId'] == widget.deviceName,
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

  Future<void> fetchData() async {
    final startDate = _formatDate(_selectedDay);
    final endDate = startDate;

    try {
      final response = await http.get(Uri.parse(
          'https://ixzeyfcuw5.execute-api.us-east-1.amazonaws.com/default/weather_station_awadh_api?deviceid=202&startdate=$startDate&enddate=$endDate'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperatureData = _parseChartData(data, 'temperature');
          humidityData = _parseChartData(data, 'humidity');
          lightIntensityData = _parseChartData(data, 'light_intensity');
          windSpeedData = _parseChartData(data, 'wind_speed');
        });
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<ChartData> _parseChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(
            timestamp: DateTime.now(), value: 0.0); // Provide default value
      }
      return ChartData(
        timestamp: _parseDate(item['human_time']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  DateTime _parseDate(String dateString) {
    final dateFormat = DateFormat(
        'yyyy-MM-dd hh:mm a'); // Ensure this matches your date format
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
      final dateTimeParts = lastReceivedTime.split(' ');
      final datePart = dateTimeParts[0].split('-');
      final timePart = dateTimeParts[1].split(':');

      final day = int.parse(datePart[2]);
      final month = int.parse(datePart[1]);
      final year = int.parse(datePart[0]);

      final hour = int.parse(timePart[0]);
      final minute = int.parse(timePart[1]);

      final lastReceivedDate = DateTime(year, month, day, hour, minute);
      final currentTime = DateTime.now();
      final difference = currentTime.difference(lastReceivedDate);

      if (difference.inMinutes <= 7) {
        return 'Active';
      } else {
        return 'Inactive';
      }
    } catch (e) {
      return 'Inactive';
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
        fetchData(); // Fetch data for the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 202, 213, 223), // Blue background color for the entire page
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
            255, 202, 213, 223), // Blue background color for the AppBar
        title: Text("Graphs for ${widget.deviceName}"),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.arrow_back),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     color: Colors.white, // White color for the back button icon
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 202, 213,
              223), // Ensure the container matches the background color
          child: Column(
            children: [
              // Device Details in a Row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Device ID: ${widget.deviceName}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black), // White text color
                    ),
                    Text(
                      'Status: $_currentStatus',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black), // White text color
                    ),
                    Text(
                      'Received: $_dataReceivedTime',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black), // White text color
                    ),
                  ],
                ),
              ),
              // Date Picker Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _selectDate,
                  child: Text(
                      'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}'),
                  style: ElevatedButton.styleFrom(
                      // backgroundColor:
                      //     Colors.blue, // Blue background color for the button
                      ),
                ),
              ),
              // Charts with updated styles
              _buildChartContainer('Temperature', temperatureData,
                  'Temperature (°C)', ChartType.line),
              _buildChartContainer(
                  'Humidity', humidityData, 'Humidity (%)', ChartType.line),
              _buildChartContainer('Light Intensity', lightIntensityData,
                  'Light Intensity (Lux)', ChartType.line),
              _buildChartContainer('Wind Speed', windSpeedData,
                  'Wind Speed (m/s)', ChartType.line),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer(String title, List<ChartData> data,
      String yAxisTitle, ChartType chartType) {
    return data.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 340,
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
        return SplineSeries<ChartData, DateTime>(
          markerSettings: const MarkerSettings(
            height: 4.0,
            width: 4.0,
            borderColor: Colors.blue,
            isVisible: true,
          ),
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: title,
          color: Colors.blue,
        );
      case ChartType.line:
        return ColumnSeries<ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: title,
          color: Colors.blue,
        );
      case ChartType.line:
        return LineSeries<ChartData, DateTime>(
          markerSettings: const MarkerSettings(
            height: 4.0,
            width: 4.0,
            borderColor: Colors.blue,
            isVisible: true,
          ),
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: title,
          color: Colors.blue,
        );
      case ChartType.line:
        return StepLineSeries<ChartData, DateTime>(
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
      timestamp: dateFormat.parse(json['human_time']),
      value: json[type] != null
          ? double.tryParse(json[type].toString()) ?? 0.0
          : 0.0,
    );
  }
}
