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
  List<ChartData> solarIrradianceData = [];
  List<ChartData> windSpeedData = [];
  List<ChartData> windDirectionData = [];
  List<ChartData> rainDetectionData = [];
  List<ChartData> rainSpeedData = [];
  List<ChartData> rainTimeData = [];
  List<ChartData> soilSensorData = [];
  List<ChartData> pressureData = [];

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
            _currentStatus = _getDeviceStatus(selectedDevice['lastReceivedTime']);
            _dataReceivedTime =
                selectedDevice['lastReceivedTime'] ?? 'Unknown';
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
        'https://ixzeyfcuw5.execute-api.us-east-1.amazonaws.com/default/weather_station_awadh_api?deviceid=${widget.deviceName}&startdate=$startDate&enddate=$endDate'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperatureData = _parseChartData(data, 'Temperature');
        humidityData = _parseChartData(data, 'Humidity');
        lightIntensityData = _parseChartData(data, 'LightIntensity');
        solarIrradianceData = _parseChartData(data, 'SolarIrradiance');
        windSpeedData = _parseChartData(data, 'WindSpeed');
        windDirectionData = _parseChartData(data, 'WindDirection');
        rainDetectionData = _parseChartData(data, 'RainDetection');
        rainSpeedData = _parseChartData(data, 'RainSpeed');
        rainTimeData = _parseChartData(data, 'RainTime');
        soilSensorData = _parseChartData(data, 'SoilSensor');
        pressureData = _parseChartData(data, 'Pressure');
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
      if (item == null || item[type] == null) {
        print('Missing data for $type');
        return ChartData(timestamp: 'N/A', value: 0.0);
      }
      return ChartData.fromJson(item, type);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _getDeviceStatus(String lastReceivedTime) {
    if (lastReceivedTime == 'Unknown') return 'Unknown';

    try {
      final dateTimeParts = lastReceivedTime.split('_');
      final datePart = dateTimeParts[0].split('-');
      final timePart = dateTimeParts[1].split('-');

      final day = int.parse(datePart[0]);
      final month = int.parse(datePart[1]);
      final year = int.parse(datePart[2]);

      final hour = int.parse(timePart[0]);
      final minute = int.parse(timePart[1]);
      final second = int.parse(timePart[2]);

      final lastReceivedDate = DateTime(year, month, day, hour, minute, second);
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
      appBar: AppBar(
        title: Text("Graphs for ${widget.deviceName}"),
      ),
      body: SingleChildScrollView(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Status: $_currentStatus',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Received: $_dataReceivedTime',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              ),
            ),
            // Charts
            _buildChartContainer('Temperature', temperatureData, 'Temperature (°C)'),
            _buildChartContainer('Humidity', humidityData, 'Humidity (%)'),
            _buildChartContainer('Light Intensity', lightIntensityData, 'Light Intensity (Lux)'),
            _buildChartContainer('Solar Irradiance', solarIrradianceData, 'Solar Irradiance (W/m²)'),
            _buildChartContainer('Wind Speed', windSpeedData, 'Wind Speed (km/h)'),
            _buildChartContainer('Wind Direction', windDirectionData, 'Wind Direction (°)'),
            _buildChartContainer('Rain Detection', rainDetectionData, 'Rain Detection (mm)'),
            _buildChartContainer('Rain Speed', rainSpeedData, 'Rain Speed (mm/h)'),
            _buildChartContainer('Rain Time', rainTimeData, 'Rain Time (minutes)'),
            _buildChartContainer('Soil Sensor', soilSensorData, 'Soil Sensor Reading'),
            _buildChartContainer('Pressure', pressureData, 'Pressure (hPa)'),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContainer(String title, List<ChartData> data, String yAxisTitle) {
    return Container(
      height: 300,
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
      child: SfCartesianChart(
        plotAreaBackgroundColor: Colors.white,
        primaryXAxis: CategoryAxis(
          title: AxisTitle(
            text: 'Time',
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          labelRotation: 45,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: yAxisTitle,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          axisLine: AxisLine(width: 0),
          majorGridLines: MajorGridLines(width: 0.5),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries<ChartData, String>>[
          LineSeries<ChartData, String>(
            markerSettings: const MarkerSettings(
              height: 3.0,
              width: 3.0,
              borderColor: Colors.blue,
              isVisible: true,
            ),
            dataSource: data.isNotEmpty ? data : [ChartData(timestamp: 'No Data', value: 0.0)],
            xValueMapper: (ChartData data, _) => data.timestamp,
            yValueMapper: (ChartData data, _) => data.value,
            name: title,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String timestamp;
  final double value;

  ChartData({required this.timestamp, required this.value});

  factory ChartData.fromJson(Map<String, dynamic> json, String type) {
    return ChartData(
      timestamp: json['timestamp'] ?? 'N/A',
      value: json[type] != null ? double.tryParse(json[type].toString()) ?? 0.0 : 0.0,
    );
  }
}
