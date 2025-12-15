import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/api/api_service.dart';
import 'package:landmarkcoop_latest/component/side_menu.dart';
import 'package:landmarkcoop_latest/model/customer_model.dart';
import 'package:landmarkcoop_latest/model/other_model.dart';
import 'package:landmarkcoop_latest/model/push_notification.dart';
import 'package:landmarkcoop_latest/pages/airtime_tabs.dart';
import 'package:landmarkcoop_latest/pages/bottomPages/customer_care.dart';
import 'package:landmarkcoop_latest/pages/bottomPages/dashboard.dart';
import 'package:landmarkcoop_latest/pages/bottomPages/setting.dart';
import 'package:landmarkcoop_latest/pages/bottomPages/transfer_tabs.dart';
import 'package:landmarkcoop_latest/pages/cable_tv.dart';
import 'package:landmarkcoop_latest/pages/investment.dart';
import 'package:landmarkcoop_latest/pages/logout_page.dart';
import 'package:landmarkcoop_latest/pages/statement_screen.dart';
import 'package:landmarkcoop_latest/pushNotifications/push_messages.dart';
import 'package:landmarkcoop_latest/utils/notification_badge.dart';
import 'package:landmarkcoop_latest/utils/rive_utils.dart';
import 'package:landmarkcoop_latest/widgets/menu_btn.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rive/rive.dart' as rive;
import 'package:shared_preferences/shared_preferences.dart';

class EntryPoint extends StatefulWidget {
  final String screenName;
  final String fullName;
  final String token;
  final String subdomain;
  final String referralId;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const EntryPoint({
    super.key,
    required this.screenName,
    required this.fullName,
    required this.token,
    required this.subdomain,
    required this.customerWallets,
    required this.referralId,
  });

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> animation;
  late Animation<double> scalAnimation;
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];

  late rive.SMIBool isSideBarClosed;

  bool isSideMenuClosed = true;
  OnlineRateResponseModel newValue = OnlineRateResponseModel(
      id: 0,
      oneMonth: 0,
      twoMonth: 0,
      threeMonth: 0,
      fourMonth: 0,
      fiveMonth: 0,
      sixMonth: 0,
      sevenMonth: 0,
      eightMonth: 0,
      nineMonth: 0,
      tenMonth: 0,
      elevenMonth: 0,
      twelveMonth: 0);

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
      setState(() {});
    });

    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.fastOutSlowIn),
    );
    getRate();

    // Push Notification
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
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('notificationTitle', message.notification!.title.toString());
        await prefs.setString('notificationBody', message.notification!.body.toString());
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context)=> EntryPoint(
              customerWallets: widget.customerWallets,
              fullName: widget.fullName,
              screenName: 'Notification',
              subdomain: widget.subdomain,
              token: widget.token,
              referralId: widget.referralId,
            ),
          ),
        );
      }
    });
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
        notificationList = [{
          'title' : notificationTitle,
          'body' : notificationBody,
        }];
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  getRate() async {
    APIService apiService = APIService(subdomain_url: widget.subdomain);
    OnlineRateResponseModel value =
    await apiService.getOnlineRate(widget.token);
    setState(() {
      newValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9B9DA1),
      resizeToAvoidBottomInset: true,
      extendBody: true,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: 288,
            left: isSideMenuClosed ? -288 : 0,
            height: MediaQuery.of(context).size.height,
            child: SideMenu(
              fullName: widget.fullName,
              subdomain: widget.subdomain,
              token: widget.token,
              customerWallets: widget.customerWallets,
              referralId: widget.referralId,
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(animation.value - 30 * animation.value * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 265, 0),
              child: Transform.scale(
                scale: scalAnimation.value,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: widget.screenName == "Home" ? Dashboard(
                    customerWallets: widget.customerWallets,
                    fullName: widget.fullName,
                    token: widget.token, pageIndex: 0,
                  )
                      : widget.screenName == "Statement" ? StatementScreen(
                    fullName: widget.fullName,
                    token: widget.token,
                  )
                      : widget.screenName == "Cable Tv" ? CableTv(
                    customerWallets: widget.customerWallets,
                    fullName: widget.fullName,
                    token: widget.token,
                  )
                      : widget.screenName == "Investment" ? Investment(
                    fullName: widget.fullName,
                    token: widget.token,
                    interestRate: newValue,
                  )
                      : widget.screenName == "Cable Tv" ? CableTv(customerWallets: widget.customerWallets, fullName: widget.fullName, token: widget.token,)
                      : widget.screenName == "Airtime / Data" ? AirtimeTabs(customerWallets: widget.customerWallets, fullName: widget.fullName, token: widget.token,)
                      : widget.screenName == "Settings" ? Setting(
                    pageIndex: 2,
                    fullName: widget.fullName,
                    token: widget.token,
                    customerWallets: widget.customerWallets, phoneNumber: widget.referralId,
                  )
                      : widget.screenName == "Contact Center" ? ContactCustomerSupport(
                    pageIndex: 3,
                    customerWallets:
                    widget.customerWallets,
                    fullName: widget.fullName,
                    token: widget.token,
                    referralId: widget.referralId,
                  )
                      : widget.screenName == "Transfer" ? TransferTabs(
                    pageIndex: 1,
                    customerWallets: widget.customerWallets,
                      fullName: widget.fullName,
                      token: widget.token,
                      subdomain: widget.subdomain,)
                      : widget.screenName == "Notification" ? PushMessages(notificationList: [], totalNotifications: 0,)
                      : widget.screenName == "Logout" ? LogoutPage(
                        token: widget.token
                      )
                      : Dashboard(
                    pageIndex: 0,
                    customerWallets: widget.customerWallets,
                    fullName: widget.fullName,
                    token: widget.token,
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideMenuClosed ? 0 : 220,
            top: 16,
            child: MenuBtn(
              riveOnInit: (artboard) {
                rive.StateMachineController controller = RiveUtils.getRiveController(
                    artboard,
                    stateMachineName: "State Machine");
                isSideBarClosed = controller.findSMI("isOpen") as rive.SMIBool;
                isSideBarClosed.value = true;
              },
              press: () {
                isSideBarClosed.value = !isSideBarClosed.value;
                if (isSideMenuClosed) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
                setState(() {
                  isSideMenuClosed = isSideBarClosed.value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}