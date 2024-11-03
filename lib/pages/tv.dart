import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/component/custom_text_form_field.dart';
import 'package:landmarkcoop_mobile_app/util/home_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../model/bill_model.dart';
import '../util/ProgressHUD.dart';

class TV extends StatefulWidget {
  final String fullName;
  final String token;
  const TV({super.key, required this.fullName, required this.token});

  @override
  State<TV> createState() => _TVState();
}

class _TVState extends State<TV> {
  String subscription = 'DSTV';
  TextEditingController smartCardController = TextEditingController();
  String currentCableTV = '--Select--';
  List<String> cableTvList = ['--Select--', 'DSTV COMPACT'];
  APIService apiService = APIService();
  List<BillsResponseModel> dataDSTV = <BillsResponseModel>[
    BillsResponseModel(
        item_code: 'Select Subscription',
        biller_code: 'Select Subscription',
        biller_name: 'Select Subscription',
        short_name: 'Select Subscription',
        amount: 0)
  ];
  List<BillsResponseModel> dataStarTimes = <BillsResponseModel>[
    BillsResponseModel(
        item_code: 'Select Subscription',
        biller_code: 'Select Subscription',
        biller_name: 'Select Subscription',
        short_name: 'Select Subscription',
        amount: 0)
  ];
  List<BillsResponseModel> dataGOtv = <BillsResponseModel>[
    BillsResponseModel(
        item_code: 'Select Subscription',
        biller_code: 'Select Subscription',
        biller_name: 'Select Subscription',
        short_name: 'Select Subscription',
        amount: 0)
  ];
  BillsResponseModel? currentDataBundle;
  BillsResponseModel? currentDSTVDataBundle;
  BillsResponseModel? currentStarTimesDataBundle;
  BillsResponseModel? currentGOtvDataBundle;
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  bool isApiCallProcess = false;

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
            child: Column(
              children: <Widget>[
                Text(
                  "Pay TV Subscription",
                  style: GoogleFonts.openSans(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          subscription = 'DSTV';
                        });
                      },
                      child: Container(
                        height: height * 0.0768,
                        width: height * 0.0768,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: subscription == 'DSTV'
                                  ? Colors.grey.shade500
                                  : Colors.transparent,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/dstv.jpg'),
                              fit: BoxFit.contain,
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          subscription = 'GOtv';
                        });
                      },
                      child: Container(
                        height: height * 0.0768,
                        width: height * 0.0768,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: subscription == 'GOtv'
                                  ? Colors.grey.shade400
                                  : Colors.transparent,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/gotv.jpg'),
                              fit: BoxFit.contain,
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          subscription = 'StarTimes';
                        });
                      },
                      child: Container(
                        height: height * 0.0768,
                        width: height * 0.0768,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: subscription == 'StarTimes'
                                  ? Colors.grey.shade400
                                  : Colors.transparent,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/startimes.jpg'),
                              fit: BoxFit.contain,
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '$subscription Subscription',
                  style: GoogleFonts.openSans(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                CustomTextFormField(
                  keyboardType: TextInputType.number,
                  controller: smartCardController,
                  hintText: 'Enter SmartCard Number',
                  enabled: true,
                ),
                const SizedBox(height: 10),
                dataBundleListBuilder(),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    // setState(() {
                    //   isApiCallProcess = true;
                    // });
                    // BillsRequestModel billsRequestModel = BillsRequestModel(
                    //   biller_name: currentDataBundle!.biller_name,
                    //   uniqueNo: smartCardController.text,
                    //   amount: currentDataBundle!.amount.toString(),
                    //   item_code: currentDataBundle!.item_code,
                    //   biller_code: currentDataBundle!.biller_code,
                    // );

                    // PayTvSubscriptionRequestModel payTvSubRequest =
                    //     PayTvSubscriptionRequestModel(
                    //         biller_name: currentDataBundle!.biller_name,
                    //         smartcard_no: smartCardController.text,
                    //         amount: currentDataBundle!.amount.toString(),
                    //         item_code: currentDataBundle!.item_code,
                    //         biller_code: currentDataBundle!.biller_code);

                    // apiService
                    //     .validateBillsRequest(
                    //         widget.token,
                    //         currentDataBundle!.item_code,
                    //         currentDataBundle!.biller_code,
                    //         smartCardController.text,
                    //         context)
                    //     .then((value) {
                    //   setState(() {
                    //     isApiCallProcess = false;
                    //   });
                    //   if (value.response_message == "Successful") {
                    //     Navigator.of(context).push(MaterialPageRoute(
                    //         builder: (context) => ValidateBills(
                    //               verificationType: 'TV',
                    //               token: widget.token,
                    //               billsRequestModel: billsRequestModel,
                    //               billsValidationResponseModel: value,
                    //               payTvSubRequest: payTvSubRequest,
                    //             )));
                    //   }else{
                    //     failTransactionAlert(value.response_message);
                    //   }
                    // });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Text("Validate",
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dataBundleListBuilder() {
    List<BillsResponseModel> dataTo = <BillsResponseModel>[
      BillsResponseModel(
          item_code: 'Select Subscription',
          biller_code: 'Select Subscription',
          biller_name: 'Select Subscription',
          short_name: 'Select Subscription',
          amount: 0)
    ];

    switch(subscription){
      case 'DSTV':
        dataTo = dataDSTV;
        currentDataBundle = currentDSTVDataBundle;
        break;
      case 'GOtv':
        dataTo = dataGOtv;
        currentDataBundle = currentGOtvDataBundle;
        break;
      case 'StarTimes':
        dataTo = dataStarTimes;
        currentDataBundle = currentStarTimesDataBundle;
        break;
    }
    return FormField<BillsResponseModel>(
        builder: (FormFieldState<BillsResponseModel> state) {
          return InputDecorator(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              labelStyle: GoogleFonts.openSans(
                color: const Color(0xff9ca2ac),
              ),
              errorStyle: GoogleFonts.openSans(
                color: Colors.redAccent,
              ),
              hintText: 'Select Subscription',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            // isEmpty: currentWallet.biller_code == "",
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BillsResponseModel>(
                alignment: AlignmentDirectional.centerEnd,
                value: currentDataBundle,
                isDense: true,
                isExpanded: true,
                onChanged: (newValue) {
                  setState(() {
                    switch(subscription){
                      case 'DSTV':
                        currentDSTVDataBundle = newValue!;
                        break;
                      case 'GOtv':
                        currentGOtvDataBundle = newValue!;
                        break;
                      case 'StarTimes':
                        currentStarTimesDataBundle = newValue!;
                        break;
                    }
                    state.didChange(newValue);
                  });
                },
                items: dataTo
                    .map((map) => DropdownMenuItem<BillsResponseModel>(
                  value: map,
                  child: Center(child: Text('${map.biller_name} -> NGN${map.amount}', overflow: TextOverflow.ellipsis,)),
                ))
                    .toList(),
              ),
            ),
          );
        });
  }

  failTransactionAlert(String message) {
    setState(() {
      isApiCallProcess = false;
    });
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
                      setState(() {
                        isApiCallProcess = false;
                      });
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

}
