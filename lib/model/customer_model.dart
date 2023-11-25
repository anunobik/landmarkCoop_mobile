import 'dart:convert';

class CustomerRequestModel {
  var firstName;
  var middleName;
  var lastName;
  var phoneNumber;
  var email;

  CustomerRequestModel({
    this.firstName,
    this.middleName,
    this.lastName,
    this.phoneNumber,
    this.email,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      'firstName': firstName.trim(),
      'middleName': middleName.trim(),
      'lastName': lastName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'email': email.trim(),
      'dateOfBirth': '1111-11-11',
      'gender': 'female',
      'maritalStatus': 'single',
      'country': 'Nigeria',
      'countryState': 'Plateau',
      'homeAddress': 'Jos',
    });
  }
}

class CustomerWalletsBalanceModel {
  final int id;
  final String accountNumber;
  final String nubanAccountNumber;
  final double balance;
  final String productName;
  final String fullName;
  final String email;
  final String phoneNo;
  final String interBankName;

  CustomerWalletsBalanceModel(
      {required this.id,
        required this.accountNumber,
        required this.nubanAccountNumber,
        required this.balance,
        required this.productName,
        required this.fullName,
        required this.email,
        required this.phoneNo,
        required this.interBankName,
      });

  factory CustomerWalletsBalanceModel.fromJson(Map<String, dynamic> json) {
    return CustomerWalletsBalanceModel(
        id: json['id'] ?? 0,
        accountNumber: json['accountNumber'] ?? '',
        nubanAccountNumber: json['nubanAccountNumber'] ?? '',
        balance: json['balance'] ?? 0,
        productName: json['products']['displayName'] ?? '',
        fullName:
        json['customer']['firstName'] + ' ' + json['customer']['lastName'] ??
            '',
        email: json['customer']['email'] ?? '',
        phoneNo: json['customer']['phoneNumber'] ?? '',
        interBankName: json['interBankName']
    );
  }
}


class CustomerInvestmentWalletModel {
  final int id;
  final double amount;
  final String accountNumber;
  final int instruction;
  final double interest;
  final String fullName;
  final double maturityAmount;
  final String maturityTime;
  final double rate;
  final int tenor;
  final String timeCreated;
  final double wht;
  final String displayName;

  CustomerInvestmentWalletModel(
      {required this.id, required this.amount, required this.accountNumber, required this.instruction,
        required this.interest, required this.fullName, required this.maturityAmount, required this.maturityTime,
        required this.rate, required this.tenor, required this.timeCreated, required this.wht, required this.displayName});

  factory CustomerInvestmentWalletModel.fromJson(Map<String, dynamic> json) {
    return CustomerInvestmentWalletModel(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? 0,
      accountNumber: json['customerAccounts']['accountNumber'] ?? '',
      instruction: json['instruction'] ?? 0,
      interest: json['interest'] ?? 0,
      fullName: json['customerAccounts']['customer']['firstName'] + ' ' + json['customerAccounts']['customer']['lastName'] ?? '',
      maturityAmount: json['maturityAmount'] ?? 0,
      maturityTime: json['maturityTime'] ?? '',
      rate: json['rate'] ?? 0,
      tenor: json['tenor'] ?? 0,
      timeCreated: json['timeCreated'] ?? '',
      wht: json['wht'] ?? 0,
      displayName: json['customerAccounts']['products']['displayName'] ?? '',
    );
  }
}

class CustomerFeedbackResponseModel {
  final bool status;
  final String message;

  CustomerFeedbackResponseModel({
    required this.status,
    required this.message,
  });
}

class CustomerAccountDisplayModel {
  final String accountNumber;
  final String displayName;
  final String phoneNumber;

  CustomerAccountDisplayModel(
      {required this.accountNumber,
        required this.displayName,
        required this.phoneNumber});

  factory CustomerAccountDisplayModel.fromJson(Map<String, dynamic> json) {
    return CustomerAccountDisplayModel(
      accountNumber: json['accountNumber'] ?? '',
      displayName: json['displayName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}