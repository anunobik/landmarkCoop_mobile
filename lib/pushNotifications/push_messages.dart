// ignore_for_file: must_be_immutable

import 'package:firebase_messaging/firebase_messaging.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/utils/notification_badge.dart';
import 'package:overlay_support/overlay_support.dart';

import '../model/push_notification.dart';

class PushMessages extends StatefulWidget {
  final List notificationList;
  int totalNotifications;
  PushMessages({
    super.key, 
    required this.notificationList, 
    required this.totalNotifications
    });

  @override
  State<PushMessages> createState() => _PushMessagesState();
}

class _PushMessagesState extends State<PushMessages> {
  // late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  // List notificationList = [];
  
  
      
  
  @override
  void initState() {
    // For handling the received notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );

      if (mounted) {
        setState(() {
        notificationInfo = notification;
        widget.totalNotifications++;
      });
      if (notificationInfo != null) {
        // For displaying the notification as an overlay
        showSimpleNotification(
          Text(notificationInfo!.title!),
          leading: NotificationBadge(totalNotifications: widget.totalNotifications),
          subtitle: Text(notificationInfo!.body!),
          background: Colors.cyan.shade700,
          duration: const Duration(seconds: 2),
        );
        widget.notificationList.add(
          {
            "title": notificationInfo!.title!,
            "body": notificationInfo!.body!
          },
        );
      }
      }
    });

    // Open to notification screen
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if(mounted) {
        setState(() {
          notificationInfo = notification;
          widget.totalNotifications++;
        });
        widget.notificationList.add({
          'title' : message.notification!.title,
          'body' : message.notification!.body,
        });

        // API Sign in token
        
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context)=>  PushMessages(
                notificationList: widget.notificationList, 
                totalNotifications: widget.totalNotifications,
              ))
            );
        }
      }
    );

    // totalNotifications = 0;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.openSans(
            color: const Color(0xff091841),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: NotificationBadge(totalNotifications: widget.totalNotifications),
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0xff091841)),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.notificationList.isNotEmpty ? Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.notificationList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(3, 3),
                        ),
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.notificationList[index]['title'],
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(widget.notificationList[index]['body'],
                          style: GoogleFonts.montserrat(),
                        ),
                      ],
                    ),
                  );
                }
              )
            )
            : Center(
              child: Text("No Notifications",
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}