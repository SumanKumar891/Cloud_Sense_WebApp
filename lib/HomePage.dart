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
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;
      bool isTablet =
          constraints.maxWidth >= 800 && constraints.maxWidth <= 1024;
      final horizontalPadding = isMobile ? 0.0 : (isTablet ? 120.0 : 280.0);

      return Scaffold(
        backgroundColor: isDarkMode
            ? Colors.grey[200] // Dark mode → blueGrey background
            : Colors.blueGrey[900], // Light mode → grey[200] background
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
          title: Padding(
            padding: EdgeInsets.only(left: horizontalPadding),
            child: Row(
              children: [
                Icon(
                  Icons.cloud,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                SizedBox(width: isMobile ? 10 : (isTablet ? 15 : 20)),
                Text(
                  'Cloud Sense Vis',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 20 : (isTablet ? 26 : 32),
                  ),
                ),
                Spacer(), // Pushes items to the right.
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
                          fontSize:
                              isTablet ? 14 : 16, // smaller font for tablets
                        ),
                        SizedBox(width: isTablet ? 14 : 20),
                        _buildNavButton(
                          'ACCOUNT INFO',
                          _accountinfoColor,
                          () => Navigator.pushNamed(context, '/accountinfo'),
                          fontSize: isTablet ? 14 : 16,
                        ),
                        // SizedBox(width: 20),
                        // _buildNavButton('DEVICE STATUS', _devicemapinfoColor,
                        //     () {
                        //   Navigator.pushNamed(context, '/devicemapinfo');
                        // }),
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
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                      ),
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.login),
                      title: Text('LOGIN/SIGNUP'),
                      onTap: () {
                        _handleLoginNavigation();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.login),
                      title: Text('ACCOUNT INFO'),
                      onTap: () {
                        Navigator.pushNamed(context, '/accountinfo');
                      },
                    ),
                    // ListTile(
                    //   leading: Icon(Icons.login),
                    //   title: Text('DEVICE STATUS'),
                    //   onTap: () {
                    //     Navigator.pushNamed(context, '/devicemapinfo');
                    //   },
                    // ),
                  ],
                ),
              )
            : null,
        body: Stack(
          children: [
            // SizedBox.expand(
            //   child: Image.asset(
            //     'assets/soil.jpg',
            //     fit: BoxFit.cover,
            //   ),
            // ),

            Container(
              color: themeProvider.isDarkMode
                  ? Colors.grey[200] // Dark mode → blueGrey background
                  : Colors.blueGrey[900],
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
                    const SizedBox(height: 60),

                    Text(
                      "Welcome to Cloud Sense",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 800 ? 30 : 60,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 40,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 22,
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
                            TyperAnimatedText('Detailed insights '),
                            TyperAnimatedText('Interact with Surrounding'),
                            TyperAnimatedText('IoT enabled Devices'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      "Explore the sensors and dive into the live data they capture. "
                      "With just a tap, you can access detailed insights for each sensor, keeping you informed. "
                      "Monitor conditions to ensure a healthy and safe space, detect potential issues, and stay alert for any irregularities. "
                      "Track various factors to help you plan effectively and contribute to optimizing your usage.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.black87
                            : Colors.white70,
                        fontSize:
                            MediaQuery.of(context).size.width < 800 ? 16 : 30,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 40,
                      runSpacing: 20,
                      children: [
                        _buildStat(
                          _totalDevices.toString(),
                          "Devices",
                          themeProvider,
                        ),
                        _buildStat(
                          "500K+", // static for now
                          "Data Points",
                          themeProvider,
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeviceActivityPage(),
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
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Explore Devices",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStat(String value, String label, ThemeProvider themeProvider) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.black : Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.black87 : Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
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
}
