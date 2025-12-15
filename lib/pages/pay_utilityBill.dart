import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/api/api_flutterwave.dart';
import 'package:landmarkcoop_latest/api/api_service.dart';
import 'package:landmarkcoop_latest/component/processing_utility.dart';
import 'package:landmarkcoop_latest/model/airtime_model.dart';
import 'package:landmarkcoop_latest/model/cable_tv_model.dart';
import 'package:landmarkcoop_latest/model/customer_model.dart';
import 'package:landmarkcoop_latest/utils/ProgressHUD.dart';
import 'package:landmarkcoop_latest/widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

Future<Object?> payUtilityBills(
    BuildContext context, {
      required ValueChanged onClosed,
      required String fullName,
      required String token,
      required List<BillsInfoResponseModel> billsList,
      required List<CustomerWalletsBalanceModel> customerWallets,
    }) {
  bool isApiCallProcess = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController meterNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isDisabled = true;
  late FocusNode focusNode;
  late FocusNode focusNode2;
  BillsInfoResponseModel? selectedCableTv;
  bool validated = false;
  String? cardName;
  late String txRef;
  String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
  bool displayAmountAndMeter = false;

  return showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: 'Electricity Payment',
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (context, animation, __, child) {
      Tween<Offset> tween;
      tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
      return SlideTransition(
        position: tween.animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
    context: context,
    pageBuilder: (context, _, __) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        void enableButton() {
          meterNumberController.text.isEmpty
              ? setState(() {
            isDisabled = true;
          })
              : setState(() {
            isDisabled = false;
          });
        }

        focusNode = FocusNode();
        focusNode.addListener(() => setState(() {}));

        focusNode2 = FocusNode();
        focusNode2.addListener(() => setState(() {}));

        return ProgressHUD(
          inAsyncCall: isApiCallProcess,
          opacity: 0.3,
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                height: 620,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            Text('Electricity Bills Payment',
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xff000080),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<BillsInfoResponseModel>(
                              value: selectedCableTv,
                              hint: Text('Select Bills'),
                              items: billsList
                                  .map((BillsInfoResponseModel billsPay) {
                                return DropdownMenuItem<BillsInfoResponseModel>(
                                  value: billsPay,
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: 200),
                                    child: Text(
                                      billsPay.name,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (BillsInfoResponseModel? newValue) {
                                setState(() {
                                  selectedCableTv = newValue;
                                  displayAmountAndMeter = true;
                                });
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                  const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                  const BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            displayAmountAndMeter ?
                            AnimatedContainer(
                              duration: const Duration(seconds: 1),
                              decoration: focusNode.hasFocus
                                  ? BoxDecoration(
                                boxShadow: const [BoxShadow(blurRadius: 6)],
                                borderRadius: BorderRadius.circular(20),
                              )
                                  : BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                controller: amountController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Amount (NGN)',
                                  hintStyle: GoogleFonts.montserrat(
                                    color: const Color(0xff9ca2ac),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                    const BorderSide(color: Colors.red),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                    const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                    const BorderSide(color: Colors.blue),
                                  ),
                                ),
                                // onTap: enableButton,
                              ),
                            ) : Container(),
                            SizedBox(height: 15,),
                            displayAmountAndMeter ?
                            AnimatedContainer(
                              duration: const Duration(seconds: 1),
                              decoration: focusNode2.hasFocus
                                  ? BoxDecoration(
                                boxShadow: const [BoxShadow(blurRadius: 6)],
                                borderRadius: BorderRadius.circular(20),
                              )
                                  : BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                controller: meterNumberController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Meter No.',
                                  hintStyle: GoogleFonts.montserrat(
                                    color: const Color(0xff9ca2ac),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                    const BorderSide(color: Colors.red),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                    const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                    const BorderSide(color: Colors.blue),
                                  ),
                                ),
                                onTap: enableButton,
                              ),
                            ) : Container(),
                            SizedBox(height: 10,),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    validated = true;
                                    cardName = 'Please wait...';
                                  });
                                  FlutterWaveService flutterWaveService =
                                  FlutterWaveService();
                                  try {
                                    flutterWaveService
                                        .validateFlutterwaveBill(
                                        selectedCableTv!.itemCode,
                                        selectedCableTv!.billerCode,
                                        meterNumberController.text.trim(), token)
                                        .then((value) {
                                      if (value.name.isNotEmpty) {
                                        setState(() {
                                          validated = true;
                                          cardName = value.name;
                                        });
                                      } else {
                                        setState(() {
                                          validated = true;
                                          cardName = value.response_message;
                                        });
                                      }
                                    });
                                  } catch (ex) {
                                    setState(() {
                                      validated = true;
                                      cardName =
                                      'Ensure meter no. is entered';
                                    });
                                  }
                                },
                                child: Text(
                                  'Click to validate Meter No.',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            validated
                                ? Center(
                              child: Text(
                                cardName!,
                                style: GoogleFonts.montserrat(),
                                textAlign: TextAlign.center,
                              ),
                            )
                                : Container(),
                            const SizedBox(height: 30),
                            isApiCallProcess
                                ? const Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue),
                              ),
                            )
                                : ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isApiCallProcess = true;
                                });
                                final prefs =
                                await SharedPreferences.getInstance();
                                String subdomain =
                                    prefs.getString('subdomain') ??
                                        'https://core.landmarkcooperative.org';

                                APIService apiService =
                                APIService(subdomain_url: subdomain);
                                txRef =
                                "${meterNumberController.text.trim()}_$datePart";
                                InstantAirtimeAndDataRequestModel
                                instantAirtimeAndDataRequestModel =
                                InstantAirtimeAndDataRequestModel(
                                  phoneNumber: meterNumberController.text,
                                  amount: amountController.text,
                                  requestType: "Utility Bills",
                                  transactionRef: txRef,
                                );
                                if (customerWallets[0].balance <
                                    selectedCableTv!.amount) {
                                  setState(() {
                                    isApiCallProcess = false;
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const AlertDialog(
                                          title: Text("Message"),
                                          content:
                                          Text("Insufficient Balance"),
                                        );
                                      });
                                } else {
                                  apiService
                                      .instantAirtimeAndDataRequest(
                                      instantAirtimeAndDataRequestModel,
                                      customerWallets[0].accountNumber,
                                      token)
                                      .then((valueTransactionRes) {
                                    setState(() {
                                      isApiCallProcess = false;
                                    });
                                    if (valueTransactionRes.result) {
                                      payBills(
                                          selectedCableTv!,
                                          valueTransactionRes,
                                          subdomain,
                                          context,
                                          fullName,
                                          token,
                                          customerWallets);
                                    } else {
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
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(49, 88, 203, 1.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Submit",
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -48,
                        child: GestureDetector(
                          onTap: () async{
                            final prefs = await SharedPreferences.getInstance();
                            String subdomain =
                                prefs.getString('subdomain') ?? 'core.landmarkcooperative.org';

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => BottomNavBar(
                                pageIndex: 0,
                                fullName: fullName,
                                token: token,
                                subdomain: subdomain,
                                customerWallets: customerWallets,
                                phoneNumber: customerWallets[0].phoneNo,
                              ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
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
      },
    ),
  ).then((onClosed));
}

void payBills(
    BillsInfoResponseModel selectedCableTv,
    InstantAirtimeAndDataFeedbackResponseModel valueTransactionRes,
    String subdomain,
    BuildContext context,
    String fullName,
    String token,
    List<CustomerWalletsBalanceModel> customerWallets) {
  String displayDate = DateFormat('yyyy-MMM-dd').format(DateTime.now());
  FlutterWaveService apiFlutterWave = FlutterWaveService();
  DataBundleRequestModel dataBundleRequestModel = DataBundleRequestModel(
    phoneNumber: valueTransactionRes.phoneNumber,
    amount: valueTransactionRes.amount,
    billerName: selectedCableTv.billerName,
    reference: valueTransactionRes.transactionRef,
  );
  apiFlutterWave
      .buyDataBundle(
      dataBundleRequestModel, selectedCableTv.billerCode, selectedCableTv.itemCode, token)
      .then((BillsPaymentResponse value) {
    if (value.status == 'success') {
      // Navigate to ProcessingAirtimeRequest on success
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ProcessingUtilityRequest(
          customerWallets: customerWallets,
          fullName: fullName,
          token: token,
          subdomain: subdomain, rechargeToken: value.data.rechargeToken!,
        ),
      ));
    } else {
      // Reverses the debit amount if status isn't successful
      APIService apiService2 = APIService(subdomain_url: subdomain);
      apiService2.reverseInstantAirtimeFeedback(valueTransactionRes.id, token);

      // Display the error in a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Failed!"),
            content: Text("Transaction failed. Please try again."),
          );
        },
      );
    }
  }).catchError((error) {
    // Handle errors such as network issues or unexpected API responses
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(error.toString()),
        );
      },
    );
  });
}
