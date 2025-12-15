import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/model/cable_tv_model.dart';
import 'package:landmarkcoop_latest/pages/pay_cableTv.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_flutterwave.dart';
import '../api/api_service.dart';
import '../model/customer_model.dart';
import '../model/login_model.dart';
import '../model/push_notification.dart';
import '../utils/ProgressHUD.dart';
import '../utils/notification_badge.dart';
import '../widgets/bottom_nav_bar.dart';

class CableTv extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const CableTv({
    Key? key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
  }) : super(key: key);

  @override
  State<CableTv> createState() => _CableTv();
}

class _CableTv extends State<CableTv> {
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  LoginRequestModel loginRequestModel = LoginRequestModel();
  FlutterWaveService flutterWaveService = FlutterWaveService();
  List<CableTvTypeInfoResponseModel> data = [];

  // List<CableTvTypeInfoResponseModel> data = <CableTvTypeInfoResponseModel>[
  //   CableTvTypeInfoResponseModel(
  //     id: 0,
  //     biller_code: '',
  //     name: '',
  //     logo: '',
  //     description: '',
  //     short_name: '',
  //     country_code: '',
  //   )
  // ];
  bool isApiCallProcess = false;
  List<dynamic> itemData = [];
  bool isCableTvDialogShown = false;
  List<BillsInfoResponseModel> cableTvList = [];

  @override
  void initState() {
    super.initState();
    getCableTvList();
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
            background: Color(0xff000080).withOpacity(0.7),
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
        APIService apiService = APIService(subdomain_url: subdomain);
        apiService.login(loginRequestModel).then((value) {
          if (value.customerWalletsList.isNotEmpty) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => BottomNavBar(
                pageIndex: 0,
                fullName: value.customerWalletsList[0].fullName,
                token: value.token,
                subdomain: subdomain,
                customerWallets: value.customerWalletsList,
                phoneNumber: value.customerWalletsList[0].phoneNo,
              ),
            ));
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
  }

  getCableTvList() {
    return flutterWaveService.getCableTvTypeList(widget.token).then((value) {
      for (var singleData in value) {
        data.add(singleData);
      }
      setState(() {
        data;
      });
    });
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
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
    return SafeArea(
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
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  'Select Cable TV',
                  style: GoogleFonts.montserrat(
                      color: const Color(0xff000080),
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              data.length > 1
                  ? allCableList(data)
                  : Center(
                      child: Text(
                        'Loading Cable Tv...',
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff000080),
                          fontSize: 15,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  allCableList(List<CableTvTypeInfoResponseModel> responseList) {
    List<Widget> histItems = [];
    for (var data in responseList) {
      histItems.add(
        Column(
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: const Color(0xff091841).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(3, 3),
                ),
              ]),
              child: ListTile(
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 800), () {
                    setState(() {
                      isCableTvDialogShown = true;
                    });
                    flutterWaveService
                        .getBillsList(data.biller_code, widget.token)
                        .then((value) {
                      payCableTv(
                        context,
                        onClosed: (context) {
                          setState(() {
                            isCableTvDialogShown = false;
                          });
                        },
                        fullName: widget.fullName,
                        token: widget.token,
                        cableTvList: value,
                        customerWallets: widget.customerWallets,
                      );
                    });
                  });
                },
                leading: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.lightBlue,
                    ),
                  ),
                  child: const Icon(Icons.edit_note_outlined,
                      color: Color(0xff000080)),
                ),
                title: Text(
                  data.name,
                  style: GoogleFonts.openSans(
                    color: const Color(0xff000080),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.lightBlue,
                ),
              ),
            ),
          ],
        ),
      );
    }
    setState(() {
      itemData = histItems;
    });

    return Column(
      children: histItems,
    );
  }
}
