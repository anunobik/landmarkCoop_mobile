import 'dart:convert';

class CheckMeterResponseModel {
  final String discoCode;
  final String vendType;
  final String meterNo;
  final String name;
  final String address;
  final int maxVendAmount;

  CheckMeterResponseModel(
      {required this.discoCode,
      required this.vendType,
      required this.meterNo,
      required this.name,
      required this.address,
      required this.maxVendAmount});

  factory CheckMeterResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckMeterResponseModel(
      discoCode: json['discoCode'] ?? '',
      vendType: json['vendType'] ?? '',
      meterNo: json['meterNo'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      maxVendAmount: json['maxVendAmount'] ?? '',
    );
  }
}

class VendRequestModel {
  var orderId;
  var meter;
  var disco;
  var phone;
  var vendType;
  var amount;
  var email;
  var name;

  VendRequestModel(
      {this.orderId,
      this.meter,
      this.disco,
      this.phone,
      this.vendType,
      this.amount,
      this.email,
      this.name});

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "orderId": orderId,
      "meter": meter,
      "disco": disco,
      "phone": phone,
      "paymentType": 'ONLINE',
      "vendType": vendType,
      "amount": amount,
      "email": email,
      "name": name,
    });
  }
}

class VendResponseModel {
  var amountGenerated;
  var debtAmount;
  var receiptNo;
  final String vendTime;
  final String token;
  var totalAmountPaid;
  var units;
  var vendAmount;
  var vendRef;
  final String responseMessage;
  int responseCode;

  VendResponseModel(
      {required this.amountGenerated,
      required this.debtAmount,
      required this.receiptNo,
      required this.vendTime,
      required this.token,
      required this.totalAmountPaid,
      required this.units,
      required this.vendAmount,
      required this.vendRef,
      required this.responseMessage,
      required this.responseCode});

  factory VendResponseModel.fromJson(Map<String, dynamic> json) {
    return VendResponseModel(
      amountGenerated: json['data']['amountGenerated'] ?? '',
      debtAmount: json['data']['debtAmount'] ?? '',
      receiptNo: json['data']['receiptNo'] ?? '',
      vendTime: json['data']['vendTime'] ?? '',
      token: json['data']['token'] ?? '',
      totalAmountPaid: json['data']['totalAmountPaid'] ?? '',
      units: json['data']['units'] ?? '',
      vendAmount: json['data']['vendAmount'] ?? '',
      responseMessage: json['data']['responseMessage'] ?? '',
      vendRef: json['data']['vendRef'] ?? '',
      responseCode: json['data']['responseCode'] ?? 0,
    );
  }
}
