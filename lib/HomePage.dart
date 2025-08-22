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

      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.white,
          title: Row(
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
              if (!isMobile)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    userProvider.userEmail != null
                        ? Row(
                            children: [
                              _buildUserIcon(),
                              SizedBox(width: 8),
                              _buildUserDropdown(isDarkMode, isTablet),
                            ],
                          )
                        : IconButton(
                            icon: _buildUserIcon(),
                            onPressed: () => _showLoginPopup(context),
                          ),
                  ],
                ),
            ],
          ),
          actions: isMobile
              ? [
                  Builder(
                    builder: (context) => IconButton(
                      icon: _buildUserIcon(),
                      onPressed: () {
                        if (userProvider.userEmail == null) {
                          _showLoginPopup(context);
                        } else {
                          Scaffold.of(context).openEndDrawer();
                        }
                      },
                    ),
                  ),
                ]
              : [],
        ),
        endDrawer: isMobile && userProvider.userEmail != null
            ? Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(color: Colors.grey[900]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Row(
                            children: [
                              userProvider.userEmail == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                    )
                                  : CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        userProvider.userEmail![0]
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                              SizedBox(width: 8),
                              Text(
                                userProvider.userEmail ?? 'Guest',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.devices),
                      title: Text('My Devices'),
                      onTap: _handleDeviceNavigation,
                    ),
                    if (userProvider.userEmail?.trim().toLowerCase() !=
                        '05agriculture.05@gmail.com')
                      ListTile(
                        leading: Icon(Icons.account_circle),
                        title: Text('Account Info'),
                        onTap: () {
                          Navigator.pushNamed(context, '/accountinfo');
                        },
                      ),
                    ListTile(
                      leading: Icon(themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode),
                      title: Text('Theme'),
                      onTap: () => themeProvider.toggleTheme(),
                    ),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      onTap: _handleLogout,
                    ),
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
                  horizontal: screenWidth < 600 ? 20 : 80,
                  vertical: 40,
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
                    const SizedBox(height: 60),
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
                    const SizedBox(height: 60),
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
                                      ? const Color.fromARGB(255, 18, 16, 16)
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

  Widget _buildUserDropdown(bool isDarkMode, bool isTablet) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAdmin = userProvider.userEmail?.trim().toLowerCase() ==
        '05agriculture.05@gmail.com';
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: () async {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            overlay.size.width, // 👈 align to right edge
            kToolbarHeight, // 👈 just below AppBar
            0,
            0,
          ),
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          items: [
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
              value: 'theme',
              child: Row(
                children: [
                  Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  SizedBox(width: 8),
                  Text('Theme'),
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
          ],
        );

        if (selected == 'devices') {
          _handleDeviceNavigation();
        } else if (selected == 'account' && !isAdmin) {
          Navigator.pushNamed(context, '/accountinfo');
        } else if (selected == 'theme') {
          themeProvider.toggleTheme();
        } else if (selected == 'logout') {
          _handleLogout();
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

  bool _isHoveredbutton = false;
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
