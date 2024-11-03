import 'dart:convert';

class PwdResetResponseModel {
  final String feedback;

  PwdResetResponseModel({required this.feedback});

  factory PwdResetResponseModel.fromJson(Map<String, dynamic> json) {
    return PwdResetResponseModel(
      feedback: json['feedback'] ?? '',
    );
  }
}

class PwdResetRequestModel {
  var email;

  PwdResetRequestModel({
    this.email,
  });

  String toJson() {
    return jsonEncode(<String, String>{
        'email': email.trim()
      });
  }
}
