import 'package:desalmcs_mobile_app/api/api_service.dart';
import 'package:desalmcs_mobile_app/util/ProgressHUD.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePassword extends StatefulWidget {
  final String fullName;
  final String token;
  const ChangePassword({super.key, required this.fullName, required this.token});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  APIService apiService = APIService();
  bool isApiCallProcess = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  bool isDisabled = true;
  bool obscure = true;
  bool obscure1 = true;
  late FocusNode focusNode;
  late FocusNode focusNode1;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() => setState(() {}));
    focusNode1 = FocusNode();
    focusNode1.addListener(() => setState(() {}));
  }

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Wrap(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    Container(
                      height: 3,
                      width: 50,
                      color: Colors.grey.shade300,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        Text('Modify Password',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            )),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Color(0XFF091841),
                            ))
                      ],
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 15),
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
                          suffixIcon: obscure1
                              ? IconButton(
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
                    const SizedBox(height: 30,),
                    ElevatedButton(
                      onPressed: () {
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
                          apiService.modifyPassword(password, widget.token).then((value) {
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
                                        color: Colors.blue.shade200,
                                        child: Text(
                                          'Message',
                                          style: GoogleFonts.montserrat(
                                              color: Colors.blue,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      content: const Text('Password Successfully modified!'),
                                      actionsAlignment: MainAxisAlignment.start,
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
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
                                                color: Colors.blue,
                                                fontSize: 16,
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
                                      content: Text("Password NOT modified!"),
                                    );
                                  });
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void enableButton() {
    passwordController.text.isEmpty ? setState(() {
      isDisabled = true;
    })
        : setState(() {
      isDisabled = false;
    });
  }

}

// Previous Code

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
//   APIService apiService = APIService();
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
//                 suffixIcon: obscure1
//                     ? IconButton(
//                   onPressed: obscureView1,
//                   icon: const Icon(Icons.visibility_off),
//                   color: Colors.grey,
//                 )
//                     : IconButton(
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
//             onPressed: () {
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
//                 apiService.modifyPassword(password, widget.token).then((value) {
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
//                               color: Colors.blue.shade200,
//                               child: Text(
//                                 'Message',
//                                 style: GoogleFonts.montserrat(
//                                     color: Colors.blue,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                             content: const Text('Password Successfully modified!'),
//                             actionsAlignment: MainAxisAlignment.start,
//                             actions: <Widget>[
//                               ElevatedButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   primary: Colors.grey.shade200,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 10, horizontal: 10),
//                                   child: Text(
//                                     "Close",
//                                     style: GoogleFonts.montserrat(
//                                       color: Colors.blue,
//                                       fontSize: 16,
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
//                             content: Text("Password NOT modified!"),
//                           );
//                         });
//                   }
//                 });
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//             child: const Text(
//               "Submit",
//               style: TextStyle(color: Colors.white),
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