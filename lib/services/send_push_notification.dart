import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:async';  // Import the Timer library

Future<void> sendPushNotification({
  required String fcmToken,
  required String title,
  required String body,
}) async {
  // Path to your service account JSON file
  const String serviceAccountJsonPath = '../files/service-account.json';
  
  // Load the service account JSON file
  final serviceAccountJson = await File(serviceAccountJsonPath).readAsString();
  final serviceAccount = ServiceAccountCredentials.fromJson(serviceAccountJson);

  // Define the scopes required for FCM
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Obtain an authenticated HTTP client
  final client = await clientViaServiceAccount(serviceAccount, scopes);

  // Define the FCM v1 API endpoint
  final url = Uri.parse('https://fcm.googleapis.com/v1/projects/diary-app-8d5de/messages:send');

  // Set the headers for the HTTP request
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${client.credentials.accessToken.data}',
  };

  // Create the payload for the push notification
  final payload = jsonEncode({
    'message': {
      'token': fcmToken,
      'notification': {
        'title': title,
        'body': body,
      },
    },
  });

  // Function to send the notification
  Future<void> sendNotification() async {
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: payload,
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully');
      } else {
        print('Failed to send push notification: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending push notification: $e');
    } finally {
      client.close();
    }
  }

  // Schedule the notification to be sent after 1 minute
  Timer(Duration(minutes: 1), sendNotification);
}