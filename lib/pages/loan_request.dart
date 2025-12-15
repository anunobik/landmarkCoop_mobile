import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/model/loan_model.dart';
import 'package:landmarkcoop_latest/model/other_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../component/custom_text_form_field.dart';
import '../entry_point.dart';
import '../model/customer_model.dart';
import '../utils/ProgressHUD.dart';

class LoanRequest extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;

  const LoanRequest(
      {Key? key,
      required this.customerWallets,
      required this.fullName,
      required this.token})
      : super(key: key);

  @override
  State<LoanRequest> createState() => _LoanRequestState();
}

class _LoanRequestState extends State<LoanRequest> {
  bool isApiCallProcess = false;
  CustomerWalletsBalanceModel? selectedWallet;
  List<dynamic> itemData = [];
  TextEditingController amountController = TextEditingController();
  List<String> tenorList = ['Select Tenor (Months)', '1', '2', '3', '4'];
  List<ProductResponseModel> data = <ProductResponseModel>[
    ProductResponseModel(
      id: 0,
      productName: 'Select Product',
      displayName: 'Select Product',
      description: 'Select Product',
      interestRate: 0.0,
      tenorDays: 0,
      prematureCharge: 0.0,
      normalCharge: 0.0,
      defaultCharge: 0.0,
      serviceCharge: 0.0,
      referralPercentageCharge: 0.0,
    )
  ];
  ProductResponseModel? currentProduct;
  ProductResponseModel? selectedProduct;
  OnlineRateResponseModel interestRate = OnlineRateResponseModel(
    id: 0,
    oneMonth: 0.0,
    twoMonth: 0.0,
    threeMonth: 0.0,
    fourMonth: 0.0,
    fiveMonth: 0.0,
    sixMonth: 0.0,
    sevenMonth: 0.0,
    eightMonth: 0.0,
    nineMonth: 0.0,
    tenMonth: 0.0,
    elevenMonth: 0.0,
    twelveMonth: 0.0,
  );
  double currentTenor = 0;
  String currentInstruction = 'Select Instruction';
  TextEditingController rateController = TextEditingController();
  bool disableRegisterBtn = true;

  @override
  void initState() {
    super.initState();
    getProducts();
    getRate();
  }

  getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    return apiService.getProducts().then((value) {
      currentProduct = data[0];

      for (var singleData in value) {
        if (singleData.productName.contains('loan')) {
          data.add(singleData);
        }
      }
      setState(() {
        data;
      });
    });
  }

  getRate() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    OnlineRateResponseModel value =
        await apiService.getOnlineLoanRate(widget.token);
    setState(() {
      interestRate = value;
    });
  }

  Widget productBuilder() {
    return FormField<ProductResponseModel>(
        builder: (FormFieldState<ProductResponseModel> state) {
      return InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          labelStyle: GoogleFonts.montserrat(
            color: const Color(0xff9ca2ac),
          ),
          errorStyle: GoogleFonts.montserrat(
            color: Colors.redAccent,
          ),
          hintText: 'Select Product',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // isEmpty: currentProduct.biller_code == "",
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ProductResponseModel>(
            alignment: AlignmentDirectional.centerEnd,
            value: currentProduct,
            isDense: true,
            isExpanded: true,
            onChanged: (newValue) {
              setState(() {
                currentProduct = newValue!;
                state.didChange(newValue);
                selectedProduct = newValue;
                if(amountController.text.isNotEmpty && rateController.text != '0.0' && currentProduct!.id != 0) {
                  disableRegisterBtn = false;
                }else{
                  disableRegisterBtn = true;
                }
              });
            },
            items: data
                .map((map) => DropdownMenuItem<ProductResponseModel>(
                      value: map,
                      child: Center(
                          child: Text(
                        map.displayName,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ))
                .toList(),
          ),
        ),
      );
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
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(children: <Widget>[
            SizedBox(height: height * 0.20),
            Text(
              'Loan Request',
              style: GoogleFonts.montserrat(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomTextFormField(
              keyboardType: TextInputType.number,
              controller: amountController,
              hintText: "Amount",
              enabled: true,
            ),
            const SizedBox(height: 20),
            Text(
              'Tenor',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            Slider(
              min: 0,
              max: 12,
              divisions: 12,
              label: '$currentTenor',
              value: currentTenor,
              onChanged: (value) {
                setState(() {
                  currentTenor = value;
                  if (currentTenor == 1.0) {
                    rateController.text = interestRate.oneMonth.toString();
                  } else if (currentTenor == 2.0) {
                    rateController.text = interestRate.twoMonth.toString();
                  } else if (currentTenor == 3.0) {
                    rateController.text = interestRate.threeMonth.toString();
                  } else if (currentTenor == 4.0) {
                    rateController.text = interestRate.fourMonth.toString();
                  } else if (currentTenor == 5.0) {
                    rateController.text = interestRate.fiveMonth.toString();
                  } else if (currentTenor == 6.0) {
                    rateController.text = interestRate.sixMonth.toString();
                  } else if (currentTenor == 7.0) {
                    rateController.text = interestRate.sevenMonth.toString();
                  } else if (currentTenor == 8.0) {
                    rateController.text = interestRate.eightMonth.toString();
                  } else if (currentTenor == 9.0) {
                    rateController.text = interestRate.nineMonth.toString();
                  } else if (currentTenor == 10.0) {
                    rateController.text = interestRate.tenMonth.toString();
                  } else if (currentTenor == 11.0) {
                    rateController.text = interestRate.elevenMonth.toString();
                  } else if (currentTenor == 12.0) {
                    rateController.text = interestRate.twelveMonth.toString();
                  } else {
                    rateController.text = '0.0';
                  }

                  if(amountController.text.isNotEmpty && rateController.text != '0.0' && currentProduct!.id != 0) {
                    disableRegisterBtn = false;
                  }else{
                    disableRegisterBtn = true;
                  }
                });
              },
            ),
            Text(
              '$currentTenor Months',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Rate',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            CustomTextFormField(
              keyboardType: TextInputType.number,
              controller: rateController,
              hintText: "",
              enabled: false,
            ),
            const SizedBox(height: 20),
            productBuilder(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: disableRegisterBtn
                  ? null
                  : () async {
                      final prefs = await SharedPreferences.getInstance();
                      String subdomain = prefs.getString('subdomain') ??
                          'https://core.landmarkcooperative.org';

                      APIService apiService =
                          APIService(subdomain_url: subdomain);
                      if (double.parse(amountController.text) > 5000) {
                        setState(() {
                          isApiCallProcess = true;
                        });
                        String selectedProductId =
                            selectedProduct!.id.toString();
                        LoanRequestModel loanRequestModel = LoanRequestModel(
                          amountRequested: double.parse(amountController.text),
                          tenor: currentTenor.toInt(),
                          rate: double.parse(rateController.text),
                        );
                        apiService
                            .loanRequest(loanRequestModel, selectedProductId,
                                widget.token)
                            .then((value) {
                          setState(() {
                            isApiCallProcess = false;
                          });
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Container(
                                    height: 50,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 15),
                                    color: Colors.blue.shade200,
                                    child: Text(
                                      'Message',
                                      style: GoogleFonts.montserrat(
                                          color: Colors.blue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  content: Text(value.message),
                                  actionsAlignment: MainAxisAlignment.start,
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        String subdomain =
                                            prefs.getString('subdomain') ??
                                                'https://core.landmarkcooperative.org';

                                        APIService apiService = APIService(
                                            subdomain_url: subdomain);
                                        setState(() {
                                          apiService
                                              .pageReload(widget.token)
                                              .then((value) {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EntryPoint(
                                                          fullName:
                                                              widget.fullName,
                                                          token: value.token,
                                                          screenName: "Home",
                                                          subdomain: subdomain,
                                                          customerWallets: value
                                                              .customerWalletsList,
                                                          referralId: value
                                                              .customerWalletsList[
                                                                  0]
                                                              .phoneNo,
                                                        )));
                                          });
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        child: Text(
                                          "Close",
                                          style: GoogleFonts.montserrat(
                                            color: Colors.blue,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        });
                      } else {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                title: Text("Notice"),
                                content: Text(
                                    "Amount must be greater than NGN5,000"),
                              );
                            });
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  "Submit",
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
