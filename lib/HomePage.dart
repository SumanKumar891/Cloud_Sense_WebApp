import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  bool isHovered = false;

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
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          backgroundColor: isDarkMode
              ? const Color.fromARGB(255, 50, 50, 50)
              : const Color.fromARGB(255, 231, 231, 231),
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
                        // SizedBox(width: 20),
                        // _buildNavButton('ABOUT US', _aboutUsColor, () {
                        //   Navigator.pushNamed(context, '/about-us');
                        // }),
                        SizedBox(width: 20),
                        _buildNavButton('LOGIN/SIGNUP', _loginTestColor, () {
                          _handleLoginNavigation();
                        }),
                        SizedBox(width: 20),
                        _buildNavButton('ACCOUNT INFO', _accountinfoColor, () {
                          Navigator.pushNamed(context, '/accountinfo');
                        }),
                        SizedBox(width: 20),
                        _buildNavButton('DEVICE STATUS', _devicemapinfoColor,
                            () {
                          Navigator.pushNamed(context, '/devicemapinfo');
                        }),
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
                    // ListTile(
                    //   leading: Icon(Icons.info),
                    //   title: Text('ABOUT US'),
                    //   onTap: () {
                    //     Navigator.pushNamed(context, '/about-us');
                    //   },
                    // ),
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
                    ListTile(
                      leading: Icon(Icons.login),
                      title: Text('DEVICE STATUS'),
                      onTap: () {
                        Navigator.pushNamed(context, '/devicemapinfo');
                      },
                    ),
                  ],
                ),
              )
            : null,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    // height: MediaQuery.of(context).size.width < 800 ? 450 : 650,
                    color: Colors.transparent,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width < 800 ? 40 : 280,
                      top: MediaQuery.of(context).size.width < 800 ? 60 : 80,
                      right:
                          MediaQuery.of(context).size.width < 1000 ? 30 : 400,
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEATHER FORECASTS\nTAILORED FOR YOUR\nLOCATION',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: MediaQuery.of(context).size.width < 800
                                ? 26
                                : 50,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.black,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Get hyper-local forecasts powered by your weather station.\nAccurate, hourly insights for temperature, humidity,\nprecipitation, and much more.',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 800
                                ? 16
                                : 22,
                            color: isDarkMode ? Colors.white : Colors.black,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20),
                        MouseRegion(
                          onEnter: (_) => setState(() => isHovered = true),
                          onExit: (_) => setState(() => isHovered = false),
                          child: Transform.scale(
                            scale: isHovered ? 1.05 : 1.0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/weatherinfo');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 49, 145, 241),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 10 : 24,
                                    vertical: isMobile ? 8 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: isHovered ? 8 : 4,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) =>
                                      SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.3, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                        opacity: animation, child: child),
                                  ),
                                  child: isHovered
                                      ? Row(
                                          key: const ValueKey('hover'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              'GET STARTED NOW',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward, size: 20),
                                          ],
                                        )
                                      : const Text(
                                          'GET STARTED NOW',
                                          key: ValueKey('normal'),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width < 800 ? 40 : 280,
                  vertical: 20,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 800;
                    return isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextContent(isDarkMode),
                              SizedBox(height: 30),
                              _buildImageContent(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextContent(isDarkMode),
                              ),
                              SizedBox(width: 40),
                              Expanded(
                                flex: 3,
                                child: isMobile
                                    ? _buildImageContent()
                                    : Transform.translate(
                                        offset: Offset(110, -200),
                                        child: _buildImageContent(),
                                      ),
                              ),
                            ],
                          );
                  },
                ),
              ),
              SizedBox(height: 0),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTextContent(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forecasting Applications',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Benefits include:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 10),
        _buildBulletPoint(
            '10-day Hourly Forecasts: Temperature; Relative Humidity; Precipitation.'),
        _buildBulletPoint(
            'Instant IoT Sync: Connect to your weather station in minutes and get real-time, AI-powered forecasts.'),
        _buildBulletPoint(
            'Up to 85% More Accurate Than National Weather Services.'),
      ],
    );
  }

  Widget _buildImageContent() {
    return Center(
      child: SizedBox(
        width: 750, // You can adjust this to smaller like 300 or 250 if needed
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/weatherforecasting.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 18,
              color: const Color.fromARGB(255, 49, 145, 241),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        ],
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
