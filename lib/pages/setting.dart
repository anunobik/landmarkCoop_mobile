import 'dart:io';
import 'package:desalmcs_mobile_app/model/customer_model.dart';
import 'package:desalmcs_mobile_app/model/other_model.dart';
import 'package:desalmcs_mobile_app/pages/change_password.dart';
import 'package:desalmcs_mobile_app/pages/change_phone_no.dart';
import 'package:desalmcs_mobile_app/pages/login.dart';
import 'package:desalmcs_mobile_app/pushNotifications/push_messages.dart';
import 'package:desalmcs_mobile_app/util/home_drawer.dart';
import 'package:desalmcs_mobile_app/util/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:badges/badges.dart' as badges;
import 'package:overlay_support/overlay_support.dart';

import '../api/api_service.dart';
import '../model/push_notification.dart';

class Setting extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;
  const Setting({Key? key, required this.fullName, required this.token, required this.customerWallets, required this.lastTransactions}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  TextEditingController phoneController = TextEditingController(text: "08032145678");
  TextEditingController emailController = TextEditingController(text: "jackson@mymail.com");
  bool enabled = false;
  APIService apiService = APIService();
  bool isApiCallProcess = false;

   // ignore: unused_field
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  String url = "";
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];


  void _onImageButtonPressed(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 63.75,
        maxHeight: 63.75,
        imageQuality: 90,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  enabledForm() {
    setState(() {
      enabled = !enabled;
    });
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );

      if (mounted) {
        setState(() {
        notificationInfo = notification;
        totalNotifications++;
      });
      if (notificationInfo != null) {
        // For displaying the notification as an overlay
        showSimpleNotification(
          Text(notificationInfo!.title!),
          leading: NotificationBadge(totalNotifications: totalNotifications),
          subtitle: Text(notificationInfo!.body!),
          background: Colors.cyan.shade700,
          duration: const Duration(seconds: 2),
        );
        notificationList.add(
          {
            "title": notificationInfo!.title!,
            "body": notificationInfo!.body!
          },
        );
      }
      }
    });

    // Open to notification screen
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if(mounted) {
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });
        notificationList.add({
          'title' : notificationInfo!.title,
          'body' : notificationInfo!.body,
        });

        // API Sign in token
        
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context)=>  PushMessages(
                notificationList: notificationList, 
                totalNotifications: totalNotifications,
              ))
            );
        }
      }
    );
    totalNotifications = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Container(
                          height: 80,
                          width: 80,
                          color: Colors.blue,
                          child: Center(
                            child: Container(
                              height: 60,
                              width: 60,
                              color: Colors.blue,
                              child: url.isNotEmpty ? Center(
                                child: CircleAvatar(
                                  radius: 80.0,
                                  backgroundImage: NetworkImage(url),
                                ),
                              )
                              : _imageFile != null ? CircleAvatar(
                                backgroundColor: Colors.grey.shade100,
                                radius: 50,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(38),
                                  child: Image.file(
                                    File(_imageFile!.path),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ) 
                              : const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          photoAlertDialog(context);
                        },
                        child: Text('Upload Image',
                          style: GoogleFonts.montserrat(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(widget.fullName,
                        style: GoogleFonts.montserrat(
                          color: Colors.black54,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        height: 2,
                        indent: 100,
                        endIndent: 100,
                        color: Colors.blue.shade100,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          enabled ? TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            }, 
                            child: Text("Save",
                              style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          : Container(),
                          enabled ? TextButton(
                            onPressed: enabledForm, 
                            child: Text("Cancel",
                              style: GoogleFonts.montserrat(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          : TextButton(
                            onPressed: enabledForm, 
                            child: Text("Edit",
                              style: GoogleFonts.montserrat(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                           enabled ? showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0))),
                            backgroundColor: Colors.white,
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return ChangePhoneNo(
                                fullName: widget.fullName, 
                                token: widget.token,
                              );
                            },
                          )
                          : null;
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: enabled ? Colors.white : Colors.grey.shade100,
                            borderRadius: enabled ? BorderRadius.circular(20) 
                            : BorderRadius.circular(0),
                            border: Border.all(color: enabled ? Colors.grey
                              : Colors.transparent
                            )
                          ),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(left: 10.0, right: 60),
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(phoneController.text,
                                style: GoogleFonts.montserrat(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          isDense: true,
                          enabled: enabled,
                          hintText: '',
                          hintStyle: GoogleFonts.montserrat(
                            color: const Color(0xff9ca2ac),
                          ),
                          filled: true,
                          fillColor: enabled ? Colors.white : Colors.grey.shade100,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.blue,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 15),
                      // GestureDetector(
                      //   onTap: () {},
                      //   child: Container(
                      //     height: 50,
                      //     decoration: BoxDecoration(
                      //       color: enabled ? Colors.white : Colors.grey.shade100,
                      //       borderRadius: enabled ? BorderRadius.circular(20) 
                      //       : BorderRadius.circular(0),
                      //       border: Border.all(color: enabled ? Colors.grey
                      //         : Colors.transparent
                      //       )
                      //     ),
                      //     child: Row(
                      //       children: <Widget>[
                      //         const Padding(
                      //           padding: EdgeInsets.only(left: 10.0, right: 60),
                      //           child: Icon(
                      //             Icons.account_balance,
                      //             color: Colors.blue,
                      //           ),
                      //         ),
                      //         Text('Fidelity - 2007987654',
                      //           style: GoogleFonts.montserrat(),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                           enabled ? showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0))),
                            backgroundColor: Colors.white,
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return ChangePassword(
                                fullName: widget.fullName, 
                                token: widget.token,
                              );
                            },
                          )
                          : null;
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: enabled ? Colors.white : Colors.grey.shade100,
                            borderRadius: enabled ? BorderRadius.circular(20) 
                            : BorderRadius.circular(0),
                            border: Border.all(color: enabled ? Colors.grey
                              : Colors.transparent
                            )
                          ),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(left: 10.0, right: 60),
                                child: Icon(
                                  Icons.password,
                                  color: Colors.blue,
                                ),
                              ),
                              Text('XXXXXXX',
                                style: GoogleFonts.montserrat(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const Login())),
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(20, 20)
                            )
                          ),
                          primary: Colors.lightBlue
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                          child:Text(
                            'Sign Out',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 7,
              left: 10,
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => HomeDrawer(
                          value: 1,
                          page: Setting(token: widget.token,
                            fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactions: widget.lastTransactions,),
                          name: 'setting',
                          token: widget.token,
                          fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactionsList: widget.lastTransactions,
                          ))
                      );
                    },
                    icon: Icon(
                      Icons.menu,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox( width: 280),
                  badges.Badge(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) =>  PushMessages(
                          notificationList: notificationList,
                          totalNotifications: totalNotifications,
                        ))
                      );
                    },
                    badgeContent: Text(totalNotifications.toString(),
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w700
                    ),
                    ),
                    child: const Icon(Icons.notifications),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Choose Camera or Gallery
  photoAlertDialog(BuildContext context) {
    SimpleDialog photoAlert = SimpleDialog(
      backgroundColor: const Color(0xff30384d),
      contentPadding: const EdgeInsets.only(bottom: 20),
      title: Text(
        'Photo Option ',
        style: GoogleFonts.montserrat(
          color: Colors.blue,
        ),
      ),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            _onImageButtonPressed(ImageSource.gallery, context);
            Navigator.pop(context);
          },
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.lightBlueAccent,
              ),
              const SizedBox(width: 20),
              Text('Gallery',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            _onImageButtonPressed(ImageSource.camera, context);
            Navigator.pop(context);
          },
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.add_a_photo_outlined,
                color: Colors.lightBlueAccent,
              ),
              const SizedBox(width: 20),
              Text('Camera',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return photoAlert;
      }
    );
  }
}


