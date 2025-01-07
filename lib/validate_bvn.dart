import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ValidateBVN extends StatefulWidget {
  const ValidateBVN({super.key});

  @override
  State<ValidateBVN> createState() => _ValidateBVNState();
}

class _ValidateBVNState extends State<ValidateBVN> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController bvnController = TextEditingController();
  bool isSuccess = true;
  bool isApiCallProcess = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Text('BVN Validation',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xff000080),
                    fontSize: 28,
                    fontWeight: FontWeight.w800
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: bvnController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Enter BVN',
                          hintStyle: GoogleFonts.montserrat(
                            color: const Color(0xff9ca2ac),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.7),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 0.7,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      isSuccess & isApiCallProcess ? 
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: Lottie.asset('assets/LottieAssets/96245-success.zip'),
                      )
                      : !isSuccess & isApiCallProcess ? 
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: Lottie.asset('assets/LottieAssets/failed.zip'),
                      )
                      : ElevatedButton(
                        onPressed: () {
                          // setState(() {
                          //   isApiCallProcess = true;
                          //   isSuccess = true;
                          // });
                          if (bvnController.text.isEmpty) {
                            Future.delayed(
                              const Duration(seconds: 2), () async{
                                setState(() {
                                  isSuccess = false;
                                  isApiCallProcess = true;
                                });
                              }
                            );
                            Future.delayed(
                              const Duration(seconds: 4), () async{
                                Fluttertoast.showToast(msg: 'BVN cannot be empty');
                              }
                            );
                            Future.delayed(
                              const Duration(seconds: 7), () async{
                                setState(() {
                                  isApiCallProcess = false;
                                });
                              }
                            );
                          } else if (bvnController.text.length < 11) {
                            Future.delayed(
                              const Duration(seconds: 2), () async{
                                setState(() {
                                  isSuccess = false;
                                  isApiCallProcess = true;
                                });
                              }
                            );
                            Future.delayed(
                              const Duration(seconds: 4), () async{
                                Fluttertoast.showToast(msg: 'Invalid BVN');
                              }
                            );
                            Future.delayed(
                              const Duration(seconds: 7), () async{
                                setState(() {
                                  isApiCallProcess = false;
                                });
                              }
                            );
                          }
                          // Validate name on bvn
                          // else if (bvnController.text != 'Anana Jackson Anana') {
                            // Future.delayed(
                            //   const Duration(seconds: 2), () async{
                            //     setState(() {
                            //       isSuccess = false;
                            //       isApiCallProcess = true;
                            //     });
                            //   }
                            // );
                            // Future.delayed(
                            //   const Duration(seconds: 4), () async{
                            //     Fluttertoast.showToast(msg: 'Your name does not match with the name on the BVN');
                            //   }
                            // );
                            // Future.delayed(
                            //   const Duration(seconds: 7), () async{
                            //     setState(() {
                            //       isApiCallProcess = false;
                            //     });
                            //   }
                            // );
                          // } 
                          else {}
                          setState(() {
                            isApiCallProcess = true;
                            isSuccess = true;
                          });
                          Future.delayed(
                            const Duration(seconds: 4), () async{
                              // Navigate to nextpage
                            }
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 15),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}