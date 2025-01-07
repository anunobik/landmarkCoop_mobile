import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/utils/ProgressHUD.dart';
import 'package:landmarkcoop_mobile_app/widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BookInvestment extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final OnlineRateResponseModel interestRate;

  const BookInvestment(
      {Key? key,
      required this.customerWallets,
      required this.interestRate,
      required this.fullName,
      required this.token})
      : super(key: key);

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
        phoneNo: '', interBankName: '', nubanAccountNumber: 'Select Account',
        limitsEnabled: false,
        limitAmount: 50000,
      limitBalance: 0,
    )
  ];
  CustomerWalletsBalanceModel? currentWallet;
  List<ProductResponseModel> dataProduct = <ProductResponseModel>[
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
  String description = "Select an investment product to view its description.";
  String productName = "";
  final TextEditingController _amountController = TextEditingController();
  num minAmount = 100000; // Initial min amount for Silver
  num maxAmount = 300000; // Initial max amount for Silver

  // Define min and max ranges for each product
  final productRanges = {
    'Silver': {'min': 100000, 'max': 300000, 'tenor': 3, 'rate': 4.5, 'productId': 3},
    'Gold': {'min': 500000, 'max': 5000000, 'tenor': 6, 'rate': 5.5, 'productId': 4},
    'Platinum': {'min': 1000000, 'max': null, 'tenor': 12, 'rate': 6.5, 'productId': 5}, // No max for Platinum
    'Target Savings': {'min': 1000000, 'max': 5000000, 'tenor': 12, 'rate': 6.5, 'productId': 1},
    'Children Savings': {'min': 1000000, 'max': 5000000, 'tenor': 3, 'rate': 5, 'productId': 2},
  };

  void _showAmountInputDialog() {
    setState(() {
      minAmount = productRanges[productName]!['min']!;
      maxAmount = productRanges[productName]!['max'] ?? 1000000000;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Amount for $selectedProduct"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Amount must be between ${minAmount.toString()} and ${maxAmount == 1000000000 ? 'No Max' : maxAmount.toString()}",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter amount",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _amountController.clear();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async{
                final enteredAmount = int.tryParse(_amountController.text) ?? 0;
                if (enteredAmount >= minAmount && (maxAmount == 1000000000 || enteredAmount <= maxAmount)) {
                  Navigator.pop(context);
                  num rate = productRanges[productName]!['rate']!;
                  num tenor = productRanges[productName]!['tenor']!;
                  num productId = productRanges[productName]!['productId']!;
                  int instructionInt = 1;

                  // Proceed with the amount
                  setState(() {
                    isApiCallProcess = true;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  String subdomain = prefs.getString('subdomain') ?? 'core.landmarkcooperative.org';
                  APIService apiService = APIService(subdomain_url: subdomain);
                  apiService.bookInvestment(widget.customerWallets[0].accountNumber,
                      enteredAmount.toString(), tenor.toInt(), rate.toDouble(),
                      instructionInt, productId.toInt(), widget.token).then((value) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        if(value.status){
                          successTransactionAlert(value.message);
                        }else{
                          failTransactionAlert(value.message);
                        }
                  });
                } else {
                  // Show validation error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Please enter a valid amount within the range.",
                        style: TextStyle(color: Colors.black), // Black text color
                      ),
                      backgroundColor: Colors.blue, // Yellow background color
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Submit",
                style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          ),),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getProducts();
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

  getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    return apiService.getProducts().then((value) {
      currentProduct = dataProduct[0];

      for (var singleData in value) {
        if (!singleData.productName.contains('loan') &&
            !singleData.displayName.contains('loan') && singleData.displayName.contains(' Plan')) {
          dataProduct.add(singleData);
        }
      }
      setState(() {
        dataProduct;
      });
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
                  });
                },
                items: dataProduct
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
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(children: <Widget>[
            Center(
              child: Text(
                'Plans',
                style: GoogleFonts.montserrat(
                  // color: Color(0xff000080),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: 20,),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Platinum Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            description =
                            "Min. 1,000,000 \nTenor - 12 Months \nROI - 6.5%";
                            productName = "Platinum";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                        child: Icon(Icons.star, size: 15, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text('Platinum', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  // Gold Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            description =
                            "Min. 500,000 - Max. 5,000,000 \nTenor - 6 Months \nROI - 5.5%";
                            productName = "Gold";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                        child: Icon(Icons.emoji_events, size: 20, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text('Gold', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  // Silver Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            description =
                            "Min. 100,000 - Max. 300,000 \nTenor - 3 Months \nROI - 4.5%";
                            productName = "Silver";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                        child: Icon(Icons.military_tech, size: 20, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text('Silver', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Target Savings Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            description =
                            "Min. 1,000,000 - Max. 5,000,000 \nTenor - 12 Months \nROI - 6.5%";
                            productName = "Target Savings";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                        child: Icon(Icons.track_changes, size: 15, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text('Target Savings', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  SizedBox(width: 10,),
                  // Children Savings Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            description =
                            "Tenor - 3 Months \nROI - 5% \nFree Birthday Cake";
                            productName = "Children Savings";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                        child: Icon(Icons.child_care, size: 15, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text('Children Savings', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            // Description Display Container
            Container(
              padding: EdgeInsets.all(16),
              width: width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showAmountInputDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Proceed",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  failTransactionAlert(String message) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Container(
                height: 50,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15),
                color: Colors.blue.shade200,
                child: Text(
                  'Message',
                  style: GoogleFonts.openSans(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              content:
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Center(
                  child: Text(
                    'Notice',
                    style: GoogleFonts.openSans(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    message,
                    style: GoogleFonts.openSans(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ]),
              actionsAlignment: MainAxisAlignment.start,
              actions: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                        "Ok",
                        style: GoogleFonts.openSans(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }

  successTransactionAlert(message) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Container(
                height: 50,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 15),
                color: Color(0xff000080),
                child: Center(
                  child: Text(
                    'Message',
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              content:
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Center(
                  child: Text(
                    'Notice',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    message,
                    style: GoogleFonts.montserrat(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ]),
              actionsAlignment: MainAxisAlignment.start,
              actions: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      String subdomain = prefs.getString('subdomain') ??
                          'https://core.landmarkcooperative.org';

                      APIService apiService =
                      APIService(subdomain_url: subdomain);
                      setState(() {
                        isApiCallProcess = true;
                      });
                      apiService.pageReload(widget.token).then((value) {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        if (value.customerWalletsList.isNotEmpty) {
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
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Message"),
                                  content: Text(value.token),
                                );
                              });
                        }
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
                        "Ok",
                        style: GoogleFonts.montserrat(
                          color: Color(0xff000080),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          });
        });
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
