import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/electricity_model.dart';

class BuyPowerService {
  static const String BUYPOWER_URL = "https://api.buypower.ng/v2";
  static const String AUTHORIZATION_TOKEN =
      "30343c40f5ec389b7218ba94c33ddb38b59a604e392d4495ca0775155bdf4ff9";
  // static const String BUYPOWER_URL = "https://idev.buypower.ng/v2";
  // static const String AUTHORIZATION_TOKEN =
  //     "7883e2ec127225f478279f0cb848e3551eaaa99d484ec39cf0b77a9ccf1d9d0d";

  Future<CheckMeterResponseModel> checkMeterInfo(String meterNo) async {
    String url = "$BUYPOWER_URL/check/meter?meter=$meterNo";

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $AUTHORIZATION_TOKEN',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      return CheckMeterResponseModel.fromJson(
        json.decode(response.body),
      );
    } else if (response.statusCode == 400) {
      return CheckMeterResponseModel(
          discoCode: '',
          vendType: '',
          meterNo: '',
          name: 'Record Not Found',
          address: '',
          maxVendAmount: 0);
    } else{
      return CheckMeterResponseModel(
          discoCode: '',
          vendType: '',
          meterNo: '',
          name: json.decode(response.body)['message'],
          address: '',
          maxVendAmount: 0);
    }
  }

  Future<VendResponseModel> payElectricBill(
      VendRequestModel vendRequestModel) async {
    String url = "$BUYPOWER_URL/vend";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $AUTHORIZATION_TOKEN',
        },
        body: vendRequestModel.toJson());
    print(response.body);
    print(response.statusCode);
    if (response.statusCode < 400) {
      VendResponseModel vendResponseModel = VendResponseModel.fromJson(
        json.decode(response.body),
      );
      return vendResponseModel;
    } else {
      return VendResponseModel(
        amountGenerated: 0,
        debtAmount: 0,
        receiptNo: '',
        responseMessage: json.decode(response.body)['message'],
        token: '',
        totalAmountPaid: '0',
        units: 0,
        vendAmount: 0,
        vendTime: '',
        vendRef: '',
        responseCode: 0,
      );
    }
  }
}
