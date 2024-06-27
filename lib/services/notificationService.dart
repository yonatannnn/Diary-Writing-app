import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getStringFromPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token == null) {
        throw Exception('No token found in SharedPreferences');
      }
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final userEmail = user.email ?? '';

      await _firestore.collection("UserTokens").doc(userEmail).set({
        'token': token.trim(),
      });
      print('Token saved successfully for user: $userEmail');
    } catch (e) {
      print('Error saving token: $e');
      throw Exception('Error saving token: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final userEmail = user.email ?? '';

      await _firestore.collection("UserTokens").doc(userEmail).delete();
      print('Token deleted successfully for user: $userEmail');
    } catch (e) {
      print('Error deleting token: $e');
      throw Exception('Error deleting token: $e');
    }
  }

  Future<void> showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id', // Replace with your own channel ID
    'Diary App', // Replace with your own channel name
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID, a unique integer value for each notification
    'New Notification', // Title of the notification
    'Hello, this is a local notification!', // Body of the notification
    platformChannelSpecifics,
    payload: 'item x', // Optional payload
  );
}

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA9xPglTQ:APA91bEuI1Hg2Mw6dLpBuh2bDvJfgcYOUm_rEUhq3glaPRzICYtTUQEG6iFF1r_EeWx3B_wC9sTDVxk0x1PYgcSh- N9Di4qG-GNF3LVDjhc9F5B_cfEqvdky-Rc1ILwdAc1oqtB5Ho8v',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
      print('Push message sent successfully');
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  Future<void> configureFirebaseMessaging() async {
    // Request permission if not granted
    await _firebaseMessaging.requestPermission();

    // Get the token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      // Save token to SharedPreferences for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userToken', token);
      print('Firebase Messaging token: $token');
    } else {
      print('Unable to get Firebase Messaging token.');
    }
  }
}
