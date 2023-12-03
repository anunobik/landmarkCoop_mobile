import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/login_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/pages/completed.dart';
import 'package:landmarkcoop_mobile_app/pages/ongoing.dart';
import 'package:landmarkcoop_mobile_app/pages/pending.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:intl/intl.dart';
import '../model/push_notification.dart';
import '../pushNotifications/push_messages.dart';
import '../util/notification_badge.dart';
import 'book_investmentment.dart';
import 'certificate_of_investment.dart';


class Investment extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;
  final OnlineRateResponseModel interestRate;
  const Investment({super.key, required this.fullName, required this.token, required this.customerWallets, required this.lastTransactions, required this.interestRate});

  @override
  State<Investment> createState() => _InvestmentState();
}

class _InvestmentState extends State<Investment> {
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  APIService apiService = APIService();
  List<CustomerInvestmentWalletModel> investData = <CustomerInvestmentWalletModel>[];
  late int noOfInvestments;
  double totalInvestments = 0;
  double roi = 0;
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  String initialInvestLoad = 'Loading Investment...';
  bool finishedLoading = false;

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
    getAllInvestment();
    super.initState();
  }

  getAllInvestment() {
    return apiService.allInvestments(widget.token).then((value) {
      // currentWallet = investData[0];
      for (var singleData in value) {
        investData.add(singleData);
        totalInvestments = totalInvestments + singleData.amount;
        roi = roi + singleData.maturityAmount;
      }

      if (investData.isEmpty) {
        initialInvestLoad = "No Investment Found";
      }
      setState(() {
        investData;
        noOfInvestments = investData.length;
        initialInvestLoad;
        finishedLoading = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeDrawer(
                        value: 1,
                        page: Investment(token: widget.token,
                          fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactions: widget.lastTransactions, interestRate: widget.interestRate,
                        ),
                        name: 'investment',
                        token: widget.token,
                        fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactionsList: widget.lastTransactions
                    ))
                );
              },
              icon: Icon(
                Icons.menu,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Investment',
                style: GoogleFonts.montserrat(
                  color: const Color(0xff091841),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            finishedLoading ?
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: height * 0.4,
                    child:  investData.isNotEmpty ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: investData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 13.0),
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => CertificateOfInvestment(customerInvestmentWalletModel: investData[index],))
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
                              title: Text(investData[index].displayName,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('NGN ${displayAmount.format(investData[index].amount)}',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(investData[index].maturityTime.substring(0, 10),
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
                    ) : Column(
                      children: [
                        SizedBox(height: 50,),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            initialInvestLoad,
                            style: GoogleFonts.montserrat(
                              color: const Color(0xff091841),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              token: widget.token, interestRate: widget.interestRate, lastTransactions: widget.lastTransactions,))
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
                  // Divider(
                  //   thickness: 2,
                  //   color: Colors.lightBlue.withOpacity(0.2),
                  // ),
                  // Text('View Investment Certificate',
                  //   style: GoogleFonts.montserrat(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w700,
                  //   ),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(
                  //         MaterialPageRoute(builder: (context) => CertificateOfInvestment(customerInvestmentWalletModel: null,),)
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.lightBlue,
                  //     shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(20)
                  //     ),
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  //     child: Text('View',
                  //       style: GoogleFonts.montserrat(
                  //         color: Colors.white,
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ) : Column(
              children: [
                SizedBox(height: 50,),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    initialInvestLoad,
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff091841),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
//   Future<LoginResponseModel> getCustomerWallets(){
//     APIService apiService = APIService();
//     return apiService.pageReload(widget.token);
//   }
//
//   Widget futureTabWidgetBuilder(){
//     return FutureBuilder<LoginResponseModel>(
//         future: getCustomerWallets(),
//         builder: (context, snapshot) {
//           if(snapshot.hasData){
//             return Expanded(
//               child: TabBarView(
//                   children: [
//                     OngoingInvestment(
//                       token: widget.token, customerWallets: snapshot.data!.customerWalletsList, fullName: widget.fullName,
//                     ),
//                     Pending(token: widget.token, customerWallets: snapshot.data!.customerWalletsList, fullName: widget.fullName,),
//                     Completed(token: widget.token, fullName: widget.fullName,),
//                   ]
//               ),
//             );
//           }else{
//             return Column(
//               children: [
//                 const SizedBox(height: 50,),
//                 Container(child: const Center(child: Text('Please wait Accounts loading...')),),
//               ],
//             );
//           }
//         });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: DefaultTabController(
//         length: 3,
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Row(
//                 children: <Widget>[
//                   IconButton(
//                     padding: EdgeInsets.zero,
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(builder: (context) => HomeDrawer(
//                           value: 1,
//                           page: Investment(token: widget.token,
//                             fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactions: widget.lastTransactions,
//                           ),
//                           name: 'investment',
//                           token: widget.token,
//                           fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactionsList: widget.lastTransactions
//                           ))
//                       );
//                     },
//                     icon: Icon(
//                       Icons.menu,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(width: 80),
//                   Text(
//                     'Investment',
//                     style: GoogleFonts.openSans(
//                       color: const Color(0xff091841),
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 8),
//                 height: 45,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 child: TabBar(
//                   indicator: BoxDecoration(
//                     color: const Color.fromRGBO(0, 0, 139, 1),
//                     borderRadius: BorderRadius.circular(25),
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
//                     Tab(text: 'Ongoing'),
//                     Tab(text: 'Pending'),
//                     Tab(text: 'Completed'),
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
// class Investment extends StatefulWidget {
//   final String fullName;
//   final String token;
//   const Investment({Key? key, required this.fullName, required this.token}) : super(key: key);

//   @override
//   State<Investment> createState() => _InvestmentState();
// }

// class _InvestmentState extends State<Investment> {

//   Future<LoginResponseModel> getCustomerWallets(){
//     APIService apiService = APIService();
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
//                     BookInvestment(token: widget.token, customerWallets: snapshot.data!.customerWalletsList, fullName: widget.fullName,),
//                     InvestmentCert(token: widget.token, fullName: widget.fullName,),
//                   ]
//               ),
//             );
//           }else{
//             return Column(
//               children: [
//                 const SizedBox(height: 50,),
//                 Container(child: const Center(child: Text('Please wait Accounts loading...')),),
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
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(builder: (context) => HomeDrawer(
//                       value: 1,
//                       page: Investment(token: widget.token,
//                         fullName: widget.fullName, ),
//                       name: 'investment',
//                       token: widget.token,
//                       fullName: widget.fullName,
//                       ))
//                   );
//                 },
//                 icon: Icon(
//                   Icons.menu,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 8),
//                 height: 45,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 child: TabBar(
//                   indicator: BoxDecoration(
//                     color: const Color.fromRGBO(0, 0, 139, 1),
//                     borderRadius: BorderRadius.circular(25),
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