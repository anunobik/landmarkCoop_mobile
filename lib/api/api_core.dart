import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/other_model.dart';

class APICore {
  static const String FLUTTERWAVE_URL = "https://api.flutterwave.com/v3/";
  static const String FLUTTERWAVE_SEC_KEY =
      "FLWSECK-bffd09eb8560f31b3df6f5d6fc67fcd7-X";

  Future<List<BankListResponseModel>> getAllBanks() async {
    String url = '$FLUTTERWAVE_URL/banks/NG';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + FLUTTERWAVE_SEC_KEY,
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'];

      List<BankListResponseModel> banksList = [];
      for (var singleBank in data) {
        BankListResponseModel bankResponseModel = BankListResponseModel(
          id: singleBank['id'] ?? 0,
          code: singleBank['code'] ?? '',
          name: singleBank['name'] ?? '',
        );

        //Adding user to the list.
        banksList.add(bankResponseModel);
      }

      return banksList;
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> bankAccountVerify(BankAccountRequestModel requestModel) async {
    String url = '$FLUTTERWAVE_URL/accounts/resolve';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + FLUTTERWAVE_SEC_KEY,
      },
      body: requestModel.toJson(),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data']['account_name'];
      return data;
    } else {
      return 'Incorrect Details';
    }
  }

}
