import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
// import 'package:flutterwave_standard/flutterwave.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:landmarkcoop_latest/api/api_service.dart';
import 'package:landmarkcoop_latest/entry_point.dart';
import 'package:landmarkcoop_latest/model/customer_model.dart';
import 'package:landmarkcoop_latest/model/login_model.dart';
import 'package:landmarkcoop_latest/model/other_model.dart';
import 'package:landmarkcoop_latest/model/push_notification.dart';
import 'package:landmarkcoop_latest/pages/airtime_tabs.dart';
import 'package:landmarkcoop_latest/pages/bottomPages/customer_care.dart';
import 'package:landmarkcoop_latest/pages/cable_tv.dart';
import 'package:landmarkcoop_latest/pages/investment.dart';
import 'package:landmarkcoop_latest/pages/investment_cert.dart';
import 'package:landmarkcoop_latest/pages/logout_page.dart';
import 'package:landmarkcoop_latest/pages/statement_screen.dart';
import 'package:landmarkcoop_latest/pages/transfer_details.dart';
import 'package:landmarkcoop_latest/pages/transfer_external.dart';
import 'package:landmarkcoop_latest/pages/utility_bill.dart';
import 'package:landmarkcoop_latest/utils/ProgressHUD.dart';
import 'package:landmarkcoop_latest/utils/notification_badge.dart';
import 'package:landmarkcoop_latest/widgets/bottom_nav_bar.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../utils/InactivityService.dart';

enum Pay { bank, recharge }

class Dashboard extends StatefulWidget {
  final int pageIndex;
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const Dashboard({
    super.key,
    required this.pageIndex,
    required this.fullName,
    required this.token,
    required this.customerWallets,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Pay? pay = Pay.bank;
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  List<dynamic> itemData = [];
  bool isApiCallProcess = false;
  bool isFundingDialogShown = false;
  bool isTransferDialogShown = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKeyTrf = GlobalKey<FormState>();
  double fundAmount = 0;
  double fundTrfAmount = 0;
  String _contact = 'Tap to get phone number';
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
  List<BranchResponseModel> dataBranch = <BranchResponseModel>[
    BranchResponseModel(
      id: 0,
      branchName: 'Select Branch',
      displayName: 'Select Branch',
      address: 'Select Branch',
    )
  ];
  BranchResponseModel? currentBranch;
  BranchResponseModel? selectedBranch;

  // final plugin = PaystackPlugin();
  Future<void>? _launched;
  late GatewayResponseModel gateWayResponse;
  CustomerAccountDisplayModel? customerAccountDisplayModel;
  bool disableSendMoneyBtn = true;
  bool disableAcctToAcctMoneyBtn = true;
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
        limitsEnabled: false,
        limitAmount: 50000,
      limitBalance: 0,
    )
  ];
  List<CustomerWalletsBalanceModel> viewWallet = [];
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  LoginRequestModel loginRequestModel = LoginRequestModel();
  bool readPolicy = false;
  bool isMinervaHub = true;
  bool isBvnLinked = false;
  bool showWallet = false;
  late int noOfInvestments;
  double totalInvestments = 0;
  double roi = 0;
  bool investExist = false;
  List<CustomerInvestmentWalletModel> investData =
      <CustomerInvestmentWalletModel>[];
  List<ExternalBankTransferHistoryResponseModel> dataTrf = [];
  final List<Map<String, String>> slides = [
    {
      "image": 'assets/pics/wealth-creation.jpg',
      "heading": "Wealth Creation",
      "description": "Coming Soon",
    },
    {
      "image": 'assets/pics/health-insurance.jpg',
      "heading": "Health Insurance",
      "description":
          "Coming Soon",
    },
    {
      "image": 'assets/pics/home-sale.jpg',
      "heading": "Home For Sale",
      "description":
          "Coming Soon",
    },
    {
      "image": 'assets/pics/laplage.jpg',
      "heading": "La Plage Meta Verse",
      "description": "100% Online Learning",
    },
  ];

  int currentIndex = 0;

  // Get Products

