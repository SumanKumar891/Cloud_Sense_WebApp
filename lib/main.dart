import 'package:flutter/material.dart';
import 'package:cloud_sense_webapp/homepage.dart';
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget { final String? initialEmail;

  MyApp({this.initialEmail});
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
