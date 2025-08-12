import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;
      final horizontalPadding =
          MediaQuery.of(context).size.width < 800 ? 0.0 : 280.0;

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
                SizedBox(width: isMobile ? 10 : 20),
                Text(
                  'Cloud Sense Vis',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 20 : 32,
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
                        SizedBox(width: 20),
                        _buildNavButton('LOGIN/SIGNUP', _loginTestColor, () {
                          _handleLoginNavigation();
                        }),
                        SizedBox(width: 20),
                        _buildNavButton('ACCOUNT INFO', _accountinfoColor, () {
                          Navigator.pushNamed(context, '/accountinfo');
                        }),
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isMobile
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 250,
                              height: 160,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/devicelocationinfo');
                                },
                                child: _buildStatCard(
                                  title: "Total Devices",
                                  value: _totalDevices.toString(),
                                  icon: Icons.devices,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: 250,
                              height: 160,
                              child: _buildStatCard(
                                title: "Total Data Points",
                                value:
                                    "-", // Replace with actual data point count
                                icon: Icons.data_usage,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 160,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/devicelocationinfo');
                              },
                              child: _buildStatCard(
                                title: "Total Devices",
                                value: _totalDevices.toString(),
                                icon: Icons.devices,
                                showArrow: true,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 250,
                            height: 160,
                            child: _buildStatCard(
                              title: "Total Data Points",
                              value: "-",
                              icon: Icons.data_usage,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    bool showArrow = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[200]! : Colors.blueGrey[900]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                if (showArrow)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String text, Color color, VoidCallback onPressed) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() {
        if (text == 'ABOUT US') _aboutUsColor = Colors.blue;
        if (text == 'LOGIN/SIGNUP') _loginTestColor = Colors.blue;
        if (text == 'ACCOUNT INFO') _accountinfoColor = Colors.blue;
        if (text == 'DEVICE STATUS') _devicemapinfoColor = Colors.blue;
        // if (text == 'WEATHER FORECAST') _weatherinfoColor = Colors.blue;
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
        child: Text(
          text,
          style: TextStyle(
            color:
                isDarkMode ? Colors.white : Colors.black, // Adjust color here
            fontWeight: FontWeight.bold, // Optional for better emphasis
          ),
        ),
      ),
    );
  }
}
