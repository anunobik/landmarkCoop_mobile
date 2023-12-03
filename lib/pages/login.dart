// ignore_for_file: library_private_types_in_public_api

import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/main.dart';
import 'package:landmarkcoop_mobile_app/model/login_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/pages/dashboard.dart';
import 'package:landmarkcoop_mobile_app/pages/face_id_finger_print.dart';
import 'package:landmarkcoop_mobile_app/pages/forgot_password.dart';
import 'package:landmarkcoop_mobile_app/util/ProgressHUD.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText = true;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  LoginRequestModel loginRequestModel = LoginRequestModel();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isApiCallProcess = false;
  String? token;
  bool useFingerPrint = false;
  late final FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    confirmToUseBiometric();
    requestAndRegisterNotifcation();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> confirmToUseBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    useFingerPrint = prefs.getBool('useFingerPrint')!;
  }

  void requestAndRegisterNotifcation() async {
    await Firebase.initializeApp();

    messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      token = await messaging.getToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  // Container(
                  //   margin: const EdgeInsets.only(top: 50),
                  //   child: Center(
                  //     child: Text(
                  //       "Login",
                  //       // style: Theme.of(context).textTheme.headline2,
                  //       style: GoogleFonts.montserrat(
                  //           fontSize: 32,
                  //           fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    margin: const EdgeInsets.symmetric(
                        vertical: 60, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).hintColor.withOpacity(0.2),
                            offset: const Offset(0, 10),
                            blurRadius: 50)
                      ],
                    ),
                    child: Form(
                      key: globalFormKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                                image: const DecorationImage(
                                    image: AssetImage('assets/landmark.jpg'),
                                    fit: BoxFit.contain)),
                          ),
                          Center(
                            child: Text(
                              "Login",
                              // style: Theme.of(context).textTheme.headline2,
                              style: GoogleFonts.montserrat(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 40),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (input) =>
                                loginRequestModel.email = input!,
                            validator: (input) => input!.isEmpty
                                ? "Please enter email or phone no."
                                : null,
                            decoration: InputDecoration(
                              hintText: "Email / Phone No.",
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue.withOpacity(0.2))),
                              focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            onSaved: (input) =>
                                loginRequestModel.password = input!,
                            validator: (input) => input!.length < 3
                                ? "Password should be more than 3 characters"
                                : null,
                            obscureText: _obscureText,
                            obscuringCharacter: '*',
                            decoration: InputDecoration(
                              hintText: "Password",
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue.withOpacity(0.2))),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.black45,
                              ),
                              hintStyle:
                                  GoogleFonts.montserrat(color: Colors.black38),
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black45,
                                  ),
                                  onPressed: _toggle),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPassword())),
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.montserrat(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w400),
                                    ))
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              if (validateAndSave()) {
                                setState(() {
                                  isApiCallProcess = true;
                                });
                                print('We are here!');
                                APIService apiService = APIService();
                                apiService
                                    .login(loginRequestModel)
                                    .then((value) async {
                                  print('We are inside here!');
                                  setState(() {
                                    isApiCallProcess = false;
                                  });

                                  if (value.customerWalletsList.isNotEmpty) {
                                    //Todo add token to database or modify
                                    APIService apiServiceDeviceToken =
                                        APIService();
                                    print("token - $token");
                                    PushDeviceTokenRequestModel
                                        pushDeviceTokenRequestModel =
                                        PushDeviceTokenRequestModel(
                                            deviceToken: token);
                                    apiServiceDeviceToken.addDeviceToken(
                                        pushDeviceTokenRequestModel,
                                        value.token);

                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool('useFingerPrint', true);
                                    await prefs.setString(
                                        'biometricToken', value.token);
                                    print('Token at Login - ${value.token}');

                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => HomeDrawer(
                                          value: 0,
                                          page: Dashboard(
                                            token: value.token,
                                            fullName: value
                                                .customerWalletsList[0]
                                                .fullName,
                                            customerWallets:
                                                value.customerWalletsList,
                                            lastTransactions:
                                                value.lastTransactionsList,
                                          ),
                                          name: 'wallet',
                                          fullName: value
                                              .customerWalletsList[0].fullName,
                                          token: value.token,
                                          customerWallets:
                                              value.customerWalletsList,
                                          lastTransactionsList:
                                              value.lastTransactionsList,
                                        ),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Message"),
                                            content: Text(value.token),
                                          );
                                        });
                                  }
                                }).catchError((errorMsg) {
                                  AlertDialog(
                                    title: const Text(
                                      "Message",
                                      textAlign: TextAlign.center,
                                    ),
                                    // titlePadding: EdgeInsets.all(5.0),
                                    content: Text(
                                      errorMsg.toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                    // contentPadding: EdgeInsets.all(5.0),
                                  );
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Text(
                                "Login",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          useFingerPrint
                              ? SizedBox(
                                  child: Column(
                                    children: [
                                      Text(
                                        '-- Or Sign In Using --',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          color: const Color(0XFF091841),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const FaceIDFingerPrint()));
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            const Icon(
                                              CupertinoIcons.camera_viewfinder,
                                              color: Colors.blue,
                                            ),
                                            const Icon(
                                              Icons.fingerprint,
                                              color: Colors.blue,
                                            ),
                                            Text(
                                              'Face ID or Finger Print',
                                              style: GoogleFonts.montserrat(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
