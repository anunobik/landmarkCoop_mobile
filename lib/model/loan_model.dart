import 'dart:convert';

class LoanRequestModel {
  var tenor;
  var amountRequested;
  var rate;

  LoanRequestModel({
    this.tenor,
    this.amountRequested,
    this.rate,
  });

  String toJson() {
    return jsonEncode(<String, String>{
      "tenor": tenor,
      "rate": rate,
      "amountRequested": amountRequested.trim(),
    });
  }
}
