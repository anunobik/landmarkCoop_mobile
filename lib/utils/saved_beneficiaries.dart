// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../model/other_model.dart';

class SavedBeneficiary extends StatefulWidget {
  final Function(String, String, String, String) onBeneficiarySelected;
  final TextEditingController bankController;
  final TextEditingController bankAcctNumController;
  final TextEditingController bankAcctNameController;
  final String token;

  const SavedBeneficiary({
    Key? key,
    required this.onBeneficiarySelected,
    required this.bankController,
    required this.bankAcctNumController,
    required this.bankAcctNameController,
    required this.token,
  }) : super(key: key);

  @override
  State<SavedBeneficiary> createState() => _SavedBeneficiaryState();
}

class _SavedBeneficiaryState extends State<SavedBeneficiary> {
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<CustomerBeneficiaryResponseModel> beneficiaryList = [];
  List<CustomerBeneficiaryResponseModel> searchList = [];
  bool enableSubmitBtn = false;
  bool loadedBeneficiaryList = false;

  @override
  void initState() {
    super.initState();
    retrieveBeneficiaryInfo();
  }

  retrieveBeneficiaryInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain = prefs.getString('subdomain') ?? 'core.landmarkcooperative.org';
    APIService apiService = APIService(subdomain_url: subdomain);
    apiService.spoolCustomerBeneficiaries(widget.token).then((value) {
      for (var singleData in value) {
        beneficiaryList.add(singleData);
      }
      setState(() {
        beneficiaryList;
        loadedBeneficiaryList = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      child: Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  height: height * 0.7,
                  child: Column(
                    children: [
                      Container(
                        height: 3,
                        width: 50,
                        color: Colors.grey.shade300,
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          Text('Beneficiaries',
                              style: GoogleFonts.openSans(
                                color: const Color(0xff091841),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              )),
                          const Spacer(),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ))
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: width * 0.5,
                            child: TextFormField(
                              focusNode: focusNode,
                              keyboardType: TextInputType.text,
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: GoogleFonts.openSans(),
                                prefixIcon: const Icon(
                                  Icons.search,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: onSearchItem,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  searchController.text = '';
                                  searchList = [];
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: Text(
                                'Clear',
                                style: GoogleFonts.openSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      searchList.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: searchList.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () {
                                        setState(() {
                                          widget.bankAcctNameController.text =
                                              searchList[index]
                                                  .beneficiaryAccountName;
                                          widget.bankController.text =
                                              searchList[index]
                                                  .beneficiaryBankName;
                                          widget.bankAcctNumController.text =
                                              searchList[index]
                                                  .beneficiaryAccountNumber;

                                          String selectedName =
                                              searchList[index]
                                                  .beneficiaryAccountName;
                                          String selectedBank =
                                              searchList[index]
                                                  .beneficiaryBankName;
                                          String selectedAccountNum =
                                              searchList[index]
                                                  .beneficiaryAccountNumber;
                                          String selectedBankCode =
                                              searchList[index]
                                                  .beneficiaryBankCode;

                                          // Call the callback function
                                          widget.onBeneficiarySelected(
                                              selectedBankCode,
                                              selectedBank,
                                              selectedAccountNum,
                                              selectedName);
                                        });
                                        Navigator.pop(context);
                                      },
                                      leading: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.lightBlue,
                                            width: 1.5,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        // child: Container(
                                        //   height: 15,
                                        //   width: 15,
                                        //   decoration: const BoxDecoration(
                                        //     image: DecorationImage(
                                        //       image: AssetImage(
                                        //           'assets/user-icon.png'),
                                        //       fit: BoxFit.contain,
                                        //     ),
                                        //   ),
                                        // ),
                                      ),
                                      title: Text(
                                        searchList[index]
                                            .beneficiaryAccountName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: RichText(
                                          text: TextSpan(
                                              text: searchList[index]
                                                  .beneficiaryAccountNumber,
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              children: [
                                            const TextSpan(
                                              text: ' - ',
                                            ),
                                            TextSpan(
                                              text: searchList[index]
                                                  .beneficiaryBankName,
                                            ),
                                          ])),
                                      trailing: GestureDetector(
                                        onTap: () async {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          String subdomain =
                                              prefs.getString('subdomain') ??
                                                  'core.landmarkcooperative.org';
                                          APIService apiService = APIService(
                                              subdomain_url: subdomain);
                                          apiService.removeCustomerBeneficiary(
                                              searchList[index].id.toString(),
                                              widget.token);
                                          Navigator.pop(context);
                                        },
                                        child: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          : loadedBeneficiaryList
                              ? beneficiaryList.isNotEmpty
                                  ? Expanded(
                                      child: ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: beneficiaryList.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () {
                                                setState(() {
                                                  widget.bankAcctNameController
                                                      .text = beneficiaryList[
                                                          index]
                                                      .beneficiaryAccountName;
                                                  widget.bankController.text =
                                                      beneficiaryList[index]
                                                          .beneficiaryBankName;
                                                  widget.bankAcctNumController
                                                      .text = beneficiaryList[
                                                          index]
                                                      .beneficiaryAccountNumber;

                                                  String selectedName =
                                                      beneficiaryList[index]
                                                          .beneficiaryAccountName;
                                                  String selectedBank =
                                                      beneficiaryList[index]
                                                          .beneficiaryBankName;
                                                  String selectedAccountNum =
                                                      beneficiaryList[index]
                                                          .beneficiaryAccountNumber;
                                                  String selectedBankCode =
                                                      beneficiaryList[index]
                                                          .beneficiaryBankCode;

                                                  // Call the callback function
                                                  widget.onBeneficiarySelected(
                                                      selectedBankCode,
                                                      selectedBank,
                                                      selectedAccountNum,
                                                      selectedName);
                                                });
                                                Navigator.pop(context);
                                              },
                                              leading: Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.lightBlue,
                                                    width: 1.5,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                // child: Container(
                                                //   height: 15,
                                                //   width: 15,
                                                //   decoration: const BoxDecoration(
                                                //     image: DecorationImage(
                                                //       image: AssetImage(
                                                //           'assets/user-icon.png'),
                                                //       fit: BoxFit.contain,
                                                //     ),
                                                //   ),
                                                // ),
                                              ),
                                              title: Text(
                                                beneficiaryList[index]
                                                    .beneficiaryAccountName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: RichText(
                                                  text: TextSpan(
                                                      text: beneficiaryList[
                                                              index]
                                                          .beneficiaryAccountNumber,
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade700,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      children: [
                                                    const TextSpan(
                                                      text: ' - ',
                                                    ),
                                                    TextSpan(
                                                      text: beneficiaryList[
                                                              index]
                                                          .beneficiaryBankName,
                                                    ),
                                                  ])),
                                              trailing: GestureDetector(
                                                onTap: () async {
                                                  final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String subdomain = prefs
                                                          .getString(
                                                              'subdomain') ??
                                                      'core.landmarkcooperative.org';
                                                  APIService apiService =
                                                      APIService(
                                                          subdomain_url:
                                                              subdomain);
                                                  apiService
                                                      .removeCustomerBeneficiary(
                                                          beneficiaryList[index]
                                                              .id
                                                              .toString(),
                                                          widget.token);
                                                  Navigator.pop(context);
                                                },
                                                child: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            );
                                          }),
                                    )
                                  : Center(
                                      child: Text(
                                        'No saved beneficiary \n\nYou can add beneficiary after a concluded transaction',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                              : Text(
                                  'Loading Please wait...',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onSearchItem(value) {
    setState(() {
      searchList = beneficiaryList
          .where((element) => element.beneficiaryAccountName
              .toLowerCase()
              .contains(value.toLowerCase()))
          .toList();
    });
  }
}
