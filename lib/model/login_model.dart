import 'dart:convert';

import 'package:desalmcs_mobile_app/model/customer_model.dart';
import 'package:desalmcs_mobile_app/model/other_model.dart';

class LoginResponseModel {
  final List<CustomerWalletsBalanceModel> customerWalletsList;
  final List<LastTransactionsModel> lastTransactionsList;
  final String token;

  LoginResponseModel(
      {required this.customerWalletsList,
      required this.lastTransactionsList,
      required this.token});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    var data = json['customerAccountsList'];
    var transData = json['lastSevenTransactionsList'];

    List<CustomerWalletsBalanceModel> customerWallets = [];
    for (var singleStatement in data) {
      CustomerWalletsBalanceModel customerWallet = CustomerWalletsBalanceModel(
        id: singleStatement['id'] ?? 0,
        accountNumber: singleStatement['accountNumber'] ?? '',
        balance: singleStatement['balance'] ?? 0,
        productName: singleStatement['products']['displayName'] ?? '',
        fullName: singleStatement['customer']['firstName'] +
                ' ' +
                singleStatement['customer']['lastName'] ??
            '',
        email: singleStatement['customer']['email'] ?? '',
        phoneNo: singleStatement['customer']['phoneNumber'] ?? '',
        nubanAccountNumber: singleStatement['nubanAccountNumber'] ?? '',
        interBankName: singleStatement['interBankName'],
      );
      //Adding user to the list.
      customerWallets.add(customerWallet);
    }

    List<LastTransactionsModel> lastTransactions = [];
    for (var singleTrans in transData) {
      double mondayDepositAmount = 0;
      double mondayWithdrawalAmount = 0;
      double tuesdayDepositAmount = 0;
      double tuesdayWithdrawalAmount = 0;
      double wednesdayDepositAmount = 0;
      double wednesdayWithdrawalAmount = 0;
      double thursdayDepositAmount = 0;
      double thursdayWithdrawalAmount = 0;
      double fridayDepositAmount = 0;
      double fridayWithdrawalAmount = 0;
      double saturdayDepositAmount = 0;
      double saturdayWithdrawalAmount = 0;
      double sundayDepositAmount = 0;
      double sundayWithdrawalAmount = 0;
      if (singleTrans['monday'] != null) {
        mondayDepositAmount =
            (singleTrans['monday']['depositAmount'] / 100000) ?? 0;
        mondayWithdrawalAmount =
            (singleTrans['monday']['withdrawalAmount'] / 100000) ?? 0;
      }

      if (singleTrans['tuesday'] != null) {
        tuesdayDepositAmount =
            (singleTrans['tuesday']['depositAmount'] / 100000) ?? 0;
        tuesdayWithdrawalAmount =
            (singleTrans['tuesday']['withdrawalAmount'] / 100000) ?? 0;
      }

      if (singleTrans['wednesday'] != null) {
        wednesdayDepositAmount =
            (singleTrans['wednesday']['depositAmount'] / 100000) ?? 0;
        wednesdayWithdrawalAmount =
            (singleTrans['wednesday']['withdrawalAmount'] / 100000) ?? 0;
      }

      if (singleTrans['thursday'] != null) {
        thursdayDepositAmount =
            (singleTrans['thursday']['depositAmount'] / 100000) ?? 0;
        thursdayWithdrawalAmount =
            (singleTrans['thursday']['withdrawalAmount'] / 100000) ?? 0;
      }

      if (singleTrans['friday'] != null) {
        fridayDepositAmount =
            (singleTrans['friday']['depositAmount'] / 100000) ?? 0;
        fridayWithdrawalAmount =
            (singleTrans['friday']['withdrawalAmount'] / 100000) ?? 0;
      }

      if (singleTrans['saturday'] != null) {
        saturdayDepositAmount =
            (singleTrans['saturday']['depositAmount'] / 100000) ?? 0;
        saturdayWithdrawalAmount =
            (singleTrans['saturday']['withdrawalAmount'] / 100000) ?? 0;
      }

      if (singleTrans['sunday'] != null) {
        sundayDepositAmount =
            (singleTrans['sunday']['depositAmount'] / 100000) ?? 0;
        sundayWithdrawalAmount =
            (singleTrans['sunday']['withdrawalAmount'] / 100000) ?? 0;
      }

      LastTransactionsModel lastTransactionsModel = LastTransactionsModel(
        mondayDepositAmount: mondayDepositAmount,
        mondayWithdrawalAmount: mondayWithdrawalAmount,
        tuesdayDepositAmount: tuesdayDepositAmount,
        tuesdayWithdrawalAmount: tuesdayWithdrawalAmount,
        wednesdayDepositAmount: wednesdayDepositAmount,
        wednesdayWithdrawalAmount: wednesdayWithdrawalAmount,
        thursdayDepositAmount: thursdayDepositAmount,
        thursdayWithdrawalAmount: thursdayWithdrawalAmount,
        fridayDepositAmount: fridayDepositAmount,
        fridayWithdrawalAmount: fridayWithdrawalAmount,
        saturdayDepositAmount: saturdayDepositAmount,
        saturdayWithdrawalAmount: saturdayWithdrawalAmount,
        sundayDepositAmount: sundayDepositAmount,
        sundayWithdrawalAmount: sundayWithdrawalAmount,
      );
      //Adding user to the list.
      lastTransactions.add(lastTransactionsModel);
    }

    return LoginResponseModel(
      customerWalletsList: customerWallets,
      lastTransactionsList: lastTransactions,
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
    return jsonEncode(
        <String, String>{'email': email.trim(), 'password': password.trim()});
  }
}
