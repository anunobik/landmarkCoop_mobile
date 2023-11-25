import 'dart:convert';

class LoanRequestModel {
  var accountNumber;
  var amount;

  LoanRequestModel({
    this.accountNumber,
    this.amount,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      "accountNumber": accountNumber,
      "amount": amount.trim(),
    });
  }
}
