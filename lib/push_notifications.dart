import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // print("Title : ${message.notification?.title}");
  // print("Body : ${message.notification?.body}");
  // print("Payload : ${message.data}");
  print(
      "Background Notification: ${message.notification?.title} - ${message.notification?.body}");
}

class PushNotifications {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("Token : $fCMToken");
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show notification details in the foreground
        print(
            "Foreground Notification: ${message.notification?.title} - ${message.notification?.body}");
      }
    });
  }

  Future<void> getFirebaseInstallationID() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fid = await messaging.getToken();
    print('Firebase Installation ID: $fid');
  }

  // Method to send ammonia alert notification
  Future<void> sendAmmoniaAlertNotification(double ammoniaValue) async {
    // Create the notification payload
    RemoteNotification notification = RemoteNotification(
      title: 'Ammonia Alert',
      body: 'Ammonia level exceeded threshold: $ammoniaValue ppm',
    );

    // Add any custom data to the notification
    Map<String, String> data = {
      'ammoniaValue': ammoniaValue.toString(),
    };

    // Here, you can call the Firebase Cloud Messaging service to send the notification to the device.
    // Note that Firebase Cloud Messaging doesn't provide a direct method to send notifications to specific devices.
    // For that, you'd need to use Firebase Functions or send notifications through the Firebase Console.
    // For now, we're just simulating a message here.

    print('Sending Notification: ${notification.title} - ${notification.body}');
    // This would normally be handled by FCM Cloud Functions, but for now, we just log it
    // If you were sending notifications directly from your server, it would be done here
  }
}
