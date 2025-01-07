import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoCard extends StatelessWidget {
  final String fullName;
  final String subdomain;
  const InfoCard({
    Key? key,
    required this.fullName,
    required this.subdomain
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:  CircleAvatar(
        radius: 20.0,
        backgroundImage:
            AssetImage('assets/Logo.png'),
      ),
      title: Text(fullName,
        style: GoogleFonts.montserrat(
          color: Color(0xff000080),
          fontWeight: FontWeight.w500
        ),
      ),
    );
  }
}