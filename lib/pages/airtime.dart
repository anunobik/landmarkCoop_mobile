// import 'dart:async';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttercontactpicker/fluttercontactpicker.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:overlay_support/overlay_support.dart';
// import 'package:intl/intl.dart';
// import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../api/api_service.dart';
// import '../model/airtime_model.dart';
// import '../utils/ProgressHUD.dart';
// import '../utils/notification_badge.dart';
//
// const iOSLocalizedLabels = false;
//
// class Airtime extends StatefulWidget {
//   const Airtime({super.key});
//
//   @override
//   State<Airtime> createState() => _AirtimeState();
// }
//
// class _AirtimeState extends State<Airtime> {
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   TextEditingController telController = TextEditingController(text: 'INSTANT');
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController amountController = TextEditingController();
//   bool isApiCallProcess = false;
//   String phone = "";
//   int amount = 0;
//   bool _value = false;
//   late int totalNotifications;
//   late List notificationList;
//   late final FirebaseMessaging messaging;
//   PushNotification? notificationInfo;
//   late double _walletBalance;
//   String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
//   late String txRef;
//   APIService apiService2 = APIService(subdomain_url: "https://plutus-core.landmarkcooperative.org");
//   bool _enableSubmitBtn = false;
//   bool readPolicy = false;
//
//
//   @override
//   void dispose() {
//     phoneController.dispose();
//     amountController.dispose();
//     super.dispose();
//   }
//   @override
//   void initState() {
//     // Push Notification
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
//       // Parse the message received
//       PushNotification notification = PushNotification(
//         title: message.notification!.title,
//         body: message.notification!.body,
//       );
//       if (mounted) {
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString('notificationTitle', message.notification!.title.toString());
//         await prefs.setString('notificationBody', message.notification!.body.toString());
//         setState(() {
//           notificationInfo = notification;
//           totalNotifications++;
//         });
//         if (notificationInfo != null) {
//           // For displaying the notification as an overlay
//           showSimpleNotification(
//             Text(notificationInfo!.title!,
//               style: GoogleFonts.montserrat(),
//             ),
//             leading: NotificationBadge(totalNotifications: totalNotifications),
//             subtitle: Text(notificationInfo!.body!,
//               style: GoogleFonts.montserrat(),
//             ),
//             background: Color(0xff000080).withOpacity(0.7),
//             duration: const Duration(seconds: 2),
//           );
//         }
//         pushNotify();
//       }
//     });
//
//     // Open to notification screen
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
//       PushNotification notification = PushNotification(
//         title: message.notification!.title,
//         body: message.notification!.body,
//       );
//       if(mounted) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('notificationTitle', message.notification!.title.toString());
//         await prefs.setString('notificationBody', message.notification!.body.toString());
//         setState(() {
//           notificationInfo = notification;
//           totalNotifications++;
//         });
//       }}
//     );
//     totalNotifications = 0;
//     pushNotify();
//     super.initState();
//   }
//
//   void pushNotify() async{
//     final prefs = await SharedPreferences.getInstance();
//     String notificationTitle = prefs.getString('notificationTitle') ?? '';
//     String notificationBody = prefs.getString('notificationBody') ?? '';
//     print('Body - $notificationBody');
//     if(notificationTitle != '') {
//       setState((){
//         notificationList.add({
//           'title' : notificationTitle,
//           'body' : notificationBody,
//         });
//       });
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return ProgressHUD(
//       inAsyncCall: isApiCallProcess,
//       opacity: 0.3,
//       child: _uiSetup(context),
//     );
//   }
//
//   Widget _uiSetup(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: formKey,
//             child: Column(
//               children: <Widget>[
//                 Text('For all networks',
//                   style: GoogleFonts.montserrat(
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 // Row(
//                 //   children: <Widget>[
//                 //     Container(),
//                 //     const Spacer(),
//                 //     GestureDetector(
//                 //       onTap: () {
//                 //         showModalBottomSheet(
//                 //           shape: const RoundedRectangleBorder(
//                 //               borderRadius: BorderRadius.only(
//                 //                   topLeft: Radius.circular(30.0),
//                 //                   topRight: Radius.circular(30.0))),
//                 //           backgroundColor: Colors.white,
//                 //           isScrollControlled: true,
//                 //           context: context,
//                 //           builder: (BuildContext context) {
//                 //             return SavedPhoneNumbers(
//                 //               phoneNoController: phoneController,
//                 //             );
//                 //           },
//                 //         );
//                 //       },
//                 //       child: Text(
//                 //         "Saved Phone Nos.",
//                 //         style: GoogleFonts.montserrat(
//                 //           color: Colors.blue,
//                 //           fontWeight: FontWeight.w600,
//                 //           decoration: TextDecoration.underline,
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),
//                 // const SizedBox(height: 15),
//                 TextFormField(
//                   keyboardType: TextInputType.text,
//                   textAlign: TextAlign.center,
//                   controller: telController,
//                   enabled: false,
//                   decoration: InputDecoration(
//                     hintText: 'Network Provider',
//                     hintStyle: GoogleFonts.montserrat(
//                       color: Colors.black,
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey.shade200,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   keyboardType: TextInputType.number,
//                   textAlign: TextAlign.center,
//                   controller: phoneController,
//                   onSaved: (input) => phone = input!,
//                   validator: (input) =>
//                       input!.length < 11 ? "Phone No. is incomplete" : null,
//                   decoration: InputDecoration(
//                     labelText: 'Phone No.',
//                     labelStyle: GoogleFonts.montserrat(
//                       color: const Color(0xff9ca2ac),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30.0),
//                       borderSide: const BorderSide(
//                         color: Colors.grey,
//                         width: 0.7,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30.0),
//                       borderSide: const BorderSide(
//                         color: Colors.blue,
//                         width: 0.7,
//                       ),
//                     ),
//                   ),
//                   onChanged: (text) {
//                     phone = phoneController.text;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: TextButton(
//                     onPressed: () async{
//                       final prefs = await SharedPreferences.getInstance();
//                       String subdomain = prefs.getString('subdomain') ??
//                           'https://core.landmarkcooperative.org';
//
//                       final granted =
//                           await FlutterContactPicker.hasPermission();
//
//                       //Todo confirm if privacy policy has been read
//                       readPolicy = prefs.getBool('readPolicy') ?? false;
//
//                       if (!readPolicy) {
//                         readAndAcceptPolicy();
//                         acceptOrRejectPolicy();
//                       } else {
//                         if (!granted) {
//                           await FlutterContactPicker.requestPermission();
//                         }
//                         final PhoneContact contact =
//                             await FlutterContactPicker.pickPhoneContact();
//                         if (contact.phoneNumber!.number!.substring(0, 4) ==
//                             '+234') {
//                           var newPhone = contact.phoneNumber!.number!
//                               .replaceAll('+234', '0');
//                           setState(() {
//                             phoneController.text = newPhone.replaceAll(" ", "");
//                           });
//                         } else {
//                           setState(() {
//                             phoneController.text = contact.phoneNumber!.number!;
//                           });
//                         }
//                         // Look at the code below
//
//                         // APIService apiServicePhone =
//                         //     new APIService(subdomain_url: subdomain);
//                         // apiServicePhone
//                         //     .getAccountFromPhone(
//                         //         phoneController.text.replaceAll(' ', ''), widget.token)
//                         //     .then((value) {
//                         //   setState(() {
//                         //     customerAccountDisplayModel = value;
//                         //     if (value.displayName.isNotEmpty) {
//                         //       disableSendMoneyBtn = false;
//                         //     } else {
//                         //       disableSendMoneyBtn = true;
//                         //     }
//                         //   });
//                         // });
//                       }
//                     },
//                     child: Text('Choose from contacts',
//                       style: GoogleFonts.montserrat(
//                         color: const Color(0xff000080),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: amountController,
//                   textAlign: TextAlign.center,
//                   // autovalidateMode: AutovalidateMode.onUserInteraction,
//                   validator: (input) {
//                     if (input!.isNotEmpty) {
//                       return
//                       double.parse(input) < 100
//                           ? "Enter amount greater than NGN100"
//                           : null;
//                       // _enableSubmitBtn = true;
//
//                     }
//                     return null;
//                   },
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     hintText: 'Enter amount',
//                     hintStyle: GoogleFonts.montserrat(
//                       color: const Color(0xff9ca2ac),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     prefix: Container(
//                       height: 14,
//                       width: 14,
//                       decoration: const BoxDecoration(
//                         image: DecorationImage(
//                           image: AssetImage("assets/pics/naira-black.png"),
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30.0),
//                       borderSide: const BorderSide(
//                         color: Colors.grey,
//                         width: 0.7,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30.0),
//                       borderSide: const BorderSide(
//                         color: Colors.blue,
//                         width: 0.7,
//                       ),
//                     ),
//                   ),
//                   onChanged: (text) {
//                     amount = int.parse(amountController.text);
//                     if(amount >= 100){
//                       setState(() {
//                         _enableSubmitBtn = true;
//                       });
//                       print('input - $text is greater than 100');
//                     }else{
//                       setState(() {
//                         _enableSubmitBtn = false;
//                       });
//                     }
//                   },
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: !_enableSubmitBtn
//                       ? null
//                       : () {
//                     if (formKey.currentState!.validate()) {
//                       setState(() {
//                         isApiCallProcess = true;
//                       });
//                       // AirtimeOnlineRequestModel airtimeOnlineRequestModel = AirtimeOnlineRequestModel(phoneNumber: phoneController.text.trim(), amount: amountController.text.trim());
//                       txRef = "minervahubuser.${phoneController.text.trim()}_$datePart";
//                       InstantAirtimeRequestModel requestModel = InstantAirtimeRequestModel(phoneNumber: phoneController.text.trim(), amount: amountController.text.trim(), transactionRef: txRef);
//
//                       // APIService apiService = APIService(subdomain_url: "https://plutus-core.landmarkcooperative.org");
//                       // apiService.getWalletInfo(user!.uid).then((value) {
//                       //   _walletBalance = value.balance;
//                       //   if (_walletBalance < amount) {
//                       //     setState(() {
//                       //       isApiCallProcess = false;
//                       //     });
//                       //     showDialog(
//                       //         context: context,
//                       //         builder: (BuildContext context) {
//                       //           return const AlertDialog(
//                       //             title: Text("Message"),
//                       //             content: Text("Insufficent Balance!"),
//                       //           );
//                       //         });
//                       //   }else{
//                       //     // apiService.airtimeRequest(user.uid, airtimeOnlineRequestModel);
//                       //     // if(_value) savePhoneNo(context);
//                       //     // Navigator.of(context).pushReplacement(
//                       //     //     MaterialPageRoute(builder: (context) => const ProcessingAirtimeRequest())
//                       //     // );
//                       //     apiService
//                       //         .debitWalletInstantAirtime(
//                       //         requestModel, user.uid)
//                       //         .then((valueTransactionRes) {
//                       //       if (valueTransactionRes.result) {
//                       //         rechargePhone(valueTransactionRes);
//                       //       } else {
//                       //         setState(() {
//                       //           isApiCallProcess = false;
//                       //         });
//                       //         showDialog(
//                       //             context: context,
//                       //             builder: (BuildContext context) {
//                       //               return const AlertDialog(
//                       //                 title: Text("Notice"),
//                       //                 content: Text("Transaction not completed!"),
//                       //               );
//                       //             });
//                       //       }
//                       //     });
//                       //   }
//                       // });
//                       // user == null ? Navigator.of(context).pushReplacement(
//                       //   MaterialPageRoute(builder: (context) => const ProcessingAirtimeRequest())
//                       // )
//                       // : _value ? savePhoneNo(context)
//                       // : Navigator.of(context).pushReplacement(
//                       //     MaterialPageRoute(builder: (context) => const ProcessingAirtimeRequest())
//                       // );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.lightBlue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 15, horizontal: 25),
//                     child: Text(
//                       'Submit',
//                       style: GoogleFonts.montserrat(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // void rechargePhone(
//   //     InstantAirtimeFeedbackResponseModel valueTransactionRes) {
//   //   String displayDate = DateFormat('yyyy-MMM-dd').format(DateTime.now());
//   //   FlutterWaveService apiFlutterWave = FlutterWaveService();
//   //   User? user = FirebaseAuth.instance.currentUser;
//   //   AirtimeRequestModel airtimeRequestModel = AirtimeRequestModel(phoneNumber: valueTransactionRes.phoneNumber, amount: valueTransactionRes.amount, reference: valueTransactionRes.transactionRef);
//   //   apiFlutterWave.buyAirtime(airtimeRequestModel).then((value) {
//   //     if (value == 'Successful') {
//   //       setState(() {
//   //         isApiCallProcess = false;
//   //       });
//   //       Navigator.of(context).pushReplacement(
//   //               MaterialPageRoute(builder: (context) => const ProcessingAirtimeRequest())
//   //           );
//   //     } else {
//   //       setState(() {
//   //         isApiCallProcess = false;
//   //       });
//
//   //       //Todo reverse the debit amount
//   //       if (user != null) {
//   //         apiService2.reverseInstantAirtimeFeedback(
//   //             user.uid, valueTransactionRes.id);
//   //       }
//
//   //       showDialog(
//   //           context: context,
//   //           builder: (BuildContext context) {
//   //             return AlertDialog(
//   //               title: const Text("Failed!"),
//   //               content: Text(value),
//   //             );
//   //           });
//   //     }
//   //   });
//   // }
//
//   // Read and Accept Policy
//   void readAndAcceptPolicy() {
//     Future<void>? launched;
//     Uri url = Uri.parse('https://privacypolicy.myminervahub.com');
//
//     Future<void> launchInWebViewOrVC(Uri url) async {
//       if (!await launchUrl(
//         url,
//         mode: LaunchMode.inAppWebView,
//         webViewConfiguration: const WebViewConfiguration(
//             headers: <String, String>{'my_header_key': 'my_header_value'}),
//       )) {
//         throw 'Could not launch $url';
//       }
//     }
//
//     setState(() {
//       launched = launchInWebViewOrVC(url);
//       Timer(const Duration(seconds: 10), () {
//         print('Closing WebView after 10 seconds...');
//         closeInAppWebView();
//       });
//     });
//     // WebViewController _controller;
//     // return Column(
//     //   children: [
//     //     Container(
//     //       child: WebView(
//     //         initialUrl: 'about:blank',
//     //         onWebViewCreated: (WebViewController webViewController) {
//     //           _controller = webViewController;
//     //           _loadHtml(_controller, 'https://privacypolicy.myminervahub.com');
//     //         },
//     //       ),
//     //     )
//     //   ],
//     // );
//   }
//
//   acceptOrRejectPolicy() {
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(builder: (context, setState) {
//           return AlertDialog(
//             title: Container(
//               height: 50,
//               alignment: Alignment.centerLeft,
//               padding: const EdgeInsets.only(left: 15),
//               color: const Color(0xff000080),
//               child: Center(
//                 child: Text(
//                   'Message',
//                   style: GoogleFonts.montserrat(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//             content:
//                 Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
//               Center(
//                 child: Text(
//                   'Notice',
//                   style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: Text(
//                   'Kindly Accept or Click Outside to Reject Privacy Policy',
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.montserrat(
//                     color: Colors.blue,
//                   ),
//                 ),
//               ),
//             ]),
//             actionsAlignment: MainAxisAlignment.start,
//             actions: <Widget>[
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     final prefs = await SharedPreferences.getInstance();
//                     prefs.setBool('readPolicy', true);
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey.shade200,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 10, horizontal: 10),
//                     child: Text(
//                       "Agree",
//                       style: GoogleFonts.montserrat(
//                         color: const Color(0xff000080),
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         });
//       });
//   }
// }