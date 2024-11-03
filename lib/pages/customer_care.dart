import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/complaint_model.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/pages/dashboard.dart';
import 'package:landmarkcoop_mobile_app/pushNotifications/push_messages.dart';
import 'package:landmarkcoop_mobile_app/util/ProgressHUD.dart';
import 'package:landmarkcoop_mobile_app/util/notification_badge.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:overlay_support/overlay_support.dart';


class ContactCustomerSupport extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;
  const ContactCustomerSupport({super.key,
    required this.customerWallets,
    required this.fullName,
    required this.lastTransactions,
    required this.token});

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
  APIService apiService = APIService();
  bool isApiCallProcess = false;
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomeDrawer(
                value: 1,
                page: ContactCustomerSupport(
                  customerWallets: widget.customerWallets, 
                  fullName: widget.fullName, 
                  token: widget.token,
                  lastTransactions: widget.lastTransactions,
                ),
                name: 'complaint',
                token: widget.token,
                fullName: widget.fullName,
                customerWallets: widget.customerWallets,
                lastTransactionsList: widget.lastTransactions,
                )
              )
            );
          },
          icon: Icon(
            Icons.menu,
            color: Colors.grey.shade600,
          ),
        ),
        title: Text(
          'Contact Customer Support',
          style: GoogleFonts.openSans(
            color: const Color(0xff091841),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff091841)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                  maxLines: 5,
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
                    onPressed: () {
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
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => HomeDrawer(
                                          value: 0,
                                          page: Dashboard(
                                            token: widget.token,
                                            fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactions: widget.lastTransactions,
                                          ),
                                          name: 'wallet',
                                          fullName: widget.fullName,
                                          token: widget.token, customerWallets: widget.customerWallets, lastTransactionsList: widget.lastTransactions,
                                        ),
                                      ),
                                    );
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
    );
  }
}
