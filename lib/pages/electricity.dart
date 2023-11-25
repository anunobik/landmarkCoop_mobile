import 'package:desalmcs_mobile_app/api/api_service.dart';
import 'package:desalmcs_mobile_app/component/custom_text_form_field.dart';
import 'package:desalmcs_mobile_app/model/push_notification.dart';
import 'package:desalmcs_mobile_app/pushNotifications/push_messages.dart';
import 'package:desalmcs_mobile_app/util/ProgressHUD.dart';
import 'package:desalmcs_mobile_app/util/home_drawer.dart';
import 'package:desalmcs_mobile_app/util/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';

class Electricity extends StatefulWidget {
  final String fullName;
  final String token;
  const Electricity({Key? key, required this.fullName, required this.token})
      : super(key: key);

  @override
  State<Electricity> createState() => _ElectricityState();
}

class _ElectricityState extends State<Electricity> {
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  String biller = 'Eko';
  String currentBiller = 'EKO DISCO ELECTRICITY';
  List<String> billerList = [
    'EKO DISCO ELECTRICITY',
    'IKEDC',
    'IBADAN DISCO ELECTRICITY',
    'ENUGU DISCO ELECTRICITY',
    'SPHC DISCO',
    'BENIN DISCO ELECTRICITY',
    'YOLA DISCO ELECTRICITY',
    'KANO DISCO',
    'KPLC'
  ];
  String currentMeterType = '--Select Meter Type--';
  List<String> meterTypeList = ['--Select Meter Type--', 'PREPAID', 'POSTPAID'];
  TextEditingController meterController = TextEditingController();
  TextEditingController amtController = TextEditingController();
  // late ElectricityRequestModel electricityRequestModel;
  APIService apiService = APIService();
  bool isApiCallProcess = false;

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
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
            child: Column(
              children: <Widget>[
                Text(
                  'Electricity Billers',
                  style: GoogleFonts.openSans(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 15),
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
                      hintText: 'EKO DISCO ELECTRICITY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    isEmpty: currentBiller == "",
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        alignment: AlignmentDirectional.centerEnd,
                        value: currentBiller,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            currentBiller = newValue!;
                            state.didChange(newValue);
                          });
                          for (var disco in billerList) {
                            if (disco == currentBiller) {
                              setState(() {
                                biller = disco.trim().split(' ')[0];
                              });
                            }
                          }
                        },
                        items: billerList
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
                  '$biller Electric Payment',
                  style: GoogleFonts.openSans(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 15),
                CustomTextFormField(
                  keyboardType: TextInputType.number,
                  controller: meterController,
                  hintText: 'Meter Number',
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
                      hintText: '--Select Meter Type--',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    isEmpty: currentMeterType == "",
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        alignment: AlignmentDirectional.centerEnd,
                        value: currentMeterType,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            currentMeterType = newValue!;
                            state.didChange(newValue);
                          });

                          // switch (currentBiller) {
                          //   case 'EKO DISCO ELECTRICITY':
                          //     electricityRequestModel.biller_code = 'BIL112';
                          //     if (currentMeterType == 'PREPAID') {
                          //       electricityRequestModel.item_code = 'UB157';
                          //       electricityRequestModel.biller_name =
                          //           'EKEDC PREPAID TOPUP';
                          //     } else {
                          //       electricityRequestModel.item_code = 'UB158';
                          //       electricityRequestModel.biller_name =
                          //           'EKEDC POSTPAID TOPUP';
                          //     }
                          //     break;
                          //   case 'IKEDC':
                          //     electricityRequestModel.biller_code = 'BIL113';
                          //     if (currentMeterType == 'PREPAID') {
                          //       electricityRequestModel.item_code = 'UB159';
                          //       electricityRequestModel.biller_name =
                          //           'IKEDC  PREPAID';
                          //     } else {
                          //       electricityRequestModel.item_code = 'UB160';
                          //       electricityRequestModel.biller_name =
                          //           'IKEDC  POSTPAID';
                          //     }
                          //     break;
                          //   case 'IBADAN DISCO ELECTRICITY':
                          //     electricityRequestModel.biller_code = 'BIL114';
                          //     if (currentMeterType == 'PREPAID') {
                          //       electricityRequestModel.item_code = 'UB161';
                          //       electricityRequestModel.biller_name =
                          //           'IBADAN DISCO ELECTRICITY PREPAID';
                          //     } else {
                          //       electricityRequestModel.item_code = 'UB162';
                          //       electricityRequestModel.biller_name =
                          //           'IBADAN DISCO ELECTRICITY POSTPAID';
                          //     }
                          //     break;
                          //   case 'ENUGU DISCO ELECTRICITY':
                          //     electricityRequestModel.biller_code = 'BIL115';
                          //     if (currentMeterType == 'PREPAID') {
                          //       electricityRequestModel.item_code = 'UB163';
                          //       electricityRequestModel.biller_name =
                          //           'ENUGU DISCO ELECTRIC BILLS PREPAID TOPUP';
                          //     } else {
                          //       electricityRequestModel.item_code = 'UB164';
                          //       electricityRequestModel.biller_name =
                          //           'ENUGU DISCO ELECTRIC BILLS POSTPAID TOPUP';
                          //     }
                          //     break;
                          //   case 'SPHC DISCO':
                          //     electricityRequestModel.biller_code = 'BIL116';
                          //     if (currentMeterType == 'PREPAID') {
                          //       electricityRequestModel.item_code = 'UB165';
                          //       electricityRequestModel.biller_name =
                          //           'PHC DISCO POSTPAID TOPUP';
                          //     } else {
                          //       electricityRequestModel.item_code = 'UB165';
                          //       electricityRequestModel.biller_name =
                          //           'PHC DISCO POSTPAID TOPUP';
                          //     }
                          //     break;
                          //   case 'BENIN DISCO ELECTRICITY':
                          //     electricityRequestModel.biller_code = 'BIL117';
                          //     if (currentMeterType == 'POSTPAID') {
                          //       electricityRequestModel.item_code = 'UB166';
                          //       electricityRequestModel.biller_name =
                          //           'BENIN DISCO POSTPAID TOPUP';
                          //     } else {
                          //       electricityRequestModel.item_code = 'UB167';
                          //       electricityRequestModel.biller_name =
                          //           'BENIN DISCO PREPAID TOPUP';
                          //     }
                          //     break;
                          //   case 'YOLA DISCO ELECTRICITY':
                          //     electricityRequestModel.biller_code = 'BIL118';
                          //     if (currentMeterType == 'PREPAID') {
                          //       electricityRequestModel.item_code = 'UB168';
                          //       electricityRequestModel.biller_name =
                          //           'YOLA DISCO TOPUP';
                          //     } else {
                          //       electricityRequestModel.item_code = 'UB168';
                          //       electricityRequestModel.biller_name =
                          //           'YOLA DISCO TOPUP';
                          //     }
                          //     break;
                          //   case 'KANO DISCO':
                          //     electricityRequestModel.biller_code = 'BIL120';
                          //     if (currentMeterType == 'PREPAID') {
                          //       electricityRequestModel.item_code = 'UB169';
                          //       electricityRequestModel.biller_name =
                          //           'KANO DISCO PREPAID TOPUP';
                          //     } else {
                          //       electricityRequestModel.item_code = 'UB170';
                          //       electricityRequestModel.biller_name =
                          //           'KANO DISCO POSTPAID TOPUP';
                          //     }
                          //     break;
                          //   case 'KPLC':
                          //     electricityRequestModel.biller_code = 'BIL191';
                          //     if (currentMeterType == 'PREPAID') {
                          //       electricityRequestModel.item_code = 'UB501';
                          //       electricityRequestModel.biller_name =
                          //           'KPLC PREPAID';
                          //     } else {
                          //       electricityRequestModel.item_code = 'UB502';
                          //       electricityRequestModel.biller_name =
                          //           'KPLC POSTPAID';
                          //     }
                          //     break;
                          //   default:
                          //     electricityRequestModel.biller_code = 'BIL112';
                          //     break;
                          // }
                        },
                        items: meterTypeList
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
                  controller: amtController,
                  hintText: 'Enter Amount',
                  enabled: true,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    // setState((){
                    //   isApiCallProcess = true;
                    // });
                    // electricityRequestModel.meter_no = meterController.text;
                    // electricityRequestModel.amount = amtController.text;

                    // BillsRequestModel billsRequestModel = BillsRequestModel(
                    //   biller_name: electricityRequestModel.biller_name,
                    //   uniqueNo: electricityRequestModel.meter_no,
                    //   amount: electricityRequestModel.amount,
                    //   item_code: electricityRequestModel.item_code,
                    //   biller_code: electricityRequestModel.biller_code,
                    // );

                    // apiService
                    //     .validateBillsRequest(
                    //         widget.token,
                    //         electricityRequestModel.item_code,
                    //         electricityRequestModel.biller_code,
                    //         electricityRequestModel.meter_no,
                    //         context)
                    //     .then((value) {
                    //   setState((){
                    //     isApiCallProcess = false;
                    //   });
                    //   if (value.response_message == "Successful") {
                    //     Navigator.of(context).push(MaterialPageRoute(
                    //         builder: (context) =>
                    //             ValidateBills(
                    //               verificationType: 'Electricity',
                    //               token: widget.token,
                    //               billsRequestModel: billsRequestModel,
                    //               billsValidationResponseModel: value,
                    //               electricityRequestModel:
                    //               electricityRequestModel,
                    //             )));
                    //   }else{
                    //     failTransactionAlert(value.response_message);
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
                    child: Text("Validate",
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

  failTransactionAlert(String message) {
    setState(() {
      isApiCallProcess = false;
    });
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Container(
                height: 50,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15),
                color: Colors.blue.shade200,
                child: Text(
                  'Message',
                  style: GoogleFonts.openSans(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              content:
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Center(
                  child: Text(
                    'Notice',
                    style: GoogleFonts.openSans(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    message,
                    style: GoogleFonts.openSans(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ]),
              actionsAlignment: MainAxisAlignment.start,
              actions: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isApiCallProcess = false;
                      });
                      Navigator.of(context).pop();
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
                        "Ok",
                        style: GoogleFonts.openSans(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }

}
