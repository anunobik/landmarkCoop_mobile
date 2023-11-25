import 'package:desalmcs_mobile_app/api/api_service.dart';
import 'package:desalmcs_mobile_app/component/custom_text_form_field.dart';
import 'package:desalmcs_mobile_app/model/customer_model.dart';
import 'package:desalmcs_mobile_app/pages/certificate_of_investment.dart';
import 'package:desalmcs_mobile_app/util/ProgressHUD.dart';
import 'package:desalmcs_mobile_app/util/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ChangePhoneNo extends StatefulWidget {
  final String fullName;
  final String token;
  const ChangePhoneNo({super.key, required this.fullName, required this.token});

  @override
  State<ChangePhoneNo> createState() => _ChangePhoneNoState();
}

class _ChangePhoneNoState extends State<ChangePhoneNo> {
  APIService apiService = APIService();
  bool isApiCallProcess = false;
  TextEditingController phoneController = TextEditingController();
  bool isDisabled = true;

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
                        Text('Change Phone Number',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Color(0XFF091841),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      hintText: "Enter New Phone No.",
                      enabled: true,
                      enableButton: enableButton,
                    ),
                    const SizedBox(height: 30,),
                    ElevatedButton(
                      onPressed: () {
                        if (phoneController.text.isEmpty) {
                          Fluttertoast.showToast(msg: 'Phone number cannot be empty');
                        } else {
                          String phoneNo = phoneController.text;
                          setState(() {
                            isApiCallProcess = true;
                          });
                          apiService.changePhoneNo(phoneNo, widget.token).then((value) {
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
                                      content: Text('Phone Number Successfully modified!',
                                        style: GoogleFonts.montserrat(),
                                      ),
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
                                      content: Text("Phone Number NOT modified!"),
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
                      child: Text(
                        "Submit",
                        style: GoogleFonts.montserrat(color: Colors.white),
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
    phoneController.text.isEmpty ? setState(() {
      isDisabled = true;
    })
        : setState(() {
      isDisabled = false;
    });
  }

}

// Previous Code


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
//   APIService apiService = APIService();
//   bool isApiCallProcess = false;
//   TextEditingController phoneController = TextEditingController();
//   bool isDisabled = true;

//   @override
//   Widget build(BuildContext context) {
//     return ProgressHUD(
//       child: _uiSetup(context),
//       inAsyncCall: isApiCallProcess,
//       opacity: 0.3,
//     );
//   }

//   Widget _uiSetup(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(children: <Widget>[
//           SizedBox(height: 50,),
//           CustomTextFormField(
//             keyboardType: TextInputType.phone,
//             controller: phoneController,
//             hintText: "Enter New Phone No.",
//             enabled: true,
//             enableButton: enableButton,
//           ),
//           SizedBox(height: 30,),
//           ElevatedButton(
//             onPressed: () {
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
//                               color: Colors.blue.shade200,
//                               child: Text(
//                                 'Message',
//                                 style: GoogleFonts.montserrat(
//                                     color: Colors.blue,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                             content: Text('Phone Number Successfully modified!'),
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
//                             content: Text("Phone Number NOT modified!"),
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
//             child: Text(
//               "Submit",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ]),
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
