
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/api/api_service.dart';
import 'package:landmarkcoop_latest/entry_point.dart';
import 'package:landmarkcoop_latest/model/complaint_model.dart';
import 'package:landmarkcoop_latest/model/customer_model.dart';
import 'package:landmarkcoop_latest/model/login_model.dart';
import 'package:landmarkcoop_latest/model/push_notification.dart';
import 'package:landmarkcoop_latest/utils/InactivityService.dart';
import 'package:landmarkcoop_latest/utils/ProgressHUD.dart';
import 'package:landmarkcoop_latest/utils/notification_badge.dart';
import 'package:landmarkcoop_latest/widgets/bottom_nav_bar.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ContactCustomerSupport extends StatefulWidget {
  final int pageIndex;
  final String fullName;
  final String token;
  final String referralId;
  final List<CustomerWalletsBalanceModel> customerWallets;
  const ContactCustomerSupport({Key? key,
    required this.pageIndex,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.referralId,
    })
      : super(key: key);

  @override
  State<ContactCustomerSupport> createState() => _ContactCustomerSupportState();
}

class _ContactCustomerSupportState extends State<ContactCustomerSupport> {
  String currentComplaintCategory = "Complaint category ";
  List<String> complaintCategory = [
    "Complaint category ",
    "Debit Error",
    "Credit Error",
    "Loan Issues",
    "Investment Issues",
    "Other Issues",
  ];
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String name = "";
  String email = "";
  String phoneNo = "";
  String subject = "";
  String description = "";
  ComplaintRequestModel complaintRequestModel = ComplaintRequestModel();
  bool isApiCallProcess = false;late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  LoginRequestModel loginRequestModel = LoginRequestModel();

  @override
  void initState() {
    super.initState();
    InactivityService().initializeInactivityTimer(context, widget.token);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
        );
        if (mounted) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('notificationTitle', message.notification!.title.toString());
          await prefs.setString('notificationBody', message.notification!.body.toString());
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
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if(mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('notificationTitle', message.notification!.title.toString());
        await prefs.setString('notificationBody', message.notification!.body.toString());
        String subdomain = prefs.getString('subdomain') ?? 'core.landmarkcooperative.org';
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });

        // API Sign in token
        APIService apiService = APIService(subdomain_url: subdomain);
        apiService.login(loginRequestModel).then((value) {
          if (value.customerWalletsList.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context)=> EntryPoint(
                customerWallets: value.customerWalletsList, 
                fullName: value.customerWalletsList[0].fullName, 
                screenName: 'Notification', 
                subdomain: subdomain, 
                token: value.token,
                referralId: value.customerWalletsList[0].phoneNo,
                ),
              )
            );
            notificationList.add({
              'title' : message.notification!.title,
              'body' : message.notification!.body,
            });
        }});
      }}
    );
    totalNotifications = 0;
    pushNotify();
  }

  void pushNotify() async{
    final prefs = await SharedPreferences.getInstance();
    String notificationTitle = prefs.getString('notificationTitle') ?? '';
    String notificationBody = prefs.getString('notificationBody') ?? '';
    print('Body - $notificationBody');
    if(notificationTitle != '') {
      setState((){
        notificationList.add({
          'title' : notificationTitle,
          'body' : notificationBody,
        });
      });
    }
  }

  @override
  void dispose() {
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
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
    nameController.text = widget.fullName;
    emailController.text = widget.customerWallets[0].email;

    // if (user?.phoneNumber != null) {
    //   phoneNoController.text = user!.phoneNumber!;
    // }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        InactivityService().resetInactivityTimer(context, widget.token);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Contact Customer Support',
                      style: GoogleFonts.openSans(
                        color: const Color(0xff000080),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Kindly filled out the form below',
                    style: GoogleFonts.openSans(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: nameController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: GoogleFonts.openSans(
                        color: const Color(0xff9ca2ac),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onChanged: (text) {
                      name = nameController.text;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    enabled: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                    EmailValidator.validate(email!) ? null : "Please enter a valid email",
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.openSans(
                        color: const Color(0xff9ca2ac),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onChanged: (text) {
                      email = emailController.text;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: phoneNoController,
                    decoration: InputDecoration(
                      labelText: 'Phone No.',
                      labelStyle: GoogleFonts.openSans(
                        color: const Color(0xff9ca2ac),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onChanged: (text) {
                      phoneNo = phoneNoController.text;
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Complaint category',
                    style: GoogleFonts.openSans(
                      color: const Color(0xff091841),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FormField<String>(builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelStyle: GoogleFonts.openSans(
                          color: const Color(0xff9ca2ac),
                        ),
                        errorStyle: GoogleFonts.openSans(
                          color: Colors.redAccent,
                        ),
                        hintText: 'Complaint category',
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      isEmpty: currentComplaintCategory == "",
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentComplaintCategory,
                          isDense: true,
                          onChanged: (newValue) {
                            setState(() {
                              currentComplaintCategory = newValue!;
                              state.didChange(newValue);
                              complaintRequestModel.complaintCategory = newValue;
                            });
                          },
                          items: complaintCategory
                              .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 15),
                  Text(
                    'Subject',
                    style: GoogleFonts.openSans(
                      color: const Color(0xff091841),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: subjectController,
                    decoration: InputDecoration(
                      hintText: 'Subject',
                      hintStyle: GoogleFonts.openSans(
                        color: const Color(0xff9ca2ac),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onChanged: (text) {
                      subject = subjectController.text;
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Description',
                    style: GoogleFonts.openSans(
                      color: const Color(0xff091841),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      hintStyle: GoogleFonts.openSans(
                        color: const Color(0xff9ca2ac),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onChanged: (text) {
                      description = descriptionController.text;
                    },
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

                        APIService apiService = APIService(subdomain_url: subdomain);
                        setState(() {
                          isApiCallProcess = true;
                        });
                        complaintRequestModel.fullName = nameController.text;
                        complaintRequestModel.email = emailController.text;
                        complaintRequestModel.phoneNo = phoneNoController.text;
                        complaintRequestModel.subject = subjectController.text;
                        complaintRequestModel.description =
                            descriptionController.text;
                        apiService
                            .recordComplaints(complaintRequestModel)
                            .then((value) {
                          setState(() {
                            isApiCallProcess = false;
                          });
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Notice!'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(value),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () async{
                                      final prefs = await SharedPreferences.getInstance();
                                      String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
                                      APIService apiService = APIService(subdomain_url: subdomain);

                                      // Fetch data asynchronously
                                      final value = await apiService.pageReload(widget.token);
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                                        builder: (context) => BottomNavBar(
                                          pageIndex: 0,
                                          fullName: widget.fullName,
                                          token: value.token,
                                          subdomain: subdomain,
                                          customerWallets: value.customerWalletsList,
                                          phoneNumber: widget.customerWallets[0].phoneNo,
                                        ),
                                      ));
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                        child: Text('Submit'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
