import 'package:desalmcs_mobile_app/model/push_notification.dart';
import 'package:desalmcs_mobile_app/pages/book_investmentment.dart';
import 'package:desalmcs_mobile_app/pages/investment_cert.dart';
import 'package:desalmcs_mobile_app/pages/investment_details.dart';
import 'package:desalmcs_mobile_app/pushNotifications/push_messages.dart';
import 'package:desalmcs_mobile_app/util/investment_list.dart';
import 'package:desalmcs_mobile_app/util/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';

import '../model/customer_model.dart';

class OngoingInvestment extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  const OngoingInvestment({super.key, required this.fullName, required this.token, required this.customerWallets});

  @override
  State<OngoingInvestment> createState() => _OngoingInvestmentState();
}

class _OngoingInvestmentState extends State<OngoingInvestment> {
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );

      if (mounted) {
        setState(() {
        notificationInfo = notification;
        totalNotifications++;
      });
      if (notificationInfo != null) {
        // For displaying the notification as an overlay
        showSimpleNotification(
          Text(notificationInfo!.title!),
          leading: NotificationBadge(totalNotifications: totalNotifications),
          subtitle: Text(notificationInfo!.body!),
          background: Colors.cyan.shade700,
          duration: const Duration(seconds: 2),
        );
        notificationList.add(
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
          totalNotifications++;
        });
        notificationList.add({
          'title' : notificationInfo!.title,
          'body' : notificationInfo!.body,
        });

        // API Sign in token
        
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context)=>  PushMessages(
                notificationList: notificationList, 
                totalNotifications: totalNotifications,
              ))
            );
        }
      }
    );
    totalNotifications = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: height * 0.4,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: investmentList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 13.0),
                      child: ListTile(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => InvestmentDetails(
                            title: investmentList[index]['investment_title'].toString(),
                            amount: 'NGN ${investmentList[index]['invested_amount']}',
                            duration: investmentList[index]['duration'].toString(),
                            rate: investmentList[index]['rate'].toString(),
                            start: investmentList[index]['start_date'].toString(),
                            end: investmentList[index]['due_date'].toString(),
                            roi: investmentList[index]['roi'].toString(),
                          ))
                        ),
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Colors.lightBlue
                          ),
                        ),
                        leading: const Icon(
                          Icons.receipt,
                        ),
                        title: Text(investmentList[index]['investment_title'].toString(),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NGN ${investmentList[index]['invested_amount']}',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(investmentList[index]['due_date'].toString(),
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          CupertinoIcons.right_chevron,
                        ),
                      ),
                    );
                  }
                ),
              ),
              Divider(
                thickness: 2,
                color: Colors.lightBlue.withOpacity(0.2),
              ),
              Text('Book A New Investment',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => BookInvestment(customerWallets: widget.customerWallets, 
                    fullName: widget.fullName, 
                    token: widget.token))
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                ), 
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text('Book Now',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Divider(
                thickness: 2,
                color: Colors.lightBlue.withOpacity(0.2),
              ),
              Text('View Investment Certificate',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => InvestmentCert(token: widget.token, fullName: widget.fullName,),)
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                  ),
                ), 
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text('View',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}