import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_flutterwave.dart';
import '../api/api_service.dart';
import '../component/processing_airtime_request.dart';
import '../model/airtime_model.dart';
import '../model/customer_model.dart';
import '../utils/ProgressHUD.dart';
import 'package:intl/intl.dart';

const iOSLocalizedLabels = false;

class AirtimePurchase extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const AirtimePurchase({
    Key? key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
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
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
  List<Contact>? _contacts;
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
                    // color: const Color(0xff000080),
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
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    Contact? contact = await _contactPicker.selectPhoneNumber();
                    print(contact);
                    setState(() {
                      _contacts = contact == null ? null : [contact];
                    });
                    setState(() {
                      phoneController.text = contact!.selectedPhoneNumber!;
                      phone = contact!.selectedPhoneNumber!;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(CupertinoIcons.phone, color: Colors.white),
                  label: Text(
                    'Tap to choose from your phone contacts',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.black),
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
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: !_enableSubmitBtn
                      ? null
                      : () async {
                          final prefs = await SharedPreferences.getInstance();
                          String subdomain = prefs.getString('subdomain') ??
                              'https://core.landmarkcooperative.org';
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isApiCallProcess = true;
                            });
                            txRef =
                                "${phoneController.text.trim()}_$datePart";
                            InstantAirtimeAndDataRequestModel requestModel =
                                InstantAirtimeAndDataRequestModel(
                                    phoneNumber: phoneController.text.trim(),
                                    amount: amountController.text.trim(),
                                    transactionRef: txRef,
                                    requestType: 'Airtime');

                            APIService apiService =
                                APIService(subdomain_url: subdomain);
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
                                  requestModel, widget.customerWallets[0].accountNumber, widget.token)
                                  .then((valueTransactionRes) {
                                if (valueTransactionRes.result) {
                                  rechargePhone(valueTransactionRes, subdomain);
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
                    backgroundColor: Color.fromRGBO(49, 88, 203, 1.0),
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
                        color: Colors.black,
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
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
      InstantAirtimeAndDataFeedbackResponseModel valueTransactionRes, String subdomain) {
    String displayDate = DateFormat('yyyy-MMM-dd').format(DateTime.now());
    FlutterWaveService apiFlutterWave = FlutterWaveService();
    AirtimeRequestModel airtimeRequestModel = AirtimeRequestModel(phoneNumber: valueTransactionRes.phoneNumber, amount: valueTransactionRes.amount, reference: valueTransactionRes.transactionRef);
    print(airtimeRequestModel.toJson());
    apiFlutterWave.buyAirtime(airtimeRequestModel, widget.token).then((value) {
      if (value == 'Successful') {
        setState(() {
          isApiCallProcess = false;
        });
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ProcessingAirtimeRequest(customerWallets: widget.customerWallets, fullName: widget.fullName, token: widget.token, subdomain: subdomain,),)
        );
      } else {
        setState(() {
          isApiCallProcess = false;
        });

        //Todo reverse the debit amount
        APIService apiService2 = APIService(subdomain_url: subdomain);
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
