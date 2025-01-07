import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../component/custom_text_form_field.dart';
import '../utils/ProgressHUD.dart';


Future<Object?> changePhoneNo(BuildContext context,
    {required ValueChanged onClosed,
      required final String fullName,
      required final String token,}){
  TextEditingController phoneController = TextEditingController();
  bool isDisabled = true;
  bool isApiCallProcess = false;
  return showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: 'Change Phone Number',
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (context, animation, __, child) {
      Tween<Offset> tween;
      tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
      return SlideTransition(
        position: tween.animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        ),
        child: child,
      );
    },
    context: context,
    pageBuilder: (context, _, __) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          void enableButton() {
            phoneController.text.isEmpty ? setState(() {
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
                        Text('Change Phone Number',
                            style: GoogleFonts.montserrat(
                              color: const Color(0xff000080),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          keyboardType: TextInputType.phone,
                          controller: phoneController,
                          hintText: "Enter New Phone No.",
                          enabled: true,
                          enableButton: enableButton,
                        ),
                        const SizedBox(height: 30,),
                        isApiCallProcess ? const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                            : ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

                            APIService apiService = APIService(subdomain_url: subdomain);
                            if (phoneController.text.isEmpty) {
                              Fluttertoast.showToast(msg: 'Phone number cannot be empty');
                            } else {
                              String phoneNo = phoneController.text;
                              setState(() {
                                isApiCallProcess = true;
                              });
                              apiService.changePhoneNo(phoneNo, token).then((value) {
                                setState(() {
                                  isApiCallProcess = false;
                                });
                                if(value == 'Success'){
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Container(
                                            height: 50,
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(left: 15),
                                            color: const Color(0xff000080),
                                            child: Center(
                                              child: Text(
                                                'Message',
                                                style: GoogleFonts.montserrat(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                          content: Text(
                                            'Phone Number Successfully modified!',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(),
                                          ),
                                          actionsAlignment: MainAxisAlignment.start,
                                          actions: <Widget>[
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey.shade200,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      vertical: 10, horizontal: 10),
                                                  child: Text(
                                                    "Close",
                                                    style: GoogleFonts.montserrat(
                                                      color: const Color(0xff000080),
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                }else{
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const AlertDialog(
                                          title: Text("Notice"),
                                          content: Text("Phone Number NOT modified!"),
                                        );
                                      });
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Submit",
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
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
                        )
                    )
                  ],
                ),
              ),
            ),
          );
        }
    ),
  ).then((onClosed));
}


// class ChangePhoneNo extends StatefulWidget {
//   final String fullName;
//   final String token;
//   const ChangePhoneNo(
//       {Key? key,
//       required this.fullName,
//       required this.token})
//       : super(key: key);

//   @override
//   State<ChangePhoneNo> createState() => _ChangePhoneNoState();
// }

// class _ChangePhoneNoState extends State<ChangePhoneNo> {
//   bool isApiCallProcess = false;
//   TextEditingController phoneController = TextEditingController();
//   bool isDisabled = true;

//   @override
//   Widget build(BuildContext context) {
//     return ProgressHUD(
//       inAsyncCall: isApiCallProcess,
//       opacity: 0.3,
//       child: _uiSetup(context),
//     );
//   }

//   Widget _uiSetup(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(children: <Widget>[
//           const SizedBox(height: 50,),
//           CustomTextFormField(
//             keyboardType: TextInputType.phone,
//             controller: phoneController,
//             hintText: "Enter New Phone No.",
//             enabled: true,
//             enableButton: enableButton,
//           ),
//           const SizedBox(height: 30,),
//           ElevatedButton(
//             onPressed: () async {
//               final prefs = await SharedPreferences.getInstance();
//               String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

//               APIService apiService = APIService(subdomain_url: subdomain);
//               if (phoneController.text.isEmpty) {
//                 Fluttertoast.showToast(msg: 'Phone number cannot be empty');
//               } else {
//                 String phoneNo = phoneController.text;
//                 setState(() {
//                   isApiCallProcess = true;
//                 });
//                 apiService.changePhoneNo(phoneNo, widget.token).then((value) {
//                   setState(() {
//                     isApiCallProcess = false;
//                   });
//                   if(value == 'Success'){
//                     showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             title: Container(
//                               height: 50,
//                               alignment: Alignment.centerLeft,
//                               padding: const EdgeInsets.only(left: 15),
//                               color: const Color(0xff000080),
//                               child: Center(
//                                 child: Text(
//                                   'Message',
//                                   style: GoogleFonts.montserrat(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                               ),
//                             ),
//                             content: Text(
//                               'Phone Number Successfully modified!', 
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.montserrat(),
//                             ),
//                             actionsAlignment: MainAxisAlignment.start,
//                             actions: <Widget>[
//                               Center(
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.grey.shade200,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 10, horizontal: 10),
//                                     child: Text(
//                                       "Close",
//                                       style: GoogleFonts.montserrat(
//                                         color: const Color(0xff000080),
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         });
//                   }else{
//                     showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return const AlertDialog(
//                             title: Text("Notice"),
//                             content: Text("Phone Number NOT modified!"),
//                           );
//                         });
//                   }
//                 });
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: Text(
//               "Submit",
//               style: GoogleFonts.montserrat(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold
//               ),
//             ),
//           ),
//         ]
//         ),
//       ),
//     );
//   }

//   void enableButton() {
//     phoneController.text.isEmpty ? setState(() {
//       isDisabled = true;
//     })
//         : setState(() {
//       isDisabled = false;
//     });
//   }

// }