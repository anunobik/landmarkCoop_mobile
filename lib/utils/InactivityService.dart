import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../main_view.dart';

class InactivityService {
  static final InactivityService _instance = InactivityService._internal();

  factory InactivityService() => _instance;

  InactivityService._internal();

  Timer? _inactivityTimer;

  void initializeInactivityTimer(BuildContext context, String token) {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 5), () {
      _navigateToLogin(context, token);
    });
  }

  void _navigateToLogin(BuildContext context, String token) async {
    final prefs = await SharedPreferences.getInstance();
    String institution = prefs.getString('institution') ?? 'Minerva Hub';
    String subdomain = prefs.getString('subdomain') ?? 'https://core.landmarkcooperative.org';
    APIService apiService = APIService(subdomain_url: subdomain);

    // Perform logout using the token
    apiService.logout(token).then((value) {
      prefs.setString('biometricToken', value);
      print('Token at Logout - $value');
    });

    // Navigate to login screen
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainView(),
      ),
    );
  }

  void resetInactivityTimer(BuildContext context, String token) {
    _inactivityTimer?.cancel();
    initializeInactivityTimer(context, token);
  }
}
