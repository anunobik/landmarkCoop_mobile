import 'package:auto_size_text/auto_size_text.dart';
import 'package:landmarkcoop_mobile_app/pages/search_status.dart';
import 'package:landmarkcoop_mobile_app/pages/transfer_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../model/customer_model.dart';
import '../model/other_model.dart';
import 'package:intl/intl.dart';

class TransferStatus extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const TransferStatus({
    Key? key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.lastTransactions,
  }) : super(key: key);

  @override
  State<TransferStatus> createState() => _TransferStatusState();
}

class _TransferStatusState extends State<TransferStatus> {
  bool isStatusDialogShown = false;
  List<ExternalBankTransferHistoryResponseModel> data = [];
  final displayAmount = NumberFormat("#,##0.00", "en_US");


  @override
  void initState() {
    super.initState();
    loadLastTenTransfers();
  }

  Future<void> loadLastTenTransfers() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    String institution = prefs.getString('institution') ?? 'Minerva Hub';

    APIService apiService = APIService();
    apiService.lastTenTransfers(widget.token).then((value) {
      setState(() {
        data = value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Transfer Status',
          style: GoogleFonts.montserrat(
            color: const Color(0XFF091841),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Future.delayed(
                const Duration(milliseconds: 800),
                    (){
                  setState(() {
                    isStatusDialogShown = true;
                  });
                  searchStatus(
                    context,
                    onClosed: (context) {
                      setState(() {
                        isStatusDialogShown = false;
                      });
                    },
                );
              }
            );
            }, 
            icon: const Icon(
              CupertinoIcons.search,
            )
          ),
          IconButton(
            onPressed: () {
              // ToDo: Date Range
            }, 
            icon: const Icon(
              Icons.tune_outlined,
            )
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0XFF091841)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          height: height,
          width: width,
          child: Column(
            children: <Widget>[
              data.isNotEmpty ? Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => TransferDetails(
                            accountNumber: data[index].destinationAccountNumber,
                            amount: "₦${displayAmount.format(data[index].amount)}", bank: data[index].destinationBankName,
                            beneficiary: data[index].destinationAccountName,
                             narration: data[index].completeMessage,
                             status: data[index].status,
                             date: data[index].timeCreated.substring(0, 10),
                             time: data[index].timeCreated.substring(10, data[index].timeCreated.length),
                            ),
                          )
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(4, 4),
                              color: Colors.grey.shade200,
                              blurRadius: 4,
                              spreadRadius: 2
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.outbond_outlined,
                                  color: data[index].status == 'SUCCESSFUL' ? Colors.green
                                  : data[index].status == 'FAILED' ?  Colors.red
                                  : Colors.amber,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(data[index].destinationAccountName,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 15),
                                    AutoSizeText(data[index].completeMessage,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                const SizedBox(width: 35),
                                Text("₦${displayAmount.format(data[index].amount)}",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                                const Spacer(),
                                AutoSizeText(data[index].timeCreated.substring(0, 10),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              )
              : Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Text('You have not made any transfers yet',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 24
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