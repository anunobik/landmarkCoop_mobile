import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:landmarkcoop_latest/main_view.dart';
import '../component/custom_text_form_field.dart';
import '../entry_point.dart';
import '../model/customer_model.dart';

Future<Object?> updateBVN(
  BuildContext context, {
  required ValueChanged onClosed,
  required final String fullName,
  required final String token,
  required final List<CustomerWalletsBalanceModel> customerWallets,
}) {
  TextEditingController bvnController = TextEditingController();
  bool isDisabled = true;
  bool isApiCallProcess = false;
  return showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: 'Update BVN',
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
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      void enableButton() {
        bvnController.text.isEmpty
            ? setState(() {
                isDisabled = true;
              })
            : setState(() {
                isDisabled = false;
              });
      }

      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
                  children: [
                    const SizedBox(height: 50),
                    Text('Update Your BVN',
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff000080),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      keyboardType: TextInputType.phone,
                      controller: bvnController,
                      hintText: "Enter Your BVN",
                      enabled: true,
                      enableButton: enableButton,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    isApiCallProcess
                        ? const Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              String subdomain = prefs.getString('subdomain') ??
                                  'https://core.landmarkcooperative.org';
                              // To Do
                              setState(() {
                                isApiCallProcess = true;
                              });
                              APIService apiService =
                                  APIService(subdomain_url: subdomain);
                              apiService
                                  .updateAccountWithBVN(
                                      bvnController.text.trim(), token)
                                  .then((value) {
                                setState(() {
                                  isApiCallProcess = false;
                                });
                                if (value.status) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Container(
                                            height: 50,
                                            alignment: Alignment.centerLeft,
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            color: Colors.blueAccent,
                                            child: Center(
                                              child: Text(
                                                'Message',
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          content: Text(
                                            "BVN linked successfully and new account generated\n ${value.message} \n You would now be logged out.\nPlease login again",
                                            textAlign: TextAlign.center,
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.start,
                                          actions: <Widget>[
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () async{
                                                  final prefs = await SharedPreferences.getInstance();
                                                  String institution =
                                                      prefs.getString('institution') ?? 'Minerva Hub';
                                                  String subdomain = prefs.getString('subdomain') ??
                                                      'https://core.landmarkcooperative.org';
                                                  APIService apiService = APIService(subdomain_url: subdomain);
                                                  apiService.logout(token).then((value) {
                                                    prefs.setString('biometricToken', value);
                                                    print('Token at Logout - $value');
                                                  });
                                                  Navigator.popUntil(context, (route) => route.isFirst);
                                                  Navigator.of(context).pushReplacement(
                                                    MaterialPageRoute(builder: (context) => MainView(),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey.shade200,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10,
                                                      horizontal: 15),
                                                  child: Text(
                                                    "Close",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Container(
                                            height: 50,
                                            alignment: Alignment.centerLeft,
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            color: Colors.blueAccent,
                                            child: Center(
                                              child: Text(
                                                'Message',
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          content: Text(
                                            value.message,
                                            textAlign: TextAlign.center,
                                          ),
                                          actionsAlignment:
                                              MainAxisAlignment.start,
                                          actions: <Widget>[
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey.shade200,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10,
                                                      horizontal: 15),
                                                  child: Text(
                                                    "Close",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Submit",
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
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
