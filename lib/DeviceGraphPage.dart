import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:cloud_sense_webapp/downloadcsv.dart';
import 'package:cloud_sense_webapp/weatherforecasting.dart';
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
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// Updated CompassNeedlePainter with corrected arrowhead positioning
class CompassNeedlePainter extends CustomPainter {
  CompassNeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Define the needle length (60% of radius as per your code)
    final needleLength = radius * 0.4;

    // Paint for the red tip (pointing to wind direction, initially pointing up/North)
    final redPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Paint for the white tail (opposite direction)
    final whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Paint for the red arrowhead (filled triangle)
    final arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw the red tip (from center to North, will be rotated by Transform.rotate)
    final tipX = center.dx;
    final tipY = center.dy - needleLength; // Pointing up (North)
    canvas.drawLine(center, Offset(tipX, tipY), redPaint);

    // Draw the white tail (from center to South)
    final tailX = center.dx;
    final tailY = center.dy + needleLength; // Pointing down (South)
    canvas.drawLine(center, Offset(tailX, tailY), whitePaint);

    // Draw the arrowhead at the tip of the red line
    final arrowSize = 8.0; // Width of the arrowhead base
    final arrowHeight = 10.0; // Height of the arrowhead (from base to tip)
    final arrowPath = Path();
    // The base of the arrowhead is at the end of the red line (tipX, tipY)
    // Calculate the two base points perpendicular to the needle direction
    // Since the needle points up (North) initially, the direction is along the negative Y-axis
    // Perpendicular direction is along the X-axis (left and right)
    final baseLeft = Offset(tipX - arrowSize / 2, tipY); // Left base point
    final baseRight = Offset(tipX + arrowSize / 2, tipY); // Right base point
    // The tip of the arrowhead extends further in the direction of the red line (upward)
    final arrowTip = Offset(
        tipX, tipY - arrowHeight); // Tip of the arrowhead (further North)
    arrowPath.moveTo(arrowTip.dx, arrowTip.dy); // Tip of the arrow
    arrowPath.lineTo(baseLeft.dx, baseLeft.dy); // Left base
    arrowPath.lineTo(baseRight.dx, baseRight.dy); // Right base
    arrowPath.close(); // Close the triangle
    canvas.drawPath(arrowPath, arrowPaint);

