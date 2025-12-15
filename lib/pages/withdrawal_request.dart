import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:landmarkcoop_latest/entry_point.dart';
import 'package:landmarkcoop_latest/model/other_model.dart';
import 'package:landmarkcoop_latest/model/push_notification.dart';
import 'package:landmarkcoop_latest/pages/transfer_external.dart';
import 'package:landmarkcoop_latest/utils/notification_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../api/api_flutterwave.dart';
import '../api/api_service.dart';
import '../component/custom_text_form_field.dart';
import '../model/customer_model.dart';
import '../model/login_model.dart';
import '../utils/ProgressHUD.dart';

class WithdrawalRequest extends StatefulWidget {
  final String fullName;
  final String token;
  final String subdomain;
  final List<CustomerWalletsBalanceModel> customerWallets;
  const WithdrawalRequest(
      {Key? key,
        required this.customerWallets,
        required this.fullName,
        required this.token,
        required this.subdomain
      }): super(key: key);

  @override
  State<WithdrawalRequest> createState() => _WithdrawalRequestState();
}

class _WithdrawalRequestState extends State<WithdrawalRequest> {
  bool isApiCallProcess = false;
  bool isBankDialogShown = false;
  CustomerWalletsBalanceModel? selectedWallet;
  List<dynamic> itemData = [];
  TextEditingController amountController = TextEditingController();
  TextEditingController bankAcctNumController = TextEditingController();
  TextEditingController bankAcctNameController = TextEditingController();
  List<String> requestType = ['Select Request Type', 'Cash', 'Transfer Request'];
  List<String> requestTypeInstant = ['Select Request Type', 'Cash', 'Instant Transfer'];
  String currentRequestType = "Select Request Type";
  String bank = 'Select Bank';
  List<CustomerWalletsBalanceModel> data = <CustomerWalletsBalanceModel>[
    CustomerWalletsBalanceModel(
        id: 0,
        accountNumber: 'Select Account',
        balance: 0,
        productName: '',
        fullName: '',
        email: '',
        phoneNo: '', interBankName: '', nubanAccountNumber: 'Select Account',limitsEnabled: false,
        limitAmount: 50000,
      limitBalance: 0,)
  ];
  CustomerWalletsBalanceModel? currentWallet;
  late WithdrawalRequestModel withdrawalRequestModel;
  bool showBankWidgets = false;
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
  bool isBvnLinked = false;
  bool isMinervaHub = false;

