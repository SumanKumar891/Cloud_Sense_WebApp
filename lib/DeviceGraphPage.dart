import 'dart:convert';
import 'dart:io';
import 'package:cloud_sense_webapp/downloadcsv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html; //import 'dart:html' as html;
import 'dart:io' as io;
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
  List<Map<String, dynamic>> rainHourlyItems = [];
  List<List<dynamic>> _csvRainRows = [];

  double _precipitationProbability = 0.0;
  List<double> _weeklyPrecipitationData = [];
  int _selectedDeviceId = 0; // Variable to hold the selected device ID
  bool _isHovering = false; // Track hover state
  String? _activeButton;
  String _currentChlorineValue = '0.00';
  bool _isLoading = false;
  String _lastSelectedRange = 'single'; // Default to single
  bool isWindDirectionValid(String? windDirection) {
    return windDirection != null && windDirection != "-";
  }

  // New variables to store rain forecasting data for WD 211
  String _totalRainLast24Hours = '0.00 mm';
  String _mostRecentHourRain = '0.00 mm';

// bool hasNonZeroValues(List<dynamic> data) {
  //   // Return false if list is empty or contains only zeros
  //   return data.isNotEmpty && data.any((entry) => entry.value != 0);
  // }
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

  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _fetchDeviceDetails();
    // fetchData();
    _fetchDataForRange('single');
    _loadLocationFromPrefs();
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
        }
        // } else {
        //   print('Device ${widget.deviceName} not found.');
        // }
      } else {
        throw Exception('Failed to load device details');
      }
    } catch (e) {
      print('Error fetching device details: $e');
    }
  }

  List<List<dynamic>> _csvRows = [];
  String _lastWindDirection = "";
  String _lastBatteryPercentage = ""; // Default value

  Future<void> _fetchDataForRange(String range,
      [DateTime? selectedDate, double? latitude, double? longitude]) async {
    setState(() {
      _isLoading = true; // Start loading
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
      _weeklyPrecipitationData.clear();
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
      case '6months':
        startDate = endDate.subtract(Duration(days: 180)); // Roughly 6 months
        break;
      case 'single':
        startDate = _selectedDay; // Use the selected day as startDate
        endDate = startDate; // Single day means endDate is same as startDate
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
        } else {
          setState(() {
            temperatureData = _parseChartData(data, 'Temperature');
            humidityData = _parseChartData(data, 'Humidity');
            lightIntensityData = _parseChartData(data, 'LightIntensity');
            windSpeedData = _parseChartData(data, 'WindSpeed');
            // rainLevelData = _parseChartData(data, 'RainLevel');
            rainDifferenceData = _parseRainDifferenceData(data);
            solarIrradianceData = _parseChartData(data, 'SolarIrradiance');

            // Calculate the current rain difference (most recent data)
            // double currentRainDifference =
            //     _getCurrentRainDifference(data['rain_hourly_items']);

            // // Calculate total rain difference for the last 24 hours
            // double totalRainDifference24h =
            //     _calculateRainSumLast24Hours(data['rain_hourly_items']);

            // // Store the values in state variables
            // _currentRainDifference = currentRainDifference;
            // _totalRainDifference24h = totalRainDifference24h;
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
                  // windSpeedData[i].value,
                  // rainLevelData[i].value,
                  // Find the closest hourly rain difference data for each 15-min timestamp
                  // rainDifferenceData.isNotEmpty
                  //     ? rainDifferenceData
                  //         .lastWhere(
                  //           (rd) => rd.timestamp.isBefore(temperatureData[i]
                  //               .timestamp
                  //               .add(Duration(minutes: 15))),
                  //           orElse: () => ChartData(
                  //               timestamp: DateTime.now(), value: 0.0),
                  //         )
                  //         .value
                  //     : 0.0,
                  solarIrradianceData[i].value,
                  // if (widget.deviceName == 'WD211') precipitationProbability
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

  void downloadRainCSV(BuildContext context) async {
    if (_csvRainRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No rain data available for download.")),
      );
      return;
    }

    String csvData = const ListToCsvConverter().convert(_csvRainRows);
    String fileName = _generateRainFileName();

    if (kIsWeb) {
      final blob = html.Blob([csvData], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloading Rain Data"),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      try {
        if (io.Platform.isAndroid) {
          if (await Permission.storage.isGranted) {
            await saveCSVFile(csvData, fileName);
          } else if (await Permission.manageExternalStorage
              .request()
              .isGranted) {
            await saveCSVFile(csvData, fileName);
          } else if (await Permission
              .manageExternalStorage.isPermanentlyDenied) {
            await openAppSettings();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text("Please enable storage permission from settings")),
            );
          }
        } else {
          await saveCSVFile(csvData, fileName);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading rain data: $e")),
        );
      }
    }
  }

  String _generateRainFileName() {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'RainData_$timestamp.csv';
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

  // Future<void> _fetchRainForecastingData() async {
  //   try {
  //     final response = await http.get(Uri.parse(
  //         'https://w6dzlucugb.execute-api.us-east-1.amazonaws.com/default/CloudSense_rain_data_api?DeviceId=211'));

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       setState(() {
  //         _totalRainLast24Hours =
  //             data['TotalRainLast24Hours']?.toString() ?? '0.00 mm';
  //         _mostRecentHourRain =
  //             data['MostRecentHourRain']?.toString() ?? '0.00 mm';

  //         // Prepare CSV rows
  //         _csvRainRows = [
  //           ["Timestamp", "TotalRainLast24Hours", "MostRecentHourRain"],
  //           [
  //             DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
  //             _totalRainLast24Hours,
  //             _mostRecentHourRain
  //           ],
  //         ];
  //       });
  //     } else {
  //       throw Exception('Failed to load rain forecasting data');
  //     }
  //   } catch (e) {
  //     print('Error fetching rain forecasting data: $e');
  //   }
  // }

  Future<void> _showWeeklyPrecipitationProbability(
      double latitude, double longitude) async {
    try {
      final apiUrl =
          'https://api.tomorrow.io/v4/weather/forecast?location=$latitude,$longitude&apikey=VCusVsCI9zp6B89kZv5lxb8zDFI7mtoi';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final rainData = json.decode(response.body);

        // Extract weekly precipitation probabilities for 7 days
        List<Map<String, dynamic>> weeklyPrecipitation = [];
        for (int i = 0; i < 6; i++) {
          final dayData = rainData['timelines']['daily'][i];
          final date = dayData['time'];
          final precipitationProbability =
              dayData['values']['precipitationProbabilityAvg'] ?? 0.0;
          final rainIntensity = dayData['values']['rainIntensityAvg'] ?? 0.0;

          weeklyPrecipitation.add({
            'date': DateFormat('dd-MM-yyyy').format(DateTime.parse(date)),
            'precipitationProbabilityAvg': precipitationProbability,
            'rainIntensityAvg': rainIntensity,
          });
        }

        // Show the weekly precipitation data in a dialog
        showDialog(
          context: context,
          builder: (context) {
            double screenWidth = MediaQuery.of(context).size.width;
            double dialogWidth = screenWidth < 800 ? 300 : 400;
            double dialogHeight = screenWidth < 800 ? 350 : 350;

            return AlertDialog(
              title: Center(
                child: Text('Weekly Rain Forecasting'),
              ),

              content: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: dialogWidth,
                  height: dialogHeight,
                  child: DataTable(
                    columnSpacing: 20,
                    horizontalMargin: 10,
                    columns: [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Avg Rain\nIntensity')),
                      DataColumn(label: Text('Avg Rain\nProbability')),
                    ],
                    rows: weeklyPrecipitation.map((day) {
                      return DataRow(cells: [
                        DataCell(Text(day['date'])),
                        DataCell(Text('${day['rainIntensityAvg']}')),
                        DataCell(Text('${day['precipitationProbabilityAvg']}')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment
                  .spaceBetween, // Aligns actions to left and right
              actions: [
                // Left-aligned "Hourly Insights" button
                TextButton(
                  onPressed: () async {
                    await _showHourlyPrecipitationForWeek();
                  },
                  child: Text('Hourly Insights'),
                ),
                // Right-aligned "Close" button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching precipitation data: $e');
    }
  }

  Future<void> _showHourlyPrecipitationForWeek() async {
    try {
      final apiUrl =
          'https://api.tomorrow.io/v4/weather/forecast?location=$_latitude,$_longitude&apikey=VCusVsCI9zp6B89kZv5lxb8zDFI7mtoi';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final rainData = json.decode(response.body);

        // Organize hourly data for each day of the week
        Map<String, List<Map<String, dynamic>>> weeklyHourlyData = {};

        for (var entry in rainData['timelines']['hourly']) {
          final dateTime = DateTime.parse(entry['time']);
          final date = DateFormat('dd-MM-yyyy').format(dateTime);
          final hour = DateFormat('HH:mm').format(dateTime);

          // Create a new date entry if it doesn't exist
          if (!weeklyHourlyData.containsKey(date)) {
            weeklyHourlyData[date] = [];
          }

          // Add hourly data to the appropriate date
          weeklyHourlyData[date]?.add({
            'time': hour,
            'precipitationProbability':
                entry['values']['precipitationProbability'] ?? 0.0,
            'rainIntensity': entry['values']['rainIntensity'] ?? 0.0,
          });
        }
        // Show the hourly data in a new dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(
                child: Text('Hourly Rain Forecasting - Weekly Insights'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: weeklyHourlyData.keys.map((date) {
                    return ExpansionTile(
                      title: Text(date),
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 20,
                            horizontalMargin: 10,
                            columns: [
                              DataColumn(label: Text('Time')),
                              DataColumn(label: Text('Rain Intensity\n(mm/h)')),
                              DataColumn(label: Text('Rain Probability\n(%)')),
                            ],
                            rows: weeklyHourlyData[date]!.map((hour) {
                              return DataRow(cells: [
                                DataCell(Text(hour['time'])),
                                DataCell(Text('${hour['rainIntensity']}')),
                                DataCell(Text(
                                    '${hour['precipitationProbability']}')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to load hourly weather data');
      }
    } catch (e) {
      print('Error fetching hourly precipitation data: $e');
    }
  }

// Function to get the current location based on platform
  Future<void> _getUserCurrentLocation() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    // For web
    if (kIsWeb) {
      try {
        html.window.navigator.geolocation.getCurrentPosition().then((position) {
          final latitude = position.coords?.latitude;
          final longitude = position.coords?.longitude;

          setState(() {
            _latitude = latitude as double?;
            _longitude = longitude as double?;
            _isLoading = false; // Stop loading after fetching location
            _saveLocationToPrefs(); // Save location to SharedPreferences
          });
        }).catchError((e) {
          print("Error getting location: $e");
          setState(() {
            _isLoading = false; // Stop loading if there's an error
          });
        });
      } catch (e) {
        print("Error accessing geolocation: $e");
        setState(() {
          _isLoading = false; // Stop loading if an error occurs
        });
      }
    } else {
      // Mobile specific location fetching
      bool serviceEnabled;
      geolocator.LocationPermission permission;

      serviceEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        setState(() {
          _isLoading = false; // Stop loading if location services are disabled
        });
        return;
      }

      permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
        if (permission == geolocator.LocationPermission.denied) {
          print('Location permissions are denied');
          setState(() {
            _isLoading = false; // Stop loading
          });
          return;
        }
      }

      if (permission == geolocator.LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        setState(() {
          _isLoading = false; // Stop loading
        });
        return;
      }

      geolocator.Position position =
          await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoading = false; // Stop loading after fetching location
        _saveLocationToPrefs(); // Save location to SharedPreferences
      });
    }
  }

  // Save latitude and longitude to SharedPreferences
  Future<void> _saveLocationToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', _latitude ?? 0.0);
    prefs.setDouble('longitude', _longitude ?? 0.0);
  }

  // Load latitude and longitude from SharedPreferences
  Future<void> _loadLocationFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _latitude = prefs.getDouble('latitude');
      _longitude = prefs.getDouble('longitude');
    });
  }

  // Function to show the location input dialog
  Future<void> _showLocationInputDialog() async {
    TextEditingController latitudeController =
        TextEditingController(text: _latitude?.toString() ?? '');
    TextEditingController longitudeController =
        TextEditingController(text: _longitude?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show input fields for latitude and longitude
              TextField(
                controller: latitudeController,
                decoration: InputDecoration(
                  labelText: 'Latitude',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: longitudeController,
                decoration: InputDecoration(
                  labelText: 'Longitude',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Show the "Use Current Location" button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_isLoading) {
                          await _getUserCurrentLocation(); // Fetch current location
                          latitudeController.text = _latitude?.toString() ?? '';
                          longitudeController.text =
                              _longitude?.toString() ?? '';
                        }
                      },
                      child: _isLoading
                          ? CircularProgressIndicator() // Show loading while fetching
                          : Text('Use Current Location'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without action
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final latitude = double.tryParse(latitudeController.text);
                final longitude = double.tryParse(longitudeController.text);

                if (latitude != null && longitude != null) {
                  setState(() {
                    _latitude = latitude;
                    _longitude = longitude;
                  });

                  Navigator.of(context).pop();
                  await _saveLocationToPrefs(); // Save updated location to prefs
                  await _showWeeklyPrecipitationProbability(
                      _latitude!, _longitude!);
                } else {
                  print("Please enter valid coordinates.");
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
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
                  Navigator.of(context).pop(); // Close the dialog
                  downloadCSV(context); // Download for selected range
                },
                child: const Text('Download for Selected Range'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Trigger the download immediately
                  // downloadCSVWithCustomRange(context, startDate!, endDate!);
                  // Navigator.of(context)
                  //     .pop(); // Close the dialog after download

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

  Future<void> downloadCSVWithCustomRange(
      BuildContext context, DateTime startDate, DateTime endDate) async {
    // Filter _csvRows based on the selected date range
    List<List<dynamic>> filteredRows = _csvRows.where((row) {
      try {
        // print("Attempting to parse date: ${row[0]}"); // Debug print
        DateTime timestamp = DateTime.parse(
            row[0]); // Adjust this line if the format is different
        return timestamp.isAfter(startDate.subtract(Duration(days: 1))) &&
            timestamp.isBefore(endDate.add(Duration(days: 1)));
      } catch (e) {
        // print("Error parsing date: $e"); // Log parsing errors
        return false; // Exclude rows with invalid timestamps
      }
    }).toList();

    if (filteredRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No data available for the selected range.")),
      );
      return;
    }

    String csvData = const ListToCsvConverter().convert(filteredRows);
    String fileName = _generateFileName(); // Generate a dynamic filename

    // Same download logic as above
    if (kIsWeb) {
      final blob = html.Blob([csvData], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName) // Use the generated filename
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloading"), duration: Duration(seconds: 1)),
      );
    } else {
      try {
        // Check storage permission status
        if (io.Platform.isAndroid) {
          if (await Permission.storage.isGranted) {
            await saveCSVFile(csvData, fileName);
          } else {
            if (await Permission.manageExternalStorage.request().isGranted) {
              await saveCSVFile(csvData, fileName);
            } else if (await Permission
                .manageExternalStorage.isPermanentlyDenied) {
              await openAppSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text("Please enable storage permission from settings")),
              );
            }
          }
        } else {
          await saveCSVFile(csvData, fileName);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error downloading: $e")),
        );
      }
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

  // List<ChartData> _parseChartData(Map<String, dynamic> data, String type) {
  //   final List<dynamic> items = data['weather_items'] ?? [];
  //   return items.map((item) {
  //     if (item == null) {
  //       return ChartData(
  //           timestamp: DateTime.now(), value: 0.0); // Provide default value
  //     }
  //     return ChartData(
  //       timestamp: _parseDate(item['HumanTime']),
  //       value: item[type] != null
  //           ? double.tryParse(item[type].toString()) ?? 0.0
  //           : 0.0,
  //     );
  //   }).toList();
  // }
  List<ChartData> _parseChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['weather_items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(
            timestamp: DateTime.now(), value: 0.0); // Provide default value
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

  List<ChartData> _parsewindChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(
            timestamp: DateTime.now(), value: 0.0); // Provide default value
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
        return ChartData(
            timestamp: DateTime.now(), value: 0.0); // Provide default value
      }
      return ChartData(
        timestamp: _parsedoDate(item['HumanTime']),
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
                    'Current Value',
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
                  columnSpacing: 4,
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
                    // DataColumn(
                    //   label: Text(
                    //     'Current Value',
                    //     style: TextStyle(
                    //         fontSize: headerFontSize,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.blue),
                    //   ),
                    // ),
                    DataColumn(
                      label: Padding(
                        padding: EdgeInsets.only(
                            right: 20), // Adjust the value as needed
                        child: Text(
                          'Current Value',
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
    double headerFontSize = screenWidth < 800 ? 16 : 22;

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
              columnSpacing: 36,
              columns: [
                DataColumn(
                  label: Text(
                    'Timeframe',
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Value',
                    style: TextStyle(
                        fontSize: fontSize,
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
      lastDate: DateTime(2025),
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
                  fontSize: MediaQuery.of(context).size.width < 800 ? 18 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                if (widget.deviceName
                    .startsWith('WD')) // Check if it's a WD sensor

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

                              if (widget.deviceName == 'WD311')
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4.0,
                                  ), // Spacing between elements
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .end, // Aligns the text to the right
                                    children: [
                                      SizedBox(
                                          width:
                                              10), // Adds some space between text and button
                                      ElevatedButton(
                                        onPressed: () async {
                                          // Call a function to show the input dialog for latitude and longitude
                                          await _showLocationInputDialog();
                                        },
                                        child: Text('Weekly Forecast'),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: const Color.fromARGB(
                                              255, 40, 41, 41), // Text color
                                        ),
                                      ),
                                    ],
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
                        ],
                      ),
                    ),
                    if (widget.deviceName.startsWith('WQ'))
                      buildStatisticsTable(),
                    if (widget.deviceName.startsWith('DO'))
                      buildDOStatisticsTable(),
                    if (widget.deviceName.startsWith('WD211'))
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

  // // Method to get color based on the battery percentage
  // Color _getBatteryIconColor(int batteryPercentage) {
  //   if (batteryPercentage < 20) {
  //     return Colors.red; // Color for battery < 20%
  //   } else {
  //     return Colors.white; // Default color
  //   }
  // }

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
                        duration:
                            4000, // Tooltip will remain for 4 seconds (4000 milliseconds)
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
                      // tooltipBehavior: _tooltipBehavior,
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
