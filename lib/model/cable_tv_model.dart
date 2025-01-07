import 'dart:convert';

class CableTvResponseModel {
  int id;
  var name;
  var code;
  var amount;

  CableTvResponseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.amount,
  });

  factory CableTvResponseModel.fromJson(Map<String, dynamic> json) {
    return CableTvResponseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      amount: json['amount'] ?? '',
    );
  }
}

class ValidateTvRequestModel {
  var provider;
  var number;

  ValidateTvRequestModel({
    this.provider,
    this.number,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'provider': provider,
      'number': number,
    });
  }
}

class ValidateTvResponseModel {
  var customer_name;
  var status;
  var due_date;
  var customer_number;
  var customer_type;
  var current_bouquet;
  var current_bouquet_code;
  var renewal_amount;

  ValidateTvResponseModel({
    required this.customer_name,
    required this.status,
    required this.due_date,
    required this.customer_number,
    required this.customer_type,
    required this.current_bouquet,
    required this.current_bouquet_code,
    required this.renewal_amount,
  });

  factory ValidateTvResponseModel.fromJson(Map<String, dynamic> json) {
    return ValidateTvResponseModel(
      customer_name: json['Customer_Name'] ?? '',
      status: json['Status'] ?? '',
      due_date: json['Due_Date'] ?? '',
      customer_number: json['Customer_Number'] ?? '',
      customer_type: json['Customer_Type'] ?? '',
      current_bouquet: json['Current_Bouquet'] ?? '',
      current_bouquet_code: json['Current_Bouquet_Code'] ?? '',
      renewal_amount: json['Renewal_Amount'] ?? '',
    );
  }
}

class CableTvPayRequestModel {
  var provider;
  var number;
  var code;
  var reference;

  CableTvPayRequestModel({
    required this.provider,
    required this.number,
    required this.code,
    required this.reference,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'provider': provider,
      'number': number,
      'code': code,
      'reference': reference,
    });
  }
}

class BudPayResponseModel {
  late bool success;
  var message;

  BudPayResponseModel({
    required this.success,
    required this.message,
  });

  factory BudPayResponseModel.fromJson(Map<String, dynamic> json) {
    return BudPayResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class CableTvTransactionRequestModel {
  var provider;
  var uniqueNo;
  var totalAmountPaid;
  var cableAmount;
  var transactionRef;
  var customerName;

  CableTvTransactionRequestModel({
    this.provider,
    this.uniqueNo,
    this.totalAmountPaid,
    this.cableAmount,
    this.transactionRef,
    this.customerName,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "provider": provider,
      "uniqueNo": uniqueNo,
      "totalAmountPaid": totalAmountPaid,
      "cableAmount": cableAmount,
      "transactionRef": transactionRef,
      "customerName": customerName,
      "narration" : provider + ": $uniqueNo",
    });
  }
}

class CableTvTransactionFeedbackResponseModel {
  final bool result;
  final int id;
  final String provider;
  final String uniqueNo;
  final int totalAmountPaid;
  final int cableAmount;
  final String narration;
  final String transactionRef;
  final String customerName;
  final String timeCreated;

  CableTvTransactionFeedbackResponseModel({
    required this.result,
    required this.id,
    required this.provider,
    required this.uniqueNo,
    required this.totalAmountPaid,
    required this.cableAmount,
    required this.narration,
    required this.transactionRef,
    required this.customerName,
    required this.timeCreated,
  });

  factory CableTvTransactionFeedbackResponseModel.fromJson(
      Map<String, dynamic> json) {
    return CableTvTransactionFeedbackResponseModel(
      result: json['result'],
      id: json['cableTvTransactions']['id'] ?? '',
      provider: json['cableTvTransactions']['provider'] ?? '',
      uniqueNo: json['cableTvTransactions']['uniqueNo'] ?? '',
      totalAmountPaid: json['cableTvTransactions']['totalAmountPaid'] ?? 0,
      cableAmount: json['cableTvTransactions']['cableAmount'] ?? 0,
      narration: json['cableTvTransactions']['narration'] ?? '',
      transactionRef: json['cableTvTransactions']['transactionRef'] ?? '',
      customerName: json['cableTvTransactions']['customerName'] ?? '',
      timeCreated: json['cableTvTransactions']['timeCreated'] ?? '',
    );
  }
}

class BillsInfoResponseModel {
  final int id;
  final String billerCode;
  final String name;
  final double defaultCommission;
  final String country;
  final bool isAirtime;
  final String billerName;
  final String itemCode;
  final String shortName;
  final int fee;
  final bool commissionOnFee;
  final String labelName;
  final int amount;

