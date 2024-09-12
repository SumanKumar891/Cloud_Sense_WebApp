import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';

import 'LoginPage.dart';
import 'ContactUsPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Sense',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color _aboutUsColor = const Color.fromARGB(255, 235, 232, 232);
  Color _loginTestColor = const Color.fromARGB(255, 235, 232, 232);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 800;
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              if (!isMobile) SizedBox(width: 50),
              Icon(Icons.cloud, color: Colors.white, size: isMobile ? 24 : 32),
              SizedBox(width: isMobile ? 8 : 16),
              Text(
                'Cloud Sense',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : 32,
                ),
              ),
              Spacer(),
              if (!isMobile) ...[
                SizedBox(width: 20),
                _buildNavButton('ABOUT US', _aboutUsColor, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }),
                SizedBox(width: 20),
                _buildNavButton('LOGIN/SIGNUP', _loginTestColor, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignInSignUpScreen()),
                  );
                }),
                // SizedBox(width: 20),
                // _buildNavButton('CONTACT US', _contactUsColor, () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (context) => ContactUsPage()),
                //   );
                // }),
              ],
            ],
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
                      leading: Icon(Icons.info),
                      title: Text('ABOUT US'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.login),
                      title: Text('LOGIN/SIGNUP'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInSignUpScreen()),
                        );
                      },
                    ),
                    // ListTile(
                    //   leading: Icon(Icons.contact_mail),
                    //   title: Text('CONTACT US'),
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (context) => ContactUsPage()),
                    //     );
                    //   },
                    // ),
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
                  Image.asset(
                    'assets/soill.jpg', // Replace with your image path
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width < 800 ? 400 : 550,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width < 800 ? 400 : 550,
                    color: Colors.black.withOpacity(0.5),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width < 800 ? 20 : 100,
                      top: MediaQuery.of(context).size.width < 800 ? 60 : 120,
                      right:
                          MediaQuery.of(context).size.width < 1000 ? 60 : 400,
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Cloud Sense ',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: MediaQuery.of(context).size.width < 800
                                ? 40
                                : 65,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: Text(
                            "At Cloud Sense, we're dedicated to providing you with real-time data to help you make informed decisions about your surroundings. Our advanced app leverages cutting-edge technology to deliver accurate and timely data.",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 800
                                  ? 16
                                  : 22,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 80),
              // "What We Offer" Section
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.maxWidth < 800
                        ? Column(
                            children: [
                              Card(
                                elevation: 5,
                                shadowColor: Colors.black.withOpacity(0.5),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'What We Offer?',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Explore the sensors and dive into the live data they capture. With just a tap, you can access detailed insights for each sensor, keeping you informed.\n\nMonitor conditions to ensure a healthy and safe space, detect potential issues, and stay alert for any irregularities. Track various factors to help you plan effectively and contribute to optimizing your usage. Fine-tune your surroundings to prevent potential problems and adjust settings for comfort and efficiency. With all the essential insights at your fingertips, you can create a more comfortable and sustainable living space.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                height: 400,
                                child: Image.asset(
                                  'assets/weather_.jpg', // Replace with your image path
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Card(
                                  elevation: 5,
                                  shadowColor: Colors.black.withOpacity(0.5),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'What We Offer?',
                                          style: TextStyle(
                                            fontSize: 46,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Explore the sensors and dive into the live data they capture. With just a tap, you can access detailed insights for each sensor, keeping you informed.\n\nMonitor conditions to ensure a healthy and safe space, detect potential issues, and stay alert for any irregularities. Track various factors to help you plan effectively and contribute to optimizing your usage. Fine-tune your surroundings to prevent potential problems and adjust settings for comfort and efficiency. With all the essential insights at your fingertips, you can create a more comfortable and sustainable living space.',
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 50),
                              Container(
                                width: 600,
                                height: 500,
                                child: Image.asset(
                                  'assets/weather_.jpg', // Replace with your image path
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          );
                  },
                ),
              ),
              SizedBox(height: 100),
              // "Our Mission" Section
              Stack(
                children: [
                  Image.asset(
                    'assets/weatherr.jpg', // Replace with your image path
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width < 800 ? 400 : 500,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width < 800 ? 400 : 500,
                    color: Colors.black.withOpacity(0.5),
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width < 800 ? 20.0 : 80.0,
                      MediaQuery.of(context).size.width < 800 ? 40.0 : 85.0,
                      MediaQuery.of(context).size.width < 800 ? 20.0 : 90.0,
                      50.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Mission',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 800
                                  ? 30
                                  : 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'At Cloud Sense, we aim to revolutionize the way you interact with your surroundings by offering intuitive and seamless monitoring solutions. Our innovative app provides instant access to essential data, giving you the tools to anticipate and respond to changes. With Cloud Sense, you can trust that you’re equipped with the knowledge needed to maintain a safe, healthy, and efficient lifestyle.',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 800
                                  ? 18
                                  : 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0),
              // Footer Section
              Container(
                color: const Color.fromARGB(255, 10, 10, 10),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Address : IIT Ropar TIF (AWaDH), 214 / M. Visvesvaraya Block, Indian Institute of Technology Ropar, Rupnagar - 140001, Punjab ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Phone : 01881 - 232601 ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Email : contact.awadh@iitrpr.ac.in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNavButton(String text, Color color, VoidCallback onPressed) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        if (text == 'ABOUT US') _aboutUsColor = Colors.blue;
        if (text == 'LOGIN/SIGNUP') _loginTestColor = Colors.blue;
        // if (text == 'CONTACT US') _contactUsColor = Colors.blue;
      }),
      onExit: (_) => setState(() {
        if (text == 'ABOUT US')
          _aboutUsColor = const Color.fromARGB(255, 235, 232, 232);
        if (text == 'LOGIN/SIGNUP')
          _loginTestColor = const Color.fromARGB(255, 235, 232, 232);
        // if (text == 'CONTACT US')
        //   _contactUsColor = const Color.fromARGB(255, 235, 232, 232);
      }),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: color)),
      ),
    );
  }
}
