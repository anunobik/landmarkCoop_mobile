import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../util/ProgressHUD.dart';
import '../util/home_drawer.dart';
import 'dashboard.dart';

class TransactionPin extends StatefulWidget {
  final String fullName;
  final String token;
  final List<CustomerWalletsBalanceModel> customerWallets;
  final List<LastTransactionsModel> lastTransactions;

  const TransactionPin(
      {super.key, required this.customerWallets, required this.fullName, required this.token, required this.lastTransactions});

  @override
  State<TransactionPin> createState() => _TransactionPinState();
}

class _TransactionPinState extends State<TransactionPin> {
  TextEditingController createPinController = TextEditingController();
  TextEditingController conCreatePinController = TextEditingController();
  TextEditingController oldPinController = TextEditingController();
  TextEditingController newPinController = TextEditingController();
  TextEditingController conNewPinController = TextEditingController();
  bool isDisabled = true;
  bool isApiCallProcess = false;
  bool createPin = false;
  bool editPin = false;
  bool obscure = true;
  bool obscure1 = true;
  bool obscure2 = true;
  bool obscure3 = true;
  bool obscure4 = true;
  late FocusNode focusNode;
  late FocusNode focusNode1;
  late FocusNode focusNode2;
  late FocusNode focusNode3;
  late FocusNode focusNode4;

  @override
  initState() {
    focusNode = FocusNode();
    focusNode.addListener(() => setState(() {}));
    focusNode1 = FocusNode();
    focusNode1.addListener(() => setState(() {}));
    focusNode2 = FocusNode();
    focusNode2.addListener(() => setState(() {}));
    focusNode3 = FocusNode();
    focusNode3.addListener(() => setState(() {}));
    focusNode4 = FocusNode();
    focusNode4.addListener(() => setState(() {}));
    checkPinCreated();
    super.initState();
  }

  Future<void> checkPinCreated() async {
    APIService apiService = APIService();
    apiService.isPinCreated(widget.token).then((value) {
      print(value.status);
      if(value.status){
        setState(() {
          createPin = false;
          editPin = true;
        });
      }else{
        setState(() {
          createPin = true;
          editPin = false;
        });
      }
    });
  }

  void enableButton() {
    createPinController.text.isEmpty
        ? setState(() {
            isDisabled = true;
          })
        : setState(() {
            isDisabled = false;
          });
  }

  void enableButton1() {
    newPinController.text.isEmpty
        ? setState(() {
            isDisabled = true;
          })
        : setState(() {
            isDisabled = false;
          });
  }

  void obscureView() {
    setState(() {
      obscure = !obscure;
    });
  }

  void obscureView1() {
    setState(() {
      obscure1 = !obscure1;
    });
  }

  void obscureView2() {
    setState(() {
      obscure2 = !obscure2;
    });
  }

  void obscureView3() {
    setState(() {
      obscure3 = !obscure3;
    });
  }

  void obscureView4() {
    setState(() {
      obscure4 = !obscure4;
    });
  }

