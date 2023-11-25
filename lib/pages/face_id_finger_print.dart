import 'package:desalmcs_mobile_app/api/api_service.dart';
import 'package:desalmcs_mobile_app/model/other_model.dart';
import 'package:desalmcs_mobile_app/pages/dashboard.dart';
import 'package:desalmcs_mobile_app/util/home_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
class FaceIDFingerPrint extends StatefulWidget {
  const FaceIDFingerPrint({super.key});

  @override
  State<FaceIDFingerPrint> createState() => _FaceIDFingerPrintState();
}

class _FaceIDFingerPrintState extends State<FaceIDFingerPrint> {
  bool isBiometricDialogShown = false;
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  String? token;
  bool isApiCallProcess = false;
  
  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
      (bool isSupported) => setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported),
    );
    _checkBiometrics();
    _getAvailableBiometrics();
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

    setState((){
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
      String? biometricToken = prefs.getString('biometricToken');
      print(biometricToken);

      APIService apiService = APIService();
      apiService.biometricLogin(biometricToken!).then((value) async {
        setState(() {
          isApiCallProcess = false;
          _isAuthenticating = false;
        });
        if (value.customerWalletsList.isNotEmpty) {
          await prefs.setString('biometricToken', value.token);
          //Todo add token to database or modify
          APIService apiServiceDeviceToken =
          APIService();
          print("token - $token");
          PushDeviceTokenRequestModel pushDeviceTokenRequestModel =
          PushDeviceTokenRequestModel(deviceToken: token);
          apiServiceDeviceToken.addDeviceToken(
              pushDeviceTokenRequestModel, value.token);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeDrawer(
                value: 0,
                page: Dashboard(
                  token: value.token,
                  fullName: value.customerWalletsList[0].fullName, customerWallets: value.customerWalletsList,lastTransactions: value.lastTransactionsList,
                ),
                name: 'wallet',
                fullName: value.customerWalletsList[0].fullName,
                token: value.token, customerWallets: value.customerWalletsList, lastTransactionsList: value.lastTransactionsList
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
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Face ID / Fingerprint',
          style: GoogleFonts.openSans(
            color: const Color(0xff091841),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff091841)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              child: Image.asset('assets/faceid.jpeg'),
            ),
            Text('Face ID / Fingerprint Sign In',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: const Color(0xff000080),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_supportState == _SupportState.unknown)
              const CircularProgressIndicator()
            else if (_supportState == _SupportState.supported)
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
                    CupertinoIcons.exclamationmark_triangle_fill,
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
                    primary: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
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
                    primary: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _isAuthenticating ? 'Cancel' : 'Authenticate',
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
      ),
    );
  }
}