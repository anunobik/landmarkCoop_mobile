import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/pages/dashboard.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:lottie/lottie.dart';

class ProcessingAirtimeRequest extends StatelessWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const ProcessingAirtimeRequest({
    super.key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.lastTransactions,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 100,
                    width: 100,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage('https://core.landmarkcooperative.org/getBizLogo'),
                          fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: width * 0.3,
                    width: width * 0.3,
                    child: Lottie.asset('assets/LottieAssets/success.zip'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your request is successful!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: const Color(0XFF091841),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HomeDrawer(
                              value: 0,
                              page: Dashboard(
                                token: token,
                                fullName:
                                customerWallets[0].fullName,
                                lastTransactions:
                                lastTransactions,
                                customerWallets: customerWallets,
                              ),
                              name: 'wallet',
                              fullName:
                              customerWallets[0].fullName,
                              token: token,
                              customerWallets:customerWallets,
                              lastTransactionsList: lastTransactions),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: GoogleFonts.montserrat(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      child: Text(
                        'Home',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
