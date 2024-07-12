// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/services.dart';
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
import 'package:local_auth/local_auth.dart';
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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberPassword = false;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _getAvailableBiometrics();
    confirmToUseBiometric();
    requestAndRegisterNotifcation();
    loadSavedCredentials();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Check biometrics
  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  // Available Biometrics
  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
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
                        vertical: 60, horizontal: 20),
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
                            height: 100,
                            width: 150,
                            decoration: BoxDecoration(
                                image: const DecorationImage(
                                    image: AssetImage('assets/Logo.png'),
                                    fit: BoxFit.contain)),
                          ),
                          Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                                image: const DecorationImage(
                                    image: AssetImage('assets/landmark.png'),
                                    fit: BoxFit.contain)),
                          ),
                          Container(
                            height: 20,
                            width: 150,
                            decoration: BoxDecoration(
                                image: const DecorationImage(
                                    image: AssetImage('assets/coop.png'),
                                    fit: BoxFit.contain)),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: Text(
                              "Login",
                              // style: Theme.of(context).textTheme.headline2,
                              style: GoogleFonts.montserrat(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 40),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
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
                          CheckboxListTile(
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            title: Text("Remember Password",
                              style: GoogleFonts.montserrat(),
                            ),
                            value: rememberPassword,
                            onChanged: (value) {
                              setState(() {
                                rememberPassword = value!;
                              });
                            },
                          ),
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
                                APIService apiService = APIService();
                                apiService
                                    .login(loginRequestModel)
                                    .then((value) async {
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
                                    prefs.setString('username', emailController.text);
                                    print('Token at Login - ${value.token}');
                                    if (rememberPassword) {
                                      prefs.setString('password', passwordController.text);
                                    } else {
                                      prefs.remove('password');
                                    }

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
                              backgroundColor: Colors.blue,
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

  void loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');
    if (savedUsername != null && savedPassword != null) {
      setState(() {
        emailController.text = savedUsername;
        passwordController.text = savedPassword;
        rememberPassword = true;
      });
    } else if (savedUsername != null) {
      setState(() {
        emailController.text = savedUsername;
      });
    }
  }
}
