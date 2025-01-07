import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:landmarkcoop_mobile_app/entry_point.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/utils/notification_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_service.dart';
import '../../model/customer_model.dart';
import '../../model/statement_model.dart';
import '../../utils/ProgressHUD.dart';
import '../model/login_model.dart';
import '../widgets/bottom_nav_bar.dart';

class StatementScreen extends StatefulWidget {
  final String fullName;
  final String token;


  const StatementScreen(
      {Key? key,
      required this.fullName,
      required this.token})
      : super(key: key);

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  List<dynamic> itemData = [];
  final TextEditingController _startDateController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  final TextEditingController _endDateController = TextEditingController();
  List<StatementResponseModel>? statementListFuture;
  bool isApiCallProcess = false;
  bool isFundingDialogShown = false;
  CustomerWalletsBalanceModel? currentWallet;
  CustomerWalletsBalanceModel? selectedWallet;
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


  getCustomerWallets() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
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
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xff000080)),
            onPressed: _navigateToSignInScreen,
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20,65,20,20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                dropDownWallets(),
                const SizedBox(height: 20),
                selectedWallet != null ? Center(
                  child: Text(
                    selectedWallet!.productName,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, 
                      fontSize: 15,
                    ),
                  ),
                )
                : Container(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              Future.delayed(
                                const Duration(milliseconds: 800),
                                (){
                                  setState(() {
                                    isFundingDialogShown = true;
                                  });
                                  dateRange(
                                    context, 
                                    onClosed: (context) {
                                      setState(() {
                                        isFundingDialogShown = false;
                                      });
                                    },
                                  );
                                }
                              );
                            },
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0.0),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.lightBlue),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.lightBlue),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Select Date Range',
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
                const SizedBox( height: 10),
                Divider(
                  height: 1,
                  color: Color(0xff000080).withOpacity(0.3),
                ),
                const SizedBox( height: 15),
                statementListFuture != null ? Expanded(
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
          ),
        ));
  }

  // Date Range
  Future<Object?> dateRange(BuildContext context,
  {required ValueChanged onClosed}){
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: 'Select Date Range',
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Select Date Range',
                          style: GoogleFonts.montserrat(
                            color: const Color(0xff000080),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Start Date',
                          style: GoogleFonts.montserrat(fontSize: 13),
                        ),
                        Container(
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
                            style: GoogleFonts.montserrat(
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
                              ),
                            ),
                          ),
                        ),
                        const SizedBox( height: 10),
                        Text(
                          'End Date',
                          style: GoogleFonts.montserrat(fontSize: 13),
                        ),
                        Container(
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
                            style: GoogleFonts.montserrat(
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
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async{
                            final prefs = await SharedPreferences.getInstance();
                              String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

                              APIService apiService = APIService(subdomain_url: subdomain);

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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                          ), 
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            child: Text('CONFIRM',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600
                              ),
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
                      )
                    )
                  ],
                ),
              ),
            ),
          );
        }
      ),
    ).then((onClosed));
  }

  
  // History
  fullHistory(List<StatementResponseModel> responseList) {
    final displayAmount = NumberFormat("#,##0.00", "en_US");
    List<Widget> histItems = [];
    for (var data in responseList) {
      histItems.add(
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 13.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(3, 3),
                ),
              ]
            ),
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
                    data.depositAmount == 0 ? Text(
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
