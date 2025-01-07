import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/login_model.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/pages/pin_reset.dart';
import 'package:landmarkcoop_mobile_app/pages/transaction_pin.dart';
import 'package:landmarkcoop_mobile_app/pages/update_bvn.dart';
import 'package:landmarkcoop_mobile_app/utils/InactivityService.dart';
import 'package:landmarkcoop_mobile_app/utils/notification_badge.dart';
import 'package:landmarkcoop_mobile_app/widgets/bottom_nav_bar.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../change_password.dart';
import '../change_phone_no.dart';

class Setting extends StatefulWidget {
  final int pageIndex;
  final String fullName;
  final String token;
  final String phoneNumber;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const Setting(
      {Key? key,
        required this.pageIndex,
        required this.customerWallets,
        required this.fullName,
        required this.token, required this.phoneNumber})
      : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  LoginRequestModel loginRequestModel = LoginRequestModel();
  bool isModifyPhoneDialogShown = false;
  bool isModifyPasswordDialogShown = false;
  bool isPinResetDialogShown = false;
  bool isBVNDialogShown = false;
  bool isDeleteDialogShown = false;
  bool isTransactionPinDialogShown = false;
  bool isBvnLinked = false;
  bool isMinervaHub = false;
  bool createPin = false;

  @override
  void initState() {
    super.initState();
    InactivityService().initializeInactivityTimer(context, widget.token);
    checkFintech();
    checkPinCreated();
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
    if (widget.customerWallets[0].interBankName.isNotEmpty) {
      setState(() {
        isBvnLinked = true;
      });
    }
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

  Future<void> checkFintech() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    String institution = prefs.getString('institution') ?? 'Minerva Hub';
    if (institution == 'Landmark Coop' ||
        subdomain == null ||
        institution.isEmpty) {
      isMinervaHub = true;
    }
  }

  Future<void> checkPinCreated() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    String institution = prefs.getString('institution') ?? 'Minerva Hub';
    APIService apiService = APIService(subdomain_url: subdomain);
    apiService.isPinCreated(widget.token).then((value) {
      print(value.status);
      setState(() {
        createPin = value.status;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        InactivityService().resetInactivityTimer(context, widget.token);
      },
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 70),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          CupertinoIcons.person_alt_circle,
                          color: Color(0xff091841),
                          size: 50,
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.fullName,
                              style: GoogleFonts.montserrat(
                                  color: const Color(0xff000080),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700
                              ),
                            ),
                            Text(widget.phoneNumber,
                              style: GoogleFonts.montserrat(
                                  color: const Color(0xff000080),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ]
                  ),
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
                            isModifyPhoneDialogShown = true;
                          });
                          changePhoneNo(
                            context,
                            onClosed: (context) {
                              setState(() {
                                isModifyPhoneDialogShown = false;
                              });
                            },
                            fullName: widget.fullName,
                            token: widget.token,
                          );
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
                        child: const Icon(CupertinoIcons.phone,
                            color: Color(0xff000080)),
                      ),
                      title: Text(
                        'Modify Phone',
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
                            isModifyPasswordDialogShown = true;
                          });
                          changePassword(
                            context,
                            onClosed: (context) {
                              setState(() {
                                isModifyPasswordDialogShown = false;
                              });
                            },
                            fullName: widget.fullName,
                            token: widget.token,
                          );
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
                        'Modify Password',
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
                  const SizedBox(height: 20),
                  isMinervaHub
                      ? isBvnLinked
                      ? Container()
                      : Container(
                    decoration:
                    BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: const Color(0xff091841).withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(3, 3),
                      ),
                    ]),
                    child: ListTile(
                      onTap: () {
                        Future.delayed(
                            const Duration(milliseconds: 800), () {
                          setState(() {
                            isBVNDialogShown = true;
                          });
                          updateBVN(
                            context,
                            onClosed: (context) {
                              setState(() {
                                isBVNDialogShown = false;
                              });
                            },
                            fullName: widget.fullName,
                            token: widget.token,
                            customerWallets: widget.customerWallets,
                          );
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
                        child: const Icon(Icons.update_outlined,
                            color: Color(0xff000080)),
                      ),
                      title: Text(
                        'Update BVN',
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
                  )
                      : Container(),
                  const SizedBox(height: 20),
                  isMinervaHub
                      ? Container(
                    decoration:
                    BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: const Color(0xff091841).withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(3, 3),
                      ),
                    ]),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TransactionPin(
                              fullName: widget.fullName,
                              token: widget.token,
                              customerWallets:
                              widget.customerWallets,
                            )));
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
                        child: const Icon(Icons.password,
                            color: Color(0xff000080)),
                      ),
                      title: Text(
                        'Transaction Pin',
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
                  )
                      : Container(),
                  const SizedBox(height: 20),
                  createPin ? Container(
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
                            isPinResetDialogShown = true;
                          });
                          pinReset(
                            context,
                            onClosed: (context) {
                              setState(() {
                                isPinResetDialogShown = false;
                              });
                            },
                            fullName: widget.fullName,
                            token: widget.token,
                            customerWallets: widget.customerWallets,
                          );
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
                        'Reset Pin Code',
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
                  ) : Container(),
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
                        deleteAccountDialog(context, widget.token);
                      },
                      leading: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.redAccent.shade100,
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.trash,
                          color: Colors.red,
                        ),
                      ),
                      title: Text(
                        'Delete Account',
                        style: GoogleFonts.openSans(
                          color: const Color(0xff091841),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  // Delete Account

  void deleteAccountDialog(context, String token) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return StatefulBuilder(builder: ((context, setState) {
            return Transform.scale(
              scale: a1.value,
              child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  scrollable: true,
                  title: Text(
                    'Delete Your Account',
                    style: GoogleFonts.openSans(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Are you sure you want to delete your account?',
                        style: GoogleFonts.montserrat(fontSize: 15),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        // APIService apiService = APIService();
                        // apiService.deleteUser(token, context);
                        // Navigator.popUntil(context, (route) => route.isFirst);
                        // Navigator.of(context).pushReplacement(
                        //   MaterialPageRoute(
                        //     builder: (context) => const Login()
                        //   ),
                        // );
                      },
                      child: Text(
                        'Yes',
                        style: GoogleFonts.montserrat(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'No',
                        style: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }));
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: "",
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }
}