  @override
  void dispose() {
    createPinController.dispose();
    conCreatePinController.dispose();
    oldPinController.dispose();
    newPinController.dispose();
    conNewPinController.dispose();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Transaction Pin',
            style: GoogleFonts.montserrat(
              color: const Color(0xff000080),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        iconTheme: const IconThemeData(color: Color(0xff000080)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              createPin
                  ? Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Create Transaction Pin',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(height: 5,),
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            decoration: focusNode.hasFocus
                                ? BoxDecoration(
                                    boxShadow: const [BoxShadow(color: Colors.black38,blurRadius: 6)],
                                    borderRadius: BorderRadius.circular(20),
                                  )
                                : BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                            child: TextFormField(
                              focusNode: focusNode,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              controller: createPinController,
                              obscureText: obscure,
                              obscuringCharacter: "*",
                              maxLength: 4,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Enter 4 digit pin',
                                hintStyle: GoogleFonts.montserrat(
                                  color: const Color(0xff9ca2ac),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                suffixIcon: obscure
                                    ? IconButton(
                                        onPressed: obscureView,
                                        icon: const Icon(Icons.visibility_off),
                                        color: Colors.grey,
                                      )
                                    : IconButton(
                                        onPressed: obscureView,
                                        icon: const Icon(Icons.visibility),
                                        color: Colors.grey,
                                      ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                              ),
                              onTap: enableButton,
                            ),
                          ),
                          const SizedBox(height: 15),
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            decoration: focusNode1.hasFocus
                                ? BoxDecoration(
                                    boxShadow: const [BoxShadow(color: Colors.black38,blurRadius: 6)],
                                    borderRadius: BorderRadius.circular(20),
                                  )
                                : BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                            child: TextFormField(
                              focusNode: focusNode1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              controller: conCreatePinController,
                              obscureText: obscure1,
                              obscuringCharacter: "*",
                              maxLength: 4,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Confirm 4 digit pin',
                                hintStyle: GoogleFonts.montserrat(
                                  color: const Color(0xff9ca2ac),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                suffixIcon: obscure1
                                    ? IconButton(
                                        onPressed: obscureView1,
                                        icon: const Icon(Icons.visibility_off),
                                        color: Colors.grey,
                                      )
                                    : IconButton(
                                        onPressed: obscureView1,
                                        icon: const Icon(Icons.visibility),
                                        color: Colors.grey,
                                      ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                              ),
                              onTap: enableButton,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Center(
                                child: ElevatedButton(
                                    onPressed: () async {
                                      if(createPinController.text.length == 4){
                                        if(createPinController.text == conCreatePinController.text) {
                                          setState(() {
                                            isApiCallProcess = true;
                                          });
                                          UserPinCodeRequestModel requestModel = UserPinCodeRequestModel(pinCode: createPinController.text, confirmPinCode: conCreatePinController.text);
                                          APIService apiService = APIService();
                                          apiService.createPincode(requestModel, widget.token).then((value) {
                                            if(value.status){
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Container(
                                                        height: 50,
                                                        alignment: Alignment.centerLeft,
                                                        padding: const EdgeInsets.only(left: 15),
                                                        color: Colors.blueAccent,
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
                                                      content: Text(value.message, textAlign: TextAlign.center,),
                                                      actionsAlignment: MainAxisAlignment.start,
                                                      actions: <Widget>[
                                                        Center(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(context).push(MaterialPageRoute(
                                                                builder: (context) => HomeDrawer(
                                                                  value: 0,
                                                                  page: Dashboard(
                                                                    token: widget.token,
                                                                    fullName: widget.fullName, customerWallets: widget.customerWallets,
                                                                    lastTransactions: widget.lastTransactions,
                                                                  ),
                                                                  name: 'wallet',
                                                                  token: widget.token,
                                                                  fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactionsList: widget.lastTransactions,
                                                                ),
                                                              )
                                                              );
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              primary: Colors.grey.shade200,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                  vertical: 10, horizontal: 15),
                                                              child: Text(
                                                                "Close",
                                                                style: GoogleFonts.montserrat(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            }else{
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
                                                        color: Colors.blueAccent,
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
                                                      content: Text(value.message, textAlign: TextAlign.center,),
                                                      actionsAlignment: MainAxisAlignment.start,
                                                      actions: <Widget>[
                                                        Center(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              primary: Colors.grey.shade200,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                  vertical: 10, horizontal: 15),
                                                              child: Text(
                                                                "Close",
                                                                style: GoogleFonts.montserrat(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w600,
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
                                        }else{
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
                                                    color: Colors.blueAccent,
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
                                                  content: const Text("PIN not the same", textAlign: TextAlign.center,),
                                                  actionsAlignment: MainAxisAlignment.start,
                                                  actions: <Widget>[
                                                    Center(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          primary: Colors.grey.shade200,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 10, horizontal: 15),
                                                          child: Text(
                                                            "Close",
                                                            style: GoogleFonts.montserrat(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w600,
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
                                      }else{
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
                                                  color: Colors.blueAccent,
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
                                                content: const Text("PIN must be 4 digits ****", textAlign: TextAlign.center,),
                                                actionsAlignment: MainAxisAlignment.start,
                                                actions: <Widget>[
                                                  Center(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        primary: Colors.grey.shade200,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            vertical: 10, horizontal: 15),
                                                        child: Text(
                                                          "Close",
                                                          style: GoogleFonts.montserrat(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.w600,
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

                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "Submit",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ),
                        ],
                      ),
                  )
                  : Container(),

              editPin
                  ? Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Edit Transaction Pin',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(height: 5,),
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            decoration: focusNode2.hasFocus
                                ? BoxDecoration(
                                    boxShadow: const [BoxShadow(color: Colors.black38,blurRadius: 6)],
                                    borderRadius: BorderRadius.circular(20),
                                  )
                                : BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                            child: TextFormField(
                              focusNode: focusNode2,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              controller: oldPinController,
                              obscureText: obscure2,
                              obscuringCharacter: "*",
                              maxLength: 4,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Enter old pin',
                                hintStyle: GoogleFonts.montserrat(
                                  color: const Color(0xff9ca2ac),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                suffixIcon: obscure2
                                    ? IconButton(
                                        onPressed: obscureView2,
                                        icon: const Icon(Icons.visibility_off),
                                        color: Colors.grey,
                                      )
                                    : IconButton(
                                        onPressed: obscureView2,
                                        icon: const Icon(Icons.visibility),
                                        color: Colors.grey,
                                      ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                              ),
                              onTap: enableButton1,
                            ),
                          ),
                          const SizedBox(height: 15),
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            decoration: focusNode3.hasFocus
                                ? BoxDecoration(
                                    boxShadow: const [BoxShadow(color: Colors.black38,blurRadius: 6)],
                                    borderRadius: BorderRadius.circular(20),
                                  )
                                : BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                            child: TextFormField(
                              focusNode: focusNode3,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              controller: newPinController,
                              obscureText: obscure3,
                              obscuringCharacter: "*",
                              maxLength: 4,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Enter new 4 digit pin',
                                hintStyle: GoogleFonts.montserrat(
                                  color: const Color(0xff9ca2ac),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                suffixIcon: obscure3
                                    ? IconButton(
                                        onPressed: obscureView3,
                                        icon: const Icon(Icons.visibility_off),
                                        color: Colors.grey,
                                      )
                                    : IconButton(
                                        onPressed: obscureView3,
                                        icon: const Icon(Icons.visibility),
                                        color: Colors.grey,
                                      ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                              ),
                              onTap: enableButton1,
                            ),
                          ),
                          const SizedBox(height: 15),
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            decoration: focusNode3.hasFocus
                                ? BoxDecoration(
                                    boxShadow: const [BoxShadow(color: Colors.black38,blurRadius: 6)],
                                    borderRadius: BorderRadius.circular(20),
                                  )
                                : BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                            child: TextFormField(
                              focusNode: focusNode4,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              controller: conNewPinController,
                              obscureText: obscure4,
                              obscuringCharacter: "*",
                              maxLength: 4,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Confirm new 4 digit pin',
                                hintStyle: GoogleFonts.montserrat(
                                  color: const Color(0xff9ca2ac),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                suffixIcon: obscure4
                                    ? IconButton(
                                        onPressed: obscureView4,
                                        icon: const Icon(Icons.visibility_off),
                                        color: Colors.grey,
                                      )
                                    : IconButton(
                                        onPressed: obscureView4,
                                        icon: const Icon(Icons.visibility),
                                        color: Colors.grey,
                                      ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                              ),
                              onTap: enableButton1,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: ElevatedButton(
                                    onPressed: () async {
                                      if(newPinController.text.length == 4){
                                        if(newPinController.text == conNewPinController.text) {
                                          setState(() {
                                            isApiCallProcess = true;
                                          });
                                          UserPinCodeModifyRequestModel requestModel = UserPinCodeModifyRequestModel(oldPinCode: oldPinController.text, newPinCode: newPinController.text, confirmNewPinCode: conNewPinController.text);
                                          final prefs = await SharedPreferences.getInstance();
                                          String subdomain = prefs.getString('subdomain') ??
                                              'https://core.myminervahub.com';

                                          APIService apiService = APIService();
                                          apiService.changePincode(requestModel, widget.token).then((value) {
                                            if(value.status){
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Container(
                                                        height: 50,
                                                        alignment: Alignment.centerLeft,
                                                        padding: const EdgeInsets.only(left: 15),
                                                        color: Colors.blueAccent,
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
                                                      content: Text(value.message, textAlign: TextAlign.center,),
                                                      actionsAlignment: MainAxisAlignment.start,
                                                      actions: <Widget>[
                                                        Center(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(context).push(MaterialPageRoute(
                                                                builder: (context) => HomeDrawer(
                                                                  value: 0,
                                                                  page: Dashboard(
                                                                    token: widget.token,
                                                                    fullName: widget.fullName, customerWallets: widget.customerWallets,
                                                                    lastTransactions: widget.lastTransactions,
                                                                  ),
                                                                  name: 'wallet',
                                                                  token: widget.token,
                                                                  fullName: widget.fullName, customerWallets: widget.customerWallets, lastTransactionsList: widget.lastTransactions,
                                                                ),
                                                              )
                                                              );
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              primary: Colors.grey.shade200,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                  vertical: 10, horizontal: 15),
                                                              child: Text(
                                                                "Close",
                                                                style: GoogleFonts.montserrat(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            }else{
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
                                                        color: Colors.blueAccent,
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
                                                      content: Text(value.message, textAlign: TextAlign.center,),
                                                      actionsAlignment: MainAxisAlignment.start,
                                                      actions: <Widget>[
                                                        Center(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              primary: Colors.grey.shade200,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                  vertical: 10, horizontal: 15),
                                                              child: Text(
                                                                "Close",
                                                                style: GoogleFonts.montserrat(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w600,
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
                                        }else{
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
                                                    color: Colors.blueAccent,
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
                                                  content: const Text("PIN not the same", textAlign: TextAlign.center,),
                                                  actionsAlignment: MainAxisAlignment.start,
                                                  actions: <Widget>[
                                                    Center(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          primary: Colors.grey.shade200,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 10, horizontal: 15),
                                                          child: Text(
                                                            "Close",
                                                            style: GoogleFonts.montserrat(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w600,
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
                                      }else{
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
                                                  color: Colors.blueAccent,
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
                                                content: const Text("PIN must be 4 digits ****", textAlign: TextAlign.center,),
                                                actionsAlignment: MainAxisAlignment.start,
                                                actions: <Widget>[
                                                  Center(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        primary: Colors.grey.shade200,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            vertical: 10, horizontal: 15),
                                                        child: Text(
                                                          "Close",
                                                          style: GoogleFonts.montserrat(
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.w600,
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

                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "Submit",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                  )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
