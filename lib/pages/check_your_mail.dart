import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/pages/forgot_password.dart';
import 'package:landmarkcoop_mobile_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckMail extends StatefulWidget {
  const CheckMail({Key? key}) : super(key: key);

  @override
  State<CheckMail> createState() => _CheckMailState();
}

class _CheckMailState extends State<CheckMail> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: height * 0.2, bottom: 20.0),
              child: Container(
                height: width / 3,
                width: width / 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200),
                child: const Center(
                  child: Icon(
                    Icons.email,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                'Check your email',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, fontSize: 28),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'We have sent a default password to your email',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w400, fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 12),
              child: TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  String institution =
                      prefs.getString('institution') ?? 'Minerva Hub';
                  String subdomain = prefs.getString('subdomain') ??
                      'https://core.landmarkcooperative.org';

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Login()));
                },
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  child: Text(
                    'Back to home',
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Center(
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                        text:
                            'Did not receive the email? Check your spam folder, or ',
                        style: GoogleFonts.montserrat(color: Colors.black)),
                    TextSpan(
                        text: 'try another email address',
                        style: GoogleFonts.montserrat(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final prefs = await SharedPreferences.getInstance();
                            String subdomain = prefs.getString('subdomain') ??
                                'https://core.landmarkcooperative.org';
                            String institution =
                                prefs.getString('institution') ?? 'Minerva Hub';
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => ForgotPassword(),
                            ));
                          })
                  ])),
            ),
          ],
        ),
      ),
    );
  }
}
