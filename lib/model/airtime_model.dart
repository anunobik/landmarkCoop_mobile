import 'dart:convert';

class AirtimeOnlineRequestModel {
  var phoneNumber;
  var amount;

  AirtimeOnlineRequestModel({
    required this.phoneNumber,
    required this.amount,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'phoneNumber': phoneNumber,
      'amount': amount,
    });
  }
}


class AirtimeResponseModel {
  final String phoneNumber;
  final int amount;
  final String network;
  final String flwRef;
  final String reference;

  AirtimeResponseModel({required this.phoneNumber, required this.amount, required this.network, required this.flwRef, required this.reference});

  factory AirtimeResponseModel.fromJson(Map<String, dynamic> json) {
    return AirtimeResponseModel(
      phoneNumber: json['data']['phone_number'] ?? '',
      amount: json['data']['amount'] ?? '',
      network: json['data']['network'] ?? '',
      flwRef: json['data']['flw_ref'] ?? '',
      reference: json['data']['reference'] ?? '',
    );
  }
}

class AirtimeRequestModel {
  var phoneNumber;
  int amount;
  var reference;

  AirtimeRequestModel({
    required this.phoneNumber,
    required this.amount,
    required this.reference,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "country": "NG",
      "phoneNumber": '+234'+ phoneNumber.trim().substring(1, phoneNumber.length),
      "amount": amount,
      "reference": reference,
    });
  }
}


class DataBundleResponseModel {
  final String phoneNumber;
  final int amount;
  final String network;
  final String flwRef;
  final String reference;

  DataBundleResponseModel({required this.phoneNumber, required this.amount, required this.network, required this.flwRef, required this.reference});

  factory DataBundleResponseModel.fromJson(Map<String, dynamic> json) {
    return DataBundleResponseModel(
      phoneNumber: json['data']['phone_number'] ?? '',
      amount: json['data']['amount'] ?? '',
      network: json['data']['network'] ?? '',
      flwRef: json['data']['flw_ref'] ?? '',
      reference: json['data']['reference'] ?? '',
    );
  }
}

class DataBundleRequestModel {
  var phoneNumber;
  int amount;
  var billerName;
  var reference;

  DataBundleRequestModel({
    required this.phoneNumber,
    required this.amount,
    required this.billerName,
    required this.reference,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "country": "NG",
      "phoneNumber": '+234'+ phoneNumber.trim().substring(1, phoneNumber.length),
      "amount": amount,
      "reference": reference,
    });
  }
}

class InstantAirtimeAndDataRequestModel {
  var phoneNumber;
  var amount;
  var requestType;
  var transactionRef;

  InstantAirtimeAndDataRequestModel({
    this.phoneNumber,
    this.amount,
    this.requestType,
    this.transactionRef,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "phoneNumber": phoneNumber,
      "amount": amount,
      "requestType": requestType,
      "transactionRef": transactionRef,
    });
  }
}

class InstantAirtimeAndDataFeedbackResponseModel {
  final bool result;
  final int id;
  final String phoneNumber;
  final int amount;
  final String transactionRef;
  final String requestType;
  final String timeCreated;

  InstantAirtimeAndDataFeedbackResponseModel({
    required this.result,
    required this.id,
    required this.phoneNumber,
    required this.amount,
    required this.transactionRef,
    required this.requestType,
    required this.timeCreated,
  });

  factory InstantAirtimeAndDataFeedbackResponseModel.fromJson(
      Map<String, dynamic> json) {
    return InstantAirtimeAndDataFeedbackResponseModel(
      result: json['result'],
      id: json['instantAirtimeAndData']['id'] ?? '',
      phoneNumber: json['instantAirtimeAndData']['phoneNumber'] ?? '',
      amount: json['instantAirtimeAndData']['amount'] ?? '',
      transactionRef: json['instantAirtimeAndData']['transactionRef'] ?? '',
      requestType: json['instantAirtimeAndData']['requestType'] ?? '',
      timeCreated: json['instantAirtimeAndData']['timeCreated'] ?? '',
    );
  }
}