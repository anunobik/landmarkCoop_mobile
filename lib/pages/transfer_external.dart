import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_flutterwave.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/login_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/custom_text_form_field.dart';
import '../model/push_notification.dart';
import '../util/ProgressHUD.dart';
import 'package:intl/intl.dart';
import '../util/home_drawer.dart';
import '../util/notification_badge.dart';
import 'dashboard.dart';
import 'enter_transaction_pin.dart';

class TransferExternal extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const TransferExternal({
    super.key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.lastTransactions,
  });

  @override
  State<TransferExternal> createState() => _TransferExternalState();
}

class _TransferExternalState extends State<TransferExternal> {
  bool isApiCallProcess = false;
  bool isBankDialogShown = false;
  bool isTransferDialogShown = false;
  CustomerWalletsBalanceModel? selectedWallet;
  List<dynamic> itemData = [];
  TextEditingController amountController = TextEditingController();
  TextEditingController bankAcctNumController = TextEditingController();
  TextEditingController bankAcctNameController = TextEditingController();
  TextEditingController narrationController = TextEditingController();
  String bank = 'Select Bank';
  List<CustomerWalletsBalanceModel> data = <CustomerWalletsBalanceModel>[
    CustomerWalletsBalanceModel(
        id: 0,
        accountNumber: 'Select Account',
        balance: 0,
        productName: '',
        fullName: '',
        email: '',
        phoneNo: '',
        interBankName: '',
        nubanAccountNumber: 'Select Account', trackNumber: '')
  ];
  CustomerWalletsBalanceModel? currentWallet;
  bool showBankWidgets = true;
  List<BankListResponseModel> bankData = <BankListResponseModel>[
    BankListResponseModel(id: 0, code: '', name: 'Select Bank')
  ];
  BankListResponseModel? currentBank;
  BankListResponseModel? selectedBank;
  late FocusNode focusNode;
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  LoginRequestModel loginRequestModel = LoginRequestModel();
  bool isMinervaHub = false;
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  late ExternalBankTransferDetailsRequestModel
      externalBankTransferDetailsRequestModel;

