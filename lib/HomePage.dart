import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_sense_webapp/devicelocationinfo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'main.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color _aboutUsColor = const Color.fromARGB(255, 235, 232, 232);
  Color _accountinfoColor = const Color.fromARGB(255, 235, 232, 232);
  Color _devicemapinfoColor = const Color.fromARGB(255, 235, 232, 232);
  int _totalDevices = 0;
  bool _isHovered = false;
  bool _isHoveredMyDevicesButton = false;
  bool _isPressedMyDevicesButton = false;
  bool _isHoveredbutton = false;
  bool _isPressed = false;
  bool _isProductsExpanded = false; // For mobile drawer products expansion

  // Calculate responsive values based on screen width
int getCrossAxisCount(double screenWidth) {
  if (screenWidth < 950) {
    return 1; // Mobile: 1 card per row
  } else if (screenWidth < 1300) {
    return 2; // Tablet: 2 cards per row
  } else {
    return 3; // Desktop: 3 cards per row
  }
}

double getCardAspectRatio(double screenWidth) {
  if (screenWidth < 870) {
    return 1.6; // Mobile: slightly taller cards
  } else if (screenWidth < 1300) {
    return 1.4; // Tablet: balanced aspect ratio
  } else {
    return 1.5; // Desktop: original aspect ratio
  }
}