  BillsInfoResponseModel({
    required this.id,
    required this.billerCode,
    required this.name,
    required this.defaultCommission,
    required this.country,
    required this.isAirtime,
    required this.billerName,
    required this.itemCode,
    required this.shortName,
    required this.fee,
    required this.commissionOnFee,
    required this.labelName,
    required this.amount,
  });

  factory BillsInfoResponseModel.fromJson(Map<String, dynamic> json) {
    return BillsInfoResponseModel(
      id: json['data']['id'] != null ? json['data']['id'] : '',
      billerCode: json['data']['biller_code'] != null
          ? json['data']['biller_code']
          : '',
      name: json['data']['name'] != null ? json['data']['name'] : '',
      defaultCommission: json['data']['default_commission'] != null
          ? json['data']['default_commission']
          : '',
      country: json['data']['country'] != null ? json['data']['country'] : '',
      isAirtime:
          json['data']['is_airtime'] != null ? json['data']['is_airtime'] : '',
      billerName: json['data']['biller_name'] != null
          ? json['data']['biller_name']
          : '',
      itemCode:
          json['data']['item_code'] != null ? json['data']['item_code'] : '',
      shortName:
          json['data']['short_name'] != null ? json['data']['short_name'] : '',
      fee: json['data']['fee'] != null ? json['data']['fee'] : '',
      commissionOnFee: json['data']['commission_on_fee'] != null
          ? json['data']['commission_on_fee']
          : '',
      labelName:
          json['data']['label_name'] != null ? json['data']['label_name'] : '',
      amount: json['data']['amount'] != null ? json['data']['amount'] : '',
    );
  }
}

class ValidateBillsInfoResponseModel {
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

  ValidateBillsInfoResponseModel({
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
    required this.minimum,
  });

  factory ValidateBillsInfoResponseModel.fromJson(Map<String, dynamic> json) {
    return ValidateBillsInfoResponseModel(
      response_code: json['data']['response_code'] ?? '',
      address: json['data']['address'] ?? '',
      response_message: json['data']['response_message'] ?? '',
      name: json['data']['name'] ?? '',
      biller_code: json['data']['biller_code'] ?? '',
      customer: json['data']['customer'] ?? '',
      product_code: json['data']['product_code'] ?? '',
      email: json['data']['email'] ?? '',
      fee: json['data']['fee'] ?? 0,
      maximum: json['data']['maximum'] ?? 0,
      minimum: json['data']['minimum'] ?? 0,
    );
  }
}

class CableRequestModel {
  var smartcardNumber;
  int amount;
  var billerName;
  var reference;

  CableRequestModel({
    required this.smartcardNumber,
    required this.amount,
    required this.billerName,
    required this.reference,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      "country": "NG",
      "customer": smartcardNumber,
      "amount": amount,
      "recurrence": "ONCE",
      "type": billerName,
      "reference": reference,
    });
  }
}

class CableTvTypeInfoResponseModel {
  final int id;
  final String name;
  final String logo;
  final String description;
  final String short_name;
  final String biller_code;
  final String country_code;

  CableTvTypeInfoResponseModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.description,
    required this.short_name,
    required this.biller_code,
    required this.country_code,
  });

  factory CableTvTypeInfoResponseModel.fromJson(Map<String, dynamic> json) {
    return CableTvTypeInfoResponseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      description: json['description'] ?? '',
      short_name: json['short_name'] ?? '',
      biller_code: json['biller_code'] ?? '',
      country_code: json['country_code'] ?? '',
    );
  }
}

class BillsPaymentResponse {
  final String status;
  final String message;
  final BillsPaymentData data;

  BillsPaymentResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BillsPaymentResponse.fromJson(Map<String, dynamic> json) {
    return BillsPaymentResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: BillsPaymentData.fromJson(json['data']),
    );
  }
}

class BillsPaymentData {
  final String phoneNumber;
  final double amount;
  final String network;
  final String code;
  final String txRef;
  final String reference;
  final String? batchReference;
  final String? rechargeToken;
  final double fee;

  BillsPaymentData({
    required this.phoneNumber,
    required this.amount,
    required this.network,
    required this.code,
    required this.txRef,
    required this.reference,
    this.batchReference,
    this.rechargeToken,
    required this.fee,
  });

  factory BillsPaymentData.fromJson(Map<String, dynamic> json) {
    return BillsPaymentData(
      phoneNumber: json['phone_number'] ?? '',
      amount: json['amount'] != null ? json['amount'].toDouble() : 0.0,
      network: json['network'] ?? '',
      code: json['code'] ?? '',
      txRef: json['tx_ref'] ?? '',
      reference: json['reference'] ?? '',
      batchReference: json['batch_reference'],
      rechargeToken: json['recharge_token'],
      fee: json['fee'] != null ? json['fee'].toDouble() : 0.0,
    );
  }
}

