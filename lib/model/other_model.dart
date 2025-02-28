import 'dart:convert';

class ProductResponseModel {
  final int id;
  final String productName;
  final String displayName;
  final String description;
  final double interestRate;
  final int tenorDays;
  final double prematureCharge;
  final double normalCharge;
  final double defaultCharge;
  final double serviceCharge;
  final double referralPercentageCharge;

  ProductResponseModel({
    required this.id,
    required this.productName,
    required this.displayName,
    required this.description,
    required this.interestRate,
    required this.tenorDays,
    required this.prematureCharge,
    required this.normalCharge,
    required this.defaultCharge,
    required this.serviceCharge,
    required this.referralPercentageCharge,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      id: json['id'] ?? 0,
      productName: json['productName'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'] ?? '',
      interestRate: json['interestRate'] ?? 0.0,
      tenorDays: json['tenorDays'] ?? 0,
      prematureCharge: json['prematureCharge'] ?? 0.0,
      normalCharge: json['normalCharge'] ?? 0.0,
      defaultCharge: json['defaultCharge'] ?? 0.0,
      serviceCharge: json['serviceCharge'] ?? 0.0,
      referralPercentageCharge: json['referralPercentageCharge'] ?? 0.0,
    );
  }
}

class AccountTransactionRequestModel {
  var accountNumber;
  double amount;
  var narration;

  AccountTransactionRequestModel(
      {this.accountNumber, required this.amount, this.narration});

  String toJson() {
    return jsonEncode(<String, dynamic>{
      'accountNumber': accountNumber,
      'amount': amount,
      'narration': narration
    });
  }
}

class GatewayResponseModel {
  final int id;
  final String gatewayName;
  final String publicKey;
  final String privateKey;
  final String secretKey;
  final int isActive;

  GatewayResponseModel({
    required this.id,
    required this.gatewayName,
    required this.publicKey,
    required this.privateKey,
    required this.secretKey,
    required this.isActive,
  });

  factory GatewayResponseModel.fromJson(Map<String, dynamic> json) {
    return GatewayResponseModel(
      id: json['id'] ?? 0,
      gatewayName: json['gatewayName'] ?? '',
      publicKey: json['publicKey'] ?? '',
      privateKey: json['privateKey'] ?? '',
      secretKey: json['secretKey'] ?? '',
      isActive: json['isActive'] ?? 0,
    );
  }
}

class BranchResponseModel {
  final int id;
  final String branchName;
  final String displayName;
  final String address;

  BranchResponseModel({
    required this.id,
    required this.branchName,
    required this.displayName,
    required this.address,
  });

