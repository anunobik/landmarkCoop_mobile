import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/component/custom_text_form_field.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/pages/dashboard.dart';
import 'package:landmarkcoop_mobile_app/pages/investment.dart';
import 'package:landmarkcoop_mobile_app/util/ProgressHUD.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookInvestment extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;
  final OnlineRateResponseModel interestRate;

  const BookInvestment(
      {super.key,
      required this.customerWallets,
      required this.interestRate,
      required this.fullName,
      required this.lastTransactions,
      required this.token});

  @override
  State<BookInvestment> createState() => _BookInvestmentState();
}

class _BookInvestmentState extends State<BookInvestment> {
  bool isApiCallProcess = false;
  CustomerWalletsBalanceModel? selectedWallet;
  List<dynamic> itemData = [];
  TextEditingController amountController = TextEditingController();
  List<String> tenorList = ['Select Tenor (Months)', '3', '6', '12', '24'];
  List<String> instructionList = [
    'Select Instruction',
    'Interest drops monthly',
    'Roll-Over Principal Only and Redeem Interest',
    'Roll-Over Principal and Interest',
    'Redeem Principal and Interest'
  ];
  double currentTenor = 0;
  String currentInstruction = 'Select Instruction';
  TextEditingController rateController = TextEditingController();
  late String instructionInt;
  List<CustomerWalletsBalanceModel> data = <CustomerWalletsBalanceModel>[
    CustomerWalletsBalanceModel(
        id: 0,
        accountNumber: 'Select Account',
        balance: 0,
        productName: '',
        fullName: '',
        email: '',
        phoneNo: '',
        interBankName: '',
        nubanAccountNumber: 'Select Account',
        trackNumber: '')
  ];
  CustomerWalletsBalanceModel? currentWallet;

  @override
  void initState() {
    super.initState();
    loadAccountAccounts();
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
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HomeDrawer(
                            value: 1,
                            page: Investment(
                              token: widget.token,
                              fullName: widget.fullName,
                              customerWallets: widget.customerWallets,
                              lastTransactions: widget.lastTransactions,
                              interestRate: widget.interestRate,
                            ),
                            name: 'investment',
                            token: widget.token,
                            fullName: widget.fullName,
                            customerWallets: widget.customerWallets,
                            lastTransactionsList: widget.lastTransactions)));
                  },
                  icon: Icon(
                    Icons.menu,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Book Investment',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff091841),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                dropDownWallets(),
                const SizedBox(height: 15),
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
                        rateController.text =
                            widget.interestRate.oneMonth.toString();
                      } else if (currentTenor == 2.0) {
                        rateController.text =
                            widget.interestRate.twoMonth.toString();
                      } else if (currentTenor == 3.0) {
                        rateController.text =
                            widget.interestRate.threeMonth.toString();
                      } else if (currentTenor == 4.0) {
                        rateController.text =
                            widget.interestRate.fourMonth.toString();
                      } else if (currentTenor == 5.0) {
                        rateController.text =
                            widget.interestRate.fiveMonth.toString();
                      } else if (currentTenor == 6.0) {
                        rateController.text =
                            widget.interestRate.sixMonth.toString();
                      } else if (currentTenor == 7.0) {
                        rateController.text =
                            widget.interestRate.sevenMonth.toString();
                      } else if (currentTenor == 8.0) {
                        rateController.text =
                            widget.interestRate.eightMonth.toString();
                      } else if (currentTenor == 9.0) {
                        rateController.text =
                            widget.interestRate.nineMonth.toString();
                      } else if (currentTenor == 10.0) {
                        rateController.text =
                            widget.interestRate.tenMonth.toString();
                      } else if (currentTenor == 11.0) {
                        rateController.text =
                            widget.interestRate.elevenMonth.toString();
                      } else if (currentTenor == 12.0) {
                        rateController.text =
                            widget.interestRate.twelveMonth.toString();
                      } else {
                        rateController.text = '0.0';
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
                FormField<String>(builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      isDense: true,
                      labelStyle: GoogleFonts.montserrat(
                        color: const Color(0xff9ca2ac),
                      ),
                      errorStyle: GoogleFonts.montserrat(
                        color: Colors.redAccent,
                      ),
                      hintText: 'Select Instruction',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    isEmpty: currentInstruction == "",
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        alignment: AlignmentDirectional.centerEnd,
                        value: currentInstruction,
                        isExpanded: true,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            currentInstruction = newValue!;
                            state.didChange(newValue);
                          });
                          switch (currentInstruction) {
                            case 'Roll-Over Principal Only and Redeem Interest':
                              instructionInt = '1';
                              break;
                            case 'Roll-Over Principal and Interest':
                              instructionInt = '2';
                              break;
                            case 'Redeem Principal and Interest':
                              instructionInt = '3';
                              break;
                            case 'Interest drops monthly':
                              instructionInt = '4';
                              break;
                            default:
                              instructionInt = '4';
                              break;
                          }
                        },
                        items: instructionList
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Center(
                                      child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      APIService apiService = APIService();
                      if (double.parse(amountController.text) > 5000) {
                        setState(() {
                          isApiCallProcess = true;
                        });
                        apiService
                            .bookInvestment(
                                selectedWallet!.accountNumber,
                                amountController.text,
                                currentTenor.toInt(),
                                double.parse(rateController.text),
                                int.parse(instructionInt),
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
                                  content: Text(value),
                                  actionsAlignment: MainAxisAlignment.start,
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async {
                                        APIService apiService = APIService();
                                        setState(() {
                                          apiService
                                              .pageReload(widget.token)
                                              .then((value) {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomeDrawer(
                                                          value: 0,
                                                          page: Dashboard(
                                                            token: widget.token,
                                                            fullName:
                                                                widget.fullName,
                                                            customerWallets: widget
                                                                .customerWallets,
                                                            lastTransactions: widget
                                                                .lastTransactions,
                                                          ),
                                                          name: 'wallet',
                                                          fullName: widget.fullName,
                                                          token: widget.token,
                                                          customerWallets: widget
                                                              .customerWallets,
                                                          lastTransactionsList:
                                                              widget
                                                                  .lastTransactions,
                                                        )));
                                          });
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
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
                                content:
                                    Text("Amount must be greater than NGN5,000"),
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
                        "Book",
                        style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ]),
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
}
