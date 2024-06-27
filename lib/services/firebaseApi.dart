import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
  print('Title , ${message.notification?.title}');
  print('Body , ${message.notification?.body}');
  print('Payload , ${message.data}');
}

class FirebaseApi {
  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High importance notification',
      description: 'this channel is', importance: Importance.defaultImportance);

  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('Token : ${fcmToken}');
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
  }
}
