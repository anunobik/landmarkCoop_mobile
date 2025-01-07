// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../login.dart';
// import '../registration.dart';


// class NewPassword extends StatefulWidget {
//   const NewPassword({ Key? key }) : super(key: key);

//   @override
//   _NewPasswordState createState() => _NewPasswordState();
// }

// class _NewPasswordState extends State<NewPassword> {
//   TextEditingController defaultPassController = TextEditingController();
//   TextEditingController newPassController = TextEditingController();
//   TextEditingController confirmPassController = TextEditingController();
//   String? defaultPassword;
//   String? newPassword;
//   String? confirmtPassword;
//   bool _obscure = true;
//   bool _obscure1 = true;
//   bool _obscure2 = true;

//   void _visible() {
//     setState(() {
//       _obscure = !_obscure;
//     });
//   }
//   void _visible1() {
//     setState(() {
//       _obscure1 = !_obscure1;
//     });
//   }
//   void _visible2() {
//     setState(() {
//       _obscure2 = !_obscure2;
//     });
//   }

//   @override
//     void dispose() {
//       defaultPassController.dispose();
//       newPassController.dispose();
//       confirmPassController.dispose();
//       super.dispose();
//     }
//   @override
//   Widget build(BuildContext context) {
//     var _height = MediaQuery.of(context).size.height;
//     var _width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: IconThemeData(
//           color: Colors.black
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(left: 20.0, right: 20.0),
//         child: ListView(
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.only(top: 40, bottom: 20.0),
//               child: Text('Create New Password',
//               style: GoogleFonts.montserrat(
//                 fontSize: 32, fontWeight: FontWeight.bold, color: Colors.lightGreen.shade500
//               )
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 25.0),
//               child: Text('Your new password must be different from previously used passwords.',
//               style: GoogleFonts.montserrat(color: Colors.lightGreen.shade500, fontSize: 18, fontWeight: FontWeight.w400)
//               ),
//             ),
//             Container(
//               height: _height * 0.50,
//               width: _width * 0.9,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(25.0),
//                 color: Colors.lightGreen.shade500
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: defaultPassController,
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       obscureText: _obscure,
//                       obscuringCharacter: 'x',
//                       maxLength: 6,
//                       decoration: InputDecoration(
//                         icon: Icon(
//                           Icons.lock,
//                           color: Colors.white
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscure ? Icons.visibility_off
//                             : Icons.visibility,
//                             color: Colors.white
//                           ),
//                           onPressed: _visible,
//                         ),
//                         hintText: 'Enter Default Password',
//                         hintStyle: GoogleFonts.montserrat(color: Colors.black38),
//                         focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.white)
//                         ) 
//                       ),
//                       onChanged: (text) {
//                         setState(() {
//                           defaultPassword = defaultPassController.text;
//                         });
//                       },
//                     ),
//                     TextField(
//                       controller: newPassController,
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       obscureText: _obscure1,
//                       obscuringCharacter: 'x',
//                       maxLength: 6,
//                       decoration: InputDecoration(
//                         icon: Icon(
//                           Icons.lock,
//                           color: Colors.white
//                         ),
//                         hintText: 'New password',
//                         hintStyle: GoogleFonts.montserrat(color: Colors.black38),
//                         helperText: 'Must be 6 digits',
//                         helperStyle: GoogleFonts.montserrat(color: Colors.black38),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscure1 ? Icons.visibility_off
//                             : Icons.visibility,
//                             color: Colors.white
//                           ),
//                           onPressed: _visible1,
//                         ),
//                         focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.white)
//                         ) 
//                       ),
//                       onChanged: (text) {
//                         setState(() {
//                           newPassword = newPassController.text;
//                         });
//                       },
//                     ),
//                     TextField(
//                       controller: confirmPassController,
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       obscureText: _obscure2,
//                       obscuringCharacter: 'x',
//                       maxLength: 6,
//                       decoration: InputDecoration(
//                         icon: Icon(
//                           Icons.lock,
//                           color: Colors.white
//                         ),
//                         hintText: 'Confirm password',
//                         hintStyle: GoogleFonts.montserrat(color: Colors.black38),
//                         helperText: 'Must match with new password entered',
//                         helperStyle: GoogleFonts.montserrat(color: Colors.black38),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscure2 ? Icons.visibility_off
//                             : Icons.visibility,
//                             color: Colors.white
//                           ),
//                           onPressed: _visible2,
//                         ),
//                         focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(color: Colors.white)
//                         ) 
//                       ),
//                       onChanged: (text) {
//                         setState(() {
//                           confirmtPassword = confirmPassController.text;
//                         });
//                       },
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left:20, right: 20, bottom: 10, top: 10),
//                       child: TextButton(
//                         onPressed: () async{
//                           final prefs = await SharedPreferences.getInstance();

//                           String institution =  prefs.getString('institution') ?? 'Minerva Hub';
//                           String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

//                           Navigator.of(context).push(
//                               MaterialPageRoute(builder: (context) => Registration(
//                                 institution: institution,
//                                 subdomain: subdomain,
//                               ))
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
//                           child: Text('Reset Password',
//                           style:  GoogleFonts.montserrat(color: Colors.lightGreen.shade500, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         style: ButtonStyle(
//                           foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//                           backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
//                           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                             RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
//                           )
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }