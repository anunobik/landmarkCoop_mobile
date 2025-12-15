import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/api/api_service.dart';
import 'package:landmarkcoop_latest/main_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/bottom_nav_bar.dart';

class LogoutPage extends StatefulWidget {
  final String token;
  const LogoutPage({super.key, required this.token});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
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

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 50,
                alignment: Alignment.centerLeft,
                color: Color(0xff000080),
                child: Center(
                  child: Text(
                    "Logout?",
                    style: GoogleFonts.montserrat(
                      color: Colors.lightBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "You are about to logout",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  String subdomain =
                      prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
                  APIService apiService = APIService(subdomain_url: subdomain);
                  apiService.logout(widget.token).then((value) {
                    prefs.setString('biometricToken', value);
                    print('Token at Logout - $value');
                  });
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
