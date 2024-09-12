import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  // Color _productsServicesColor = const Color.fromARGB(255, 235, 232, 232);
  // Color _contactUsColor = const Color.fromARGB(255, 235, 232, 232);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.grey[900],
//         title: Row(
//           children: [
//             SizedBox(width: 100),
//             Icon(
//               Icons.cloud,
//               color: Colors.white,
//               size: 32,
//             ),
//             SizedBox(width: 8),
//             Text(
//               'Cloud Sense',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 32,
//               ),
//             ),
//             SizedBox(width: 200),
//             MouseRegion(
//               onEnter: (_) => setState(() {
//                 _aboutUsColor = Colors.blue;
//               }),
//               onExit: (_) => setState(() {
//                 _aboutUsColor = const Color.fromARGB(255, 235, 232, 232);
//               }),
//               child: TextButton(
//                 onPressed: () {},
//                 child: Text('ABOUT US', style: TextStyle(color: _aboutUsColor)),
//               ),
//             ),
//             SizedBox(width: 50),
//             MouseRegion(
//               onEnter: (_) => setState(() {
//                 _loginTestColor = Colors.blue;
//               }),
//               onExit: (_) => setState(() {
//                 _loginTestColor = const Color.fromARGB(255, 235, 232, 232);
//               }),
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => SignInSignUpScreen()),
//                   );
//                 },
//                 child: Text('LOGIN/SIGNUP',
//                     style: TextStyle(color: _loginTestColor)),
//               ),
//             ),

//             SizedBox(width: 50),
//             MouseRegion(
//               onEnter: (_) => setState(() {
//                 _contactUsColor = Colors.blue;
//               }),
//               onExit: (_) => setState(() {
//                 _contactUsColor = const Color.fromARGB(255, 235, 232, 232);
//               }),
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ContactUsPage()),
//                   );
//                 },
//                 child: Text('CONTACT US',
//                     style: TextStyle(color: _contactUsColor)),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 Image.asset(
//                   'assets/buildings.jpg', // Replace with your image path
//                   width: double.infinity,
//                   height: 550,
//                   fit: BoxFit.cover,
//                 ),
//                 Container(
//                   width: double.infinity,
//                   height: 550,
//                   color: Colors.black.withOpacity(0.5), // Dark overlay
//                   alignment: Alignment.centerLeft, // Align to left
//                   padding: EdgeInsets.only(
//                       left: 100,
//                       top: 120,
//                       right: 20,
//                       bottom:
//                           20), // Add padding to ensure content doesn't touch edges
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.start, // Align text to the left
//                     children: [
//                       Text(
//                         'Welcome to Cloud Sense',
//                         style: TextStyle(
//                           fontFamily: 'OpenSans',
//                           //-- fontStyle: FontStyle.italic,
//                           fontSize: 65,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white, // Text color
//                         ),
//                         textAlign: TextAlign.left, // Align text to the left
//                       ),
//                       SizedBox(height: 20), // Space between texts
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                         child: Text(
//                           'At Cloud Sense, we’re dedicated to providing you with real-time data\nto help you make informed decisions about your surroundings. Our\nadvanced app leverages cutting-edge technology to deliver accurate\nand timely data.',
//                           style: TextStyle(
//                             fontSize: 22,
//                             color: Colors.white, // Text color
//                           ),
//                           textAlign: TextAlign.left, // Align text to the left
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: 80), // Space between sections

