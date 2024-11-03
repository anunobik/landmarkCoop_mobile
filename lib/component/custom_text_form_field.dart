import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatefulWidget {
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final VoidCallback? enableButton;

  const CustomTextFormField({
    super.key,
    required this.keyboardType,
    required this.controller,
    required this.hintText,
    required this.enabled,
    this.enableButton,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late FocusNode focusNode;
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: focusNode.hasFocus
          ? BoxDecoration(
              boxShadow: const [BoxShadow(blurRadius: 6)],
              borderRadius: BorderRadius.circular(20),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
      child: TextFormField(
        focusNode: focusNode,
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        enabled: widget.enabled,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.montserrat(
            color: const Color(0xff9ca2ac),
          ),
          filled: true,
          fillColor: widget.enabled ? Colors.white : Colors.grey.shade200,
          hoverColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        onTap: widget.enableButton,
        // validator: (value) {
        //   String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
        //   RegExp regExp = RegExp(patttern);
        //   if (value!.isEmpty) {
        //     return 'Please enter mobile number';
        //   }
        //   else if (!regExp.hasMatch(value)) {
        //     return 'Please enter valid mobile number';
        //   }
        //   return null;
        // },
      ),
    );
  }
}
