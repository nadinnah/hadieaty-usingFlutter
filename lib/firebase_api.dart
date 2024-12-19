import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print(message.notification?.title);
  print(message.notification?.body);
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    print(message.notification?.title);
  }

  Future<void> initLocalNotification() async {
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@drawable/ic_launcher"),
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        print("Notification clicked with payload: ${notificationResponse.payload}");
      },
    );
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }

    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    print("Displaying notification: ${notification?.title}");
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@drawable/ic_launcher',
          ),
        ),
      );
    }
  }

  void initPushNotification() {
    _firebaseMessaging.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final fcmToken = await _firebaseMessaging.getToken();
    print('Token: $fcmToken');
    await setupFlutterNotifications();
    await initLocalNotification();
    initPushNotification();
  }

  Future<String> getAccessToken() async {
    const serviceAccountJson = {
      "type": "service_account",
      "project_id": "fir-a41f4",
      "private_key_id": "90aefa5a8c9cb48c3e4b49b01e1c671b08b82e35",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCvNTlSKIb/eOzb\nzLHnIVJ5i4VrKIFJS6e3FcwaYocaYzHv0aFnPh2K2PRLkMKd1KAFszaeCRS1SZYG\n1szGBOKi/sR5Ra92q+Xvi5dJcsL5TQz/EG1lmzzsbfAaNxK+f8bCKTLXbQ3VYeWb\nqoU75PZuViUug/LRGWYPAu+1TMpI8aN/22RrmR4oVWQme3UVWGkSREozTcxXHX97\n4BUWxpiKrdIGsIW8UYJ1pi3L93V0v+bLUYqS/5WFZ3Bk/Q8szIYHjxfl+L4Qoviu\n4JAxAQIWnjP6WZjY95rgPPG1we9J9lrk0GQvdXz4zVjtfkC5kaeP29NFX+6WCkO4\ndORM+Sc7AgMBAAECggEAU3bTW6Qay1Db5MlaZnSlSWmBoU6maDg2KS2lEVymZ5eh\njlEaxof8osw/dE/9phpIMO7ysc45ozLu2UsyOZLSNDuRdQQRVkMFQlwJMeANqZ1e\n95LnymNtXmPw4UwjDcTo9k2R/rXgxSnhq4pL9gBYtK8s/z+0SJAE4lnPv1pZcu1/\ncao4RN7jh3E8a2zXARCB9hALqh5aOBwlo3vWrU8CD5NLiUwz+OGnKOjgkO4jcGQK\nqubJumVv+FQUoeTgPFxVPp9FvUvcILDO0mtSjrM55dTv/J4zPuD/IvEywmXGVi+W\nH2c9AEzqdyj4AldB53UwqOKiNzGcZqSd6ndMN8PtAQKBgQDiNsFbQkxdxWkU7Miz\nWneHA+rlw1rybOV79vc/IQXqVnKlx3m3ZxH5juwGhZh3OPJun7O5ZwKdxQ90n78a\nxmldquw9IRYhdILvESEmICDcfr+6I07MovwD2lI22dJIKu4lsod31Zmm/YVEE0gA\n+n8LLsX3GCrghtjmedIVh9YyoQKBgQDGRycjxOhQ8ou3U1ZO0VmgPTxqjZU0t20A\n3Y3uQUar63AeVchC5LuMnpFng6awk5QLlHbpZqP2nyZyyJulNjunZyC0Bzm3LEVu\n131yUJchWnpbY6sfahD90TSUld8/Pt1WGkO0boG2hreCFJF2XjkmN+2GKU43J6+K\nDmkoMGwoWwKBgQC31l/U1lBRdHktdDC28TJqGxjumJB0q2LkF5RfTWsNQivx5eZY\n0f6dnTTbJ/78BN+gX1Ejvz81EEy7LoeULuK6KInMM/NUROeTeYxC+6E5EBioIMGN\nNHcyel6ODP8Df0ACis/k50Xzm9yNsk213d0ZLW3cnVtbFLt4sk+1B6tfgQKBgQC6\ngxP+QauG+aETwgDeA3Abm37JfIVuIV0YA1EPXbfs4HuHDYpj4mXJ0R9WEDEsyKXq\nfq2cwEBcLTktoCdJMcrLnebVcjaIZ8yoh2wprEV9ym5uqUK/Ojbhi3m6i4CFLc1m\nwS4O/CRoXjEg29g5UEjR+qokGZbJqzsk0ol4lJQpIQKBgEjtgNFkmzzhpWC1+5Lf\nrd37kUEaDgime+rfAXQ4tTiTJUDR74d/Sw/Z3BeArqTYQ6V2kYNzda/lgMgzAoE6\nvlwab7OOifZVJc8nblsER5uszwdvqvn+NQWk+gwHER2eGgnraGlNCWHRGlEmvmPr\nNcDiGd+kTeChQla6DfcTWNkM\n-----END PRIVATE KEY-----\n",
      "client_email": "hadieaty@fir-a41f4.iam.gserviceaccount.com",
      "client_id": "115122268752226328388",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/hadieaty%40fir-a41f4.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }
    ;

    final scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    // Authenticate using the service account
    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  Future<void> sendNotificationToUser(String userId, String title, String body) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        final fcmToken = userDoc.data()?['fcmToken'];
        if (fcmToken != null) {
          final accessToken = await getAccessToken();
          final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/fir-a41f4/messages:send';

          final payload = {
            'message': {
              'token': fcmToken,
              'notification': {
                'title': title,
                'body': body,
              },
              'data': {
                'userId': userId,
              },
            }
          };

          final response = await http.post(
            Uri.parse(fcmEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(payload),
          );

          if (response.statusCode == 200) {
            print('Notification sent successfully to user: $userId');

            // Add notification details to Firestore
            await FirebaseFirestore.instance.collection('notifications').add({
              'userId': userId,
              'title': title,
              'body': body,
              'fcmToken': fcmToken,
              'timestamp': FieldValue.serverTimestamp(),
            });

            print('Notification added to Firestore for user: $userId');
          } else {
            print('Failed to send FCM message: ${response.body}');
          }
        } else {
          print('FCM token not found for user: $userId');
        }
      } else {
        print('User document does not exist for userId: $userId');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

}
