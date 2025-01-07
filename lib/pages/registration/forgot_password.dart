import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_service.dart';
import '../../model/password_model.dart';
import '../../utils/ProgressHUD.dart';
import '../check_your_mail.dart';

class ForgotPassword extends StatefulWidget {
  final String subdomain;
  final String institution;

  const ForgotPassword({
    Key? key,
    required this.institution,
    required this.subdomain,
  }) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  late PwdResetRequestModel pwdResetRequestModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<PwdResetResponseModel>? _futureResponse;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    pwdResetRequestModel = PwdResetRequestModel();
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
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        child: Center(
                          child: Text(
                            "Password Reset",
                            // style: Theme.of(context).textTheme.headline2,
                            style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontSize: 32,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                              'Enter the Phone Number or Email linked to your account and we will send an email with a default password to your email with instructions to reset your password.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
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
                              image: DecorationImage(
                                  image: AssetImage('assets/pics/royalmarshal-logo.png'),
                                  fit: BoxFit.contain
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (input) =>
                                pwdResetRequestModel.email = input!,
                            validator: (input) => input!.isEmpty
                                ? "Please Enter Email/Phone Number"
                                : null,
                            decoration: InputDecoration(
                              hintText: "Enter Linked Email / Phone Number",
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).focusColor
                                          .withOpacity(0.2))),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).focusColor)),
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Padding(
                          //   padding: const EdgeInsets.only(bottom: 10.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.end,
                          //     children: [
                          //       TextButton(
                          //           onPressed: () => Navigator.of(context)
                          //               .pushReplacement(MaterialPageRoute(
                          //                   builder: (context) =>
                          //                       NewPassword())),
                          //           child: Text(
                          //             'Change Password',
                          //             style: GoogleFonts.montserrat(
                          //                 color: Colors.blueAccent,
                          //                 fontWeight: FontWeight.w400),
                          //           ))
                          //     ],
                          //   ),
                          // ),
                          ElevatedButton(
                            onPressed: () async {
                              if (validateAndSave()){
                                final prefs = await SharedPreferences.getInstance();
                                String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

                                APIService apiService = APIService(subdomain_url: subdomain);
                                setState(() {
                                  isApiCallProcess = true;
                                });

                                apiService
                                    .passwordReset(pwdResetRequestModel)
                                    .then((value) {
                                  setState(() {
                                    isApiCallProcess = false;
                                  });

                                  if (value == 'Success') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => const CheckMail()),
                                    );
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const AlertDialog(
                                            title: Text("Message"),
                                            content: Text(
                                                "Incorrect Email Details"),
                                          );
                                        });
                                  }
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue
                              ,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Text(
                                "Submit",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(height: 15),
                          // (_futureResponse == null)
                          //     ? Center()
                          //     : buildFutureBuilder(),
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

  // FutureBuilder<PwdResetResponseModel> buildFutureBuilder() {
  //   return FutureBuilder<PwdResetResponseModel>(
  //       future: _futureResponse,
  //       builder: (context, snapshot) {
  //         if (snapshot.hasError) {
  //          print("${snapshot.error}");
  //          String err = snapshot.error.toString();
  //         return Text(err.substring(10, err.length));
  //         }
  //         return CircularProgressIndicator();
  //       });
  // }
}
