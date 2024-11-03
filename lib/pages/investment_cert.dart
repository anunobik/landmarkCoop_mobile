import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/pages/certificate_of_investment.dart';
import 'package:landmarkcoop_mobile_app/pushNotifications/push_messages.dart';
import 'package:landmarkcoop_mobile_app/util/ProgressHUD.dart';
import 'package:landmarkcoop_mobile_app/util/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';

class InvestmentCert extends StatefulWidget {
  final String fullName;
  final String token;
  const InvestmentCert(
      {super.key,
      required this.fullName,
      required this.token});

  @override
  State<InvestmentCert> createState() => _InvestmentCertState();
}

class _InvestmentCertState extends State<InvestmentCert> {
  APIService apiService = APIService();
  bool isApiCallProcess = false;
  CustomerInvestmentWalletModel? currentWallet;
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  List<dynamic> itemData = [];
  List<CustomerInvestmentWalletModel> data = <CustomerInvestmentWalletModel>[
    CustomerInvestmentWalletModel(
      id: 0,
      amount: 0,
      accountNumber: 'Select Account',
      instruction: 0,
      interest: 0,
      fullName: 'Select Account',
      maturityAmount: 0,
      maturityTime: 'Select Account',
      rate: 0,
      tenor: 0,
      timeCreated: 'Select Account',
      wht: 0, displayName: 'Select Account',)
  ];

  @override
  void initState() {
    super.initState();
    getAllInvestment();
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
  }

  getAllInvestment(){
    return apiService.allInvestments(widget.token).then((value){
      currentWallet = data[0];
      for (var singleData in value) {
        data.add(singleData);
      }
      setState(() {
        data;
      });
    });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Investment Certificate',
          style: GoogleFonts.openSans(
            color: const Color(0xff091841),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff091841)),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(children: <Widget>[
          dropDownWallets(),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CertificateOfInvestment(customerInvestmentWalletModel: currentWallet!),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 10),
              child: Text(
                "View",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget dropDownWallets() {
    return FormField<CustomerInvestmentWalletModel>(
        builder: (FormFieldState<CustomerInvestmentWalletModel> state) {
          return InputDecorator(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              labelStyle: GoogleFonts.montserrat(
                color: const Color(0xff9ca2ac),
              ),
              errorStyle: GoogleFonts.montserrat(
                color: Colors.redAccent,
              ),
              hintText: 'Select Wallet',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            // isEmpty: currentWallet.biller_code == "",
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CustomerInvestmentWalletModel>(
                alignment: AlignmentDirectional.centerEnd,
                value: currentWallet,
                isDense: true,
                isExpanded: true,
                onChanged: (newValue) {
                  setState(() {
                    currentWallet = newValue!;
                    state.didChange(newValue);
                  });
                },
                items: data
                    .map((map) => DropdownMenuItem<CustomerInvestmentWalletModel>(
                  value: map,
                  child: Center(child: Text(map.accountNumber)),
                ))
                    .toList(),
              ),
            ),
          );
        });
  }
  
}
