// import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
// import 'package:landmarkcoop_mobile_app/model/other_model.dart';
// import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
// import 'package:landmarkcoop_mobile_app/pages/add_card.dart';
// import 'package:landmarkcoop_mobile_app/pushNotifications/push_messages.dart';
// import 'package:landmarkcoop_mobile_app/util/card_details.dart';
// import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
// import 'package:landmarkcoop_mobile_app/util/notification_badge.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:overlay_support/overlay_support.dart';

// class ManageCards extends StatefulWidget {
//   final String fullName;
//   final String token;
//   final List<CustomerWalletsBalanceModel> customerWallets;
//   final List<LastTransactionsModel> lastTransactions;
//   const ManageCards({super.key, required this.fullName, required this.token, required this.customerWallets, required this.lastTransactions});

//   @override
//   State<ManageCards> createState() => _ManageCardsState();
// }

// class _ManageCardsState extends State<ManageCards> {
//   bool edit = false;
//   String chooseCard = '1';
//   late int totalNotifications;
//   late final FirebaseMessaging messaging;
//   PushNotification? notificationInfo;
//   List notificationList = [];

//   @override
//   void initState() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       // Parse the message received
//       PushNotification notification = PushNotification(
//         title: message.notification?.title,
//         body: message.notification?.body,
//       );

//       if (mounted) {
//         setState(() {
//         notificationInfo = notification;
//         totalNotifications++;
//       });
//       if (notificationInfo != null) {
//         // For displaying the notification as an overlay
//         showSimpleNotification(
//           Text(notificationInfo!.title!),
//           leading: NotificationBadge(totalNotifications: totalNotifications),
//           subtitle: Text(notificationInfo!.body!),
//           background: Colors.cyan.shade700,
//           duration: const Duration(seconds: 2),
//         );
//         notificationList.add(
//           {
//             "title": notificationInfo!.title!,
//             "body": notificationInfo!.body!
//           },
//         );
//       }
//       }
//     });

//     // Open to notification screen
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
//       PushNotification notification = PushNotification(
//         title: message.notification!.title,
//         body: message.notification!.body,
//       );
//       if(mounted) {
//         setState(() {
//           notificationInfo = notification;
//           totalNotifications++;
//         });
//         notificationList.add({
//           'title' : notificationInfo!.title,
//           'body' : notificationInfo!.body,
//         });

