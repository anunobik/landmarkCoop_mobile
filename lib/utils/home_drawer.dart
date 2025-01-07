// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:landmarkcoop_mobile_app/pages/withdrawal_request.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../api/api_service.dart';
// import '../login.dart';
// import '../pages/customer_care.dart';
// import '../pages/dashboard.dart';
// import '../pages/investment.dart';
// import '../pages/setting.dart';
// import '../pages/transaction_history.dart';
// import '../registration.dart';

// // ignore: must_be_immutable
// class HomeDrawer extends StatefulWidget {
//   double value;
//   Widget page;
//   String name;
//   String fullName;
//   String token;
//   String subdomain;
//   HomeDrawer({
//     Key? key,
//     required this.value,
//     required this.page,
//     required this.name,
//     required this.fullName,
//     required this.token,
//     required this.subdomain,
//   }) : super(key: key);

//   @override
//   State<HomeDrawer> createState() => _HomeDrawerState();
// }

// class _HomeDrawerState extends State<HomeDrawer> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(children: <Widget>[
//         Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft,
//                 colors: [
//                   Colors.blue,
//                   Color(0xff000080),
//                   Color.fromRGBO(0, 0, 80, 1),
//                 ],
//                 stops: [
//                   0.1,
//                   0.5,
//                   1,
//                 ]),
//           ),
//         ),
//         SafeArea(
//           child: Container(
//             width: 200,
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: <Widget>[
//                 DrawerHeader(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       CircleAvatar(
//                         radius: 40.0,
//                         backgroundImage:
//                             NetworkImage('${widget.subdomain}/getBizLogo'),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         widget.fullName,
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.montserrat(
//                           color: Colors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView(
//                     children: <Widget>[
//                       ListTile(
//                         onTap: () async {
//                           final prefs = await SharedPreferences.getInstance();
//                           String subdomain = prefs.getString('subdomain') ??
//                               'https://core.landmarkcooperative.org';

//                           APIService apiService =
//                               APIService(subdomain_url: subdomain);
//                           setState(() {
//                             apiService.pageReload(widget.token).then((value) {
//                               widget.value = 0;
//                               widget.page = Dashboard(
//                                 token: widget.token,
//                                 fullName: widget.fullName,
//                                 customerWallets: value.customerWalletsList,
//                               );
//                               widget.name = 'wallet';
//                             });
//                           });
//                         },
//                         leading: Icon(
//                           Icons.account_balance_wallet,
//                           color: widget.name == 'wallet'
//                               ? Colors.white
//                               : Colors.white,
//                         ),
//                         title: Text(
//                           "Wallet",
//                           style: GoogleFonts.montserrat(
//                             color: widget.name == 'wallet'
//                                 ? Colors.white
//                                 : Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       ListTile(
//                         onTap: () {
//                           setState(() {
//                             widget.value = 0;
//                             widget.page = TransactionHistory(
//                               token: widget.token,
//                               fullName: widget.fullName,
//                             );
//                             widget.name = 'transactionHistory';
//                           });
//                         },
//                         leading: Icon(
//                           Icons.table_rows_rounded,
//                           color: widget.name == 'transactionHistory'
//                               ? Colors.white
//                               : Colors.white,
//                         ),
//                         title: Text(
//                           "Statement",
//                           style: GoogleFonts.montserrat(
//                             color: widget.name == 'transactionHistory'
//                                 ? Colors.white
//                                 : Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       ListTile(
//                         onTap: () async {
//                           final prefs = await SharedPreferences.getInstance();
//                           String subdomain = prefs.getString('subdomain') ??
//                               'https://core.landmarkcooperative.org';

//                           APIService apiService =
//                           APIService(subdomain_url: subdomain);
//                           setState(() {
//                             apiService.pageReload(widget.token).then((value) {
//                               widget.value = 0;
//                               // widget.page = WithdrawalRequest(
//                               //   token: widget.token,
//                               //   fullName: widget.fullName,
//                               //   customerWallets: value.customerWalletsList,
//                               // );
//                               widget.name = 'withdrawalRequest';
//                             });
//                           });
//                         },
//                         leading: Icon(
//                           Icons.outbox_rounded,
//                           color: widget.name == 'withdrawalRequest'
//                               ? Colors.white
//                               : Colors.white,
//                         ),
//                         title: Text(
//                           "Withdrawal",
//                           style: GoogleFonts.montserrat(
//                             color: widget.name == 'withdrawalRequest'
//                                 ? Colors.white
//                                 : Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       ListTile(
//                         onTap: () async {
//                           final prefs = await SharedPreferences.getInstance();
//                           String subdomain = prefs.getString('subdomain') ??
//                               'https://core.landmarkcooperative.org';

//                           APIService apiService =
//                           APIService(subdomain_url: subdomain);
//                           setState(() {
//                             apiService.getOnlineRate(widget.token).then((value) {
//                               widget.value = 0;
//                               widget.page = Investment(
//                                 token: widget.token,
//                                 interestRate: value,
//                                 fullName: widget.fullName,
//                               );
//                               widget.name = 'investment';
//                             });
//                           });
//                         },
//                         leading: Icon(
//                           Icons.inventory_2_sharp,
//                           color: widget.name == 'investment'
//                               ? Colors.white
//                               : Colors.white,
//                         ),
//                         title: Text(
//                           "Investment",
//                           style: GoogleFonts.montserrat(
//                             color: widget.name == 'investment'
//                                 ? Colors.white
//                                 : Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       ListTile(
//                         onTap: () {
//                           setState(() {
//                             widget.value = 0;
//                             widget.page = Setting(
//                               token: widget.token,
//                               fullName: widget.fullName,
//                             );
//                             widget.name = 'setting';
//                           });
//                         },
//                         leading: Icon(
//                           Icons.settings,
//                           color: widget.name == 'setting'
//                               ? Colors.white
//                               : Colors.white,
//                         ),
//                         title: Text(
//                           "Settings",
//                           style: GoogleFonts.montserrat(
//                             color: widget.name == 'setting'
//                                 ? Colors.white
//                                 : Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       ListTile(
//                         contentPadding: const EdgeInsets.only(left: 16.0),
//                         onTap: () async {
//                           final prefs = await SharedPreferences.getInstance();
//                           String subdomain = prefs.getString('subdomain') ??
//                               'https://core.landmarkcooperative.org';

//                           APIService apiService =
//                               APIService(subdomain_url: subdomain);
//                           setState(() {
//                             apiService.pageReload(widget.token).then((value) {
//                               widget.value = 0;
//                               widget.page = ContactCustomerSupport(
//                                 token: widget.token,
//                                 fullName: widget.fullName,
//                                 customerWallets: value.customerWalletsList,
//                               );
//                               widget.name = 'complaint';
//                             });
//                           });
//                         },
//                         leading: Icon(
//                           Icons.local_post_office_rounded,
//                           color: widget.name == 'complaint'
//                               ? Colors.white
//                               : Colors.white,
//                         ),
//                         title: Text(
//                           "Contact Center",
//                           style: GoogleFonts.montserrat(
//                             color: widget.name == 'complaint'
//                                 ? Colors.white
//                                 : Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 50,
//                       ),
//                       ListTile(
//                         onTap: () async {
//                           final prefs = await SharedPreferences.getInstance();
//                           String institution =
//                               prefs.getString('institution') ?? 'Minerva Hub';
//                           String subdomain = prefs.getString('subdomain') ??
//                               'https://core.landmarkcooperative.org';
//                           Navigator.popUntil(context, (route) => route.isFirst);
//                           Navigator.of(context).pushReplacement(MaterialPageRoute(
//                               builder: (context) => Registration(
//                                     institution: institution,
//                                     subdomain: subdomain,
//                                   )));
//                         },
//                         leading: const Icon(
//                           Icons.logout_outlined,
//                           color: Color(0xffd4af37),
//                         ),
//                         title: Text(
//                           "Logout",
//                           style: GoogleFonts.montserrat(
//                             color: Colors.red,
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         TweenAnimationBuilder(
//             tween: Tween<double>(begin: 0, end: widget.value),
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeIn,
//             builder: (context, double val, _) {
//               return Transform(
//                 alignment: Alignment.center,
//                 transform: Matrix4.identity()
//                   ..setEntry(3, 2, 0.001)
//                   ..setEntry(0, 3, 200 * val)
//                   ..rotateY((pi / 6) * val),
//                 child: GestureDetector(
//                   onHorizontalDragUpdate: (e) {
//                     if (e.delta.dx > 0) {
//                       setState(() {
//                         widget.value = 1;
//                       });
//                     } else {
//                       setState(() {
//                         widget.value = 0;
//                       });
//                     }
//                   },
//                   onTap: () {
//                     setState(() {
//                       widget.value = 0;
//                     });
//                   },
//                   child: widget.page,
//                 ),
//               );
//             }),
//       ]),
//     );
//   }
// }
