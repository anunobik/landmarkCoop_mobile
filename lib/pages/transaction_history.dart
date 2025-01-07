// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// // ignore: depend_on_referenced_packages
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../api/api_service.dart';
// import '../model/customer_model.dart';
// import '../model/statement_model.dart';
// import '../utils/ProgressHUD.dart';
// import '../utils/home_drawer.dart';

// class TransactionHistory extends StatefulWidget {
//   final String fullName;
//   final String token;


//   const TransactionHistory(
//       {Key? key,
//       required this.fullName,
//       required this.token})
//       : super(key: key);

//   @override
//   State<TransactionHistory> createState() => _TransactionHistoryState();
// }

// class _TransactionHistoryState extends State<TransactionHistory> {
//   List<dynamic> itemData = [];
//   final TextEditingController _startDateController = TextEditingController();
//   DateTime _selectedStartDate = DateTime.now();
//   DateTime _selectedEndDate = DateTime.now();
//   final TextEditingController _endDateController = TextEditingController();
//   List<StatementResponseModel>? statementListFuture;
//   bool isApiCallProcess = false;
//   CustomerWalletsBalanceModel? currentWallet;
//   CustomerWalletsBalanceModel? selectedWallet;
//   List<CustomerWalletsBalanceModel> data = <CustomerWalletsBalanceModel>[
//     CustomerWalletsBalanceModel(
//         id: 0,
//         accountNumber: 'Select Account',
//         balance: 0,
//         productName: '',
//         fullName: '',
//         email: '',
//         phoneNo: '')
//   ];

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getCustomerWallets();
//   }

//   getCustomerWallets() async {
//     final prefs = await SharedPreferences.getInstance();
//     String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

//     APIService apiService = APIService(subdomain_url: subdomain);
//     return apiService.pageReload(widget.token).then((value) {
//       currentWallet = data[0];
//       for (var singleData in value.customerWalletsList) {
//         data.add(singleData);
//       }
//       setState(() {
//         data;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ProgressHUD(
//       child: _uiSetup(context),
//       inAsyncCall: isApiCallProcess,
//       opacity: 0.3,
//     );
//   }

//   Widget _uiSetup(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;

//     return Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               IconButton(
//                 padding: EdgeInsets.zero,
//                 onPressed: () async {
//                   final prefs = await SharedPreferences.getInstance();
//                   String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

