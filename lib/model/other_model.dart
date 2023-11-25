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

  ProductResponseModel(
      {required this.id,
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
  var amount;
  var narration;

  AccountTransactionRequestModel({
    this.accountNumber,
    this.amount,
    this.narration
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'accountNumber': accountNumber,
      'amount': amount,
      'narration': narration
    });
  }
}

class BankListResponseModel {
  final int id;
  final String code;
  final String name;

  BankListResponseModel({required this.id,
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

  WithdrawalRequestModel({
    this.accountNumber,
    this.amount,
    this.requestType,
    this.bankName,
    this.bankAccountNo,
    this.bankAccountName
  });

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

class LastTransactionsModel {
  final double mondayDepositAmount;
  final double mondayWithdrawalAmount;
  final double tuesdayDepositAmount;
  final double tuesdayWithdrawalAmount;
  final double wednesdayDepositAmount;
  final double wednesdayWithdrawalAmount;
  final double thursdayDepositAmount;
  final double thursdayWithdrawalAmount;
  final double fridayDepositAmount;
  final double fridayWithdrawalAmount;
  final double saturdayDepositAmount;
  final double saturdayWithdrawalAmount;
  final double sundayDepositAmount;
  final double sundayWithdrawalAmount;

  LastTransactionsModel(
      {required this.mondayDepositAmount, required this.mondayWithdrawalAmount,
        required this.tuesdayDepositAmount, required this.tuesdayWithdrawalAmount,
        required this.wednesdayDepositAmount, required this.wednesdayWithdrawalAmount,
        required this.thursdayDepositAmount, required this.thursdayWithdrawalAmount,
        required this.fridayDepositAmount, required this.fridayWithdrawalAmount,
        required this.saturdayDepositAmount, required this.saturdayWithdrawalAmount,
        required this.sundayDepositAmount, required this.sundayWithdrawalAmount,
        });

  factory LastTransactionsModel.fromJson(Map<String, dynamic> json) {
    return LastTransactionsModel(
      mondayDepositAmount: json['depositAmount'] ?? 0,
      mondayWithdrawalAmount: json['withdrawalAmount'] ?? 0,
      tuesdayDepositAmount: json['depositAmount'] ?? 0,
      tuesdayWithdrawalAmount: json['withdrawalAmount'] ?? 0,
      wednesdayDepositAmount: json['depositAmount'] ?? 0,
      wednesdayWithdrawalAmount: json['withdrawalAmount'] ?? 0,
      thursdayDepositAmount: json['depositAmount'] ?? 0,
      thursdayWithdrawalAmount: json['withdrawalAmount'] ?? 0,
      fridayDepositAmount: json['depositAmount'] ?? 0,
      fridayWithdrawalAmount: json['withdrawalAmount'] ?? 0,
      saturdayDepositAmount: json['depositAmount'] ?? 0,
      saturdayWithdrawalAmount: json['withdrawalAmount'] ?? 0,
      sundayDepositAmount: json['depositAmount'] ?? 0,
      sundayWithdrawalAmount: json['withdrawalAmount'] ?? 0,
    );
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
      'narration': 'MinervaHub-$narration',
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

class AccountToAccountRequestModel {
  var fromAccountNumber;
  var toAccountNumber;
  var amount;
  var narration;

  AccountToAccountRequestModel({
    required this.fromAccountNumber,
    required this.toAccountNumber,
    required this.amount,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'fromAccountNumber': fromAccountNumber,
      'toAccountNumber': toAccountNumber,
      'amount': amount,
      'narration': 'Account Transfer '
    });
  }
}