import 'dart:math';

import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/pages/bills_payment.dart';
import 'package:landmarkcoop_mobile_app/pages/customer_care.dart';
import 'package:landmarkcoop_mobile_app/pages/dashboard.dart';
import 'package:landmarkcoop_mobile_app/pages/investment.dart';
import 'package:landmarkcoop_mobile_app/pages/login.dart';
import 'package:landmarkcoop_mobile_app/pages/manage_cards.dart';
import 'package:landmarkcoop_mobile_app/pages/setting.dart';
import 'package:landmarkcoop_mobile_app/pages/transaction_history.dart';
import 'package:landmarkcoop_mobile_app/pages/transfer_tabs.dart';
import 'package:landmarkcoop_mobile_app/pages/withdrawal_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/transfer_ozi.dart';

// ignore: must_be_immutable
class HomeDrawer extends StatefulWidget {
  double value;
  Widget page;
  String name;
  String fullName;
  String token;
  List<CustomerWalletsBalanceModel> customerWallets;
  List<LastTransactionsModel> lastTransactionsList;

  HomeDrawer(
      {Key? key,
      required this.value,
      required this.page,
      required this.name,
      required this.fullName,
      required this.token,
      required this.lastTransactionsList,
      required this.customerWallets})
      : super(key: key);

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  APIService apiService = APIService();
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRate();
  }

  getRate() async {
    APIService apiService = APIService();
    OnlineRateResponseModel value = await apiService.getOnlineRate(widget.token);
    setState(() {
      newValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.blue,
                  Color.fromRGBO(0, 0, 139, 1),
                  Color.fromRGBO(0, 0, 80, 1),
                ],
                stops: [
                  0.1,
                  0.5,
                  1,
                ]),
          ),
        ),
        SafeArea(
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 50.0,
                        backgroundImage: AssetImage('assets/user.png'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.fullName,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          setState(() {
                            widget.value = 0;
                            widget.page = Dashboard(
                              token: widget.token,
                              fullName: widget.fullName,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactionsList,
                            );
                            widget.name = 'wallet';
                          });
                        },
                        leading: Icon(
                          Icons.account_balance_wallet,
                          color: widget.name == 'wallet'
                              ? Colors.white
                              : Colors.white,
                        ),
                        title: Text(
                          "Wallet",
                          style: GoogleFonts.montserrat(
                            color: widget.name == 'wallet'
                                ? Colors.white
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          setState(() {
                            widget.value = 0;
                            widget.page = TransactionHistory(
                              token: widget.token,
                              fullName: widget.fullName,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactionsList,
                            );
                            widget.name = 'transactionHistory';
                          });
                        },
                        leading: Icon(
                          Icons.table_rows_rounded,
                          color: widget.name == 'transactionHistory'
                              ? Colors.white
                              : Colors.white,
                        ),
                        title: Text(
                          "Statement",
                          style: GoogleFonts.montserrat(
                            color: widget.name == 'transactionHistory'
                                ? Colors.white
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // ListTile(
                      //   onTap: () {
                      //     setState(() {
                      //       widget.value = 0;
                      //       widget.page = WithdrawalRequest(
                      //         token: widget.token,
                      //         fullName: widget.fullName,
                      //         customerWallets: widget.customerWallets,
                      //         lastTransactions: widget.lastTransactionsList,
                      //       );
                      //       widget.name = 'withdrawal';
                      //     });
                      //   },
                      //   leading: Icon(
                      //     Icons.download,
                      //     color: widget.name == 'withdrawal'
                      //         ? Colors.white
                      //         : Colors.white,
                      //   ),
                      //   title: Text(
                      //     "Withdrawal",
                      //     style: GoogleFonts.montserrat(
                      //       color: widget.name == 'withdrawal'
                      //           ? Colors.white
                      //           : Colors.white,
                      //       fontSize: 13,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      ListTile(
                        onTap: () {
                          setState(() {
                            widget.value = 0;
                            widget.page = Investment(
                              token: widget.token,
                              fullName: widget.fullName,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactionsList, interestRate: newValue,
                            );
                            widget.name = 'investment';
                          });
                        },
                        leading: Icon(
                          Icons.inventory_2_sharp,
                          color: widget.name == 'investment'
                              ? Colors.white
                              : Colors.white,
                        ),
                        title: Text(
                          "Investment",
                          style: GoogleFonts.montserrat(
                            color: widget.name == 'investment'
                                ? Colors.white
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          setState(() {
                            widget.value = 0;
                            widget.page = BillsPayment(
                              token: widget.token,
                              fullName: widget.fullName,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactionsList,
                            );
                            widget.name = 'Bills Payment';
                          });
                        },
                        leading: Icon(
                          Icons.receipt_long_outlined,
                          color: widget.name == 'Bills Payment'
                              ? Colors.white
                              : Colors.white,
                        ),
                        title: Text(
                          "Bills Payment",
                          style: GoogleFonts.montserrat(
                            color: widget.name == 'Bills Payment'
                                ? Colors.white
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          setState(() {
                            widget.value = 0;
                            widget.page = TransferTabs(
                              token: widget.token,
                              fullName: widget.fullName,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactionsList,
                            );
                            widget.name = 'Transfer';
                          });
                        },
                        leading: Icon(
                          CupertinoIcons.location,
                          color: widget.name == 'Transfer'
                              ? Colors.white
                              : Colors.white,
                        ),
                        title: Text(
                          "Transfer",
                          style: GoogleFonts.montserrat(
                            color: widget.name == 'Transfer'
                                ? Colors.white
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          setState(() {
                            widget.value = 0;
                            widget.page = Setting(
                              token: widget.token,
                              fullName: widget.fullName,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactionsList, phoneNumber: widget.customerWallets[0].phoneNo,
                            );
                            widget.name = 'setting';
                          });
                        },
                        leading: Icon(
                          Icons.settings,
                          color: widget.name == 'setting'
                              ? Colors.white
                              : Colors.white,
                        ),
                        title: Text(
                          "Settings",
                          style: GoogleFonts.montserrat(
                            color: widget.name == 'setting'
                                ? Colors.white
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.only(left: 16.0),
                        onTap: () {
                          setState(() {
                            widget.value = 0;
                            widget.page = ContactCustomerSupport(
                              token: widget.token,
                              fullName: widget.fullName,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactionsList,
                            );
                            widget.name = 'complaint';
                          });
                        },
                        leading: Icon(
                          Icons.local_post_office_rounded,
                          color: widget.name == 'complaint'
                              ? Colors.white
                              : Colors.white,
                        ),
                        title: Text(
                          "Contact Center",
                          style: GoogleFonts.montserrat(
                            color: widget.name == 'complaint'
                                ? Colors.white
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ListTile(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          APIService apiService = APIService();
                          apiService.logout(widget.token).then((value) {
                            prefs.setString('biometricToken', value);
                            print('Token at Logout - $value');
                          });
                          Navigator.popUntil(context, (route) => route.isFirst);
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                        },
                        leading: const Icon(
                          Icons.logout_outlined,
                          color: Color(0xffd4af37),
                        ),
                        title: Text(
                          "Logout",
                          style: GoogleFonts.montserrat(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: widget.value),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            builder: (context, double val, _) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..setEntry(0, 3, 200 * val)
                  ..rotateY((pi / 6) * val),
                child: GestureDetector(
                  onHorizontalDragUpdate: (e) {
                    if (e.delta.dx > 0) {
                      setState(() {
                        widget.value = 1;
                      });
                    } else {
                      setState(() {
                        widget.value = 0;
                      });
                    }
                  },
                  onTap: () {
                    setState(() {
                      widget.value = 0;
                    });
                  },
                  child: widget.page,
                ),
              );
            }),
      ]),
    );
  }
}