double getHorizontalPadding(double screenWidth) {
  if (screenWidth < 850) {
    return 10; // Mobile: minimal padding
  } else if (screenWidth < 1300) {
    return 40; // Tablet: moderate padding
  } else {
    return 0; // Desktop: no extra padding (uses main container padding)
  }
}

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

        if (mounted) {
          setState(() {
            _totalDevices = totalCount;
          });
        }
      } else {
        print('Failed to load device data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching device data: $e');
    }
  }

  Future<void> _handleLogout() async {
    try {
      await Amplify.Auth.signOut();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await unsubscribeFromGpsSnsTopic(fcmToken);
        await unsubscribeFromSnsTopic(fcmToken);
      }
      userProvider.setUser(null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully')),
      );
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out')),
      );
    }
  }

  Future<void> _handleDeviceNavigation() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final email = userProvider.userEmail;
    if (email == null) {
      _showLoginPopup(context);
      return;
    }
    try {
      if (email.trim().toLowerCase() == '05agriculture.05@gmail.com') {
        Navigator.pushNamed(context, '/deviceinfo');
      } else {
        Navigator.pushNamed(context, '/devicelist');
      }
      await manageNotificationSubscription();
    } catch (e) {
      print('Error checking user: $e');
      Navigator.pushNamed(context, '/login');
    }
  }

  void _showLoginPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Required'),
          content: Text('Please log in or sign up to access your devices.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, '/login');
              },
              child: Text('Login/Signup'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSensorPopup(BuildContext context, {GlobalKey? buttonKey}) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    RelativeRect position;

    if (buttonKey != null) {
      final RenderBox button =
          buttonKey.currentContext!.findRenderObject() as RenderBox;
      final buttonPosition =
          button.localToGlobal(Offset.zero, ancestor: overlay);

      position = RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height,
        buttonPosition.dx + 200,
        0,
      );
    } else {
      position = RelativeRect.fromLTRB(
        overlay.size.width - 200,
        kToolbarHeight,
        0,
        0,
      );
    }

    bool isAtrhExpanded = false;

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      items: [
        PopupMenuItem<String>(
          value: 'atrh_sensor',
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        isAtrhExpanded = !isAtrhExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.thermostat,
                            color: isDarkMode ? Colors.white : Colors.black),
                        SizedBox(width: 8),
                        Text('ATRH Sensor'),
                        SizedBox(width: 8),
                        Icon(
                          isAtrhExpanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                  ),
                  if (isAtrhExpanded) ...[
                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/probe');
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.thermostat,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black),
                              SizedBox(width: 8),
                              Text('Temperature and Humidity\nProbe'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/atrh');
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.thermostat,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black),
                              SizedBox(width: 8),
                              Text('ATRH Lux Pressure Sensor'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        PopupMenuItem(
          value: 'wind_speed',
          child: Row(
            children: [
              Icon(Icons.air, color: isDarkMode ? Colors.white : Colors.black),
              SizedBox(width: 8),
              Text('Wind Sensor'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'rain_gauge',
          child: Row(
            children: [
              Icon(Icons.water_drop,
                  color: isDarkMode ? Colors.white : Colors.black),
              SizedBox(width: 8),
              Text('Rain Gauge'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'data_logger',
          child: Row(
            children: [
              Icon(Icons.storage,
                  color: isDarkMode ? Colors.white : Colors.black),
              SizedBox(width: 8),
              Text('Data Logger'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'gateway',
          child: Row(
            children: [
              Icon(Icons.router,
                  color: isDarkMode ? Colors.white : Colors.black),
              SizedBox(width: 8),
              Text('Gateway'),
            ],
          ),
        ),
      ],
    );

    if (selected != null && selected != 'atrh_sensor') {
      switch (selected) {
        case 'wind_speed':
          Navigator.pushNamed(context, '/windsensor');
          break;
        case 'rain_gauge':
          Navigator.pushNamed(context, '/raingauge');
          break;
        case 'data_logger':
          Navigator.pushNamed(context, '/datalogger');
          break;
        case 'gateway':
          Navigator.pushNamed(context, '/gateway');
          break;
      }
    }
  }

  Widget _buildUserIcon() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);
    final userEmail = userProvider.userEmail;

    if (userEmail == null || userEmail.isEmpty) {
      return Icon(
        Icons.person,
        color: isDarkMode ? Colors.white : Colors.black,
      );
    }
    return CircleAvatar(
      radius: 14,
      backgroundColor: isDarkMode ? Colors.white : Colors.black,
      child: Text(
        userEmail[0].toUpperCase(),
        style: TextStyle(
          color: isDarkMode ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // GlobalKeys for positioning dropdowns
    final GlobalKey productsButtonKey = GlobalKey();
    final GlobalKey userButtonKey = GlobalKey();

    double titleFont = screenWidth < 800
        ? 28
        : screenWidth < 1024
            ? 48
            : 60;
    double subtitleFont = screenWidth < 800
        ? 18
        : screenWidth < 1024
            ? 22
            : 30;
    double paragraphFont = screenWidth < 800
        ? 14
        : screenWidth < 1024
            ? 18
            : 18;

    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;
      bool isTablet =
          constraints.maxWidth >= 800 && constraints.maxWidth <= 1024;

      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.white,
          toolbarHeight: 70,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: screenWidth < 800 ? 8 : 26),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: screenWidth < 800
                          ? 24
                          : screenWidth <= 1024
                              ? 32
                              : 46,
                    ),
                    SizedBox(width: isMobile ? 10 : (isTablet ? 15 : 20)),
                    Text(
                      'Cloud Sense Vis',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 800
                            ? 20
                            : screenWidth <= 1024
                                ? 26
                                : 46,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                Padding(
                  padding: EdgeInsets.only(right: screenWidth < 800 ? 8 : 26),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        key: productsButtonKey,
                        onPressed: () => _showSensorPopup(context, buttonKey: productsButtonKey),
                        child: Row(
                          children: [
                            SizedBox(width: 4),
                            Text(
                              'Products',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 14 : 16,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down,
                                color: isDarkMode ? Colors.white : Colors.black,
                                size: isTablet ? 18 : 20),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth <= 1024 ? 12 : 24),
                      userProvider.userEmail != null
                          ? Row(
                              key: userButtonKey,
                              children: [
                                _buildUserIcon(),
                                SizedBox(width: 8),
                                _buildUserDropdown(isDarkMode, isTablet, userButtonKey),
                              ],
                            )
                          : TextButton(
                              key: userButtonKey,
                              onPressed: () => _showLoginPopup(context),
                              child: Row(
                                children: [
                                  Text(
                                    'Login/Signup',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 14 : 16,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      size: isTablet ? 18 : 20),
                                ],
                              ),
                            ),
                      SizedBox(width: screenWidth <= 1024 ? 12 : 24),
                      TextButton(
                        onPressed: () {
                          themeProvider.toggleTheme();
                        },
                        child: Row(
                          children: [
                            Icon(
                              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: isDarkMode ? Colors.white : Colors.black,
                              size: isTablet ? 18 : 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Theme',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 14 : 16,
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
          actions: isMobile
              ? [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),
                ]
              : [],
        ),
        endDrawer: isMobile
            ? Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.blueGrey[900]
                            : Colors.grey[200],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Row(
                            children: [
                              _buildUserIcon(),
                              SizedBox(width: 8),
                              Text(
                                userProvider.userEmail ?? 'Guest User',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            userProvider.userEmail != null
                                ? 'Welcome back!'
                                : 'Please login to access all features',
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (userProvider.userEmail != null) ...[
                      ListTile(
                        leading: Icon(Icons.devices),
                        title: Text('My Devices'),
                        onTap: () {
                          Navigator.pop(context);
                          _handleDeviceNavigation();
                        },
                      ),
                      if (userProvider.userEmail?.trim().toLowerCase() !=
                          '05agriculture.05@gmail.com')
                        ListTile(
                          leading: Icon(Icons.account_circle),
                          title: Text('Account Info'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/accountinfo');
                          },
                        ),
                      ListTile(
                        leading: Icon(themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode),
                        title: Text('Theme'),
                        onTap: () {
                          themeProvider.toggleTheme();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        onTap: () {
                          Navigator.pop(context);
                          _handleLogout();
                        },
                      ),
                      Divider(),
                    ],
                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory,
                              color: isDarkMode ? Colors.white : Colors.black),
                          SizedBox(width: 8),
                          Icon(
                              _isProductsExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: isDarkMode ? Colors.white : Colors.black),
                        ],
                      ),
                      title: Text('Products'),
                      subtitle: Text('Browse our sensor products'),
                      onTap: () {
                        setState(() {
                          _isProductsExpanded = !_isProductsExpanded;
                        });
                      },
                    ),
                    if (_isProductsExpanded)
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.thermostat, size: 20),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_drop_down, size: 20),
                                ],
                              ),
                              title: Text('ATRH Sensor',
                                  style: TextStyle(fontSize: 14)),
                              onTap: () {
                                setState(() {
                                  _isProductsExpanded = true;
                                });
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.thermostat, size: 18),
                                    title: Text(
                                        'Temperature and Humidity\nProbe',
                                        style: TextStyle(fontSize: 12)),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, '/probe');
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.thermostat, size: 18),
                                    title: Text('ATRH Lux Pressure Sensor',
                                        style: TextStyle(fontSize: 12)),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, '/atrh');
                                    },
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.air, size: 20),
                              title: Text('Wind Sensor',
                                  style: TextStyle(fontSize: 14)),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/windsensor');
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.water_drop, size: 20),
                              title: Text('Rain Gauge',
                                  style: TextStyle(fontSize: 14)),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/raingauge');
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.storage, size: 20),
                              title: Text('Data Logger',
                                  style: TextStyle(fontSize: 14)),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/datalogger');
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.router, size: 20),
                              title: Text('Gateway',
                                  style: TextStyle(fontSize: 14)),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/gateway');
                              },
                            ),
                          ],
                        ),
                      ),
                    if (userProvider.userEmail == null) ...[
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.login),
                        title: Text('Login/Signup'),
                        onTap: () {
                          Navigator.pop(context);
                          _showLoginPopup(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode),
                        title: Text('Theme'),
                        onTap: () {
                          themeProvider.toggleTheme();
                        },
                      ),
                    ],
                  ],
                ),
              )
            : null,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.isDarkMode
                      ? [
                          const Color.fromARGB(255, 57, 57, 57)!,
                          const Color.fromARGB(255, 2, 54, 76)!,
                        ]
                      : [
                          const Color.fromARGB(255, 191, 242, 237)!,
                          const Color.fromARGB(255, 79, 106, 112)!,
                        ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 800
                      ? 20
                      : screenWidth <= 1024
                          ? 260
                          : 260,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome to Cloud Sense",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleFont,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
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
                            ? Colors.white70
                            : Colors.black54,
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
                              ? Colors.white
                              : Colors.black,
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
                    const SizedBox(height: 30),
                    Text(
                      "Explore the sensors and dive into the live data they capture. "
                      "With just a tap, you can access detailed insights for each sensor, keeping you informed. "
                      "Monitor conditions to ensure a healthy and safe space, detect potential issues, and stay alert for any irregularities. "
                      "Track various factors to help you plan effectively and contribute to optimizing your usage.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                        fontSize: paragraphFont,
                      ),
                    ),
                    const SizedBox(height: 30),
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
                    screenWidth < 900
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MouseRegion(
                                onEnter: (_) => setState(
                                    () => _isHoveredMyDevicesButton = true),
                                onExit: (_) => setState(
                                    () => _isHoveredMyDevicesButton = false),
                                child: GestureDetector(
                                  onTapDown: (_) => setState(
                                      () => _isPressedMyDevicesButton = true),
                                  onTapUp: (_) => setState(
                                      () => _isPressedMyDevicesButton = false),
                                  onTapCancel: () => setState(
                                      () => _isPressedMyDevicesButton = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()
                                      ..scale(_isPressedMyDevicesButton
                                          ? 0.95
                                          : (_isHoveredMyDevicesButton
                                              ? 1.05
                                              : 1.0)),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _isHoveredMyDevicesButton
                                              ? Colors.black.withOpacity(0.4)
                                              : Colors.black.withOpacity(0.2),
                                          blurRadius:
                                              _isHoveredMyDevicesButton ? 12 : 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _handleDeviceNavigation();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: themeProvider.isDarkMode
                                            ? const Color.fromARGB(
                                                255, 18, 16, 16)
                                            : Colors.white,
                                        foregroundColor: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "My Devices",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: paragraphFont,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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
                              const SizedBox(height: 20),
                              MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _isHoveredbutton = true),
                                onExit: (_) =>
                                    setState(() => _isHoveredbutton = false),
                                child: GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => _isPressed = true),
                                  onTapUp: (_) =>
                                      setState(() => _isPressed = false),
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
                                            ? const Color.fromARGB(
                                                255, 18, 16, 16)
                                            : Colors.white,
                                        foregroundColor: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Total Devices",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: paragraphFont,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MouseRegion(
                                onEnter: (_) => setState(
                                    () => _isHoveredMyDevicesButton = true),
                                onExit: (_) => setState(
                                    () => _isHoveredMyDevicesButton = false),
                                child: GestureDetector(
                                  onTapDown: (_) => setState(
                                      () => _isPressedMyDevicesButton = true),
                                  onTapUp: (_) => setState(
                                      () => _isPressedMyDevicesButton = false),
                                  onTapCancel: () => setState(
                                      () => _isPressedMyDevicesButton = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()
                                      ..scale(_isPressedMyDevicesButton
                                          ? 0.95
                                          : (_isHoveredMyDevicesButton
                                              ? 1.05
                                              : 1.0)),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _isHoveredMyDevicesButton
                                              ? Colors.black.withOpacity(0.4)
                                              : Colors.black.withOpacity(0.2),
                                          blurRadius:
                                              _isHoveredMyDevicesButton ? 12 : 6,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _handleDeviceNavigation();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: themeProvider.isDarkMode
                                            ? const Color.fromARGB(
                                                255, 18, 16, 16)
                                            : Colors.white,
                                        foregroundColor: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "My Devices",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: paragraphFont,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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
                              const SizedBox(width: 40),
                              MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _isHoveredbutton = true),
                                onExit: (_) =>
                                    setState(() => _isHoveredbutton = false),
                                child: GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => _isPressed = true),
                                  onTapUp: (_) =>
                                      setState(() => _isPressed = false),
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
                                            ? const Color.fromARGB(
                                                255, 18, 16, 16)
                                            : Colors.white,
                                        foregroundColor: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Total Devices",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: paragraphFont,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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
                          ),
                    const SizedBox(height: 60),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.grey[850]
                              : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Our Products",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 30),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: getCrossAxisCount(screenWidth),
                              crossAxisSpacing: screenWidth < 850 ? 10 : 12,
                              mainAxisSpacing: screenWidth < 850 ? 20 : 40,
                              childAspectRatio: getCardAspectRatio(screenWidth),
                              padding: EdgeInsets.symmetric(
                                  horizontal: getHorizontalPadding(screenWidth)),
                              children: [
                                _buildSensorCard(
                                  imageAsset: "assets/probebg.jpg",
                                  title: "Temperature and Humidity Probe",
                                  description:
                                      "Accurate measurements for temperature and humidity.",
                                  onReadMore: () =>
                                      Navigator.pushNamed(context, '/probe'),
                                  screenWidth: screenWidth,
                                ),
                                _buildSensorCard(
                                  imageAsset: "assets/arth.jpg",
                                  title: "ATRH Lux Pressure Sensor",
                                  description:
                                      "Multi-sensor for ATRH, lux, and pressure.",
                                  onReadMore: () =>
                                      Navigator.pushNamed(context, '/atrh'),
                                  screenWidth: screenWidth,
                                ),
                                _buildSensorCard(
                                  imageAsset: "assets/windsensor.jpg",
                                  title: "Wind Sensor",
                                  description:
                                      "Ultrasonic wind sensors for precise wind data.",
                                  onReadMore: () =>
                                      Navigator.pushNamed(context, '/windsensor'),
                                  screenWidth: screenWidth,
                                ),
                                _buildSensorCard(
                                  imageAsset: "assets/rbase.png",
                                  title: "Rain Gauge",
                                  description: "Reliable rainfall measurement.",
                                  onReadMore: () =>
                                      Navigator.pushNamed(context, '/raingauge'),
                                  screenWidth: screenWidth,
                                ),
                                _buildSensorCard(
                                  imageAsset: "assets/dataloggerrender.png",
                                  title: "Data Logger",
                                  description:
                                      "Logs data from multiple sensors.",
                                  onReadMore: () =>
                                      Navigator.pushNamed(context, '/datalogger'),
                                  screenWidth: screenWidth,
                                ),
                                _buildSensorCard(
                                  imageAsset: "assets/gateway.jpg",
                                  title: "Gateway",
                                  description: "Connects devices to the cloud.",
                                  onReadMore: () =>
                                      Navigator.pushNamed(context, '/gateway'),
                                  screenWidth: screenWidth,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildNavButton(
    String text,
    Color color,
    VoidCallback onPressed, {
    double fontSize = 14,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Flexible(
      child: MouseRegion(
        onEnter: (_) => setState(() {
          if (text == 'ABOUT US') _aboutUsColor = Colors.blue;
          if (text == 'ACCOUNT INFO') _accountinfoColor = Colors.blue;
          if (text == 'DEVICE STATUS') _devicemapinfoColor = Colors.blue;
        }),
        onExit: (_) => setState(() {
          if (text == 'ABOUT US')
            _aboutUsColor = const Color.fromARGB(255, 235, 232, 232);
          if (text == 'ACCOUNT INFO')
            _accountinfoColor = const Color.fromARGB(255, 235, 232, 232);
          if (text == 'DEVICE STATUS')
            _devicemapinfoColor = const Color.fromARGB(255, 235, 232, 232);
        }),
        child: TextButton(
          onPressed: onPressed,
          child: FittedBox(
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

  Widget _buildUserDropdown(
      bool isDarkMode, bool isTablet, GlobalKey userButtonKey) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.userEmail?.trim().toLowerCase() ==
        '05agriculture.05@gmail.com';

    return GestureDetector(
      onTap: () async {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final RenderBox button =
            userButtonKey.currentContext!.findRenderObject() as RenderBox;
        final buttonPosition =
            button.localToGlobal(Offset.zero, ancestor: overlay);

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            buttonPosition.dx,
            buttonPosition.dy + button.size.height,
            buttonPosition.dx + 200,
            0,
          ),
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          items: userProvider.userEmail != null
              ? [
                  PopupMenuItem(
                    value: 'devices',
                    child: Row(
                      children: [
                        Icon(Icons.devices,
                            color: isDarkMode ? Colors.white : Colors.black),
                        SizedBox(width: 8),
                        Text('My Devices'),
                      ],
                    ),
                  ),
                  if (!isAdmin)
                    PopupMenuItem(
                      value: 'account',
                      child: Row(
                        children: [
                          Icon(Icons.account_circle,
                              color: isDarkMode ? Colors.white : Colors.black),
                          SizedBox(width: 8),
                          Text('Account Info'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout,
                            color: isDarkMode ? Colors.white : Colors.black),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ]
              : [
                  PopupMenuItem(
                    value: 'login',
                    child: Row(
                      children: [
                        Icon(Icons.login,
                            color: isDarkMode ? Colors.white : Colors.black),
                        SizedBox(width: 8),
                        Text('Login/Signup'),
                      ],
                    ),
                  ),
                ],
        );

        if (selected == 'devices') {
          _handleDeviceNavigation();
        } else if (selected == 'account' && !isAdmin) {
          Navigator.pushNamed(context, '/accountinfo');
        } else if (selected == 'logout') {
          _handleLogout();
        } else if (selected == 'login') {
          _showLoginPopup(context);
        }
      },
      child: Row(
        children: [
          Text(
            userProvider.userEmail ?? 'Guest',
            style: TextStyle(
              fontSize: isTablet ? 14 : 16,
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard({
    required String statValue,
    required String label,
    required ThemeProvider themeProvider,
    required BuildContext context,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardSize = screenWidth < 500
        ? 80
        : screenWidth < 850
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

  Widget _buildSensorCard({
    required String imageAsset,
    required String title,
    required String description,
    required VoidCallback onReadMore,
    required double screenWidth,
  }) {
    double titleFontSize = screenWidth < 850
        ? 16
        : (screenWidth < 1300 ? 12 : 16);
    double descriptionFontSize = screenWidth < 850
        ? 12
        : (screenWidth < 1300 ? 10 : 14);
    double buttonFontSize = screenWidth < 850
        ? 8.0
        : (screenWidth < 1300 ? 8.0 : 12.0);

    EdgeInsets cardPadding = EdgeInsets.only(
      top: screenWidth < 850 ? 16.0 : (screenWidth < 1300 ? 8.0 : 20.0),
      left: screenWidth < 850 ? 12.0 : 16.0,
      right: screenWidth < 850 ? 12.0 : 16.0,
      bottom: screenWidth < 850 ? 12.0 : 14.0,
    );

    double titleDescriptionSpacing = screenWidth < 850 ? 3 : 4;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.grey);
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.65),
          ),
          Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: screenWidth < 800 ? 1 : 2,
                    ),
                    SizedBox(height: titleDescriptionSpacing),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: descriptionFontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: screenWidth < 800 ? 2 : 3,
                    ),
                  ],
                ),
                SizedBox(
                  width: screenWidth < 850 ? 80 : (screenWidth < 1300 ? 90 : 120.0),
                  height: screenWidth < 850 ? 25 : 24,
                  child: ElevatedButton(
                    onPressed: onReadMore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 850 ? 6 : 10,
                        vertical: screenWidth < 850 ? 3 : 6,
                      ),
                    ),
                    child: Text(
                      "READ MORE >",
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}