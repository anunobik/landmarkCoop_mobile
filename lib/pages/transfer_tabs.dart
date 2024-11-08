import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/login_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/pages/transfer_external.dart';
import 'package:landmarkcoop_mobile_app/pages/transfer_ozi.dart';
import 'package:landmarkcoop_mobile_app/pages/transfer_status.dart';
import 'package:landmarkcoop_mobile_app/pushNotifications/push_messages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../model/push_notification.dart';
import '../util/notification_badge.dart';

class TransferTabs extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const TransferTabs(
      {super.key,
      required this.customerWallets,
      required this.token,
      required this.fullName,
      required this.lastTransactions});

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
    APIService apiService = APIService();
    return apiService.pageReload(widget.token);
  }

  Widget futureTabWidgetBuilder() {
    return FutureBuilder<LoginResponseModel>(
        future: getCustomerWallets(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Expanded(
              child: TabBarView(children: [
                Transfer(
                  fullName: widget.fullName,
                  token: widget.token,
                  customerWallets: widget.customerWallets,
                  lastTransactions: widget.lastTransactions,
                ),
                TransferExternal(
                  customerWallets: widget.customerWallets,
                  fullName: widget.fullName,
                  token: widget.token,
                  lastTransactions: widget.lastTransactions,
                ),
                TransferStatus(
                  customerWallets: widget.customerWallets,
                  fullName: widget.fullName,
                  token: widget.token,
                  lastTransactions: widget.lastTransactions,
                ),
              ]),
            );
          } else {
            return const Column(
              children: [
                SizedBox(height: 50),
                SizedBox(
                  child: Center(child: Text('Please wait Accounts loading...')),
                ),
              ],
            );
          }
        });
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if (mounted) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'notificationTitle', message.notification!.title.toString());
        await prefs.setString(
            'notificationBody', message.notification!.body.toString());
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });
        if (notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(
              notificationInfo!.title!,
              style: GoogleFonts.montserrat(),
            ),
            leading: NotificationBadge(totalNotifications: totalNotifications),
            subtitle: Text(
              notificationInfo!.body!,
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
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'notificationTitle', message.notification!.title.toString());
        await prefs.setString(
            'notificationBody', message.notification!.body.toString());
        String subdomain =
            prefs.getString('subdomain') ?? 'core.landmarkcooperative.org';
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });

        // API Sign in token
        APIService apiService = APIService();
        apiService.login(loginRequestModel).then((value) {
          if (value.customerWalletsList.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PushMessages(notificationList: notificationList, totalNotifications: totalNotifications),
              ),
            );
            notificationList.add({
              'title': message.notification!.title,
              'body': message.notification!.body,
            });
          }
        });
      }
    });
    totalNotifications = 0;
    pushNotify();
    if (widget.customerWallets[0].interBankName.isNotEmpty) {
      setState(() {
        isBvnLinked = true;
      });
    }
    super.initState();
  }

  void pushNotify() async {
    final prefs = await SharedPreferences.getInstance();
    String notificationTitle = prefs.getString('notificationTitle') ?? '';
    String notificationBody = prefs.getString('notificationBody') ?? '';
    print('Body - $notificationBody');
    if (notificationTitle != '') {
      setState(() {
        notificationList.add({
          'title': notificationTitle,
          'body': notificationBody,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HomeDrawer(
                            value: 1,
                            page: TransferTabs(
                              token: widget.token,
                              fullName: widget.fullName,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactions,
                            ),
                            name: 'Transfer',
                            token: widget.token,
                            fullName: widget.fullName,
                            customerWallets: widget.customerWallets,
                            lastTransactionsList: widget.lastTransactions)));
                  },
                  icon: Icon(
                    Icons.menu,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Transfer',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff091841),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                isMinervaHub
                    ? Container(
                        margin: const EdgeInsets.fromLTRB(8, 30, 8, 10),
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
                              fontWeight: FontWeight.bold),
                          unselectedLabelStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'In-House'),
                            Tab(text: 'Other Banks'),
                            Tab(text: 'Status'),
                          ],
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.fromLTRB(8, 60, 8, 20),
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
                              fontWeight: FontWeight.bold),
                          unselectedLabelStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'Landmark Users'),
                            Tab(text: 'Withdrawal Request')
                          ],
                        ),
                      ),
                futureTabWidgetBuilder(),
              ],
            )),
      ),
    );
  }
}
