import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_sense_webapp/devicelocationinfo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures Flutter bindings are initialized before running the app (needed for async ops like SharedPreferences).
  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          ThemeProvider(), // Provides theme state management across the app.
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Cloud Sense Vis',
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode =>
      _isDarkMode; // Getter to access the current theme mode.

  ThemeProvider() {
    _loadTheme(); // Load saved theme preference on initialization.
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode; // Toggle between dark and light modes.
    notifyListeners(); // Notify all listeners about the theme change.

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode); // Save theme preference.
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode =
        prefs.getBool('isDarkMode') ?? false; // Default to light theme.
    notifyListeners(); // Ensure UI updates after loading saved theme.
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color _aboutUsColor = const Color.fromARGB(255, 235, 232, 232);
  Color _loginTestColor = const Color.fromARGB(255, 235, 232, 232);
  Color _accountinfoColor = const Color.fromARGB(255, 235, 232, 232);
  Color _devicemapinfoColor = const Color.fromARGB(255, 235, 232, 232);

  int _totalDevices = 0; // Stores total devices from API

  bool isHovered = false;
  @override
  void initState() {
    super.initState();
    _fetchDeviceData();
  }

  Future<void> _fetchDeviceData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://xa9ry8sls0.execute-api.us-east-1.amazonaws.com/CloudSense_device_activity_api_function',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final wsDevices = data['WS_Device_Activity'] ?? [];
        final awadhDevices = data['Awadh_Jio_Device_Activity'] ?? [];
        final weatherDevices = data['weather_Device_Activity'] ?? [];

        final totalCount =
            wsDevices.length + awadhDevices.length + weatherDevices.length;

        setState(() {
          _totalDevices = totalCount;
        });
      } else {
        print('Failed to load device data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching device data: $e');
    }
  }

  Future<void> _handleLoginNavigation() async {
    try {
      var currentUser = await Amplify.Auth.getCurrentUser();
      var userAttributes = await Amplify.Auth.fetchUserAttributes();
      String? email;
      for (var attr in userAttributes) {
        if (attr.userAttributeKey == AuthUserAttributeKey.email) {
          email = attr.value;
          break;
        }
      }
      print('Current user ID: ${currentUser.username}, Email: $email');
      if (email?.trim().toLowerCase() == '05agriculture.05@gmail.com') {
        print('Navigating to MapPage (/deviceinfo)');
        Navigator.pushNamed(context, '/deviceinfo');
      } else {
        print('Navigating to DeviceListPage (/devicelist)');
        Navigator.pushNamed(context, '/devicelist');
      }
    } catch (e) {
      print('No user logged in or error: $e');
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Responsive font sizes
    double titleFont = screenWidth < 800
        ? 28
        : screenWidth < 1024
            ? 48
            : 60;
    double subtitleFont = screenWidth < 600
        ? 18
        : screenWidth < 1024
            ? 22
            : 30;
    double paragraphFont = screenWidth < 600
        ? 14
        : screenWidth < 1024
            ? 18
            : 18;

    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;
      bool isTablet =
          constraints.maxWidth >= 800 && constraints.maxWidth <= 1024;
      final horizontalPadding = isMobile ? 0.0 : (isTablet ? 120.0 : 280.0);

      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.white,
          title: Padding(
            padding: EdgeInsets.only(left: horizontalPadding),
            child: Row(
              children: [
                Icon(Icons.cloud,
                    color: isDarkMode ? Colors.white : Colors.black),
                SizedBox(width: isMobile ? 10 : (isTablet ? 15 : 20)),
                Text(
                  'Cloud Sense Vis',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 20 : (isTablet ? 26 : 32),
                  ),
                ),
                Spacer(),
                if (isMobile)
                  IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => themeProvider.toggleTheme(),
                  ),
                if (!isMobile)
                  Padding(
                    padding: EdgeInsets.only(right: horizontalPadding),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            themeProvider.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onPressed: () => themeProvider.toggleTheme(),
                        ),
                        SizedBox(width: isTablet ? 12 : 20),
                        _buildNavButton(
                          'LOGIN/SIGNUP',
                          _loginTestColor,
                          _handleLoginNavigation,
                          fontSize: isTablet ? 14 : 16,
                        ),
                        SizedBox(width: isTablet ? 14 : 20),
                        _buildNavButton(
                          'ACCOUNT INFO',
                          _accountinfoColor,
                          () => Navigator.pushNamed(context, '/accountinfo'),
                          fontSize: isTablet ? 14 : 16,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        endDrawer: isMobile
            ? Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(color: Colors.grey[900]),
                      child: Text(
                        'Menu',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.login),
                      title: Text('LOGIN/SIGNUP'),
                      onTap: _handleLoginNavigation,
                    ),
                    ListTile(
                      leading: Icon(Icons.login),
                      title: Text('ACCOUNT INFO'),
                      onTap: () {
                        Navigator.pushNamed(context, '/accountinfo');
                      },
                    ),
                  ],
                ),
              )
            : null,
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.isDarkMode
                      ? [Color(0xFFC0B9B9), Color(0xFF7B9FAE)]
                      : [Color(0xFF7EABA6), Color(0xFF363A3B)],
                ),
              ),
            ),
            // Content
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 600 ? 20 : 80,
                  vertical: 60,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      "Welcome to Cloud Sense",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleFont,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? Colors.black87
                            : Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black26,
                            offset: Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      height: 3,
                      width: 160,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.black54
                            : Colors.white70,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: subtitleFont,
                          color: themeProvider.isDarkMode
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          pause: const Duration(milliseconds: 1000),
                          animatedTexts: [
                            TyperAnimatedText('Explore Sensors'),
                            TyperAnimatedText('Real time Data'),
                            TyperAnimatedText('Detailed insights'),
                            TyperAnimatedText('Interact with Surrounding'),
                            TyperAnimatedText('IoT enabled Devices'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      "Explore the sensors and dive into the live data they capture. "
                      "With just a tap, you can access detailed insights for each sensor, keeping you informed. "
                      "Monitor conditions to ensure a healthy and safe space, detect potential issues, and stay alert for any irregularities. "
                      "Track various factors to help you plan effectively and contribute to optimizing your usage.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white70,
                        fontSize: paragraphFont,
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Animated cards for stats
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 40,
                      runSpacing: 20,
                      children: [
                        _buildAnimatedStatCard(
                          statValue: _totalDevices.toString(),
                          label: "Devices",
                          themeProvider: themeProvider,
                          context: context,
                          // 👈 upar defined
                        ),
                        _buildAnimatedStatCard(
                          statValue: "500K",
                          label: "Data Points",
                          themeProvider: themeProvider,
                          context: context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MouseRegion(
                          onEnter: (_) =>
                              setState(() => _isHoveredbutton = true),
                          onExit: (_) =>
                              setState(() => _isHoveredbutton = false),
                          child: GestureDetector(
                            onTapDown: (_) => setState(() => _isPressed = true),
                            onTapUp: (_) => setState(() => _isPressed = false),
                            onTapCancel: () =>
                                setState(() => _isPressed = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: Matrix4.identity()
                                ..scale(_isPressed
                                    ? 0.95
                                    : (_isHoveredbutton ? 1.05 : 1.0)),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isHoveredbutton
                                        ? Colors.black.withOpacity(0.4)
                                        : Colors.black.withOpacity(0.2),
                                    blurRadius: _isHoveredbutton ? 12 : 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DeviceActivityPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeProvider.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                  foregroundColor: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Explore Devices",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: paragraphFont,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 8), // gap between text and icon
                                    Icon(
                                      Icons.arrow_forward,
                                      size: paragraphFont + 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavButton(
    String text,
    Color color,
    VoidCallback onPressed, {
    double fontSize = 14,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Flexible(
      // ✅ Makes button adapt inside row
      child: MouseRegion(
        onEnter: (_) => setState(() {
          if (text == 'ABOUT US') _aboutUsColor = Colors.blue;
          if (text == 'LOGIN/SIGNUP') _loginTestColor = Colors.blue;
          if (text == 'ACCOUNT INFO') _accountinfoColor = Colors.blue;
          if (text == 'DEVICE STATUS') _devicemapinfoColor = Colors.blue;
        }),
        onExit: (_) => setState(() {
          if (text == 'ABOUT US')
            _aboutUsColor = const Color.fromARGB(255, 235, 232, 232);
          if (text == 'LOGIN/SIGNUP')
            _loginTestColor = const Color.fromARGB(255, 235, 232, 232);
          if (text == 'ACCOUNT INFO')
            _accountinfoColor = const Color.fromARGB(255, 235, 232, 232);
          if (text == 'DEVICE STATUS')
            _devicemapinfoColor = const Color.fromARGB(255, 235, 232, 232);
        }),
        child: TextButton(
          onPressed: onPressed,
          child: FittedBox(
            // ✅ Automatically shrinks text if needed
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isHoveredbutton = false;
  bool _isHovered = false; // state variable
  bool _isPressed = false;

  Widget _buildAnimatedStatCard({
    required String statValue,
    required String label,
    required ThemeProvider themeProvider,
    required BuildContext context,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;

    double cardSize = screenWidth < 500
        ? 80
        : screenWidth < 800
            ? 150
            : 180;

    double valueFontSize = cardSize * 0.12;
    double labelFontSize = cardSize * 0.10;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: cardSize,
          height: cardSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: themeProvider.isDarkMode
                  ? (_isHovered
                      ? [const Color(0xFF3B6A7F), const Color(0xFF8C6C8E)]
                      : [
                          const Color.fromARGB(255, 29, 56, 68),
                          const Color.fromARGB(228, 69, 59, 71)
                        ])
                  : (_isHovered
                      ? [const Color(0xFF5BAA9D), const Color(0xFFA7DCA1)]
                      : [
                          const Color.fromARGB(255, 73, 117, 121),
                          const Color(0xFF81C784)
                        ]),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: _isHovered ? 16 : 12,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 1),
                builder: (context, progressValue, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: cardSize * 0.5,
                        height: cardSize * 0.5,
                        child: CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 6,
                          color: themeProvider.isDarkMode
                              ? const Color.fromARGB(255, 95, 154, 172)
                              : Colors.white,
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.white10
                              : Colors.white24,
                        ),
                      ),
                      Text(
                        statValue,
                        style: TextStyle(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