  factory BranchResponseModel.fromJson(Map<String, dynamic> json) {
    return BranchResponseModel(
      id: json['id'] ?? 0,
      branchName: json['branchName'] ?? '',
      displayName: json['displayName'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class BankListResponseModel {
  final int id;
  final String code;
  final String name;

  BankListResponseModel({
    required this.id,
    required this.code,
    required this.name,
  });

  factory BankListResponseModel.fromJson(Map<String, dynamic> json) {
    return BankListResponseModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class WithdrawalRequestModel {
  var accountNumber;
  var amount;
  var requestType;
  var bankName;
  var bankAccountNo;
  var bankAccountName;

  WithdrawalRequestModel(
      {this.accountNumber,
      this.amount,
      this.requestType,
      this.bankName,
      this.bankAccountNo,
      this.bankAccountName});

  String toJson() {
    return jsonEncode(<String, String>{
      'accountNumber': accountNumber,
      'amount': amount,
      'requestType': requestType,
      'bankName': bankName ?? 'Cash',
      'bankAccountNo': bankAccountNo ?? 'Cash',
      'bankAccountName': bankAccountName ?? 'Cash'
    });
  }
}

class BankAccountRequestModel {
  var account_number;
  var account_bank;

  BankAccountRequestModel({
    this.account_number,
    this.account_bank
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'account_number': account_number,
      'account_bank': account_bank
    });
  }
}

class OnlineRateResponseModel {
  final int id;
  final double oneMonth;
  final double twoMonth;
  final double threeMonth;
  final double fourMonth;
  final double fiveMonth;
  final double sixMonth;
  final double sevenMonth;
  final double eightMonth;
  final double nineMonth;
  final double tenMonth;
  final double elevenMonth;
  final double twelveMonth;

  OnlineRateResponseModel({
    required this.id,
    required this.oneMonth,
    required this.twoMonth,
    required this.threeMonth,
    required this.fourMonth,
    required this.fiveMonth,
    required this.sixMonth,
    required this.sevenMonth,
    required this.eightMonth,
    required this.nineMonth,
    required this.tenMonth,
    required this.elevenMonth,
    required this.twelveMonth,
  });

  factory OnlineRateResponseModel.fromJson(Map<String, dynamic> json) {
    return OnlineRateResponseModel(
      id: json['id'] ?? 0,
      oneMonth: json['oneMonth'] ?? 0,
      twoMonth: json['twoMonth'] ?? 0,
      threeMonth: json['threeMonth'] ?? 0,
      fourMonth: json['fourMonth'] ?? 0,
      fiveMonth: json['fiveMonth'] ?? 0,
      sixMonth: json['sixMonth'] ?? 0,
      sevenMonth: json['sevenMonth'] ?? 0,
      eightMonth: json['eightMonth'] ?? 0,
      nineMonth: json['nineMonth'] ?? 0,
      tenMonth: json['tenMonth'] ?? 0,
      elevenMonth: json['elevenMonth'] ?? 0,
      twelveMonth: json['twelveMonth'] ?? 0,
    );
  }
}

class AccountToAccountRequestModel {
  var fromAccountNumber;
  var toAccountNumber;
  double amount;
  var narration;

  AccountToAccountRequestModel({
    required this.fromAccountNumber,
    required this.toAccountNumber,
    required this.amount,
  });

  String toJson() {
    return jsonEncode(<String, dynamic>{
      'fromAccountNumber': fromAccountNumber,
      'toAccountNumber': toAccountNumber,
      'amount': amount,
      'narration': 'Account Transfer '
    });
  }
}

class PushDeviceTokenRequestModel {
  var deviceToken;

  PushDeviceTokenRequestModel({
    required this.deviceToken,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'deviceToken': deviceToken,
    });
  }
}

class ExternalBankTransferModel {
  var account_bank;
  var account_number;
  var amount;
  var narration;
  var reference;

  ExternalBankTransferModel({
    required this.account_bank,
    required this.account_number,
    required this.amount,
    required this.narration,
    required this.reference,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'account_bank': account_bank,
      'account_number': account_number,
      'amount': amount,
      'narration': narration,
      'reference': reference,
    });
  }
}

class ExternalBankTransferDetailsRequestModel {
  var destinationAccountName;
  var destinationAccountNumber;
  var destinationBankName;
  var pinCode; //
  var token;
  var sourceAccountNumber;
  var accountBank;
  var accountNumber;
  var amount;
  var narration;
  var reference;

  ExternalBankTransferDetailsRequestModel({
    this.destinationAccountName,
    this.destinationAccountNumber,
    this.destinationBankName,
    this.pinCode,
    this.token,
    this.sourceAccountNumber,
    this.accountBank,
    this.accountNumber,
    this.amount,
    this.narration,
    this.reference,
  });

  String toJson() {
   return jsonEncode(<String, String>{
      'destinationAccountName': destinationAccountName,
      'destinationAccountNumber': destinationAccountNumber,
      'destinationBankName': destinationBankName,
      'pinCode': pinCode,
      'token': token,
      'sourceAccountNumber': sourceAccountNumber,
      'account_bank': accountBank,
      'account_number': accountNumber,
      'amount': amount,
      'narration': 'Landmark-$narration',
      'reference': reference,
    });
  }
}


class UserPinCodeRequestModel {
  var pinCode;
  var confirmPinCode;

  UserPinCodeRequestModel({
    required this.pinCode,
    required this.confirmPinCode,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'pinCode': pinCode,
      'confirmPinCode': confirmPinCode,
    });
  }
}

class UserPinCodeModifyRequestModel {
  var oldPinCode;
  var newPinCode;
  var confirmNewPinCode;

  UserPinCodeModifyRequestModel({
    required this.oldPinCode,
    required this.newPinCode,
    required this.confirmNewPinCode,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'oldPinCode': oldPinCode,
      'newPinCode': newPinCode,
      'confirmNewPinCode': confirmNewPinCode,
    });
  }
}

class ExternalBankTransferHistoryResponseModel {
  final int id;
  final String destinationAccountName;
  final String destinationAccountNumber;
  final String destinationBankName;
  final String reference;
  final String status;
  final int amount;
  final String completeMessage;
  final String timeCreated;

  ExternalBankTransferHistoryResponseModel({
    required this.id,
    required this.destinationAccountName,
    required this.destinationAccountNumber,
    required this.destinationBankName,
    required this.reference,
    required this.status,
    required this.amount,
    required this.completeMessage,
    required this.timeCreated,
  });

  factory ExternalBankTransferHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return ExternalBankTransferHistoryResponseModel(
      id: json['id'] ?? 0,
      destinationAccountName: json['destinationAccountName'] ?? '',
      destinationAccountNumber: json['destinationAccountNumber'] ?? '',
      destinationBankName: json['destinationBankName'] ?? '',
      reference: json['reference'] ?? '',
      status: json['status'] ?? '',
      amount: json['amount'] ?? 0,
      completeMessage: json['completeMessage'] ?? '',
      timeCreated: json['timeCreated'] ?? ''
    );
  }
}

class CustomerBeneficiaryRequestModel {
  var beneficiaryAccountName;
  var beneficiaryAccountNumber;
  var beneficiaryBankName;
  var beneficiaryBankCode;

  CustomerBeneficiaryRequestModel({
    required this.beneficiaryAccountName,
    required this.beneficiaryAccountNumber,
    required this.beneficiaryBankName,
    required this.beneficiaryBankCode,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'beneficiaryAccountName': beneficiaryAccountName,
      'beneficiaryAccountNumber': beneficiaryAccountNumber,
      'beneficiaryBankName': beneficiaryBankName,
      'beneficiaryBankCode': beneficiaryBankCode,
    });
  }
}

class CustomerBeneficiaryResponseModel {
  final int id;
  final String beneficiaryAccountName;
  final String beneficiaryAccountNumber;
  final String beneficiaryBankName;
  final String beneficiaryBankCode;

  CustomerBeneficiaryResponseModel({
    required this.id,
    required this.beneficiaryAccountName,
    required this.beneficiaryAccountNumber,
    required this.beneficiaryBankName,
    required this.beneficiaryBankCode,
  });

  factory CustomerBeneficiaryResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerBeneficiaryResponseModel(
        id: json['id'] ?? 0,
        beneficiaryAccountName: json['beneficiaryAccountName'] ?? '',
        beneficiaryAccountNumber: json['beneficiaryAccountNumber'] ?? '',
        beneficiaryBankName: json['beneficiaryBankName'] ?? '',
        beneficiaryBankCode: json['beneficiaryBankCode'] ?? '',
    );
  }
}