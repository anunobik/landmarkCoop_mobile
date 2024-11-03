import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_flutterwave.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/airtime_model.dart';
import 'package:landmarkcoop_mobile_app/model/cable_tv_model.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/util/ProgressHUD.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../component/processing_airtime_request.dart';

class DataSubscription extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const DataSubscription({
    super.key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.lastTransactions,
  });

  @override
  State<DataSubscription> createState() => _DataSubscriptionState();
}

class _DataSubscriptionState extends State<DataSubscription> {
  String subscription = 'MTN';
  TextEditingController phoneController = TextEditingController();
  String viewAmount = 'Please Wait... \n\n Loading...';
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  bool isApiCallProcess = false;
  late int totalNotifications;
  late List notificationList;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  bool readPolicy = false;
  FlutterWaveService flutterWaveService = FlutterWaveService();
  List<BillsInfoResponseModel> dataMTN = <BillsInfoResponseModel>[
    BillsInfoResponseModel(
      id: 0,
      billerCode: '',
      name: 'Select Subscription',
      defaultCommission: 0,
      country: '',
      isAirtime: false,
      billerName: '',
      itemCode: '',
      shortName: 'Select Subscription',
      fee: 0,
      commissionOnFee: false,
      labelName: '',
      amount: 0,
    )
  ];
  List<BillsInfoResponseModel> dataGlo = <BillsInfoResponseModel>[
    BillsInfoResponseModel(
      id: 0,
      billerCode: '',
      name: 'Select Subscription',
      defaultCommission: 0,
      country: '',
      isAirtime: false,
      billerName: '',
      itemCode: '',
      shortName: 'Select Subscription',
      fee: 0,
      commissionOnFee: false,
      labelName: '',
      amount: 0,
    )
  ];
  List<BillsInfoResponseModel> data9Mobile = <BillsInfoResponseModel>[
    BillsInfoResponseModel(
      id: 0,
      billerCode: '',
      name: 'Select Subscription',
      defaultCommission: 0,
      country: '',
      isAirtime: false,
      billerName: '',
      itemCode: '',
      shortName: 'Select Subscription',
      fee: 0,
      commissionOnFee: false,
      labelName: '',
      amount: 0,
    )
  ];
  List<BillsInfoResponseModel> dataAirtel = <BillsInfoResponseModel>[
    BillsInfoResponseModel(
      id: 0,
      billerCode: '',
      name: 'Select Subscription',
      defaultCommission: 0,
      country: '',
      isAirtime: false,
      billerName: '',
      itemCode: '',
      shortName: 'Select Subscription',
      fee: 0,
      commissionOnFee: false,
      labelName: '',
      amount: 0,
    )
  ];
  BillsInfoResponseModel? currentMTNDataBundle;
  BillsInfoResponseModel? currentGloDataBundle;
  BillsInfoResponseModel? current9MobileDataBundle;
  BillsInfoResponseModel? currentAirtelDataBundle;
  BillsInfoResponseModel selectedDateBundle = BillsInfoResponseModel(
    id: 0,
    billerCode: '',
    name: 'Select Subscription',
    defaultCommission: 0,
    country: '',
    isAirtime: false,
    billerName: '',
    itemCode: '',
    shortName: 'Select Subscription',
    fee: 0,
    commissionOnFee: false,
    labelName: '',
    amount: 0,
  );
  BillsInfoResponseModel? currentDataBundle;
  bool _enableSubmitBtn = false;
  String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
  late String txRef;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getMTNDataBundle();
    getGloDataBundle();
    get9MobileDataBundle();
    getAirtelDataBundle();
  }

  getMTNDataBundle() {
    return flutterWaveService.getBillsList('BIL108', widget.token).then((value) {
      currentMTNDataBundle = dataMTN[0];
      for (var singleData in value) {
        dataMTN.add(singleData);
      }
      setState(() {
        dataMTN;
        viewAmount = '0.0';
      });
    });
  }

  getGloDataBundle() {
    return flutterWaveService.getBillsList('BIL109', widget.token).then((value) {
      currentGloDataBundle = dataGlo[0];
      for (var singleData in value) {
        dataGlo.add(singleData);
      }
      setState(() {
        dataGlo;
      });
    });
  }

  get9MobileDataBundle() {
    return flutterWaveService.getBillsList('BIL111', widget.token).then((value) {
      current9MobileDataBundle = data9Mobile[0];
      for (var singleData in value) {
        data9Mobile.add(singleData);
      }
      setState(() {
        data9Mobile;
      });
    });
  }

  getAirtelDataBundle() {
    return flutterWaveService.getBillsList('BIL110', widget.token).then((value) {
      currentAirtelDataBundle = dataAirtel[0];
      for (var singleData in value) {
        dataAirtel.add(singleData);
      }
      setState(() {
        dataAirtel;
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
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        subscription = 'MTN';
                        viewAmount = '0.0';
                      });
                    },
                    child: Container(
                      height: height * 0.0768,
                      width: height * 0.0768,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: subscription == 'MTN'
                              ? Colors.lightBlue
                              : Colors.transparent,
                          width: 3,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/mtn.jpg'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        subscription = 'Glo';
                        viewAmount = '0.0';
                      });
                    },
                    child: Container(
                      height: height * 0.0768,
                      width: height * 0.0768,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: subscription == 'Glo'
                                ? Colors.lightBlue
                                : Colors.transparent,
                            width: 3),
                        image: const DecorationImage(
                          image: AssetImage('assets/glo.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        subscription = 'Airtel';
                        viewAmount = '0.0';
                      });
                    },
                    child: Container(
                      height: height * 0.0768,
                      width: height * 0.0768,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: subscription == 'Airtel'
                              ? Colors.lightBlue
                              : Colors.transparent,
                          width: 3,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/airtel.jpg'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        subscription = '9mobile';
                        viewAmount = '0.0';
                      });
                    },
                    child: Container(
                      height: height * 0.0768,
                      width: height * 0.0768,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: subscription == '9mobile'
                              ? Colors.lightBlue
                              : Colors.transparent,
                          width: 3,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/9mobile.jpg'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                '$subscription Subscription',
                style: GoogleFonts.openSans(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                controller: phoneController,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Enter Phone Number',
                  hintStyle: GoogleFonts.montserrat(
                    color: const Color(0xff9ca2ac),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 0.7,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 0.7,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final granted = await FlutterContactPicker.hasPermission();

                    //Todo confirm if privacy policy has been read
                    readPolicy = prefs.getBool('readPolicy') ?? false;

                    if (!readPolicy) {
                      readAndAcceptPolicy();
                      acceptOrRejectPolicy();
                    } else {
                      if (!granted) {
                        await FlutterContactPicker.requestPermission();
                      }
                      final PhoneContact contact =
                          await FlutterContactPicker.pickPhoneContact();
                      if (contact.phoneNumber!.number!.substring(0, 4) ==
                          '+234') {
                        var newPhone = contact.phoneNumber!.number!
                            .replaceAll('+234', '0');
                        setState(() {
                          phoneController.text = newPhone.replaceAll(" ", "");
                        });
                      } else {
                        setState(() {
                          phoneController.text = contact.phoneNumber!.number!;
                        });
                      }
                      // Look at the code below

                      // APIService apiServicePhone =
                      //     new APIService();
                      // apiServicePhone
                      //     .getAccountFromPhone(
                      //         phoneController.text.replaceAll(' ', ''), widget.token)
                      //     .then((value) {
                      //   setState(() {
                      //     customerAccountDisplayModel = value;
                      //     if (value.displayName.isNotEmpty) {
                      //       disableSendMoneyBtn = false;
                      //     } else {
                      //       disableSendMoneyBtn = true;
                      //     }
                      //   });
                      // });
                    }
                  },
                  child: Text(
                    'Choose from contacts',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff000080),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // data Bundle List,
              dataBundleListBuilder(),
              const SizedBox(height: 10),
              Text(
                viewAmount,
                style: GoogleFonts.montserrat(),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: !_enableSubmitBtn
                    ? null
                    : () async {
                        final prefs = await SharedPreferences.getInstance();
                        setState(() {
                          isApiCallProcess = true;
                        });
                        txRef =
                            "ozi_user.${phoneController.text.trim()}_$datePart";
                        InstantAirtimeAndDataRequestModel requestModel =
                            InstantAirtimeAndDataRequestModel(
                                phoneNumber: phoneController.text.trim(),
                                amount: currentDataBundle!.amount,
                                transactionRef: txRef,
                                requestType: 'Data');

                        APIService apiService =
                            APIService();
                        if (widget.customerWallets[0].balance <
                            currentDataBundle!.amount) {
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
                              rechargeDataPhone(valueTransactionRes, selectedDateBundle);
                            } else {
                              setState(() {
                                isApiCallProcess = false;
                              });
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const AlertDialog(
                                      title: Text("Notice"),
                                      content:
                                          Text("Transaction not completed!"),
                                    );
                                  });
                            }
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
    );
  }

  // Read and Accept Policy
  void readAndAcceptPolicy() {
    Future<void>? launched;
    Uri url = Uri.parse('https://privacypolicy.myminervahub.com');

    Future<void> launchInWebViewOrVC(Uri url) async {
      if (!await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
            headers: <String, String>{'my_header_key': 'my_header_value'}),
      )) {
        throw 'Could not launch $url';
      }
    }

    setState(() {
      launched = launchInWebViewOrVC(url);
      Timer(const Duration(seconds: 10), () {
        print('Closing WebView after 10 seconds...');
        closeInAppWebView();
      });
    });
    // WebViewController _controller;
    // return Column(
    //   children: [
    //     Container(
    //       child: WebView(
    //         initialUrl: 'about:blank',
    //         onWebViewCreated: (WebViewController webViewController) {
    //           _controller = webViewController;
    //           _loadHtml(_controller, 'https://privacypolicy.myminervahub.com');
    //         },
    //       ),
    //     )
    //   ],
    // );
  }

  acceptOrRejectPolicy() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Container(
                height: 50,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15),
                color: const Color.fromRGBO(0, 0, 139, 1),
                child: Center(
                  child: Text(
                    'Message',
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              content:
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Center(
                  child: Text(
                    'Notice',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Kindly Accept or Click Outside to Reject Privacy Policy',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ]),
              actionsAlignment: MainAxisAlignment.start,
              actions: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('readPolicy', true);
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
                        "Agree",
                        style: GoogleFonts.montserrat(
                          color: const Color.fromRGBO(0, 0, 139, 1),
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

  Widget dataBundleListBuilder() {
    List<BillsInfoResponseModel> dataTo = <BillsInfoResponseModel>[
      BillsInfoResponseModel(
        id: 0,
        billerCode: '',
        name: 'Select Subscription',
        defaultCommission: 0,
        country: '',
        isAirtime: false,
        billerName: '',
        itemCode: '',
        shortName: 'Select Subscription',
        fee: 0,
        commissionOnFee: false,
        labelName: '',
        amount: 0,
      ),
    ];

    switch (subscription) {
      case 'MTN':
        dataTo = dataMTN;
        currentDataBundle = currentMTNDataBundle;
        break;
      case 'Glo':
        dataTo = dataGlo;
        currentDataBundle = currentGloDataBundle;
        break;
      case 'Airtel':
        dataTo = dataAirtel;
        currentDataBundle = currentAirtelDataBundle;
        break;
      case '9mobile':
        dataTo = data9Mobile;
        currentDataBundle = current9MobileDataBundle;
        break;
    }
    return FormField<BillsInfoResponseModel>(
        builder: (FormFieldState<BillsInfoResponseModel> state) {
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
          hintText: 'Select Subscription',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // isEmpty: currentWallet.biller_code == "",
        child: DropdownButtonHideUnderline(
          child: DropdownButton<BillsInfoResponseModel>(
            alignment: AlignmentDirectional.centerEnd,
            value: currentDataBundle,
            isDense: true,
            isExpanded: true,
            onChanged: (newValue) {
              setState(() {
                switch (subscription) {
                  case 'MTN':
                    currentMTNDataBundle = newValue!;
                    break;
                  case 'Glo':
                    currentGloDataBundle = newValue!;
                    break;
                  case 'Airtel':
                    currentAirtelDataBundle = newValue!;
                    break;
                  case '9mobile':
                    current9MobileDataBundle = newValue!;
                    break;
                }
                viewAmount = displayAmount.format(newValue!.amount);
                state.didChange(newValue);
                _enableSubmitBtn = true;
                selectedDateBundle = newValue;
              });
            },
            items: dataTo
                .map((map) => DropdownMenuItem<BillsInfoResponseModel>(
                      value: map,
                      child: Center(
                          child: Text(
                        map.shortName,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ))
                .toList(),
          ),
        ),
      );
    });
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

  void rechargeDataPhone(
      InstantAirtimeAndDataFeedbackResponseModel valueTransactionRes, BillsInfoResponseModel billsInfoModel) {
    String displayDate = DateFormat('yyyy-MMM-dd').format(DateTime.now());
    FlutterWaveService apiFlutterWave = FlutterWaveService();
    DataBundleRequestModel dataBundleRequestModel = DataBundleRequestModel(
      phoneNumber: valueTransactionRes.phoneNumber,
      amount: valueTransactionRes.amount,
      billerName: currentDataBundle!.billerName,
      reference: valueTransactionRes.transactionRef,
    );
    apiFlutterWave.buyDataBundle(dataBundleRequestModel, billsInfoModel.billerCode, billsInfoModel.itemCode, widget.token).then((value) {
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
