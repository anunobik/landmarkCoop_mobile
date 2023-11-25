import 'dart:convert';

class TransactionInitResponseModel {
  final bool status;
  final String message;
  final String authorization_url;
  final String access_code;
  final String reference;

  TransactionInitResponseModel({
    required this.status,
    required this.message,
    required this.authorization_url,
    required this.access_code,
    required this.reference,
  });

  factory TransactionInitResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionInitResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      authorization_url: json['data']['authorization_url'] ?? '',
      access_code: json['data']['access_code'] ?? '',
      reference: json['data']['reference'] ?? '',
    );
  }
}

class TransactionInitRequestModel {
  var email;
  var amount;

  TransactionInitRequestModel({
    required this.email,
    required this.amount,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'email': email.trim(),
      'amount': amount,
    });
  }
}
