import 'dart:convert';

import 'customer_model.dart';

class LoginResponseModel {
  final List<CustomerWalletsBalanceModel> customerWalletsList;
  final String token;

  LoginResponseModel({required this.customerWalletsList, required this.token});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    var data = json['customerAccountsList'];
    List<CustomerWalletsBalanceModel> customerWallets = [];
    for (var singleStatement in data) {
      CustomerWalletsBalanceModel customerWallet = CustomerWalletsBalanceModel(
        id: singleStatement['id'] ?? 0,
        accountNumber: singleStatement['accountNumber'] ?? '',
        nubanAccountNumber: singleStatement['nubanAccountNumber'] ?? '',
        balance: singleStatement['balance'] ?? 0,
        productName: singleStatement['products']['displayName'] ?? '',
        fullName: singleStatement['customer']['firstName'] + ' ' + singleStatement['customer']['lastName'] ?? '',
        email: singleStatement['customer']['email'] ?? '',
        phoneNo: singleStatement['customer']['phoneNumber'] ?? '',
        interBankName: singleStatement['interBankName'] ?? '',
        limitsEnabled: singleStatement['limitsEnabled'] ?? false,
        limitAmount: singleStatement['limitAmount'] ?? 50000,
        limitBalance: singleStatement['limitBalance'] ?? 0,
      );
      //Adding user to the list.
      customerWallets.add(customerWallet);
    }

    return LoginResponseModel(
      customerWalletsList: customerWallets,
      token: json['token'] ?? '',
    );
  }
}

class LoginRequestModel {
  var email;
  var password;

  LoginRequestModel({
    this.email,
    this.password,
  });

  String toJson() {
    return jsonEncode(<String, String>{
        'email': email.trim(),
        'password': password.trim()
      });
  }
}
