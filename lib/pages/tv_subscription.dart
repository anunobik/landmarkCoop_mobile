import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TVSubscription extends StatefulWidget {
  const TVSubscription({super.key});

  @override
  State<TVSubscription> createState() => _TVSubscriptionState();
}

class _TVSubscriptionState extends State<TVSubscription> {
  String subscription = 'DSTV';
  TextEditingController smartCardController = TextEditingController();
  String currentCableTV = '--Select--';
  List<String> cableTvList = ['--Select--', 'DSTV COMPACT'];


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        subscription = 'DSTV';
                      });
                    },
                    child: Container(
                      height: height * 0.08,
                      width: height * 0.08,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: subscription == 'DSTV' ? Colors.lightGreen.shade300
                            : Colors.grey.shade300,
                            offset: const Offset(
                              -1.0,
                              4.0,
                            ),
                            blurRadius: 5.0,
                            spreadRadius: 4.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          height: height * 0.0768,
                          width: height * 0.0768,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/pics/dstv.jpeg'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        subscription = 'GOtv';
                      });
                    },
                    child: Container(
                      height: height * 0.08,
                      width: height * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: subscription == 'GOtv' ? Colors.lightGreen.shade300
                            : Colors.grey.shade300,
                            offset: const Offset(
                              -1.0,
                              4.0,
                            ),
                            blurRadius: 5.0,
                            spreadRadius: 4.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          height: height * 0.0768,
                          width: height * 0.0768,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/pics/gotv.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        subscription = 'StarTimes';
                      });
                    },
                    child: Container(
                      height: height * 0.08,
                      width: height * 0.08,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: subscription == 'StarTimes' ? Colors.lightGreen.shade300
                            : Colors.grey.shade300,
                            offset: const Offset(0, 3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          height: height * 0.0768,
                          width: height * 0.0768,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/pics/startimes.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                '$subscription Subscription',
                style: GoogleFonts.openSans(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: smartCardController,
                decoration: InputDecoration(
                  hintText: 'Enter Smart Card Number',
                  hintStyle: GoogleFonts.montserrat(
                    color: const Color(0xff9ca2ac),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text('Take code remaining from my wallet shop',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}