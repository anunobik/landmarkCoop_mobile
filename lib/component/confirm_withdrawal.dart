// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
//
// class ConfirmWithdrawal extends StatefulWidget {
//   final token;
//   final accountNumber;
//   final amount;
//
//   const ConfirmWithdrawal({required this.token,
//     required this.accountNumber,
//     required this.amount,});
//
//   @override
//   _ConfirmWithdrawalState createState() => _ConfirmWithdrawalState(token, accountNumber, amount);
// }
//
// class _ConfirmWithdrawalState extends State<ConfirmWithdrawal> {
//   _ConfirmWithdrawalState(
// this.token, this.accountNumber, this.amount);
//   final String token;
//   final String accountNumber;
//   final String amount;
//   bool isApiCallProcess = false;
//   final displayAmount = new NumberFormat("#,##0.00", "en_US");
//
//   @override
//   Widget build(BuildContext context) {
//     var _height = MediaQuery.of(context).size.height;
//     return Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.all(60.0),
//               height: _height * 0.3,
//               width: _height * 0.3,
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                       image: AssetImage('assets/Confirmed.png'),
//                       fit: BoxFit.contain)),
//             ),
//             Center(
//               child: Text(
//                 'Your Withdrawal of NGN' + displayAmount.format(double.parse(amount)) +' is been preocessed',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.montserrat(
//                     fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 5, top: 8),
//               child: Center(
//                 child: Text(
//                   'We will contact you shortly...',
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.montserrat(
//                       fontWeight: FontWeight.w400, fontSize: 17),
//                 ),
//               ),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.only(top: 20.0, bottom: 8),
//               child: TextButton(
//                 onPressed: () {
//                   //Todo get the current balance with the token
//                   APIService apiService = new APIService();
//                   apiService.getCustomerAccountBal(token).then((value) => {
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
