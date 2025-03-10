// Import essential packages
import 'dart:convert';
import 'package:cloud_sense_webapp/AccountInfo.dart';
import 'package:cloud_sense_webapp/DeviceGraphPage.dart';
import 'package:cloud_sense_webapp/DeviceListPage.dart';
import 'package:cloud_sense_webapp/LoginPage.dart';
import 'package:cloud_sense_webapp/buffalodata.dart';
import 'package:cloud_sense_webapp/cowdata.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:cloud_sense_webapp/amplifyconfiguration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_sense_webapp/push_notifications.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

// Initialize Flutter local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background message handler for Firebase Messaging (required to be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Handling a background message: ${message.messageId}");
}

// Update SNS endpoint with the latest FCM token via API Gateway
Future<void> updateSnsEndpoint(String fcmToken) async {
  print("Updating SNS with new FCM token: $fcmToken");

  const String snsEndpointArn =
      'arn:aws:sns:us-east-1:975048338421:endpoint/GCM/CS_ammonia/da4a9442-5aee-367a-b65b-33fbbb96928a';
  const String apiGatewayUrl =
      'https://2u9vg092x5.execute-api.us-east-1.amazonaws.com/default/sns_api_fcm_updation';

  try {
    var requestBody = jsonEncode({
      'snsEndpointArn': snsEndpointArn,
      'fcmToken': fcmToken,
    });

    var response = await http.post(
      Uri.parse(apiGatewayUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print("✅ SNS endpoint updated successfully.");
    } else {
      print("❌ Failed to update SNS endpoint: ${response.statusCode}");
    }
  } catch (e) {
    print("⚠ Error updating SNS endpoint: $e");
  }
}

// Setup and configure local notifications
Future<void> setupNotifications() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // Unique ID
    'High Importance Notifications', // Channel name
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const InitializationSettings initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
    print("📱 User tapped on notification: ${details.payload}");
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy(); // Remove # from web app URLs

  await setupNotifications();

  // Firebase initialization based on platform
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC8VgXQxru1bzlbLTUvOc4o490gxDc_MDQ",
          authDomain: "cloudsense-cba8a.firebaseapp.com",
          projectId: "cloudsense-cba8a",
          storageBucket: "cloudsense-cba8a.firebasestorage.app",
          messagingSenderId: "209940213885",
          appId: "1:209940213885:web:1b68309df786c4c30fc114",
          measurementId: "G-HMXS0HV32J"),
    );
  } else {
    await Firebase.initializeApp();
    await PushNotifications().initNotifications();
  }

  // Set up Firebase background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Get FCM token and update SNS
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  if (token != null) {
    await updateSnsEndpoint(token);
  }

  // Listen for FCM token refreshes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await updateSnsEndpoint(newToken);
  });

  // Initialize Amplify for Cognito authentication
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    print('⚠ Could not configure Amplify: $e');
  }

  // Retrieve user's email from shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');

  // Launch app with theme provider
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
      title: 'Cloud Sense Viz',
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
        '/cowdata': (context) => CowData(
              startDateTime: null ?? DateTime.now(),
              endDateTime: null ?? DateTime.now(),
              nodeId: '',
            ),
      },
    );
  }
}
