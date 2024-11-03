import 'dart:convert';

class CardValidationResponseModel {
  final String amount;
  final String chargedAmount;
  final String processorResponse;
  final String flwRef;
  final String status;
  final String message;

  CardValidationResponseModel(
      {required this.amount,
      required this.chargedAmount,
      required this.processorResponse,
      required this.flwRef,
      required this.status,
      required this.message});

  factory CardValidationResponseModel.fromJson(Map<String, dynamic> json) {
    return CardValidationResponseModel(
      amount: json['data']['amount'] ?? '',
      flwRef: json['data']['flw_ref'] ?? '',
      chargedAmount: json['data']['charged_amount'] ?? '',
      processorResponse: json['data']['processor_response'] ?? '',
      status: json['data']['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class CardRequestModel {
  var cardNumber;
  var cvv;
  var expiryMonth;
  var expiryYear;
  var depositAmount;
  var email;
  var fullName;
  var txRef;
  var redirectUrl = 'https://webhook.site/751fcd84-1b57-461f-ad7c-691140d7f0b8';
  var pin;

  CardRequestModel(
      {this.cardNumber,
      this.cvv,
      this.expiryMonth,
      this.expiryYear,
      this.depositAmount,
      this.email,
      this.fullName,
      this.txRef,
      this.pin});

  String authorizationPinJson() {
    return jsonEncode(<String, String>{"mode": "pin", "pin": pin});
  }

  String toJson() {
    return jsonEncode(<String, String>{
      "card_number": cardNumber,
      "cvv": cvv,
      "expiry_month": expiryMonth,
      "expiry_year": expiryYear,
      "currency": "NGN",
      "amount": depositAmount,
      "email": email,
      "fullname": fullName,
      "tx_ref": txRef,
      "redirect_url": redirectUrl,
      "authorization": authorizationPinJson()
    });
  }
}


class CardOtpRequestModel {
  var otp;
  var flwRef;

  CardOtpRequestModel(
      {this.otp,
      this.flwRef});

  String toJson() {
    return jsonEncode(<String, String>{
      "otp": otp,
      "flw_ref": flwRef,
      "type": "card"
    });
  }
}

class CardClientRequestModel {
  var message;

  CardClientRequestModel({
    this.message
  });

  String toJson() {
    return jsonEncode(<String, String>{
        'client': message,
      });
  }
}
