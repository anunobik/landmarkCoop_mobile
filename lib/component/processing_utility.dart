import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/widgets/bottom_nav_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProcessingUtilityRequest extends StatelessWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final String subdomain;
  final String rechargeToken;

  const ProcessingUtilityRequest({
    Key? key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.subdomain,
    required this.rechargeToken,
  }) : super(key: key);

  String formatRechargeToken(String token) {
    return token.replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)}-').replaceAll(RegExp(r'-$'), '');
  }

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
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/Logo.png'),
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
                      color: Color(0xff000080),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Token: ${formatRechargeToken(rechargeToken)}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      color: Color(0xff000080),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async{
                      final prefs = await SharedPreferences.getInstance();
                      String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
                      APIService apiService = APIService(subdomain_url: subdomain);

                      // Fetch data asynchronously
                      final value = await apiService.pageReload(token);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => BottomNavBar(
                          pageIndex: 0,
                          fullName: fullName,
                          token: value.token,
                          subdomain: subdomain,
                          customerWallets: value.customerWalletsList,
                          phoneNumber: value.customerWalletsList[0].phoneNo,
                        ),
                      ));
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
