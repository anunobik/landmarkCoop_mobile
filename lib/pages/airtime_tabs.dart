import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/login_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/pages/airtime_data.dart';
import 'package:landmarkcoop_mobile_app/pages/data_subscription.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:landmarkcoop_mobile_app/util/notification_badge.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/push_notification.dart';

class AirtimeTabs extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactionsList;

  AirtimeTabs({
    Key? key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.lastTransactionsList,
  }) : super(key: key);

  @override
  State<AirtimeTabs> createState() => _AirtimeTabsState();
}

class _AirtimeTabsState extends State<AirtimeTabs> {
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  LoginRequestModel loginRequestModel = LoginRequestModel();

  Widget futureTabWidgetBuilder(){
    return Expanded(
      child: TabBarView(
        children: [
          AirtimePurchase(customerWallets: widget.customerWallets, fullName: widget.fullName, token: widget.token, lastTransactions: widget.lastTransactionsList,),
          DataSubscription(customerWallets: widget.customerWallets, fullName: widget.fullName, token: widget.token, lastTransactions: widget.lastTransactionsList,),
        ]
      ),
    );
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
        );
        if (mounted) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('notificationTitle', message.notification!.title.toString());
          await prefs.setString('notificationBody', message.notification!.body.toString());
          setState(() {
            notificationInfo = notification;
            totalNotifications++;
          });
          if (notificationInfo != null) {
            // For displaying the notification as an overlay
            showSimpleNotification(
              Text(notificationInfo!.title!,
                style: GoogleFonts.montserrat(),
              ),
              leading: NotificationBadge(totalNotifications: totalNotifications),
              subtitle: Text(notificationInfo!.body!,
                style: GoogleFonts.montserrat(),
              ),
              background: const Color(0XFF091841).withOpacity(0.7),
              duration: const Duration(seconds: 2),
            );
          }
          pushNotify();
        }
      });

    // Open to notification screen
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if(mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('notificationTitle', message.notification!.title.toString());
        await prefs.setString('notificationBody', message.notification!.body.toString());
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });

      }}
    );
    totalNotifications = 0;
    pushNotify();
    super.initState();
  }

  void pushNotify() async{
    final prefs = await SharedPreferences.getInstance();
    String notificationTitle = prefs.getString('notificationTitle') ?? '';
    String notificationBody = prefs.getString('notificationBody') ?? '';
    print('Body - $notificationBody');
    if(notificationTitle != '') {
      setState((){
        notificationList.add({
          'title' : notificationTitle,
          'body' : notificationBody,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => HomeDrawer(
                          value: 1,
                          page: AirtimeTabs(token: widget.token,
                            fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactionsList: widget.lastTransactionsList,
                          ),
                          name: 'Bills Payment',
                          token: widget.token,
                          fullName: widget.fullName,
                          customerWallets: widget.customerWallets,
                          lastTransactionsList: widget.lastTransactionsList,
                        ))
                    );
                  },
                  icon: Icon(
                    Icons.menu,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(8,60,8,20),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 139, 1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold
                  ),
                  unselectedLabelStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold
                  ),
                  tabs: const [
                    Tab(text: 'Airtime Purchase'),
                    Tab(text: 'Data Subscription'),
                  ],
                ),
              ),
              futureTabWidgetBuilder(),
            ],
          )
        ),
      ),
    );
  }
}