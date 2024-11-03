import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/pages/login.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Congrats extends StatefulWidget {
  final String response;

  const Congrats(
      {super.key,
        required this.response});

  @override
  State<Congrats> createState() => _CongratsState();
}

class _CongratsState extends State<Congrats> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
        child: Column(
          children: <Widget>[
            Container(
              height: height * 0.35,
              width: width * 0.6,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/congrats.jpg'),
                        fit: BoxFit.contain)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(8)),
              child: Text(widget.response,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();

                  String institution =  prefs.getString('institution') ?? 'institution';
                  String subdomain = prefs.getString('subdomain') ?? 'subdomain';
                  print('This is the institution $institution');
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Login())
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffd4af37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Ok",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
