import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../model/customer_model.dart';
import '../model/login_model.dart';
import '../model/other_model.dart';
import '../model/push_notification.dart';
import '../util/ProgressHUD.dart';
import '../util/home_drawer.dart';
import '../util/notification_badge.dart';
import 'dashboard.dart';

class Transfer extends StatefulWidget {
  final String fullName;
  final String token;
  final List<LastTransactionsModel> lastTransactions;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const Transfer({
    super.key,
    required this.fullName,
    required this.token,
    required this.customerWallets,
    required this.lastTransactions,
  });

  @override
  State<Transfer> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  PhoneContact? _phoneContact;
  String _contact = 'Tap to get phone number';
  bool isApiCallProcess = false;
  GlobalKey<FormState> formKeyTrf = GlobalKey<FormState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double fundTrfAmount = 0;
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
        phoneNo: '', interBankName: '', nubanAccountNumber: 'Select Account', trackNumber: '')
  ];
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  LoginRequestModel loginRequestModel = LoginRequestModel();

  @override
  void initState() {
    super.initState();
    getCustomerWallets();
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
              background: const Color(0XFF091841).withOpacity(0.7),
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
        APIService apiService = APIService();
        apiService.login(loginRequestModel).then((value) {
          if (value.customerWalletsList.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context)=> HomeDrawer(
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
              'title' : message.notification!.title,
              'body' : message.notification!.body,
            });
        }});
      }}
    );
    totalNotifications = 0;
    pushNotify();
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

  getCustomerWallets() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService();
    return apiService.pageReload(widget.token).then((value) {
      currentWallet = dataWallet[0];
      for (var singleData in value.customerWalletsList) {
        dataWallet.add(singleData);
      }
      setState(() {
        dataWallet;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
              child: Column(
                children: <Widget>[
                  Text(
                    'Transfer to other Landmark users',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff000080),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Tap to select from your phone contacts',
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

                      final granted =
                          await FlutterContactPicker.hasPermission();
                      granted
                          ? print('Granted')
                          : await FlutterContactPicker.requestPermission();
                      final PhoneContact contact =
                          await FlutterContactPicker.pickPhoneContact();
                      setState(() {
                        _phoneContact = contact;
                      });
                      setState(() {
                        _contact = _phoneContact!.phoneNumber!.number!;
                      });
                      APIService apiServicePhone =
                          new APIService();
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
                                    customerAccountDisplayModel!.accountNumber,
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
            ),
          )),
    );
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
                      style: TextStyle(fontSize: 18.0),
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
                        APIService();

                    if (validateAndSaveTrf()) {
                      AccountToAccountRequestModel
                          accountToAccountRequestModel =
                          new AccountToAccountRequestModel(
                              fromAccountNumber: selectedWallet!.accountNumber,
                              toAccountNumber:
                                  customerAccountDisplayModel!.accountNumber,
                              amount: fundTrfAmount.toString());
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
                      primary: Colors.lightBlue,
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
                color: Color.fromRGBO(0, 0, 139, 1),
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
                          APIService();
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
                      primary: Colors.grey.shade200,
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
                          color: Color.fromRGBO(0, 0, 139, 1),
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
}
