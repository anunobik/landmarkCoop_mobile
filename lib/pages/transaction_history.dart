import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/model/statement_model.dart';
import 'package:landmarkcoop_mobile_app/pushNotifications/push_messages.dart';
import 'package:landmarkcoop_mobile_app/util/ProgressHUD.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:landmarkcoop_mobile_app/util/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';

import '../api/api_service.dart';

class TransactionHistory extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const TransactionHistory(
      {super.key,
      required this.fullName,
      required this.token,
      required this.customerWallets,
      required this.lastTransactions});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<dynamic> itemData = [];
  final TextEditingController _startDateController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  final TextEditingController _endDateController = TextEditingController();
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  List<StatementResponseModel>? statementListFuture;
  bool isApiCallProcess = false;
  CustomerWalletsBalanceModel? currentWallet;
  CustomerWalletsBalanceModel? selectedWallet;
  APIService apiService = APIService();
  List<CustomerWalletsBalanceModel> data = <CustomerWalletsBalanceModel>[
    CustomerWalletsBalanceModel(
        id: 0,
        accountNumber: 'Select Account',
        balance: 0,
        productName: '',
        fullName: '',
        email: '',
        phoneNo: '',
        nubanAccountNumber: '',
        interBankName: '', trackNumber: '')
  ];

  @override
  void initState() {
    super.initState();
    getCustomerWallets();
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
    return apiService.pageReload(widget.token).then((value) {
      currentWallet = data[0];
      for (var singleData in value.customerWalletsList) {
        data.add(singleData);
      }
      setState(() {
        data;
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
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HomeDrawer(
                            value: 1,
                            page: TransactionHistory(
                              fullName: widget.fullName,
                              token: widget.token,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactions,
                            ),
                            name: 'transactionHistory',
                            token: widget.token,
                            fullName: widget.fullName,
                            customerWallets: widget.customerWallets,
                            lastTransactionsList: widget.lastTransactions,
                          )));
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Transaction History',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xff091841),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: dropDownWallets(),
              ),
              const SizedBox(height: 20),
              selectedWallet != null
                  ? Center(
                      child: Text(
                        selectedWallet!.productName,
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    )
                  : Container(),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => dateBottomSheet(context),
                          style: ButtonStyle(
                            elevation: WidgetStateProperty.all(10.0),
                            foregroundColor: WidgetStateProperty.all<Color>(
                                Colors.lightBlue),
                            shape: WidgetStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Colors.lightBlue),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Select Range',
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              statementListFuture != null
                  ? Expanded(
                      child: ListView.builder(
                          itemCount: itemData.length,
                          itemBuilder: (context, index) {
                            return itemData[index];
                          }),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text(
                          'No Transaction History',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
            ],
          ),
        ));
  }

  Future dateBottomSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Select Period',
                    style: GoogleFonts.montserrat(fontSize: 16),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop())
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: Text(
                'Start Date',
                style: GoogleFonts.montserrat(fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade900),
                ),
                child: TextFormField(
                  controller: _startDateController,
                  focusNode: AlwaysDisabledFocusNode(),
                  onTap: () {
                    _selectStartDate(context);
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Select Date',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range_outlined),
                        onPressed: () {
                          _selectStartDate(context);
                        },
                      )),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: Text(
                'End Date',
                style: GoogleFonts.montserrat(fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 50),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade900),
                ),
                child: TextFormField(
                  controller: _endDateController,
                  focusNode: AlwaysDisabledFocusNode(),
                  onTap: () {
                    _selectEndDate(context);
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Select Date',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range_outlined),
                        onPressed: () {
                          _selectEndDate(context);
                        },
                      )),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      isApiCallProcess = true;
                    });

                    apiService
                        .getAccountStatement(
                            widget.token,
                            selectedWallet!.accountNumber,
                            _startDateController.text,
                            _endDateController.text)
                        .then((value) {
                      statementListFuture = value;
                      setState(() {
                        isApiCallProcess = false;
                      });
                      Navigator.of(context).pop();
                      fullHistory(statementListFuture!);
                    });
                  },
                  style: ButtonStyle(
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.blue),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.blue)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.25,
                        vertical: 12),
                    child: Text(
                      "CONFIRM",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                      ),
                    ),
                  )),
            )
          ],
        );
      });

  fullHistory(List<StatementResponseModel> responseList) {
    final displayAmount = NumberFormat("#,##0.00", "en_US");
    List<Widget> histItems = [];
    for (var data in responseList) {
      histItems.add(
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 13.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(3, 3),
              ),
            ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: <Widget>[
                    Text(
                      data.timeCreated.toString().substring(0, 10),
                      style: TextStyle(
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '',
                        style: TextStyle(color: Colors.grey.shade900),
                      ),
                    ),
                    const Spacer(),
                    data.depositAmount == 0
                        ? Text(
                            '- NGN${displayAmount.format(data.withdrawalAmount)}',
                            style: TextStyle(
                                color: data.depositAmount == 0
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold),
                          )
                        : Text(
                            'NGN${displayAmount.format(data.depositAmount)}',
                            style: TextStyle(
                                color: data.depositAmount == 0
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    data.narration,
                    style: TextStyle(color: Colors.grey.shade900),
                  ),
                )
              ],
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

  _selectStartDate(BuildContext context) async {
    DateTime? newSelectedStartDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2021, 1),
      lastDate: DateTime(2050),
    );

    if (newSelectedStartDate != null) {
      _selectedStartDate = newSelectedStartDate;
      _startDateController
        ..text = DateFormat('yyyy-MM-dd').format(_selectedStartDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _startDateController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  _selectEndDate(BuildContext context) async {
    DateTime? newSelectedEndDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime(2021, 1),
      lastDate: DateTime(2050),
    );

    if (newSelectedEndDate != null) {
      _selectedEndDate = newSelectedEndDate;
      _endDateController
        ..text = DateFormat('yyyy-MM-dd').format(_selectedEndDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _endDateController.text.length,
            affinity: TextAffinity.upstream));
    }
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
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
