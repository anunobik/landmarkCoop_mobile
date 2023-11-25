import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import 'forgot_password.dart';

class CheckMail extends StatefulWidget {
  const CheckMail({ Key? key }) : super(key: key);

  @override
  _CheckMailState createState() => _CheckMailState();
}

class _CheckMailState extends State<CheckMail> {
  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: _height * 0.2, bottom: 20.0),
              child: Container(
                height: _width / 3,
                width: _width / 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200
                ),
                child: Center(
                  child: Icon(
                    Icons.email,
                    size: 80, color: Colors.blue,
                  ),
                ),
              ),
            ),
            Center(
              child: Text('Check your email',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 28),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text('We have sent a default password to your email',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w400, fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 12),
              child: TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage())
                ), 
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  child: Text('Back to home',
                  style:  GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  )
                ),
              ),
            ),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Did not receive the email? Check your spam folder, or ',
                      style: GoogleFonts.montserrat(color: Colors.black)
                    ),
                    TextSpan(
                      text: 'try another email address',
                      style: GoogleFonts.montserrat(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => ForgotPassword())
                        )
                      )
                    ]
                  )
                ),
              ),
          ],
        ),
      ),
    );
  }
}