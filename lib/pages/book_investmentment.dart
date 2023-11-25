import 'package:desalmcs_mobile_app/api/api_service.dart';
import 'package:desalmcs_mobile_app/component/custom_text_form_field.dart';
import 'package:desalmcs_mobile_app/model/customer_model.dart';
import 'package:desalmcs_mobile_app/model/push_notification.dart';
import 'package:desalmcs_mobile_app/pushNotifications/push_messages.dart';
import 'package:desalmcs_mobile_app/util/ProgressHUD.dart';
import 'package:desalmcs_mobile_app/util/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';

class BookInvestment extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  const BookInvestment(
      {Key? key,
      required this.customerWallets,
      required this.fullName,
      required this.token})
      : super(key: key);

  @override
  State<BookInvestment> createState() => _BookInvestmentState();
}

class _BookInvestmentState extends State<BookInvestment> {
  APIService apiService = APIService();
  bool isApiCallProcess = false;
  CustomerWalletsBalanceModel? selectedWallet;
  List<dynamic> itemData = [];
  TextEditingController amountController = TextEditingController();
  List<String> tenorList = ['Select Tenor (Months)', '3', '6', '12', '24'];
  List<String> instructionList = [
    'Select Instruction',
    'Interest drops monthly',
    'Roll-Over Principal Only and Redeem Interest',
    'Roll-Over Principal and Interest',
    'Redeem Principal and Interest'
  ];
  String currentTenor = "Select Tenor (Months)";
  String currentInstruction = 'Select Instruction';
  TextEditingController rateController = TextEditingController();
  late String instructionInt;
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  List<CustomerWalletsBalanceModel> data = <CustomerWalletsBalanceModel>[
    CustomerWalletsBalanceModel(
        id: 0,
        accountNumber: 'Select Account',
        balance: 0,
        productName: '',
        fullName: '',
        email: '',
        phoneNo: '',
        nubanAccountNumber: '',
        interBankName: ''
    )
  ];
  CustomerWalletsBalanceModel? currentWallet;

  @override
  void initState() {
    super.initState();
    loadAccountAccounts();
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


  loadAccountAccounts() {
    currentWallet = data[0];
    for (var singleData in widget.customerWallets) {
      data.add(singleData);
    }
    setState(() {
      data;
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
          'Book Investment',
          style: GoogleFonts.openSans(
            color: const Color(0xff091841),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff091841)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(children: <Widget>[
            const SizedBox(height: 20),
            dropDownWallets(),
            const SizedBox(height: 15),
            CustomTextFormField(
              keyboardType: TextInputType.number,
              controller: amountController,
              hintText: "Amount",
              enabled: true,
            ),
            const SizedBox(height: 15),
            FormField<String>(builder: (FormFieldState<String> state) {
              return InputDecorator(
                decoration: InputDecoration(
                  isDense: true,
                  labelStyle: GoogleFonts.montserrat(
                    color: const Color(0xff9ca2ac),
                  ),
                  errorStyle: GoogleFonts.montserrat(
                    color: Colors.redAccent,
                  ),
                  hintText: 'Select Tenor (Months)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                isEmpty: currentTenor == "",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    alignment: AlignmentDirectional.centerEnd,
                    value: currentTenor,
                    isDense: true,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        currentTenor = newValue!;
                        state.didChange(newValue);
                      });
                      switch(currentTenor){
                        case '3':
                          rateController = TextEditingController(text: '20');
                          break;
                        case '6':
                          rateController = TextEditingController(text: '15');
                          break;
                        case '12':
                          rateController = TextEditingController(text: '40');
                          break;
                        case '24':
                          rateController = TextEditingController(text: '100');
                          break;
                      }
                    },
                    items: tenorList
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Center(child: Text(value)),
                            ))
                        .toList(),
                  ),
                ),
              );
            }),
            const SizedBox(height: 15),
            const Text('Rate', style: TextStyle(fontWeight: FontWeight.bold),),
            CustomTextFormField(
              keyboardType: TextInputType.number,
              controller: rateController,
              hintText: "",
              enabled: false,
            ),
            const SizedBox(height: 15),
            FormField<String>(builder: (FormFieldState<String> state) {
              return InputDecorator(
                decoration: InputDecoration(
                  isDense: true,
                  labelStyle: GoogleFonts.montserrat(
                    color: const Color(0xff9ca2ac),
                  ),
                  errorStyle: GoogleFonts.montserrat(
                    color: Colors.redAccent,
                  ),
                  hintText: 'Select Instruction',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                isEmpty: currentInstruction == "",
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    alignment: AlignmentDirectional.centerEnd,
                    value: currentInstruction,
                    isExpanded: true,
                    isDense: true,
                    onChanged: (newValue) {
                      setState(() {
                        currentInstruction = newValue!;
                        state.didChange(newValue);
                      });
                      switch(currentInstruction){
                        case 'Roll-Over Principal Only and Redeem Interest':
                          instructionInt = '1';
                          break;
                        case 'Roll-Over Principal and Interest':
                          instructionInt = '2';
                          break;
                        case 'Redeem Principal and Interest':
                          instructionInt = '3';
                          break;
                        case 'Interest drops monthly':
                          instructionInt = '4';
                          break;
                        default:
                          instructionInt = '4';
                          break;
                      }
                    },
                    items: instructionList
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Center(child: Text(value, overflow: TextOverflow.ellipsis,)),
                            ))
                        .toList(),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                if(double.parse(amountController.text) > 50000){
                  setState(() {
                    isApiCallProcess = true;
                  });
                  apiService.bookInvestment(selectedWallet!.accountNumber, amountController.text,
                      int.parse(currentTenor), double.parse(rateController.text), int.parse(instructionInt), widget.token).then((value) {
                    setState(() {
                      isApiCallProcess = false;
                    });
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
                            content: Text(value),
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
                  });
                }else{
                  setState(() {
                    isApiCallProcess = false;
                  });
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text("Notice"),
                          content: Text("Amount must be greater than NGN100,000"),
                        );
                      });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 10),
                child: Text(
                  "Book",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget dropDownWallets() {
    return FormField<CustomerWalletsBalanceModel>(
        builder: (FormFieldState<CustomerWalletsBalanceModel> state) {
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
              child: DropdownButton<CustomerWalletsBalanceModel>(
                alignment: AlignmentDirectional.centerEnd,
                value: currentWallet,
                isDense: true,
                isExpanded: true,
                onChanged: (newValue) {
                  setState(() {
                    currentWallet = newValue!;
                    state.didChange(newValue);
                    selectedWallet = newValue;
                  });
                },
                items: data
                    .map((map) => DropdownMenuItem<CustomerWalletsBalanceModel>(
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
