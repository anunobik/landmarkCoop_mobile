import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/model/push_notification.dart';
import 'package:landmarkcoop_mobile_app/pushNotifications/push_messages.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:landmarkcoop_mobile_app/util/notification_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import '../api/api_service.dart';
import '../component/custom_text_form_field.dart';
import '../util/ProgressHUD.dart';
import 'dashboard.dart';

class WithdrawalRequest extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const WithdrawalRequest(
      {Key? key,
      required this.customerWallets,
      required this.lastTransactions,
      required this.fullName,
      required this.token})
      : super(key: key);

  @override
  State<WithdrawalRequest> createState() => _WithdrawalRequestState();
}

class _WithdrawalRequestState extends State<WithdrawalRequest> {
  bool isApiCallProcess = false;
  CustomerWalletsBalanceModel? selectedWallet;
  List<dynamic> itemData = [];
  TextEditingController amountController = TextEditingController();
  TextEditingController bankAcctNumController = TextEditingController();
  TextEditingController bankAcctNameController = TextEditingController();
  late int totalNotifications;
  late final FirebaseMessaging messaging;
  PushNotification? notificationInfo;
  List notificationList = [];
  List<String> requestType = ['Select Request Type', 'Cash', 'Bank Transfer'];
  String currentRequestType = "Select Request Type";
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
  CustomerWalletsBalanceModel? currentWallet;
  late WithdrawalRequestModel withdrawalRequestModel;
  List<BankListResponseModel> bankData = <BankListResponseModel>[
    BankListResponseModel(id: 0, code: '', name: 'Select Bank')
  ];
  BankListResponseModel? currentBank;
  BankListResponseModel? selectedBank;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    loadAccountAccounts();
    withdrawalRequestModel = WithdrawalRequestModel();
    // getBanks();
    focusNode = FocusNode();
    focusNode.addListener(() => setState(() {}));
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

  loadAccountAccounts() {
    currentWallet = data[0];
    for (var singleData in widget.customerWallets) {
      data.add(singleData);
    }
    setState(() {
      data;
    });
  }

  // getBanks(){
  //   APICore apiCore = APICore();
  //   return apiCore.getAllBanks().then((value) {
  //     currentBank = bankData[0];