  @override
  void initState() {
    super.initState();
    loadAccountAccounts();
    checkFintech();
    withdrawalRequestModel = WithdrawalRequestModel();
    getBanks();
    focusNode = FocusNode();
    focusNode.addListener(() => setState(() {}));
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if (mounted) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('notificationTitle', message.notification!.title.toString());
        await prefs.setString('notificationBody', message.notification!.body.toString());
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });
        if (notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(notificationInfo!.title!,
              style: GoogleFonts.montserrat(),
            ),
            leading: NotificationBadge(totalNotifications: totalNotifications),
            subtitle: Text(notificationInfo!.body!,
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
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
      if(mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('notificationTitle', message.notification!.title.toString());
        await prefs.setString('notificationBody', message.notification!.body.toString());
        String subdomain = prefs.getString('subdomain') ?? 'core.landmarkcooperative.org';
        setState(() {
          notificationInfo = notification;
          totalNotifications++;
        });

        // API Sign in token
        APIService apiService = APIService(subdomain_url: subdomain);
        apiService.login(loginRequestModel).then((value) {
          if (value.customerWalletsList.isNotEmpty) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context)=> EntryPoint(
                  customerWallets: value.customerWalletsList,
                  fullName: value.customerWalletsList[0].fullName,
                  screenName: 'Notification',
                  subdomain: subdomain,
                  token: value.token,
                  referralId: value.customerWalletsList[0].phoneNo,
                ),
              ),
            );
            notificationList.add({
              'title' : message.notification!.title,
              'body' : message.notification!.body,
            });
          }});
      }}
    );
    totalNotifications = 0;
    pushNotify();
    if (widget.customerWallets[0].interBankName.isNotEmpty) {
      setState(() {
        isBvnLinked = true;
      });
    }
  }

  Future<void> checkFintech() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    String institution = prefs.getString('institution') ?? 'Minerva Hub';
    if (institution == 'Landmark Coop' ||
        subdomain == null ||
        institution.isEmpty) {
      isMinervaHub = true;
    }
  }

  void pushNotify() async{
    final prefs = await SharedPreferences.getInstance();
    String notificationTitle = prefs.getString('notificationTitle') ?? '';
    String notificationBody = prefs.getString('notificationBody') ?? '';
    print('Body - $notificationBody');
    if(notificationTitle != '') {
      setState((){
        notificationList.add({
          'title' : notificationTitle,
          'body' : notificationBody,
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

  getBanks(){
    FlutterWaveService flutterWaveService = FlutterWaveService();
    return flutterWaveService.getAllBanks(widget.token).then((value) {
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
              isMinervaHub? isBvnLinked?
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(children: <Widget>[
                  const SizedBox(height: 50),
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
                        hintText: 'Select Request Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      isEmpty: currentRequestType == "",
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          alignment: AlignmentDirectional.centerEnd,
                          value: currentRequestType,
                          isDense: true,
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              currentRequestType = newValue!;
                              state.didChange(newValue);
                            });
                            if (currentRequestType == 'Instant Transfer') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TransferExternal(
                                        customerWallets:
                                        widget.customerWallets,
                                        fullName: widget.fullName,
                                        token: widget.token,
                                      ),
                                ),
                              );
                            }else{
                              showBankWidgets = false;
                            }
                          },
                          items: requestTypeInstant
                              .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value)),
                          ))
                              .toList(),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  //Todo display the bank info here
                  showBankWidgets ? displayBankWidget() : Container(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async{
                      final prefs = await SharedPreferences.getInstance();
                      String subdomain = prefs.getString('subdomain') ??
                          'https://core.landmarkcooperative.org';

                      APIService apiService =
                      APIService(subdomain_url: subdomain);
                      if (double.parse(amountController.text) <
                          currentWallet!.balance) {
                        setState(() {
                          isApiCallProcess = true;
                        });
                        withdrawalRequestModel.amount = amountController.text;
                        withdrawalRequestModel.accountNumber =
                            currentWallet!.accountNumber;
                        withdrawalRequestModel.requestType = currentRequestType;
                        if (currentRequestType == 'Instant Transfer') {
                          withdrawalRequestModel.bankName = currentBank!.name;
                          withdrawalRequestModel.bankAccountNo = bankAcctNumController.text;
                          withdrawalRequestModel.bankAccountName = bankAcctNameController.text;
                        }
                        apiService
                            .withdrawalRequest(
                            withdrawalRequestModel, widget.token)
                            .then((value) {
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
                                  content: Text(value, textAlign: TextAlign.center,),
                                  actionsAlignment: MainAxisAlignment.start,
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        String subdomain = prefs.getString('subdomain') ??
                                            'https://core.landmarkcooperative.org';

                                        APIService apiService =
                                        APIService(subdomain_url: subdomain);
                                        setState(() {
                                          apiService.pageReload(widget.token).then((value) {
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => EntryPoint(
                                                fullName: widget.fullName,
                                                token: value.token,
                                                screenName: "Home",
                                                subdomain: widget.subdomain,
                                                customerWallets: value.customerWalletsList,
                                                referralId: value.customerWalletsList[0].phoneNo,
                                              ),
                                            )
                                            );
                                          });
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
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
                          borderRadius: BorderRadius.circular(15)
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text('Send',
                        style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                ]),
              ) :
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(children: <Widget>[
                  const SizedBox(height: 50),
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
                        hintText: 'Select Request Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      isEmpty: currentRequestType == "",
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          alignment: AlignmentDirectional.centerEnd,
                          value: currentRequestType,
                          isDense: true,
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              currentRequestType = newValue!;
                              state.didChange(newValue);
                            });
                            if (currentRequestType == 'Transfer Request') {
                              showBankWidgets = true;
                              getBanks();
                            }else{
                              showBankWidgets = false;
                            }
                          },
                          items: requestType
                              .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value)),
                          ))
                              .toList(),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  //Todo display the bank info here
                  showBankWidgets ? displayBankWidget() : Container(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async{
                      final prefs = await SharedPreferences.getInstance();
                      String subdomain = prefs.getString('subdomain') ??
                          'https://core.landmarkcooperative.org';

                      APIService apiService =
                      APIService(subdomain_url: subdomain);
                      if (double.parse(amountController.text) <
                          currentWallet!.balance) {
                        setState(() {
                          isApiCallProcess = true;
                        });
                        withdrawalRequestModel.amount = amountController.text;
                        withdrawalRequestModel.accountNumber =
                            currentWallet!.accountNumber;
                        withdrawalRequestModel.requestType = currentRequestType;
                        if (currentRequestType == 'Bank Transfer') {
                          withdrawalRequestModel.bankName = currentBank!.name;
                          withdrawalRequestModel.bankAccountNo = bankAcctNumController.text;
                          withdrawalRequestModel.bankAccountName = bankAcctNameController.text;
                        }
                        apiService
                            .withdrawalRequest(
                            withdrawalRequestModel, widget.token)
                            .then((value) {
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
                                  content: Text(value, textAlign: TextAlign.center,),
                                  actionsAlignment: MainAxisAlignment.start,
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        String subdomain = prefs.getString('subdomain') ??
                                            'https://core.landmarkcooperative.org';

                                        APIService apiService =
                                        APIService(subdomain_url: subdomain);
                                        setState(() {
                                          apiService.pageReload(widget.token).then((value) {
                                            Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) => EntryPoint(
                                                  fullName: widget.fullName,
                                                  token: value.token,
                                                  screenName: "Home",
                                                  subdomain: widget.subdomain,
                                                  customerWallets: value.customerWalletsList,
                                                  referralId: value.customerWalletsList[0].phoneNo,
                                                ),
                                              )
                                            );
                                          });
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
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
                          borderRadius: BorderRadius.circular(15)
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text('Send',
                        style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                ]),
              ) : Container(
                padding: const EdgeInsets.all(20),
                child: Column(children: <Widget>[
                  const SizedBox(height: 50),
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
                        hintText: 'Select Request Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      isEmpty: currentRequestType == "",
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          alignment: AlignmentDirectional.centerEnd,
                          value: currentRequestType,
                          isDense: true,
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              currentRequestType = newValue!;
                              state.didChange(newValue);
                            });
                            if (currentRequestType == 'Transfer Request') {
                              showBankWidgets = true;
                              getBanks();
                            }else{
                              showBankWidgets = false;
                            }
                          },
                          items: requestType
                              .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value)),
                          ))
                              .toList(),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  //Todo display the bank info here
                  showBankWidgets ? displayBankWidget() : Container(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async{
                      final prefs = await SharedPreferences.getInstance();
                      String subdomain = prefs.getString('subdomain') ??
                          'https://core.landmarkcooperative.org';

                      APIService apiService =
                      APIService(subdomain_url: subdomain);
                      if (double.parse(amountController.text) <
                          currentWallet!.balance) {
                        setState(() {
                          isApiCallProcess = true;
                        });
                        withdrawalRequestModel.amount = amountController.text;
                        withdrawalRequestModel.accountNumber =
                            currentWallet!.accountNumber;
                        withdrawalRequestModel.requestType = currentRequestType;
                        if (currentRequestType == 'Transfer Request') {
                          withdrawalRequestModel.bankName = currentBank!.name;
                          withdrawalRequestModel.bankAccountNo = bankAcctNumController.text;
                          withdrawalRequestModel.bankAccountName = bankAcctNameController.text;
                        }
                        apiService
                            .withdrawalRequest(
                            withdrawalRequestModel, widget.token)
                            .then((value) {
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
                                  content: Text(value, textAlign: TextAlign.center,),
                                  actionsAlignment: MainAxisAlignment.start,
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        String subdomain = prefs.getString('subdomain') ??
                                            'https://core.landmarkcooperative.org';

                                        APIService apiService =
                                        APIService(subdomain_url: subdomain);
                                        setState(() {
                                          apiService.pageReload(widget.token).then((value) {
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => EntryPoint(
                                                fullName: widget.fullName,
                                                token: value.token,
                                                screenName: "Home",
                                                subdomain: widget.subdomain,
                                                customerWallets: value.customerWalletsList,
                                                referralId: value.customerWalletsList[0].phoneNo,
                                              ),
                                            )
                                            );
                                          });
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
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
                          borderRadius: BorderRadius.circular(15)
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text('Send',
                        style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
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
        required List<BankListResponseModel> bankList}){
    var width = MediaQuery.of(context).size.width;
    TextEditingController bankController = TextEditingController();
    bankList.sort((a, b) => a.name.compareTo(b.name),);
    List<BankListResponseModel> searchList = [];
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: 'Select Bank',
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, __, child) {
        Tween<Offset> tween;
        tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
        return SlideTransition(
          position: tween.animate(CurvedAnimation(
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
                searchList = bankList.where((element) => element.name.toString()
                    .toLowerCase().contains(value.toString().toLowerCase())).toList();
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
                              )
                          ),
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
                          searchList.isNotEmpty ? Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: searchList.length,
                              cacheExtent: 0,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 13.0),
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
                                              searchList[index].name.toString(),
                                              style: GoogleFonts.montserrat(
                                                color:
                                                Color(0xff000080),
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
                              : bankList.isNotEmpty ? Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: bankList.length,
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
                                            currentBank = bankList[index];
                                            selectedBank = bankList[index];
                                            bank = bankList[index].name;
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
                                              bankList[index].name.toString(),
                                              style: GoogleFonts.montserrat(
                                                color:
                                                Color(0xff000080),
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
                              : Center(
                            child: Text(
                              'Please check your internet connection',
                              style: GoogleFonts.montserrat(
                                color:
                                Color(0xff000080),
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
          }
      ),
    ).then((onClosed));
  }



  Widget displayBankWidget() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Future.delayed(
                const Duration(milliseconds: 800), () {
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
            }
            );
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
                Text(bank,
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
        const SizedBox(height: 20),
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
            onChanged: (value){
              setState(() {
                if(value.length == 10){
                  FlutterWaveService flutterWaveService = FlutterWaveService();
                  BankAccountRequestModel bankAcctRequest = BankAccountRequestModel();
                  bankAcctRequest.account_bank = currentBank!.code;
                  bankAcctRequest.account_number = value;
                  flutterWaveService.bankAccountVerify(bankAcctRequest, widget.token).then((valueAcct) {
                    bankAcctNameController.text = valueAcct;
                  });
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
        const SizedBox(height: 20),
        CustomTextFormField(
          keyboardType: TextInputType.number,
          controller: bankAcctNameController,
          hintText: "Account Name",
          enabled: false,
        ),
      ],
    );
  }
}



// Previous Code

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:landmarkcoop_latest/model/other_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// 
// import '../api/api_service.dart';
// import '../component/custom_text_form_field.dart';
// import '../model/customer_model.dart';
// import '../utils/ProgressHUD.dart';
// import '../utils/home_drawer.dart';
// import 'dashboard.dart';

// class WithdrawalRequest extends StatefulWidget {
//   final String fullName;
//   final String token;
//   final List<CustomerWalletsBalanceModel> customerWallets;
//   const WithdrawalRequest(
//       {Key? key,
//       required this.customerWallets,
//       required this.fullName,
//       required this.token})
//       : super(key: key);

//   @override
//   State<WithdrawalRequest> createState() => _WithdrawalRequestState();
// }

// class _WithdrawalRequestState extends State<WithdrawalRequest> {
//   bool isApiCallProcess = false;
//   CustomerWalletsBalanceModel? selectedWallet;
//   List<dynamic> itemData = [];
//   TextEditingController amountController = TextEditingController();
//   TextEditingController bankAcctNumController = TextEditingController();
//   TextEditingController bankAcctNameController = TextEditingController();
//   List<String> requestType = ['Select Request Type', 'Cash', 'Bank Transfer'];
//   String currentRequestType = "Select Request Type";
//   List<CustomerWalletsBalanceModel> data = <CustomerWalletsBalanceModel>[
//     CustomerWalletsBalanceModel(
//         id: 0,
//         accountNumber: 'Select Account',
//         balance: 0,
//         productName: '',
//         fullName: '',
//         email: '',
//         phoneNo: '')
//   ];
//   CustomerWalletsBalanceModel? currentWallet;
//   late WithdrawalRequestModel withdrawalRequestModel;
//   bool showBankWidgets = false;
//   List<BankListResponseModel> bankData = <BankListResponseModel>[
//     BankListResponseModel(id: 0, code: '', name: 'Select Bank')
//   ];
//   BankListResponseModel? currentBank;
//   BankListResponseModel? selectedBank;
//   late FocusNode focusNode;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     loadAccountAccounts();
//     withdrawalRequestModel = WithdrawalRequestModel();
//     getBanks();
//     focusNode = FocusNode();
//     focusNode.addListener(() => setState(() {}));
//   }

//   loadAccountAccounts() {
//     currentWallet = data[0];
//     for (var singleData in widget.customerWallets) {
//       data.add(singleData);
//     }
//     setState(() {
//       data;
//     });
//   }

//   getBanks(){
//     FlutterWaveService flutterWaveService = FlutterWaveService();
//     return flutterWaveService.getAllBanks().then((value) {
//       currentBank = bankData[0];

//       for (var singleData in value) {
//         bankData.add(singleData);
//       }
//       setState(() {
//         bankData;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ProgressHUD(
//       child: _uiSetup(context),
//       inAsyncCall: isApiCallProcess,
//       opacity: 0.3,
//     );
//   }

//   Widget _uiSetup(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 onPressed: () async {
//                   final prefs = await SharedPreferences.getInstance();
//                   String subdomain = prefs.getString('subdomain') ??
//                       'https://core.landmarkcooperative.org';

//                   Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) => HomeDrawer(
//                             value: 1,
//                             page: WithdrawalRequest(
//                               token: widget.token,
//                               fullName: widget.fullName,
//                               customerWallets: widget.customerWallets,
//                             ),
//                             name: 'withdrawalRequest',
//                             token: widget.token,
//                             fullName: widget.fullName,
//                             subdomain: subdomain,
//                           )));
//                 },
//                 icon: Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(children: <Widget>[
//                   const SizedBox(height: 20),
//                   dropDownWallets(),
//                   const SizedBox(height: 15),
//                   CustomTextFormField(
//                     keyboardType: TextInputType.number,
//                     controller: amountController,
//                     hintText: "Amount",
//                     enabled: true,
//                   ),
//                   const SizedBox(height: 15),
//                   FormField<String>(builder: (FormFieldState<String> state) {
//                     return InputDecorator(
//                       decoration: InputDecoration(
//                         labelStyle: GoogleFonts.montserrat(
//                           color: const Color(0xff9ca2ac),
//                         ),
//                         errorStyle: GoogleFonts.montserrat(
//                           color: Colors.redAccent,
//                         ),
//                         hintText: 'Select Request Type',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       isEmpty: currentRequestType == "",
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           alignment: AlignmentDirectional.centerEnd,
//                           value: currentRequestType,
//                           isDense: true,
//                           isExpanded: true,
//                           onChanged: (newValue) {
//                             setState(() {
//                               currentRequestType = newValue!;
//                               state.didChange(newValue);
//                             });
//                             if (currentRequestType == 'Bank Transfer') {
//                               showBankWidgets = true;
//                               getBanks();
//                             }else{
//                               showBankWidgets = false;
//                             }
//                           },
//                           items: requestType
//                               .map((String value) => DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Center(child: Text(value)),
//                                   ))
//                               .toList(),
//                         ),
//                       ),
//                     );
//                   }),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   //Todo display the bank info here
//                   showBankWidgets ? displayBankWidget() : Container(),
//                   SizedBox(
//                     height: 30,
//                   ),
//                   ElevatedButton(
//                     onPressed: () async {
//                       final prefs = await SharedPreferences.getInstance();
//                       String subdomain = prefs.getString('subdomain') ??
//                           'https://core.landmarkcooperative.org';

//                       APIService apiService =
//                           APIService(subdomain_url: subdomain);
//                       if (double.parse(amountController.text) <
//                           currentWallet!.balance) {
//                         setState(() {
//                           isApiCallProcess = true;
//                         });
//                         withdrawalRequestModel.amount = amountController.text;
//                         withdrawalRequestModel.accountNumber =
//                             currentWallet!.accountNumber;
//                         withdrawalRequestModel.requestType = currentRequestType;
//                         if (currentRequestType == 'Bank Transfer') {
//                           withdrawalRequestModel.bankName = currentBank!.name;
//                           withdrawalRequestModel.bankAccountNo = bankAcctNumController.text;
//                           withdrawalRequestModel.bankAccountName = bankAcctNameController.text;
//                         }
//                         apiService
//                             .withdrawalRequest(
//                                 withdrawalRequestModel, widget.token)
//                             .then((value) {
//                           setState(() {
//                             isApiCallProcess = false;
//                           });
//                           showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: Container(
//                                     height: 50,
//                                     alignment: Alignment.centerLeft,
//                                     padding: const EdgeInsets.only(left: 15),
//                                     color: Colors.blue.shade200,
//                                     child: Text(
//                                       'Message',
//                                       style: GoogleFonts.montserrat(
//                                           color: Colors.blue,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600),
//                                     ),
//                                   ),
//                                   content: Text(value, textAlign: TextAlign.center,),
//                                   actionsAlignment: MainAxisAlignment.start,
//                                   actions: <Widget>[
//                                     ElevatedButton(
//                                       onPressed: () async {
//                                         final prefs = await SharedPreferences.getInstance();
//                                         String subdomain = prefs.getString('subdomain') ??
//                                             'https://core.landmarkcooperative.org';

//                                         APIService apiService =
//                                         APIService(subdomain_url: subdomain);
//                                         setState(() {
//                                           apiService.pageReload(widget.token).then((value) {
//                                             Navigator.of(context).push(MaterialPageRoute(
//                                                 builder: (context) => HomeDrawer(
//                                                   value: 1,
//                                                   page: Dashboard(
//                                                     token: widget.token,
//                                                     fullName: widget.fullName,
//                                                     customerWallets: value.customerWalletsList,
//                                                   ),
//                                                   name: 'wallet',
//                                                   token: widget.token,
//                                                   fullName: widget.fullName,
//                                                   subdomain: subdomain,
//                                                 )));
//                                           });
//                                         });
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.grey.shade200,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 10, horizontal: 10),
//                                         child: Text(
//                                           "Close",
//                                           style: GoogleFonts.montserrat(
//                                             color: Colors.blue,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               });
//                         });
//                       } else {
//                         setState(() {
//                           isApiCallProcess = false;
//                         });
//                         showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return const AlertDialog(
//                                 title: Text("Notice"),
//                                 content: Text("Insufficient Balance"),
//                               );
//                             });
//                       }
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 10, horizontal: 10),
//                       child: Text(
//                         "Send",
//                         style: GoogleFonts.montserrat(
//                           color: Colors.white,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget dropDownWallets() {
//     return FormField<CustomerWalletsBalanceModel>(
//         builder: (FormFieldState<CustomerWalletsBalanceModel> state) {
//       return InputDecorator(
//         textAlign: TextAlign.center,
//         decoration: InputDecoration(
//           labelStyle: GoogleFonts.montserrat(
//             color: const Color(0xff9ca2ac),
//           ),
//           errorStyle: GoogleFonts.montserrat(
//             color: Colors.redAccent,
//           ),
//           hintText: 'Select Wallet',
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//         // isEmpty: currentWallet.biller_code == "",
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<CustomerWalletsBalanceModel>(
//             alignment: AlignmentDirectional.centerEnd,
//             value: currentWallet,
//             isDense: true,
//             isExpanded: true,
//             onChanged: (newValue) {
//               setState(() {
//                 currentWallet = newValue!;
//                 state.didChange(newValue);
//                 selectedWallet = newValue;
//               });
//             },
//             items: data
//                 .map((map) => DropdownMenuItem<CustomerWalletsBalanceModel>(
//                       value: map,
//                       child: Center(child: Text(map.accountNumber)),
//                     ))
//                 .toList(),
//           ),
//         ),
//       );
//     });
//   }


//   Widget dropDownBanks() {
//     return FormField<BankListResponseModel>(
//         builder: (FormFieldState<BankListResponseModel> state) {
//           return InputDecorator(
//             textAlign: TextAlign.center,
//             decoration: InputDecoration(
//               labelStyle: GoogleFonts.montserrat(
//                 color: const Color(0xff9ca2ac),
//               ),
//               errorStyle: GoogleFonts.montserrat(
//                 color: Colors.redAccent,
//               ),
//               hintText: 'Select Bank',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             // isEmpty: currentWallet.biller_code == "",
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<BankListResponseModel>(
//                 alignment: AlignmentDirectional.centerEnd,
//                 value: currentBank,
//                 isDense: true,
//                 isExpanded: true,
//                 onChanged: (newValue) {
//                   setState(() {
//                     currentBank = newValue!;
//                     state.didChange(newValue);
//                     selectedBank = newValue;
//                   });
//                 },
//                 items: bankData
//                     .map((map) => DropdownMenuItem<BankListResponseModel>(
//                   value: map,
//                   child: Center(child: Text(map.name)),
//                 ))
//                     .toList(),
//               ),
//             ),
//           );
//         });
//   }

//   Widget displayBankWidget() {
//     return Column(
//       children: [
//         dropDownBanks(),
//         SizedBox(
//           height: 20,
//         ),
//         AnimatedContainer(
//           duration: const Duration(seconds: 1),
//           decoration: focusNode.hasFocus
//               ? BoxDecoration(
//             boxShadow: const [BoxShadow(blurRadius: 6)],
//             borderRadius: BorderRadius.circular(20),
//           )
//               : BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: TextFormField(
//             focusNode: focusNode,
//             keyboardType: TextInputType.number,
//             controller: bankAcctNumController,
//             enabled: true,
//             textAlign: TextAlign.center,
//             onChanged: (value){
//               setState(() {
//                 if(value.length == 10){
//                   FlutterWaveService flutterWaveService = FlutterWaveService();
//                   BankAccountRequestModel bankAcctRequest = BankAccountRequestModel();
//                   bankAcctRequest.account_bank = currentBank!.code;
//                   bankAcctRequest.account_number = value;
//                   flutterWaveService.bankAccountVerify(bankAcctRequest).then((valueAcct) {
//                     bankAcctNameController.text = valueAcct;
//                   });
//                 }
//               });
//             },
//             decoration: InputDecoration(
//               hintText: 'Bank Account No.',
//               hintStyle: GoogleFonts.montserrat(
//                 color: const Color(0xff9ca2ac),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               hoverColor: Colors.white,
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 borderSide: const BorderSide(color: Colors.grey),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(20),
//                 borderSide: const BorderSide(color: Colors.grey, width: 1),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 20,
//         ),
//         CustomTextFormField(
//           keyboardType: TextInputType.number,
//           controller: bankAcctNameController,
//           hintText: "Account Name",
//           enabled: false,
//         ),
//       ],
//     );
//   }
// }