// Previous Code

// import 'package:desalmcs_mobile_app/pages/change_password.dart';
// import 'package:desalmcs_mobile_app/pages/change_phone_no.dart';
// import 'package:desalmcs_mobile_app/util/home_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class Setting extends StatefulWidget {
//   final String fullName;
//   final String token;
//   const Setting({Key? key, required this.fullName, required this.token}) : super(key: key);

//   @override
//   State<Setting> createState() => _SettingState();
// }

// class _SettingState extends State<Setting> {

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(builder: (context) => HomeDrawer(
//                       value: 1,
//                       page: Setting(token: widget.token,
//                         fullName: widget.fullName, ),
//                       name: 'setting',
//                       token: widget.token,
//                       fullName: widget.fullName,
//                       ))
//                   );
//                 },
//                 icon: Icon(
//                   Icons.menu,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 8),
//                 height: 45,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 child: TabBar(
//                   indicator: BoxDecoration(
//                     color: const Color.fromRGBO(0, 0, 139, 1),
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                   labelColor: Colors.white,
//                   unselectedLabelColor: Colors.grey,
//                   labelStyle: GoogleFonts.montserrat(
//                     fontWeight: FontWeight.bold
//                   ),
//                   unselectedLabelStyle: GoogleFonts.montserrat(
//                     fontWeight: FontWeight.bold
//                   ),
//                   tabs: const [
//                     Tab(text: 'Modify Phone'),
//                     Tab(text: 'Modify Password'),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: TabBarView(
//                     children: [
//                       ChangePhoneNo(token: widget.token, fullName: widget.fullName,),
//                       ChangePassword(token: widget.token, fullName: widget.fullName,),
//                     ]
//                 ),
//               ),
//             ],
//           )
//         ),
//       ),
//     );
//   }
// }

