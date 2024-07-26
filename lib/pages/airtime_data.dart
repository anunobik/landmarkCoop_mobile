import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_flutterwave.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/component/processing_airtime_request.dart';
import 'package:landmarkcoop_mobile_app/model/airtime_model.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/util/ProgressHUD.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

const iOSLocalizedLabels = false;

class AirtimePurchase extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const AirtimePurchase({
    Key? key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.lastTransactions,
  }) : super(key: key);

  @override
  State<AirtimePurchase> createState() => _AirtimePurchaseState();
}

class _AirtimePurchaseState extends State<AirtimePurchase> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController telController =
      TextEditingController(text: 'Instant Airtime');
  TextEditingController phoneController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  PhoneContact? _phoneContact;
  String phone = "";
  int amount = 0;
  bool _value = false;
  bool _enableSubmitBtn = false;
  bool isApiCallProcess = false;
  String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
  late String txRef;

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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Text(
                  'For All Networks',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xff000080),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  controller: telController,
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Network Provider',
                    hintStyle: GoogleFonts.montserrat(
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  controller: phoneController,
                  onSaved: (input) => phone = input!,
                  validator: (input) =>
                      input!.length < 11 ? "Phone No. is incomplete" : null,
                  decoration: InputDecoration(
                    labelText: 'Phone No.',
                    labelStyle: GoogleFonts.montserrat(
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
                    phone = phoneController.text;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  "Or select from phone contacts",
                  style: GoogleFonts.montserrat(
                    color: const Color(0xff000080),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final granted = await FlutterContactPicker.hasPermission();
                    granted
                        ? print('Granted')
                        : await FlutterContactPicker.requestPermission();
                    final PhoneContact contact =
                        await FlutterContactPicker.pickPhoneContact();
                    print(contact);
                    setState(() {
                      _phoneContact = contact;
                    });
                    setState(() {
                      phoneController.text =
                          _phoneContact!.phoneNumber!.number!;
                      phone = _phoneContact!.phoneNumber!.number!;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(CupertinoIcons.phone, color: Colors.white),
                  label: Text(
                    'Tap to choose from your phone contacts',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: amountController,
                  textAlign: TextAlign.center,
                  validator: (input) {
                    if (input!.isNotEmpty) {
                      double.parse(input) < 100
                          ? "Enter amt greater than vending amount - Min vending amt is NGN100"
                          : null;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: GoogleFonts.montserrat(
                      color: const Color(0xff9ca2ac),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefix: Container(
                      height: 14,
                      width: 14,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/pics/naira-black.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (text) {
                    amount = int.parse(amountController.text);
                    if (amount >= 100) {
                      setState(() {
                        _enableSubmitBtn = true;
                      });
                      print('input - $text is greater than 100');
                    } else {
                      setState(() {
                        _enableSubmitBtn = false;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                // SizedBox(
                //   height: 150,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: <Widget>[
                //       Text("Recent Payments",
                //         style: GoogleFonts.montserrat(
                //           fontWeight: FontWeight.w700,
                //         ),
                //       ),
                //       const SizedBox(height: 10),
                //       Expanded(
                //         child: ListView.builder(
                //           shrinkWrap: true,
                //           scrollDirection: Axis.horizontal,
                //           itemCount: airtimePurchaseList.length,
                //           itemBuilder: (context, index) {
                //             return GestureDetector(
                //               onTap: () {
                //                 setState(() {
                //                   phoneController.text = airtimePurchaseList[index]["phone_number"].toString();
                //                   amountController.text = airtimePurchaseList[index]["amount"].toString();
                //                 });
                //               },
                //               child: Container(
                //                 margin: const EdgeInsets.symmetric(horizontal: 15),
                //                 child: Column(
                //                   children: <Widget>[
                //                     Container(
                //                       height: 30,
                //                       width: 30,
                //                       decoration: BoxDecoration(
                //                         image: DecorationImage(
                //                           image: AssetImage(airtimePurchaseList[index]["network_image"].toString()),
                //                           fit: BoxFit.contain,
                //                         ),
                //                       ),
                //                     ),
                //                     const SizedBox(height: 5),
                //                     Text(airtimePurchaseList[index]["amount"].toString(),
                //                       style: GoogleFonts.montserrat(
                //                         fontSize: 15,
                //                         fontWeight: FontWeight.w600,
                //                       ),
                //                     ),
                //                     const SizedBox(height: 5),
                //                     Text(airtimePurchaseList[index]["phone_number"].toString(),
                //                       style: GoogleFonts.montserrat(
                //                         fontSize: 15,
                //                         fontWeight: FontWeight.w600,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             );
                //           }
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: !_enableSubmitBtn
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isApiCallProcess = true;
                            });
                            txRef =
                                "ozi_user.${phoneController.text.trim()}_$datePart";
                            InstantAirtimeAndDataRequestModel requestModel =
                                InstantAirtimeAndDataRequestModel(
                                    phoneNumber: phoneController.text.trim(),
                                    amount: amountController.text.trim(),
                                    transactionRef: txRef,
                                    requestType: 'Airtime');

                            APIService apiService = APIService();
                            if (widget.customerWallets[0].balance < amount) {
                              setState(() {
                                isApiCallProcess = false;
                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const AlertDialog(
                                      title: Text("Message"),
                                      content: Text("Insufficent Balance"),
                                    );
                                  });
                            } else {
                              apiService
                                  .instantAirtimeAndDataRequest(
                                      requestModel,
                                      widget.customerWallets[0].accountNumber,
                                      widget.token)
                                  .then((valueTransactionRes) {
                                if (valueTransactionRes.result) {
                                  rechargePhone(valueTransactionRes);
                                } else {
                                  setState(() {
                                    isApiCallProcess = false;
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const AlertDialog(
                                          title: Text("Notice"),
                                          content: Text(
                                              "Transaction not completed!"),
                                        );
                                      });
                                }
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 25),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  void rechargePhone(
      InstantAirtimeAndDataFeedbackResponseModel valueTransactionRes) {
    String displayDate = DateFormat('yyyy-MMM-dd').format(DateTime.now());
    FlutterWaveService apiFlutterWave = FlutterWaveService();
    AirtimeRequestModel airtimeRequestModel = AirtimeRequestModel(
        phoneNumber: valueTransactionRes.phoneNumber,
        amount: valueTransactionRes.amount,
        reference: valueTransactionRes.transactionRef);
    apiFlutterWave.buyAirtime(airtimeRequestModel, widget.token).then((value) {
      if (value == 'Successful') {
        setState(() {
          isApiCallProcess = false;
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ProcessingAirtimeRequest(
            customerWallets: widget.customerWallets,
            fullName: widget.fullName,
            token: widget.token,
            lastTransactions: widget.lastTransactions,
          ),
        ));
      } else {
        setState(() {
          isApiCallProcess = false;
        });

        //Todo reverse the debit amount
        APIService apiService2 = APIService();
        apiService2.reverseInstantAirtimeFeedback(
            valueTransactionRes.id, widget.token);

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Failed!"),
                content: Text(value),
              );
            });
      }
    });
  }
}