//             // "What We Offer" Section
//             Container(
//               margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//               padding: EdgeInsets.only(left: 30), // Add padding to move right
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Text Section
//                   Expanded(
//                     flex: 2,
//                     child: Card(
//                       elevation: 5,
//                       shadowColor: Colors.black.withOpacity(0.5),
//                       child: Padding(
//                         padding: EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'What We Offer?',
//                               style: TextStyle(
//                                 fontSize: 46, // Reduced font size
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black, // Text color
//                               ),
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               // 'Explore the sensors you’ve selected and dive into the live data they capture. With just a tap, you can access\ndetailed insights for each sensor, allowing you to stay informed.\n\nMonitor air quality to ensure a fresh and safe atmosphere, detect potential sources of contamination, and stay\nvigilant against hazardous gases. Keep track of weather conditions to plan your day and contribute to climate\ncontrol efforts by optimizing energy usage and reducing your carbon footprint. Fine-tune your indoor climate\nto prevent issues like mold, and adjust lighting for both comfort and efficiency. By closely monitoring\ntemperature variations, you can also refine your heating and cooling systems for ultimate comfort. All the\nessential insights you need are right at your fingertips, helping you create a safer, more sustainable living space.',
//                               'Explore the sensors and dive into the live data they capture.With just a tap,you can access detailed insights for each sensor, keeping you informed.\n\nMonitor conditions to ensure a healthy and safe space,detect potential issues, and stay alert for any\nirregularities. Track various factors to help you plan effectively and contribute to optimizing your\nusage. Fine-tune your surroundings to prevent potential problems and adjust settings for comfort\nand efficiency. With all the essential insights at your fingertips, you can create a more comfortable\nand sustainable living space.',
//                               style: TextStyle(
//                                 fontSize: 22, // Reduced font size
//                                 color: Colors.black, // Text color
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8), // Space between text and image
//                   // Image Section
//                   Container(
//                     width: 750, // Reduced width
//                     height: 700, // Reduced height
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: Image.asset(
//                         'assets/weather_.jpg', // Replace with your image path
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: 100), // Space between sections

//             // "Our Mission" Section
//             Stack(
//               children: [
//                 Image.asset(
//                   'assets/weatherr.jpg', // Replace with your image path
//                   width: double.infinity,
//                   height: 350,
//                   fit: BoxFit.cover,
//                 ),
//                 Container(
//                   width: double.infinity,
//                   height: 350,
//                   color: Colors.black.withOpacity(0.5), // Dark overlay
//                   padding: EdgeInsets.fromLTRB(80.0, 85.0, 90.0, 50.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Our Mission',
//                         style: TextStyle(
//                           fontSize: 50,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white, // Text color
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         // 'At Cloud Sense, we aim to transform the way you interact with your biodiversity by offering intuitive and seamless monitoring solutions. Our innovative app provides instant access to essential data, giving you the tools to anticipate and respond to changes in your surroundings. With Cloud Sense, you can trust that you’re equipped with the knowledge needed to maintain a safe, healthy, and sustainable life.',
//                         'At Cloud Sense, we aim to revolutionize the way you interact with your surroundings by offering intuitive and seamless monitoring solutions. Our innovative app provides instant access to essential data, giving you the tools to anticipate and respond to changes. With Cloud Sense, you can trust that you’re equipped with the knowledge needed to maintain a safe, healthy, and efficient lifestyle.',
//                         style: TextStyle(
//                           fontSize: 24,
//                           color: Colors.white, // Text color
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: 0), // Space before footer

//             // Footer Section
//             Container(
//               color: const Color.fromARGB(255, 10, 10, 10),
//               width: double.infinity,
//               padding:
//                   EdgeInsets.only(left: 80, top: 50, right: 20, bottom: 20),
//               child: Column(
//                 children: [
//                   // Address, Phone, and Email Section
//                   Column(
//                     children: [
//                       Text(
//                         'Address : IIT Ropar TIF (AWaDH), 214 / M. Visvesvaraya Block, Indian Institute of Technology Ropar, Rupnagar - 140001, Punjab ',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                       SizedBox(height: 18),
//                       Text(
//                         'Phone : 01881 - 232601 ',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                       SizedBox(height: 18),
//                       Text(
//                         'Email : contact.awadh@iitrpr.ac.in',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                       height: 30), // Increase space before the bottom border
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 800;

            return Row(
              children: [
                if (!isMobile) SizedBox(width: 50),
                Icon(Icons.cloud,
                    color: Colors.white, size: isMobile ? 24 : 32),
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
                  _buildNavButton('ABOUT US', _aboutUsColor, () {}),
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
                if (isMobile)
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
              ],
            );
          },
        ),
      ),
      drawer: Drawer(
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
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => AboutUsPage()),
              //   );
              // },
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('LOGIN/SIGNUP'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInSignUpScreen()),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/soil.jpg', // Replace with your image path
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
                    right: MediaQuery.of(context).size.width < 1000 ? 60 : 400,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Cloud Sense',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize:
                              MediaQuery.of(context).size.width < 800 ? 40 : 65,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          'At Cloud Sense, we’re dedicated to providing you with real-time data to help you make informed decisions about your surroundings. Our advanced app leverages cutting-edge technology to deliver accurate and timely data.',
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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


// // Dummy pages for navigation

// class ProductsServicesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Products and Services Page'),
//       ),
//       body: Center(
//         child: Text('Products and Services Page'),
//       ),
//     );
//   }
// }

