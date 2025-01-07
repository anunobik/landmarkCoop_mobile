import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthChangePage extends StatelessWidget {
  const AuthChangePage({
    Key? key,
    required this.infoText,
    required this.flipPageText,
    required this.flipCard,
  }) : super(key: key);

  final String infoText;
  final String flipPageText;
  final Function() flipCard;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          infoText,
          style: GoogleFonts.montserrat(
            color: Color(0xff000080).withOpacity(0.7),
          ),
        ),
        GestureDetector(
          onTap: flipCard,
          child: Container(
            color: Colors.transparent,
            padding:
                const EdgeInsets.only(right: 20, left: 5, top: 6, bottom: 6),
            child: Text(
              flipPageText,
              style: GoogleFonts.montserrat(
                color: Colors.pink[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }
}