  //     for (var singleData in value) {
  //       bankData.add(singleData);
  //     }
  //     setState(() {
  //       bankData;
  //     });
  //   });
  // }

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
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HomeDrawer(
                            value: 1,
                            page: WithdrawalRequest(
                              customerWallets: widget.customerWallets,
                              fullName: widget.fullName,
                              token: widget.token,
                              lastTransactions: widget.lastTransactions,
                            ),
                            name: 'withdrawal',
                            fullName: widget.fullName,
                            token: widget.token,
                            customerWallets: widget.customerWallets,
                            lastTransactionsList: widget.lastTransactions,
                          )));
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(children: <Widget>[
                  const SizedBox(height: 20),
                  dropDownWallets(),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    keyboardType: TextInputType.number,
                    controller: amountController,
                    hintText: "Amount",
                    enabled: true,
                  ),
                  const SizedBox(height: 15),
                  //Todo display the bank info here
                  displayBankWidget(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      // final prefs = await SharedPreferences.getInstance();
                      // String subdomain = prefs.getString('subdomain') ??
                      //     'https://core.landmarkcooperative.org';

                      // APIService apiService =
                      //     APIService();
                      // if (double.parse(amountController.text) <
                      //     currentWallet!.balance) {
                      //   setState(() {
                      //     isApiCallProcess = true;
                      //   });
                      //   withdrawalRequestModel.amount = amountController.text;
                      //   withdrawalRequestModel.accountNumber =
                      //       currentWallet!.accountNumber;
                      //   withdrawalRequestModel.requestType = currentRequestType;
                      //   if (currentRequestType == 'Bank Transfer') {
                      //     withdrawalRequestModel.bankName = currentBank!.name;
                      //     withdrawalRequestModel.bankAccountNo = bankAcctNumController.text;
                      //     withdrawalRequestModel.bankAccountName = bankAcctNameController.text;
                      //   }
                      //   apiService
                      //       .withdrawalRequest(
                      //           withdrawalRequestModel, widget.token)
                      //       .then((value) {
                      //     setState(() {
                      //       isApiCallProcess = false;
                      //     });
                      //     showDialog(
                      //         context: context,
                      //         builder: (BuildContext context) {
                      //           return AlertDialog(
                      //             title: Container(
                      //               height: 50,
                      //               alignment: Alignment.centerLeft,
                      //               padding: const EdgeInsets.only(left: 15),
                      //               color: Colors.blue.shade200,
                      //               child: Text(
                      //                 'Message',
                      //                 style: GoogleFonts.montserrat(
                      //                     color: Colors.blue,
                      //                     fontSize: 16,
                      //                     fontWeight: FontWeight.w600),
                      //               ),
                      //             ),
                      //             content: Text(value, textAlign: TextAlign.center,),
                      //             actionsAlignment: MainAxisAlignment.start,
                      //             actions: <Widget>[
                      //               ElevatedButton(
                      //                 onPressed: () async {
                      //                   final prefs = await SharedPreferences.getInstance();
                      //                   String subdomain = prefs.getString('subdomain') ??
                      //                       'https://core.landmarkcooperative.org';

                      //                   APIService apiService =
                      //                   APIService();
                      //                   setState(() {
                      //                     apiService.pageReload(widget.token).then((value) {
                      //                       Navigator.of(context).push(MaterialPageRoute(
                      //                           builder: (context) => HomeDrawer(
                      //                             value: 1,
                      //                             page: Dashboard(
                      //                               token: widget.token,
                      //                               fullName: widget.fullName,
                      //                               customerWallets: value.customerWalletsList,
                      //                             ),
                      //                             name: 'wallet',
                      //                             token: widget.token,
                      //                             fullName: widget.fullName,
                      //                             subdomain: subdomain,
                      //                           )));
                      //                     });
                      //                   });
                      //                 },
                      //                 style: ElevatedButton.styleFrom(
                      //                   backgroundColor: Colors.grey.shade200,
                      //                   shape: RoundedRectangleBorder(
                      //                     borderRadius:
                      //                         BorderRadius.circular(5),
                      //                   ),
                      //                 ),
                      //                 child: Padding(
                      //                   padding: const EdgeInsets.symmetric(
                      //                       vertical: 10, horizontal: 10),
                      //                   child: Text(
                      //                     "Close",
                      //                     style: GoogleFonts.montserrat(
                      //                       color: Colors.blue,
                      //                       fontSize: 16,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           );
                      //         });
                      //   });
                      // } else {
                      //   setState(() {
                      //     isApiCallProcess = false;
                      //   });
                      //   showDialog(
                      //       context: context,
                      //       builder: (BuildContext context) {
                      //         return const AlertDialog(
                      //           title: Text("Notice"),
                      //           content: Text("Insufficient Balance"),
                      //         );
                      //       });
                      // }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text(
                        "Send",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 15,
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

  Widget dropDownBanks() {
    return FormField<BankListResponseModel>(
        builder: (FormFieldState<BankListResponseModel> state) {
      return InputDecorator(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelStyle: GoogleFonts.montserrat(
            color: const Color(0xff9ca2ac),
          ),
          errorStyle: GoogleFonts.montserrat(
            color: Colors.redAccent,
          ),
          hintText: 'Select Bank',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // isEmpty: currentWallet.biller_code == "",
        child: DropdownButtonHideUnderline(
          child: DropdownButton<BankListResponseModel>(
            alignment: AlignmentDirectional.centerEnd,
            value: currentBank,
            isDense: true,
            isExpanded: true,
            onChanged: (newValue) {
              setState(() {
                currentBank = newValue!;
                state.didChange(newValue);
                selectedBank = newValue;
              });
            },
            items: bankData
                .map((map) => DropdownMenuItem<BankListResponseModel>(
                      value: map,
                      child: Center(child: Text(map.name)),
                    ))
                .toList(),
          ),
        ),
      );
    });
  }

  Widget displayBankWidget() {
    return Column(
      children: [
        dropDownBanks(),
        const SizedBox(
          height: 20,
        ),
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
            // onChanged: (value){
            //   setState(() {
            //     if(value.length == 10){
            //       APICore apiCore = APICore();
            //       BankAccountRequestModel bankAcctRequest = BankAccountRequestModel();
            //       bankAcctRequest.account_bank = currentBank!.code;
            //       bankAcctRequest.account_number = value;
            //       apiCore.bankAccountVerify(bankAcctRequest).then((valueAcct) {
            //         bankAcctNameController.text = valueAcct;
            //       });
            //     }
            //   });
            // },
            decoration: InputDecoration(
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
        const SizedBox(
          height: 20,
        ),
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
