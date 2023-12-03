import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/pages/setting.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';


Future<Object?> changePassword(BuildContext context,
    {required ValueChanged onClosed,
      required final String fullName,
      required final String token,
      required final List<CustomerWalletsBalanceModel> customerWallets,
      required final List<LastTransactionsModel> lastTransactions,
    }){
  bool isApiCallProcess = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  bool isDisabled = true;
  bool obscure = true;
  bool obscure1 = true;
  late FocusNode focusNode;
  late FocusNode focusNode1;
  return showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: 'Change Password',
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
            passwordController.text.isEmpty ? setState(() {
              isDisabled = true;
            })
                : setState(() {
              isDisabled = false;
            });
          }
          focusNode = FocusNode();
          focusNode.addListener(() => setState(() {}));
          focusNode1 = FocusNode();
          focusNode1.addListener(() => setState(() {}));

          void obscureView() {
            setState(() {
              obscure = !obscure;
            });
          }

          void obscureView1() {
            setState(() {
              obscure1 = !obscure1;
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
                        const SizedBox(height: 20),
                        Text('Change Password',
                            style: GoogleFonts.montserrat(
                              color: const Color(0xff000080),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                        const SizedBox(height: 15),
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          decoration: focusNode.hasFocus
                              ? BoxDecoration(
                            boxShadow: const [BoxShadow(blurRadius: 6)],
                            borderRadius: BorderRadius.circular(20),
                          )
                              : BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextFormField(
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.text,
                            controller: passwordController,
                            obscureText: obscure,
                            obscuringCharacter: "*",
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Password',
                              hintStyle: GoogleFonts.montserrat(
                                color: const Color(0xff9ca2ac),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              suffixIcon: obscure
                                  ? IconButton(
                                onPressed: obscureView,
                                icon: const Icon(Icons.visibility_off),
                                color: Colors.grey,
                              )
                                  : IconButton(
                                onPressed: obscureView,
                                icon: const Icon(Icons.visibility),
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.blue),
                              ),
                            ),
                            onTap: enableButton,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          decoration: focusNode1.hasFocus
                              ? BoxDecoration(
                            boxShadow: const [BoxShadow(blurRadius: 6)],
                            borderRadius: BorderRadius.circular(20),
                          )
                              : BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextFormField(
                            focusNode: focusNode1,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.text,
                            controller: cPasswordController,
                            obscureText: obscure1,
                            obscuringCharacter: "*",
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Re-type Password',
                              hintStyle: GoogleFonts.montserrat(
                                color: const Color(0xff9ca2ac),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              suffixIcon: obscure1 ? IconButton(
                                onPressed: obscureView1,
                                icon: const Icon(Icons.visibility_off),
                                color: Colors.grey,
                              )
                                  : IconButton(
                                onPressed: obscureView1,
                                icon: const Icon(Icons.visibility),
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.blue),
                              ),
                            ),
                            onTap: enableButton,
                          ),
                        ),
                        const SizedBox(height: 30),
                        isApiCallProcess ? const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                            : ElevatedButton(
                          onPressed: () async {
                            APIService apiService = APIService();
                            if (passwordController.text.isEmpty) {
                              Fluttertoast.showToast(msg: 'Password cannot be empty');
                            } else if (cPasswordController.text.isEmpty) {
                              Fluttertoast.showToast(msg: 'Password cannot be empty');
                            } else if (cPasswordController.text != passwordController.text) {
                              Fluttertoast.showToast(msg: 'Password does not match');
                            } else {
                              String password = passwordController.text;
                              setState(() {
                                isApiCallProcess = true;
                              });
                              apiService.modifyPassword(password, token).then((value) {
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
                                            color: const Color.fromRGBO(0, 0, 139, 1),
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
                                            'Password Successfully modified!',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.montserrat(),
                                          ),
                                          actionsAlignment: MainAxisAlignment.start,
                                          actions: <Widget>[
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                      builder: (context) => HomeDrawer(
                                                          value: 1,
                                                          page: Setting(
                                                            token: token,
                                                            fullName: fullName,
                                                            customerWallets: customerWallets,
                                                            lastTransactions: lastTransactions, phoneNumber: customerWallets[0].phoneNo,
                                                          ),
                                                          name: 'setting',
                                                          token: token,
                                                          fullName: fullName,
                                                          customerWallets: customerWallets,
                                                          lastTransactionsList: lastTransactions)));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.grey.shade200,
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
                                                      color: const Color.fromRGBO(0, 0, 139, 1),
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
                                        return AlertDialog(
                                          title: Text("Notice",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          content: Text("Password NOT modified!",
                                            style: GoogleFonts.montserrat(),
                                          ),
                                        );
                                      }
                                  );
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Submit",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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


// class ChangePassword extends StatefulWidget {
//   final String fullName;
//   final String token;
//   const ChangePassword(
//       {Key? key,
//       required this.fullName,
//       required this.token})
//       : super(key: key);

//   @override
//   State<ChangePassword> createState() => _ChangePasswordState();
// }

// class _ChangePasswordState extends State<ChangePassword> {
//   bool isApiCallProcess = false;
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController cPasswordController = TextEditingController();
//   bool isDisabled = true;
//   bool obscure = true;
//   bool obscure1 = true;
//   late FocusNode focusNode;
//   late FocusNode focusNode1;

//   @override
//   void initState() {
//     super.initState();
//     focusNode = FocusNode();
//     focusNode.addListener(() => setState(() {}));
//     focusNode1 = FocusNode();
//     focusNode1.addListener(() => setState(() {}));
//   }

//   void obscureView() {
//     setState(() {
//       obscure = !obscure;
//     });
//   }

//   void obscureView1() {
//     setState(() {
//       obscure1 = !obscure1;
//     });
//   }

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
//           AnimatedContainer(
//             duration: const Duration(seconds: 1),
//             decoration: focusNode.hasFocus
//                 ? BoxDecoration(
//               boxShadow: const [BoxShadow(blurRadius: 6)],
//               borderRadius: BorderRadius.circular(20),
//             )
//                 : BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: TextFormField(
//               focusNode: focusNode,
//               textAlign: TextAlign.center,
//               keyboardType: TextInputType.text,
//               controller: passwordController,
//               obscureText: obscure,
//               obscuringCharacter: "*",
//               decoration: InputDecoration(
//                 isDense: true,
//                 hintText: 'Password',
//                 hintStyle: GoogleFonts.montserrat(
//                   color: const Color(0xff9ca2ac),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(color: Colors.red),
//                 ),
//                 suffixIcon: obscure
//                     ? IconButton(
//                   onPressed: obscureView,
//                   icon: const Icon(Icons.visibility_off),
//                   color: Colors.grey,
//                 )
//                     : IconButton(
//                   onPressed: obscureView,
//                   icon: const Icon(Icons.visibility),
//                   color: Colors.grey,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(color: Colors.blue),
//                 ),
//               ),
//               onTap: enableButton,
//             ),
//           ),
//           const SizedBox(height: 15),
//           AnimatedContainer(
//             duration: const Duration(seconds: 1),
//             decoration: focusNode1.hasFocus
//                 ? BoxDecoration(
//               boxShadow: const [BoxShadow(blurRadius: 6)],
//               borderRadius: BorderRadius.circular(20),
//             )
//                 : BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: TextFormField(
//               focusNode: focusNode1,
//               textAlign: TextAlign.center,
//               keyboardType: TextInputType.text,
//               controller: cPasswordController,
//               obscureText: obscure1,
//               obscuringCharacter: "*",
//               decoration: InputDecoration(
//                 isDense: true,
//                 hintText: 'Re-type Password',
//                 hintStyle: GoogleFonts.montserrat(
//                   color: const Color(0xff9ca2ac),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(color: Colors.red),
//                 ),
//                 suffixIcon: obscure1 ? IconButton(
//                   onPressed: obscureView1,
//                   icon: const Icon(Icons.visibility_off),
//                   color: Colors.grey,
//                 )
//                 : IconButton(
//                   onPressed: obscureView1,
//                   icon: const Icon(Icons.visibility),
//                   color: Colors.grey,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                   borderSide: const BorderSide(color: Colors.blue),
//                 ),
//               ),
//               onTap: enableButton,
//             ),
//           ),
//           const SizedBox(height: 30,),
//           ElevatedButton(
//             onPressed: () async {
//               final prefs = await SharedPreferences.getInstance();
//               String subdomain = prefs.getString('subdomain') ?? 'https://core.myminervahub.com';

//               APIService apiService = APIService();
//               if (passwordController.text.isEmpty) {
//                 Fluttertoast.showToast(msg: 'Password cannot be empty');
//               } else if (cPasswordController.text.isEmpty) {
//                 Fluttertoast.showToast(msg: 'Password cannot be empty');
//               } else if (cPasswordController.text != passwordController.text) {
//                 Fluttertoast.showToast(msg: 'Password does not match');
//               } else {
//                 String password = passwordController.text;
//                 setState(() {
//                   isApiCallProcess = true;
//                 });
//                 apiService.modifyPassword(password, token).then((value) {
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
//                               color: const Color.fromRGBO(0, 0, 139, 1),
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
//                               'Password Successfully modified!', 
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
//                                     primary: Colors.grey.shade200,
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
//                                         color: const Color.fromRGBO(0, 0, 139, 1),
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
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           title: Text("Notice",
//                             style: GoogleFonts.montserrat(
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                           content: Text("Password NOT modified!",
//                             style: GoogleFonts.montserrat(),
//                           ),
//                         );
//                       }
//                     );
//                   }
//                 });
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               primary: Colors.lightBlue,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: Text(
//               "Submit",
//               style: GoogleFonts.montserrat(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   void enableButton() {
//     passwordController.text.isEmpty ? setState(() {
//       isDisabled = true;
//     })
//         : setState(() {
//       isDisabled = false;
//     });
//   }

// }