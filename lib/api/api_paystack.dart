import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/paystack_model.dart';

class PaystackApi {
  static const String DOMAIN_URL = "https://api.paystack.co";

  Future<TransactionInitResponseModel> initializeTransaction(
      TransactionInitRequestModel requestModel, String SECRET_KEY) async {
    String url = "$DOMAIN_URL/transaction/initialize";

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $SECRET_KEY',
      },
      body: requestModel.toJson(),
    );
print(response.body);
    if (response.statusCode >= 200 && response.statusCode <= 300) {
      return TransactionInitResponseModel.fromJson(
        json.decode(response.body),
      );
    } else{
      return TransactionInitResponseModel.fromJson(
        json.decode(response.body),
      );
    }
  }

}