import 'package:landmarkcoop_mobile_app/api/api_service.dart';
import 'package:landmarkcoop_mobile_app/component/congrats.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../util/ProgressHUD.dart';
import '../component/custom_text_form_field.dart';

class LastRegistration extends StatefulWidget {
  final String fName;
  final String sName;
  final String mName;
  final String email;
  final String phone;
  const LastRegistration(
      {super.key,
      required this.email,
      required this.phone,
      required this.fName,
      required this.sName,
      required this.mName});

  @override
  State<LastRegistration> createState() => _LastRegistrationState();
}

class _LastRegistrationState extends State<LastRegistration> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController referralController = TextEditingController();
  bool value = false;
  CustomerRequestModel customerRequestModel = CustomerRequestModel();
  bool isApiCallProcess = false;
  APIService apiService = APIService();
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
  bool disableRegisterBtn = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProducts();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      productBuilder(),
                      const SizedBox(height: 10),
                      selectedProduct != null
                          ? Column(
                              children: [
                                Center(
                                  child: Text(
                                    selectedProduct!.displayName,
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Center(
                                  child: Text(
                                    selectedProduct!.description,
                                    textAlign: TextAlign.justify,
                                    style: GoogleFonts.montserrat(fontSize: 8),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(height: 15),
                      CustomTextFormField(
                        keyboardType: TextInputType.number,
                        controller: referralController,
                        hintText: "Referral No (Optional)",
                        enabled: true,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Checkbox(
                              value: value,
                              onChanged: (newValue) {
                                setState(() {
                                  value = newValue!;
                                });
                              },
                            ),
                            RichText(
                              text: TextSpan(
                                  text: "I agree to the ",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "terms",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.blue,
                                        ),
                                        // ignore: avoid_print
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = (() =>
                                              print('Terms & Condition'))),
                                  ]),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: disableRegisterBtn
                      ? null
                      : () {
                          setState(() {
                            registerAccount();
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffd4af37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Register",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  registerAccount() {
    APIService apiService = APIService();
    customerRequestModel.email = widget.email;
    customerRequestModel.phoneNumber = widget.phone;
    customerRequestModel.firstName = widget.fName;
    customerRequestModel.middleName = widget.mName;
    customerRequestModel.lastName = widget.sName;

    setState(() {
      isApiCallProcess = true;
    });
    String referralId;
    if (referralController.text.isEmpty || referralController.text == '') {
      referralId = '0';
    } else {
      referralId = referralController.text.trim();
    }
    print(customerRequestModel.toString());

    apiService
        .registerCustomer(
            customerRequestModel, referralId, selectedProduct!.id.toString())
        .then((value) {
      if (value.status){
        setState(() {
          isApiCallProcess = false;
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const Congrats(
                  response: "Your account has been successfully opened.\n\nKindly check email Inbox/Spam for login details.",
                )));
      } else {
        setState(() {
          isApiCallProcess = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  "Message",
                  textAlign: TextAlign.center,
                ),
                // titlePadding: EdgeInsets.all(5.0),
                content: Text(
                  value.message,
                  textAlign: TextAlign.center,
                ),
                // contentPadding: EdgeInsets.all(5.0),
              );
            });
      }
    }).catchError((e) {
      print("The Error is $e");
      setState(() {
        isApiCallProcess = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("Message"),
              content: Text("Email or Phone already exist"),
            );
          });
    });
  }

  getProducts() {
    return apiService.getProducts().then((value) {
      currentProduct = data[0];

      for (var singleData in value) {
        if (!singleData.productName.contains('loan') &&
            !singleData.displayName.contains('loan')) {
          data.add(singleData);
        }
      }
      setState(() {
        data;
      });
    });
  }

  Widget productBuilder() {
    return FormField<ProductResponseModel>(
        builder: (FormFieldState<ProductResponseModel> state) {
      return InputDecorator(
        decoration: InputDecoration(
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
                disableRegisterBtn = false;
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
}
