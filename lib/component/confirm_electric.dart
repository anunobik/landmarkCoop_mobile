// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class ConfirmElectric extends StatefulWidget {
//   final email;
//   final token;
//   final accountNumber;
//   final accountName;
//   final balance;
//   final buypowerToken;
//
//   const ConfirmElectric(
//       {Key? key,
//       required this.email,
//       required this.token,
//       required this.accountNumber,
//       required this.accountName,
//       required this.balance,
//       required this.buypowerToken})
//       : super(key: key);
//
//   @override
//   ConfirmElectricState createState() => ConfirmElectricState(email, token, accountNumber, accountName, balance, buypowerToken);
// }
//
// class ConfirmElectricState extends State<ConfirmElectric> {
//   ConfirmElectricState(
//       this.email, this.token, this.accountNumber, this.accountName, this.balance, this.buypowerToken);
//   final String email;
//   final String token;
//   final String accountNumber;
//   final String accountName;
//   final String balance;
//   final String buypowerToken;
//
//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     return Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.all(60.0),
//               height: height * 0.3,
//               width: height * 0.3,
//               decoration: BoxDecoration(
//                   image: DecorationImage(
//                       image: AssetImage('assets/Confirmed.png'),
//                       fit: BoxFit.contain)),
//             ),
//             Center(
//               child: Text(
//                 'Successful',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.montserrat(
//                     fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 5, top: 8),
//               child: Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       'Generated token',
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.montserrat(
//                           fontWeight: FontWeight.w400, fontSize: 17),
//                     ),
//                     Text(
//                       buypowerToken,
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.montserrat(
//                           fontWeight: FontWeight.bold, fontSize: 20),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
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
