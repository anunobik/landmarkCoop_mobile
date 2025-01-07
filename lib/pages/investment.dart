import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/entry_point.dart';
import 'package:landmarkcoop_mobile_app/model/login_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/utils/notification_badge.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'book_investmentment.dart';
import 'investment_cert.dart';

class Investment extends StatefulWidget {
  final String fullName;
  final String token;
  final OnlineRateResponseModel interestRate;
  const Investment({Key? key, required this.fullName, required this.interestRate, required this.token}) : super(key: key);

  @override
  State<Investment> createState() => _InvestmentState();
}

class _InvestmentState extends State<Investment> {
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  LoginRequestModel loginRequestModel = LoginRequestModel();

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
                    BookInvestment(token: widget.token, customerWallets: snapshot.data!.customerWalletsList, interestRate: widget.interestRate, fullName: widget.fullName,),
                    InvestmentCert(token: widget.token, fullName: widget.fullName,),
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
              // const SizedBox(height: 10),
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
                    Tab(text: ' Investment '),
                    Tab(text: ' Certificate '),
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



// Previous Code

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:landmarkcoop_mobile_app/model/other_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../api/api_service.dart';
// import '../model/login_model.dart';
// import '../utils/home_drawer.dart';
// import 'book_investmentment.dart';
// import 'investment_cert.dart';

// class Investment extends StatefulWidget {
//   final String fullName;
//   final String token;
//   final OnlineRateResponseModel interestRate;
//   const Investment({Key? key, required this.fullName, required this.interestRate, required this.token}) : super(key: key);

//   @override
//   State<Investment> createState() => _InvestmentState();
// }

// class _InvestmentState extends State<Investment> {

//   Future<LoginResponseModel> getCustomerWallets() async {
//     final prefs = await SharedPreferences.getInstance();
//     String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

//     APIService apiService = APIService(subdomain_url: subdomain);
//     return apiService.pageReload(widget.token);
//   }

//   Widget futureTabWidgetBuilder(){
//     return FutureBuilder<LoginResponseModel>(
//         future: getCustomerWallets(),
//         builder: (context, snapshot) {
//           if(snapshot.hasData){
//             return Expanded(
//               child: TabBarView(
//                   children: [
//                     BookInvestment(token: widget.token, customerWallets: snapshot.data!.customerWalletsList, interestRate: widget.interestRate, fullName: widget.fullName,),
//                     InvestmentCert(token: widget.token, fullName: widget.fullName,),
//                   ]
//               ),
//             );
//           }else{
//             return Column(
//               children: [
//                 SizedBox(height: 50,),
//                 Container(child: Center(child: Text('Please wait Accounts loading...')),),
//               ],
//             );
//           }
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 onPressed: () async {
//                   final prefs = await SharedPreferences.getInstance();
//                   String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

//                   Navigator.of(context).push(
//                     MaterialPageRoute(builder: (context) => HomeDrawer(
//                       value: 1,
//                       page: Investment(token: widget.token,
//                         fullName: widget.fullName, interestRate: widget.interestRate, ),
//                       name: 'investment',
//                       token: widget.token,
//                       fullName: widget.fullName,
//                       subdomain: subdomain,
//                       ))
//                   );
//                 },
//                 icon: Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 8),
//                 height: 45,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: TabBar(
//                   indicator: BoxDecoration(
//                     color: Color(0xff000080),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   labelColor: Colors.white,
//                   unselectedLabelColor: Colors.grey,
//                   labelStyle: GoogleFonts.montserrat(
//                     fontWeight: FontWeight.bold
//                   ),
//                   unselectedLabelStyle: GoogleFonts.montserrat(
//                     fontWeight: FontWeight.bold
//                   ),
//                   tabs: const [
//                     Tab(text: 'Book'),
//                     Tab(text: 'Certificate'),
//                   ],
//                 ),
//               ),
//               futureTabWidgetBuilder(),
//             ],
//           )
//         ),
//       ),
//     );
//   }
// }