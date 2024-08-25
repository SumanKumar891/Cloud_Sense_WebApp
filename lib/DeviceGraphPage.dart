import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class DeviceGraphPage extends StatefulWidget {
  final String deviceName;

  DeviceGraphPage({required this.deviceName});

  @override
  _DeviceGraphPageState createState() => _DeviceGraphPageState();
}

class _DeviceGraphPageState extends State<DeviceGraphPage> {
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
    fetchData();
  }

  Future<void> fetchData() async {
    final startDate = _formatDate(DateTime.now());
    final endDate = startDate;

    final response = await http.get(Uri.parse(
        'https://5gdhg1ja9d.execute-api.us-east-1.amazonaws.com/default/beehive_weather?deviceid=${widget.deviceName}&startdate=$startDate&enddate=$endDate'));

    if (response.statusCode == 200) {
      try {
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
      } catch (e, stackTrace) {
        print('Error parsing response: $e');
        print('Stack trace: $stackTrace');
      }
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
    }
  }

  List<ChartData> _parseChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null || item[type] == null) {
        return ChartData(timestamp: 'N/A', value: 0.0);
      }
      return ChartData.fromJson(item, type);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
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
