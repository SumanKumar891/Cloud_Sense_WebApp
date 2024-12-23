import 'package:cloud_sense_webapp/AccountInfo.dart';
import 'package:cloud_sense_webapp/DeviceGraphPage.dart';
import 'package:cloud_sense_webapp/DeviceListPage.dart';
import 'package:cloud_sense_webapp/LoginPage.dart';
import 'package:cloud_sense_webapp/buffalodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:cloud_sense_webapp/amplifyconfiguration.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Configure Amplify
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print('Could not configure Amplify: $e');
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(initialEmail: email),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? initialEmail;

  MyApp({this.initialEmail});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Cloud Sense',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/about-us': (context) => HomePage(),
        '/login': (context) => SignInSignUpScreen(),
        '/accountinfo': (context) => AccountInfoPage(),
        '/devicelist': (context) => DataDisplayPage(),
        '/devicegraph': (context) => DeviceGraphPage(
              deviceName: '',
              sequentialName: null,
              backgroundImagePath: '',
            ),
        '/buffalodata': (context) => BuffaloData(
              startDateTime: null ?? DateTime.now(),
              endDateTime: null ?? DateTime.now(),
              nodeId: '',
            ),
      },
    );
  }
}
