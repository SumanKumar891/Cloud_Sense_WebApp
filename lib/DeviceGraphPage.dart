import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'dart:html' as html;
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
  bool _isHovering = false; // Track hover state
  String _selectedRange = 'none'; // Tracks which button is selected
  void _onRangeSelected(String range) {
    setState(() {
      _selectedRange = range;
      _fetchDataForRange(range); // Fetch data based on the selected range
    });
  }

  String _currentChlorineValue = '0.00';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDeviceDetails();
    // fetchData();
    _fetchDataForRange('single');
  }

  bool _showCurrentData = false; // To toggle current data visibility

  Future<void> _fetchDeviceDetails() async {
    try {
      final response = await http.get(Uri.parse(
          // 'https://c27wvohcuc.execute-api.us-east-1.amazonaws.com/default/beehive_activity_api'
          'https://xa9ry8sls0.execute-api.us-east-1.amazonaws.com/CloudSense_device_activity_api_function'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  // Future<void> fetchData() async {
  //   final startdate = _formatDate(_selectedDay);
  //   final enddate = startdate;
  //   final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
  //   int deviceId =
  //       int.parse(widget.deviceName.replaceAll(RegExp(r'[^0-9]'), ''));

  //   setState(() {
  //     _selectedDeviceId = deviceId; // Set the selected device ID
  //   });

  Future<void> _fetchDataForRange(String range) async {
    setState(() {
      _isLoading = true; // Start loading
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
    } else {
      setState(() {
        _message = "Unknown device type";
      });
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
      //   } catch (e) {
      //     setState(() {
      //       _message = 'Error fetching data: $e';
      //     });
      //   }
      // }
    } catch (e) {
      setState(() {
        _message = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
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

    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
        chlorineData.clear();
        _fetchDataForRange('single'); // Fetch data for the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the background image based on the device type
    String backgroundImagePath = widget.deviceName.startsWith('WD')
        ? 'assets/tree.jpg'
        : 'assets/Chloritronn.png';
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
                  fontSize: 32,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Text(
                                  //   'Device ID: ${widget.sequentialName}',
                                  //   style: TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //     fontSize:
                                  //         MediaQuery.of(context).size.width *
                                  //             0.013,
                                  //     color: Colors.white,
                                  //   ),
                                  // ),
                                  Text(
                                    'Status: $_currentStatus',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.011,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Text(
                                  //   'Received: $_dataReceivedTime',
                                  //   style: TextStyle(
                                  //     fontWeight: FontWeight.bold,
                                  //     fontSize:
                                  //         MediaQuery.of(context).size.width *
                                  //             0.013,
                                  //     color: Colors.white,
                                  //   ),
                                  // ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      20), // Space between status and buttons
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0),
                                    color: const Color.fromARGB(150, 0, 0, 0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Space out buttons evenly
                                    children: [
                                      // Date Picker button
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            _selectDate(); // Your date picker function
                                            setState(() {
                                              _selectedRange =
                                                  'date'; // Mark this button as selected
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors
                                                .transparent, // Make button background transparent
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 36, vertical: 28),
                                            side: _selectedRange == 'date'
                                                ? BorderSide(
                                                    color: Colors.white,
                                                    width:
                                                        2) // Show border if selected
                                                : BorderSide
                                                    .none, // No border if not selected
                                          ),
                                          child: Text(
                                            'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _selectedRange == 'date'
                                                  ? Colors.blue
                                                  : Colors
                                                      .white, // Change text color based on selection
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 8), // Space between buttons
                                      // 7 Days button
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            _fetchDataForRange(
                                                '7days'); // Your data fetching function
                                            setState(() {
                                              _selectedRange =
                                                  '7days'; // Mark this button as selected
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors
                                                .transparent, // Background color
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 36, vertical: 28),
                                            side: _selectedRange == '7days'
                                                ? BorderSide(
                                                    color: Colors.white,
                                                    width:
                                                        2) // Show border if selected
                                                : BorderSide
                                                    .none, // No border if not selected
                                          ),
                                          child: Text(
                                            'Last 7 Days',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _selectedRange == '7days'
                                                  ? Colors.blue
                                                  : Colors
                                                      .white, // Change text color based on selection
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 8), // Space between buttons
                                      // 30 Days button
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            _fetchDataForRange(
                                                '30days'); // Fetch data for 30 days range
                                            setState(() {
                                              _selectedRange =
                                                  '30days'; // Mark this button as selected
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 36, vertical: 28),
                                            side: _selectedRange == '30days'
                                                ? BorderSide(
                                                    color: Colors.white,
                                                    width: 2)
                                                : BorderSide.none,
                                          ),
                                          child: Text(
                                            'Last 30 Days',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _selectedRange == '30days'
                                                  ? Colors.blue
                                                  : Colors
                                                      .white, // Change text color based on selection
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
                                                '3months'); // Your data fetching function
                                            setState(() {
                                              _selectedRange =
                                                  '3months'; // Mark this button as selected
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors
                                                .transparent, // Background color
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 36, vertical: 28),
                                            side: _selectedRange == '3months'
                                                ? BorderSide(
                                                    color: Colors.white,
                                                    width:
                                                        2) // Show border if selected
                                                : BorderSide
                                                    .none, // No border if not selected
                                          ),
                                          child: Text(
                                            'Last 3 months',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _selectedRange == '3months'
                                                  ? Colors.blue
                                                  : Colors
                                                      .white, // Change text color based on selection
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(
                                  height:
                                      0), // Space between buttons and the next section
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
                    //           SizedBox(height: 10),
                    //           Text(
                    //             _message,
                    //             style: TextStyle(color: Colors.red),
                    //           ),
                    //           _buildChartContainer('Chlorine', chlorineData,
                    //               'chlorine (mg/L)', ChartType.line),
                    //           _buildChartContainer('Temperature', temperatureData,
                    //               'Temperature (°C)', ChartType.line),
                    //           _buildChartContainer('Humidity', humidityData,
                    //               'Humidity (%)', ChartType.line),
                    //           _buildChartContainer('Light Intensity', lightIntensityData,
                    //               'Light Intensity (Lux)', ChartType.line),
                    //           _buildChartContainer('Wind Speed', windSpeedData,
                    //               'Wind Speed (m/s)', ChartType.line),
                    //           _buildChartContainer('Rain Intensity', rainIntensityData,
                    //               'Rain Intensity (mm/h)', ChartType.line),
                    //           _buildChartContainer(
                    //               'Solar Irradiance',
                    //               solarIrradianceData,
                    //               'Solar Irradiance (W/M^2)',
                    //               ChartType.line),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Current values display section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildCurrentValue(
                              'Chlorine Level', _currentChlorineValue, 'mg/L'),
                          // _buildCurrentValue('Temperature', _currentTemperature, '°C'),
                          // _buildCurrentValue('Humidity', _currentHumidity, '%'),
                          // _buildCurrentValue('Light Intensity', _currentLightIntensity, 'Lux'),
                          // _buildCurrentValue('Wind Speed', _currentWindSpeed, 'm/s'),
                          // _buildCurrentValue('Rain Intensity', _currentRainIntensity, 'mm/h'),
                          // _buildCurrentValue('Solar Irradiance', _currentSolarIrradiance, 'W/M^2'),
                        ],
                      ),
                    ),

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
                onPressed: downloadCSV,
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
              height: MediaQuery.of(context).size.width < 800 ? 300 : 400,
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
                        interval: 30,
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
            height: 6.0,
            width: 6.0,
            // color: Colors.red,
            // borderColor: Colors.red,
            isVisible: true,
          ),
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: title,
          color: Colors.blue,
          // Set marker colors based on the value
          pointColorMapper: (ChartData data, _) {
            if (data.value >= 0.01 && data.value <= 0.5) {
              return Colors.green; // Green for values between 0.01 and 1
            } else if (data.value > 0.5 && data.value <= 1.0) {
              return Colors.yellow; // Yellow for values between 1.1 and 2
            } else if (data.value > 1.0 && data.value <= 4.0) {
              return Colors.orange; // Red for values between 2.1 and 5
            } else if (data.value > 4.0) {
              return Colors.red; // Red for values between 2.1 and 5
            }
            return Colors.white; // Default color (if needed)
          },
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