//         // API Sign in token
        
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (context)=>  PushMessages(
//                 notificationList: notificationList, 
//                 totalNotifications: totalNotifications,
//               ))
//             );
//         }
//       }
//     );
//     totalNotifications = 0;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//   var height = MediaQuery.of(context).size.height;
//   var width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.0,
//         centerTitle: true,
//         leading: IconButton(
//           padding: EdgeInsets.zero,
//           onPressed: () {
//             Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => HomeDrawer(
//                 value: 1,
//                 page: ManageCards(
//                   fullName: widget.fullName, 
//                   token: widget.token, customerWallets: widget.customerWallets,
//                   lastTransactions: widget.lastTransactions,
//                 ),
//                 name: 'card',
//                 token: widget.token,
//                 fullName: widget.fullName, 
//                 customerWallets: widget.customerWallets,
//                 lastTransactionsList: widget.lastTransactions,
//                 )
//               )
//             );
//           },
//           icon: Icon(
//             Icons.menu,
//             color: Colors.grey.shade600,
//           ),
//         ),
//         title: Text(
//           'Manage Your Cards',
//           style: GoogleFonts.openSans(
//             color: const Color(0xff091841),
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Color(0xff091841)),
//       ),
//       body: SizedBox(
//         height: height,
//         width: width,
//         child: Column(
//           children: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       edit = !edit;
//                     });
//                   }, 
//                   child: Text(edit ? 'Cancel' : 'Edit',
//                     style: GoogleFonts.montserrat(
//                       color: edit ? Colors.red : Colors.lightBlue,
//                       fontWeight: FontWeight.w800
//                     ),
//                   ),
//                 ),
//                 Text('Set as default card',
//                   style: GoogleFonts.montserrat(
//                     color: Colors.lightBlue,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800
//                   ),
//                 ),
//                 edit ? TextButton(
//                   onPressed: () {
//                     setState(() {
//                       edit = !edit;
//                     });
//                   }, 
//                   child: Text('Save',
//                     style: GoogleFonts.montserrat(
//                       color: Colors.green,
//                       fontWeight: FontWeight.w800
//                     ),
//                   ),
//                 )
//                 : Container(),
//               ],
//             ),
//             SizedBox(
//               height: height * 0.6,
//               width: width,
//               // TODO: no card available
//               // child: Center(
//               //   child: Text('No Cards Added',
//               //     style: GoogleFonts.montserrat(
//               //       fontSize: 22,
//               //       fontWeight: FontWeight.w700,
//               //     ),
//               //   ),
//               // ),
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: cardDetails.length,
//                 itemBuilder: (context, index) {
//                   return Row(
//                     children: <Widget>[
//                       edit ? Radio(
//                         value: cardDetails[index]['id'].toString(), 
//                         groupValue: chooseCard, 
//                         onChanged: (value) {
//                           setState(() {
//                             chooseCard = value.toString();
//                           });
//                         },
//                       )
//                       : Container(),
//                       if(edit == false) const Padding(
//                         padding: EdgeInsets.only(left: 30),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.only(bottom: 13),
//                         padding: const EdgeInsets.all(15),
//                         height: height * 0.25,
//                         width: width * 0.75,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(25),
//                           border: Border.all(
//                             color: Colors.grey
//                           ),
//                           gradient: cardDetails[index]['card_type'].toString() == 'Mastercard' ? LinearGradient(
//                             colors: [
//                               Colors.lightBlue.shade100,
//                               Colors.lightBlue,
//                               Colors.lightBlue.shade700,
//                             ],
//                           )
//                           : cardDetails[index]['card_type'].toString() == 'Visa' ? const LinearGradient(
//                             colors: [
//                               Colors.white10,
//                               Colors.white,
//                               Colors.white70,
//                             ],
//                           )
//                           : LinearGradient(
//                             colors: [
//                               Colors.red.shade100,
//                               Colors.red,
//                               Colors.red.shade700,
//                             ],
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Row(
//                               children: [
//                                 Text(cardDetails[index]['bank'].toString(),
//                                   style: GoogleFonts.montserrat(
//                                     color: const Color.fromRGBO(0, 0, 80, 1),
//                                     fontSize: 18,
//                                     fontStyle: FontStyle.italic,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 const Icon(
//                                   CupertinoIcons.dot_radiowaves_right,
//                                   color: Color.fromRGBO(0, 0, 80, 1),
//                                   size: 35,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                             Text(cardDetails[index]['card_number'].toString(),
//                               style: GoogleFonts.montserrat(
//                                 color: const Color.fromRGBO(0, 0, 80, 1),
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(cardDetails[index]['name'].toString().substring(0, 18),
//                                       style: GoogleFonts.montserrat(
//                                         color: const Color.fromRGBO(0, 0, 80, 1),
//                                         fontWeight: FontWeight.bold
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     Text(cardDetails[index]['exp_date'].toString(),
//                                       style: GoogleFonts.montserrat(
//                                         color: const Color.fromRGBO(0, 0, 80, 1),
//                                         fontWeight: FontWeight.bold
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       height: 40,
//                                       width: 45,
//                                       decoration: BoxDecoration(
//                                         image: DecorationImage(
//                                           image: AssetImage(
//                                             cardDetails[index]['logo'].toString()
//                                           )
//                                         ),
//                                       ),
//                                     ),
//                                     Text(cardDetails[index]['card_type'].toString(),
//                                       style: GoogleFonts.montserrat(
//                                         color: const Color.fromRGBO(0, 0, 80, 1),
//                                         fontWeight: FontWeight.w600
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       chooseCard == cardDetails[index]['id'].toString() ?  IconButton(
//                         padding: EdgeInsets.zero,
//                         onPressed: () {}, 
//                         icon: const Icon(
//                           CupertinoIcons.trash,
//                           color: Colors.red,
//                         ),
//                       )
//                       : Container(),
//                     ],
//                   );            
//                 }
//               )
//             ),
//             const Spacer(),
//             Container(
//               height: height * 0.18,
//               width: width,
//               decoration: const BoxDecoration(
//                 color: Color.fromRGBO(0, 0, 80, 1),
//                 borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(40)
//                 )
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   IconButton(
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(builder: (context) => const AddNewCard())
//                       );
//                     }, 
//                     icon: const Icon(
//                       CupertinoIcons.plus_app_fill,
//                       color: Colors.lightBlue,
//                       size: 40,
//                     ),
//                   ),
//                   Text('Add New Card',
//                     style: GoogleFonts.montserrat(
//                       color: Colors.lightBlue,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }