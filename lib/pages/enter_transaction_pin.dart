// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/pages/transfer_receipt.dart';
import 'package:landmarkcoop_mobile_app/utils/ProgressHUD.dart';
import 'package:landmarkcoop_mobile_app/widgets/bottom_nav_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

class EnterTransactionPin extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final ExternalBankTransferDetailsRequestModel
  externalBankTransferDetailsRequestModel;
  final bool saveBeneficiary;

  const EnterTransactionPin({
    Key? key,
    required this.customerWallets,
    required this.fullName,
    required this.token,
    required this.externalBankTransferDetailsRequestModel,
    required this.saveBeneficiary,
  }) : super(key: key);

  @override
  State<EnterTransactionPin> createState() => _EnterTransactionPinState();
}

class _EnterTransactionPinState extends State<EnterTransactionPin> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController pin1 = TextEditingController();
  TextEditingController pin2 = TextEditingController();
  TextEditingController pin3 = TextEditingController();
  TextEditingController pin4 = TextEditingController();
  bool failed = false;
  late ExternalBankTransferDetailsRequestModel requestModel;
  final displayAmount = NumberFormat("#,##0.00", "en_US");
  bool isApiCallProcess = false;
  bool showInvalid = false;

  @override
  void dispose() {
    pin1.dispose();
    pin2.dispose();
    pin3.dispose();
    pin4.dispose();
    super.dispose();
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: const IconThemeData(color: Color(0xff000080)),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 150,
                  width: 150,
                  child: Lottie.asset('assets/LottieAssets/security.zip'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Enter your Pin',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xff000080),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Kindly enter your transaction pin to continue',
                  style: GoogleFonts.montserrat(
                    color: Color(0xff000080),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 54,
                        width: 50,
                        child: TextFormField(
                          controller: pin1,
                          onChanged: ((value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                          }),
                          onTap: () {
                            setState(() {
                              showInvalid = false;
                            });
                          },
                          obscureText: true,
                          obscuringCharacter: '•',
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey.shade300,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(30)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 54,
                        width: 50,
                        child: TextFormField(
                          controller: pin2,
                          onChanged: ((value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                          }),
                          onTap: () {
                            setState(() {
                              showInvalid = false;
                            });
                          },
                          obscureText: true,
                          obscuringCharacter: '•',
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey.shade300,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(30)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 54,
                        width: 50,
                        child: TextFormField(
                          controller: pin3,
                          onChanged: ((value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                          }),
                          onTap: () {
                            setState(() {
                              showInvalid = false;
                            });
                          },
                          obscureText: true,
                          obscuringCharacter: '•',
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey.shade300,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(30)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 54,
                        width: 50,
                        child: TextFormField(
                          controller: pin4,
                          onChanged: ((value) {
                            if (value.length == 1) {
                              FocusScope.of(context).nextFocus();
                            }
                          }),
                          onTap: () {
                            setState(() {
                              showInvalid = false;
                            });
                          },
                          obscureText: true,
                          obscuringCharacter: '•',
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey.shade300,
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(30)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          style: Theme
                              .of(context)
                              .textTheme
                              .headlineSmall,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                failed
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    showInvalid
                        ? Column(
                      children: [
                        Text(
                          'Invalid transaction PIN',
                          style: GoogleFonts.montserrat(),
                        ),
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Lottie.asset(
                              'assets/LottieAssets/failed.zip'),
                        ),
                        Center(
                          child: Text(
                            'Or if you have not created a transaction Pin before, kindly go to settings to create your transacton Pin',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                      ],
                    )
                        : Container(),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: pin1.text.isNotEmpty &
                      pin2.text.isNotEmpty &
                      pin3.text.isNotEmpty &
                      pin4.text.isNotEmpty
                          ? () async {
                        setState(() {
                          isApiCallProcess = true;
                        });
                        final prefs =
                        await SharedPreferences.getInstance();
                        String subdomain =
                            prefs.getString('subdomain') ??
                                'core.landmarkcooperative.org';
                        APIService apiService =
                        APIService(subdomain_url: subdomain);
                        String pinCode = pin1.text +
                            pin2.text +
                            pin3.text +
                            pin4.text;
                        apiService
                            .verifyPin(pinCode, widget.token)
                            .then((value) {
                          if (value.status) {
                            requestModel = widget
                                .externalBankTransferDetailsRequestModel;
                            requestModel.pinCode = pinCode;
                            requestModel.token = widget.token;
                            saveBeneficiary();
                            APIService apiServiceTrf = APIService(
                                subdomain_url: subdomain);
                            apiServiceTrf
                                .externalBankTransfer(requestModel)
                                .then((value) {
                              if (value.status) {
                                setState(() {
                                  isApiCallProcess = false;
                                });
                                //todo save to firebase here if beneficiary is checked
                                saveBeneficiary();

                                showModalBottomSheet(
                                    context: context,
                                    shape:
                                    const RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30),
                                        )),
                                    backgroundColor: Colors.white,
                                    isDismissible: false,
                                    isScrollControlled: true,
                                    builder:
                                        (BuildContext context) {
                                      return Wrap(
                                        children: <Widget>[
                                          Align(
                                            alignment:
                                            Alignment.center,
                                            child: Container(
                                              margin:
                                              const EdgeInsets
                                                  .only(top: 5),
                                              height: 4,
                                              width: 100,
                                              color:
                                              Colors.lightBlue,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 20),
                                          Align(
                                            alignment:
                                            Alignment.center,
                                            child: SizedBox(
                                              height: 150,
                                              width: 150,
                                              child: Lottie.asset(
                                                  'assets/LottieAssets/96245-success.zip'),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal: 20),
                                            child: Text(
                                              'You\'ve sent ₦${displayAmount
                                                  .format(int.parse(requestModel
                                                  .amount))} to ${requestModel
                                                  .destinationAccountName}',
                                              style: GoogleFonts
                                                  .montserrat(
                                                color: Color(
                                                    0xff000080),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 40),
                                          Align(
                                            alignment:
                                            Alignment.center,
                                            child: TextButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                            TransferReceipt(
                                                              customerWallets: widget
                                                                  .customerWallets,
                                                              fullName: widget
                                                                  .fullName,
                                                              token: widget
                                                                  .token,
                                                              externalBankTransferDetailsRequestModel: requestModel,
                                                            )));
                                              },
                                              icon: const Icon(
                                                Icons.share,
                                                color: Colors
                                                    .lightBlue,
                                              ),
                                              label: Text(
                                                'Share Receipt',
                                                style: GoogleFonts
                                                    .montserrat(
                                                    fontSize:
                                                    16,
                                                    fontWeight:
                                                    FontWeight
                                                        .w700),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 60),
                                          Align(
                                            alignment:
                                            Alignment.center,
                                            child: ElevatedButton(
                                              onPressed: () async{
                                                // return to home page
                                                final prefs = await SharedPreferences.getInstance();
                                                String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
                                                APIService apiService = APIService(subdomain_url: subdomain);

                                                // Fetch data asynchronously
                                                final value = await apiService.pageReload(widget.token);
                                                Navigator.of(context).pushReplacement(MaterialPageRoute(
                                                  builder: (context) => BottomNavBar(
                                                    pageIndex: 0,
                                                    fullName: widget.fullName,
                                                    token: value.token,
                                                    subdomain: subdomain,
                                                    customerWallets: value.customerWalletsList,
                                                    phoneNumber: widget.customerWallets[0].phoneNo,
                                                  ),
                                                ));
                                              },
                                              style: ElevatedButton
                                                  .styleFrom(
                                                backgroundColor:
                                                Colors.blue,
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      20),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    vertical:
                                                    12.0,
                                                    horizontal:
                                                    100),
                                                child: Text(
                                                  'Done',
                                                  style: GoogleFonts.openSans(
                                                      color: Colors
                                                          .white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 40),
                                          Container(
                                            height: 60,
                                          )
                                        ],
                                      );
                                    });
                              } else {
                                setState(() {
                                  isApiCallProcess = false;
                                });
                                showDialog(
                                    context: context,
                                    builder:
                                        (BuildContext context) {
                                      return AlertDialog(
                                        title: Container(
                                          height: 50,
                                          alignment:
                                          Alignment.centerLeft,
                                          padding:
                                          const EdgeInsets.only(
                                              left: 15),
                                          color: Colors.blueAccent,
                                          child: Center(
                                            child: Text(
                                              'Message',
                                              style: GoogleFonts
                                                  .montserrat(
                                                  color: Colors
                                                      .white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight
                                                      .w600),
                                            ),
                                          ),
                                        ),
                                        content:
                                        Text(value.message),
                                        actionsAlignment:
                                        MainAxisAlignment.start,
                                        actions: <Widget>[
                                          Center(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(
                                                    context)
                                                    .pop();
                                              },
                                              style: ElevatedButton
                                                  .styleFrom(
                                                backgroundColor:
                                                Colors.grey
                                                    .shade200,
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      10),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    vertical:
                                                    10,
                                                    horizontal:
                                                    15),
                                                child: Text(
                                                  "Close",
                                                  style: GoogleFonts
                                                      .montserrat(
                                                    color: Colors
                                                        .black,
                                                    fontWeight:
                                                    FontWeight
                                                        .w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              }
                            });
                          } else {
                            setState(() {
                              failed = true;
                              isApiCallProcess = false;
                              showInvalid = true;
                              pin1.text = '';
                              pin2.text = '';
                              pin3.text = '';
                              pin4.text = '';
                            });
                          }
                        });
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 70),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )
                    : ElevatedButton(
                  onPressed: pin1.text.isNotEmpty &
                  pin2.text.isNotEmpty &
                  pin3.text.isNotEmpty &
                  pin4.text.isNotEmpty
                      ? () async {
                    setState(() {
                      isApiCallProcess = true;
                    });
                    final prefs =
                    await SharedPreferences.getInstance();
                    String subdomain =
                        prefs.getString('subdomain') ??
                            'core.landmarkcooperative.org';
                    APIService apiService =
                    APIService(subdomain_url: subdomain);
                    String pinCode = pin1.text +
                        pin2.text +
                        pin3.text +
                        pin4.text;
                    apiService
                        .verifyPin(pinCode, widget.token)
                        .then((value) {
                      if (value.status) {
                        requestModel = widget
                            .externalBankTransferDetailsRequestModel;
                        requestModel.pinCode = pinCode;
                        requestModel.token = widget.token;
                        saveBeneficiary();
                        APIService apiServiceTrf =
                        APIService(subdomain_url: subdomain);
                        print(requestModel.toJson());
                        apiServiceTrf
                            .externalBankTransfer(requestModel)
                            .then((value) {
                          if (value.status) {
                            setState(() {
                              isApiCallProcess = false;
                            });
                            saveBeneficiary();
                            showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    )),
                                backgroundColor: Colors.white,
                                isDismissible: false,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return Wrap(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          margin:
                                          const EdgeInsets.only(
                                              top: 5),
                                          height: 4,
                                          width: 100,
                                          color: Colors.lightBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          height: 150,
                                          width: 150,
                                          child: Lottie.asset(
                                              'assets/LottieAssets/96245-success.zip'),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          'You\'ve sent ₦${displayAmount.format(
                                              int.parse(requestModel
                                                  .amount))} to ${requestModel
                                              .destinationAccountName}',
                                          style: GoogleFonts
                                              .montserrat(
                                            color:
                                            Color(0xff000080),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      Align(
                                        alignment: Alignment.center,
                                        child: TextButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                        TransferReceipt(
                                                          customerWallets:
                                                          widget
                                                              .customerWallets,
                                                          fullName:
                                                          widget.fullName,
                                                          token:
                                                          widget.token,
                                                          externalBankTransferDetailsRequestModel:
                                                          requestModel,
                                                        )));
                                          },
                                          icon: const Icon(
                                            Icons.share,
                                            color: Colors.lightBlue,
                                          ),
                                          label: Text(
                                            'Share Receipt',
                                            style: GoogleFonts
                                                .montserrat(
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight
                                                    .w700),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 60),
                                      Align(
                                        alignment: Alignment.center,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            // return to home page
                                            final prefs = await SharedPreferences.getInstance();
                                            String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
                                            APIService apiService = APIService(subdomain_url: subdomain);

                                            // Fetch data asynchronously
                                            final value = await apiService.pageReload(widget.token);
                                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                              builder: (context) => BottomNavBar(
                                                pageIndex: 0,
                                                fullName: widget.fullName,
                                                token: value.token,
                                                subdomain: subdomain,
                                                customerWallets: value.customerWalletsList,
                                                phoneNumber: widget.customerWallets[0].phoneNo,
                                              ),
                                            ));
                                          },
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                            Colors.blue,
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(20),
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                vertical: 12.0,
                                                horizontal:
                                                100),
                                            child: Text(
                                              'Done',
                                              style: GoogleFonts
                                                  .openSans(
                                                  color: Colors
                                                      .white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      Container(
                                        height: 60,
                                      )
                                    ],
                                  );
                                });
                          } else {
                            setState(() {
                              isApiCallProcess = false;
                            });
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Container(
                                      height: 50,
                                      alignment:
                                      Alignment.centerLeft,
                                      padding:
                                      const EdgeInsets.only(
                                          left: 15),
                                      color: Colors.blueAccent,
                                      child: Center(
                                        child: Text(
                                          'Message',
                                          style: GoogleFonts
                                              .montserrat(
                                              color:
                                              Colors.white,
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight
                                                  .w600),
                                        ),
                                      ),
                                    ),
                                    content: Text(value.message),
                                    actionsAlignment:
                                    MainAxisAlignment.start,
                                    actions: <Widget>[
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop();
                                          },
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor: Colors
                                                .grey.shade200,
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(10),
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                vertical: 10,
                                                horizontal: 15),
                                            child: Text(
                                              "Close",
                                              style: GoogleFonts
                                                  .montserrat(
                                                color: Colors.black,
                                                fontWeight:
                                                FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          }
                        });
                      } else {
                        setState(() {
                          failed = true;
                          isApiCallProcess = false;
                          showInvalid = true;
                          pin1.text = '';
                          pin2.text = '';
                          pin3.text = '';
                          pin4.text = '';
                        });
                      }
                    });
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 70),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  saveBeneficiary() async {
    if (widget.saveBeneficiary) {
      final prefs =
      await SharedPreferences.getInstance();
      String subdomain =
          prefs.getString('subdomain') ??
              'core.landmarkcooperative.org';
      APIService apiService =
      APIService(subdomain_url: subdomain);
      CustomerBeneficiaryRequestModel customerBeneficiaryRequestModel = CustomerBeneficiaryRequestModel(
        beneficiaryAccountName: widget.externalBankTransferDetailsRequestModel
            .destinationAccountName,
        beneficiaryAccountNumber: widget.externalBankTransferDetailsRequestModel
            .destinationAccountNumber,
        beneficiaryBankName: widget.externalBankTransferDetailsRequestModel
            .destinationBankName,
        beneficiaryBankCode: widget.externalBankTransferDetailsRequestModel
            .accountBank,
      );
      apiService.addCustomerBeneficiary(
          customerBeneficiaryRequestModel, widget.token);
    }
  }
}
