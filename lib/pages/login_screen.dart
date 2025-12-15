import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/api/api_service.dart';
import 'package:landmarkcoop_latest/entry_point.dart';
import 'package:landmarkcoop_latest/main.dart';
import 'package:landmarkcoop_latest/model/login_model.dart';
import 'package:landmarkcoop_latest/model/other_model.dart';
import 'package:landmarkcoop_latest/model/push_notification.dart';
import 'package:landmarkcoop_latest/pages/registration/forgot_password.dart';
import 'package:landmarkcoop_latest/utils/notification_badge.dart';
import 'package:landmarkcoop_latest/widgets/bottom_nav_bar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final PageController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool inItialized = false;
  bool _obscure = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isApiCallProcess = false;
  LoginRequestModel loginRequestModel = LoginRequestModel();
  late final FirebaseMessaging messaging;
  String? token;
  bool isBiometricDialogShown = false;
  bool rememberPassword = false;
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  bool useFingerPrint = false;
  late int totalNotifications;
  PushNotification? notificationInfo;
  List notificationList = [];

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _obscureView() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  void requestAndRegisterNotifcation() async {
    // await Firebase.initializeApp();
    //
    // messaging = FirebaseMessaging.instance;
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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

  Future<void> confirmToUseBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    useFingerPrint = prefs.getBool('useFingerPrint')!;
  }

  @override
  void initState() {
    requestAndRegisterNotifcation();
    auth.isDeviceSupported().then(
          (bool isSupported) =>
          setState(() =>
          _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
    );
    _checkBiometrics();
    _getAvailableBiometrics();
    confirmToUseBiometric();
    loadSavedCredentials();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if (mounted) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'notificationTitle', message.notification!.title.toString());
        await prefs.setString(
            'notificationBody', message.notification!.body.toString());
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });
        if (notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(notificationInfo!.title!,
              style: GoogleFonts.montserrat(),
            ),
            leading: NotificationBadge(totalNotifications: totalNotifications),
            subtitle: Text(notificationInfo!.body!,
              style: GoogleFonts.montserrat(),
            ),
            background: Color(0xff000080).withOpacity(0.7),
            duration: const Duration(seconds: 2),
          );
        }
        pushNotify();
      }
    });

    // Open to notification screen
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'notificationTitle', message.notification!.title.toString());
        await prefs.setString(
            'notificationBody', message.notification!.body.toString());
        String subdomain = prefs.getString('subdomain') ??
            'core.landmarkcooperative.org';
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });

        // API Sign in token
        APIService apiService = APIService(subdomain_url: subdomain);
        apiService.login(loginRequestModel).then((value) {
          if (value.customerWalletsList.isNotEmpty) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) =>
                    EntryPoint(
                      customerWallets: value.customerWalletsList,
                      fullName: value.customerWalletsList[0].fullName,
                      screenName: 'Notification',
                      subdomain: subdomain,
                      token: value.token,
                      referralId: value.customerWalletsList[0].phoneNo,))
            );
            notificationList.add({
              'title': message.notification!.title,
              'body': message.notification!.body,
            });
          }
        });
      }
    }
    );
    totalNotifications = 0;
    pushNotify();
    super.initState();
  }

  void pushNotify() async {
    final prefs = await SharedPreferences.getInstance();
    String notificationTitle = prefs.getString('notificationTitle') ?? '';
    String notificationBody = prefs.getString('notificationBody') ?? '';
    print('Body - $notificationBody');
    if (notificationTitle != '') {
      setState(() {
        notificationList.add({
          'title': notificationTitle,
          'body': notificationBody,
        });
      });
    }
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

  // Cancel Authentication
  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  Route _routeToSignInScreen(Widget newScreen) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => newScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(-1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      backgroundColor: Colors.white70,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                "assets/images/guy-listen.jpeg",
                width: width,
                height: height * 0.5,
              ),
            ),
            // const SizedBox(
            //   height: 5,
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: formKey,
                child: Column(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log In',
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
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      textAlign: TextAlign.center,
                      onSaved: (input) => loginRequestModel.email = input!,
                      validator: (input) =>
                      input!.isEmpty
                          ? "Please enter email or phone no."
                          : null,
                      style: const TextStyle(
                        color: Color(0xFF393939),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Email / Phone No.',
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
                      height: 15,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                      textAlign: TextAlign.center,
                      onSaved: (input) => loginRequestModel.password = input!,
                      validator: (input) =>
                      input!.isEmpty ? "Password is empty" : null,
                      obscureText: _obscure,
                      obscuringCharacter: '*',
                      style: const TextStyle(
                        color: Color(0xFF393939),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                        suffixIcon: IconButton(
                          onPressed: _obscureView,
                          icon: Icon(_obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          color:
                          _obscure ? const Color(0xff9ca2ac) : Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      title: Text("Remember Password",
                        style: TextStyle(
                          fontFamily: 'Mulish',
                        ),
                      ),
                      value: rememberPassword,
                      onChanged: (value) {
                        setState(() {
                          rememberPassword = value!;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    isApiCallProcess
                        ? ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                        width: 329,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Working...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                        : ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                        width: 329,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (validateAndSave()) {
                              setState(() {
                                isApiCallProcess = true;
                              });
                              final prefs =
                              await SharedPreferences.getInstance();
                              String subdomain =
                                  prefs.getString('subdomain') ??
                                      'core.landmarkcooperative.org';
                              await prefs.setBool('atLoginPage', true);

                              APIService apiService =
                              APIService(subdomain_url: subdomain);
                              apiService
                                  .login(loginRequestModel)
                                  .then((value) async {
                                setState(() {
                                  isApiCallProcess = false;
                                });
                                if (value.customerWalletsList.isNotEmpty) {
                                  //Todo add token to database or modify
                                  APIService apiServiceDeviceToken =
                                  APIService(subdomain_url: subdomain);
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
                                  prefs.setString(
                                      'username', emailController.text);

                                  print('Token at Login - ${value.token}');

                                  if (rememberPassword) {
                                    prefs.setString(
                                        'password', passwordController.text);
                                  } else {
                                    prefs.remove('password');
                                  }
                                  Navigator.of(context).push(_routeToSignInScreen(
                                      BottomNavBar(pageIndex: 0,
                                        fullName: value.customerWalletsList[0].fullName,
                                        token: value.token,
                                        subdomain: subdomain,
                                        customerWallets: value.customerWalletsList,
                                        phoneNumber: value.customerWalletsList[0]
                                            .phoneNo,)));
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
                            backgroundColor: Color.fromRGBO(49, 88, 203, 1.0),
                          ),
                          child: const Text(
                            'Sign In',
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
                    const SizedBox(height: 10),
                    useFingerPrint
                        ? Container(
                      child: Column(
                        children: [
                          // Text(
                          //   '-- Or Sign In Using --',
                          //   textAlign: TextAlign.center,
                          //   style: GoogleFonts.montserrat(
                          //     color: Color(0xff000080),
                          //     fontSize: 15,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Future.delayed(
                                  const Duration(milliseconds: 800), () {
                                setState(() {
                                  isBiometricDialogShown = true;
                                });
                                faceIDFingerPrint(
                                  context,
                                  onClosed: (context) {
                                    setState(() {
                                      isBiometricDialogShown = false;
                                    });
                                  },
                                );
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don’t have an account?',
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
                            widget.controller.animateToPage(1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xff000080),
                              fontSize: 13,
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          final prefs =
                          await SharedPreferences.getInstance();
                          String subdomain = prefs.getString('subdomain') ??
                              'https://core.landmarkcooperative.org';
                          String institution =
                              prefs.getString('institution') ??
                                  'Minerva Hub';

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ForgotPassword(
                                    institution: institution,
                                    subdomain: subdomain,
                                  ),
                            ),
                          );
                        },
                        child: const Text(
                          'Forget Password?',
                          style: TextStyle(
                            color: Color(0xff000080),
                            fontSize: 13,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
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

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<Object?> faceIDFingerPrint(BuildContext context, {
    required ValueChanged onClosed,
  }) {
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: 'Face ID / Finger Print',
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, __, child) {
        Tween<Offset> tween;
        tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
        return SlideTransition(
          position: tween.animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
      },
      context: context,
      pageBuilder: (context, _, __) =>
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                // Authenticate Biometrics
                Future<void> _authenticateWithBiometrics() async {
                  bool authenticated = false;
                  try {
                    setState(() {
                      _isAuthenticating = true;
                      _authorized = 'Authenticating';
                    });
                    authenticated = await auth.authenticate(
                      localizedReason: 'Scan to authenticate',
                      options: const AuthenticationOptions(
                        stickyAuth: true,
                        biometricOnly: true,
                      ),
                    );
                    setState(() {
                      _isAuthenticating = false;
                      _authorized = 'Authenticating';
                    });
                  } on PlatformException catch (e) {
                    print(e);
                    setState(() {
                      _isAuthenticating = false;
                      _authorized = 'Error - ${e.message}';
                    });
                    return;
                  }
                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    _isAuthenticating = true;
                  });

                  final String message =
                  authenticated ? 'Authorized' : 'Not Authorized';
                  setState(() {
                    _authorized = message;
                  });
                  print('This is the report - $_authorized');

                  // Navigate to home page
                  if (_authorized == 'Authorized') {
                    final prefs = await SharedPreferences.getInstance();
                    String subdomain =
                        prefs.getString('subdomain') ?? 'core.landmarkcooperative.org';
                    String? biometricToken = prefs.getString('biometricToken');
                    print(biometricToken);

                    APIService apiService = APIService(
                        subdomain_url: subdomain);
                    apiService.biometricLogin(biometricToken!).then((
                        value) async {
                      setState(() {
                        isApiCallProcess = false;
                        _isAuthenticating = false;
                      });
                      if (value.customerWalletsList.isNotEmpty) {
                        await prefs.setString('biometricToken', value.token);
                        //Todo add token to database or modify
                        APIService apiServiceDeviceToken =
                        APIService(subdomain_url: subdomain);
                        print("token - $token");
                        PushDeviceTokenRequestModel pushDeviceTokenRequestModel =
                        PushDeviceTokenRequestModel(deviceToken: token);
                        apiServiceDeviceToken.addDeviceToken(
                            pushDeviceTokenRequestModel, value.token);

                        Navigator.of(context).push(_routeToSignInScreen(
                            BottomNavBar(pageIndex: 0,
                                fullName: value.customerWalletsList[0].fullName,
                                token: value.token,
                                subdomain: subdomain,
                                customerWallets: value.customerWalletsList,
                                phoneNumber: value.customerWalletsList[0]
                                    .phoneNo,)));
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
                }

                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 50),
                    height: 620,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 150,
                                child: Lottie.asset(
                                    'assets/LottieAssets/face-unlock.zip'),
                              ),
                              Text('Face ID / Finger Print Sign In',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xff000080),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(height: 12),
                              if (_supportState == _SupportState.unknown)
                                const CircularProgressIndicator()
                              else
                                if (_supportState == _SupportState.supported)
                                  Text(
                                    'This device is supported',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      color: const Color(0xff000080),
                                    ),
                                  )
                                else
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        CupertinoIcons
                                            .exclamationmark_triangle_fill,
                                        color: Colors.red,
                                      ),
                                      Text(
                                        'This device is not supported',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                              // const SizedBox(height: 20),
                              // Text('Can check biometrics: $_canCheckBiometrics\n',
                              //   style: GoogleFonts.montserrat(
                              //     color: const Color(0xff000080),
                              //   ),
                              // ),
                              // const SizedBox(height: 20),
                              // Text('Available biometrics: $_availableBiometrics\n',
                              //   style: GoogleFonts.montserrat(
                              //     color: const Color(0xff000080),
                              //   ),
                              // ),
                              // const SizedBox(height: 20),
                              // Text('Current State: $_authorized\n',
                              //   style: GoogleFonts.montserrat(
                              //     color: const Color(0xff000080),
                              //   ),
                              // ),
                              const SizedBox(height: 60),
                              if (_isAuthenticating)
                                ElevatedButton(
                                  onPressed: _cancelAuthentication,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              15))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Working...',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800),
                                        ),
                                        // const Icon(
                                        //   CupertinoIcons.xmark,
                                        //   color: Colors.white,
                                        // ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: _authenticateWithBiometrics,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              15))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          _isAuthenticating
                                              ? 'Cancel'
                                              : 'Authenticate',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800),
                                        ),
                                        const Icon(Icons.fingerprint),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Positioned(
                              left: 0,
                              right: 0,
                              bottom: -48,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                );
              }),
    ).then((onClosed));
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
