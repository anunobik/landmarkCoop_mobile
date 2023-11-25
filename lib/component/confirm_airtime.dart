// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class ConfirmAirtime extends StatefulWidget {
//   final token;
//   final accountNumber;
//   final cAmount;
//   final network;
//   final pNumber;
//
//   const ConfirmAirtime({
//     required this.token,
//     required this.accountNumber,
//     required this.cAmount,
//     required this.network,
//     required this.pNumber,
//   });
//
//   @override
//   ConfirmAirtimeState createState() =>
//       ConfirmAirtimeState(token, accountNumber, cAmount, network, pNumber);
// }
//
// class ConfirmAirtimeState extends State<ConfirmAirtime> {
//   ConfirmAirtimeState(
//       this.token, this.accountNumber, this.cAmount, this.network, this.pNumber);
//
//   final String token;
//   final String accountNumber;
//   final String cAmount;
//   final String network;
//   final String pNumber;
//   bool isApiCallProcess = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return ProgressHUD(
//       child: _uiSetup(context),
//       inAsyncCall: isApiCallProcess,
//       opacity: 0.3,
//     );
//   }
//
//   Widget _uiSetup(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     return Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.fromLTRB(20, 60, 20, 20),
//               height: height * 0.3,
//               width: height * 0.3,
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                       image: AssetImage('assets/Order_confirmed.png'),
//                       fit: BoxFit.contain)),
//             ),
//             Center(
//               child: Text(
//                 'Airtime Purchase',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.montserrat(
//                     fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 5, top: 8),
//               child: Center(
//                 child: Text(
//                   'Thank you for your airtime purchase. The phone number ' +
//                       widget.pNumber +
//                       ' has been credited with NGN' +
//                       widget.cAmount +
//                       ' ' +
//                       widget.network,
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.montserrat(
//                       fontWeight: FontWeight.w400, fontSize: 17),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 20.0, bottom: 8),
//               child: TextButton(
//                 onPressed: () {
//                   setState(() {
//                     isApiCallProcess = true;
//                   });
//                   //Todo get the current balance with the token
//                   APIService apiService = new APIService();
//                   apiService.getCustomerAccountBal(token).then((value) => {
//                         setState(() {
//                           isApiCallProcess = false;
//                         }),
//
//                         Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => Overview(
//                                     email: value.email,
//                                     token: value.token,
//                                     accountNumber: value.accountNumber,
//                                     accountName: value.accountName,
//                                     balance: value.balance)))
//                       });
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 80, vertical: 12),
//                   child: Text(
//                     'Back to home',
//                     style: GoogleFonts.montserrat(
//                         color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 style: ButtonStyle(
//                     foregroundColor: MaterialStateProperty.all<Color>(
//                         Colors.lightGreenAccent.shade700),
//                     backgroundColor: MaterialStateProperty.all<Color>(
//                         Colors.lightGreenAccent.shade700),
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15)))),
//               ),
//             ),
//           ],
//         ));
//   }
// }