  Future<List<ProductResponseModel>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    return apiService.getProducts();
  }

  Future<void> checkFintech() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    String institution = prefs.getString('institution') ?? 'Minerva Hub';
    if (institution == 'https://core.landmarkcooperative.org' ||
        institution.isEmpty) {
      isMinervaHub = true;
    }
  }

  getAllInvestment() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    String institution = prefs.getString('institution') ?? 'Minerva Hub';
    APIService apiService = APIService(subdomain_url: subdomain);
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
                isDense: true,
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

  loadGateWay() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    return apiService.getActivePaymentGateway().then((value) {
      gateWayResponse = value;
      setState(() {
        gateWayResponse;
        // if (gateWayResponse.gatewayName == 'Paystack') {
        //   plugin.initialize(publicKey: gateWayResponse.publicKey);
        // }
      });
    });
  }

  // Make A Phone Call
  Future<void> _makePhoneCall(int amount) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '*321*09068841765*$amount*0000#',
    );
    await launchUrl(launchUri);
  }

  @override
  void initState() {
    InactivityService().initializeInactivityTimer(context, widget.token);
    loadGateWay();
    getBranches();
    getCustomerWallets();
    checkFintech();
    loadLastTenTransfers();
    getAllInvestment();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if (mounted) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'notificationTitle', message.notification!.title.toString());
        await prefs.setString(
            'notificationBody', message.notification!.body.toString());
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });
        if (notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(
              notificationInfo!.title!,
              style: GoogleFonts.montserrat(),
            ),
            leading: NotificationBadge(totalNotifications: totalNotifications),
            subtitle: Text(
              notificationInfo!.body!,
              style: GoogleFonts.montserrat(),
            ),
            background: Color(0xff000080).withOpacity(0.7),
            duration: const Duration(seconds: 2),
          );
        }
        pushNotify();
      }
    });

    // Open to notification screen
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'notificationTitle', message.notification!.title.toString());
        await prefs.setString(
            'notificationBody', message.notification!.body.toString());
        String subdomain =
            prefs.getString('subdomain') ?? 'core.landmarkcooperative.org';
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });

        // API Sign in token
        APIService apiService = APIService(subdomain_url: subdomain);
        apiService.login(loginRequestModel).then((value) {
          if (value.customerWalletsList.isNotEmpty) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => EntryPoint(
                      customerWallets: value.customerWalletsList,
                      fullName: value.customerWalletsList[0].fullName,
                      screenName: 'Notification',
                      subdomain: subdomain,
                      token: value.token,
                      referralId: value.customerWalletsList[0].phoneNo,
                    )));
            notificationList.add({
              'title': message.notification!.title,
              'body': message.notification!.body,
            });
          }
        });
      }
    });
    totalNotifications = 0;
    pushNotify();
    super.initState();
  }

  void pushNotify() async {
    final prefs = await SharedPreferences.getInstance();
    String notificationTitle = prefs.getString('notificationTitle') ?? '';
    String notificationBody = prefs.getString('notificationBody') ?? '';
    print('Body - $notificationBody');
    if (notificationTitle != '') {
      setState(() {
        notificationList.add({
          'title': notificationTitle,
          'body': notificationBody,
        });
      });
    }
  }

  Future<void> loadLastTenTransfers() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    String institution = prefs.getString('institution') ?? 'Minerva Hub';

    APIService apiService = APIService(subdomain_url: subdomain);
    apiService.lastTenTransfers(widget.token).then((value) {
      setState(() {
        dataTrf = value;
      });
    });
  }

  getCustomerWallets() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    return apiService.pageReload(widget.token).then((value) {
      currentWallet = dataWallet[0];
      for (var singleData in value.customerWalletsList) {
        dataWallet.add(singleData);
        viewWallet.add(singleData);
      }
      if (viewWallet[0].interBankName.isNotEmpty) {
        setState(() {
          isBvnLinked = true;
        });
      }
      setState(() {
        displayWallets(viewWallet);
        showWallet = true;
      });
    });
  }

  getBranches() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    return apiService.getAllBranches().then((value) {
      currentBranch = dataBranch[0];

      for (var singleData in value) {
        dataBranch.add(singleData);
      }
      setState(() {
        dataBranch;
      });
    });
  }

  Route _routeToSignInScreen(Widget newScreen) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => newScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(-1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
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
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // Returning false prevents the app from closing
        return false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          InactivityService().resetInactivityTimer(context, widget.token);
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 40),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // Ensures the text stays centered and icon goes to the end
                            children: [
                              Text(
                                'Welcome',
                                style: GoogleFonts.montserrat(
                                  // color: Color(0xff000080),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '${widget.fullName} !',
                                style: GoogleFonts.montserrat(
                                  // color: Color(0xff000080),
                                  fontSize: 12,
                                ),
                              ),
                            ]),
                        IconButton(
                          icon: Icon(
                            Icons.headset_mic, // Help icon
                            color: Colors.white, // Icon color
                            size: 18, // Icon size, can be adjusted
                          ),
                          onPressed: () async {
                            // Handle button press
                            final prefs = await SharedPreferences.getInstance();
                            String subdomain = prefs.getString('subdomain') ??
                                'https://core.landmarkcooperative.org';
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => ContactCustomerSupport(
                                    pageIndex: 3,
                                    fullName: widget.fullName,
                                    token: widget.token,
                                    customerWallets: widget.customerWallets,
                                    referralId:
                                        widget.customerWallets[0].phoneNo,
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // Ensures the text stays centered and icon goes to the end
                      children: [
                        // Empty container or widget to hold the start of the row
                        SizedBox(width: 40),
                        // You can adjust the width based on your design

                        // Centered Text Widget
                        Expanded(
                          child: Center(
                            child: Text(
                              'Wallet Balance',
                              style: GoogleFonts.montserrat(
                                // color: Color(0xff000080),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        // Help Desk Icon
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.logout_rounded, // Help icon
                                color: Colors.red, // Icon color
                                size: 18, // Icon size, can be adjusted
                              ),
                              onPressed: () async {
                                // Handle button press
                                final prefs =
                                    await SharedPreferences.getInstance();
                                String subdomain =
                                    prefs.getString('subdomain') ??
                                        'https://core.landmarkcooperative.org';
                                Future.delayed(const Duration(seconds: 2), () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LogoutPage(token: widget.token),
                                    ),
                                  );
                                });
                              },
                            ),
                            // Text("Log Out",
                            //   style: GoogleFonts.montserrat(
                            //         color: Colors.red,
                            //         fontSize: 10,
                            //         fontWeight: FontWeight.w600,
                            //   )),
                          ],
                        ),
                      ],
                    ),
                    // const SizedBox(height: 5),
                    // Center(
                    //   child: Text(
                    //     '(Tap to fund wallet)',
                    //     style: GoogleFonts.roboto(
                    //       // color: Color(0xff000080),
                    //       fontSize: 13,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 5),
                    showWallet
                        ? Container(
                            padding: const EdgeInsets.only(left: 10),
                            height: 140,
                            width: width,
                            child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: itemData.length,
                                itemBuilder: (context, index) {
                                  return itemData[index];
                                }),
                          )
                        : Center(
                            child: Text(
                              'Loading...',
                              style: GoogleFonts.montserrat(
                                  // color: const Color(0xff000080),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                    itemData.length > 1
                        ? const Center(
                            child: Icon(
                              Icons.swipe,
                              size: 10,
                              // color: Color(0xff000080),
                            ),
                          )
                        : const SizedBox(),
                    itemData.length > 1
                        ? Center(
                            child: Text(
                              'Swipe to view your wallets',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 10,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(),

                    // Other Dashboard Options

                    Container(
                      padding: const EdgeInsets.all(20),
                      // height: height,
                      width: width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.only(
                        //   topRight: Radius.circular(150),
                        // ),
                      ),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 2),
                          isMinervaHub
                              ? Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              // Evenly space the buttons
                                              children: [
                                                // Button 1
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        // Handle button press
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        String subdomain = prefs
                                                                .getString(
                                                                    'subdomain') ??
                                                            'https://core.landmarkcooperative.org';
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  TransferExternal(
                                                                token: widget
                                                                    .token,
                                                                customerWallets:
                                                                    widget
                                                                        .customerWallets,
                                                                fullName: widget
                                                                    .fullName,
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape: CircleBorder(),
                                                        // Circular shape
                                                        padding: EdgeInsets.all(
                                                            20), // Adjust padding to make the button circular
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .align_horizontal_right_rounded,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ), // Icon inside the button
                                                    ),
                                                    SizedBox(height: 8),
                                                    // Space between button and text
                                                    Text('Transfer',
                                                        style: TextStyle(
                                                            fontSize: 15)),
                                                    // Label under the button
                                                  ],
                                                ),
                                                // Button 2
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        // Handle button press
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        String subdomain = prefs
                                                                .getString(
                                                                    'subdomain') ??
                                                            'https://core.landmarkcooperative.org';
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      AirtimeTabs(
                                                                token: widget
                                                                    .token,
                                                                customerWallets:
                                                                    widget
                                                                        .customerWallets,
                                                                fullName: widget
                                                                    .fullName,
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape: CircleBorder(),
                                                        // Circular shape
                                                        padding: EdgeInsets.all(
                                                            20), // Adjust padding to make the button circular
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .phone_android_rounded,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ), // Icon inside the button
                                                    ),
                                                    SizedBox(height: 8),
                                                    // Space between button and text
                                                    Text('Airtime/Data',
                                                        style: TextStyle(
                                                            fontSize: 15)),
                                                    // Label under the button
                                                  ],
                                                ),
                                                // Button 3
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        // Handle button press
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        String subdomain = prefs
                                                                .getString(
                                                                    'subdomain') ??
                                                            'https://core.landmarkcooperative.org';
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      CableTv(
                                                                token: widget
                                                                    .token,
                                                                customerWallets:
                                                                    widget
                                                                        .customerWallets,
                                                                fullName: widget
                                                                    .fullName,
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape: CircleBorder(),
                                                        // Circular shape
                                                        padding: EdgeInsets.all(
                                                            20), // Adjust padding to make the button circular
                                                      ),
                                                      child: Icon(
                                                        Icons.tv_sharp,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ), // Icon inside the button
                                                    ),
                                                    SizedBox(height: 8),
                                                    // Space between button and text
                                                    Text('Cable Tv',
                                                        style: TextStyle(
                                                            fontSize: 15)),
                                                    // Label under the button
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              // Evenly space the buttons
                                              children: [
                                                // Button 1
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        // Handle button press
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        String subdomain = prefs
                                                                .getString(
                                                                    'subdomain') ??
                                                            'https://core.landmarkcooperative.org';
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  StatementScreen(
                                                                token: widget
                                                                    .token,
                                                                fullName: widget
                                                                    .fullName,
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape: CircleBorder(),
                                                        // Circular shape
                                                        padding: EdgeInsets.all(
                                                            20), // Adjust padding to make the button circular
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .file_copy_outlined,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ), // Icon inside the button
                                                    ),
                                                    SizedBox(height: 8),
                                                    // Space between button and text
                                                    Text('Statement',
                                                        style: TextStyle(
                                                            fontSize: 15)),
                                                    // Label under the button
                                                  ],
                                                ),
                                                // Button 2
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        // Handle button press
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        String subdomain = prefs
                                                                .getString(
                                                                    'subdomain') ??
                                                            'https://core.landmarkcooperative.org';

                                                        APIService apiService =
                                                            APIService(
                                                                subdomain_url:
                                                                    subdomain);
                                                        OnlineRateResponseModel
                                                            interestRate =
                                                            await apiService
                                                                .getOnlineRate(
                                                                    widget
                                                                        .token);

                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Investment(
                                                                token: widget
                                                                    .token,
                                                                fullName: widget
                                                                    .fullName,
                                                                interestRate:
                                                                    interestRate,
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape: CircleBorder(),
                                                        // Circular shape
                                                        padding: EdgeInsets.all(
                                                            20), // Adjust padding to make the button circular
                                                      ),
                                                      child: Icon(
                                                        Icons.money_outlined,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ), // Icon inside the button
                                                    ),
                                                    SizedBox(height: 8),
                                                    // Space between button and text
                                                    Text('Investment',
                                                        style: TextStyle(
                                                            fontSize: 15)),
                                                    // Label under the button
                                                  ],
                                                ),
                                                // Button 3
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        // Handle button press
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        String subdomain = prefs
                                                                .getString(
                                                                    'subdomain') ??
                                                            'https://core.landmarkcooperative.org';
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          Navigator.of(context)
                                                              .pushReplacement(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      UtilityBill(
                                                                token: widget
                                                                    .token,
                                                                customerWallets:
                                                                    widget
                                                                        .customerWallets,
                                                                fullName: widget
                                                                    .fullName,
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        shape: CircleBorder(),
                                                        // Circular shape
                                                        padding: EdgeInsets.all(
                                                            20), // Adjust padding to make the button circular
                                                      ),
                                                      child: Icon(
                                                        Icons.lightbulb,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ), // Icon inside the button
                                                    ),
                                                    SizedBox(height: 8),
                                                    // Space between button and text
                                                    Text('Bills Pay',
                                                        style: TextStyle(
                                                            fontSize: 15)),
                                                    // Label under the button
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Center(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                _transferToLaplageWallet();
                                              },
                                              icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                                              label: Text(
                                                'Fund LaPlage Wallet',
                                                style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    dataTrf.isNotEmpty
                                        ? Container(
                                            padding: const EdgeInsets.all(5),
                                            width: width,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              // Shrink-wraps the column's children
                                              children: <Widget>[
                                                Flexible(
                                                  child: ListView.builder(
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        dataTrf.length > 3
                                                            ? 3
                                                            : dataTrf.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  TransferDetails(
                                                                accountNumber:
                                                                    dataTrf[index]
                                                                        .destinationAccountNumber,
                                                                amount:
                                                                    "${displayAmount.format(dataTrf[index].amount)}",
                                                                bank: dataTrf[
                                                                        index]
                                                                    .destinationBankName,
                                                                beneficiary: dataTrf[
                                                                        index]
                                                                    .destinationAccountName,
                                                                narration: dataTrf[
                                                                        index]
                                                                    .completeMessage,
                                                                status: dataTrf[
                                                                        index]
                                                                    .status,
                                                                date: dataTrf[
                                                                        index]
                                                                    .timeCreated
                                                                    .substring(
                                                                        0, 10),
                                                                time: dataTrf[
                                                                        index]
                                                                    .timeCreated
                                                                    .substring(
                                                                        10,
                                                                        dataTrf[index]
                                                                            .timeCreated
                                                                            .length),
                                                                customerWallets:
                                                                    widget
                                                                        .customerWallets,
                                                                fullName: widget
                                                                    .fullName,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 10),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                offset:
                                                                    const Offset(
                                                                        4, 4),
                                                                color: Colors
                                                                    .grey
                                                                    .shade200,
                                                                blurRadius: 4,
                                                                spreadRadius: 2,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                children: <Widget>[
                                                                  Icon(
                                                                    Icons
                                                                        .outbond_outlined,
                                                                    color: dataTrf[index].status ==
                                                                            'SUCCESSFUL'
                                                                        ? Colors
                                                                            .green
                                                                        : dataTrf[index].status ==
                                                                                'FAILED'
                                                                            ? Colors.red
                                                                            : Colors.blue,
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          10),
                                                                  Flexible(
                                                                    // Use Flexible here to manage overflow
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <Widget>[
                                                                        Text(
                                                                          dataTrf[index]
                                                                              .destinationAccountName,
                                                                          style: GoogleFonts.montserrat(
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 12),
                                                                          overflow:
                                                                              TextOverflow.ellipsis, // Ensures long text is handled
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                5),
                                                                        AutoSizeText(
                                                                          dataTrf[index]
                                                                              .completeMessage,
                                                                          maxLines:
                                                                              3,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              GoogleFonts.montserrat(
                                                                            fontSize:
                                                                                10,
                                                                            // fontWeight: FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: <Widget>[
                                                                  const SizedBox(
                                                                      width:
                                                                          35),
                                                                  Text(
                                                                    "₦${displayAmount.format(dataTrf[index].amount)}",
                                                                    style: GoogleFonts
                                                                        .montserrat(
                                                                            // fontWeight: FontWeight.w700,
                                                                            ),
                                                                  ),
                                                                  const Spacer(),
                                                                  AutoSizeText(
                                                                    dataTrf[index]
                                                                        .timeCreated
                                                                        .substring(
                                                                            0,
                                                                            10),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: GoogleFonts
                                                                        .montserrat(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              'You have not made any transfers yet',
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 24,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                    investExist
                                        ? GestureDetector(
                                            onTap: () {
                                              // Add navigation or any other functionality
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      InvestmentCert(
                                                    fullName: widget.fullName,
                                                    token: widget.token,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              height: height * 0.18,
                                              width: width,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    // Shadow color
                                                    blurRadius: 10,
                                                    offset: const Offset(5,
                                                        5), // Shadow position
                                                  ),
                                                ],
                                              ),
                                              child: LayoutBuilder(builder:
                                                  (context, constraints) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    // Top Header with a bold black text
                                                    Center(
                                                      child: Text(
                                                        'INVESTMENT OVERVIEW',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 14),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.white,
                                                      // Divider between header and content
                                                      thickness: 1,
                                                    ),
                                                    // Investment Details Section
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .account_balance_wallet,
                                                            color: Colors.white,
                                                            size: 30),
                                                        // Investment Icon
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'No. of Investments: $noOfInvestments',
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      maxWidth:
                                                                          constraints
                                                                              .maxWidth),
                                                              child: Text(
                                                                'Total Investment: NGN ${displayAmount.format(totalInvestments)}',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      maxWidth:
                                                                          constraints
                                                                              .maxWidth),
                                                              child: Text(
                                                                'Expected R.O.I: NGN ${displayAmount.format(roi)}',
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Carousel Slider
                                          CarouselSlider.builder(
                                            itemCount: slides.length,
                                            itemBuilder: (context, index, realIndex) {
                                              final slide = slides[index];
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white.withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                      offset: Offset(4, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      // Image with larger size
                                                      Expanded(
                                                        flex: 4, // Increased flex for image
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: Image.asset(
                                                            slide["image"]!,
                                                            fit: BoxFit.contain, // Ensures the image scales proportionally
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 20),
                                                      // Text column with reduced size
                                                      Expanded(
                                                        flex: 2,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              slide["heading"]!,
                                                              style: TextStyle(
                                                                fontSize: 15, // Increased font size
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.blueAccent,
                                                              ),
                                                            ),
                                                            SizedBox(height: 10),
                                                            Text(
                                                              slide["description"]!,
                                                              style: TextStyle(
                                                                fontSize: 10, // Slightly larger description font
                                                                color: Colors.black54,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            options: CarouselOptions(
                                              height: 350, // Increased height for the carousel
                                              autoPlay: true,
                                              enlargeCenterPage: true,
                                              autoPlayInterval: Duration(seconds: 3),
                                              onPageChanged: (index, reason) {
                                                setState(() {
                                                  currentIndex = index;
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          buildDots(),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 5),
                                  ],
                                )
                              : Container(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Text(
                //   'Additional Account',
                //   style: GoogleFonts.montserrat(fontSize: 10.0),
                // ),
                SizedBox(width: 8.0), // Adjust the spacing as needed
                FloatingActionButton(
                  onPressed: _additionalAccount,
                  tooltip: 'Additional Account',
                  child: const Icon(Icons.add),
                    backgroundColor: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Display Wallets
  displayWallets(List<CustomerWalletsBalanceModel> responseList) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    List<Widget> histItems = [];

    for (var data in responseList) {
      histItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0, right: 13.0),
          child: GestureDetector(
            onTap: () {
              // Future.delayed(const Duration(milliseconds: 800), () {
              //   setState(() {
              //     isFundingDialogShown = true;
              //   });
              //   selectFundingOptions(
              //     context,
              //     accountNumber: data.accountNumber,
              //     onClosed: (context) {
              //       setState(() {
              //         isFundingDialogShown = false;
              //       });
              //     },
              //   );
              // });
            },
            child: Container(
              width: width * 0.9,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(3, 3),
                    ),
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Wallet details
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'NGN',
                          // style: GoogleFonts.montserrat(color: Colors.white),
                        ),
                        Text(
                          displayAmount.format(data.balance),
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data.productName,
                          style: GoogleFonts.montserrat(fontSize: 14),
                        ),
                        Text(
                          isBvnLinked
                              ? data.nubanAccountNumber
                              : data.accountNumber,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        isBvnLinked
                            ? LayoutBuilder(builder: (context, constraints) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth: constraints.maxWidth),
                                  child: Text(
                                    '${data.interBankName}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              })
                            : Container(),
                        SizedBox(height: 5),
                        Text('Current Limit: NGN${displayAmount.format(data.limitBalance)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Share icon
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.black54),
                    onPressed: () {
                      final accountDetails =
                          "Account Number: ${isBvnLinked ? data.nubanAccountNumber : data.accountNumber}\n"
                          "Account Name: ${widget.fullName}\n"
                          "Bank: ${isBvnLinked ? data.interBankName : "No Bank Name"}";

                      Share.share(accountDetails);
                    },
                  ),
                ],
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

  // Payment Initializer
  // _handlePaymentInitialization(String accountNumber) async {
  //   String FLUTTERWAVE_PUB_KEY = gateWayResponse.publicKey;
  //   var email = widget.customerWallets[0].email;
  //   var displayName = widget.customerWallets[0].fullName;
  //   var phoneNo = widget.customerWallets[0].phoneNo;
  //
  //   String narration = "Mobile App credit";
  //   String datePart = DateFormat('yymmddhhmmss').format(DateTime.now());
  //   String txRef = "$accountNumber.$datePart";
  //
  //   // final style = FlutterwaveStyle(
  //   //     appBarText: "Wallet Funding",
  //   //     appBarTitleTextStyle: const TextStyle(color: Colors.white),
  //   //     buttonColor: Color(0xff000080),
  //   //     appBarIcon: const Icon(Icons.message, color: Color(0xff01440a)),
  //   //     buttonTextStyle: const TextStyle(
  //   //         color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
  //   //     appBarColor: Color(0xff000080),
  //   //     dialogCancelTextStyle:
  //   //     const TextStyle(color: Colors.redAccent, fontSize: 18),
  //   //     dialogContinueTextStyle:
  //   //     const TextStyle(color: Colors.blue, fontSize: 18),
  //   //     dialogBackgroundColor: Colors.white,
  //   //     buttonText: "Pay NGN$fundAmount");
  //
  //   final Customer customer =
  //       Customer(name: displayName, phoneNumber: phoneNo, email: email);
  //   print("Flutterwave Hre");
  //   final Flutterwave flutterwave = Flutterwave(
  //       context: context,
  //       // style: style,
  //       publicKey: FLUTTERWAVE_PUB_KEY,
  //       currency: "NGN",
  //       redirectUrl:
  //           "https://core.landmarkcooperative.org/verifyBanktransfer/IHd88sdBGAasdfRYEGRh76asf05052023",
  //       txRef: txRef,
  //       amount: fundAmount.toString(),
  //       customer: customer,
  //       paymentOptions: "ussd, bank_transfer, card",
  //       // paymentOptions: "ussd, bank_transfer",
  //       customization: Customization(title: "Mobile funding"),
  //       isTestMode: false);
  //
  //   final ChargeResponse response = await flutterwave.charge();
  //   Navigator.pop(context);
  //   print(response.toJson());
  //   if (response != null) {
  //     if (!response.success!) {
  //       // Call the verify transaction endpoint with the transactionID returned in `response.transactionId` to verify transaction before offering value to customer
  //       AccountTransactionRequestModel accountTransactionRequestModel =
  //           AccountTransactionRequestModel(amount: fundAmount);
  //       accountTransactionRequestModel.narration = narration;
  //       accountTransactionRequestModel.accountNumber = accountNumber;
  //       final prefs = await SharedPreferences.getInstance();
  //       String subdomain =
  //           prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
  //
  //       APIService apiService = APIService(subdomain_url: subdomain);
  //       apiService
  //           .verifyDeposit(
  //               accountTransactionRequestModel,
  //               int.parse(response.transactionId!),
  //               response.txRef!,
  //               widget.token)
  //           .then((value) {
  //         successTransactionAlert(value);
  //       });
  //     } else {
  //       failTransactionAlert("Transaction not successful");
  //     }
  //   } else {
  //     // User cancelled
  //     showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return const AlertDialog(
  //             title: Text("Message"),
  //             content: Text("You cancelled the transaction!"),
  //           );
  //         });
  //     setState(() {
  //       isApiCallProcess = false;
  //     });
  //   }
  // }

  // Paystack Payments
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
  //   TransactionInitRequestModel(email: email, amount: amount);
  //   print(transactionInitRequestModel.toJson());
  //   paystackApi
  //       .initializeTransaction(
  //       transactionInitRequestModel, gateWayResponse.secretKey)
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
  //     await plugin.checkout(context, charge: charge);
  //     Navigator.pop(context);
  //     if (response.message == 'Success') {
  //       final prefs = await SharedPreferences.getInstance();
  //       String subdomain =
  //           prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
  //
  //       APIService apiService = APIService(subdomain_url: subdomain);
  //       // Call the verify transaction endpoint with the transactionID returned in `response.transactionId` to verify transaction before offering value to customer
  //       AccountTransactionRequestModel accountTransactionRequestModel =
  //       AccountTransactionRequestModel(amount: fundAmount);
  //       accountTransactionRequestModel.narration = narration;
  //       accountTransactionRequestModel.accountNumber = accountNumber;
  //       apiService
  //           .verifyDepositPayStack(
  //           accountTransactionRequestModel, value.reference, widget.token)
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

  bool validateAndSaveTrf() {
    final form = formKeyTrf.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Open Additional Accounts
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
            title: Text(
              'Open Additional Account',
              style: GoogleFonts.montserrat(
                color: const Color(0xff000080),
              ),
            ),
            content: SizedBox(
              height: height * 0.25,
              width: width,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 15),
                  futureBundleListBuilder(),
                  const SizedBox(height: 10),
                  selectedProduct != null
                      ? Text(
                          selectedProduct!.displayName,
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        )
                      : Container(),
                  const SizedBox(height: 10),
                  branchBuilder(),
                  // const SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  String subdomain = prefs.getString('subdomain') ??
                      'https://core.landmarkcooperative.org';

                  APIService apiService = APIService(subdomain_url: subdomain);
                  if (validateAndSave()) {
                    setState(() {
                      isApiCallProcess = true;
                    });
                    apiService
                        .additionalAccount(selectedProduct!.id.toString(),
                            selectedBranch!.id.toString(), widget.token)
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
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: Text(
                  'Submit',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Open Additional Accounts
  void _transferToLaplageWallet() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    CustomerWalletsBalanceModel selectedWallet = widget.customerWallets[0];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool dialogLoading = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return ProgressHUD(
              inAsyncCall: dialogLoading,
              opacity: 0.3,
              child: Form(
                key: formKey,
                child: AlertDialog(
                  title: Text(
                    'Funding Your LaPlage Wallet',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff000080),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 15),
                        StatefulBuilder(
                          builder: (context, setStateSB) {
                            return DropdownButtonFormField<CustomerWalletsBalanceModel>(
                              decoration: InputDecoration(
                                labelText: 'Select Account',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: widget.customerWallets.map((w) {
                                final acct = isBvnLinked ? w.nubanAccountNumber : w.accountNumber;
                                return DropdownMenuItem<CustomerWalletsBalanceModel>(
                                    value: w,
                                    child: Text('$acct')
                                );
                              }).toList(),
                              onChanged: (val) {
                                setStateSB(() {
                                  selectedWallet = val!;
                                });
                              },
                              validator: (val) => val == null || val.accountNumber.isEmpty
                                  ? 'Please select an account' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Enter Amount',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Please enter an amount' : null,
                          onSaved: (val) => fundAmount = double.parse(val!),
                        ),
                        // const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  actions: [
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔴 Cancel Button
                          ElevatedButton(
                            onPressed: dialogLoading
                                ? null
                                : () {
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          const SizedBox(width: 15),

                          // 🔵 Submit Button
                          ElevatedButton(
                            onPressed: dialogLoading
                                ? null
                                : () async {
                              if (!formKey.currentState!.validate()) return;
                              formKey.currentState!.save();

                              if (selectedWallet.balance < fundAmount) {
                                showDialog(
                                  context: context,
                                  builder: (_) => const AlertDialog(
                                    title: Text("Message",
                                        textAlign: TextAlign.center),
                                    content: Text("Insufficient Funds",
                                        textAlign: TextAlign.center),
                                  ),
                                );
                                return;
                              }

                              setStateDialog(() {
                                dialogLoading = true;
                              });

                              try {
                                final prefs =
                                await SharedPreferences.getInstance();
                                final subdomain =
                                    prefs.getString('subdomain') ??
                                        'https://core.landmarkcooperative.org';

                                APIService apiService =
                                APIService(subdomain_url: subdomain);

                                final result =
                                await apiService.transferFundsToLaPlageWallet(
                                  fundAmount,
                                  selectedWallet.accountNumber,
                                  widget.token,
                                );

                                setStateDialog(() {
                                  dialogLoading = false;
                                });

                                Navigator.pop(dialogContext);

                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(
                                      result.status ? "Success" : "Message",
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Text(
                                      result.message,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                setStateDialog(() {
                                  dialogLoading = false;
                                });

                                showDialog(
                                  context: context,
                                  builder: (_) => const AlertDialog(
                                    title: Text("Error",
                                        textAlign: TextAlign.center),
                                    content: Text(
                                        "Something went wrong. Please try again."),
                                  ),
                                );
                              }
                            },
                            child: dialogLoading
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text("Sending...",
                                    style: TextStyle(color: Colors.white)),
                              ],
                            )
                                : const Text("Submit"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

  }

  // Success Transaction Alert
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
                color: Color(0xff000080),
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
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      String subdomain = prefs.getString('subdomain') ??
                          'https://core.landmarkcooperative.org';

                      APIService apiService =
                          APIService(subdomain_url: subdomain);
                      setState(() {
                        isApiCallProcess = true;
                      });
                      apiService.pageReload(widget.token).then((value) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        if (value.customerWalletsList.isNotEmpty) {
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
                          color: Color(0xff000080),
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

  // Select Funding Options
  Future<Object?> selectFundingOptions(BuildContext context,
      {required ValueChanged onClosed, required String accountNumber}) {
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: 'Select Funding Options',
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, __, child) {
        Tween<Offset> tween;
        tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        return SlideTransition(
          position: tween.animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
      },
      context: context,
      pageBuilder: (context, _, __) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Center(
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
                        Text('Select Any Funding Option',
                            style: GoogleFonts.montserrat(
                              color: const Color(0xff000080),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Radio(
                                activeColor: Colors.lightBlue,
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.lightBlue),
                                value: Pay.bank,
                                groupValue: pay,
                                onChanged: (Pay? value) {
                                  setState(() {
                                    pay = value;
                                  });
                                }),
                            const SizedBox(width: 20),
                            Text(
                              'Bank Transfer/ATM',
                              style: GoogleFonts.montserrat(
                                color: Color(0xff000080),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pay == Pay.bank
                            ? const SizedBox(height: 20)
                            : Container(),
                        pay == Pay.bank
                            ? Form(
                                key: formKey,
                                child: TextFormField(
                                  autofocus: true,
                                  onSaved: (input) =>
                                      fundAmount = double.parse(input!.trim()),
                                  validator: (input) => input!.isEmpty
                                      ? "Please enter amount"
                                      : null,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                    hintText: 'Enter amount to fund',
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
                                          image: AssetImage(
                                              "assets/pics/naira-black.png"),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        pay == Pay.bank
                            ? const SizedBox(height: 10)
                            : Container(),
                        pay == Pay.bank
                            ? ElevatedButton(
                                onPressed: () {
                                  if (validateAndSave()) {
                                    setState(() {
                                      isApiCallProcess = false;
                                    });
                                    // _handlePaymentInitialization(accountNumber);
                                    // if (gateWayResponse.gatewayName ==
                                    //     'Paystack') {
                                    //   _handlePaystackPayment(accountNumber);
                                    // } else {
                                    //   _handlePaymentInitialization(
                                    //       accountNumber);
                                    // }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                child: Text(
                                  'Continue',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 30),
                        Row(
                          children: <Widget>[
                            Radio(
                                activeColor: Colors.lightBlue,
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.lightBlue),
                                value: Pay.recharge,
                                groupValue: pay,
                                onChanged: (Pay? value) {
                                  setState(() {
                                    pay = value;
                                  });
                                }),
                            const SizedBox(width: 20),
                            Text(
                              'Recharge Card (MTN)',
                              style: GoogleFonts.montserrat(
                                color: Color(0xff000080),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pay == Pay.recharge
                            ? const SizedBox(height: 20)
                            : Container(),
                        pay == Pay.recharge
                            ? Text(
                                'Kindly make sure that you have your MTN Share And Sell set up before using this feature. Make sure to change the default pin (0000) to your preferred pin.',
                                style: GoogleFonts.montserrat(),
                              )
                            : Container(),
                        pay == Pay.recharge
                            ? const SizedBox(height: 10)
                            : Container(),
                        pay == Pay.recharge
                            ? Form(
                                key: formKey,
                                child: TextFormField(
                                  autofocus: true,
                                  onSaved: (input) =>
                                      fundAmount = double.parse(input!),
                                  validator: (input) => input!.isEmpty
                                      ? "Please enter amount"
                                      : null,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                    hintText: 'Enter amount',
                                    hintStyle: GoogleFonts.openSans(
                                      color: const Color(0xff9ca2ac),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefix: Container(
                                      height: 14,
                                      width: 14,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/pics/naira-black.png"),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        pay == Pay.recharge
                            ? ElevatedButton(
                                onPressed: () {
                                  if (validateAndSave()) {
                                    setState(() {
                                      isApiCallProcess = false;
                                    });
                                    if (fundAmount > 50) {
                                      _makePhoneCall(fundAmount.toInt());
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const AlertDialog(
                                              title: Text(
                                                "Important Notice!",
                                                textAlign: TextAlign.center,
                                              ),
                                              content: Text(
                                                "Amount must be more than NGN50 "
                                                "else call 08147312529 or email - contactcenter@landmarkcooperative.org "
                                                "for other funding less than NGN50",
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          });
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                child: Text(
                                  'Continue',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  // const Positioned(
                  //   left: 0,
                  //   right: 0,
                  //   bottom: -48,
                  //   child: CircleAvatar(
                  //     radius: 16,
                  //     backgroundColor: Colors.white,
                  //     child: Icon(
                  //       Icons.close,
                  //       color: Colors.white,
                  //     ),
                  //   )
                  // )
                ],
              ),
            ),
          ),
        );
      }),
    ).then((onClosed));
  }

  // Transfer To Landmark Coop Users
  Future<Object?> transferToOziUsers(BuildContext context,
      {required ValueChanged onClosed}) {
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: 'Select From Your Phone Contacts',
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, __, child) {
        Tween<Offset> tween;
        tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        return SlideTransition(
          position: tween.animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
      },
      context: context,
      pageBuilder: (context, _, __) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            height: 550,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Send Money',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xff000080),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 20),
                      Text('Tap to select from your phone contacts',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: const Color(0xff000080),
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          String subdomain = prefs.getString('subdomain') ??
                              'https://core.landmarkcooperative.org';

                          // final granted =
                          //     await FlutterContactPicker.hasPermission();

                          //Todo confirm if privacy policy has been read
                          readPolicy = prefs.getBool('readPolicy') ?? false;

                          if (!readPolicy) {
                            readAndAcceptPolicy();
                            acceptOrRejectPolicy();
                          } else {
                            // if (!granted) {
                            //   await FlutterContactPicker.requestPermission();
                            // }
                            // final PhoneContact contact =
                            //     await FlutterContactPicker.pickPhoneContact();
                            // if (contact.phoneNumber!.number!.substring(0, 4) ==
                            //     '+234') {
                            //   var newPhone = contact.phoneNumber!.number!
                            //       .replaceAll('+234', '0');
                            //   setState(() {
                            //     _contact = newPhone.replaceAll(" ", "");
                            //   });
                            // } else {
                            //   setState(() {
                            //     _contact = contact.phoneNumber!.number!;
                            //   });
                            // }
                            APIService apiServicePhone =
                                new APIService(subdomain_url: subdomain);
                            apiServicePhone
                                .getAccountFromPhone(
                                    _contact.replaceAll(' ', ''), widget.token)
                                .then((value) {
                              setState(() {
                                customerAccountDisplayModel = value;
                                if (value.displayName.isNotEmpty) {
                                  disableSendMoneyBtn = false;
                                } else {
                                  disableSendMoneyBtn = true;
                                }
                              });
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Icon(CupertinoIcons.phone,
                                  color: Color(0xff000080)),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                _contact,
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      customerAccountDisplayModel != null
                          ? Container(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Account Number:   ',
                                        style: GoogleFonts.montserrat(
                                          color: const Color(0xff000080),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        customerAccountDisplayModel!
                                            .accountNumber,
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    customerAccountDisplayModel!.displayName,
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: disableSendMoneyBtn
                            ? null
                            : () {
                                _transferToOzi();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.montserrat(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Positioned(
                      left: 0,
                      right: 0,
                      bottom: -48,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ))
                ],
              ),
            ),
          ),
        );
      }),
    ).then((onClosed));
  }

  failTransactionAlert(String message) {
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

  // Dots indicator for the slider
  Widget buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(slides.length, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index ? Colors.black : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget branchBuilder() {
    return FormField<BranchResponseModel>(
        builder: (FormFieldState<BranchResponseModel> state) {
      return InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          labelStyle: GoogleFonts.montserrat(
            color: const Color(0xff9ca2ac),
          ),
          errorStyle: GoogleFonts.montserrat(
            color: Colors.redAccent,
          ),
          hintText: 'Select Branch',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // isEmpty: currentProduct.biller_code == "",
        child: DropdownButtonHideUnderline(
          child: DropdownButton<BranchResponseModel>(
            alignment: AlignmentDirectional.centerEnd,
            value: currentBranch,
            isDense: true,
            isExpanded: true,
            onChanged: (newValue) {
              setState(() {
                currentBranch = newValue!;
                state.didChange(newValue);
                selectedBranch = newValue;
              });
            },
            items: dataBranch
                .map((map) => DropdownMenuItem<BranchResponseModel>(
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
  }

  // Open Additional Accounts
  void _transferToOzi() {
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
            title: Text(
              'Amount to Transfer',
              style: GoogleFonts.montserrat(
                color: const Color(0xff000080),
              ),
            ),
            content: SizedBox(
              height: height * 0.25,
              width: width,
              child: Column(
                children: [
                  Form(
                    key: formKeyTrf,
                    child: TextFormField(
                      style: const TextStyle(fontSize: 18.0),
                      autofocus: true,
                      onSaved: (input) =>
                          fundTrfAmount = double.parse(input!.trim()),
                      validator: (input) =>
                          input!.isEmpty ? "Please enter amount" : null,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Enter amount to transfer',
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  dropDownWallets(),
                  // const SizedBox(height: 10),
                  // selectedWallet != null ? Center(
                  //   child: Text(
                  //     selectedWallet!.productName,
                  //     style: GoogleFonts.montserrat(
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 15,
                  //     ),
                  //   ),
                  // )
                  //     : Container(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    String subdomain = prefs.getString('subdomain') ??
                        'https://core.landmarkcooperative.org';

                    APIService apiService =
                        APIService(subdomain_url: subdomain);

                    if (validateAndSaveTrf()) {
                      AccountToAccountRequestModel
                          accountToAccountRequestModel =
                          new AccountToAccountRequestModel(
                              fromAccountNumber: selectedWallet!.accountNumber,
                              toAccountNumber:
                                  customerAccountDisplayModel!.accountNumber,
                              amount: fundTrfAmount);
                      setState(() {
                        isApiCallProcess = true;
                      });
                      apiService
                          .internalTransfer(
                              accountToAccountRequestModel, widget.token)
                          .then((value) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        successTransactionAlert(value);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
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
                if (selectedWallet!.fullName.isNotEmpty) {
                  disableAcctToAcctMoneyBtn = false;
                } else {
                  disableAcctToAcctMoneyBtn = true;
                }
              });
            },
            items: dataWallet
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

  // void _loadHtml(WebViewController _controller, html) async {
  //   final String contentBase64 =
  //       base64Encode(const Utf8Encoder().convert(html));
  //   await _controller.loadUrl('data:text/html;base64,$contentBase64');
  // }

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
                color: Color(0xff000080),
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
                          color: Color(0xff000080),
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