    // Draw a small circle at the center to cover the intersection
    final centerPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CompassBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, gradientPaint);

    final innerCirclePaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.8, innerCirclePaint);

    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    final tickLength = 8.0;
    for (int i = 0; i < 360; i += 30) {
      final angle = i * math.pi / 180;
      final startX = center.dx + (radius - tickLength) * math.sin(angle);
      final startY = center.dy - (radius - tickLength) * math.cos(angle);
      final endX = center.dx + radius * math.sin(angle);
      final endY = center.dy - radius * math.cos(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
  // Mobile menu button builder
  Widget _buildMobileMenuButton(
    String title,
    String value,
    IconData icon,
    bool isDarkMode,
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    bool isActive = _activeButton == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10), // smaller height
          backgroundColor: isActive
              ? (isDarkMode ? Colors.blue[700] : Colors.blue[600])
              : (isDarkMode ? Colors.grey[850] : Colors.grey[200]),
          foregroundColor: isActive
              ? Colors.white
              : (isDarkMode ? Colors.white70 : Colors.black87),
          elevation: isActive ? 3 : 0,
          minimumSize: const Size(0, 40), // compact height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isActive) const Icon(Icons.check_circle, size: 18),
          ],
        ),
      ),
    );
  }

  // Build the drawer widget
  Widget _buildDrawer(bool isDarkMode, BuildContext context) {
    return Drawer(
      child: Container(
        color: isDarkMode
            ? Colors.blueGrey[900]
            : Colors.grey[200], // Entire background
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[200] : Colors.blueGrey[900],
              ),
              child: Text(
                'Select Time Period',
                style: TextStyle(
                    color: isDarkMode ? Colors.black : Colors.white,
                    fontSize: 20),
              ),
            ),
            _buildMobileMenuButton(
              '1 Day',
              'date',
              Icons.today,
              isDarkMode,
              context,
              onPressed: () async {
                await _selectDate(); // same as sidebar button
                setState(() => _activeButton = 'date');
                Navigator.pop(context); // close drawer
              },
            ),
            _buildMobileMenuButton(
              'Last 7 Days',
              '7days',
              Icons.calendar_view_week,
              isDarkMode,
              context,
              onPressed: () {
                _fetchDataForRange('7days');
                setState(() => _activeButton = '7days');
                Navigator.pop(context);
              },
            ),
            _buildMobileMenuButton(
              'Last 30 Days',
              '30days',
              Icons.calendar_view_month,
              isDarkMode,
              context,
              onPressed: () {
                _fetchDataForRange('30days');
                setState(() => _activeButton = '30days');
                Navigator.pop(context);
              },
            ),
            _buildMobileMenuButton(
              'Last 3 Months',
              '3months',
              Icons.calendar_today,
              isDarkMode,
              context,
              onPressed: () {
                _fetchDataForRange('3months');
                setState(() => _activeButton = '3months');
                Navigator.pop(context);
              },
            ),
            _buildMobileMenuButton(
              'Last 1 Year',
              '1year',
              Icons.date_range,
              isDarkMode,
              context,
              onPressed: () {
                _fetchDataForRange('1year');
                setState(() => _activeButton = '1year');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

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
  List<ChartData> rfdData = [];
  List<ChartData> rfsData = [];
  List<ChartData> ittempData = [];
  List<ChartData> itpressureData = [];
  List<ChartData> ithumidityData = [];
  List<ChartData> itradiationData = [];
  List<ChartData> itwindspeedData = [];
  List<ChartData> itvisibilityData = [];
  List<ChartData> itrainData = [];
  List<ChartData> itwinddirectionData = [];
  List<ChartData> fstempData = [];
  List<ChartData> fspressureData = [];
  List<ChartData> fshumidityData = [];
  List<ChartData> fsradiationData = [];
  List<ChartData> fswindspeedData = [];
  List<ChartData> smwindspeedData = [];
  List<ChartData> smWindDirectionData = [];
  List<ChartData> smAtmPressureData = [];
  List<ChartData> smLightIntensityData = [];
  List<ChartData> smRainfallWeeklyData = [];
  List<ChartData> smMaximumTemperatureData = [];
  List<ChartData> smRainfallDailyData = [];
  List<ChartData> smAverageHumidityData = [];
  List<ChartData> smBatteryVoltageData = [];
  List<ChartData> smAverageTemperatureData = [];
  List<ChartData> smMaximumHumidityData = [];
  List<ChartData> smMinimumTemperatureData = [];
  List<ChartData> smMinimumHumidityData = [];
  List<ChartData> smCurrentHumidityData = [];
  List<ChartData> smRainfallHourlyData = [];
  List<ChartData> smIMEINumberData = [];
  List<ChartData> smRainfallMinutlyData = [];
  List<ChartData> smCurrentTemperatureData = [];
  List<ChartData> smSignalStrength = [];
  Map<String, List<ChartData>> smParametersData = {};
  Map<String, List<ChartData>> cfParametersData = {};
  Map<String, List<ChartData>> svParametersData = {};
  Map<String, List<ChartData>> kdParametersData = {};
  Map<String, List<ChartData>> vdParametersData = {};
  Map<String, List<ChartData>> NARLParametersData = {};
  Map<String, List<ChartData>> csParametersData = {};
  List<ChartData> cod2Data = [];
  List<ChartData> bod2Data = [];
  List<ChartData> temp2Data = [];
  final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
  List<ChartData> wfAverageTemperatureData = [];
  List<ChartData> wfrainfallData = [];
  List<ChartData> fsrainData = [];
  List<ChartData> fswinddirectionData = [];
  Timer? _reloadTimer;
  double? _fsDailyRainBaseline;
  String? _fsLastRainDate;

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
  String _currentrfdValue = '0.00';
  String _currentAmmoniaValue = '0.00';
  bool _isLoading = false;
  String _lastSelectedRange = 'single'; // Default to single
  bool isWindDirectionValid(String? windDirection) {
    return windDirection != null && windDirection != "-";
  }

  bool iswinddirectionValid(String? direction) {
    if (direction == null || direction.isEmpty) {
      return false;
    }
    try {
      double value = double.parse(direction);
      bool isValid = value >= 0 && value <= 360;

      return isValid;
    } catch (e) {
      return false;
    }
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
    _initializeNotifications();

    // Set up the periodic timer to reload data every 30 seconds
    _reloadTimer = Timer.periodic(Duration(seconds: 120), (timer) {
      _reloadData();
    });
  }

  @override
  void dispose() {
    // Cancel the timer to prevent memory leaks
    _reloadTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
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
  String _lastwinddirection = "";
  // String _lastfswinddirection = "";
  String _lastBatteryPercentage = "";
  double _lastfsBattery = 0.0;
  double _lastsmBattery = 0.0;
  double _lastcfBattery = 0.0;
  double _lastvdBattery = 0.0;
  double _lastkdBattery = 0.0;
  double _lastNARLBattery = 0.0;
  double _lastcsBattery = 0.0;
  double _lastsvBattery = 0.0;
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
      temperaturedata.clear();
      humiditydata.clear();
      ittempData.clear();
      itpressureData.clear();
      ithumidityData.clear();
      itradiationData.clear();
      itvisibilityData.clear();
      itrainData.clear();
      itwinddirectionData.clear();
      itwindspeedData.clear();
      fshumidityData.clear();
      fspressureData.clear();
      fsradiationData.clear();
      fsrainData.clear();
      fstempData.clear();
      fswinddirectionData.clear();
      _lastfsBattery = 0.0;
      _lastsmBattery = 0.0;
      _lastcfBattery = 0.0;
      _lastvdBattery = 0.0;
      _lastkdBattery = 0.0;
      _lastNARLBattery = 0.0;

      _lastcsBattery = 0.0;
      _lastsvBattery = 0.0;

      fswindspeedData.clear();

      smParametersData.clear();
      cfParametersData.clear();
      svParametersData.clear();
      vdParametersData.clear();
      wfAverageTemperatureData.clear();
      wfrainfallData.clear();
      kdParametersData.clear();

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
      case '1year':
        startDate = endDate.subtract(Duration(days: 365));
        break;
      case 'single':
        startDate = _selectedDay; // Use the selected day as startDate
        endDate = startDate;

        // Single day means endDate is same as startDate
        break;
      default:
        startDate = endDate; // Default to today
    }

    _lastSelectedRange = range; // Store the currently selected range

    // Format dates for most APIs (DD-MM-YYYY)
    final dateFormatter = DateFormat('dd-MM-yyyy');
    final startdate = dateFormatter.format(startDate);
    final enddate = dateFormatter.format(endDate);

    // Format dates for SM sensor API (YYYYMMDD)
    final smDateFormatter = DateFormat('yyyyMMdd');
    final smStartDate = smDateFormatter.format(startDate);
    final smEndDate = smDateFormatter.format(endDate);

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
    if (widget.deviceName.startsWith('SM')) {
      apiUrl =
          'https://n42fiw7l89.execute-api.us-east-1.amazonaws.com/default/SSMet_API_Func?device_id=$deviceId&start_date=$smStartDate&end_date=$smEndDate';
    } else if (widget.deviceName.startsWith('CF')) {
      apiUrl =
          'https://gtk47vexob.execute-api.us-east-1.amazonaws.com/colonelfarmdata?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('VD')) {
      apiUrl =
          'https://gtk47vexob.execute-api.us-east-1.amazonaws.com/vanixdata?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('SV')) {
      apiUrl =
          'https://gtk47vexob.execute-api.us-east-1.amazonaws.com/svpudata?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('KD')) {
      apiUrl =
          'https://gtk47vexob.execute-api.us-east-1.amazonaws.com/kargildata?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('NA')) {
      apiUrl =
          'https://gtk47vexob.execute-api.us-east-1.amazonaws.com/ssmetnarldata?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('CP')) {
      apiUrl =
          'https://gtk47vexob.execute-api.us-east-1.amazonaws.com/campusdata?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('WD')) {
      apiUrl =
          'https://62f4ihe2lf.execute-api.us-east-1.amazonaws.com/CloudSense_Weather_data_api_function?DeviceId=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('CL') ||
        (widget.deviceName.startsWith('BD'))) {
      apiUrl =
          'https://b0e4z6nczh.execute-api.us-east-1.amazonaws.com/CloudSense_Chloritrone_api_function?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('WQ')) {
      apiUrl =
          'https://oy7qhc1me7.execute-api.us-west-2.amazonaws.com/default/k_wqm_api?deviceid=${widget.deviceName}&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('WF')) {
      apiUrl =
          'https://wf3uh3yhn7.execute-api.us-east-1.amazonaws.com/default/Awadh_Jio_Data_Api_func?Device_ID=$deviceId&start_date=$startdate&end_date=$enddate';
    } else if (widget.deviceName.startsWith('IT')) {
      apiUrl =
          'https://7a3bcew3y2.execute-api.us-east-1.amazonaws.com/default/IIT_Bombay_API_func?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('WS')) {
      apiUrl =
          'https://xjbnnqcup4.execute-api.us-east-1.amazonaws.com/default/CloudSense_Water_quality_api_function?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('CB')) {
      apiUrl =
          'https://a9z5vrfpkd.execute-api.us-east-1.amazonaws.com/default/CloudSense_BOD_COD_Api_func?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
    } else if (widget.deviceName.startsWith('FS')) {
      apiUrl =
          'https://w7w21t8s23.execute-api.us-east-1.amazonaws.com/default/SSMet_Forest_API_func?deviceid=$deviceId&startdate=$startdate&enddate=$enddate';
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
    } else if (widget.deviceName.startsWith('20')) {
      apiUrl =
          'https://gzdsa7h08k.execute-api.us-east-1.amazonaws.com/default/lat_long_api_func?deviceId=$deviceId';

      try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
        } else {
          print("Failed to fetch data. Status Code: ${response.statusCode}");
        }
      } catch (e) {
        print("Error during API call: $e");
      }
    } else {
      setState(() {}); // Not sure if needed here
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
        String lastwinddirection;
        String lastBatteryPercentage = 'Unknown';
        String lastRSSI_Value = 'Unknown';

        if (widget.deviceName.startsWith('SM')) {
          setState(() {
            smParametersData.clear();
            smParametersData = _parseSMParametersData(data);

            if (smParametersData.isEmpty) {
              _csvRows = [
                ['Timestamp', 'Message'],
                ['', 'No data available']
              ];
            } else {
              List<String> headers = ['Timestamp'];
              headers.addAll(smParametersData.keys);

              List<List<dynamic>> dataRows = [];
              int maxLength = smParametersData.values
                  .map((list) => list.length)
                  .reduce((a, b) => a > b ? a : b);

              for (int i = 0; i < maxLength; i++) {
                List<dynamic> row = [
                  smParametersData.values.isNotEmpty &&
                          smParametersData.values.first.length > i
                      ? formatter
                          .format(smParametersData.values.first[i].timestamp)
                      : ''
                ];
                for (var key in smParametersData.keys) {
                  var value = smParametersData[key]!.length > i
                      ? smParametersData[key]![i].value
                      : null;
                  // ✅ Preserve 0, replace null with empty string
                  row.add(value ?? '');
                }
                dataRows.add(row);
              }

              _csvRows = [headers, ...dataRows];
            }

            // Clear unrelated data
            temperatureData = [];
            humidityData = [];
            // etc...
          });

          // // ✅ Now trigger download
          // downloadCSV(context);
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('CF')) {
          setState(() {
            cfParametersData.clear();
            cfParametersData = _parseCFParametersData(data);

            if (cfParametersData.isEmpty) {
              _csvRows = [
                ['Timestamp', 'Message'],
                ['', 'No data available']
              ];
            } else {
              List<String> headers = ['Timestamp'];
              headers.addAll(cfParametersData.keys);

              List<List<dynamic>> dataRows = [];
              int maxLength = cfParametersData.values
                  .map((list) => list.length)
                  .reduce((a, b) => a > b ? a : b);

              for (int i = 0; i < maxLength; i++) {
                List<dynamic> row = [
                  cfParametersData.values.isNotEmpty &&
                          cfParametersData.values.first.length > i
                      ? formatter
                          .format(cfParametersData.values.first[i].timestamp)
                      : ''
                ];
                for (var key in cfParametersData.keys) {
                  var value = cfParametersData[key]!.length > i
                      ? cfParametersData[key]![i].value
                      : null;
                  // ✅ Preserve 0, replace null with empty string
                  row.add(value ?? '');
                }
                dataRows.add(row);
              }

              _csvRows = [headers, ...dataRows];
            }

            // Clear unrelated data
            temperatureData = [];
            humidityData = [];
          });

          // // ✅ Now trigger download
          // downloadCSV(context);
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('VD')) {
          setState(() {
            vdParametersData.clear();
            vdParametersData = _parseVDParametersData(data);

            if (vdParametersData.isEmpty) {
              _csvRows = [
                ['Timestamp', 'Message'],
                ['', 'No data available']
              ];
            } else {
              List<String> headers = ['Timestamp'];
              headers.addAll(vdParametersData.keys);

              List<List<dynamic>> dataRows = [];
              int maxLength = vdParametersData.values
                  .map((list) => list.length)
                  .reduce((a, b) => a > b ? a : b);

              for (int i = 0; i < maxLength; i++) {
                List<dynamic> row = [
                  vdParametersData.values.isNotEmpty &&
                          vdParametersData.values.first.length > i
                      ? formatter
                          .format(vdParametersData.values.first[i].timestamp)
                      : ''
                ];
                for (var key in vdParametersData.keys) {
                  var value = vdParametersData[key]!.length > i
                      ? vdParametersData[key]![i].value
                      : null;
                  // ✅ Preserve 0, replace null with empty string
                  row.add(value ?? '');
                }
                dataRows.add(row);
              }

              _csvRows = [headers, ...dataRows];
            }

            // Clear unrelated data
            temperatureData = [];
            humidityData = [];
          });

          // // ✅ Now trigger download
          // downloadCSV(context);
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('SV')) {
          setState(() {
            svParametersData.clear();
            svParametersData = _parseSVParametersData(data);

            if (svParametersData.isEmpty) {
              _csvRows = [
                ['Timestamp', 'Message'],
                ['', 'No data available']
              ];
            } else {
              List<String> headers = ['Timestamp'];
              headers.addAll(svParametersData.keys);

              List<List<dynamic>> dataRows = [];
              int maxLength = svParametersData.values
                  .map((list) => list.length)
                  .reduce((a, b) => a > b ? a : b);

              for (int i = 0; i < maxLength; i++) {
                List<dynamic> row = [
                  svParametersData.values.isNotEmpty &&
                          svParametersData.values.first.length > i
                      ? formatter
                          .format(svParametersData.values.first[i].timestamp)
                      : ''
                ];
                for (var key in svParametersData.keys) {
                  var value = svParametersData[key]!.length > i
                      ? svParametersData[key]![i].value
                      : null;
                  // ✅ Preserve 0, replace null with empty string
                  row.add(value ?? '');
                }
                dataRows.add(row);
              }

              _csvRows = [headers, ...dataRows];
            }

            // Clear unrelated data
            temperatureData = [];
            humidityData = [];
            // etc...
          });

          // // ✅ Now trigger download
          // downloadCSV(context);
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('KD')) {
          setState(() {
            kdParametersData.clear();
            kdParametersData = _parseKDParametersData(data);

            if (kdParametersData.isEmpty) {
              _csvRows = [
                ['Timestamp', 'Message'],
                ['', 'No data available']
              ];
            } else {
              List<String> headers = ['Timestamp'];
              headers.addAll(kdParametersData.keys);

              List<List<dynamic>> dataRows = [];
              int maxLength = kdParametersData.values
                  .map((list) => list.length)
                  .reduce((a, b) => a > b ? a : b);

              for (int i = 0; i < maxLength; i++) {
                List<dynamic> row = [
                  kdParametersData.values.isNotEmpty &&
                          kdParametersData.values.first.length > i
                      ? formatter
                          .format(kdParametersData.values.first[i].timestamp)
                      : ''
                ];
                for (var key in kdParametersData.keys) {
                  var value = kdParametersData[key]!.length > i
                      ? kdParametersData[key]![i].value
                      : null;
                  // ✅ Preserve 0, replace null with empty string
                  row.add(value ?? '');
                }
                dataRows.add(row);
              }

              _csvRows = [headers, ...dataRows];
            }

            // Clear unrelated data
            temperatureData = [];
            humidityData = [];
          });

          // // ✅ Now trigger download
          // downloadCSV(context);
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('NA')) {
          setState(() {
            NARLParametersData.clear();
            NARLParametersData = _parseNARLParametersData(data);

            if (NARLParametersData.isEmpty) {
              _csvRows = [
                ['Timestamp', 'Message'],
                ['', 'No data available']
              ];
            } else {
              List<String> headers = ['Timestamp'];
              headers.addAll(NARLParametersData.keys);

              List<List<dynamic>> dataRows = [];
              int maxLength = NARLParametersData.values
                  .map((list) => list.length)
                  .reduce((a, b) => a > b ? a : b);

              for (int i = 0; i < maxLength; i++) {
                List<dynamic> row = [
                  NARLParametersData.values.isNotEmpty &&
                          NARLParametersData.values.first.length > i
                      ? formatter
                          .format(NARLParametersData.values.first[i].timestamp)
                      : ''
                ];
                for (var key in NARLParametersData.keys) {
                  var value = NARLParametersData[key]!.length > i
                      ? NARLParametersData[key]![i].value
                      : null;
                  // ✅ Preserve 0, replace null with empty string
                  row.add(value ?? '');
                }
                dataRows.add(row);
              }

              _csvRows = [headers, ...dataRows];
            }

            // Clear unrelated data
            temperatureData = [];
            humidityData = [];
          });

          // // ✅ Now trigger download
          // downloadCSV(context);
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('CP')) {
          setState(() {
            csParametersData.clear();
            csParametersData = _parsecsParametersData(data);

            if (csParametersData.isEmpty) {
              _csvRows = [
                ['Timestamp', 'Message'],
                ['', 'No data available']
              ];
            } else {
              List<String> headers = ['Timestamp'];
              headers.addAll(csParametersData.keys);

              List<List<dynamic>> dataRows = [];
              int maxLength = csParametersData.values
                  .map((list) => list.length)
                  .reduce((a, b) => a > b ? a : b);

              for (int i = 0; i < maxLength; i++) {
                List<dynamic> row = [
                  csParametersData.values.isNotEmpty &&
                          csParametersData.values.first.length > i
                      ? formatter
                          .format(csParametersData.values.first[i].timestamp)
                      : ''
                ];
                for (var key in csParametersData.keys) {
                  var value = csParametersData[key]!.length > i
                      ? csParametersData[key]![i].value
                      : null;
                  // ✅ Preserve 0, replace null with empty string
                  row.add(value ?? '');
                }
                dataRows.add(row);
              }

              _csvRows = [headers, ...dataRows];
            }

            // Clear unrelated data
            temperatureData = [];
            humidityData = [];
          });

          // // ✅ Now trigger download
          // downloadCSV(context);
          await _fetchDeviceDetails();
        }

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
        } else if (widget.deviceName.startsWith('CB')) {
          setState(() {
            temp2Data = _parseCBChartData(data, 'temperature');

            cod2Data = _parseCBChartData(data, 'COD');
            bod2Data = _parseCBChartData(data, 'BOD');

            rows = [
              [
                "Timestamp",
                "temperature",
                "COD",
                "BOD",
              ],
              for (int i = 0; i < temp2Data.length; i++)
                [
                  formatter.format(temp2Data[i].timestamp),
                  temp2Data[i].value,
                  cod2Data[i].value,
                  bod2Data[i].value,
                ]
            ];
          });
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('IT')) {
          setState(() {
            ittempData = _parseITChartData(data, 'temperature');
            itpressureData = _parseITChartData(data, 'pressure');
            ithumidityData = _parseITChartData(data, 'humidity');
            itradiationData = _parseITChartData(data, 'radiation');
            itrainData = _parseITChartData(data, 'rain_level');
            itvisibilityData = _parseITChartData(data, 'visibility');
            itwinddirectionData = _parseITChartData(data, 'wind_direction');
            itwindspeedData = _parseITChartData(data, 'wind_speed');
            temperatureData = [];
            humidityData = [];
            lightIntensityData = [];
            windSpeedData = [];
            rainLevelData = [];
            solarIrradianceData = [];
            chlorineData = [];

            // Assign _lastWindDirection from the latest item
            if (data.containsKey('items') &&
                data['items'] is List &&
                data['items'].isNotEmpty) {
              var lastItem = data['items'].last;

              _lastwinddirection =
                  lastItem['wind_direction']?.toString() ?? '0';
            } else {
              _lastwinddirection = '0';
            }
            rows = [
              [
                "Timestamp",
                "Temperature",
                "Pressure ",
                "Humidity",
                "Radiation",
                "Visibility",
                "Wind Direction",
                "Wind Speed",
                "Rain Level"
              ],
              for (int i = 0; i < ittempData.length; i++)
                [
                  formatter.format(ittempData[i].timestamp),
                  ittempData[i].value,
                  itpressureData[i].value,
                  ithumidityData[i].value,
                  itradiationData[i].value,
                  itvisibilityData[i].value,
                  itwinddirectionData[i].value,
                  itwindspeedData[i].value,
                  itrainData[i].value,
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
        } else if (widget.deviceName.startsWith('WF')) {
          setState(() {
            wfAverageTemperatureData =
                _parsewfChartData(data, 'Average_Temperature');
            wfrainfallData =
                _parsewfChartData(data, 'Rainfall_Daily_Comulative');

            rows = [
              [
                "Time_Stamp",
                "Average_Temperature",
                "Rainfall_Daily_Comulative"
              ],
              for (int i = 0; i < wfAverageTemperatureData.length; i++)
                [
                  formatter.format(wfAverageTemperatureData[i].timestamp),
                  wfAverageTemperatureData[i].value,
                  wfrainfallData[i].value,
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
        } else if (widget.deviceName.startsWith('FS')) {
          setState(() {
            fstempData = _parsefsChartData(data, 'temperature');
            fspressureData = _parsefsChartData(data, 'pressure');
            fshumidityData = _parsefsChartData(data, 'humidity');
            fsradiationData = _parsefsChartData(data, 'radiation');
            fsrainData = [];

            for (var item in data['items']) {
              DateTime ts = formatter.parse(item['timestamp']);
              String day = DateFormat('yyyy-MM-dd').format(ts);

              double rain =
                  double.tryParse(item['rain_level'].toString()) ?? 0.0;

              if (_fsLastRainDate != day) {
                // New day starts -> reset baseline
                _fsLastRainDate = day;
                _fsDailyRainBaseline = rain;
              }

              double rainDisplay = rain - (_fsDailyRainBaseline ?? rain);

              // Round to 2 decimal places
              rainDisplay = double.parse(rainDisplay.toStringAsFixed(2));

              fsrainData.add(ChartData(timestamp: ts, value: rainDisplay));
            }

            fswinddirectionData = _parsefsChartData(data, 'wind_direction');
            fswindspeedData = _parsefsChartData(data, 'wind_speed');

            if (data.containsKey('items') &&
                data['items'] is List &&
                data['items'].isNotEmpty) {
              var lastItem = data['items'].last;

              var batteryVoltage = lastItem['battery_voltage'];
              if (batteryVoltage != null) {
                _lastfsBattery =
                    double.tryParse(batteryVoltage.toString()) ?? 0.0;
              } else {
                _lastfsBattery = 0;
              }
            }

            // Prepare data for CSV
            rows = [
              [
                "Timestamp",
                "Temperature",
                "Pressure ",
                "Relative Humidity",
                "Radiation",
                "Wind Speed",
                "Wind Direction",
                "Rain Level"
              ],
              for (int i = 0; i < fstempData.length; i++)
                [
                  formatter.format(fstempData[i].timestamp),
                  fstempData[i].value,
                  fspressureData[i].value,
                  fshumidityData[i].value,
                  fsradiationData[i].value,
                  fswindspeedData[i].value,
                  fswinddirectionData[i].value,
                  fsrainData[i].value,
                ]
            ];
          });
          // Fetch device details specifically for Weather data
          await _fetchDeviceDetails();
        } else if (widget.deviceName.startsWith('WD')) {
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
        } else {
          setState(() {
            rfdData = _parserainChartData(data, 'RFD');
            rfsData = _parserainChartData(data, 'RFS');

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

            // Update current chlorine value
            if (rfdData.isNotEmpty) {
              _currentrfdValue = rfdData.last.value.toStringAsFixed(2);
            }
          });
          await _fetchDeviceDetails();
        }

        // Store CSV rows for download later
        setState(() {
          // Only set _csvRows for sensors other than SM and CF
          if (!widget.deviceName.startsWith('SM') &&
              !widget.deviceName.startsWith('CF') &&
              !widget.deviceName.startsWith('VD') &&
              !widget.deviceName.startsWith('CP') &&
              !widget.deviceName.startsWith('SV')) {
            _csvRows = rows;
          }
          _lastWindDirection =
              lastWindDirection; // Store the last wind direction
          _lastBatteryPercentage = lastBatteryPercentage;
          _lastRSSI_Value = lastRSSI_Value;
          // _lastwinddirection = lastwinddirection;

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
    List<List<dynamic>> csvRows;

    if (widget.deviceName.startsWith('SM')) {
      if (smParametersData.isEmpty) {
        csvRows = [
          ['Timestamp', 'Message'],
          ['', 'No data available']
        ];
      } else {
        List<String> headers = ['Timestamp'];
        headers.addAll(smParametersData.keys);

        List<List<dynamic>> dataRows = [];
        Set<DateTime> timestamps = {};
        smParametersData.values.forEach((dataList) {
          dataList.forEach((data) => timestamps.add(data.timestamp));
        });
        List<DateTime> sortedTimestamps = timestamps.toList()..sort();

        for (var timestamp in sortedTimestamps) {
          List<dynamic> row = [formatter.format(timestamp)];
          for (var key in smParametersData.keys) {
            var dataList = smParametersData[key]!;
            var matchingData = dataList.firstWhere(
              (data) => data.timestamp == timestamp,
              orElse: () => ChartData(timestamp: timestamp, value: 0.0),
            );
            row.add(matchingData.value ?? '');
          }
          dataRows.add(row);
        }

        csvRows = [headers, ...dataRows];
      }
    } else if (widget.deviceName.startsWith('CF')) {
      if (cfParametersData.isEmpty) {
        csvRows = [
          ['Timestamp', 'Message'],
          ['', 'No data available']
        ];
      } else {
        List<String> headers = ['Timestamp'];
        headers.addAll(cfParametersData.keys);

        List<List<dynamic>> dataRows = [];
        Set<DateTime> timestamps = {};
        cfParametersData.values.forEach((dataList) {
          dataList.forEach((data) => timestamps.add(data.timestamp));
        });
        List<DateTime> sortedTimestamps = timestamps.toList()..sort();

        for (var timestamp in sortedTimestamps) {
          List<dynamic> row = [formatter.format(timestamp)];
          for (var key in cfParametersData.keys) {
            var dataList = cfParametersData[key]!;
            var matchingData = dataList.firstWhere(
              (data) => data.timestamp == timestamp,
              orElse: () => ChartData(timestamp: timestamp, value: 0.0),
            );
            row.add(matchingData.value ?? '');
          }
          dataRows.add(row);
        }

        csvRows = [headers, ...dataRows];
      }
    } else if (widget.deviceName.startsWith('SV')) {
      if (svParametersData.isEmpty) {
        csvRows = [
          ['Timestamp', 'Message'],
          ['', 'No data available']
        ];
      } else {
        List<String> headers = ['Timestamp'];
        headers.addAll(svParametersData.keys);

        List<List<dynamic>> dataRows = [];
        Set<DateTime> timestamps = {};
        svParametersData.values.forEach((dataList) {
          dataList.forEach((data) => timestamps.add(data.timestamp));
        });
        List<DateTime> sortedTimestamps = timestamps.toList()..sort();

        for (var timestamp in sortedTimestamps) {
          List<dynamic> row = [formatter.format(timestamp)];
          for (var key in svParametersData.keys) {
            var dataList = svParametersData[key]!;
            var matchingData = dataList.firstWhere(
              (data) => data.timestamp == timestamp,
              orElse: () => ChartData(timestamp: timestamp, value: 0.0),
            );
            row.add(matchingData.value ?? '');
          }
          dataRows.add(row);
        }

        csvRows = [headers, ...dataRows];
      }
    } else if (widget.deviceName.startsWith('WD211') ||
        widget.deviceName.startsWith('WD511')) {
      if (rfdData.isEmpty || rfsData.isEmpty) {
        csvRows = [
          ['Timestamp', 'Message'],
          ['', 'No data available']
        ];
      } else {
        csvRows = [
          ["Timestamp", "RFD ", "RFS "],
          for (int i = 0; i < rfdData.length; i++)
            [
              formatter.format(rfdData[i].timestamp),
              rfdData[i].value,
              rfsData[i].value,
            ]
        ];
      }
    } else {
      // Use _csvRows for other sensors (CL, BD, WQ, IT, WS, DO, TH, NH, TE, LU, FS, WD, etc.)
      if (_csvRows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No data available for download.")),
        );
        return;
      }
      csvRows = _csvRows;
    }

    String csvData = const ListToCsvConverter().convert(csvRows);
    String fileName = _generateFileName();

    if (kIsWeb) {
      final blob = html.Blob([csvData], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
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
        await saveCSVFile(csvData, fileName);
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
    final result = items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      String valueStr = item[type]?.toString().split(' ')[0] ?? '0.0';
      double value = double.tryParse(valueStr) ?? 0.0;
      DateTime timestamp = _parsewaterDate(item['HumanTime']);

      return ChartData(
        timestamp: timestamp,
        value: value,
      );
    }).toList();

    return result;
  }

  List<ChartData> _parseITChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parseITDate(item['human_time']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parsefsChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parsefsDate(item['timestamp']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  Map<String, List<ChartData>> _parseSMParametersData(
      Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];
    Map<String, List<ChartData>> parametersData = {};

    if (items.isEmpty) {
      return parametersData;
    }

    // Collect all possible parameter keys from the first item, excluding non-numeric fields
    final sampleItem = items.first;
    final parameterKeys = sampleItem.keys.where((key) {
      // Exclude non-numeric fields like TimeStamp, TimeStampFormatted, Topic, IMEINumber, DeviceId
      return ![
        'TimeStamp',
        'TimeStampFormatted',
        'Topic',
        'IMEINumber',
        'DeviceId'
      ].contains(key);
    }).toList();

    // Initialize ChartData lists for each parameter
    for (var key in parameterKeys) {
      parametersData[key] = [];
    }

    // Parse data for each item
    for (var item in items) {
      if (item == null) continue;
      DateTime timestamp = _parseSMDate(item['TimeStamp']);
      for (var key in parameterKeys) {
        if (item[key] != null) {
          // Only include non-null values
          double value = double.tryParse(item[key].toString()) ?? 0.0;
          parametersData[key]!
              .add(ChartData(timestamp: timestamp, value: value));
        }
      }
    }
    // Update _lastsmBattery with the latest BatteryVoltage (from the last item)
    for (var item in items.reversed) {
      if (item != null && item['BatteryVoltage'] != null) {
        _lastsmBattery =
            double.tryParse(item['BatteryVoltage'].toString()) ?? 0.0;

        break; // Exit after finding the latest non-null value
      }
    }

    // Remove parameters with empty lists (i.e., all values were null)
    parametersData.removeWhere((key, value) => value.isEmpty);

    return parametersData;
  }

  Map<String, List<ChartData>> _parseCFParametersData(
      Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];
    Map<String, List<ChartData>> parametersData = {};

    if (items.isEmpty) {
      return parametersData;
    }

    // Collect all possible parameter keys from the first item, excluding non-numeric fields
    final sampleItem = items.first;
    final parameterKeys = sampleItem.keys.where((key) {
      // Exclude non-numeric fields like TimeStamp, Topic, IMEINumber, DeviceId, Latitude, Longitude
      return ![
        'TimeStamp',
        'Topic',
        'IMEINumber',
        'DeviceId',
        'Latitude',
        'Longitude'
      ].contains(key);
    }).toList();

    // Initialize ChartData lists for each parameter
    for (var key in parameterKeys) {
      parametersData[key] = [];
    }

    // Parse data for each item
    for (var item in items) {
      if (item == null) continue;
      DateTime timestamp = _parseCFDate(item['TimeStamp']);
      for (var key in parameterKeys) {
        if (item[key] != null) {
          // Only include non-null values
          double value = double.tryParse(item[key].toString()) ?? 0.0;
          parametersData[key]!
              .add(ChartData(timestamp: timestamp, value: value));
        }
      }
    }

    // Update _lastcfBattery with the latest BatteryVoltage (from the last item)
    for (var item in items.reversed) {
      if (item != null && item['BatteryVoltage'] != null) {
        _lastcfBattery =
            double.tryParse(item['BatteryVoltage'].toString()) ?? 0.0;

        break; // Exit after finding the latest non-null value
      }
    }

    // Remove parameters with empty lists (i.e., all values were null)
    parametersData.removeWhere((key, value) => value.isEmpty);

    return parametersData;
  }

  Map<String, List<ChartData>> _parseVDParametersData(
      Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];
    Map<String, List<ChartData>> parametersData = {};

    if (items.isEmpty) {
      return parametersData;
    }

    // Collect all possible parameter keys from the first item, excluding non-numeric fields
    final sampleItem = items.first;
    final parameterKeys = sampleItem.keys.where((key) {
      // Exclude non-numeric fields like TimeStamp, Topic, IMEINumber, DeviceId, Latitude, Longitude
      return ![
        'TimeStamp',
        'Topic',
        'IMEINumber',
        'DeviceId',
        'Latitude',
        'Longitude'
      ].contains(key);
    }).toList();

    // Initialize ChartData lists for each parameter
    for (var key in parameterKeys) {
      parametersData[key] = [];
    }

    // Parse data for each item
    for (var item in items) {
      if (item == null) continue;
      DateTime timestamp = _parseVDDate(item['TimeStamp']);
      for (var key in parameterKeys) {
        if (item[key] != null) {
          // Only include non-null values
          double value = double.tryParse(item[key].toString()) ?? 0.0;
          parametersData[key]!
              .add(ChartData(timestamp: timestamp, value: value));
        }
      }
    }

    // Update _lastcfBattery with the latest BatteryVoltage (from the last item)
    for (var item in items.reversed) {
      if (item != null && item['BatteryVoltage'] != null) {
        _lastvdBattery =
            double.tryParse(item['BatteryVoltage'].toString()) ?? 0.0;

        break; // Exit after finding the latest non-null value
      }
    }

    // Remove parameters with empty lists (i.e., all values were null)
    parametersData.removeWhere((key, value) => value.isEmpty);

    return parametersData;
  }

  Map<String, List<ChartData>> _parseKDParametersData(
      Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];
    Map<String, List<ChartData>> parametersData = {};

    if (items.isEmpty) {
      return parametersData;
    }

    // Collect all possible parameter keys from the first item, excluding non-numeric fields
    final sampleItem = items.first;
    final parameterKeys = sampleItem.keys.where((key) {
      // Exclude non-numeric fields like TimeStamp, Topic, IMEINumber, DeviceId, Latitude, Longitude
      return ![
        'TimeStamp',
        'Topic',
        'IMEINumber',
        'DeviceId',
        'Latitude',
        'Longitude'
      ].contains(key);
    }).toList();

    // Initialize ChartData lists for each parameter
    for (var key in parameterKeys) {
      parametersData[key] = [];
    }

    // Parse data for each item
    for (var item in items) {
      if (item == null) continue;
      DateTime timestamp = _parseKDDate(item['TimeStamp']);
      for (var key in parameterKeys) {
        if (item[key] != null) {
          // Only include non-null values
          double value = double.tryParse(item[key].toString()) ?? 0.0;
          parametersData[key]!
              .add(ChartData(timestamp: timestamp, value: value));
        }
      }
    }

    // Update _lastkdBattery with the latest BatteryVoltage (from the last item)
    for (var item in items.reversed) {
      if (item != null && item['BatteryVoltage'] != null) {
        _lastkdBattery =
            double.tryParse(item['BatteryVoltage'].toString()) ?? 0.0;

        break; // Exit after finding the latest non-null value
      }
    }

    // Remove parameters with empty lists (i.e., all values were null)
    parametersData.removeWhere((key, value) => value.isEmpty);

    return parametersData;
  }

  Map<String, List<ChartData>> _parseNARLParametersData(
      Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];
    Map<String, List<ChartData>> parametersData = {};

    if (items.isEmpty) {
      return parametersData;
    }

    // Collect all possible parameter keys from the first item, excluding non-numeric fields
    final sampleItem = items.first;
    final parameterKeys = sampleItem.keys.where((key) {
      // Exclude non-numeric fields like TimeStamp, Topic, IMEINumber, DeviceId, Latitude, Longitude
      return ![
        'TimeStamp',
        'Topic',
        'IMEINumber',
        'DeviceId',
        'Latitude',
        'Longitude'
      ].contains(key);
    }).toList();

    // Initialize ChartData lists for each parameter
    for (var key in parameterKeys) {
      parametersData[key] = [];
    }

    // Parse data for each item
    for (var item in items) {
      if (item == null) continue;
      DateTime timestamp = _parseNARLDate(item['TimeStamp']);
      for (var key in parameterKeys) {
        if (item[key] != null) {
          // Only include non-null values
          double value = double.tryParse(item[key].toString()) ?? 0.0;
          parametersData[key]!
              .add(ChartData(timestamp: timestamp, value: value));
        }
      }
    }

    // Update _lastkdBattery with the latest BatteryVoltage (from the last item)
    for (var item in items.reversed) {
      if (item != null && item['BatteryVoltage'] != null) {
        _lastNARLBattery =
            double.tryParse(item['BatteryVoltage'].toString()) ?? 0.0;

        break; // Exit after finding the latest non-null value
      }
    }

    // Remove parameters with empty lists (i.e., all values were null)
    parametersData.removeWhere((key, value) => value.isEmpty);

    return parametersData;
  }

  Map<String, List<ChartData>> _parsecsParametersData(
      Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];
    Map<String, List<ChartData>> parametersData = {};

    if (items.isEmpty) {
      return parametersData;
    }

    // Collect all possible parameter keys from the first item, excluding non-numeric fields
    final sampleItem = items.first;
    final parameterKeys = sampleItem.keys.where((key) {
      // Exclude non-numeric fields like TimeStamp, Topic, IMEINumber, DeviceId, Latitude, Longitude
      return ![
        'TimeStamp',
        'Topic',
        'IMEINumber',
        'DeviceId',
        'Latitude',
        'Longitude'
      ].contains(key);
    }).toList();

    // Initialize ChartData lists for each parameter
    for (var key in parameterKeys) {
      parametersData[key] = [];
    }

    // Parse data for each item
    for (var item in items) {
      if (item == null) continue;
      DateTime timestamp = _parsecsDate(item['TimeStamp']);
      for (var key in parameterKeys) {
        if (item[key] != null) {
          // Only include non-null values
          double value = double.tryParse(item[key].toString()) ?? 0.0;
          parametersData[key]!
              .add(ChartData(timestamp: timestamp, value: value));
        }
      }
    }

    // Update _lastkdBattery with the latest BatteryVoltage (from the last item)
    for (var item in items.reversed) {
      if (item != null && item['BatteryVoltage'] != null) {
        _lastcsBattery =
            double.tryParse(item['BatteryVoltage'].toString()) ?? 0.0;

        break; // Exit after finding the latest non-null value
      }
    }

    // Remove parameters with empty lists (i.e., all values were null)
    parametersData.removeWhere((key, value) => value.isEmpty);

    return parametersData;
  }

  Map<String, List<ChartData>> _parseSVParametersData(
      Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];
    Map<String, List<ChartData>> parametersData = {};

    if (items.isEmpty) {
      return parametersData;
    }

    // Collect all possible parameter keys from the first item, excluding non-numeric fields
    final sampleItem = items.first;
    final parameterKeys = sampleItem.keys.where((key) {
      // Exclude non-numeric fields like TimeStamp, Topic, IMEINumber, DeviceId, Latitude, Longitude
      return ![
        'TimeStamp',
        'Topic',
        'IMEINumber',
        'DeviceId',
        'Latitude',
        'Longitude'
      ].contains(key);
    }).toList();

    // Initialize ChartData lists for each parameter
    for (var key in parameterKeys) {
      parametersData[key] = [];
    }

    // Parse data for each item
    for (var item in items) {
      if (item == null) continue;
      DateTime timestamp = _parseSVDate(item['TimeStamp']);
      for (var key in parameterKeys) {
        if (item[key] != null) {
          // Only include non-null values
          double value = double.tryParse(item[key].toString()) ?? 0.0;
          parametersData[key]!
              .add(ChartData(timestamp: timestamp, value: value));
        }
      }
    }

    // Update _lastsvBattery with the latest BatteryVoltage (from the last item)
    for (var item in items.reversed) {
      if (item != null && item['BatteryVoltage'] != null) {
        _lastsvBattery =
            double.tryParse(item['BatteryVoltage'].toString()) ?? 0.0;

        break; // Exit after finding the latest non-null value
      }
    }

    // Remove parameters with empty lists (i.e., all values were null)
    parametersData.removeWhere((key, value) => value.isEmpty);

    return parametersData;
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

  List<ChartData> _parsewfChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parsewfDate(item['Time_Stamp']),
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

  List<ChartData> _parseCBChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parseCBDate(item['human_time']),
        value: item[type] != null
            ? double.tryParse(item[type].toString()) ?? 0.0
            : 0.0,
      );
    }).toList();
  }

  List<ChartData> _parserainChartData(Map<String, dynamic> data, String type) {
    final List<dynamic> items = data['items'] ?? [];
    return items.map((item) {
      if (item == null) {
        return ChartData(timestamp: DateTime.now(), value: 0.0);
      }
      return ChartData(
        timestamp: _parserainDate(item['human_time']),
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
  Map<String, List<double?>> _calculateCBStatistics(List<ChartData> data) {
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
  Widget buildCBStatisticsTable() {
    final temp2Stats = _calculateCBStatistics(temp2Data);

    final cod2Stats = _calculateCBStatistics(cod2Data);
    final bod2Stats = _calculateCBStatistics(bod2Data);

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
                buildCBDataRow('Temp', temp2Stats, fontSize),
                buildCBDataRow('COD', cod2Stats, fontSize),
                buildCBDataRow('BOD', bod2Stats, fontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow buildCBDataRow(
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

  // Calculate average, min, and max values
  Map<String, List<double?>> _calculateITStatistics(List<ChartData> data) {
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
  Widget buildITStatisticsTable() {
    final ittempStats = _calculateITStatistics(ittempData);
    final itpressureStats = _calculateITStatistics(itpressureData);
    final ithumStats = _calculateITStatistics(ithumidityData);
    final itrainStats = _calculateITStatistics(itrainData);
    final itradiationStats = _calculateITStatistics(itradiationData);
    final itvisibilityStats = _calculateITStatistics(itvisibilityData);
    final itwindspeedStats = _calculateITStatistics(itwindspeedData);

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 800 ? 13 : 16;
    double headerFontSize = screenWidth < 800 ? 16 : 22;
// Check if there is any valid data
    bool hasValidData = [
      ittempStats['current']?[0],
      itpressureStats['current']?[0],
      ithumStats['current']?[0],
      itrainStats['current']?[0],
      itradiationStats['current']?[0],
      itvisibilityStats['current']?[0],
      itwindspeedStats['current']?[0],
    ].any((value) => value != null && value.toStringAsFixed(2) != '0.00');

    // Only render the table if there is valid data
    if (!hasValidData) {
      return SizedBox.shrink(); // Return an empty widget if no data
    }
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
                buildITDataRow('TEMP', ittempStats, fontSize),
                buildITDataRow('PRESSURE', itpressureStats, fontSize),
                buildITDataRow('HUMIDITY', ithumStats, fontSize),
                buildITDataRow('RAIN', itrainStats, fontSize),
                buildITDataRow('RADIATION', itradiationStats, fontSize),
                buildITDataRow('VISIBILITY', itvisibilityStats, fontSize),
                buildITDataRow('WIND SPEED', itwindspeedStats, fontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow buildITDataRow(
      String parameter, Map<String, List<double?>> stats, double fontSize) {
    // Parameters that should only show current values
    final onlyCurrentParams = [
      'RAIN',
    ];

    final isOnlyCurrent = onlyCurrentParams.contains(parameter);

    return DataRow(cells: [
      DataCell(Text(parameter,
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          stats['current']?[0] != null
              ? stats['current']![0]!.toStringAsFixed(2)
              : '-',
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          isOnlyCurrent
              ? '-' // Show '-' for min if parameter is in onlyCurrentParams
              : (stats['min']?[0] != null
                  ? stats['min']![0]!.toStringAsFixed(2)
                  : '-'),
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          isOnlyCurrent
              ? '-' // Show '-' for max if parameter is in onlyCurrentParams
              : (stats['max']?[0] != null
                  ? stats['max']![0]!.toStringAsFixed(2)
                  : '-'),
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
    ]);
  }

  // Calculate average, min, and max values
  Map<String, List<double?>> _calculatefsStatistics(List<ChartData> data) {
    if (data.isEmpty) {
      return {
        'average': [null],
        'current': [null],
        'min': [null],
        'max': [null],
      };
    }
    double sum = 0.0;
    double? current = data.last.value;
    double min = double.infinity;
    double max = double.negativeInfinity;

    for (var entry in data) {
      sum += entry.value;
      if (entry.value < min) min = entry.value;
      if (entry.value > max) max = entry.value;
    }
    double avg = sum / data.length;
    return {
      'average': [avg],
      'current': [current],
      'min': [min],
      'max': [max],
    };
  }

  // Create a table displaying statistics
  Widget buildfsStatisticsTable() {
    final fstempStats = _calculatefsStatistics(fstempData);
    final fspressureStats = _calculatefsStatistics(fspressureData);
    final fshumStats = _calculatefsStatistics(fshumidityData);
    final fsrainStats = _calculatefsStatistics(fsrainData);
    final fsradiationStats = _calculatefsStatistics(fsradiationData);

    final fswindspeedStats = _calculatefsStatistics(fswindspeedData);
    final fswinddirectionStats = _calculatefsStatistics(fswinddirectionData);

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 800 ? 13 : 27;
    double headerFontSize = screenWidth < 800 ? 16 : 33;
// Check if there is any valid data
    bool hasValidData = [
      fstempStats['current']?[0],
      fspressureStats['current']?[0],
      fshumStats['current']?[0],
      fsrainStats['current']?[0],
      fsradiationStats['current']?[0],
      fswindspeedStats['current']?[0],
      fswinddirectionStats['current']?[0],
    ].any((value) => value != null && value.toStringAsFixed(2) != '0.00');

    // Only render the table if there is valid data
    if (!hasValidData) {
      return SizedBox.shrink(); // Return an empty widget if no data
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withOpacity(0.6),
        ),
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(8),
        width: screenWidth < 800 ? double.infinity : 900,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth < 800 ? screenWidth - 32 : 900,
            ),
            child: DataTable(
              horizontalMargin: 20,
              columnSpacing: 25,
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
                buildfsDataRow('TEMPERATURE (°C)', fstempStats, fontSize),
                buildfsDataRow('PRESSURE (hPa)', fspressureStats, fontSize),
                buildfsDataRow('RELATIVE HUMIDITY (%)', fshumStats, fontSize),
                buildfsDataRow('RAIN LEVEL (mm)', fsrainStats, fontSize),
                buildfsDataRow('RADIATION (W/m²)', fsradiationStats, fontSize),
                buildfsDataRow('WIND SPEED (m/s)', fswindspeedStats, fontSize),
                buildfsDataRow(
                    'WIND DIRECTION (°)', fswinddirectionStats, fontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow buildfsDataRow(
      String parameter, Map<String, List<double?>> stats, double fontSize) {
    // Parameters that should only show current values
    final onlyCurrentParams = [
      'WIND DIRECTION (°)',
      'RAIN LEVEL (mm)',
    ];

    final isOnlyCurrent = onlyCurrentParams.contains(parameter);

    return DataRow(cells: [
      DataCell(Text(parameter,
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          stats['current']?[0] != null
              ? stats['current']![0]!.toStringAsFixed(2)
              : '-',
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          isOnlyCurrent
              ? '-' // Show '-' for min if parameter is in onlyCurrentParams
              : (stats['min']?[0] != null
                  ? stats['min']![0]!.toStringAsFixed(2)
                  : '-'),
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
      DataCell(Text(
          isOnlyCurrent
              ? '-' // Show '-' for max if parameter is in onlyCurrentParams
              : (stats['max']?[0] != null
                  ? stats['max']![0]!.toStringAsFixed(2)
                  : '-'),
          style: TextStyle(fontSize: fontSize, color: Colors.white))),
    ]);
  }

  Widget buildSMStatisticsTable() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 800 ? 13 : 16;
    double headerFontSize = screenWidth < 800 ? 16 : 22;

    // Filter only specific keys if needed
    List<String> includedParameters = ['RainfallMinutly', 'RainfallDaily'];

    List<DataRow> rows = smParametersData.entries
        .where((entry) => includedParameters.contains(entry.key))
        .map((entry) {
      final current = entry.value.isNotEmpty
          ? entry.value.last.value.toStringAsFixed(2)
          : '-';
      return DataRow(cells: [
        DataCell(Text(entry.key,
            style: TextStyle(fontSize: fontSize, color: Colors.white))),
        DataCell(Text('$current mm',
            style: TextStyle(fontSize: fontSize, color: Colors.white))),
      ]);
    }).toList();

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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth < 800 ? screenWidth - 32 : 400,
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
              ],
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }


// Widget to display current values horizontally
Widget buildCurrentValuesRow() {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  double screenWidth = MediaQuery.of(context).size.width;
  double fontSize = screenWidth < 800 ? 14 : 18;

  // Calculate statistics for each parameter
  final fstempStats = _calculatefsStatistics(fstempData);
  final fspressureStats = _calculatefsStatistics(fspressureData);
  final fshumStats = _calculatefsStatistics(fshumidityData);
  final fsrainStats = _calculatefsStatistics(fsrainData);
  final fsradiationStats = _calculatefsStatistics(fsradiationData);
  final fswindspeedStats = _calculatefsStatistics(fswindspeedData);
  final fswinddirectionStats = _calculatefsStatistics(fswinddirectionData);

  // Map of parameters and their current values with units
  final currentValues = {
    'Temperature': '${fstempStats['current']?[0]?.toStringAsFixed(2) ?? '-'} °C',
    'Pressure': '${fspressureStats['current']?[0]?.toStringAsFixed(2) ?? '-'} hPa',
    'Relative Humidity': '${fshumStats['current']?[0]?.toStringAsFixed(2) ?? '-'} %',
    'Rain Level': '${fsrainStats['current']?[0]?.toStringAsFixed(2) ?? '-'} mm',
    'Radiation': '${fsradiationStats['current']?[0]?.toStringAsFixed(2) ?? '-'} W/m²',
    'Wind Speed': '${fswindspeedStats['current']?[0]?.toStringAsFixed(2) ?? '-'} m/s',
    'Wind Direction': '${fswinddirectionStats['current']?[0]?.toStringAsFixed(2) ?? '-'} °',
  };

  // Filter out entries where the value is null or effectively zero
  final filteredValues = currentValues.entries.where((entry) {
    final value = entry.value.replaceAll(RegExp(r'[^\d.-]'), ''); // Extract numeric part
    return value.isNotEmpty && value != '-' && double.parse(value) != 0.00;
  }).toList();

  // Return an empty container if no valid data
  if (filteredValues.isEmpty) {
    return SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: filteredValues.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                entry.value,
                style: TextStyle(
                  fontSize: fontSize,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}
  Widget buildVDStatisticsTable() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 800 ? 13 : 16;
    double headerFontSize = screenWidth < 800 ? 16 : 22;

    // Map internal keys to readable labels with units
    Map<String, String> parameterLabels = {
      'CurrentTemperature': 'Temperature (°C)',
      'CurrentHumidity': 'Humidity (%)',
      'LightIntensity': 'Light Intensity (lux)',
      'RainfallHourly': 'Rainfall (mm)',
    };

    List<String> includedParameters = parameterLabels.keys.toList();

    // Check if there is any valid data
    bool hasValidData = vdParametersData.entries.any((entry) {
      return includedParameters.contains(entry.key) &&
          entry.value.isNotEmpty &&
          entry.value.last.value != null &&
          entry.value.last.value.toStringAsFixed(2) !=
              '0.00'; // Exclude zero or null values
    });

    // Only render the table if there is valid data
    if (!hasValidData) {
      return SizedBox.shrink(); // Return an empty widget if no data
    }

    List<DataRow> rows = vdParametersData.entries
        .where((entry) => includedParameters.contains(entry.key))
        .map((entry) {
      final current = entry.value.isNotEmpty
          ? entry.value.last.value.toStringAsFixed(2)
          : '-';
      return DataRow(cells: [
        DataCell(Text(
          parameterLabels[entry.key] ?? entry.key,
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        )),
        DataCell(Text(
          '$current',
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        )),
      ]);
    }).toList();

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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth < 800 ? screenWidth - 32 : 400,
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
                      color: Colors.blue,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Current',
                    style: TextStyle(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNAStatisticsTable() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 800 ? 13 : 16;
    double headerFontSize = screenWidth < 800 ? 16 : 22;

    // Map internal keys to readable labels with units
    Map<String, String> parameterLabels = {
      'CurrentTemperature': 'Temperature (°C)',
      'CurrentHumidity': 'Humidity (%)',
      'LightIntensity': 'Light Intensity (lux)',
      'RainfallHourly': 'Rainfall (mm)',
      'WindSpeed': 'Wind Speed (m/s)',
      'AtmPressure': 'Atm Pressure (hpa)',
      'WindDirection': 'Wind Direction (°)',
      'RainfallMinutly': 'Rainfall Minutely (mm)'
    };

    List<String> includedParameters = parameterLabels.keys.toList();
    // Check if there is any valid data
    bool hasValidData = NARLParametersData.entries.any((entry) {
      return includedParameters.contains(entry.key) &&
          entry.value.isNotEmpty &&
          entry.value.last.value != null &&
          entry.value.last.value.toStringAsFixed(2) !=
              '0.00'; // Exclude zero or null values
    });

    // Only render the table if there is valid data
    if (!hasValidData) {
      return SizedBox.shrink(); // Return an empty widget if no data
    }

    List<DataRow> rows = NARLParametersData.entries
        .where((entry) => includedParameters.contains(entry.key))
        .map((entry) {
      final current = entry.value.isNotEmpty
          ? entry.value.last.value.toStringAsFixed(2)
          : '-';
      return DataRow(cells: [
        DataCell(Text(
          parameterLabels[entry.key] ?? entry.key,
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        )),
        DataCell(Text(
          '$current',
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        )),
      ]);
    }).toList();

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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth < 800 ? screenWidth - 32 : 400,
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
                      color: Colors.blue,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Current',
                    style: TextStyle(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
              rows: rows,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCPStatisticsTable() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 800 ? 13 : 16;
    double headerFontSize = screenWidth < 800 ? 16 : 22;

    // Map internal keys to readable labels with units
    Map<String, String> parameterLabels = {
      'CurrentTemperature': 'Temperature (°C)',
      'CurrentHumidity': 'Humidity (%)',
      'LightIntensity': 'Light Intensity (lux)',
      'RainfallHourly': 'Rainfall (mm)',
      'WindSpeed': 'Wind Speed (m/s)',
      'AtmPressure': 'Atm Pressure (hpa)',
      'WindDirection': 'Wind Direction (°)'
    };

    List<String> includedParameters = parameterLabels.keys.toList();
    // Check if there is any valid data
    bool hasValidData = csParametersData.entries.any((entry) {
      return includedParameters.contains(entry.key) &&
          entry.value.isNotEmpty &&
          entry.value.last.value != null &&
          entry.value.last.value.toStringAsFixed(2) !=
              '0.00'; // Exclude zero or null values
    });

    // Only render the table if there is valid data
    if (!hasValidData) {
      return SizedBox.shrink(); // Return an empty widget if no data
    }

    List<DataRow> rows = csParametersData.entries
        .where((entry) => includedParameters.contains(entry.key))
        .map((entry) {
      final current = entry.value.isNotEmpty
          ? entry.value.last.value.toStringAsFixed(2)
          : '-';
      return DataRow(cells: [
        DataCell(Text(
          parameterLabels[entry.key] ?? entry.key,
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        )),
        DataCell(Text(
          '$current',
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        )),
      ]);
    }).toList();

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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth < 800 ? screenWidth - 32 : 400,
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
                      color: Colors.blue,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Current',
                    style: TextStyle(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
              rows: rows,
            ),
          ),
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

  DateTime _parseCBDate(String dateString) {
    final dateFormat = DateFormat(
        'dd-MM-yyyy HH:mm:ss'); // Ensure this matches your date format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  DateTime _parseITDate(String dateString) {
    final dateFormat = DateFormat(
        'dd-MM-yyyy HH:mm:ss'); // Ensure this matches your date format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  DateTime _parsefsDate(String dateString) {
    final dateFormat = DateFormat(
        'dd-MM-yyyy HH:mm:ss'); // Ensure this matches your date format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now(); // Provide a default date-time if parsing fails
    }
  }

  DateTime _parseSMDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      // Parse the timestamp format: YYYYMMDDTHHMMSS (e.g., 20250614T162130)
      return DateTime.parse(
          dateStr.replaceFirst('T', ' ')); // Convert to YYYYMMDD HHMMSS
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _parseCFDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      // Parse the timestamp format: YYYY-MM-DD HH:MM:SS (e.g., 2025-06-15 01:01:02)
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _parseVDDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      // Parse the timestamp format: YYYY-MM-DD HH:MM:SS (e.g., 2025-06-15 01:01:02)
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _parseKDDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      // Parse the timestamp format: YYYY-MM-DD HH:MM:SS (e.g., 2025-06-15 01:01:02)
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _parseNARLDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      // Parse the timestamp format: YYYY-MM-DD HH:MM:SS (e.g., 2025-06-15 01:01:02)
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _parsecsDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      // Parse the timestamp format: YYYY-MM-DD HH:MM:SS (e.g., 2025-06-15 01:01:02)
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _parseSVDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    try {
      // Parse the timestamp format: YYYY-MM-DD HH:MM:SS (e.g., 2025-06-15 01:01:02)
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
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

  DateTime _parsewfDate(String dateString) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss'); // Correct format
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _parserainDate(String dateString) {
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
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    try {
      return dateFormat.parse(dateString);
    } catch (e) {
      return DateTime.now();
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

  // Updated _buildWindCompass
  Widget _buildWindCompass(String? winddirection) {
    // Convert wind direction to double, default to 0 if invalid
    double angle = 0;
    try {
      angle = double.parse(winddirection ?? '0');
    } catch (e) {
      angle = 0;
    }

    // Convert degrees to radians for rotation
    final angleRad = angle * math.pi / 180;

    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Compass background with ticks
              CustomPaint(
                painter: CompassBackgroundPainter(),
                child: Container(width: 150, height: 150),
              ),
              // Compass cardinal directions (N, NE, E, SE, S, SW, W, NW)
              Positioned(
                top: 10,
                child: Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Text(
                  'NE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                child: Text(
                  'E',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Text(
                  'SE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  'SW',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                child: Text(
                  'W',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Text(
                  'NW',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Rotated needle for wind direction
              Transform.rotate(
                angle: angleRad,
                child: CustomPaint(
                  painter: CompassNeedlePainter(), // No angle parameter
                  child: Container(width: 150, height: 150),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Wind Direction: ${winddirection ?? 'N/A'}°',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

// Helper function to map parameter keys to display names and units
  Map<String, dynamic> _getParameterDisplayInfo(String paramName) {
    String displayName = paramName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match[1]}')
        .trim();
    String unit = '';

    if (paramName.contains('Rainfall'))
      unit = 'mm';
    else if (paramName.contains('Voltage'))
      unit = 'V';
    else if (paramName.contains('SignalStrength'))
      unit = 'dBm';
    else if (paramName.contains('Latitude') || paramName.contains('Longitude'))
      unit = 'deg';
    else if (paramName.contains('Temperature'))
      unit = '°C';
    else if (paramName.contains('Humidity'))
      unit = '%';
    else if (paramName.contains('Pressure'))
      unit = 'hPa';
    else if (paramName.contains('LightIntensity'))
      unit = 'Lux';
    else if (paramName.contains('WindSpeed'))
      unit = 'm/s';
    else if (paramName.contains('WindDirection'))
      unit = 'degrees'; // Added for CF WindDirection
    else if (paramName.contains('Irradiance') ||
        paramName.contains('Radiation'))
      unit = 'W/m²';
    else if (paramName.contains('Chlorine') ||
        paramName.contains('COD') ||
        paramName.contains('BOD') ||
        paramName.contains('DO'))
      unit = 'mg/L';
    else if (paramName.contains('TDS'))
      unit = 'ppm';
    else if (paramName.contains('EC'))
      unit = 'mS/cm';
    else if (paramName.contains('pH'))
      unit = '';
    else if (paramName.contains('Ammonia'))
      unit = 'PPM';
    else if (paramName.contains('Visibility'))
      unit = 'm';
    else if (paramName.contains('ElectrodeSignal')) unit = 'mV';

    return {'displayName': displayName, 'unit': unit};
  }



// Updated _buildHorizontalStatsRow and _buildParamStat
Widget _buildHorizontalStatsRow(bool isDarkMode) {
  if (widget.deviceName.startsWith('WQ')) {
    final tempStats = _calculateStatistics(tempData);
    final tdsStats = _calculateStatistics(tdsData);
    final codStats = _calculateStatistics(codData);
    final bodStats = _calculateStatistics(bodData);
    final pHStats = _calculateStatistics(pHData);
    final doStats = _calculateStatistics(doData);
    final ecStats = _calculateStatistics(ecData);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildParamStat('Temp', tempStats['current']?[0], tempStats['min']?[0], tempStats['max']?[0], '°C', isDarkMode),
        _buildParamStat('TDS', tdsStats['current']?[0], tdsStats['min']?[0], tdsStats['max']?[0], 'ppm', isDarkMode),
        _buildParamStat('COD', codStats['current']?[0], codStats['min']?[0], codStats['max']?[0], 'mg/L', isDarkMode),
        _buildParamStat('BOD', bodStats['current']?[0], bodStats['min']?[0], bodStats['max']?[0], 'mg/L', isDarkMode),
        _buildParamStat('pH', pHStats['current']?[0], pHStats['min']?[0], pHStats['max']?[0], '', isDarkMode),
        _buildParamStat('DO', doStats['current']?[0], doStats['min']?[0], doStats['max']?[0], 'mg/L', isDarkMode),
        _buildParamStat('EC', ecStats['current']?[0], ecStats['min']?[0], ecStats['max']?[0], 'mS/cm', isDarkMode),
      ],
    );
  } else if (widget.deviceName.startsWith('CB')) {
    final temp2Stats = _calculateCBStatistics(temp2Data);
    final cod2Stats = _calculateCBStatistics(cod2Data);
    final bod2Stats = _calculateCBStatistics(bod2Data);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildParamStat('Temp', temp2Stats['current']?[0], temp2Stats['min']?[0], temp2Stats['max']?[0], '°C', isDarkMode),
        _buildParamStat('COD', cod2Stats['current']?[0], cod2Stats['min']?[0], cod2Stats['max']?[0], 'mg/L', isDarkMode),
        _buildParamStat('BOD', bod2Stats['current']?[0], bod2Stats['min']?[0], bod2Stats['max']?[0], 'mg/L', isDarkMode),
      ],
    );
  } else if (widget.deviceName.startsWith('NH')) {
    final ammoniaStats = _calculateNHStatistics(ammoniaData);
    final temppStats = _calculateNHStatistics(temperaturedata);
    final humStats = _calculateNHStatistics(humiditydata);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildParamStat('AMMONIA', ammoniaStats['current']?[0], ammoniaStats['min']?[0], ammoniaStats['max']?[0], 'PPM', isDarkMode),
        _buildParamStat('TEMP', temppStats['current']?[0], temppStats['min']?[0], temppStats['max']?[0], '°C', isDarkMode),
        _buildParamStat('HUMIDITY', humStats['current']?[0], humStats['min']?[0], humStats['max']?[0], '%', isDarkMode),
      ],
    );
  } else if (widget.deviceName.startsWith('DO')) {
    final ttempStats = _calculateDOStatistics(ttempData);
    final dovalueStats = _calculateDOStatistics(dovaluedata);
    final dopercentageStats = _calculateDOStatistics(dopercentagedata);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildParamStat('Temperature', ttempStats['current']?[0], ttempStats['min']?[0], ttempStats['max']?[0], '°C', isDarkMode),
        _buildParamStat('DO Value', dovalueStats['current']?[0], dovalueStats['min']?[0], dovalueStats['max']?[0], 'mg/L', isDarkMode),
        _buildParamStat('DO Percentage', dopercentageStats['current']?[0], dopercentageStats['min']?[0], dopercentageStats['max']?[0], '%', isDarkMode),
      ],
    );
  } else if (widget.deviceName.startsWith('NA')) {
    Map<String, String> parameterLabels = {
      'CurrentTemperature': 'Temperature',
      'CurrentHumidity': 'Humidity',
      'LightIntensity': 'Light Intensity',
      
      'WindSpeed': 'Wind Speed',
      'AtmPressure': 'Atm Pressure',
      'WindDirection': 'Wind Direction',
      'RainfallMinutly': 'Rainfall'
    };
    List<String> includedParameters = parameterLabels.keys.toList();

    List<Widget> children = NARLParametersData.entries
        .where((entry) => includedParameters.contains(entry.key))
        .map((entry) {
          String label = parameterLabels[entry.key] ?? entry.key;
          double? current = entry.value.isNotEmpty ? entry.value.last.value : null;
          String unit = '';
          if (label == 'Temperature') unit = '°C';
          else if (label == 'Humidity') unit = '%';
          else if (label == 'Light Intensity') unit = 'lux';
          else if (label == 'Rainfall' || label == 'Rainfall Minutely') unit = 'mm';
          else if (label == 'Wind Speed') unit = 'm/s';
          else if (label == 'Atm Pressure') unit = 'hpa';
          else if (label == 'Wind Direction') unit = '°';
          return _buildParamStat(label, current, null, null, unit, isDarkMode);
        }).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  } else if (widget.deviceName.startsWith('VD')) {
    Map<String, String> parameterLabels = {
      'CurrentTemperature': 'Temperature',
      'CurrentHumidity': 'Humidity',
      'LightIntensity': 'Light Intensity',
      'RainfallHourly': 'Rainfall',
    };
    List<String> includedParameters = parameterLabels.keys.toList();

    List<Widget> children = vdParametersData.entries
        .where((entry) => includedParameters.contains(entry.key))
        .map((entry) {
          String label = parameterLabels[entry.key] ?? entry.key;
          double? current = entry.value.isNotEmpty ? entry.value.last.value : null;
          String unit = '';
          if (label == 'Temperature') unit = '°C';
          else if (label == 'Humidity') unit = '%';
          else if (label == 'Light Intensity') unit = 'lux';
          else if (label == 'Rainfall') unit = 'mm';
          return _buildParamStat(label, current, null, null, unit, isDarkMode);
        }).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  } else if (widget.deviceName.startsWith('CP')) {
    Map<String, String> parameterLabels = {
      'CurrentTemperature': 'Temperature',
      'CurrentHumidity': 'Humidity',
      'LightIntensity': 'Light Intensity',
      'RainfallMinutly': 'Rainfall',
      'WindSpeed': 'Wind Speed',
      'AtmPressure': 'Atm Pressure',
      'WindDirection': 'Wind Direction'
    };
    List<String> includedParameters = parameterLabels.keys.toList();

    List<Widget> children = csParametersData.entries
        .where((entry) => includedParameters.contains(entry.key))
        .map((entry) {
          String label = parameterLabels[entry.key] ?? entry.key;
          double? current = entry.value.isNotEmpty ? entry.value.last.value : null;
          String unit = '';
          if (label == 'Temperature') unit = '°C';
          else if (label == 'Humidity') unit = '%';
          else if (label == 'Light Intensity') unit = 'lux';
          else if (label == 'Rainfall') unit = 'mm';
          else if (label == 'Wind Speed') unit = 'm/s';
          else if (label == 'Atm Pressure') unit = 'hpa';
          else if (label == 'Wind Direction') unit = '°';
          return _buildParamStat(label, current, null, null, unit, isDarkMode);
        }).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }
  return Row(); // Default empty
}

// Helper to build param stat column
Widget _buildParamStat(String label, double? current, double? min, double? max, String unit, bool isDarkMode) {
  // Apply background color only if current value exists
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Container(
      color: current != null
          ? (isDarkMode ?  Colors.blueGrey[900] : Colors.grey[200])
          : Colors.transparent, // Transparent for undefined sensors
      padding: EdgeInsets.all(4.0), // Optional padding for the bar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ?  Colors.white : Colors.black,
            ),
          ),
          Text(
            '${current?.toStringAsFixed(2) ?? '-'} $unit',
            style: TextStyle(
              color: isDarkMode ?  Colors.white : Colors.black,
            ),
          ),
          if (min != null)
            Text(
              'Min: ${min.toStringAsFixed(2)} $unit',
              style: TextStyle(color: isDarkMode ?  Colors.white : Colors.black),
            ),
          if (max != null)
            Text(
              'Max: ${max.toStringAsFixed(2)} $unit',
              style: TextStyle(color: isDarkMode ?  Colors.white : Colors.black),
            ),
        ],
      ),
    ),
  );
}
  @override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  String _selectedRange = 'ee';

  // Calculate sidebar width based on screen size
  double sidebarWidth = MediaQuery.of(context).size.width < 800 ? 250 : 220;
  bool isMobile = MediaQuery.of(context).size.width < 800;

  return Scaffold(
    drawer: isMobile ? _buildDrawer(isDarkMode, context) : null,
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                      const Color.fromARGB(255, 192, 185, 185)!,
                      const Color.fromARGB(255, 123, 159, 174)!,
                    ]
                  : [
                      const Color.fromARGB(255, 126, 171, 166)!,
                      const Color.fromARGB(255, 54, 58, 59)!,
                    ],
            ),
          ),
        ),
       // Layout for larger screens (tablets and desktops)
if (!isMobile)
  Row(
    children: [
      // Left Navbar for larger screens
      Container(
        width: sidebarWidth,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and Device Name on the same line
           Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      SizedBox(width: 8),
      Text.rich(
        TextSpan(
          text: "${widget.sequentialName}\n", // Sequential name first, followed by newline
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: " (${widget.deviceName})", // Device name on next line
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
            // Time Period Selection
            Container(
              height: 64,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.blueGrey[900]! : Colors.grey[200]!,
                    width: 0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Select Time Period',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSidebarButton(
                      '1 Day',
                      'date',
                      Icons.today,
                      isDarkMode,
                      onPressed: () {
                        _selectDate();
                        setState(() {
                          _activeButton = 'date';
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    _buildSidebarButton(
                      'Last 7 Days',
                      '7days',
                      Icons.calendar_view_week,
                      isDarkMode,
                      onPressed: () {
                        _fetchDataForRange('7days');
                        setState(() {
                          _activeButton = '7days';
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    _buildSidebarButton(
                      'Last 30 Days',
                      '30days',
                      Icons.calendar_view_month,
                      isDarkMode,
                      onPressed: () {
                        _fetchDataForRange('30days');
                        setState(() {
                          _activeButton = '30days';
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    _buildSidebarButton(
                      'Last 3 Months',
                      '3months',
                      Icons.calendar_today,
                      isDarkMode,
                      onPressed: () {
                        _fetchDataForRange('3months');
                        setState(() {
                          _activeButton = '3months';
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    _buildSidebarButton(
                      'Last 1 Year',
                      '1year',
                      Icons.date_range,
                      isDarkMode,
                      onPressed: () {
                        _fetchDataForRange('1year');
                        setState(() {
                          _activeButton = '1year';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Main content area for larger screens
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal row with stats, battery, and reload
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              color: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MediaQuery.of(context).size.width < 1200
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildHorizontalStatsRow(isDarkMode),
                          )
                        : _buildHorizontalStatsRow(isDarkMode),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.deviceName.startsWith('WD'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getBatteryIcon(
                                  _parseBatteryPercentage(_lastBatteryPercentage),
                                ),
                                size: 26,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              SizedBox(width: 4),
                              Text(
                                ': $_lastBatteryPercentage',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.deviceName.startsWith('FS'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getfsBatteryIcon(_lastfsBattery),
                                    color: _getBatteryColor(_lastfsBattery),
                                    size: 28,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${_lastfsBattery.toStringAsFixed(2)} V',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (widget.deviceName.startsWith('SM'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getfsBatteryIcon(_lastsmBattery),
                                    color: _getBatteryColor(_lastsmBattery),
                                    size: 28,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${_lastsmBattery.toStringAsFixed(2)} V',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (widget.deviceName.startsWith('CF'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getfsBatteryIcon(_lastcfBattery),
                                    color: _getBatteryColor(_lastcfBattery),
                                    size: 28,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${_lastcfBattery.toStringAsFixed(2)} V',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (widget.deviceName.startsWith('VD'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getfsBatteryIcon(_lastvdBattery),
                                    color: _getBatteryColor(_lastvdBattery),
                                    size: 28,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${_lastvdBattery.toStringAsFixed(2)} V',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (widget.deviceName.startsWith('KD'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getfsBatteryIcon(_lastkdBattery),
                                    color: _getBatteryColor(_lastkdBattery),
                                    size: 28,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${_lastkdBattery.toStringAsFixed(2)} V',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (widget.deviceName.startsWith('NA'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getfsBatteryIcon(_lastNARLBattery),
                                    color: _getBatteryColor(_lastNARLBattery),
                                    size: 28,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${_lastNARLBattery.toStringAsFixed(2)} V',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (widget.deviceName.startsWith('CP'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getfsBatteryIcon(_lastcsBattery),
                                    color: _getBatteryColor(_lastcsBattery),
                                    size: 28,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${_lastcsBattery.toStringAsFixed(2)} V',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (widget.deviceName.startsWith('SV'))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getfsBatteryIcon(_lastsvBattery),
                                    color: _getBatteryColor(_lastsvBattery),
                                    size: 28,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${_lastsvBattery.toStringAsFixed(2)} V',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: IconButton(
                          icon: Icon(Icons.refresh,
                              color: isDarkMode ? Colors.white : Colors.black,
                              size: 26),
                          onPressed: () {
                            _reloadData();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
                    // Main Content Area
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(top: 0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Column(
                                      children: [
                                        SizedBox(height: 0),
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
                                              SizedBox(height: 0),
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
                                        if (widget.deviceName.startsWith('WF'))
                                          Column(
                                            children: [
                                              SizedBox(height: 0),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          WeatherForecastPage(
                                                        deviceName: widget.deviceName,
                                                        sequentialName: widget.sequentialName,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.cloud,
                                                      size: 40,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Weather Forecast',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        SizedBox(height: 0),
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
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  children: [
                                    if (widget.deviceName.startsWith('CL'))
                                      _buildCurrentValue('Chlorine Level',
                                          _currentChlorineValue, 'mg/L'),
                                    if (widget.deviceName.startsWith('20'))
                                      _buildCurrentValue(
                                          'Rain Level ', _currentrfdValue, 'mm'),
                                    () {
                                      if (widget.deviceName.startsWith('IT') &&
                                          iswinddirectionValid(_lastwinddirection) &&
                                          _lastwinddirection != null &&
                                          _lastwinddirection.isNotEmpty) {
                                        return _buildWindCompass(_lastwinddirection);
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    }(),
                                  ],
                                ),
                              ),
                              if (widget.deviceName.startsWith('WQ'))
                                buildStatisticsTable(),
                              if (widget.deviceName.startsWith('CB'))
                                buildCBStatisticsTable(),
                              if (widget.deviceName.startsWith('NH'))
                                buildNHStatisticsTable(),
                              if (widget.deviceName.startsWith('DO'))
                                buildDOStatisticsTable(),
                              if (widget.deviceName.startsWith('IT'))
                                buildITStatisticsTable(),
                              if (widget.deviceName.startsWith('FS'))
                                buildfsStatisticsTable(),
                              if (widget.deviceName.startsWith('WD211') ||
                                  (widget.deviceName.startsWith('WD511')))
                                SingleChildScrollView(
                                  child: Center(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        double screenWidth = constraints.maxWidth;
                                        bool isLargeScreen = screenWidth > 800;
                                        return isLargeScreen
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  buildWeatherStatisticsTable(),
                                                  SizedBox(width: 5),
                                                  buildRainDataTable(),
                                                ],
                                              )
                                            : Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  buildWeatherStatisticsTable(),
                                                  SizedBox(height: 5),
                                                  buildRainDataTable(),
                                                ],
                                              );
                                      },
                                    ),
                                  ),
                                ),
                              Column(
                                children: [
                                  if (widget.deviceName.startsWith('SM'))
                                    ...smParametersData.entries.map((entry) {
                                      String paramName = entry.key;
                                      List<ChartData> data = entry.value;
                                      List<String> excludedParams = [
                                        'Longitude',
                                        'Latitude',
                                        'SignalStrength',
                                        'BatteryVoltage',
                                        'TemperatureHourlyComulative',
                                        'LuxHourlyComulative',
                                        'PressureHourlyComulative',
                                        'HumidityHourlyComulative'
                                      ];
                                      if (!excludedParams.contains(paramName) &&
                                          data.isNotEmpty) {
                                        final displayInfo = _getParameterDisplayInfo(paramName);
                                        String displayName = displayInfo['displayName'];
                                        String unit = displayInfo['unit'];
                                        return _buildChartContainer(
                                          displayName,
                                          data,
                                          unit.isNotEmpty ? '$displayName ($unit)' : displayName,
                                          ChartType.line,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }).toList(),
                                  if (widget.deviceName.startsWith('CF'))
                                    ...cfParametersData.entries.map((entry) {
                                      String paramName = entry.key;
                                      List<ChartData> data = entry.value;
                                      List<String> excludedParams = [
                                        'Longitude',
                                        'Latitude',
                                        'SignalStrength',
                                        'BatteryVoltage',
                                        'MaximumTemperature',
                                        'MinimumTemperature',
                                        'AverageTemperature',
                                        'RainfallDaily',
                                        'RainfallWeekly',
                                        'AverageHumidity',
                                        'MinimumHumidity',
                                        'MaximumHumidity',
                                        'HumidityHourlyComulative',
                                        'PressureHourlyComulative',
                                        'LuxHourlyComulative',
                                        'TemperatureHourlyComulative',
                                      ];
                                      if (!excludedParams.contains(paramName) &&
                                          data.isNotEmpty) {
                                        final displayInfo = _getParameterDisplayInfo(paramName);
                                        String displayName = displayInfo['displayName'];
                                        String unit = displayInfo['unit'];
                                        String chartTitle;
                                        if (paramName.toLowerCase() == 'currenthumidity') {
                                          chartTitle = 'Humidity Graph ($unit)';
                                        } else if (paramName.toLowerCase() == 'currenttemperature') {
                                          chartTitle = 'Temperature Graph ($unit)';
                                        } else {
                                          chartTitle = unit.isNotEmpty
                                              ? '$displayName ($unit)'
                                              : displayName;
                                        }
                                        return _buildChartContainer(
                                          displayName,
                                          data,
                                          chartTitle,
                                          ChartType.line,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }).toList(),
                                  if (widget.deviceName.startsWith('VD'))
                                    ...vdParametersData.entries.map((entry) {
                                      String paramName = entry.key;
                                      List<ChartData> data = entry.value;
                                      List<String> excludedParams = [
                                        'Longitude',
                                        'Latitude',
                                        'SignalStrength',
                                        'BatteryVoltage',
                                        'MaximumTemperature',
                                        'MinimumTemperature',
                                        'AverageTemperature',
                                        'RainfallDaily',
                                        'RainfallWeekly',
                                        'AverageHumidity',
                                        'MinimumHumidity',
                                        'MaximumHumidity',
                                      ];
                                      if (!excludedParams.contains(paramName) &&
                                          data.isNotEmpty) {
                                        final displayInfo = _getParameterDisplayInfo(paramName);
                                        String displayName = displayInfo['displayName'];
                                        String unit = displayInfo['unit'];
                                        String chartTitle;
                                        if (paramName.toLowerCase() == 'currenthumidity') {
                                          chartTitle = 'Humidity Graph ($unit)';
                                        } else if (paramName.toLowerCase() == 'currenttemperature') {
                                          chartTitle = 'Temperature Graph ($unit)';
                                        } else {
                                          chartTitle = unit.isNotEmpty
                                              ? '$displayName ($unit)'
                                              : displayName;
                                        }
                                        return _buildChartContainer(
                                          displayName,
                                          data,
                                          chartTitle,
                                          ChartType.line,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }).toList(),
                                  if (widget.deviceName.startsWith('KD'))
                                    ...kdParametersData.entries.map((entry) {
                                      String paramName = entry.key;
                                      List<ChartData> data = entry.value;
                                      List<String> excludedParams = [
                                        'Longitude',
                                        'Latitude',
                                        'SignalStrength',
                                        'BatteryVoltage',
                                        'MaximumTemperature',
                                        'MinimumTemperature',
                                        'AverageTemperature',
                                        'RainfallDaily',
                                        'RainfallWeekly',
                                        'AverageHumidity',
                                        'MinimumHumidity',
                                        'MaximumHumidity',
                                      ];
                                      if (!excludedParams.contains(paramName) &&
                                          data.isNotEmpty) {
                                        final displayInfo = _getParameterDisplayInfo(paramName);
                                        String displayName = displayInfo['displayName'];
                                        String unit = displayInfo['unit'];
                                        String chartTitle;
                                        if (paramName.toLowerCase() == 'currenthumidity') {
                                          chartTitle = 'Humidity Graph ($unit)';
                                        } else if (paramName.toLowerCase() == 'currenttemperature') {
                                          chartTitle = 'Temperature Graph ($unit)';
                                        } else {
                                          chartTitle = unit.isNotEmpty
                                              ? '$displayName ($unit)'
                                              : displayName;
                                        }
                                        return _buildChartContainer(
                                          displayName,
                                          data,
                                          chartTitle,
                                          ChartType.line,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }).toList(),
                                  if (widget.deviceName.startsWith('NA'))
                                    ...NARLParametersData.entries.map((entry) {
                                      String paramName = entry.key;
                                      List<ChartData> data = entry.value;
                                      List<String> excludedParams = [
                                        'Longitude',
                                        'Latitude',
                                        'SignalStrength',
                                        'BatteryVoltage',
                                        'MaximumTemperature',
                                        'MinimumTemperature',
                                        'AverageTemperature',
                                        'RainfallDaily',
                                        'RainfallWeekly',
                                        'RainfallHourly',
                                        'AverageHumidity',
                                        'MinimumHumidity',
                                        'MaximumHumidity',
                                        'HumidityHourlyComulative',
                                        'PressureHourlyComulative',
                                        'LuxHourlyComulative',
                                        'TemperatureHourlyComulative',
                                      ];
                                      if (!excludedParams.contains(paramName) &&
                                          data.isNotEmpty) {
                                        final displayInfo = _getParameterDisplayInfo(paramName);
                                        String displayName = displayInfo['displayName'];
                                        String unit = displayInfo['unit'];
                                        String chartTitle;
                                        if (paramName.toLowerCase() == 'currenthumidity') {
                                          chartTitle = 'Humidity Graph ($unit)';
                                        } else if (paramName.toLowerCase() == 'currenttemperature') {
                                          chartTitle = 'Temperature Graph ($unit)';
                                        } else {
                                          chartTitle = unit.isNotEmpty
                                              ? '$displayName ($unit)'
                                              : displayName;
                                        }
                                        return _buildChartContainer(
                                          displayName,
                                          data,
                                          chartTitle,
                                          ChartType.line,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }).toList(),
                                  if (widget.deviceName.startsWith('CP'))
                                    ...csParametersData.entries.map((entry) {
                                      String paramName = entry.key;
                                      List<ChartData> data = entry.value;
                                      List<String> excludedParams = [
                                        'Longitude',
                                        'Latitude',
                                        'SignalStrength',
                                        'BatteryVoltage',
                                        'MaximumTemperature',
                                        'MinimumTemperature',
                                        'AverageTemperature',
                                        'RainfallHourly',
                                        'RainfallDaily',
                                        'RainfallWeekly',
                                        'AverageHumidity',
                                        'MinimumHumidity',
                                        'MaximumHumidity',
                                        'HumidityHourlyComulative',
                                        'PressureHourlyComulative',
                                        'LuxHourlyComulative',
                                        'TemperatureHourlyComulative',
                                      ];
                                      if (!excludedParams.contains(paramName) &&
                                          data.isNotEmpty) {
                                        final displayInfo = _getParameterDisplayInfo(paramName);
                                        String displayName = displayInfo['displayName'];
                                        String unit = displayInfo['unit'];
                                        String chartTitle;
                                        if (paramName.toLowerCase() == 'currenthumidity') {
                                          chartTitle = 'Humidity Graph ($unit)';
                                        } else if (paramName.toLowerCase() == 'currenttemperature') {
                                          chartTitle = 'Temperature Graph ($unit)';
                                        } else {
                                          chartTitle = unit.isNotEmpty
                                              ? '$displayName ($unit)'
                                              : displayName;
                                        }
                                        return _buildChartContainer(
                                          displayName,
                                          data,
                                          chartTitle,
                                          ChartType.line,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }).toList(),
                                  if (widget.deviceName.startsWith('SV'))
                                    ...svParametersData.entries.map((entry) {
                                      String paramName = entry.key;
                                      List<ChartData> data = entry.value;
                                      List<String> excludedParams = [
                                        'Longitude',
                                        'Latitude',
                                        'SignalStrength',
                                        'BatteryVoltage',
                                        'MaximumTemperature',
                                        'MinimumTemperature',
                                        'AverageTemperature',
                                        'RainfallDaily',
                                        'RainfallWeekly',
                                        'AverageHumidity',
                                        'MinimumHumidity',
                                        'MaximumHumidity',
                                        'HumidityHourlyComulative',
                                        'PressureHourlyComulative',
                                        'LuxHourlyComulative',
                                        'TemperatureHourlyComulative',
                                      ];
                                      if (!excludedParams.contains(paramName) &&
                                          data.isNotEmpty) {
                                        final displayInfo = _getParameterDisplayInfo(paramName);
                                        String displayName = displayInfo['displayName'];
                                        String unit = displayInfo['unit'];
                                        String chartTitle;
                                        if (paramName.toLowerCase() == 'currenthumidity') {
                                          chartTitle = 'Humidity Graph ($unit)';
                                        } else if (paramName.toLowerCase() == 'currenttemperature') {
                                          chartTitle = 'Temperature Graph ($unit)';
                                        } else {
                                          chartTitle = unit.isNotEmpty
                                              ? '$displayName ($unit)'
                                              : displayName;
                                        }
                                        return _buildChartContainer(
                                          displayName,
                                          data,
                                          chartTitle,
                                          ChartType.line,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }).toList(),
                                  if (!widget.deviceName.startsWith('SM') &&
                                      !widget.deviceName.startsWith('CM') &&
                                      !widget.deviceName.startsWith('SV')) ...[
                                    if (hasNonZeroValues(chlorineData))
                                      _buildChartContainer('Chlorine', chlorineData,
                                          'Chlorine (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(temperatureData))
                                      _buildChartContainer(
                                          'Temperature', temperatureData, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(humidityData))
                                      _buildChartContainer('Humidity', humidityData, 'Humidity (%)', ChartType.line),
                                    if (hasNonZeroValues(lightIntensityData))
                                      _buildChartContainer(
                                          'Light Intensity', lightIntensityData, 'Light Intensity (Lux)', ChartType.line),
                                    if (hasNonZeroValues(windSpeedData))
                                      _buildChartContainer(
                                          'Wind Speed', windSpeedData, 'Wind Speed (m/s)', ChartType.line),
                                    if (hasNonZeroValues(solarIrradianceData))
                                      _buildChartContainer(
                                          'Solar Irradiance', solarIrradianceData, 'Solar Irradiance (W/M^2)', ChartType.line),
                                    if (hasNonZeroValues(tempData))
                                      _buildChartContainer('Temperature', tempData, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(tdsData))
                                      _buildChartContainer('TDS', tdsData, 'TDS (ppm)', ChartType.line),
                                    if (hasNonZeroValues(codData))
                                      _buildChartContainer('COD', codData, 'COD (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(bodData))
                                      _buildChartContainer('BOD', bodData, 'BOD (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(pHData))
                                      _buildChartContainer('pH', pHData, 'pH', ChartType.line),
                                    if (hasNonZeroValues(doData))
                                      _buildChartContainer('DO', doData, 'DO (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(ecData))
                                      _buildChartContainer('EC', ecData, 'EC (mS/cm)', ChartType.line),
                                    if (hasNonZeroValues(temppData))
                                      _buildChartContainer('Temperature', temppData, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(electrodeSignalData))
                                      _buildChartContainer(
                                          'Electrode Signal', electrodeSignalData, 'Electrode Signal (mV)', ChartType.line),
                                    if (hasNonZeroValues(residualchlorineData))
                                      _buildChartContainer(
                                          'Chlorine', residualchlorineData, 'Chlorine (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(hypochlorousData))
                                      _buildChartContainer(
                                          'Hypochlorous', hypochlorousData, 'Hypochlorous (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(temmppData))
                                      _buildChartContainer(
                                          'Temperature', temmppData, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(humidityyData))
                                      _buildChartContainer('Humidity', humidityyData, 'Humidity (%)', ChartType.line),
                                    if (hasNonZeroValues(lightIntensityyData))
                                      _buildChartContainer(
                                          'Light Intensity', lightIntensityyData, 'Light Intensity (Lux)', ChartType.line),
                                    if (hasNonZeroValues(windSpeeddData))
                                      _buildChartContainer(
                                          'Wind Speed', windSpeeddData, 'Wind Speed (m/s)', ChartType.line),
                                    if (hasNonZeroValues(ttempData))
                                      _buildChartContainer('Temperature', ttempData, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(dovaluedata))
                                      _buildChartContainer('DO Value', dovaluedata, 'DO (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(dopercentagedata))
                                      _buildChartContainer(
                                          'DO Percentage', dopercentagedata, 'DO Percentage (%)', ChartType.line),
                                    if (hasNonZeroValues(temperaturData))
                                      _buildChartContainer(
                                          'Temperature', temperaturData, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(humData))
                                      _buildChartContainer('Humidity', humData, 'Humidity (%)', ChartType.line),
                                    if (hasNonZeroValues(luxData))
                                      _buildChartContainer('Light Intensity', luxData, 'Lux (Lux)', ChartType.line),
                                    if (hasNonZeroValues(coddata))
                                      _buildChartContainer('COD', coddata, 'COD (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(boddata))
                                      _buildChartContainer('BOD', boddata, 'BOD (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(phdata))
                                      _buildChartContainer('pH', phdata, 'pH', ChartType.line),
                                    if (hasNonZeroValues(temperattureData))
                                      _buildChartContainer(
                                          'Temperature', temperattureData, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(humidittyData))
                                      _buildChartContainer('Humidity', humidittyData, 'Humidity (%)', ChartType.line),
                                    if (hasNonZeroValues(ammoniaData))
                                      _buildChartContainer('Ammonia', ammoniaData, 'Ammonia (PPM)', ChartType.line),
                                    if (hasNonZeroValues(temperaturedata))
                                      _buildChartContainer(
                                          'Temperature', temperaturedata, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(humiditydata))
                                      _buildChartContainer('Humidity', humiditydata, 'Humidity (%)', ChartType.line),
                                    if (hasNonZeroValues(ittempData))
                                      _buildChartContainer('Temperature', ittempData, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(itpressureData))
                                      _buildChartContainer('Pressure', itpressureData, 'Pressure (hPa)', ChartType.line),
                                    if (hasNonZeroValues(ithumidityData))
                                      _buildChartContainer('Humidity', ithumidityData, 'Humidity (%)', ChartType.line),
                                    if (hasNonZeroValues(itrainData))
                                      _buildChartContainer('Rain Level', itrainData, 'Rain Level (mm)', ChartType.line),
                                    if (hasNonZeroValues(itvisibilityData))
                                      _buildChartContainer(
                                          'Wind Speed', itwindspeedData, 'Wind Speed (m/s)', ChartType.line),
                                    if (hasNonZeroValues(itradiationData))
                                      _buildChartContainer(
                                          'Radiation', itradiationData, 'Radiation (W/m²)', ChartType.line),
                                    if (hasNonZeroValues(itvisibilityData))
                                      _buildChartContainer('Visibilty', itvisibilityData, 'Visibility (m)', ChartType.line),
                                    if (hasNonZeroValues(fstempData))
                                      _buildChartContainer('Temperature', fstempData, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(fspressureData))
                                      _buildChartContainer('Pressure', fspressureData, 'Pressure (hPa)', ChartType.line),
                                    if (hasNonZeroValues(fshumidityData))
                                      _buildChartContainer(
                                          'Relative Humidity', fshumidityData, 'Humidity (%)', ChartType.line),
                                    if (hasNonZeroValues(fsrainData))
                                      _buildChartContainer('Rain Level', fsrainData, 'Rain Level (mm)', ChartType.line),
                                    if (hasNonZeroValues(fsradiationData))
                                      _buildChartContainer(
                                          'Radiation', fsradiationData, 'Radiation (W/m²)', ChartType.line),
                                    if (hasNonZeroValues(fswindspeedData))
                                      _buildChartContainer(
                                          'Wind Speed', fswindspeedData, 'Wind Speed (m/s)', ChartType.line),
                                    if (hasNonZeroValues(temp2Data))
                                      _buildChartContainer('Temperature', temp2Data, 'Temperature (°C)', ChartType.line),
                                    if (hasNonZeroValues(cod2Data))
                                      _buildChartContainer('COD', cod2Data, 'COD (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(bod2Data))
                                      _buildChartContainer('BOD', bod2Data, 'BOD (mg/L)', ChartType.line),
                                    if (hasNonZeroValues(wfAverageTemperatureData))
                                      _buildChartContainer(
                                          'Temperature', wfAverageTemperatureData, 'Temperature (°C)', ChartType.line),
                                    _buildChartContainer(
                                        'Rain Level', wfrainfallData, 'Rain Level (mm)', ChartType.line),
                                   ],
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
           ],
            ),
            
        // Layout for mobile and smaller screens
        if (isMobile)
          Column(
            children: [
              // AppBar for mobile
              AppBar(
                backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
                elevation: 0,
                title: Text.rich(
                  TextSpan(
                    text: "${widget.sequentialName}\n",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: MediaQuery.of(context).size.width < 800 ? 14 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: " (${widget.deviceName})",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 800 ? 14 : 30,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                actions: [
                  if (widget.deviceName.startsWith('WD'))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getBatteryIcon(
                              _parseBatteryPercentage(_lastBatteryPercentage),
                            ),
                            size: 26,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          SizedBox(width: 4),
                          Text(
                            ': $_lastBatteryPercentage',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.deviceName.startsWith('FS'))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getfsBatteryIcon(_lastfsBattery),
                                color: _getBatteryColor(_lastfsBattery),
                                size: 28,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${_lastfsBattery.toStringAsFixed(2)} V',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (widget.deviceName.startsWith('SM'))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getfsBatteryIcon(_lastsmBattery),
                                color: _getBatteryColor(_lastsmBattery),
                                size: 28,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${_lastsmBattery.toStringAsFixed(2)} V',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (widget.deviceName.startsWith('CF'))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getfsBatteryIcon(_lastcfBattery),
                                color: _getBatteryColor(_lastcfBattery),
                                size: 28,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${_lastcfBattery.toStringAsFixed(2)} V',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (widget.deviceName.startsWith('VD'))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getfsBatteryIcon(_lastvdBattery),
                                color: _getBatteryColor(_lastvdBattery),
                                size: 28,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${_lastvdBattery.toStringAsFixed(2)} V',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (widget.deviceName.startsWith('KD'))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getfsBatteryIcon(_lastkdBattery),
                                color: _getBatteryColor(_lastkdBattery),
                                size: 28,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${_lastkdBattery.toStringAsFixed(2)} V',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (widget.deviceName.startsWith('NA'))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getfsBatteryIcon(_lastNARLBattery),
                                color: _getBatteryColor(_lastNARLBattery),
                                size: 28,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${_lastNARLBattery.toStringAsFixed(2)} V',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (widget.deviceName.startsWith('CP'))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getfsBatteryIcon(_lastcsBattery),
                                color: _getBatteryColor(_lastcsBattery),
                                size: 28,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${_lastcsBattery.toStringAsFixed(2)} V',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (widget.deviceName.startsWith('SV'))
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getfsBatteryIcon(_lastsvBattery),
                                color: _getBatteryColor(_lastsvBattery),
                                size: 28,
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${_lastsvBattery.toStringAsFixed(2)} V',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      icon: Icon(Icons.refresh,
                          color: isDarkMode ? Colors.white : Colors.black,
                          size: 26),
                      onPressed: () {
                        _reloadData();
                      },
                    ),
                  ),
                ],
              ),
              // Content area below AppBar
              Expanded(
                child: Row(
                  children: [
                    // Left Sidebar - Only show on large screens
                    if (!isMobile)
                      Container(
                        width: sidebarWidth,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(2, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 64,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDarkMode ? Colors.blueGrey[900]! : Colors.grey[200]!,
                                    width: 0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Select Time Period',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontSize: MediaQuery.of(context).size.width < 800 ? 14 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildSidebarButton(
                                      '1 Day',
                                      'date',
                                      Icons.today,
                                      isDarkMode,
                                      onPressed: () {
                                        _selectDate();
                                        setState(() {
                                          _activeButton = 'date';
                                        });
                                      },
                                    ),
                                    SizedBox(height: 8),
                                    _buildSidebarButton(
                                      'Last 7 Days',
                                      '7days',
                                      Icons.calendar_view_week,
                                      isDarkMode,
                                      onPressed: () {
                                        _fetchDataForRange('7days');
                                        setState(() {
                                          _activeButton = '7days';
                                        });
                                      },
                                    ),
                                    SizedBox(height: 8),
                                    _buildSidebarButton(
                                      'Last 30 Days',
                                      '30days',
                                      Icons.calendar_view_month,
                                      isDarkMode,
                                      onPressed: () {
                                        _fetchDataForRange('30days');
                                        setState(() {
                                          _activeButton = '30days';
                                        });
                                      },
                                    ),
                                    SizedBox(height: 8),
                                    _buildSidebarButton(
                                      'Last 3 Months',
                                      '3months',
                                      Icons.calendar_today,
                                      isDarkMode,
                                      onPressed: () {
                                        _fetchDataForRange('3months');
                                        setState(() {
                                          _activeButton = '3months';
                                        });
                                      },
                                    ),
                                    SizedBox(height: 8),
                                    _buildSidebarButton(
                                      'Last 1 Year',
                                      '1year',
                                      Icons.date_range,
                                      isDarkMode,
                                      onPressed: () {
                                        _fetchDataForRange('1year');
                                        setState(() {
                                          _activeButton = '1year';
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Main content area
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            color: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
                            child: MediaQuery.of(context).size.width < 1200
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: _buildHorizontalStatsRow(isDarkMode),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: _buildHorizontalStatsRow(isDarkMode),
                                      ),
                                    ],
                                  ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.only(top: 0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Column(
                                            children: [
                                              SizedBox(height: 0),
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
                                                    SizedBox(height: 0),
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
                                              if (widget.deviceName.startsWith('WF'))
                                                Column(
                                                  children: [
                                                    SizedBox(height: 0),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                WeatherForecastPage(
                                                              deviceName: widget.deviceName,
                                                              sequentialName: widget.sequentialName,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons.cloud,
                                                            size: 40,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            'Weather Forecast',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 20,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              SizedBox(height: 0),
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
                                      padding: const EdgeInsets.all(0.0),
                                      child: Column(
                                        children: [
                                          if (widget.deviceName.startsWith('CL'))
                                            _buildCurrentValue('Chlorine Level',
                                                _currentChlorineValue, 'mg/L'),
                                          if (widget.deviceName.startsWith('20'))
                                            _buildCurrentValue(
                                                'Rain Level ', _currentrfdValue, 'mm'),
                                          () {
                                            if (widget.deviceName.startsWith('IT') &&
                                                iswinddirectionValid(_lastwinddirection) &&
                                                _lastwinddirection != null &&
                                                _lastwinddirection.isNotEmpty) {
                                              return _buildWindCompass(_lastwinddirection);
                                            } else {
                                              return SizedBox.shrink();
                                            }
                                          }(),
                                        ],
                                      ),
                                    ),
                                    if (widget.deviceName.startsWith('WQ'))
                                      buildStatisticsTable(),
                                    if (widget.deviceName.startsWith('CB'))
                                      buildCBStatisticsTable(),
                                    if (widget.deviceName.startsWith('NH'))
                                      buildNHStatisticsTable(),
                                    if (widget.deviceName.startsWith('DO'))
                                      buildDOStatisticsTable(),
                                    if (widget.deviceName.startsWith('IT'))
                                      buildITStatisticsTable(),
                                    if (widget.deviceName.startsWith('FS'))
                                      buildfsStatisticsTable(),
                                    if (widget.deviceName.startsWith('WD211') ||
                                        (widget.deviceName.startsWith('WD511')))
                                      SingleChildScrollView(
                                        child: Center(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              double screenWidth = constraints.maxWidth;
                                              bool isLargeScreen = screenWidth > 800;
                                              return isLargeScreen
                                                  ? Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        buildWeatherStatisticsTable(),
                                                        SizedBox(width: 5),
                                                        buildRainDataTable(),
                                                      ],
                                                    )
                                                  : Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        buildWeatherStatisticsTable(),
                                                        SizedBox(height: 5),
                                                        buildRainDataTable(),
                                                      ],
                                                    );
                                            },
                                          ),
                                        ),
                                      ),
                                    Column(
                                      children: [
                                        if (widget.deviceName.startsWith('SM'))
                                          ...smParametersData.entries.map((entry) {
                                            String paramName = entry.key;
                                            List<ChartData> data = entry.value;
                                            List<String> excludedParams = [
                                              'Longitude',
                                              'Latitude',
                                              'SignalStrength',
                                              'BatteryVoltage',
                                              'TemperatureHourlyComulative',
                                              'LuxHourlyComulative',
                                              'PressureHourlyComulative',
                                              'HumidityHourlyComulative'
                                            ];
                                            if (!excludedParams.contains(paramName) &&
                                                data.isNotEmpty) {
                                              final displayInfo = _getParameterDisplayInfo(paramName);
                                              String displayName = displayInfo['displayName'];
                                              String unit = displayInfo['unit'];
                                              return _buildChartContainer(
                                                displayName,
                                                data,
                                                unit.isNotEmpty ? '$displayName ($unit)' : displayName,
                                                ChartType.line,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }).toList(),
                                        if (widget.deviceName.startsWith('CF'))
                                          ...cfParametersData.entries.map((entry) {
                                            String paramName = entry.key;
                                            List<ChartData> data = entry.value;
                                            List<String> excludedParams = [
                                              'Longitude',
                                              'Latitude',
                                              'SignalStrength',
                                              'BatteryVoltage',
                                              'MaximumTemperature',
                                              'MinimumTemperature',
                                              'AverageTemperature',
                                              'RainfallDaily',
                                              'RainfallWeekly',
                                              'AverageHumidity',
                                              'MinimumHumidity',
                                              'MaximumHumidity',
                                              'HumidityHourlyComulative',
                                              'PressureHourlyComulative',
                                              'LuxHourlyComulative',
                                              'TemperatureHourlyComulative',
                                            ];
                                            if (!excludedParams.contains(paramName) &&
                                                data.isNotEmpty) {
                                              final displayInfo = _getParameterDisplayInfo(paramName);
                                              String displayName = displayInfo['displayName'];
                                              String unit = displayInfo['unit'];
                                              String chartTitle;
                                              if (paramName.toLowerCase() == 'currenthumidity') {
                                                chartTitle = 'Humidity Graph ($unit)';
                                              } else if (paramName.toLowerCase() == 'currenttemperature') {
                                                chartTitle = 'Temperature Graph ($unit)';
                                              } else {
                                                chartTitle = unit.isNotEmpty
                                                    ? '$displayName ($unit)'
                                                    : displayName;
                                              }
                                              return _buildChartContainer(
                                                displayName,
                                                data,
                                                chartTitle,
                                                ChartType.line,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }).toList(),
                                        if (widget.deviceName.startsWith('VD'))
                                          ...vdParametersData.entries.map((entry) {
                                            String paramName = entry.key;
                                            List<ChartData> data = entry.value;
                                            List<String> excludedParams = [
                                              'Longitude',
                                              'Latitude',
                                              'SignalStrength',
                                              'BatteryVoltage',
                                              'MaximumTemperature',
                                              'MinimumTemperature',
                                              'AverageTemperature',
                                              'RainfallDaily',
                                              'RainfallWeekly',
                                              'AverageHumidity',
                                              'MinimumHumidity',
                                              'MaximumHumidity',
                                            ];
                                            if (!excludedParams.contains(paramName) &&
                                                data.isNotEmpty) {
                                              final displayInfo = _getParameterDisplayInfo(paramName);
                                              String displayName = displayInfo['displayName'];
                                              String unit = displayInfo['unit'];
                                              String chartTitle;
                                              if (paramName.toLowerCase() == 'currenthumidity') {
                                                chartTitle = 'Humidity Graph ($unit)';
                                              } else if (paramName.toLowerCase() == 'currenttemperature') {
                                                chartTitle = 'Temperature Graph ($unit)';
                                              } else {
                                                chartTitle = unit.isNotEmpty
                                                    ? '$displayName ($unit)'
                                                    : displayName;
                                              }
                                              return _buildChartContainer(
                                                displayName,
                                                data,
                                                chartTitle,
                                                ChartType.line,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }).toList(),
                                        if (widget.deviceName.startsWith('KD'))
                                          ...kdParametersData.entries.map((entry) {
                                            String paramName = entry.key;
                                            List<ChartData> data = entry.value;
                                            List<String> excludedParams = [
                                              'Longitude',
                                              'Latitude',
                                              'SignalStrength',
                                              'BatteryVoltage',
                                              'MaximumTemperature',
                                              'MinimumTemperature',
                                              'AverageTemperature',
                                              'RainfallDaily',
                                              'RainfallWeekly',
                                              'AverageHumidity',
                                              'MinimumHumidity',
                                              'MaximumHumidity',
                                            ];
                                            if (!excludedParams.contains(paramName) &&
                                                data.isNotEmpty) {
                                              final displayInfo = _getParameterDisplayInfo(paramName);
                                              String displayName = displayInfo['displayName'];
                                              String unit = displayInfo['unit'];
                                              String chartTitle;
                                              if (paramName.toLowerCase() == 'currenthumidity') {
                                                chartTitle = 'Humidity Graph ($unit)';
                                              } else if (paramName.toLowerCase() == 'currenttemperature') {
                                                chartTitle = 'Temperature Graph ($unit)';
                                              } else {
                                                chartTitle = unit.isNotEmpty
                                                    ? '$displayName ($unit)'
                                                    : displayName;
                                              }
                                              return _buildChartContainer(
                                                displayName,
                                                data,
                                                chartTitle,
                                                ChartType.line,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }).toList(),
                                        if (widget.deviceName.startsWith('NA'))
                                          ...NARLParametersData.entries.map((entry) {
                                            String paramName = entry.key;
                                            List<ChartData> data = entry.value;
                                            List<String> excludedParams = [
                                              'Longitude',
                                              'Latitude',
                                              'SignalStrength',
                                              'BatteryVoltage',
                                              'MaximumTemperature',
                                              'MinimumTemperature',
                                              'AverageTemperature',
                                              'RainfallDaily',
                                              'RainfallWeekly',
                                              'RainfallHourly',
                                              'AverageHumidity',
                                              'MinimumHumidity',
                                              'MaximumHumidity',
                                              'HumidityHourlyComulative',
                                              'PressureHourlyComulative',
                                              'LuxHourlyComulative',
                                              'TemperatureHourlyComulative',
                                            ];
                                            if (!excludedParams.contains(paramName) &&
                                                data.isNotEmpty) {
                                              final displayInfo = _getParameterDisplayInfo(paramName);
                                              String displayName = displayInfo['displayName'];
                                              String unit = displayInfo['unit'];
                                              String chartTitle;
                                              if (paramName.toLowerCase() == 'currenthumidity') {
                                                chartTitle = 'Humidity Graph ($unit)';
                                              } else if (paramName.toLowerCase() == 'currenttemperature') {
                                                chartTitle = 'Temperature Graph ($unit)';
                                              } else {
                                                chartTitle = unit.isNotEmpty
                                                    ? '$displayName ($unit)'
                                                    : displayName;
                                              }
                                              return _buildChartContainer(
                                                displayName,
                                                data,
                                                chartTitle,
                                                ChartType.line,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }).toList(),
                                        if (widget.deviceName.startsWith('CP'))
                                          ...csParametersData.entries.map((entry) {
                                            String paramName = entry.key;
                                            List<ChartData> data = entry.value;
                                            List<String> excludedParams = [
                                              'Longitude',
                                              'Latitude',
                                              'SignalStrength',
                                              'BatteryVoltage',
                                              'MaximumTemperature',
                                              'MinimumTemperature',
                                              'AverageTemperature',
                                              'RainfallHourly',
                                              'RainfallDaily',
                                              'RainfallWeekly',
                                              'AverageHumidity',
                                              'MinimumHumidity',
                                              'MaximumHumidity',
                                              'HumidityHourlyComulative',
                                              'PressureHourlyComulative',
                                              'LuxHourlyComulative',
                                              'TemperatureHourlyComulative',
                                            ];
                                            if (!excludedParams.contains(paramName) &&
                                                data.isNotEmpty) {
                                              final displayInfo = _getParameterDisplayInfo(paramName);
                                              String displayName = displayInfo['displayName'];
                                              String unit = displayInfo['unit'];
                                              String chartTitle;
                                              if (paramName.toLowerCase() == 'currenthumidity') {
                                                chartTitle = 'Humidity Graph ($unit)';
                                              } else if (paramName.toLowerCase() == 'currenttemperature') {
                                                chartTitle = 'Temperature Graph ($unit)';
                                              } else {
                                                chartTitle = unit.isNotEmpty
                                                    ? '$displayName ($unit)'
                                                    : displayName;
                                              }
                                              return _buildChartContainer(
                                                displayName,
                                                data,
                                                chartTitle,
                                                ChartType.line,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }).toList(),
                                        if (widget.deviceName.startsWith('SV'))
                                          ...svParametersData.entries.map((entry) {
                                            String paramName = entry.key;
                                            List<ChartData> data = entry.value;
                                            List<String> excludedParams = [
                                              'Longitude',
                                              'Latitude',
                                              'SignalStrength',
                                              'BatteryVoltage',
                                              'MaximumTemperature',
                                              'MinimumTemperature',
                                              'AverageTemperature',
                                              'RainfallDaily',
                                              'RainfallWeekly',
                                              'AverageHumidity',
                                              'MinimumHumidity',
                                              'MaximumHumidity',
                                              'HumidityHourlyComulative',
                                              'PressureHourlyComulative',
                                              'LuxHourlyComulative',
                                              'TemperatureHourlyComulative',
                                            ];
                                            if (!excludedParams.contains(paramName) &&
                                                data.isNotEmpty) {
                                              final displayInfo = _getParameterDisplayInfo(paramName);
                                              String displayName = displayInfo['displayName'];
                                              String unit = displayInfo['unit'];
                                              String chartTitle;
                                              if (paramName.toLowerCase() == 'currenthumidity') {
                                                chartTitle = 'Humidity Graph ($unit)';
                                              } else if (paramName.toLowerCase() == 'currenttemperature') {
                                                chartTitle = 'Temperature Graph ($unit)';
                                              } else {
                                                chartTitle = unit.isNotEmpty
                                                    ? '$displayName ($unit)'
                                                    : displayName;
                                              }
                                              return _buildChartContainer(
                                                displayName,
                                                data,
                                                chartTitle,
                                                ChartType.line,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }).toList(),
                                        if (!widget.deviceName.startsWith('SM') &&
                                            !widget.deviceName.startsWith('CM') &&
                                            !widget.deviceName.startsWith('SV')) ...[
                                          if (hasNonZeroValues(chlorineData))
                                            _buildChartContainer('Chlorine', chlorineData,
                                                'Chlorine (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(temperatureData))
                                            _buildChartContainer(
                                                'Temperature', temperatureData, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(humidityData))
                                            _buildChartContainer('Humidity', humidityData, 'Humidity (%)', ChartType.line),
                                          if (hasNonZeroValues(lightIntensityData))
                                            _buildChartContainer(
                                                'Light Intensity', lightIntensityData, 'Light Intensity (Lux)', ChartType.line),
                                          if (hasNonZeroValues(windSpeedData))
                                            _buildChartContainer(
                                                'Wind Speed', windSpeedData, 'Wind Speed (m/s)', ChartType.line),
                                          if (hasNonZeroValues(solarIrradianceData))
                                            _buildChartContainer(
                                                'Solar Irradiance', solarIrradianceData, 'Solar Irradiance (W/M^2)', ChartType.line),
                                          if (hasNonZeroValues(tempData))
                                            _buildChartContainer('Temperature', tempData, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(tdsData))
                                            _buildChartContainer('TDS', tdsData, 'TDS (ppm)', ChartType.line),
                                          if (hasNonZeroValues(codData))
                                            _buildChartContainer('COD', codData, 'COD (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(bodData))
                                            _buildChartContainer('BOD', bodData, 'BOD (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(pHData))
                                            _buildChartContainer('pH', pHData, 'pH', ChartType.line),
                                          if (hasNonZeroValues(doData))
                                            _buildChartContainer('DO', doData, 'DO (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(ecData))
                                            _buildChartContainer('EC', ecData, 'EC (mS/cm)', ChartType.line),
                                          if (hasNonZeroValues(temppData))
                                            _buildChartContainer('Temperature', temppData, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(electrodeSignalData))
                                            _buildChartContainer(
                                                'Electrode Signal', electrodeSignalData, 'Electrode Signal (mV)', ChartType.line),
                                          if (hasNonZeroValues(residualchlorineData))
                                            _buildChartContainer(
                                                'Chlorine', residualchlorineData, 'Chlorine (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(hypochlorousData))
                                            _buildChartContainer(
                                                'Hypochlorous', hypochlorousData, 'Hypochlorous (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(temmppData))
                                            _buildChartContainer(
                                                'Temperature', temmppData, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(humidityyData))
                                            _buildChartContainer('Humidity', humidityyData, 'Humidity (%)', ChartType.line),
                                          if (hasNonZeroValues(lightIntensityyData))
                                            _buildChartContainer(
                                                'Light Intensity', lightIntensityyData, 'Light Intensity (Lux)', ChartType.line),
                                          if (hasNonZeroValues(windSpeeddData))
                                            _buildChartContainer(
                                                'Wind Speed', windSpeeddData, 'Wind Speed (m/s)', ChartType.line),
                                          if (hasNonZeroValues(ttempData))
                                            _buildChartContainer('Temperature', ttempData, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(dovaluedata))
                                            _buildChartContainer('DO Value', dovaluedata, 'DO (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(dopercentagedata))
                                            _buildChartContainer(
                                                'DO Percentage', dopercentagedata, 'DO Percentage (%)', ChartType.line),
                                          if (hasNonZeroValues(temperaturData))
                                            _buildChartContainer(
                                                'Temperature', temperaturData, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(humData))
                                            _buildChartContainer('Humidity', humData, 'Humidity (%)', ChartType.line),
                                          if (hasNonZeroValues(luxData))
                                            _buildChartContainer('Light Intensity', luxData, 'Lux (Lux)', ChartType.line),
                                          if (hasNonZeroValues(coddata))
                                            _buildChartContainer('COD', coddata, 'COD (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(boddata))
                                            _buildChartContainer('BOD', boddata, 'BOD (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(phdata))
                                            _buildChartContainer('pH', phdata, 'pH', ChartType.line),
                                          if (hasNonZeroValues(temperattureData))
                                            _buildChartContainer(
                                                'Temperature', temperattureData, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(humidittyData))
                                            _buildChartContainer('Humidity', humidittyData, 'Humidity (%)', ChartType.line),
                                          if (hasNonZeroValues(ammoniaData))
                                            _buildChartContainer('Ammonia', ammoniaData, 'Ammonia (PPM)', ChartType.line),
                                          if (hasNonZeroValues(temperaturedata))
                                            _buildChartContainer(
                                                'Temperature', temperaturedata, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(humiditydata))
                                            _buildChartContainer('Humidity', humiditydata, 'Humidity (%)', ChartType.line),
                                          if (hasNonZeroValues(ittempData))
                                            _buildChartContainer('Temperature', ittempData, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(itpressureData))
                                            _buildChartContainer('Pressure', itpressureData, 'Pressure (hPa)', ChartType.line),
                                          if (hasNonZeroValues(ithumidityData))
                                            _buildChartContainer('Humidity', ithumidityData, 'Humidity (%)', ChartType.line),
                                          if (hasNonZeroValues(itrainData))
                                            _buildChartContainer('Rain Level', itrainData, 'Rain Level (mm)', ChartType.line),
                                          if (hasNonZeroValues(itvisibilityData))
                                            _buildChartContainer(
                                                'Wind Speed', itwindspeedData, 'Wind Speed (m/s)', ChartType.line),
                                          if (hasNonZeroValues(itradiationData))
                                            _buildChartContainer(
                                                'Radiation', itradiationData, 'Radiation (W/m²)', ChartType.line),
                                          if (hasNonZeroValues(itvisibilityData))
                                            _buildChartContainer('Visibilty', itvisibilityData, 'Visibility (m)', ChartType.line),
                                          if (hasNonZeroValues(fstempData))
                                            _buildChartContainer('Temperature', fstempData, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(fspressureData))
                                            _buildChartContainer('Pressure', fspressureData, 'Pressure (hPa)', ChartType.line),
                                          if (hasNonZeroValues(fshumidityData))
                                            _buildChartContainer(
                                                'Relative Humidity', fshumidityData, 'Humidity (%)', ChartType.line),
                                          if (hasNonZeroValues(fsrainData))
                                            _buildChartContainer('Rain Level', fsrainData, 'Rain Level (mm)', ChartType.line),
                                          if (hasNonZeroValues(fsradiationData))
                                            _buildChartContainer(
                                                'Radiation', fsradiationData, 'Radiation (W/m²)', ChartType.line),
                                          if (hasNonZeroValues(fswindspeedData))
                                            _buildChartContainer(
                                                'Wind Speed', fswindspeedData, 'Wind Speed (m/s)', ChartType.line),
                                          if (hasNonZeroValues(temp2Data))
                                            _buildChartContainer('Temperature', temp2Data, 'Temperature (°C)', ChartType.line),
                                          if (hasNonZeroValues(cod2Data))
                                            _buildChartContainer('COD', cod2Data, 'COD (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(bod2Data))
                                            _buildChartContainer('BOD', bod2Data, 'BOD (mg/L)', ChartType.line),
                                          if (hasNonZeroValues(wfAverageTemperatureData))
                                            _buildChartContainer(
                                                'Temperature', wfAverageTemperatureData, 'Temperature (°C)', ChartType.line),
                                          _buildChartContainer(
                                              'Rain Level', wfrainfallData, 'Rain Level (mm)', ChartType.line),
                                        ],
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
           ],
            ),
          ),
           ],
            ),
          
        // Loader overlay
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        // Download CSV button
        Positioned(
          bottom: 16,
          right: 16,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: ElevatedButton(
              onPressed: () {
                _showDownloadOptionsDialog(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 40, 41, 41),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download,
                    color: _isHovering ? Colors.blue : Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Download CSV',
                    style: TextStyle(
                      color: _isHovering ? Colors.blue : Colors.white,
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

// Helper method to build sidebar buttons
  Widget _buildSidebarButton(
    String title,
    String value,
    IconData icon,
    bool isDarkMode, {
    required VoidCallback onPressed,
  }) {
    bool isActive = _activeButton == value;

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? (isDarkMode ? Colors.blue[700] : Colors.blue[600])
              : (isDarkMode
                  ? Colors.grey[700]!.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9)),
          foregroundColor: isActive
              ? Colors.white
              : (isDarkMode ? Colors.white : Colors.black),
          elevation: isActive ? 4 : 1,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isActive
                  ? (isDarkMode ? Colors.blue[400]! : Colors.blue[300]!)
                  : (isDarkMode ? Colors.grey[600]! : Colors.grey[400]!),
              width: isActive ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? Colors.white
                  : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
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
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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

  Color _getBatteryColor(double voltage) {
    if (voltage < 3.3) {
      return Colors.red;
    } else if (voltage < 4.0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getfsBatteryIcon(double voltage) {
    if (voltage < 3.3) {
      return Icons.battery_2_bar; // Low battery
    } else if (voltage < 4.0) {
      return Icons.battery_5_bar; // Medium battery
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
                              if (event is PointerScrollEvent &&
                                  isShiftPressed) {}
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
                                majorGridLines: MajorGridLines(
                                  width: 1.0,
                                  dashArray: [
                                    5,
                                    5
                                  ], // <-- Makes vertical grid lines dotted
                                  color:
                                      const Color.fromARGB(255, 141, 144, 148),
                                ),
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
                             trackballBehavior: TrackballBehavior(
  enable: true,
  activationMode: ActivationMode.singleTap,
  lineType: TrackballLineType.vertical,
  lineColor: Colors.blue,
  lineWidth: 1,
  markerSettings: const TrackballMarkerSettings(
    markerVisibility: TrackballVisibilityMode.visible,
    width: 8,
    height: 8,
    borderWidth: 2,
    color: Colors.blue,
  ),
  builder: (BuildContext context, TrackballDetails details) {
    try {
      final DateTime? time = details.point?.x;
      final num? value = details.point?.y;

      if (time == null || value == null) {
        return const SizedBox();
      }

      // ✅ Format: only "1year" removes time, rest show date + time
      String formattedDate;
      if (_lastSelectedRange == '1year') {
        formattedDate = DateFormat('MM/dd').format(time); // only date
      } else {
        formattedDate = DateFormat('MM/dd hh:mm a').format(time); // date + time
      }

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(200, 0, 0, 0),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Value: $value',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  },
),


                              zoomPanBehavior: ZoomPanBehavior(
                                zoomMode: ZoomMode.x,
                                enablePanning: true,
                                enablePinching: true,
                                enableMouseWheelZooming: isShiftPressed,
                              ),
                              series: <CartesianSeries<ChartData, DateTime>>[
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

  CartesianSeries<ChartData, DateTime> _getChartSeries(
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
          // Other devices — blue gradient
          return AreaSeries<ChartData, DateTime>(
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.timestamp,
            yValueMapper: (ChartData data, _) => data.value,
            name: title,
            borderColor: Colors.blue, // Line color
            borderWidth: 2,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.4),
                Colors.blue.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            markerSettings: const MarkerSettings(isVisible: false),
          );
        }

      default:
        return AreaSeries<ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: title,
          borderColor: Colors.blue,
          borderWidth: 2,
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.4),
              Colors.blue.withOpacity(0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          markerSettings: const MarkerSettings(isVisible: false),
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
