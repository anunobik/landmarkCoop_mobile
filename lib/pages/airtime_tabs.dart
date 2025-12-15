import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/api/api_service.dart';
import 'package:landmarkcoop_latest/entry_point.dart';
import 'package:landmarkcoop_latest/model/customer_model.dart';
import 'package:landmarkcoop_latest/model/login_model.dart';
import 'package:landmarkcoop_latest/model/push_notification.dart';
import 'package:landmarkcoop_latest/pages/airtime_purchase.dart';
import 'package:landmarkcoop_latest/pages/data_subscription.dart';
import 'package:landmarkcoop_latest/utils/notification_badge.dart';
import 'package:landmarkcoop_latest/widgets/bottom_nav_bar.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AirtimeTabs extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const AirtimeTabs({
    Key? key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
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
          AirtimePurchase(customerWallets: widget.customerWallets, fullName: widget.fullName, token: widget.token,),
          DataSubscription(customerWallets: widget.customerWallets, fullName: widget.fullName, token: widget.token,),
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
              background: Color(0xff000080).withOpacity(0.7),
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
        String subdomain = prefs.getString('subdomain') ?? 'core.landmarkcooperative.org';
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });

        // API Sign in token
        APIService apiService = APIService(subdomain_url: subdomain);
        apiService.login(loginRequestModel).then((value) {
          if (value.customerWalletsList.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context)=> EntryPoint(
                customerWallets: value.customerWalletsList, 
                fullName: value.customerWalletsList[0].fullName, 
                screenName: 'Notification', 
                subdomain: subdomain, 
                token: value.token, 
                referralId: value.customerWalletsList[0].phoneNo,))
            );
            notificationList.add({
              'title' : message.notification!.title,
              'body' : message.notification!.body,
            });
        }});
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


  Future<void> _navigateToSignInScreen() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    final value = await apiService.pageReload(widget.token); // Assuming pageReload gets necessary data

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BottomNavBar(
        pageIndex: 0,
        fullName: value.customerWalletsList[0].fullName,
        token: value.token,
        subdomain: subdomain,
        customerWallets: value.customerWalletsList,
        phoneNumber: value.customerWalletsList[0].phoneNo,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xff000080)),
                onPressed: _navigateToSignInScreen,
              ),
            ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.fromLTRB(8,60,8,20),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold
                  ),
                  unselectedLabelStyle: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold
                  ),
                  tabs: const [
                    Tab(text: ' Airtime Purchase '),
                    Tab(text: ' Data Subscription '),
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