
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../api/api_service.dart';
import '../model/customer_model.dart';
import '../utils/ProgressHUD.dart';
import '../widgets/bottom_nav_bar.dart';
import 'certificate_of_investment.dart';

class InvestmentCert extends StatefulWidget {
  final String fullName;
  final String token;
  const InvestmentCert(
      {Key? key,
      required this.fullName,
      required this.token})
      : super(key: key);

  @override
  State<InvestmentCert> createState() => _InvestmentCertState();
}

class _InvestmentCertState extends State<InvestmentCert> {
  bool isApiCallProcess = false;
  CustomerInvestmentWalletModel? currentWallet;
  List<dynamic> itemData = [];
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  List<CustomerInvestmentWalletModel> data = [];
  bool showInvestments = false;

  @override
  void initState() {
    super.initState();
    getAllInvestment();
  }
  
  getAllInvestment() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    return apiService.allInvestments(widget.token).then((value){
      // currentWallet = data[0];
      for (var singleData in value) {
        data.add(singleData);
      }
      setState(() {
        data;
        showInvestments = true;
      });
    });
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff000080)),
          onPressed: _navigateToSignInScreen,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Shrink-wraps the column's children
          children: <Widget>[
            Center(
              child: Text(
                'Investments',
                style: GoogleFonts.montserrat(
                  // color: Color(0xff000080),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: 20,),
            showInvestments ?
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CertificateOfInvestment(customerInvestmentWalletModel: data[index]),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(5, 5),
                          color: Colors.grey.shade200,
                          blurRadius: 9,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Flexible( // Use Flexible here to manage overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Text(
                              data[index].product,
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 15),
                              overflow: TextOverflow.ellipsis,  // Ensures long text is handled
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                              "Amount: ₦${displayAmount.format(data[index].amount)}",
                            style: GoogleFonts.montserrat(),
                            overflow: TextOverflow.ellipsis,  // Ensures long text is handled
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Mat. Amount: ₦${displayAmount.format(data[index].maturityAmount)}",
                            style: GoogleFonts.montserrat(
                              // fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Mat. Date: ${data[index].timeCreated.substring(0, 10)}",
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              // fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Tenor: ${data[index].tenor} Months",
                                style: GoogleFonts.montserrat(
                                  // fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "R.O.I: ${data[index].rate}%",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ) : Column(
              children: const [
                SizedBox(height: 50),
                SizedBox(child: Center(child: Text('Please wait...')),),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget dropDownWallets() {
    return FormField<CustomerInvestmentWalletModel>(
        builder: (FormFieldState<CustomerInvestmentWalletModel> state) {
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
              child: DropdownButton<CustomerInvestmentWalletModel>(
                alignment: AlignmentDirectional.centerEnd,
                value: currentWallet,
                isDense: true,
                isExpanded: true,
                onChanged: (newValue) {
                  setState(() {
                    currentWallet = newValue!;
                    state.didChange(newValue);
                  });
                },
                items: data
                    .map((map) => DropdownMenuItem<CustomerInvestmentWalletModel>(
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