  @override
  void initState() {
    super.initState();
    loadAccountAccounts();
    getBanks();
    focusNode = FocusNode();
    externalBankTransferDetailsRequestModel =
        ExternalBankTransferDetailsRequestModel();
    focusNode.addListener(() => setState(() {}));
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
            background: const Color(0XFF091841).withOpacity(0.7),
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
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });

        // API Sign in token
        APIService apiService = APIService();
        apiService.login(loginRequestModel).then((value) {
          if (value.customerWalletsList.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeDrawer(
                  value: 0,
                  page: Dashboard(
                    token: widget.token,
                    fullName: widget.fullName, customerWallets: widget.customerWallets,
                    lastTransactions: widget.lastTransactions,
                  ),
                  name: 'wallet',
                  token: widget.token,
                  fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactionsList: widget.lastTransactions,
                ),
              ),
            );
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

  loadAccountAccounts() {
    currentWallet = data[0];
    for (var singleData in widget.customerWallets) {
      data.add(singleData);
    }
    setState(() {
      data;
    });
  }

  getBanks() {
    FlutterWaveService apiCore = FlutterWaveService();
    return apiCore.getAllBanks(widget.token).then((value) {
      currentBank = bankData[0];

      for (var singleData in value) {
        bankData.add(singleData);
      }
      setState(() {
        bankData;
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(children: <Widget>[
                  const SizedBox(height: 20),
                  dropDownWallets(),
                  const SizedBox(height: 30),
                  CustomTextFormField(
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    hintText: "Amount",
                    enabled: true,
                  ),
                  const SizedBox(height: 30),
                  //Todo display the bank info here
                  showBankWidgets ? displayBankWidget() : Container(),
                  const SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: narrationController,
                    maxLength: 30,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Narration",
                      hintStyle: GoogleFonts.montserrat(
                        color: const Color(0xff9ca2ac),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 0.7),
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
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      String subdomain = prefs.getString('subdomain') ??
                          'https://core.landmarkcooperative.org';

                      APIService apiService = APIService();
                      if (double.parse(amountController.text) <
                              currentWallet!.balance ||
                          double.parse(amountController.text) ==
                              currentWallet!.balance) {
                        if (double.parse(amountController.text) < 200) {
                          setState(() {
                            isApiCallProcess = false;
                          });
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  title: Text("Notice",
                                      textAlign: TextAlign.center),
                                  content: Text(
                                    "Amount must be above NGN200!",
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              });
                        } else {
                          setState(() {
                            isTransferDialogShown = true;
                          });
                          externalBankTransferDetailsRequestModel.amount =
                              amountController.text.trim();
                          externalBankTransferDetailsRequestModel.narration =
                              narrationController.text;

                          confirmTransferDetails(
                            externalBankTransferDetailsRequestModel,
                            context,
                            onClosed: (context) {
                              setState(() {
                                isTransferDialogShown = false;
                              });
                            },
                          );
                        }
                      } else {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                title: Text("Notice"),
                                content: Text("Insufficient Balance"),
                              );
                            });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Text(
                        'Send',
                        style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ]),
              ),
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
                externalBankTransferDetailsRequestModel.sourceAccountNumber =
                    newValue.accountNumber;

                String datePart =
                    DateFormat('yymmddhhmmss').format(DateTime.now());
                String txRef = "${newValue.accountNumber}_$datePart";
                externalBankTransferDetailsRequestModel.reference = txRef;
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

  // Drop Down Banks
  Future<Object?> selectBank(BuildContext context,
      {required ValueChanged onClosed,
      required List<BankListResponseModel> bankList}) {
    var width = MediaQuery.of(context).size.width;
    TextEditingController bankController = TextEditingController();
    bankList.sort(
      (a, b) => a.name.compareTo(b.name),
    );
    List<BankListResponseModel> searchList = [];
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: 'Select Bank',
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, __, child) {
        Tween<Offset> tween;
        tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
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
        void onSearchBank(value) {
          setState(() {
            searchList = bankList
                .where((element) => element.name
                    .toString()
                    .toLowerCase()
                    .contains(value.toString().toLowerCase()))
                .toList();
          });
        }

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
                  Column(
                    children: [
                      Text('Select Bank',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: width * 0.55,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: bankController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Search',
                                hintStyle: GoogleFonts.montserrat(
                                  color: const Color(0xff9ca2ac),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: onSearchBank,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  bankController.text = '';
                                  searchList = [];
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: Text(
                                'Clear',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                      searchList.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: searchList.length,
                                cacheExtent: 0,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 13.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              currentBank = searchList[index];
                                              selectedBank = searchList[index];
                                              bank = searchList[index].name;
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                left: 10, top: 5, right: 10),
                                            alignment: Alignment.centerLeft,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                searchList[index]
                                                    .name
                                                    .toString(),
                                                style: GoogleFonts.montserrat(
                                                  color:
                                                      const Color(0XFF091841),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Divider(thickness: 2.0),
                                    ],
                                  );
                                },
                              ),
                            )
                          : bankList.isNotEmpty
                              ? Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: bankList.length,
                                    cacheExtent: 0,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 13.0),
                                            child: GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  currentBank = bankList[index];
                                                  selectedBank =
                                                      bankList[index];
                                                  bank = bankList[index].name;
                                                  bankAcctNameController.text =
                                                      '';
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 10,
                                                    top: 5,
                                                    right: 10),
                                                alignment: Alignment.centerLeft,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    bankList[index]
                                                        .name
                                                        .toString(),
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      color: const Color(
                                                          0XFF091841),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(thickness: 2.0),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'Please check your internet connection',
                                    style: GoogleFonts.montserrat(
                                      color: const Color(0XFF091841),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                    ],
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
                  //       color: Colors.black,
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

  Widget displayBankWidget() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Future.delayed(const Duration(milliseconds: 800), () {
              setState(() {
                isBankDialogShown = true;
              });
              selectBank(
                context,
                bankList: bankData,
                onClosed: (context) {
                  setState(() {
                    isBankDialogShown = false;
                  });
                },
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 50,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Spacer(),
                Text(
                  bank,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
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
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            controller: bankAcctNumController,
            enabled: true,
            textAlign: TextAlign.center,
            onChanged: (value) {
              setState(() {
                if (value.length == 10) {
                  FlutterWaveService apiCore = FlutterWaveService();
                  BankAccountRequestModel bankAcctRequest =
                      BankAccountRequestModel();
                  bankAcctRequest.account_bank = currentBank!.code;
                  bankAcctRequest.account_number = value;

                  externalBankTransferDetailsRequestModel.accountBank =
                      currentBank!.code;
                  externalBankTransferDetailsRequestModel.accountNumber = value;
                  externalBankTransferDetailsRequestModel
                      .destinationAccountNumber = value;
                  externalBankTransferDetailsRequestModel.destinationBankName =
                      currentBank!.name;

                  apiCore.bankAccountVerify(bankAcctRequest, widget.token).then((valueAcct) {
                    bankAcctNameController.text = valueAcct;
                    externalBankTransferDetailsRequestModel
                        .destinationAccountName = valueAcct;
                  });
                } else {
                  bankAcctNameController.text = '';
                }
              });
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Bank Account No.',
              hintStyle: GoogleFonts.montserrat(
                color: const Color(0xff9ca2ac),
              ),
              filled: true,
              fillColor: Colors.white,
              hoverColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          keyboardType: TextInputType.number,
          controller: bankAcctNameController,
          textAlign: TextAlign.center,
          enabled: false,
          style: GoogleFonts.montserrat(
              fontSize: 15,
              color: const Color(0XFF091841),
              fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            isDense: true,
            hintText: "Account Name",
            hintStyle: GoogleFonts.montserrat(
              color: const Color(0xff9ca2ac),
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: Colors.grey, width: 0.7),
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
      ],
    );
  }

  // Confirm Transfer

  Future<Object?> confirmTransferDetails(
    ExternalBankTransferDetailsRequestModel requestModel,
    BuildContext context, {
    required ValueChanged onClosed,
  }) {
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: 'Confirm Transfer',
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, __, child) {
        Tween<Offset> tween;
        tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
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
        var width = MediaQuery.of(context).size.width;
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Review Transfer Details',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: const Color(0xff000080),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 20),
                      const Divider(
                        height: 1,
                        color: Color(0XFF091841),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Send to',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.4,
                            child: Text(
                              requestModel.destinationAccountName,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.montserrat(
                                color: const Color(0xff000080),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        height: 1,
                        color: Color(0XFF091841),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Account number',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.4,
                            child: Text(
                              requestModel.destinationAccountNumber,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.montserrat(
                                color: const Color(0xff000080),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        height: 1,
                        color: Color(0XFF091841),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Bank',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.4,
                            child: Text(
                              requestModel.destinationBankName,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.montserrat(
                                color: const Color(0xff000080),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        height: 1,
                        color: Color(0XFF091841),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Amount',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.4,
                            child: Text(
                              displayAmount
                                  .format(int.parse(requestModel.amount)),
                              textAlign: TextAlign.end,
                              style: GoogleFonts.montserrat(
                                color: const Color(0xff000080),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        height: 1,
                        color: Color(0XFF091841),
                      ),
                      const SizedBox(height: 10),
                      // const Divider(
                      //   height: 1,
                      //   color: Color(0XFF091841),
                      // ),
                      // const SizedBox(height: 15),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: <Widget>[
                      //     Text(
                      //       'From',
                      //       style: GoogleFonts.montserrat(
                      //         color: Colors.lightBlue,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     RichText(
                      //       text: TextSpan(
                      //           text: widget.fullName,
                      //           style: GoogleFonts.montserrat(
                      //             color: const Color(0xff000080),
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //           children: <TextSpan>[
                      //             TextSpan(
                      //               text: requestModel.sourceAccountNumber,
                      //               style: GoogleFonts.montserrat(
                      //                 color: const Color(0xff000080),
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ]),
                      //       textAlign: TextAlign.end,
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 10),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: <Widget>[
                      //     Text(
                      //       'Account Available\nBalance',
                      //       style: GoogleFonts.montserrat(
                      //         color: Colors.lightBlue,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: width * 0.4,
                      //       child: Text(
                      //         '₦50000',
                      //         textAlign: TextAlign.end,
                      //         style: GoogleFonts.montserrat(
                      //           color: const Color(0xff000080),
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Remarks',
                            style: GoogleFonts.montserrat(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: width * 0.4,
                            child: Text(
                              requestModel.narration,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.montserrat(
                                color: const Color(0xff000080),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        height: 1,
                        color: Color(0XFF091841),
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EnterTransactionPin(
                                    customerWallets: widget.customerWallets,
                                    fullName: widget.fullName,
                                    token: widget.token,
                                    externalBankTransferDetailsRequestModel:
                                        externalBankTransferDetailsRequestModel,
                                    lastTransactions: widget.lastTransactions,
                                  )));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Confirm Transfer',
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800),
                          ),
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    ).then((onClosed));
  }
}
