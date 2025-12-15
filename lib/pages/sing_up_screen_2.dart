import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_latest/main_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../component/congrats.dart';
import '../model/customer_model.dart';
import '../model/other_model.dart';
import '../utils/ProgressHUD.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SingUpScreen2 extends StatefulWidget {
  final String fName;
  final String sName;
  final String mName;

  const SingUpScreen2(
      {Key? key, required this.fName, required this.sName, required this.mName})
      : super(key: key);

  @override
  State<SingUpScreen2> createState() => _SingUpScreen2State();
}

class _SingUpScreen2State extends State<SingUpScreen2> {
  bool value = false;
  CustomerRequestModel customerRequestModel = CustomerRequestModel();
  bool isApiCallProcess = false;
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
  List<BranchResponseModel> dataBranch = <BranchResponseModel>[
    BranchResponseModel(
      id: 0,
      branchName: 'Select Branch',
      displayName: 'Select Branch',
      address: 'Select Branch',
    )
  ];
  BranchResponseModel? currentBranch;
  BranchResponseModel? selectedBranch;
  bool disableRegisterBtn = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  bool isMinervaHub = false;
  bool isBVN = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  TextEditingController bvnController = TextEditingController();
  bool isSuccess = true;

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    referralController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getProducts();
    getBranches();
    checkFintech();
  }

  Future<void> checkFintech() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    String institution = prefs.getString('institution') ?? 'Minerva Hub';
    if (institution == 'Landmark Coop' ||
        institution.isEmpty) {
      isMinervaHub = true;
      disableRegisterBtn = false;
    }
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
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Image.asset(
                "assets/images/girl-phone.jpeg",
                width: width,
                height: height * 0.5,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: formKey,
                child: Column(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'More Information',
                      style: TextStyle(
                        color: Color(0xff000080),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF393939),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Email (Optional)',
                        labelStyle: TextStyle(
                          color: Color(0xff000080),
                          fontSize: 15,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w600,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF837E93),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF393939),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          color: Color(0xff000080),
                          fontSize: 15,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w600,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF837E93),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    isMinervaHub ? Container() : productBuilder(),
                    isMinervaHub ? Container() : const SizedBox(height: 10),
                    isMinervaHub ? Container() : branchBuilder(),
                    const SizedBox(height: 5),
                    isMinervaHub ? bvnChooserBuilder() : Container(),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: referralController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF393939),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Referral Number (optional)',
                        labelStyle: TextStyle(
                          color: Color(0xff000080),
                          fontSize: 15,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w600,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Color(0xFF837E93),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: SizedBox(
                        width: 329,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: disableRegisterBtn
                              ? null
                              : () {
                                  setState(() {
                                    registerAccount();
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Text(
                          ' have an account?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF837E93),
                            fontSize: 13,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          width: 2.5,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MainView()));
                          },
                          child: const Text(
                            'Log In ',
                            style: TextStyle(
                              color: Color(0xff000080),
                              fontSize: 13,
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  registerAccount() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    String selectedBranchId;
    String selectedProductId;
    if (phoneController.text.isNotEmpty) {
      customerRequestModel.email = emailController.text;
      customerRequestModel.phoneNumber = phoneController.text;
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

      if (isMinervaHub) {
        if (isBVN) {
          if (bvnController.text.isEmpty) {
            Future.delayed(const Duration(seconds: 2), () async {
              setState(() {
                isSuccess = false;
                isApiCallProcess = true;
              });
            });
            Future.delayed(const Duration(seconds: 4), () async {
              Fluttertoast.showToast(msg: 'BVN cannot be empty');
            });
          } else if (bvnController.text.length < 11) {
            Future.delayed(const Duration(seconds: 4), () async {
              Fluttertoast.showToast(msg: 'Invalid BVN');
            });
            Future.delayed(const Duration(seconds: 7), () async {
              setState(() {
                isApiCallProcess = false;
              });
            });
          } else {
            //todo account opening with BVN
            print(customerRequestModel.toJson());
            apiService
                .registerCustomerWithBVN(
                    customerRequestModel, bvnController.text.trim(), referralId)
                .then((value) {
              if (value.status) {
                setState(() {
                  isApiCallProcess = false;
                });
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const Congrats(
                          response:
                              "Your account has been successfully opened.\n\nKindly check email Inbox/Spam for validation link.",
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
        } else {
          //todo account opening without BVN
          apiService
              .registerCustomerWithoutBVN(customerRequestModel, referralId)
              .then((value) {
            if (value.status) {
              setState(() {
                isApiCallProcess = false;
              });
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const Congrats(
                        response:
                            "Your account has been successfully opened.\n\nKIndly check email Inbox/Spam for validation link.",
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
      } else {
        selectedBranchId = selectedBranch!.id.toString();
        selectedProductId = selectedProduct!.id.toString();

        apiService
            .registerCustomer(customerRequestModel, referralId,
                selectedProductId, selectedBranchId)
            .then((value) {
          if (value.status) {
            setState(() {
              isApiCallProcess = false;
            });
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const Congrats(
                      response:
                          "Your account has been successfully opened.\n\nKindly check email Inbox/Spam for validation link.",
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
    } else {
      // if (emailController.text.isEmpty) {
      //   Future.delayed(const Duration(seconds: 4), () async {
      //     Fluttertoast.showToast(msg: 'Email cannot be empty');
      //   });
      //   Future.delayed(const Duration(seconds: 7), () async {
      //     setState(() {
      //       isApiCallProcess = false;
      //     });
      //   });
      // }

      if (phoneController.text.isEmpty) {
        Future.delayed(const Duration(seconds: 4), () async {
          Fluttertoast.showToast(msg: 'Phone Number cannot be empty');
        });
        Future.delayed(const Duration(seconds: 7), () async {
          setState(() {
            isApiCallProcess = false;
          });
        });
      }
    }
  }

  getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
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

  getBranches() async {
    final prefs = await SharedPreferences.getInstance();
    String subdomain =
        prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';

    APIService apiService = APIService(subdomain_url: subdomain);
    return apiService.getAllBranches().then((value) {
      currentBranch = dataBranch[0];

      for (var singleData in value) {
        dataBranch.add(singleData);
      }
      setState(() {
        dataBranch;
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
                if (isMinervaHub) {
                  disableRegisterBtn = false;
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

  Widget branchBuilder() {
    return FormField<BranchResponseModel>(
        builder: (FormFieldState<BranchResponseModel> state) {
      return InputDecorator(
        decoration: InputDecoration(
          isDense: true,
          labelStyle: GoogleFonts.montserrat(
            color: const Color(0xff9ca2ac),
          ),
          errorStyle: GoogleFonts.montserrat(
            color: Colors.redAccent,
          ),
          hintText: 'Select Branch',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // isEmpty: currentProduct.biller_code == "",
        child: DropdownButtonHideUnderline(
          child: DropdownButton<BranchResponseModel>(
            alignment: AlignmentDirectional.centerEnd,
            value: currentBranch,
            isDense: true,
            isExpanded: true,
            onChanged: (newValue) {
              setState(() {
                currentBranch = newValue!;
                state.didChange(newValue);
                selectedBranch = newValue;
                disableRegisterBtn = false;
              });
            },
            items: dataBranch
                .map((map) => DropdownMenuItem<BranchResponseModel>(
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

  Widget bvnChooserBuilder() {
    return Column(
      children: [
        Text(
          "Open with BVN?",
          style: GoogleFonts.montserrat(
            fontSize: 15,
            color: Color(0xff000080),
          ),
        ),
        Text(
          "Account opened with BVN would enable you receive funds from other banks apps and transfer to other banks",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: Color(0xff000080),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Yes'),
                leading: Radio(
                  value: true,
                  groupValue: isBVN,
                  onChanged: (value) {
                    setState(() {
                      isBVN = value as bool;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('No'),
                leading: Radio(
                  value: false,
                  groupValue: isBVN,
                  onChanged: (value) {
                    setState(() {
                      isBVN = value as bool;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        isBVN
            ? Form(
                key: formKey2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: bvnController,
                      textAlign: TextAlign.center,
                      maxLength: 11,
                      style: GoogleFonts.montserrat(
                          fontSize: 15,
                          color: Color(0xff000080),
                          fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Enter BVN',
                        hintStyle: GoogleFonts.montserrat(
                          color: const Color(0xff9ca2ac),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 0.7),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }
}
