import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;
  const NotificationBadge({super.key, required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: 25,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('$totalNotifications',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}