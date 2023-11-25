import 'dart:convert';

class BuyAirtimeDataRequestModel {
  var amount;
  var mobile_no;
  var item_code;
  var biller_code;
  var biller_name;

  BuyAirtimeDataRequestModel({
    this.amount,
    this.mobile_no,
    this.item_code,
    this.biller_code,
    this.biller_name,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'amount': amount.trim(),
      'mobile_no': mobile_no.trim(),
      'item_code': item_code,
      'biller_code': biller_code,
      'biller_name': biller_name,
    });
  }
}

class PayTvSubscriptionRequestModel {
  var amount;
  var smartcard_no;
  var item_code;
  var biller_code;
  var biller_name;

  PayTvSubscriptionRequestModel({
    required this.amount,
    required this.smartcard_no,
    required this.item_code,
    required this.biller_code,
    required this.biller_name,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'amount': amount.trim(),
      'smartcard_no': smartcard_no.trim(),
      'item_code': item_code,
      'biller_code': biller_code,
      'biller_name': biller_name,
    });
  }
}

class BillsRequestModel {
  var amount;
  var uniqueNo;
  var item_code;
  var biller_code;
  var biller_name;

  BillsRequestModel({
    required this.amount,
    required this.uniqueNo,
    required this.item_code,
    required this.biller_code,
    required this.biller_name,
  });

}

class BillsResponseModel {
  final String item_code;
  final String biller_code;
  final String biller_name;
  final String short_name;
  final int amount;

  BillsResponseModel(
      {required this.item_code,
        required this.biller_code,
        required this.biller_name,
        required this.short_name,
        required this.amount});

  factory BillsResponseModel.fromJson(Map<String, dynamic> json) {
    return BillsResponseModel(
      item_code: json['item_code'] ?? '',
      biller_code: json['biller_code'] ?? '',
      biller_name: json['biller_name'] ?? '',
      short_name: json['short_name'] ?? '',
      amount: json['amount'] ?? '',
    );
  }

}

class ElectricityRequestModel {
  var amount;
  var meter_no;
  var item_code;
  var biller_code;
  var biller_name;

  ElectricityRequestModel({
    required this.amount,
    required this.meter_no,
    required this.item_code,
    required this.biller_code,
    required this.biller_name,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'amount': amount.trim(),
      'meter_no': meter_no.trim(),
      'item_code': item_code,
      'biller_code': biller_code,
      'biller_name': biller_name,
    });
  }
}

class BillsValidationResponseModel {
  final String response_code;
  final String address;
  final String response_message;
  final String name;
  final String biller_code;
  final String customer;
  final String product_code;
  final String email;
  final int fee;
  final int maximum;
  final int minimum;

  BillsValidationResponseModel(
      {
        required this.response_code,
        required this.address,
        required this.response_message,
        required this.name,
        required this.biller_code,
        required this.customer,
        required this.product_code,
        required this.email,
        required this.fee,
        required this.maximum,
        required this.minimum});

  factory BillsValidationResponseModel.fromJson(Map<String, dynamic> json) {
    return BillsValidationResponseModel(
      response_code: json['response_code'] ?? '',
      address: json['address'] ?? '',
      response_message: json['response_message'] ?? '',
      name: json['name'] ?? '',
      biller_code: json['biller_code'] ?? '',
      customer: json['customer'] ?? '',
      product_code: json['product_code'] ?? '',
      email: json['email'] ?? '',
      fee: json['fee'] ?? 0,
      maximum: json['maximum'] ?? 0,
      minimum: json['minimum'] ?? 0,
    );
  }

}
