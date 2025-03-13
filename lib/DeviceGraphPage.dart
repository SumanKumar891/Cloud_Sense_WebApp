import 'dart:convert';
import 'dart:io';
import 'package:cloud_sense_webapp/downloadcsv.dart';
import 'package:cloud_sense_webapp/push_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;
import 'package:shared_preferences/shared_preferences.dart';
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
  List<ChartData> rainLevelData = [];
  List<ChartData> rainDifferenceData = [];
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
  List<ChartData> temmppData = [];
  List<ChartData> humidityyData = [];
  List<ChartData> lightIntensityyData = [];
  List<ChartData> windSpeeddData = [];
  List<ChartData> ttempData = [];
  List<ChartData> dovaluedata = [];
  List<ChartData> dopercentagedata = [];
  List<ChartData> temperaturData = [];
  List<ChartData> humData = [];
  List<ChartData> luxData = [];
  List<ChartData> coddata = [];
  List<ChartData> boddata = [];
  List<ChartData> phdata = [];
  List<ChartData> temperattureData = [];
  List<ChartData> humidittyData = [];
  List<ChartData> ammoniaData = [];
  List<ChartData> temperaturedata = [];
  List<ChartData> humiditydata = [];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _hasShownAmmoniaNotification =
      false; // To prevent repeated notifications
  double _ammoniaThreshold = 0.0; // Threshold for ammonia alerts

  bool isShiftPressed = false;
  late final FocusNode _focusNode;

  List<Map<String, dynamic>> rainHourlyItems = [];
  List<List<dynamic>> _csvRainRows = [];

  double _precipitationProbability = 0.0;
  List<double> _weeklyPrecipitationData = [];
  int _selectedDeviceId = 0; // Variable to hold the selected device ID
  bool _isHovering = false;
  String? _activeButton;
  String _currentChlorineValue = '0.00';
  String _currentAmmoniaValue = '0.00';
  bool _isLoading = false;
  String _lastSelectedRange = 'single'; // Default to single
  bool isWindDirectionValid(String? windDirection) {
    return windDirection != null && windDirection != "-";
  }

  // New variables to store rain forecasting data for WD 211
  String _totalRainLast24Hours = '0.00 mm';
  String _mostRecentHourRain = '0.00 mm';

  bool hasNonZeroValues(List<dynamic> data,
      {bool includePrecipitation = true}) {
    // Exclude precipitation from the zero check if `includePrecipitation` is false
    if (includePrecipitation) {
      return data.isNotEmpty && data.any((entry) => entry.value != 0);
    } else {
      return data.isNotEmpty &&
          data.any((entry) =>
              entry.value != 0 && entry.type != 'precipitationProbability');
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _fetchDeviceDetails();

    _fetchDataForRange('single');

    _focusNode = FocusNode();
    // Initialize notifications
    _initializeNotifications();
  }

  Future<void> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

// Add this method to initialize notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Add this method to show notification
  Future<void> _showAmmoniaAlertNotification(double value) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ammonia_alerts',
      'Ammonia Alerts',
      channelDescription: 'Alerts for high ammonia values',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'High Ammonia Level Alert',
      'Ammonia level has reached ${value.toStringAsFixed(2)}, exceeding the safe threshold of $_ammoniaThreshold',
      platformChannelSpecifics,
    );
  }

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
  String _lastBatteryPercentage = "";
  String _lastRSSI_Value = "";

  Future<void> _fetchDataForRange(String range,
      [DateTime? selectedDate, double? latitude, double? longitude]) async {
    setState(() {
      _isLoading = true;
      _csvRows.clear();
      chlorineData.clear();
      temperatureData.clear();
      humidityData.clear();
      lightIntensityData.clear();
      windSpeedData.clear();
      rainLevelData.clear();
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
      temmppData.clear();
      humidityyData.clear();
      lightIntensityyData.clear();
      windSpeeddData.clear();
      ttempData.clear();
      dovaluedata.clear();
      dopercentagedata.clear();
      temperaturData.clear();
      humData.clear();
      luxData.clear();
      ammoniaData.clear();
      temperaturedata.clear;
      humiditydata.clear;
      _weeklyPrecipitationData.clear();
    });
    DateTime startDate;
    DateTime endDate = DateTime.now();

    switch (range) {
      case '7days':
        startDate = endDate.subtract(Duration(days: 7));
        break;
      case '30days':
        startDate = endDate.subtract(Duration(days: 30));
        break;
      case '3months':
        startDate = endDate.subtract(Duration(days: 90));
        break;
      case '6months':
        startDate = endDate.subtract(Duration(days: 180));
        break;
      case 'single':
        startDate = _selectedDay; // Use the selected day as startDate
        endDate = startDate;
        print('Selected Day: $_selectedDay');
        print('Start Date: $startDate, End Date: $endDate');

        // Single day means endDate is same as startDate
        break;
      default:
        startDate = endDate; // Default to today
    }

    _lastSelectedRange = range; // Store the currently selected range

    final startdate = _formatDate(startDate);
    final enddate = _formatDate(endDate);
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    int deviceId =
        int.parse(widget.deviceName.replaceAll(RegExp(r'[^0-9]'), ''));

    setState(() {
      _selectedDeviceId = deviceId; // Set the selected device ID
    });
    // Call the additional rain data API for WD211
    if (widget.deviceName == 'WD211') {
      await _fetchRainForecastingData();
    }
    if (widget.deviceName == 'WD511') {
      await _fetchRainForecastData();
    }

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
    } else if (widget.deviceName.startsWith('DO')) {
      apiUrl =
          'https://br2s08as9f.execute-api.us-east-1.amazonaws.com/default/CloudSense_Water_quality_api_2_function?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('TH')) {
      apiUrl =
          'https://5s3pangtz0.execute-api.us-east-1.amazonaws.com/default/CloudSense_TH_Data_Api_function?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('NH')) {
      apiUrl =
          'https://qgbwurafri.execute-api.us-east-1.amazonaws.com/default/CloudSense_NH_Data_Api_function?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('LU') ||
        widget.deviceName.startsWith('TE') ||
        widget.deviceName.startsWith('AC')) {
      apiUrl =
          'https://2bftil5o0c.execute-api.us-east-1.amazonaws.com/default/CloudSense_sensor_api_function?DeviceId=$deviceId&startdate=$startdate&enddate=$enddate';
    } else {
      setState(() {});
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<List<dynamic>> rows = [];
        String lastWindDirection = 'Unknown';
        String lastBatteryPercentage = 'Unknown';
        String lastRSSI_Value = 'Unknown';

        if (widget.deviceName.startsWith('CL') ||
            widget.deviceName.startsWith('BD')) {
          setState(() {
            chlorineData = _parseBDChartData(data, 'chlorine');
            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainLevelData = [];
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
            rainLevelData = [];
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
            rainLevelData = [];
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
        } else if (widget.deviceName.startsWith('DO')) {
          setState(() {
            ttempData = _parsedoChartData(data, 'Temperature');
            dovaluedata = _parsedoChartData(data, 'DO Value');
            dopercentagedata = _parsedoChartData(data, 'DO Percentage');

            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainLevelData = [];
            solarIrradianceData = [];
            chlorineData = [];
            tempData = [];
            tdsData = [];
            codData = [];
            bodData = [];
            pHData = [];
            doData = [];
            ecData = [];
            temmppData = [];
            humidityyData = [];
            lightIntensityData = [];
            windSpeeddData = [];

            rows = [
              [
                "Timestamp",
                "Temperature",
                "DO Value ",
                "DO Percentage",
              ],
              for (int i = 0; i < ttempData.length; i++)
                [
                  formatter.format(ttempData[i].timestamp),
                  ttempData[i].value,
                  dovaluedata[i].value,
                  dopercentagedata[i].value,
                ]
            ];
          });
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('TH')) {
          setState(() {
            temperattureData = _parsethChartData(data, 'Temperature');
            humidittyData = _parsethChartData(data, 'Humidity');

            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainLevelData = [];
            solarIrradianceData = [];
            chlorineData = [];
            tempData = [];
            tdsData = [];
            codData = [];
            bodData = [];
            pHData = [];
            doData = [];
            ecData = [];
            temmppData = [];
            humidityyData = [];
            lightIntensityData = [];
            windSpeeddData = [];

            rows = [
              [
                "Timestamp",
                "Temperature",
                "Humidity ",
              ],
              for (int i = 0; i < temperattureData.length; i++)
                [
                  formatter.format(temperattureData[i].timestamp),
                  temperattureData[i].value,
                  humidittyData[i].value,
                ]
            ];
          });
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('NH')) {
          setState(() {
            ammoniaData = _parseammoniaChartData(data, 'AmmoniaPPM');
            temperaturedata = _parseammoniaChartData(data, 'Temperature');
            humiditydata = _parseammoniaChartData(data, 'Humidity');

            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainLevelData = [];
            solarIrradianceData = [];
            chlorineData = [];
            electrodeSignalData = [];
            hypochlorousData = [];
            temppData = [];
            residualchlorineData = [];
            tempData = [];
            tdsData = [];
            codData = [];
            bodData = [];
            pHData = [];
            doData = [];
            ecData = [];
            temmppData = [];
            humidityyData = [];
            lightIntensityData = [];
            windSpeeddData = [];
            ttempData = [];
            dovaluedata = [];
            dopercentagedata = [];
            temperaturData = [];
            humData = [];
            luxData = [];
            coddata = [];
            boddata = [];
            phdata = [];
            temperattureData = [];
            humidittyData = [];

            // if (ammoniaData.isNotEmpty) {
            //   _currentAmmoniaValue = ammoniaData.last.value.toStringAsFixed(2);
            // }
// Update ammonia value and check threshold
            // Check if ammonia value exceeds 25 ppm and trigger notification
            // if (ammoniaData.isNotEmpty) {
            //   double currentAmmoniaValue = ammoniaData.last.value;
            //   if (currentAmmoniaValue > 0) {
            //     // Trigger the notification when ammonia level exceeds 25 ppm
            //     PushNotifications()
            //         .sendAmmoniaAlertNotification(currentAmmoniaValue);
            //   }
            // }

            rows = [
              [
                "Timestamp",
                "Ammonia",
                "Temperature",
                "Humidity ",
              ],
              for (int i = 0; i < ammoniaData.length; i++)
                [
                  formatter.format(ammoniaData[i].timestamp),
                  ammoniaData[i].value,
                  temperaturedata[i].value,
                  humiditydata[i].value,
                ]
            ];
          });
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('TE')) {
          setState(() {
            temperaturData = _parsesensorChartData(data, 'Temperature');
            humData = _parsesensorChartData(data, 'Humidity');

            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainLevelData = [];
            solarIrradianceData = [];
            chlorineData = [];
            tempData = [];
            tdsData = [];
            codData = [];
            bodData = [];
            pHData = [];
            doData = [];
            ecData = [];
            temmppData = [];
            humidityyData = [];
            lightIntensityData = [];
            windSpeeddData = [];

            if (data['sensor_data_items'].isNotEmpty) {
              lastRSSI_Value =
                  data['sensor_data_items'].last['RSSI_Value']?.toString() ??
                      'Unknown';
            }

            rows = [
              [
                "Timestamp",
                "Temperature",
                "Humidity",
              ],
              for (int i = 0; i < temperaturData.length; i++)
                [
                  formatter.format(temperaturData[i].timestamp),
                  temperaturData[i].value,
                  humData[i].value,
                ]
            ];
          });
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('LU')) {
          setState(() {
            luxData = _parsesensorChartData(data, 'LUX');

            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainLevelData = [];
            solarIrradianceData = [];
            chlorineData = [];
            tempData = [];
            tdsData = [];
            codData = [];
            bodData = [];
            pHData = [];
            doData = [];
            ecData = [];
            temmppData = [];
            humidityyData = [];
            lightIntensityData = [];
            windSpeeddData = [];

            rows = [
              [
                "Timestamp",
                "LUX",
              ],
              for (int i = 0; i < luxData.length; i++)
                [
                  formatter.format(luxData[i].timestamp),
                  luxData[i].value,
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
            rainDifferenceData = _parseRainDifferenceData(data);
            solarIrradianceData = _parseChartData(data, 'SolarIrradiance');

            chlorineData = [];
            tempData = [];
            tdsData = [];
            codData = [];
            bodData = [];
            pHData = [];
            doData = [];
            ecData = [];

            //Extract the last wind direction from the data
            if (data['weather_items'].isNotEmpty) {
              lastWindDirection = data['weather_items'].last['WindDirection'];
              lastBatteryPercentage =
                  data['weather_items'].last['BatteryPercentage'];
            }

            // Prepare data for CSV
            rows = [
              [
                "Timestamp",
                "Temperature",
                "Humidity",
                "LightIntensity",
                "SolarIrradiance",
              ],
              for (int i = 0; i < temperatureData.length; i++)
                [
                  formatter.format(temperatureData[i].timestamp),
                  temperatureData[i].value,
                  humidityData[i].value,
                  lightIntensityData[i].value,
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
          _lastBatteryPercentage = lastBatteryPercentage;
          _lastRSSI_Value = lastRSSI_Value;

          if (_csvRows.isEmpty) {
          } else {}
        });
      }
    } catch (e) {
      setState(() {});
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void downloadCSV(BuildContext context, {DateTimeRange? range}) async {
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
        // Use Storage Access Framework for non-web platforms
        await saveCSVFile(csvData, fileName); // Pass filename to saveCSVFile
      } catch (e) {
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
    try {
      // Get the Downloads directory.
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving file: $e")),
      );
    }
  }

  Future<void> _fetchRainForecastingData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://w6dzlucugb.execute-api.us-east-1.amazonaws.com/default/CloudSense_rain_data_api?DeviceId=211'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalRainLast24Hours =
              data['TotalRainLast24Hours']?.toString() ?? '0.00 mm';
          _mostRecentHourRain =
              data['MostRecentHourRain']?.toString() ?? '0.00 mm';
        });
      } else {
        throw Exception('Failed to load rain forecasting data');
      }
    } catch (e) {
      print('Error fetching rain forecasting data: $e');
    }
  }

  Future<void> _fetchRainForecastData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://w6dzlucugb.execute-api.us-east-1.amazonaws.com/default/CloudSense_rain_data_api?DeviceId=511'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalRainLast24Hours =
              data['TotalRainLast24Hours']?.toString() ?? '0.00 mm';
          _mostRecentHourRain =
              data['MostRecentHourRain']?.toString() ?? '0.00 mm';
        });
      } else {
        throw Exception('Failed to load rain forecasting data');
      }
    } catch (e) {
      print('Error fetching rain forecasting data: $e');
    }
  }

  Future<void> _showDownloadOptionsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Download Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  downloadCSV(context);
                },
                child: const Text('Download for Selected Range'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CsvDownloader(
                              deviceName: widget.deviceName,
                            )),
                  );
                },
                child: const Text('Download for Custom Range'),
              ),
            ],
          ),
        );
      },
    );
  }

  List<ChartData> _parseBDChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
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
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }

      // Parse the value based on the `type`
      double value;
      if (type == 'RainLevel' && item[type] is String) {
        // Remove unit from RainLevel string and parse the numeric part
        String rainLevelStr =
            item[type].split(' ')[0]; // Extract "2.51" from "2.51 mm"
        value = double.tryParse(rainLevelStr) ?? 0.0;
      } else {
        // For other types, parse directly
        value = double.tryParse(item[type].toString()) ?? 0.0;
      }

      return ChartData(
        timestamp: _parseDate(item['HumanTime']),
        value: value,
      );
    }).toList();
  }

  List<ChartData> _parseRainDifferenceData(Map<String, dynamic> data) {
    final List<dynamic> items = data['rain_hourly_items'] ?? [];

    return items.map((item) {
      if (item == null) {
        return ChartData(
            timestamp: DateTime.now(), value: 0.0); // Default value
      }

      // Extract and parse RainDifference value, removing unit "mm"
      String rainDifferenceStr = item['RainDifference'].split(' ')[0];
      double rainDifferenceValue = double.tryParse(rainDifferenceStr) ?? 0.0;

      return ChartData(
        timestamp: DateTime.parse(item['HourTimestamp']),
        value: rainDifferenceValue,
      );
    }).toList();
  }

  List<ChartData> _parsewaterChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parsewaterDate(item['HumanTime']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parsesensorChartData(
      Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['sensor_data_items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parsesensorDate(item['HumanTime']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parsewindChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parsewindDate(item['human_time']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parsedoChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parsedoDate(item['HumanTime']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parsethChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parsethDate(item['HumanTime']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parseammoniaChartData(
      Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parseammoniaDate(item['HumanTime']),
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
        return ChartData(timestamp: DateTime.now(), value: 0.0);
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
        // 'average': [null],
        'current': [null],
        'min': [null],
        'max': [null],
      };
    }
    // double sum = 0.0;
    double? current = data.last.value;
    double min = double.infinity;
    double max = double.negativeInfinity;

    for (var entry in data) {
      if (entry.value < min) min = entry.value;
      if (entry.value > max) max = entry.value;
    }

    return {
      'current': [current],
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
                    'Current',
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
          stats['current']?[0] != null
              ? stats['current']![0]!.toStringAsFixed(2)
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

// Calculate average, min, and max values
  Map<String, List<double?>> _calculateDOStatistics(List<ChartData> data) {
    if (data.isEmpty) {
      return {
        // 'average': [null],
        'current': [null],
        'min': [null],
        'max': [null],
      };
    }
    // double sum = 0.0;
    double? current = data.last.value; // Get the most recent (current) value
    double min = double.infinity;
    double max = double.negativeInfinity;

    for (var entry in data) {
      // sum += entry.value;
      if (entry.value < min) min = entry.value;
      if (entry.value > max) max = entry.value;
    }

    // double avg = data.isNotEmpty ? sum / data.length : 0.0;
    return {
      // 'average': [avg],
      'current': [current], // Return the last (current) value
      'min': [min],
      'max': [max],
    };
  }

  // Create a table displaying statistics
  Widget buildDOStatisticsTable() {
    final ttempStats = _calculateDOStatistics(ttempData);
    final dovalueStats = _calculateDOStatistics(dovaluedata);
    final dopercentageStats = _calculateDOStatistics(dopercentagedata);

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
                    'Recent Value',
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
                buildDataRow('Temperature', ttempStats, fontSize),
                buildDataRow('DO Value', dovalueStats, fontSize),
                buildDataRow('DO Percentage', dopercentageStats, fontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow buildDODataRow(
      String parameter, Map<String, List<double?>> stats, double fontSize) {
    return DataRow(cells: [
      DataCell(Text(parameter,
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          stats['current']?[0] != null
              ? stats['current']![0]!.toStringAsFixed(2)
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

  Map<String, List<double?>> _calculateWeatherStatistics(List<ChartData> data) {
    if (data.isEmpty) {
      return {
        'current': [null],
      };
    }

    double? current = data.last.value; // Get the most recent (current) value

    return {
      'current': [current], // Return the last (current) value
    };
  }

  Widget buildWeatherStatisticsTable() {
    final temperatureStats = _calculateWeatherStatistics(temperatureData);
    final humidityStats = _calculateWeatherStatistics(humidityData);
    final lightIntensityStats = _calculateWeatherStatistics(lightIntensityData);
    final solarIrradianceStats =
        _calculateWeatherStatistics(solarIrradianceData);

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 800 ? 13 : 16;
    double headerFontSize = screenWidth < 800 ? 18 : 22;

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
        width: screenWidth < 800 ? double.infinity : 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered heading for the table
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Text(
                  'Data',
                  style: TextStyle(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: screenWidth < 800 ? screenWidth - 32 : 500,
                ),
                child: DataTable(
                  horizontalMargin: 16,
                  // columnSpacing: screenWidth < 700 ? 70 : 30,

                  columnSpacing: screenWidth < 362
                      ? 50
                      : screenWidth < 392
                          ? 80
                          : screenWidth < 500
                              ? 120
                              : screenWidth < 800
                                  ? 180
                                  : 70,

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
                      label: Padding(
                        padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width *
                              0.04, // Adjust padding based on screen width
                        ), // Adjust the value as needed
                        child: Text(
                          'Recent Value',
                          style: TextStyle(
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    buildWeatherDataRow(
                        'Temperature', temperatureStats, fontSize),
                    buildWeatherDataRow('Humidity', humidityStats, fontSize),
                    buildWeatherDataRow(
                        'Light Intensity', lightIntensityStats, fontSize),
                    buildWeatherDataRow(
                        'Solar Irradiance', solarIrradianceStats, fontSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow buildWeatherDataRow(
      String parameter, Map<String, List<double?>> stats, double fontSize) {
    return DataRow(cells: [
      DataCell(Text(parameter,
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          stats['current']?[0] != null
              ? stats['current']![0]!.toStringAsFixed(2)
              : '-',
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
    ]);
  }

  Widget buildRainDataTable() {
    // Use the string values directly from the API
    String currentRain = _mostRecentHourRain ?? "-"; // If null, show "-"
    String totalRainLast24Hours =
        _totalRainLast24Hours ?? "-"; // If null, show "-"

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 800 ? 13 : 16;
    double headerFontSize = screenWidth < 800 ? 18 : 22;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withOpacity(0.6), // Semi-transparent background
        ),
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(8),
        width: screenWidth < 800 ? double.infinity : 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Rain Data',
                style: TextStyle(
                  fontSize: headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            DataTable(
              columnSpacing: screenWidth < 380
                  ? 70
                  : screenWidth < 500
                      ? 120
                      : screenWidth < 800
                          ? 200
                          : 50,
              columns: [
                DataColumn(
                  label: Text(
                    'Timeframe',
                    style: TextStyle(
                        fontSize: screenWidth < 800 ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Value',
                    style: TextStyle(
                        fontSize: screenWidth < 800 ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text(
                      'Recent Hour',
                      style: TextStyle(fontSize: fontSize, color: Colors.white),
                    )),
                    DataCell(Text(
                      currentRain,
                      style: TextStyle(fontSize: fontSize, color: Colors.white),
                    )),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text(
                      'Last 24 Hours',
                      style: TextStyle(fontSize: fontSize, color: Colors.white),
                    )),
                    DataCell(Text(
                      totalRainLast24Hours,
                      style: TextStyle(fontSize: fontSize, color: Colors.white),
                    )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Calculate average, min, and max values
  Map<String, List<double?>> _calculateNHStatistics(List<ChartData> data) {
    if (data.isEmpty) {
      return {
        // 'average': [null],
        'current': [null],
        'min': [null],
        'max': [null],
      };
    }
    // double sum = 0.0;
    double? current = data.last.value;
    double min = double.infinity;
    double max = double.negativeInfinity;

    for (var entry in data) {
      if (entry.value < min) min = entry.value;
      if (entry.value > max) max = entry.value;
    }

    return {
      'current': [current],
      'min': [min],
      'max': [max],
    };
  }

  // Create a table displaying statistics
  Widget buildNHStatisticsTable() {
    final ammoniaStats = _calculateNHStatistics(ammoniaData);
    final temppStats = _calculateNHStatistics(temperaturedata);
    final humStats = _calculateNHStatistics(humiditydata);

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
                    'Current',
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
                buildDataRow('AMMONIA', ammoniaStats, fontSize),
                buildDataRow('TEMP', temppStats, fontSize),
                buildDataRow('HUMIDITY', humStats, fontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow buildNHDataRow(
      String parameter, Map<String, List<double?>> stats, double fontSize) {
    return DataRow(cells: [
      DataCell(Text(parameter,
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          stats['current']?[0] != null
              ? stats['current']![0]!.toStringAsFixed(2)
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
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  DateTime _parsewindDate(String dateString) {
    final dateFormat = DateFormat(
        'yyyy-MM-dd hh:mm a'); // Ensure this matches your date format
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

  DateTime _parsedoDate(String dateString) {
    final dateFormat = DateFormat(
        'yyyy-MM-dd HH:mm:ss'); // Ensure this matches your date format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  DateTime _parseammoniaDate(String dateString) {
    final dateFormat = DateFormat(
        'dd-MM-yyyy HH:mm:ss'); // Ensure this matches your date format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  DateTime _parsethDate(String dateString) {
    if (dateString.isEmpty) {
      return DateTime.now();
    }

    final dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      print('Date parsing error: $e');
      return DateTime.now();
    }
  }

  DateTime _parsesensorDate(String dateString) {
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
        'yyyy-MM-dd hh:MM:ss'); // Ensure this matches your date format
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
      lastDate: DateTime(2027),
    );

    if (picked != null) {
      setState(() {
        _selectedDay = picked;

        _fetchDataForRange('single'); // Fetch data for the selected date
      });
    }
  }

  void _reloadData({DateTime? selectedDate}) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    if (selectedDate != null) {
      // If a single date is selected, pass 'single' to fetch data for that day
      _lastSelectedRange = 'single'; // Update last selected range
      await _fetchDataForRange('single', selectedDate);
    } else {
      // If no date is selected, reload the last selected range
      await _fetchDataForRange(_lastSelectedRange);
    }

    setState(() {
      _isLoading = false; // Stop loading once data is fetched
    });
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
    } else if (widget.deviceName.startsWith('TE')) {
      backgroundImagePath = 'assets/tree.jpg';
    } else if (widget.deviceName.startsWith('LU')) {
      backgroundImagePath = 'assets/tree.jpg';
    } else if (widget.deviceName.startsWith('TH')) {
      backgroundImagePath = 'assets/tree.jpg';
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
              title: Text.rich(
                TextSpan(
                  text: widget.sequentialName, // Main title
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width < 800 ? 16 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: " (${widget.deviceName})", // Device ID in brackets
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 800
                            ? 16
                            : 30, // Smaller font
                        fontWeight: FontWeight.bold,
                        color: Colors.white70, // Slightly dim color
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                if (widget.deviceName.startsWith('WD'))
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 0.0), // Adjust padding as needed
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ensure Row uses only required space
                      children: [
                        Icon(
                          _getBatteryIcon(_parseBatteryPercentage(
                              _lastBatteryPercentage)), // Convert to int before passing
                          size: 26,
                          color: Colors.white,
                          // color: _getBatteryIconColor(_parseBatteryPercentage(
                          //     _lastBatteryPercentage)), // Change color based on percentage
                        ),
                        Text(
                          ': $_lastBatteryPercentage', // Battery percentage
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 0.0), // Adjust padding as needed
                  child: IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white, size: 26),
                    onPressed: () {
                      _reloadData(); // Function to reload data
                    },
                  ),
                ),
              ],
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
                                                    } else if (value ==
                                                        '6months') {
                                                      _fetchDataForRange(
                                                          '6months'); // Fetch data for 6 months
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
                                                  DropdownMenuItem(
                                                    child: Text(
                                                      'Last 6 months',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white),
                                                    ),
                                                    value: '6months',
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
                                              SizedBox(width: 8),
                                              // 3 Months button
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () {
                                                    _fetchDataForRange(
                                                        '6months'); // Fetch data for 6 months range
                                                    setState(() {
                                                      _activeButton = '6months';
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
                                                            '6months'
                                                        ? BorderSide(
                                                            color: Colors.white,
                                                            width: 2)
                                                        : BorderSide.none,
                                                  ),
                                                  child: Text(
                                                    'Last 6 months',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: _activeButton ==
                                                              '6months'
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
                              // if (widget.deviceName.startsWith('WD') &&
                              //     isWindDirectionValid(_lastWindDirection))
                              if (widget.deviceName.startsWith('WD') &&
                                  isWindDirectionValid(_lastWindDirection) &&
                                  _lastWindDirection != null &&
                                  _lastWindDirection.isNotEmpty)
                                Column(
                                  children: [
                                    Icon(
                                      Icons.wind_power,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Wind Direction : $_lastWindDirection',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),

                              SizedBox(height: 20),
                              if (widget.deviceName.startsWith('TE'))
                                Text(
                                  'RSSI Value : $_lastRSSI_Value',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
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
                          // if (widget.deviceName.startsWith('NH'))
                          //   _buildCurrentValue(
                          //       'Ammonia Value', _currentAmmoniaValue, 'PPM'),
                        ],
                      ),
                    ),
                    if (widget.deviceName.startsWith('WQ'))
                      buildStatisticsTable(),
                    if (widget.deviceName.startsWith('NH'))
                      buildNHStatisticsTable(),
                    if (widget.deviceName.startsWith('DO'))
                      buildDOStatisticsTable(),
                    if (widget.deviceName.startsWith('WD211') ||
                        (widget.deviceName.startsWith('WD511')))
                      SingleChildScrollView(
                        // Make the whole layout scrollable
                        child: Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double screenWidth = constraints.maxWidth;

                              // Check if the screen width is large enough to show the tables side by side
                              bool isLargeScreen = screenWidth > 800;

                              return isLargeScreen
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        buildWeatherStatisticsTable(), // Weather Statistics Table
                                        SizedBox(
                                            width: 5), // Space between tables
                                        buildRainDataTable(), // Rain Data Table
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        buildWeatherStatisticsTable(), // Weather Statistics Table
                                        SizedBox(
                                            height: 5), // Space between tables
                                        buildRainDataTable(), // Rain Data Table
                                      ],
                                    );
                            },
                          ),
                        ),
                      ),
                    Column(
                      children: [
                        if (hasNonZeroValues(chlorineData))
                          _buildChartContainer('Chlorine', chlorineData,
                              'Chlorine (mg/L)', ChartType.line),
                        if (hasNonZeroValues(temperatureData))
                          _buildChartContainer('Temperature', temperatureData,
                              'Temperature (°C)', ChartType.line),
                        if (hasNonZeroValues(humidityData))
                          _buildChartContainer('Humidity', humidityData,
                              'Humidity (%)', ChartType.line),
                        if (hasNonZeroValues(lightIntensityData))
                          _buildChartContainer(
                              'Light Intensity',
                              lightIntensityData,
                              'Light Intensity (Lux)',
                              ChartType.line),
                        if (hasNonZeroValues(windSpeedData))
                          _buildChartContainer('Wind Speed', windSpeedData,
                              'Wind Speed (m/s)', ChartType.line),
                        if (hasNonZeroValues(solarIrradianceData))
                          _buildChartContainer(
                              'Solar Irradiance',
                              solarIrradianceData,
                              'Solar Irradiance (W/M^2)',
                              ChartType.line),
                        if (hasNonZeroValues(tempData))
                          _buildChartContainer('Temperature', tempData,
                              'Temperature (°C)', ChartType.line),
                        if (hasNonZeroValues(tdsData))
                          _buildChartContainer(
                              'TDS', tdsData, 'TDS (ppm)', ChartType.line),
                        if (hasNonZeroValues(codData))
                          _buildChartContainer(
                              'COD', codData, 'COD (mg/L)', ChartType.line),
                        if (hasNonZeroValues(bodData))
                          _buildChartContainer(
                              'BOD', bodData, 'BOD (mg/L)', ChartType.line),
                        if (hasNonZeroValues(pHData))
                          _buildChartContainer(
                              'pH', pHData, 'pH', ChartType.line),
                        if (hasNonZeroValues(doData))
                          _buildChartContainer(
                              'DO', doData, 'DO (mg/L)', ChartType.line),
                        if (hasNonZeroValues(ecData))
                          _buildChartContainer(
                              'EC', ecData, 'EC (mS/cm)', ChartType.line),
                        if (hasNonZeroValues(temppData))
                          _buildChartContainer('Temperature', temppData,
                              'Temperature (°C)', ChartType.line),
                        if (hasNonZeroValues(electrodeSignalData))
                          _buildChartContainer(
                              'Electrode Signal',
                              electrodeSignalData,
                              'Electrode Signal (mV)',
                              ChartType.line),
                        if (hasNonZeroValues(residualchlorineData))
                          _buildChartContainer('Chlorine', residualchlorineData,
                              'Chlorine (mg/L)', ChartType.line),
                        if (hasNonZeroValues(hypochlorousData))
                          _buildChartContainer('Hypochlorous', hypochlorousData,
                              'Hypochlorous (mg/L)', ChartType.line),
                        if (hasNonZeroValues(temmppData))
                          _buildChartContainer('Temperature', temmppData,
                              'Temperature (°C)', ChartType.line),
                        if (hasNonZeroValues(humidityyData))
                          _buildChartContainer('Humidity', humidityyData,
                              'Humidity (%)', ChartType.line),
                        if (hasNonZeroValues(lightIntensityyData))
                          _buildChartContainer(
                              'Light Intensity',
                              lightIntensityyData,
                              'Light Intensity (Lux)',
                              ChartType.line),
                        if (hasNonZeroValues(windSpeeddData))
                          _buildChartContainer('Wind Speed', windSpeeddData,
                              'Wind Speed (m/s)', ChartType.line),
                        if (hasNonZeroValues(ttempData))
                          _buildChartContainer('Temperature', ttempData,
                              'Temperature (°C)', ChartType.line),
                        if (hasNonZeroValues(dovaluedata))
                          _buildChartContainer('DO Value', dovaluedata,
                              'DO (mg/L)', ChartType.line),
                        if (hasNonZeroValues(dopercentagedata))
                          _buildChartContainer(
                              'DO Percentage',
                              dopercentagedata,
                              'DO Percentage (%)',
                              ChartType.line),
                        if (hasNonZeroValues(temperaturData))
                          _buildChartContainer('Temperature', temperaturData,
                              'Temperature (°C)', ChartType.line),
                        if (hasNonZeroValues(humData))
                          _buildChartContainer('Humidity', humData,
                              'Humidity (%)', ChartType.line),
                        if (hasNonZeroValues(luxData))
                          _buildChartContainer('Light Intensity', luxData,
                              'Lux (Lux)', ChartType.line),
                        if (hasNonZeroValues(coddata))
                          _buildChartContainer(
                              'COD', coddata, 'COD (mg/L)', ChartType.line),
                        if (hasNonZeroValues(boddata))
                          _buildChartContainer(
                              'BOD', boddata, 'BOD (mg/L)', ChartType.line),
                        if (hasNonZeroValues(phdata))
                          _buildChartContainer(
                              'pH', luxData, 'pH', ChartType.line),
                        if (hasNonZeroValues(temperattureData))
                          _buildChartContainer('Temperature', temperattureData,
                              'Temperature (°C)', ChartType.line),
                        if (hasNonZeroValues(humidittyData))
                          _buildChartContainer('Humidity', humidittyData,
                              'Humidity (%)', ChartType.line),
                        if (hasNonZeroValues(ammoniaData))
                          _buildChartContainer('Ammonia', ammoniaData,
                              'Ammonia (PPM)', ChartType.line),
                        if (hasNonZeroValues(temperaturedata))
                          _buildChartContainer('Temperature', temperaturedata,
                              'Temperature (°C)', ChartType.line),
                        if (hasNonZeroValues(humiditydata))
                          _buildChartContainer('Humidity', humiditydata,
                              'Humidity (%)', ChartType.line),
                      ],
                    )
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
                  //downloadCSV(context);
                  // downloadRainCSV(context);
                  _showDownloadOptionsDialog(context); // Show popup
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

// This method will parse the percentage string (e.g., "84%") and return the numeric value
  int _parseBatteryPercentage(String batteryPercentage) {
    try {
      // Remove the '%' symbol and parse the number
      return int.parse(batteryPercentage.replaceAll('%', ''));
    } catch (e) {
      // If parsing fails, return a default value (e.g., 0)
      return 0;
    }
  }

  IconData _getBatteryIcon(int batteryPercentage) {
    if (batteryPercentage <= 0) {
      return Icons.battery_0_bar; // Empty battery
    } else if (batteryPercentage > 0 && batteryPercentage <= 20) {
      return Icons.battery_1_bar; // 20% battery
    } else if (batteryPercentage > 20 && batteryPercentage <= 40) {
      return Icons.battery_2_bar; // 40% battery
    } else if (batteryPercentage > 40 && batteryPercentage <= 60) {
      return Icons.battery_3_bar; // 60% battery
    } else if (batteryPercentage > 60 && batteryPercentage <= 80) {
      return Icons.battery_4_bar; // 80% battery
    } else if (batteryPercentage > 80 && batteryPercentage < 100) {
      return Icons.battery_5_bar; // 90% battery
    } else {
      return Icons.battery_full; // Full battery
    }
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
                      '$title Graph',
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
                    child: Focus(
                      autofocus: true,
                      child: RawKeyboardListener(
                        focusNode: _focusNode,
                        autofocus: true,
                        onKey: (RawKeyEvent event) {
                          if (event is RawKeyDownEvent &&
                              (event.logicalKey ==
                                      LogicalKeyboardKey.shiftLeft ||
                                  event.logicalKey ==
                                      LogicalKeyboardKey.shiftRight)) {
                            setState(() {
                              isShiftPressed = true;
                            });
                          } else if (event is RawKeyUpEvent &&
                              (event.logicalKey ==
                                      LogicalKeyboardKey.shiftLeft ||
                                  event.logicalKey ==
                                      LogicalKeyboardKey.shiftRight)) {
                            setState(() {
                              isShiftPressed = false;
                            });
                          }
                        },
                        child: MouseRegion(
                          onEnter: (_) => _focusNode.requestFocus(),
                          child: Listener(
                            onPointerSignal: (PointerSignalEvent event) {
                              print(
                                  "Pointer Signal Event: $event | Shift Pressed: $isShiftPressed");
                              if (event is PointerScrollEvent &&
                                  isShiftPressed) {
                                print("Zooming...");
                                // No need to return early; let ZoomPanBehavior handle it
                              }
                            },
                            child: SfCartesianChart(
                              plotAreaBackgroundColor:
                                  const Color.fromARGB(100, 0, 0, 0),
                              primaryXAxis: DateTimeAxis(
                                dateFormat: DateFormat('MM/dd hh:mm a'),
                                title: AxisTitle(
                                  text: 'Time',
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                labelStyle: TextStyle(color: Colors.white),
                                labelRotation: 70,
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                intervalType: DateTimeIntervalType.auto,
                                autoScrollingDelta: 100,
                                autoScrollingMode: AutoScrollingMode.end,
                                enableAutoIntervalOnZooming: true,
                                majorGridLines: MajorGridLines(width: 1.0),
                              ),
                              primaryYAxis: NumericAxis(
                                labelStyle: TextStyle(color: Colors.white),
                                title: AxisTitle(
                                  text: yAxisTitle,
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w200,
                                      color: Colors.white),
                                ),
                                axisLine: AxisLine(width: 1),
                                majorGridLines: MajorGridLines(width: 0),
                              ),
                              tooltipBehavior: TooltipBehavior(
                                enable: true,
                                duration: 4000,
                                builder: (dynamic data,
                                    dynamic point,
                                    dynamic series,
                                    int pointIndex,
                                    int seriesIndex) {
                                  final ChartData chartData = data as ChartData;
                                  return Container(
                                    padding: EdgeInsets.all(8),
                                    color: const Color.fromARGB(127, 0, 0, 0),
                                    constraints: BoxConstraints(
                                      maxWidth: 200,
                                      maxHeight: 60,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                enableMouseWheelZooming: isShiftPressed,
                              ),
                              series: <ChartSeries<ChartData, DateTime>>[
                                _getChartSeries(chartType, data, title),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
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
