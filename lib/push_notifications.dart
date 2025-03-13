// import 'package:firebase_messaging/firebase_messaging.dart';

// // Background notification handler (runs when app is in the background or terminated)
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print(
//       "Background Notification: ${message.notification?.title} - ${message.notification?.body}");
// }

// class PushNotifications {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   // Initialize Firebase Cloud Messaging (FCM) notifications
//   Future<void> initNotifications() async {
//     // Request user permission for push notifications (iOS/Android)
//     await _firebaseMessaging.requestPermission();

//     // Get and print FCM token (used to identify the device)
//     final fCMToken = await _firebaseMessaging.getToken();
//     print("Token : $fCMToken");

//     // Set up background notification handler
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

//     // Listen for foreground notifications (when app is open)
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         print(
//             "Foreground Notification: ${message.notification?.title} - ${message.notification?.body}");
//       }
//     });
//   }

//   // Retrieve Firebase Installation ID (FCM token)
//   Future<void> getFirebaseInstallationID() async {
//     String? fid = await _firebaseMessaging.getToken();
//     print('Firebase Installation ID: $fid');
//   }

//   // Simulate sending an ammonia alert notification
//   Future<void> sendAmmoniaAlertNotification(double ammoniaValue) async {
//     // Create notification payload (title and body)
//     RemoteNotification notification = RemoteNotification(
//       title: 'Ammonia Alert',
//       body: 'Ammonia level exceeded threshold: $ammoniaValue ppm',
//     );

//     // Add custom data to the notification
//     Map<String, String> data = {
//       'ammoniaValue': ammoniaValue.toString(),
//     };

//     // Placeholder for sending notification via FCM Cloud Functions or API
//     print('Sending Notification: ${notification.title} - ${notification.body}');
//   }
// }
