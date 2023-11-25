import 'package:desalmcs_mobile_app/component/custom_text_form_field.dart';
import 'package:desalmcs_mobile_app/model/push_notification.dart';
import 'package:desalmcs_mobile_app/pushNotifications/push_messages.dart';
import 'package:desalmcs_mobile_app/util/home_drawer.dart';
import 'package:desalmcs_mobile_app/util/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';

import '../api/api_service.dart';
import '../model/bill_model.dart';

class AirtimeData extends StatefulWidget {
  final String fullName;
  final String token;
  const AirtimeData({Key? key, required this.fullName, required this.token})
      : super(key: key);

  @override
  State<AirtimeData> createState() => _AirtimeDataState();
}

class _AirtimeDataState extends State<AirtimeData> {
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  TextEditingController airtimeNumController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dataNumController = TextEditingController();
  String network = '';
  String currentNetwork = 'Select Network';
  List<String> networkList = [
    'Select Network',
    'MTN',
    'Airtel',
    'Glo',
    '9Mobile'
  ];

  late String itemCode;
  late String billerCode;
  APIService apiService = APIService();
  List<BillsResponseModel> dataMTN = <BillsResponseModel>[
    BillsResponseModel(
        item_code: 'Select Bundle',
        biller_code: 'Select Bundle',
        biller_name: 'Select Bundle',
        short_name: 'Select Bundle',
        amount: 0)
  ];
  List<BillsResponseModel> dataGlo = <BillsResponseModel>[
    BillsResponseModel(
        item_code: 'Select Bundle',
        biller_code: 'Select Bundle',
        biller_name: 'Select Bundle',
        short_name: 'Select Bundle',
        amount: 0)
  ];
  List<BillsResponseModel> data9Mobile = <BillsResponseModel>[
    BillsResponseModel(
        item_code: 'Select Bundle',
        biller_code: 'Select Bundle',
        biller_name: 'Select Bundle',
        short_name: 'Select Bundle',
        amount: 0)
  ];
  List<BillsResponseModel> dataAirtel = <BillsResponseModel>[
    BillsResponseModel(
        item_code: 'Select Bundle',
        biller_code: 'Select Bundle',
        biller_name: 'Select Bundle',
        short_name: 'Select Bundle',
        amount: 0)
  ];
  BillsResponseModel? currentMTNDataBundle;
  BillsResponseModel? currentGloDataBundle;
  BillsResponseModel? current9MobileDataBundle;
  BillsResponseModel? currentAirtelDataBundle;
  BillsResponseModel selectedDateBundle = BillsResponseModel(
      item_code: 'Select Bundle',
      biller_code: 'Select Bundle',
      biller_name: 'Select Bundle',
      short_name: 'Select Bundle',
      amount: 0);
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  BillsResponseModel? currentDataBundle;

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
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
            child: Column(
              children: <Widget>[
                Text(
                  "Buy AIRTIME",
                  style: GoogleFonts.openSans(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                CustomTextFormField(
                  keyboardType: TextInputType.phone,
                  controller: airtimeNumController,
                  hintText: 'Mobile Number',
                  enabled: true,
                ),
                const SizedBox(height: 10),
                FormField<String>(builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      isDense: true,
                      labelStyle: GoogleFonts.openSans(
                        color: const Color(0xff9ca2ac),
                      ),
                      errorStyle: GoogleFonts.openSans(
                        color: Colors.redAccent,
                      ),
                      hintText: 'Select Network',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    isEmpty: currentNetwork == "",
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        alignment: AlignmentDirectional.centerEnd,
                        value: currentNetwork,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            currentNetwork = newValue!;
                            state.didChange(newValue);
                          });

                          if (currentNetwork == 'MTN') {
                            itemCode = "AT099";
                            billerCode = "BIL099";
                          } else if (currentNetwork == 'Airtel') {
                            itemCode = "AT099";
                            billerCode = "BIL099";
                          } else if (currentNetwork == 'Glo') {
                            itemCode = "AT099";
                            billerCode = "BIL099";
                          } else if (currentNetwork == '9Mobile') {
                            itemCode = "AT099";
                            billerCode = "BIL099";
                          }
                        },
                        items: networkList
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                CustomTextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: amountController,
                  hintText: 'Enter Amount',
                  enabled: true,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // BuyAirtimeDataRequestModel airtimeBillsRequestModel =
                    // BuyAirtimeDataRequestModel(
                    //   biller_name: "AIRTIME",
                    //   mobile_no: airtimeNumController.text,
                    //   amount: amountController.text,
                    //   item_code: itemCode,
                    //   biller_code: billerCode
                    // );

                    // BillsRequestModel billsRequestModel =
                    // BillsRequestModel(
                    //     biller_name: "AIRTIME",
                    //     uniqueNo: airtimeNumController.text,
                    //     amount: amountController.text,
                    //     item_code: itemCode,
                    //     biller_code: billerCode
                    // );

                    // apiService
                    //     .buyAirtimeAndData(airtimeBillsRequestModel, 'Airtime', widget.token, context)
                    //     .then((value) {

                    //   Navigator.of(context).push(MaterialPageRoute(
                    //       builder: (context) => VerifyDetails(
                    //             verificationType: 'Airtime',
                    //             token: widget.token,
                    //             transactionIdResponseModel: value, billsRequestModel: billsRequestModel,
                    //           )));
                    // });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Text("Continue",
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                const SizedBox(height: 20),

                //  BUY DATA

                Text(
                  "Buy Data",
                  style: GoogleFonts.openSans(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          network = 'MTN';
                        });
                      },
                      child: Container(
                        height: height * 0.0768,
                        width: height * 0.0768,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: network == 'MTN'
                                  ? Colors.grey.shade500
                                  : Colors.transparent,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/mtn.jpg'),
                              fit: BoxFit.contain,
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          network = 'Glo';
                        });
                      },
                      child: Container(
                        height: height * 0.0768,
                        width: height * 0.0768,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: network == 'Glo'
                                  ? Colors.grey.shade400
                                  : Colors.transparent,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/glo.png'),
                              fit: BoxFit.contain,
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          network = '9Mobile';
                        });
                      },
                      child: Container(
                        height: height * 0.0768,
                        width: height * 0.0768,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: network == '9Mobile'
                                  ? Colors.grey.shade400
                                  : Colors.transparent,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/9mobile.jpg'),
                              fit: BoxFit.contain,
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          network = 'Airtel';
                        });
                      },
                      child: Container(
                        height: height * 0.0768,
                        width: height * 0.0768,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: network == 'Airtel'
                                  ? Colors.grey.shade400
                                  : Colors.transparent,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/airtel.jpg'),
                              fit: BoxFit.contain,
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$network Internet Data',
                  style: GoogleFonts.openSans(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextFormField(
                  keyboardType: TextInputType.phone,
                  controller: dataNumController,
                  hintText: 'Mobile Number',
                  enabled: true,
                ),
                const SizedBox(height: 10),
                dataBundleListBuilder(),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // BuyAirtimeDataRequestModel dataBillsRequestModel =
                    // BuyAirtimeDataRequestModel(
                    //   biller_name: currentDataBundle!.biller_name,
                    //   mobile_no: dataNumController.text,
                    //   amount: currentDataBundle!.amount.toString(),
                    //   item_code: currentDataBundle!.item_code,
                    //   biller_code: currentDataBundle!.biller_code,
                    // );

                    // BillsRequestModel billsRequestModel =
                    // BillsRequestModel(
                    //   biller_name: currentDataBundle!.biller_name,
                    //   uniqueNo: dataNumController.text,
                    //   amount: currentDataBundle!.amount.toString(),
                    //   item_code: currentDataBundle!.item_code,
                    //   biller_code: currentDataBundle!.biller_code,
                    // );
                    // print(dataBillsRequestModel.toJson());
                    // apiService
                    //     .buyAirtimeAndData(dataBillsRequestModel, 'Data', widget.token, context)
                    //     .then((value) {
                    //   if(value.status != '') {
                    //     Navigator.of(context).push(MaterialPageRoute(
                    //         builder: (context) =>
                    //             VerifyDetails(
                    //               verificationType: 'Data',
                    //               token: widget.token,
                    //               transactionIdResponseModel: value,
                    //               billsRequestModel: billsRequestModel,
                    //             )));
                    //   }
                    // });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Text("Continue",
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget dataBundleListBuilder() {
    List<BillsResponseModel> dataTo = <BillsResponseModel>[
      BillsResponseModel(
          item_code: 'Select Bundle',
          biller_code: 'Select Bundle',
          biller_name: 'Select Bundle',
          short_name: 'Select Bundle',
          amount: 0)
    ];

    switch(network){
      case 'MTN':
        dataTo = dataMTN;
        currentDataBundle = currentMTNDataBundle;
        break;
      case 'Glo':
        dataTo = dataGlo;
        currentDataBundle = currentGloDataBundle;
        break;
      case '9Mobile':
        dataTo = data9Mobile;
        currentDataBundle = current9MobileDataBundle;
        break;
      case 'Airtel':
        dataTo = dataAirtel;
        currentDataBundle = currentAirtelDataBundle;
        break;
    }
    return FormField<BillsResponseModel>(
        builder: (FormFieldState<BillsResponseModel> state) {
          return InputDecorator(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              labelStyle: GoogleFonts.openSans(
                color: const Color(0xff9ca2ac),
              ),
              errorStyle: GoogleFonts.openSans(
                color: Colors.redAccent,
              ),
              hintText: 'Select Bundle',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BillsResponseModel>(
                alignment: AlignmentDirectional.centerEnd,
                value: currentDataBundle,
                isDense: true,
                isExpanded: true,
                onChanged: (newValue) {
                  setState(() {
                    switch(network){
                      case 'MTN':
                        currentMTNDataBundle = newValue!;
                        break;
                      case 'Glo':
                        currentGloDataBundle = newValue!;
                        break;
                      case '9Mobile':
                        current9MobileDataBundle = newValue!;
                        break;
                      case 'Airtel':
                        currentAirtelDataBundle = newValue!;
                        break;
                    }
                    state.didChange(newValue);
                  });
                },
                items: dataTo
                    .map((map) => DropdownMenuItem<BillsResponseModel>(
                  value: map,
                  child: Center(child: Text(map.biller_name + ' -> NGN' + map.amount.toString(), overflow: TextOverflow.ellipsis,)),
                ))
                    .toList(),
              ),
            ),
          );
        });
  }
}
