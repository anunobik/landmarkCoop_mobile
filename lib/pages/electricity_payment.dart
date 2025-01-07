import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_buypower.dart';
import '../api/api_service.dart';
import '../model/customer_model.dart';
import '../model/electricity_model.dart';
import '../widgets/bottom_nav_bar.dart';

class ElectricityPayment extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const ElectricityPayment({
    Key? key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
  }) : super(key: key);

  @override
  State<ElectricityPayment> createState() => ElectricityPaymentState();
}

class ElectricityPaymentState extends State<ElectricityPayment> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController meterNoController;
  late TextEditingController discoController;
  late TextEditingController accTypeController;
  late TextEditingController amountController;
  late TextEditingController emailController;
  late TextEditingController phoneNoController;
  String meterNo = "";
  int amount = 0;
  String email = "";
  String phoneNo = "";
  late TextEditingController customerName;
  String customerNameStr = "";
  late TextEditingController customerAddress;
  String customerAddressStr = "";
  String disco = "";
  String accType = "";
  late double _walletBalance;
  bool isApiCallProcess = false;
  // late TransactionRequestModel transactionRequestModel;
  late VendRequestModel vendRequestModel;
  late int minVendAmount;
  // APIService apiService2 = APIService();
  bool _enableSubmitBtn = false;
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  bool _value = false;

  @override
  void dispose() {
    meterNoController.dispose();
    discoController.dispose();
    accTypeController.dispose();
    amountController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    meterNoController = TextEditingController();
    discoController = TextEditingController();
    accTypeController = TextEditingController();
    amountController = TextEditingController();
    emailController = TextEditingController();
    phoneNoController = TextEditingController();
    customerName = TextEditingController();
    customerAddress = TextEditingController();
    vendRequestModel = VendRequestModel();
    // transactionRequestModel = TransactionRequestModel();
  }

  void fetch(String disco, String accountType) {
    setState(() {
      discoController.text = disco;
      accTypeController.text = accountType;
    });
  }

  Future<void> _navigateToSignInScreen() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    final value = await apiService.pageReload(widget.token); // Assuming pageReload gets necessary data

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BottomNavBar(
        pageIndex: 0,
        fullName: value.customerWalletsList[0].fullName,
        token: value.token,
        subdomain: subdomain,
        customerWallets: value.customerWalletsList,
        phoneNumber: value.customerWalletsList[0].phoneNo,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff000080)),
          onPressed: _navigateToSignInScreen,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: meterNoController,
                        onSaved: (input) => meterNo = input!,
                        validator: (input) =>
                            input!.length < 4 ? "Meter No is incomplete" : null,
                        decoration: InputDecoration(
                          labelText: 'Meter No.',
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
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        meterNo = meterNoController.text;
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            isApiCallProcess = true;
                          });
                          BuyPowerService buyPowerService = BuyPowerService();
                          buyPowerService.checkMeterInfo(meterNo).then((value) {
                            setState(() {
                              isApiCallProcess = false;
                            });
                            fetch(value.discoCode, value.vendType);
                            customerName.text = value.name;
                            customerNameStr = value.name;
                            customerAddress.text = value.address;
                            customerAddressStr = value.address;
                            // minVendAmount = value.minVendAmount;
                            // transactionRequestModel.customerName = value.name;
                            // transactionRequestModel.address = value.address;

                            if (value.maxVendAmount > 1) {
                              _enableSubmitBtn = true;
                            }
                          }).catchError((e) {
                            // ignore: avoid_print
                            print(e.toString());
                            setState(() {
                              isApiCallProcess = false;
                            });
                            fetch('Incorrect Details', 'Incorrect Details');
                            customerNameStr = 'No Account Name';
                            customerAddressStr = 'No Address';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        textStyle: GoogleFonts.montserrat(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Fetch'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Name: ',
                      style: GoogleFonts.montserrat(),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: customerName,
                        enabled: false,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      'Address: ',
                      style: GoogleFonts.montserrat(),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: customerAddress,
                        enabled: false,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: discoController,
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Disco',
                    hintStyle: GoogleFonts.montserrat(
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: accTypeController,
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Account Type.',
                    hintStyle: GoogleFonts.montserrat(
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: amountController,
                  validator: (input) {
                    if (input!.isNotEmpty) {
                      double.parse(input) < 1000
                          ? "Enter amt greater than vending amount - Min vending amt is NGN1000"
                          : null;
                    }
                  },
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                    email = emailController.text;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  onSaved: (input) => phoneNo = input!,
                  validator: (input) {
                    if (input!.isNotEmpty) {
                      input.length < 8 ? "Incomplete phone number" : null;
                    }
                  },
                  controller: phoneNoController,
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
                    phoneNo = phoneNoController.text;
                  },
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: !_enableSubmitBtn
                        ? null
                        : () {
                            // if (formKey.currentState!.validate()) {
                            //   user == null
                            //       ? submitUnregistered()
                            //       : submitMerchant(user);
                            // }
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitUnregistered() {
    //Popup flutterwave payment
    if (amount < 1000) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("Message"),
              content: Text("Amount MUST be more than NGN1,000!"),
            );
          });
      setState(() {
        isApiCallProcess = false;
      });
    } else {
      _handlePaymentInitialization();
    }
  }

  _handlePaymentInitialization() async {
    const String _FLUTTERWAVE_PUB_KEY =
        "FLWPUBK-ffa67ca9defd5a5a55604596614bb668-X";
    var email = emailController.text;
    var displayName = "Minerva Payer";
    var phoneNo = phoneNoController.text;
    email.isEmpty ? email = "info@myminervahub.com" : email;
    phoneNo.isEmpty ? phoneNo = "07039162908" : phoneNo;
    String narration = "Minervahub electricity payment";
    String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
    String txRef = "minervahubuser." + datePart;
    double amountToDebit = amount + 50;

    // final style = FlutterwaveStyle(
    //     appBarText: "Payment",
    //     appBarTitleTextStyle: GoogleFonts.montserrat(color: Colors.white),
    //     buttonColor: Color(0xff000080),
    //     appBarIcon: const Icon(Icons.message, color: Color(0xff01440a)),
    //     buttonTextStyle: GoogleFonts.montserrat(
    //         color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
    //     appBarColor: Color(0xff000080),
    //     dialogCancelTextStyle:
    //         GoogleFonts.montserrat(color: Colors.redAccent, fontSize: 18),
    //     dialogContinueTextStyle:
    //         GoogleFonts.montserrat(color: Colors.blue, fontSize: 18),
    //     dialogBackgroundColor: Colors.white,
    //     buttonText: "Pay NGN$amountToDebit");

    final Customer customer =
        Customer(name: displayName, phoneNumber: phoneNo, email: email);

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        // style: style,
        publicKey: _FLUTTERWAVE_PUB_KEY,
        currency: "NGN",
        redirectUrl: "my_redirect_url",
        txRef: txRef,
        amount: amountToDebit.toString(),
        customer: customer,
        paymentOptions: "ussd, card",
        customization: Customization(title: "Plux Payment"),
        isTestMode: false);

    final ChargeResponse response = await flutterwave.charge();
    if (response != null) {
      if (response.success!) {
        String orderId = "minervahubuser.$datePart";
        // transactionRequestModel.meterNo = meterNoController.text;
        // transactionRequestModel.disco = discoController.text;
        // transactionRequestModel.vendAmount = amountController.text;
        // transactionRequestModel.phoneNo = phoneNo;
        // transactionRequestModel.orderId = orderId;
        // transactionRequestModel.email = emailController.text;
        // Call the verify transaction endpoint with the transactionID returned in `response.transactionId` to verify transaction before offering value to customer
        // APIService apiService = APIService();
        // apiService
        //     .anonymousBillsPay(
        //         transactionRequestModel, int.parse(response.transactionId!))
        //     .then((value) {
        //   vendBillPayment(value, orderId);
        // });
      } else {
        // Transaction not successful
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text("Notice"),
                content: Text("Transaction not successful"),
              );
            });
      }
    } else {
      // User cancelled
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("Message"),
              content: Text("You cancelled the transaction!"),
            );
          });
      setState(() {
        isApiCallProcess = false;
      });
    }
  }

  void submitMerchant() {
    // String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
    // String orderId = "${user!.uid}.$datePart";
    // // APIService apiService = APIService();
    // apiService.getWalletInfo(user.uid).then((value) {
    //   _walletBalance = value.balance;
    //   if (_walletBalance < amount) {
    //     showDialog(
    //         context: context,
    //         builder: (BuildContext context) {
    //           return const AlertDialog(
    //             title: Text("Message"),
    //             content: Text("Insufficent Balance!"),
    //           );
    //         });
    //     setState(() {
    //       isApiCallProcess = false;
    //     });
    //   } else if (amount < 1000) {
    //     showDialog(
    //         context: context,
    //         builder: (BuildContext context) {
    //           return const AlertDialog(
    //             title: Text("Message"),
    //             content: Text("Amount MUST be more than NGN1,000!"),
    //           );
    //         });
    //     setState(() {
    //       isApiCallProcess = false;
    //     });
    //   } else {
    //     setState(() {
    //       isApiCallProcess = false;
    //     });

    //     transactionRequestModel.meterNo = meterNo;
    //     transactionRequestModel.disco = discoController.text;
    //     transactionRequestModel.vendAmount = amountController.text;
    //     transactionRequestModel.phoneNo = phoneNo;
    //     transactionRequestModel.orderId = orderId;
    //     transactionRequestModel.email = emailController.text;
    //     amount = int.parse(amountController.text);
    //     String amountStr = displayAmount.format(amount);
    //     showDialog<void>(
    //       context: context,
    //       barrierDismissible: false, // user must tap button!
    //       builder: (BuildContext context) {
    //         return ProgressHUD(
    //           inAsyncCall: isApiCallProcess,
    //           opacity: 0.3,
    //           child: AlertDialog(
    //             title: const Text('Confirmation'),
    //             content: SingleChildScrollView(
    //               child: ListBody(
    //                 children: <Widget>[
    //                   Text("Are you sure you want to vend NGN$amountStr ?"),
    //                 ],
    //               ),
    //             ),
    //             actions: <Widget>[
    //               TextButton(
    //                 child: const Text('Cancel'),
    //                 onPressed: () {
    //                   Navigator.of(context).pushReplacement(MaterialPageRoute(
    //                       builder: (context) => const ElectricityPayment()));
    //                 },
    //               ),
    //               TextButton(
    //                 child: const Text('OK'),
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                   setState(() {
    //                     isApiCallProcess = true;
    //                   });
    //                   APIService apiService = APIService();
    //                   apiService
    //                       .debitWallet(transactionRequestModel, user.uid)
    //                       .then((valueTransactionRes) {
    //                     if (valueTransactionRes.result) {
    //                       vendBillPayment(valueTransactionRes, orderId);
    //                     } else {
    //                       showDialog(
    //                           context: context,
    //                           builder: (BuildContext context) {
    //                             return const AlertDialog(
    //                               title: Text("Notice"),
    //                               content: Text("Transaction not completed!"),
    //                             );
    //                           });
    //                     }
    //                   });
    //                 },
    //               ),
    //             ],
    //           ),
    //         );
    //       },
    //     );
    //   }
    // });
  }

  // void vendBillPayment(
  //     TransactionFeedbackResponseModel valueTransactionRes, String orderId) {
  //   vendRequestModel.amount = amountController.text;
  //   vendRequestModel.orderId = orderId;
  //   vendRequestModel.disco = discoController.text;
  //   vendRequestModel.name = customerName.text;
  //   vendRequestModel.vendType = accTypeController.text;
  //   vendRequestModel.meter = meterNoController.text;
  //   String displayDate = DateFormat('yyyy-MMM-dd').format(DateTime.now());
  //   if (phoneNo.length < 11 || phoneNo.isEmpty) {
  //     vendRequestModel.phone = '07039162908';
  //   } else {
  //     vendRequestModel.phone = phoneNo;
  //   }
  //   print(vendRequestModel.toJson());
  //   BuyPowerService buyPowerService = BuyPowerService();
  //   User? user = FirebaseAuth.instance.currentUser;
  //   buyPowerService.payElectricBill(vendRequestModel).then((value) {
  //     if (value.responseMessage == "Payment was successful" ||
  //         value.responseCode == 100 || value.responseCode == 200 || value.token.isNotEmpty ||
  //         value.responseMessage == "SUCCESSFUL" ||
  //         value.responseMessage == "OK") {
  //       saveMerchantMeterNo();
  //       if (value.token.isNotEmpty) {
  //         transactionRequestModel.receiptNo = value.receiptNo;
  //         transactionRequestModel.units = value.units;
  //         transactionRequestModel.token = value.token;
  //         transactionRequestModel.transactionRef = value.vendRef;
  //         accTypeController.text.isEmpty
  //             ? transactionRequestModel.vendType = "PREPAID"
  //             : transactionRequestModel.vendType = accTypeController.text;

  //         if(valueTransactionRes.disco == 'EKO'){
  //           apiService2.updateTransactionHistory(
  //               valueTransactionRes.id.toString(),
  //               value.token,
  //               value.units.toString(),
  //               value.receiptNo,
  //               value.vendRef,
  //               transactionRequestModel.vendType);
  //         }else {
  //           apiService2.updateTransactionHistory(
  //               valueTransactionRes.id.toString(),
  //               value.token,
  //               value.units,
  //               value.receiptNo,
  //               value.vendRef,
  //               transactionRequestModel.vendType);
  //         }
  //         disco = discoController.text;
  //         email = emailController.text;
  //         accType = accTypeController.text;

  //         phoneNoController.clear();
  //         amountController.clear();
  //         accTypeController.clear();
  //         discoController.clear();
  //         emailController.clear();
  //         meterNoController.clear();
  //         customerNameStr = '';
  //         customerAddressStr = '';

  //         setState(() {
  //           isApiCallProcess = false;
  //         });

  //         Navigator.of(context).push(
  //           MaterialPageRoute(
  //             builder: (context) => PaymentStatus(
  //               meterNo: meterNo,
  //               disco: disco,
  //               email: email,
  //               phone: phoneNo,
  //               accType: accType,
  //               amount: value.totalAmountPaid,
  //               transactionDate: displayDate,
  //               token: value.token,
  //               receiptNo: value.receiptNo,
  //               customerName: customerName.text,
  //               units: value.units,
  //               transactionRef: value.vendRef,
  //               transactionsId: valueTransactionRes.id,
  //               address: valueTransactionRes.address,
  //             ),
  //           ),
  //         );
  //       } else {
  //         transactionRequestModel.receiptNo = value.receiptNo;
  //         transactionRequestModel.units = value.units;
  //         transactionRequestModel.transactionRef = value.vendRef;
  //         transactionRequestModel.vendType = accTypeController.text;

  //         if(valueTransactionRes.disco == 'EKO'){
  //           apiService2.updateTransactionHistory(
  //               valueTransactionRes.id.toString(),
  //               value.token,
  //               value.units.toString(),
  //               value.receiptNo,
  //               value.vendRef,
  //               transactionRequestModel.vendType);
  //         }else {
  //           apiService2.updateTransactionHistory(
  //               valueTransactionRes.id.toString(),
  //               value.token,
  //               value.units,
  //               value.receiptNo,
  //               value.vendRef,
  //               transactionRequestModel.vendType);
  //         }
  //         disco = discoController.text;
  //         email = emailController.text;
  //         accType = accTypeController.text;

  //         phoneNoController.clear();
  //         amountController.clear();
  //         accTypeController.clear();
  //         discoController.clear();
  //         emailController.clear();
  //         meterNoController.clear();
  //         customerNameStr = '';
  //         customerAddressStr = '';

  //         setState(() {
  //           isApiCallProcess = false;
  //         });

  //         Navigator.of(context).push(
  //           MaterialPageRoute(
  //             builder: (context) => PaymentStatus(
  //               meterNo: meterNo,
  //               disco: discoController.text,
  //               email: emailController.text,
  //               phone: phoneNo,
  //               accType: accTypeController.text,
  //               amount: value.totalAmountPaid,
  //               transactionDate: displayDate,
  //               token: "POST PAID PAYMENT (NO TOKEN GENERATED)",
  //               receiptNo: value.receiptNo,
  //               customerName: customerName.text,
  //               units: value.units,
  //               transactionRef: value.vendRef,
  //               transactionsId: valueTransactionRes.id,
  //               address: valueTransactionRes.address,
  //             ),
  //           ),
  //         );
  //       }
  //       setState(() {
  //         isApiCallProcess = false;
  //       });
  //     } else {
  //       setState(() {
  //         isApiCallProcess = false;
  //       });
  //       //Todo reverse the debit amount
  //       if(user != null){
  //         apiService2.reverseTransaction(user.uid, valueTransactionRes.id);
  //       }

  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: const Text("Failed!"),
  //               content: Text(
  //                   value.responseMessage),
  //             );
  //           });
  //     }
  //   });
  // }
}
