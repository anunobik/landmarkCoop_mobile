import 'package:desalmcs_mobile_app/model/customer_model.dart';
import 'package:desalmcs_mobile_app/model/other_model.dart';
import 'package:desalmcs_mobile_app/pages/airtime_data.dart';
import 'package:desalmcs_mobile_app/pages/electricity.dart';
import 'package:desalmcs_mobile_app/pages/tv.dart';
import 'package:desalmcs_mobile_app/util/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillsPayment extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;
  const BillsPayment({Key? key, required this.fullName, required this.lastTransactions, required this.token, required this.customerWallets})
      : super(key: key);

  @override
  State<BillsPayment> createState() => _BillsPaymentState();
}

class _BillsPaymentState extends State<BillsPayment> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomeDrawer(
                        value: 1,
                        page: BillsPayment(token: widget.token,
                          fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactions: widget.lastTransactions,
                        ),
                        name: 'Bills Payment',
                        token: widget.token,
                        fullName: widget.fullName, 
                        customerWallets: widget.customerWallets,
                        lastTransactionsList: widget.lastTransactions,
                        ))
                    );
                  },
                  icon: Icon(
                    Icons.menu,
                    color: Colors.grey.shade600,
                  ),
                              ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor:Colors.white,
                    unselectedLabelColor: Colors.grey,
                    labelStyle:
                        GoogleFonts.openSans(fontWeight: FontWeight.bold),
                    unselectedLabelStyle:
                        GoogleFonts.openSans(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Airtime/Data'),
                      Tab(text: 'TV'),
                      Tab(text: 'Electricity'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(children: [
                    AirtimeData(
                      token: widget.token,
                      fullName: widget.fullName,
                    ),
                    TV(
                      token: widget.token,
                      fullName: widget.fullName,
                    ),
                    Electricity(
                      token: widget.token,
                      fullName: widget.fullName,
                    ),
                  ]),
                ),
              ],
            )),
      ),
    );
  }
}
