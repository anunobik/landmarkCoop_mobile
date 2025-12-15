import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:landmarkcoop_latest/pages/sing_up_screen_2.dart';

import '../main_view.dart';

class SingUpScreen extends StatefulWidget {
  const SingUpScreen({super.key, required this.controller});
  final PageController controller;
  @override
  State<SingUpScreen> createState() => _SingUpScreenState();
}

class _SingUpScreenState extends State<SingUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Image.asset(
                "assets/images/female-happy.jpeg",
                width: width,
                height: height * 0.5,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: formKey,
                child: Column(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xff000080),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: firstNameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF393939),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        labelStyle: TextStyle(
                          color: Color(0xff000080),
                          fontSize: 15,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w600,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF837E93),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: middleNameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF393939),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Middle Name',
                        labelStyle: TextStyle(
                          color: Color(0xff000080),
                          fontSize: 15,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w600,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF837E93),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: lastNameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF393939),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        labelStyle: TextStyle(
                          color: Color(0xff000080),
                          fontSize: 15,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w600,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF837E93),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                        width: 329,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (firstNameController.text.isEmpty) {
                              Fluttertoast.showToast(msg: 'First Name cannot be empty');
                            } else if (lastNameController.text.isEmpty) {
                              Fluttertoast.showToast(msg: 'Last Name cannot be empty');
                            } else {
                              String firstName = firstNameController.text;
                              String middleName = middleNameController.text;
                              String lastName = lastNameController.text;

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SingUpScreen2(
                                    fName: firstName,
                                    sName: lastName,
                                    mName: middleName,
                                  )));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text(
                          ' have an account?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF837E93),
                            fontSize: 13,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          width: 2.5,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MainView()));
                          },
                          child: const Text(
                            'Log In ',
                            style: TextStyle(
                              color: Color(0xff000080),
                              fontSize: 15,
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
