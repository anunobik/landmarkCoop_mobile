import 'package:landmarkcoop_mobile_app/pages/last_registration.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/custom_text_form_field.dart';

class FirstRegistration extends StatefulWidget {
  const FirstRegistration({Key? key}) : super(key: key);

  @override
  State<FirstRegistration> createState() => _FirstRegistrationState();
}

class _FirstRegistrationState extends State<FirstRegistration> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  bool isDisabled = true;

  void enableButton() {
    phoneController.text.isEmpty &&
            emailController.text.isEmpty &&
            firstNameController.text.isEmpty
        ? setState(() {
            isDisabled = true;
          })
        : setState(() {
            isDisabled = false;
          });
  }

  void validate() {
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9]{0,253}[a-zA-Z0-9])?)*$");
    if (phoneController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Phone number cannot be empty');
    } else if (firstNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'First Name cannot be empty');
    } else if (lastNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Last Name cannot be empty');
    } else if (emailController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'E-mail cannot be empty');
    }else if (phoneController.text.length != 11) {
      Fluttertoast.showToast(msg: 'Phone number must be 11 digits');
    } else {
      String phone = phoneController.text;
      String email = emailController.text;
      String firstName = firstNameController.text;
      String middleName = middleNameController.text;
      String lastName = lastNameController.text;

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LastRegistration(
              email: email,
              phone: phone,
              fName: firstName,
              sName: middleName,
              mName: lastName)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed: isDisabled
                ? null
                : () {
                    validate();
                  },
            child: Text(
              'Next',
              style: GoogleFonts.montserrat(
                  color: isDisabled ? Colors.grey : const Color(0xffd4af37),
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: GestureDetector(
              onTap: (){
                enableButton;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Let's Help You Setup Your Account",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 35),
                  CustomTextFormField(
                    keyboardType: TextInputType.name,
                    controller: firstNameController,
                    hintText: "First Name",
                    enabled: true,
                    enableButton: enableButton,
                  ),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: middleNameController,
                    hintText: "Middle Name (Optional)",
                    enabled: true,
                    enableButton: enableButton,
                  ),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: lastNameController,
                    hintText: "Last Name",
                    enabled: true,
                    enableButton: enableButton,
                  ),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    hintText: "Enter Email",
                    enabled: true,
                    enableButton: enableButton,
                  ),
                  const SizedBox(height: 15),
                  CustomTextFormField(
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    hintText: "Enter Phone Number",
                    enabled: true,
                    enableButton: enableButton,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