//                   Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => HomeDrawer(
//                         value: 1,
//                         page: TransactionHistory(token: widget.token,
//                           fullName: widget.fullName, ),
//                         name: 'transactionHistory',
//                         token: widget.token,
//                         fullName: widget.fullName,
//                         subdomain: subdomain,
//                       ))
//                   );
//                 },
//                 icon: Icon(
//                   Icons.arrow_back_ios_new,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 30, right: 30),
//                 child: dropDownWallets(),
//               ),
//               const SizedBox(height: 20),
//               selectedWallet != null
//                   ? Center(
//                       child: Text(
//                         selectedWallet!.productName,
//                         style: GoogleFonts.montserrat(
//                             fontWeight: FontWeight.bold, fontSize: 15),
//                       ),
//                     )
//                   : Container(),
//               SizedBox(
//                 height: 30,
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         TextButton(
//                           onPressed: () => dateBottomSheet(context),
//                           style: ButtonStyle(
//                             elevation: MaterialStateProperty.all(10.0),
//                             foregroundColor: MaterialStateProperty.all<Color>(
//                                 Colors.lightBlue),
//                             shape: MaterialStateProperty.all<
//                                 RoundedRectangleBorder>(
//                               RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             backgroundColor: MaterialStateProperty.all<Color>(
//                                 Colors.lightBlue),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Text(
//                               'Select Range',
//                               style: GoogleFonts.montserrat(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 15,
//               ),
//               statementListFuture != null
//                   ? Expanded(
//                       child: ListView.builder(
//                           itemCount: itemData.length,
//                           itemBuilder: (context, index) {
//                             return itemData[index];
//                           }),
//                     )
//                   : Padding(
//                       padding: const EdgeInsets.only(top: 50),
//                       child: Center(
//                         child: Text(
//                           'No Transaction History',
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.montserrat(
//                               fontSize: 15, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     )
//             ],
//           ),
//         ));
//   }

//   Future dateBottomSheet(BuildContext context) => showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Text(
//                     'Select Period',
//                     style: GoogleFonts.montserrat(fontSize: 16),
//                   ),
//                   IconButton(
//                       icon: Icon(Icons.close),
//                       onPressed: () => Navigator.of(context).pop())
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
//               child: Text(
//                 'Start Date',
//                 style: GoogleFonts.montserrat(fontSize: 13),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 50, right: 50),
//               child: Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade900),
//                 ),
//                 child: TextFormField(
//                   controller: _startDateController,
//                   focusNode: AlwaysDisabledFocusNode(),
//                   onTap: () {
//                     _selectStartDate(context);
//                   },
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                   decoration: InputDecoration(
//                       hintText: 'Select Date',
//                       border: InputBorder.none,
//                       suffixIcon: IconButton(
//                         icon: Icon(Icons.date_range_outlined),
//                         onPressed: () {
//                           _selectStartDate(context);
//                         },
//                       )),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
//               child: Text(
//                 'End Date',
//                 style: GoogleFonts.montserrat(fontSize: 13),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 50, right: 50),
//               child: Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey.shade900),
//                 ),
//                 child: TextFormField(
//                   controller: _endDateController,
//                   focusNode: AlwaysDisabledFocusNode(),
//                   onTap: () {
//                     _selectEndDate(context);
//                   },
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   ),
//                   decoration: InputDecoration(
//                       hintText: 'Select Date',
//                       border: InputBorder.none,
//                       suffixIcon: IconButton(
//                         icon: Icon(Icons.date_range_outlined),
//                         onPressed: () {
//                           _selectEndDate(context);
//                         },
//                       )),
//                 ),
//               ),
//             ),
//             Padding(
//               padding:
//                   const EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
//               child: TextButton(
//                   onPressed: () async {
//                     final prefs = await SharedPreferences.getInstance();
//                     String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

//                     APIService apiService = APIService(subdomain_url: subdomain);

//                     setState(() {
//                       isApiCallProcess = true;
//                     });
                    
//                     apiService
//                         .getAccountStatement(
//                             widget.token,
//                             selectedWallet!.accountNumber,
//                             _startDateController.text,
//                             _endDateController.text)
//                         .then((value) {
//                       statementListFuture = value;
//                       setState(() {
//                         isApiCallProcess = false;
//                       });
//                       Navigator.of(context).pop();
//                       fullHistory(statementListFuture!);
//                     });
//                   },
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.25,
//                         vertical: 12),
//                     child: Text(
//                       "CONFIRM",
//                       style: GoogleFonts.montserrat(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   style: ButtonStyle(
//                       foregroundColor:
//                           MaterialStateProperty.all<Color>(Colors.blue),
//                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       backgroundColor:
//                           MaterialStateProperty.all<Color>(Colors.blue))),
//             )
//           ],
//         );
//       });

//   fullHistory(List<StatementResponseModel> responseList) {
//     final displayAmount = NumberFormat("#,##0.00", "en_US");
//     List<Widget> histItems = [];
//     responseList.forEach((data) {
//       histItems.add(
//         Padding(
//           padding: const EdgeInsets.only(left: 20, right: 20, bottom: 13.0),
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(color: Colors.white, boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5),
//                 spreadRadius: 1,
//                 blurRadius: 2,
//                 offset: const Offset(3, 3),
//               ),
//             ]),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: <Widget>[
//                     Text(
//                       data.timeCreated.toString().substring(0, 10),
//                       style: TextStyle(
//                           color: Colors.grey.shade900,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: Text(
//                         '',
//                         style: TextStyle(color: Colors.grey.shade900),
//                       ),
//                     ),
//                     Spacer(),
//                     data.depositAmount == 0
//                         ? Text(
//                             '- NGN${displayAmount.format(data.withdrawalAmount)}',
//                             style: TextStyle(
//                                 color: data.depositAmount == 0
//                                     ? Colors.red
//                                     : Colors.green,
//                                 fontWeight: FontWeight.bold),
//                           )
//                         : Text(
//                             'NGN${displayAmount.format(data.depositAmount)}',
//                             style: TextStyle(
//                                 color: data.depositAmount == 0
//                                     ? Colors.red
//                                     : Colors.green,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 15.0),
//                   child: Text(
//                     data.narration,
//                     style: TextStyle(color: Colors.grey.shade900),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//     setState(() {
//       itemData = histItems;
//     });

//     return Column(
//       children: histItems,
//     );
//   }

//   _selectStartDate(BuildContext context) async {
//     DateTime? newSelectedStartDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedStartDate,
//       firstDate: DateTime(2021, 1),
//       lastDate: DateTime(2050),
//     );

//     if (newSelectedStartDate != null) {
//       _selectedStartDate = newSelectedStartDate;
//       _startDateController
//         ..text = DateFormat('yyyy-MM-dd').format(_selectedStartDate)
//         ..selection = TextSelection.fromPosition(TextPosition(
//             offset: _startDateController.text.length,
//             affinity: TextAffinity.upstream));
//     }
//   }

//   _selectEndDate(BuildContext context) async {
//     DateTime? newSelectedEndDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedEndDate,
//       firstDate: DateTime(2021, 1),
//       lastDate: DateTime(2050),
//     );

//     if (newSelectedEndDate != null) {
//       _selectedEndDate = newSelectedEndDate;
//       _endDateController
//         ..text = DateFormat('yyyy-MM-dd').format(_selectedEndDate)
//         ..selection = TextSelection.fromPosition(TextPosition(
//             offset: _endDateController.text.length,
//             affinity: TextAffinity.upstream));
//     }
//   }

//   Widget dropDownWallets() {
//     return FormField<CustomerWalletsBalanceModel>(
//         builder: (FormFieldState<CustomerWalletsBalanceModel> state) {
//           return InputDecorator(
//             textAlign: TextAlign.center,
//             decoration: InputDecoration(
//               labelStyle: GoogleFonts.montserrat(
//                 color: const Color(0xff9ca2ac),
//               ),
//               errorStyle: GoogleFonts.montserrat(
//                 color: Colors.redAccent,
//               ),
//               hintText: 'Select Wallet',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             // isEmpty: currentWallet.biller_code == "",
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<CustomerWalletsBalanceModel>(
//                 alignment: AlignmentDirectional.centerEnd,
//                 value: currentWallet,
//                 isDense: true,
//                 isExpanded: true,
//                 onChanged: (newValue) {
//                   setState(() {
//                     currentWallet = newValue!;
//                     state.didChange(newValue);
//                     selectedWallet = newValue;
//                   });
//                 },
//                 items: data
//                     .map((map) => DropdownMenuItem<CustomerWalletsBalanceModel>(
//                   value: map,
//                   child: Center(child: Text(map.accountNumber)),
//                 ))
//                     .toList(),
//               ),
//             ),
//           );
//         });
//   }

// }

// class AlwaysDisabledFocusNode extends FocusNode {
//   @override
//   bool get hasFocus => false;
// }
