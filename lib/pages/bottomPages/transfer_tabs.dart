import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/entry_point.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/login_model.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/pages/transfer_external.dart';
import 'package:landmarkcoop_mobile_app/pages/transfer_ozi.dart';
import 'package:landmarkcoop_mobile_app/pages/transfer_status.dart';
import 'package:landmarkcoop_mobile_app/pages/withdrawal_request.dart';
import 'package:landmarkcoop_mobile_app/utils/InactivityService.dart';
import 'package:landmarkcoop_mobile_app/utils/notification_badge.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferTabs extends StatefulWidget {
  final int pageIndex;
  final String fullName;
  final String token;
  final String subdomain;
  final List<CustomerWalletsBalanceModel> customerWallets;
  const TransferTabs({super.key, required this.pageIndex, required this.customerWallets, required this.token, required this.fullName, required this.subdomain});

  @override
  State<TransferTabs> createState() => _TransferTabsState();
}

class _TransferTabsState extends State<TransferTabs> {
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  LoginRequestModel loginRequestModel = LoginRequestModel();
  bool isBvnLinked = false;
  bool isMinervaHub = true;

  Future<LoginResponseModel> getCustomerWallets() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    return apiService.pageReload(widget.token);
  }

  Widget futureTabWidgetBuilder(){
    return FutureBuilder<LoginResponseModel>(
        future: getCustomerWallets(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return Expanded(
              child: TabBarView(
                  children: [
                    Transfer(
                      fullName: widget.fullName, 
                      token: widget.token),
                    isMinervaHub?
                    TransferExternal(
                      customerWallets:
                      widget.customerWallets,
                      fullName: widget.fullName,
                      token: widget.token,
                    ):
                    WithdrawalRequest(
                      customerWallets: snapshot.data!.customerWalletsList, 
                      fullName: widget.fullName, 
                      token: widget.token, 
                      subdomain: widget.subdomain),
                    TransferStatus(customerWallets: widget.customerWallets, fullName: widget.fullName, token: widget.token,),
                  ]
              ),
            );
          }else{
            return Column(
              children: const [
                SizedBox(height: 50),
                SizedBox(child: Center(child: Text('Please wait Accounts loading...')),),
              ],
            );
          }
        });
  }


  @override
  void initState() {
    // checkFintech();
    InactivityService().initializeInactivityTimer(context, widget.token);
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
                referralId: value.customerWalletsList[0].phoneNo,
                ),
              ),
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
    if (widget.customerWallets[0].interBankName.isNotEmpty) {
      setState(() {
        isBvnLinked = true;
      });
    }
    super.initState();
  }

  // Future<void> checkFintech() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String subdomain =
  //       prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
  //   String institution = prefs.getString('institution') ?? 'Minerva Hub';
  //   if (institution == 'Landmark Coop' ||
  //       subdomain == null ||
  //       institution.isEmpty) {
  //     isMinervaHub = true;
  //   }
  // }

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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        InactivityService().resetInactivityTimer(context, widget.token);
      },
      child: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                isMinervaHub?
                Container(
                  margin: const EdgeInsets.fromLTRB(8,60,8,10),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
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
                      Tab(text: 'Landmark Users '),
                      Tab(text: 'Other Banks'),
                      Tab(text: 'Status'),
                    ],
                  ),
                ): Container(
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
                      Tab(text: 'Landmark Coop Users'),
                      Tab(text: 'Withdrawal Request')
                    ],
                  ),
                ),
                futureTabWidgetBuilder(),
              ],
            )
          ),
        ),
      ),
    );
  }
}