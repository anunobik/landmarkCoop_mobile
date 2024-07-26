import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:landmarkcoop_mobile_app/api/api_paystack.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/main.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/model/paystack_model.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/pages/investment.dart';
import 'package:landmarkcoop_mobile_app/pushNotifications/push_messages.dart';
import 'package:landmarkcoop_mobile_app/util/ProgressHUD.dart';
import 'package:landmarkcoop_mobile_app/util/color_extension.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:landmarkcoop_mobile_app/util/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/data_item.dart';

class Dashboard extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const Dashboard(
      {Key? key,
      required this.customerWallets,
      required this.lastTransactions,
      required this.fullName,
      required this.token})
      : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool showWallet = false;
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  APIService apiService = APIService();
  List itemData = [];
  bool isApiCallProcess = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double fundAmount = 0;
  late int noOfInvestments;
  double totalInvestments = 0;
  double roi = 0;
  bool investExist = false;
  final Color leftBarColor = const Color(0xFF3BFF49);
  final Color rightBarColor = const Color(0xFFE80054);
  final Color avgColor = const Color(0xFF2196F3).avg(const Color(0xFF50E4FF));
  final double width = 7;
  List chartList = [];
  List<DataItem> newData = [];
  int touchedGroupIndex = -1;
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  CustomerWalletsBalanceModel? currentWallet;
  CustomerWalletsBalanceModel? selectedWallet;
  List<CustomerWalletsBalanceModel> dataWallet = <CustomerWalletsBalanceModel>[
    CustomerWalletsBalanceModel(
        id: 0,
        accountNumber: 'Select Account',
        balance: 0,
        productName: '',
        fullName: '',
        email: '',
        phoneNo: '',
        interBankName: '',
        nubanAccountNumber: 'Select Account',
        trackNumber: 'Select Account')
  ];
  List<CustomerWalletsBalanceModel> viewWallet = [];
  final CarouselController _controller = CarouselController();
  int _currentIndex = 0;
  GatewayResponseModel? gateWayResponse;

  List<ProductResponseModel> data = <ProductResponseModel>[
    ProductResponseModel(
      id: 0,
      productName: 'Select Product',
      displayName: 'Select Product',
      description: 'Select Product',
      interestRate: 0.0,
      tenorDays: 0,
      prematureCharge: 0.0,
      normalCharge: 0.0,
      defaultCharge: 0.0,
      serviceCharge: 0.0,
      referralPercentageCharge: 0.0,
    )
  ];
  late ProductResponseModel currentProduct;
  ProductResponseModel? selectedProduct;
  var publicKey = 'pk_live_a6fbbb05e8b8e498674780e7dd0560d0cbc23670';

  // final plugin = PaystackPlugin();
  Future<void>? _launched;
  List<CustomerInvestmentWalletModel> investData =
      <CustomerInvestmentWalletModel>[];

  OnlineRateResponseModel newValue = OnlineRateResponseModel(
      id: 0,
      oneMonth: 0,
      twoMonth: 0,
      threeMonth: 0,
      fourMonth: 0,
      fiveMonth: 0,
      sixMonth: 0,
      sevenMonth: 0,
      eightMonth: 0,
      nineMonth: 0,
      tenMonth: 0,
      elevenMonth: 0,
      twelveMonth: 0);

  Future<List<ProductResponseModel>> getProducts() {
    return apiService.getProducts();
  }

  getRate() async {
    APIService apiService = APIService();
    OnlineRateResponseModel value =
        await apiService.getOnlineRate(widget.token);
    setState(() {
      newValue = value;
    });
  }

  Widget futureBundleListBuilder() {
    return FutureBuilder<List<ProductResponseModel>>(
      future: getProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ProductResponseModel> insideData = snapshot.data!;
          // data.clear();
          data = <ProductResponseModel>[
            ProductResponseModel(
              id: 0,
              productName: 'Select Product',
              displayName: 'Select Product',
              description: 'Select Product',
              interestRate: 0.0,
              tenorDays: 0,
              prematureCharge: 0.0,
              normalCharge: 0.0,
              defaultCharge: 0.0,
              serviceCharge: 0.0,
              referralPercentageCharge: 0.0,
            )
          ];
          currentProduct = data[0];

          for (var singleData in insideData) {
            if (!singleData.productName.contains('loan') &&
                !singleData.displayName.contains('loan')) {
              data.add(singleData);
            }
          }

          return FormField<ProductResponseModel>(
              builder: (FormFieldState<ProductResponseModel> state) {
            return InputDecorator(
              decoration: InputDecoration(
                labelStyle: GoogleFonts.montserrat(
                  color: const Color(0xff9ca2ac),
                ),
                errorStyle: GoogleFonts.montserrat(
                  color: Colors.redAccent,
                ),
                hintText: 'Select Product',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              // isEmpty: currentProduct.biller_code == "",
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ProductResponseModel>(
                  alignment: AlignmentDirectional.centerEnd,
                  value: currentProduct,
                  isExpanded: true,
                  isDense: true,
                  onChanged: (newValue) {
                    setState(() {
                      currentProduct = newValue!;
                      state.didChange(newValue);
                      selectedProduct = newValue;
                    });
                  },
                  items: data
                      .map((map) => DropdownMenuItem<ProductResponseModel>(
                            value: map,
                            child: Center(
                                child: Text(
                              map.displayName,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ))
                      .toList(),
                ),
              ),
            );
          });
        } else {
          return const Text('Please wait Products loading...');
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getRate();
    getCustomerWallets();
    getAllInvestment();
    loadGateWay();
    // plugin.initialize(publicKey: publicKey);

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
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if (mounted) {
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });
        notificationList.add({
          'title': notificationInfo!.title,
          'body': notificationInfo!.body,
        });

        // API Sign in token

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => PushMessages(
                  notificationList: notificationList,
                  totalNotifications: totalNotifications,
                )));
      }
    });
    totalNotifications = 0;
  }

  getCustomerWallets() {
    apiService = APIService();
    return apiService.pageReload(widget.token).then((value) {
      currentWallet = dataWallet[0];
      for (var singleData in value.customerWalletsList) {
        dataWallet.add(singleData);
        viewWallet.add(singleData);
      }
      setState(() {
        displayWallets(viewWallet);
        displayChart(value.lastTransactionsList);
        showWallet = true;
      });
    });
  }

  loadGateWay() {
    APIService apiService = APIService();
    return apiService.getActivePaymentGateway().then((value) {
      gateWayResponse = value;
      setState(() {
        gateWayResponse;
        // if (gateWayResponse!.gatewayName == 'Paystack') {
        //   plugin.initialize(publicKey: gateWayResponse!.publicKey);
        // }
      });
    });
  }

  getAllInvestment() {
    return apiService.allInvestments(widget.token).then((value) {
      // currentWallet = investData[0];
      for (var singleData in value) {
        investData.add(singleData);
        totalInvestments = totalInvestments + singleData.amount;
        roi = roi + singleData.maturityAmount;
      }

      if (investData.isNotEmpty) {
        investExist = true;
      }
      setState(() {
        investData;
        noOfInvestments = investData.length;
        investExist;
      });
    });
  }

  void displayChart(List<LastTransactionsModel> lastTransactionsList) {
    for (var singleTransactions in lastTransactionsList) {
      final items = [
        DataItem(
            x: 0,
            y1: singleTransactions.mondayDepositAmount,
            y2: singleTransactions.mondayWithdrawalAmount),
        DataItem(
            x: 1,
            y1: singleTransactions.tuesdayDepositAmount,
            y2: singleTransactions.tuesdayWithdrawalAmount),
        DataItem(
            x: 2,
            y1: singleTransactions.wednesdayDepositAmount,
            y2: singleTransactions.wednesdayWithdrawalAmount),
        DataItem(
            x: 3,
            y1: singleTransactions.thursdayDepositAmount,
            y2: singleTransactions.thursdayWithdrawalAmount),
        DataItem(
            x: 4,
            y1: singleTransactions.fridayDepositAmount,
            y2: singleTransactions.fridayWithdrawalAmount),
        DataItem(
            x: 5,
            y1: singleTransactions.saturdayDepositAmount,
            y2: singleTransactions.saturdayWithdrawalAmount),
        DataItem(
            x: 6,
            y1: singleTransactions.sundayDepositAmount,
            y2: singleTransactions.sundayWithdrawalAmount),
      ];

      chartList.add(items);
    }

    setState(() {
      if (chartList.length >= 1) {
        newData = chartList[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HomeDrawer(
                            value: 1,
                            page: Dashboard(
                              token: widget.token,
                              fullName: widget.fullName,
                              lastTransactions: widget.lastTransactions,
                              customerWallets: widget.customerWallets,
                            ),
                            name: 'wallet',
                            token: widget.token,
                            fullName: widget.fullName,
                            customerWallets: widget.customerWallets,
                            lastTransactionsList: widget.lastTransactions)));
                  },
                  icon: Icon(
                    Icons.menu,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),

                // Wallet Balance/Status

                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  height: height * 0.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Wallet Balance',
                        style: GoogleFonts.montserrat(
                            color: const Color(0xff000080),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '(Tap to fund wallet)',
                        style: GoogleFonts.roboto(
                            color: const Color(0xff000080),
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                      showWallet
                          ? Expanded(
                              child: CarouselSlider(
                                items: itemData.map((card) {
                                  return Builder(
                                      builder: (BuildContext context) {
                                    return SizedBox(
                                      height: 0.5 * height,
                                      width: width,
                                      child: Card(
                                        color: Colors.grey.shade100,
                                        child: card,
                                      ),
                                    );
                                  });
                                }).toList(),
                                carouselController: _controller,
                                options: CarouselOptions(
                                  height: 330.8,
                                  autoPlay: false,
                                  enlargeCenterPage: true,
                                  autoPlayInterval: const Duration(seconds: 3),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enableInfiniteScroll: false,
                                  pauseAutoPlayOnTouch: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentIndex = index;
                                      if (chartList.length >= 1) {
                                        newData = chartList[index];
                                      }
                                    });
                                  },
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'Loading...',
                                style: GoogleFonts.montserrat(
                                    color: const Color(0xff000080),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                      itemData.length > 1
                          ? const Center(
                              child: Icon(
                                Icons.swipe,
                                color: Color(0xff000080),
                              ),
                            )
                          : const SizedBox(),
                      itemData.length > 1
                          ? Center(
                              child: Text(
                                'Swipe to view your wallets',
                                style: GoogleFonts.roboto(
                                  color: Color(0xff000080),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
                investExist
                    ? GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Investment(
                                    token: widget.token,
                                    fullName: widget.fullName,
                                    customerWallets: widget.customerWallets,
                                    lastTransactions: widget.lastTransactions,
                                    interestRate: newValue,
                                  )));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          height: height * 0.15,
                          width: width,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.lightBlue.shade900,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.lightBlue.shade300,
                                    Colors.lightBlue.shade700,
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'No. of Investment:  $noOfInvestments',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Total Investment:  NGN ${displayAmount.format(totalInvestments)}',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  // Text('Total Duration:  $investmentPeriod',
                                  //   style: GoogleFonts.montserrat(
                                  //     color: Colors.white,
                                  //     fontWeight: FontWeight.w700,
                                  //   ),
                                  // ),
                                  Text(
                                    'Expected R.O.I:  NGN ${displayAmount.format(roi)}',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: const Text(
                        'Our Partners',
                        style: TextStyle(
                            color: Color.fromARGB(255, 13, 155, 22),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Image.asset('assets/partners.jpg', fit: BoxFit.contain),
                    Image.asset('assets/MinervaHub.png',
                        fit: BoxFit.contain),
                    const SizedBox(
                      height: 38,
                    ),
                    const SizedBox(
                      height: 38,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _additionalAccount,
        child: Container(
          height: 40,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.lightBlue,
          ),
          child: Center(
            child: Text(
              'Add Account',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  displayWallets(List<CustomerWalletsBalanceModel> responseList) {
    List<Widget> histItems = [];
    for (var data in responseList) {
      histItems.add(
        Padding(
          padding: const EdgeInsets.only(right: 13.0, bottom: 10),
          child: GestureDetector(
            onTap: () {
              fundWalletDialog(data.accountNumber);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(3, 3),
                    ),
                  ]),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('NGN', style: GoogleFonts.montserrat()),
                    Text(
                      displayAmount.format(data.balance),
                      style: GoogleFonts.montserrat(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff000080),
                      ),
                    ),
                    Text(
                      data.productName,
                      style: GoogleFonts.montserrat(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      data.accountNumber,
                      style: GoogleFonts.montserrat(
                          fontSize: 10, color: Colors.blueGrey),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    setState(() {
      itemData = histItems;
    });

    return Column(
      children: histItems,
    );
  }

  Future fundWalletDialog(String accountNumber) => showDialog(
        context: context,
        builder: (context) => ProgressHUD(
          inAsyncCall: isApiCallProcess,
          opacity: 0.3,
          child: Form(
            key: formKey,
            child: AlertDialog(
              title: const Text('Amount to fund'),
              content: TextFormField(
                autofocus: true,
                onSaved: (input) => fundAmount = double.parse(input!.trim()),
                validator: (input) =>
                    input!.isEmpty ? "Please enter amount" : null,
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
                        image: AssetImage("assets/naira-black.png"),
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
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (validateAndSave()) {
                      setState(() {
                        isApiCallProcess = false;
                      });
                      _handlePaymentInitialization(accountNumber);
                      // if (gateWayResponse.gatewayName ==
                      //     'Paystack') {
                      //   _handlePaystackPayment(accountNumber);
                      // } else {
                      //   _handlePaymentInitialization(
                      //       accountNumber);
                      // }
                    }
                  },
                  child: const Text('Submit'),
                )
              ],
            ),
          ),
        ),
      );

  _handlePaymentInitialization(String accountNumber) async {
    const String _FLUTTERWAVE_PUB_KEY =
        "FLWPUBK-c0049d19c1c3137f3a3415922541720e-X";
    var email = widget.customerWallets[0].email;
    var displayName = widget.customerWallets[0].fullName;
    var phoneNo = widget.customerWallets[0].phoneNo;

    String narration = "Mobile App credit";
    String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
    String txRef = "$accountNumber.$datePart";

    // final style = FlutterwaveStyle(
    //     appBarText: "Wallet Funding",
    //     appBarTitleTextStyle: const TextStyle(color: Colors.white),
    //     buttonColor: const Color(0XFF091841),
    //     appBarIcon: const Icon(Icons.message, color: Color(0XFF091841)),
    //     buttonTextStyle: const TextStyle(
    //         color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
    //     appBarColor: const Color(0XFF091841),
    //     dialogCancelTextStyle:
    //         const TextStyle(color: Colors.redAccent, fontSize: 18),
    //     dialogContinueTextStyle:
    //         const TextStyle(color: Colors.blue, fontSize: 18),
    //     dialogBackgroundColor: Colors.white,
    //     buttonText: "Pay NGN$fundAmount");

    final Customer customer =
        Customer(name: displayName, phoneNumber: phoneNo, email: email);

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        // style: style,
        publicKey: _FLUTTERWAVE_PUB_KEY,
        currency: "NGN",
        redirectUrl:
            "https://landmarkcooperative.org/verifyBanktransfer/IHd88sdBGAasdfRYEGRh76asf05052023",
        txRef: txRef,
        amount: fundAmount.toString(),
        customer: customer,
        paymentOptions: "ussd, bank_transfer, card",
        customization: Customization(title: "Landmark Coop Mobile funding"),
        isTestMode: false);

    final ChargeResponse response = await flutterwave.charge();
    Navigator.pop(context);
    if (response != null) {
      if (response.success!) {
        // Call the verify transaction endpoint with the transactionID returned in `response.transactionId` to verify transaction before offering value to customer
        AccountTransactionRequestModel accountTransactionRequestModel =
            AccountTransactionRequestModel(amount: fundAmount);
        accountTransactionRequestModel.narration = narration;
        accountTransactionRequestModel.amount = fundAmount;
        accountTransactionRequestModel.accountNumber = accountNumber;
        apiService
            .verifyDeposit(accountTransactionRequestModel,
                int.parse(response.transactionId!), widget.token)
            .then((value) {
          successTransactionAlert(value);
        });
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

  // _handlePaystackPayment(String accountNumber) async {
  //   var email = widget.customerWallets[0].email;
  //   var displayName = widget.customerWallets[0].fullName;
  //   var phoneNo = widget.customerWallets[0].phoneNo;
  //   var amount = (fundAmount * 100).toString();
  //
  //   String narration = "Mobile App credit";
  //   String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
  //
  //   PaystackApi paystackApi = PaystackApi();
  //   TransactionInitRequestModel transactionInitRequestModel =
  //       TransactionInitRequestModel(email: email, amount: amount);
  //   print(transactionInitRequestModel.toJson());
  //   paystackApi
  //       .initializeTransaction(transactionInitRequestModel)
  //       .then((value) async {
  //     Charge charge = Charge()
  //       ..amount = (fundAmount * 100).toInt()
  //       ..reference = value.reference
  //       ..accessCode = value.access_code
  //       ..email = email;
  //
  //     Uri url = Uri.parse(value.authorization_url);
  //     setState(() {
  //       _launched = _launchInWebViewOrVC(url);
  //       Timer(const Duration(seconds: 10), () {
  //         print('Closing WebView after 10 seconds...');
  //         closeInAppWebView();
  //       });
  //     });
  //     CheckoutResponse response =
  //         await plugin.checkout(context, charge: charge);
  //     Navigator.pop(context);
  //     if (response.message == 'Success' ||
  //         response.message == 'Transaction already succeeded') {
  //       // Call the verify transaction endpoint with the transactionID returned in `response.transactionId` to verify transaction before offering value to customer
  //       AccountTransactionRequestModel accountTransactionRequestModel =
  //           AccountTransactionRequestModel(amount: fundAmount);
  //       accountTransactionRequestModel.narration = narration;
  //       accountTransactionRequestModel.accountNumber = accountNumber;
  //       apiService
  //           .verifyDepositPayStack(
  //               accountTransactionRequestModel, value.reference, widget.token)
  //           .then((valueDep) {
  //         successTransactionAlert(valueDep);
  //       });
  //     } else {
  //       // Transaction not successful
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return const AlertDialog(
  //               title: Text("Notice"),
  //               content: Text("Transaction not successful"),
  //             );
  //           });
  //     }
  //   });
  // }

  Future<void> _launchInWebViewOrVC(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      throw 'Could not launch $url';
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _additionalAccount() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => ProgressHUD(
        inAsyncCall: isApiCallProcess,
        opacity: 0.3,
        child: Form(
          key: formKey,
          child: AlertDialog(
            title: const Text('Open Additional Account'),
            content: SizedBox(
              height: height * 0.2,
              width: width,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 15),
                  futureBundleListBuilder(),
                  const SizedBox(height: 10),
                  selectedProduct != null
                      ? Text(
                          selectedProduct!.displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        )
                      : Container(),
                  // const SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (validateAndSave()) {
                    setState(() {
                      isApiCallProcess = true;
                    });
                    apiService
                        .additionalAccount(
                            selectedProduct!.id.toString(), widget.token)
                        .then((value) {
                      setState(() {
                        isApiCallProcess = false;
                      });
                      if (value.customerWalletsList.isNotEmpty) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                title: Text(
                                  "Success",
                                  textAlign: TextAlign.center,
                                ),
                                // titlePadding: EdgeInsets.all(5.0),
                                content: Text(
                                  "Additional account opened successfully",
                                  textAlign: TextAlign.center,
                                ),
                                // contentPadding: EdgeInsets.all(5.0),
                              );
                            });
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HomeDrawer(
                                value: 0,
                                page: Dashboard(
                                  token: value.token,
                                  fullName:
                                      value.customerWalletsList[0].fullName,
                                  lastTransactions: value.lastTransactionsList,
                                  customerWallets: value.customerWalletsList,
                                ),
                                name: 'wallet',
                                fullName: value.customerWalletsList[0].fullName,
                                token: value.token,
                                customerWallets: value.customerWalletsList,
                                lastTransactionsList:
                                    value.lastTransactionsList),
                          ),
                        );
                      } else {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                title: Text(
                                  "Message",
                                  textAlign: TextAlign.center,
                                ),
                                // titlePadding: EdgeInsets.all(5.0),
                                content: Text(
                                  "Registration not successful",
                                  textAlign: TextAlign.center,
                                ),
                                // contentPadding: EdgeInsets.all(5.0),
                              );
                            });
                        Navigator.of(context).pop();
                      }
                    });
                  }
                },
                child: const Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }

  successTransactionAlert(message) {
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
                child: Center(
                  child: Text(
                    'Message',
                    style: GoogleFonts.montserrat(
                        color: Colors.blue,
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
                    message,
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
                    onPressed: () {
                      setState(() {
                        isApiCallProcess = true;
                      });
                      apiService.pageReload(widget.token).then((value) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        if (value.customerWalletsList.isNotEmpty) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HomeDrawer(
                                  value: 0,
                                  page: Dashboard(
                                    token: value.token,
                                    fullName:
                                        value.customerWalletsList[0].fullName,
                                    lastTransactions:
                                        value.lastTransactionsList,
                                    customerWallets: value.customerWalletsList,
                                  ),
                                  name: 'wallet',
                                  fullName:
                                      value.customerWalletsList[0].fullName,
                                  token: value.token,
                                  customerWallets: value.customerWalletsList,
                                  lastTransactionsList:
                                      value.lastTransactionsList),
                            ),
                          );
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Message"),
                                  content: Text(value.token),
                                );
                              });
                        }
                      });
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
                        style: GoogleFonts.montserrat(
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

  // Widget bottomTitles(double value, TitleMeta meta) {
  //   final titles = <String>['Mn', 'Te', 'Wd', 'Th', 'Fr', 'St', 'Su'];
  //
  //   final Widget text = Text(
  //     titles[value.toInt()],
  //     style: const TextStyle(
  //       color: Color(0xff7589a2),
  //       fontWeight: FontWeight.bold,
  //       fontSize: 14,
  //     ),
  //   );
  //
  //   return SideTitleWidget(
  //     axisSide: meta.axisSide,
  //     space: 16, //margin top
  //     child: text,
  //   );
  // }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.blue.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.blue.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.blue.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.blue.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.blue.withOpacity(0.4),
        ),
      ],
    );
  }
}

// Previous Code

// class Dashboard extends StatefulWidget {
//   final String fullName;
//   final String token;
//   final List<CustomerWalletsBalanceModel> customerWallets;
//   const Dashboard(
//       {Key? key,
//       required this.customerWallets,
//       required this.fullName,
//       required this.token})
//       : super(key: key);

//   @override
//   State<Dashboard> createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   final displayAmount = NumberFormat("#,##0.00", "en_US");
//   APIService apiService = APIService();
//   List<dynamic> itemData = [];
//   bool isApiCallProcess = false;
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   double fundAmount = 0;
//   List<ProductResponseModel> data = <ProductResponseModel>[
//     ProductResponseModel(
//       id: 0,
//       productName: 'Select Product',
//       displayName: 'Select Product',
//       description: 'Select Product',
//       interestRate: 0.0,
//       tenorDays: 0,
//       prematureCharge: 0.0,
//       normalCharge: 0.0,
//       defaultCharge: 0.0,
//       serviceCharge: 0.0,
//       referralPercentageCharge: 0.0,
//     )
//   ];
//   late ProductResponseModel currentProduct;
//   ProductResponseModel? selectedProduct;
//   var publicKey = 'pk_live_a6fbbb05e8b8e498674780e7dd0560d0cbc23670';
//   final plugin = PaystackPlugin();
//   Future<void>? _launched;

//   Future<List<ProductResponseModel>> getProducts() {
//     return apiService.getProducts();
//   }

//   Widget futureBundleListBuilder() {
//     return FutureBuilder<List<ProductResponseModel>>(
//       future: getProducts(),
//       builder: (context, snapshot) {

//         if (snapshot.hasData) {
//           List<ProductResponseModel> insideData = snapshot.data!;
//           // data.clear();
//           data = <ProductResponseModel>[
//             ProductResponseModel(
//               id: 0,
//               productName: 'Select Product',
//               displayName: 'Select Product',
//               description: 'Select Product',
//               interestRate: 0.0,
//               tenorDays: 0,
//               prematureCharge: 0.0,
//               normalCharge: 0.0,
//               defaultCharge: 0.0,
//               serviceCharge: 0.0,
//               referralPercentageCharge: 0.0,
//             )
//           ];
//           currentProduct = data[0];

//           for (var singleData in insideData) {
//             if(!singleData.productName.contains('loan') && !singleData.displayName.contains('loan')) {
//               data.add(singleData);
//             }
//           }

//           return FormField<ProductResponseModel>(
//               builder: (FormFieldState<ProductResponseModel> state) {
//                 return InputDecorator(
//                   decoration: InputDecoration(
//                     labelStyle: GoogleFonts.montserrat(
//                       color: const Color(0xff9ca2ac),
//                     ),
//                     errorStyle: GoogleFonts.montserrat(
//                       color: Colors.redAccent,
//                     ),
//                     hintText: 'Select Product',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   // isEmpty: currentProduct.biller_code == "",
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<ProductResponseModel>(
//                       alignment: AlignmentDirectional.centerEnd,
//                       value: currentProduct,
//                       isExpanded: true,
//                       isDense: true,
//                       onChanged: (newValue) {
//                         setState(() {
//                           currentProduct = newValue!;
//                           state.didChange(newValue);
//                           selectedProduct = newValue;
//                         });
//                       },
//                       items: data
//                           .map((map) => DropdownMenuItem<ProductResponseModel>(
//                         value: map,
//                         child: Center(child: Text(map.displayName, overflow: TextOverflow.ellipsis,)),
//                       ))
//                           .toList(),
//                     ),
//                   ),
//                 );
//               });
//         } else {
//           return const Text('Please wait Products loading...');
//         }
//       },
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     displayWallets(widget.customerWallets);
//     plugin.initialize(publicKey: publicKey);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 IconButton(
//                   padding: EdgeInsets.zero,
//                   onPressed: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => HomeDrawer(
//                               value: 1,
//                               page: Dashboard(
//                                 token: widget.token,
//                                 fullName: widget.fullName,
//                                 customerWallets: widget.customerWallets,
//                               ),
//                               name: 'wallet',
//                               token: widget.token,
//                               fullName: widget.fullName,
//                             )));
//                   },
//                   icon: Icon(
//                     Icons.menu,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 // Wallet Balance/Status

//                 Center(
//                   child: Text(
//                     'Wallet Balance',
//                     style: GoogleFonts.montserrat(
//                         color: const Color(0xff000080),
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 SizedBox(height: 10,),
//                 Center(
//                   child: Text(
//                     '(Tap to fund wallet)',
//                     style: GoogleFonts.roboto(
//                         color: const Color(0xff000080),
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 SizedBox(height: 30,),
//                 ListView.builder(
//                     physics: const BouncingScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: itemData.length,
//                     itemBuilder: (context, index) {
//                       return itemData[index];
//                     }),
//                 const SizedBox(height: 30),

//               ],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _additionalAccount,
//         tooltip: 'Additional Account',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   displayWallets(List<CustomerWalletsBalanceModel> responseList) {
//     List<Widget> histItems = [];
//     responseList.forEach((data) {
//       histItems.add(
//         Padding(
//           padding: const EdgeInsets.only(bottom: 13.0),
//           child: GestureDetector(
//             onTap: (){
//               fundWalletDialog(data.accountNumber);
//             },
//             child: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.all(Radius.circular(15.0)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 1,
//                       blurRadius: 2,
//                       offset: const Offset(3, 3),
//                     ),
//                   ]),
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Text('NGN', style: GoogleFonts.montserrat()),
//                     Text(
//                       displayAmount.format(data.balance),
//                       style: GoogleFonts.montserrat(
//                           fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xff000080),),
//                     ),
//                     Text(
//                       data.productName,
//                       style: GoogleFonts.montserrat(fontSize: 12),
//                     ),
//                     Text(
//                       data.accountNumber,
//                       style: GoogleFonts.montserrat(fontSize: 10, color: Colors.blueGrey),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//     setState(() {
//       itemData = histItems;
//     });

//     return Column(
//       children: histItems,
//     );
//   }

//   Future fundWalletDialog(String accountNumber) => showDialog(
//     context: context,
//     builder: (context) => ProgressHUD(
//       inAsyncCall: isApiCallProcess,
//       opacity: 0.3,
//       child: Form(
//         key: formKey,
//         child: AlertDialog(
//           title: const Text('Amount to fund'),
//           content: TextFormField(
//             autofocus: true,
//             onSaved: (input) => fundAmount = double.parse(input!.trim()),
//             validator: (input) =>
//             input!.isEmpty ? "Please enter amount" : null,
//             keyboardType:
//             const TextInputType.numberWithOptions(decimal: true),
//             decoration: InputDecoration(
//               hintText: 'Enter amount',
//               hintStyle: GoogleFonts.montserrat(
//                 color: const Color(0xff9ca2ac),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               prefix: Container(
//                 height: 14,
//                 width: 14,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage("assets/naira-black.png"),
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//               enabledBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: Colors.grey),
//               ),
//               focusedBorder: const UnderlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blue),
//               ),
//             ),
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 if (validateAndSave()) {
//                   setState(() {
//                     isApiCallProcess = false;
//                   });
//                   // _handlePaymentInitialization(accountNumber);
//                   _handlePaystackPayment(accountNumber);
//                 }
//               },
//               child: const Text('Submit'),
//             )
//           ],
//         ),
//       ),
//     ),
//   );

//   _handlePaymentInitialization(String accountNumber) async {
//     const String _FLUTTERWAVE_PUB_KEY =
//         "FLWPUBK-1598a88367443af15598a00b28119236-X";
//     var email = widget.customerWallets[0].email;
//     var displayName = widget.customerWallets[0].fullName;
//     var phoneNo = widget.customerWallets[0].phoneNo;

//     String narration = "Mobile App credit";
//     String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
//     String txRef = "$accountNumber.$datePart";

//     final style = FlutterwaveStyle(
//         appBarText: "Wallet Funding",
//         appBarTitleTextStyle: const TextStyle(color: Colors.white),
//         buttonColor: const Color(0XFF091841),
//         appBarIcon: const Icon(Icons.message, color: Color(0XFF091841)),
//         buttonTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//         appBarColor: const Color(0XFF091841),
//         dialogCancelTextStyle: const TextStyle(color: Colors.redAccent, fontSize: 18),
//         dialogContinueTextStyle: const TextStyle(color: Colors.blue, fontSize: 18),
//         dialogBackgroundColor: Colors.white,
//         buttonText: "Pay NGN$fundAmount");

//     final Customer customer =
//     Customer(name: displayName, phoneNumber: phoneNo, email: email);

//     final Flutterwave flutterwave = Flutterwave(
//         context: context,
//         style: style,
//         publicKey: _FLUTTERWAVE_PUB_KEY,
//         currency: "NGN",
//         redirectUrl: "my_redirect_url",
//         txRef: txRef,
//         amount: fundAmount.toString(),
//         customer: customer,
//         paymentOptions: "ussd, bank_transfer, card",
//         customization: Customization(title: "Landmark Coop Mobile funding"),
//         isTestMode: false);

//     final ChargeResponse response = await flutterwave.charge();
//     Navigator.pop(context);
//     if (response != null) {
//       if (response.success!) {
//         // Call the verify transaction endpoint with the transactionID returned in `response.transactionId` to verify transaction before offering value to customer
//         AccountTransactionRequestModel accountTransactionRequestModel = AccountTransactionRequestModel();
//         accountTransactionRequestModel.narration = narration;
//         accountTransactionRequestModel.amount = fundAmount;
//         accountTransactionRequestModel.accountNumber = accountNumber;
//         apiService
//             .verifyDeposit(
//             accountTransactionRequestModel, int.parse(response.transactionId!), widget.token)
//             .then((value) {
//           showDialog<void>(
//             context: context,
//             barrierDismissible: false, // user must tap button!
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Notice!'),
//                 content: SingleChildScrollView(
//                   child: ListBody(
//                     children: <Widget>[
//                       Text(value),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         });
//       } else {
//         // Transaction not successful
//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return const AlertDialog(
//                 title: Text("Notice"),
//                 content: Text("Transaction not successful"),
//               );
//             });
//       }
//     } else {
//       // User cancelled
//       showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return new AlertDialog(
//               title: new Text("Message"),
//               content: new Text("You cancelled the transaction!"),
//             );
//           });
//       setState(() {
//         isApiCallProcess = false;
//       });
//     }
//   }

//   _handlePaystackPayment(String accountNumber) async{
//     var email = widget.customerWallets[0].email;
//     var displayName = widget.customerWallets[0].fullName;
//     var phoneNo = widget.customerWallets[0].phoneNo;
//     var amount = (fundAmount * 100).toString();

//     String narration = "Mobile App credit";
//     String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());

//     PaystackApi paystackApi = PaystackApi();
//     TransactionInitRequestModel transactionInitRequestModel = TransactionInitRequestModel(email: email, amount: amount);
//     print(transactionInitRequestModel.toJson());
//     paystackApi.initializeTransaction(transactionInitRequestModel).then((value) async {
//       Charge charge = Charge()
//           ..amount = (fundAmount * 100).toInt()
//           ..reference = value.reference
//           ..accessCode = value.access_code
//           ..email = email;

//       Uri url = Uri.parse(value.authorization_url);
//       setState(() {
//         _launched = _launchInWebViewOrVC(url);
//         Timer(const Duration(seconds: 10), () {
//           print('Closing WebView after 10 seconds...');
//           closeInAppWebView();
//         });
//       });
//       CheckoutResponse response = await plugin.checkout(context, charge: charge);
//       Navigator.pop(context);
//       if(response.message == 'Success'){
//         // Call the verify transaction endpoint with the transactionID returned in `response.transactionId` to verify transaction before offering value to customer
//         AccountTransactionRequestModel accountTransactionRequestModel = AccountTransactionRequestModel();
//         accountTransactionRequestModel.narration = narration;
//         accountTransactionRequestModel.amount = fundAmount.toString();
//         accountTransactionRequestModel.accountNumber = accountNumber;
//         apiService
//             .verifyDepositPayStack(
//             accountTransactionRequestModel, value.reference, widget.token)
//             .then((valueDep) {
//           successTransactionAlert(valueDep);
//         });
//       } else {
//         // Transaction not successful
//         showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return const AlertDialog(
//                 title: Text("Notice"),
//                 content: Text("Transaction not successful"),
//               );
//             });
//       }
//     });
//   }

//   Future<void> _launchInWebViewOrVC(Uri url) async {
//     if (!await launchUrl(
//       url,
//       mode: LaunchMode.inAppWebView,
//       webViewConfiguration: const WebViewConfiguration(
//           headers: <String, String>{'my_header_key': 'my_header_value'}),
//     )) {
//       throw 'Could not launch $url';
//     }
//   }

//   bool validateAndSave() {
//     final form = formKey.currentState;
//     if (form!.validate()) {
//       form.save();
//       return true;
//     }
//     return false;
//   }

//   void _additionalAccount() {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//     showDialog(
//       context: context,
//       builder: (context) => ProgressHUD(
//         inAsyncCall: isApiCallProcess,
//         opacity: 0.3,
//         child: Form(
//           key: formKey,
//           child: AlertDialog(
//             title: const Text('Open Additional Account'),
//             content: SizedBox(
//               height: height * 0.2,
//               width: width,
//               child: Column(
//                 children: <Widget>[
//                   const SizedBox(height: 15),
//                   futureBundleListBuilder(),
//                   const SizedBox(height: 10),
//                   selectedProduct != null
//                       ? Text(
//                     selectedProduct!.displayName,
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 15),
//                   )
//                       : Container(),
//                   // const SizedBox(height: 10),
//                 ],),
//             ),
//             actions: [
//               ElevatedButton(
//                 onPressed: () {
//                   if (validateAndSave()) {
//                     setState(() {
//                       isApiCallProcess = true;
//                     });
//                     apiService.additionalAccount(selectedProduct!.id.toString(), widget.token).then((value) {
//                       setState(() {
//                         isApiCallProcess = false;
//                       });
//                       if (value.customerWalletsList.isNotEmpty) {
//                         showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return const AlertDialog(
//                                 title: Text(
//                                   "Success",
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 // titlePadding: EdgeInsets.all(5.0),
//                                 content: Text(
//                                   "Additional account opened successfully",
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 // contentPadding: EdgeInsets.all(5.0),
//                               );
//                             });
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => HomeDrawer(
//                               value: 0,
//                               page: Dashboard(
//                                 token: value.token,
//                                 fullName: value.customerWalletsList[0].fullName, customerWallets: value.customerWalletsList,
//                               ),
//                               name: 'wallet',
//                               fullName: value.customerWalletsList[0].fullName,
//                               token: value.token,
//                             ),
//                           ),
//                         );
//                       } else {
//                         setState(() {
//                           isApiCallProcess = false;
//                         });
//                         showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return const AlertDialog(
//                                 title: Text(
//                                   "Message",
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 // titlePadding: EdgeInsets.all(5.0),
//                                 content: Text(
//                                   "Registration not successful",
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 // contentPadding: EdgeInsets.all(5.0),
//                               );
//                             });
//                       }
//                     });
//                   }
//                 },
//                 child: const Text('Submit'),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   successTransactionAlert(message) {
//     return showDialog(
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(builder: (context, setState) {
//             return AlertDialog(
//               title: Container(
//                 height: 50,
//                 alignment: Alignment.centerLeft,
//                 padding: const EdgeInsets.only(left: 15),
//                 color: Colors.blue.shade200,
//                 child: Center(
//                   child: Text(
//                     'Message',
//                     style: GoogleFonts.montserrat(
//                         color: Colors.blue,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//               content:
//               Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
//                 Center(
//                   child: Text(
//                     'Notice',
//                     style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: Text(
//                     message,
//                     style: GoogleFonts.montserrat(
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ),
//               ]),
//               actionsAlignment: MainAxisAlignment.start,
//               actions: <Widget>[
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         isApiCallProcess = true;
//                       });
//                       apiService
//                           .pageReload(widget.token)
//                           .then((value) {
//                         setState(() {
//                           isApiCallProcess = false;
//                         });
//                         if (value.customerWalletsList.isNotEmpty) {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => HomeDrawer(
//                                 value: 0,
//                                 page: Dashboard(
//                                   token: value.token,
//                                   fullName: value.customerWalletsList[0].fullName, customerWallets: value.customerWalletsList,
//                                 ),
//                                 name: 'wallet',
//                                 fullName: value.customerWalletsList[0].fullName,
//                                 token: value.token,
//                               ),
//                             ),
//                           );
//                         } else {
//                           showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return new AlertDialog(
//                                   title: new Text("Message"),
//                                   content: new Text(
//                                       value.token),
//                                 );
//                               });
//                         }
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey.shade200,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 10, horizontal: 10),
//                       child: Text(
//                         "Ok",
//                         style: GoogleFonts.montserrat(
//                           color: Colors.blue,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           });
//         });
//   }

// }
