import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:landmarkcoop_mobile_app/model/cable_tv_model.dart';

import '../model/airtime_model.dart';

class FlutterWaveService {
  static const String FLUTTERWAVE_URL = "https://api.flutterwave.com/v3/";
  static const String FLUTTERWAVE_SEC_KEY =
      "FLWSECK-a7ae39340408e2215930f3e919a75ed3-18dc7f28248vt-X";

  Future<List<BillsInfoResponseModel>> getBillsList(String billCode) async {
    print('Bill code - $billCode');
    String url = "${FLUTTERWAVE_URL}bill-categories?biller_code=$billCode";

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $FLUTTERWAVE_SEC_KEY',
      },
    );
    print(response.body);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var restList = data["data"] as List;
      // var filteredList;
      // print("BILLER CODE=== " + requestType);

      // filteredList = rest.where((val) =>
      // ((val["country"] == "NG") && (val["biller_code"] == requestType)));
      // print("Filtered list>>>> " + filteredList.toString());

      // var billTypesList = filteredList.map<BillsInfoResponseModel>((json) => BillsInfoResponseModel.fromJson(json)).toList();
      List<BillsInfoResponseModel> billTypesList = [];
      for (var singleBill in restList) {
        BillsInfoResponseModel billsInfoResponseModel = BillsInfoResponseModel(
          id: singleBill['id'] != null ? singleBill['id'] : '',
          billerCode: singleBill['biller_code'] != null
              ? singleBill['biller_code']
              : '',
          name: singleBill['name'] != null ? singleBill['name'] : '',
          defaultCommission: singleBill['default_commission'] != null
              ? singleBill['default_commission']
              : '',
          country: singleBill['country'] != null ? singleBill['country'] : '',
          isAirtime:
              singleBill['is_airtime'] != null ? singleBill['is_airtime'] : '',
          billerName: singleBill['biller_name'] != null
              ? singleBill['biller_name']
              : '',
          itemCode:
              singleBill['item_code'] != null ? singleBill['item_code'] : '',
          shortName:
              singleBill['short_name'] != null ? singleBill['short_name'] : '',
          fee: singleBill['fee'] != null ? singleBill['fee'] : '',
          commissionOnFee: singleBill['commission_on_fee'] != null
              ? singleBill['commission_on_fee']
              : '',
          labelName:
              singleBill['label_name'] != null ? singleBill['label_name'] : '',
          amount: singleBill['amount'] != null ? singleBill['amount'] : '',
        );

        //Adding user to the list.
        billTypesList.add(billsInfoResponseModel);
      }

      return billTypesList;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> buyAirtime(
      AirtimeRequestModel airtimeRequestModel) async {
    String url = "${FLUTTERWAVE_URL}bills";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $FLUTTERWAVE_SEC_KEY',
        },
        body: airtimeRequestModel.toJson());

    if (response.statusCode == 200) {
      return 'Successful';
    } else if (response.statusCode == 400) {
      print(response.body);
      return 'Incomplete Transaction';
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> buyDataBundle(
      DataBundleRequestModel dataBundleRequestModel) async {
    String url = "${FLUTTERWAVE_URL}bills";
    print(dataBundleRequestModel.toJson());

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $FLUTTERWAVE_SEC_KEY',
        },
        body: dataBundleRequestModel.toJson());
    print(response.body);

    if (response.statusCode == 200) {
      return 'Successful';
    } else if (response.statusCode == 400) {
      return 'Incomplete Transaction';
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> buyTvCable(CableRequestModel cableRequestModel) async {
    String url = "${FLUTTERWAVE_URL}bills";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $FLUTTERWAVE_SEC_KEY',
        },
        body: cableRequestModel.toJson());

    if (response.statusCode == 200) {
      return 'Successful';
    } else if (response.statusCode == 400) {
      print(response.body);
      return 'Incomplete Transaction';
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<ValidateBillsInfoResponseModel> validateFlutterwaveBill(
      String itemCode, String billerCode, String customerNo) async {
    String url =
        "${FLUTTERWAVE_URL}bill-items/$itemCode/validate?customer=$customerNo&code=$billerCode";

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $FLUTTERWAVE_SEC_KEY',
      },
    );

    if (response.statusCode == 200) {
      return ValidateBillsInfoResponseModel.fromJson(
        json.decode(response.body),
      );
    } else {
      return ValidateBillsInfoResponseModel(
          response_code: '',
          address: '',
          response_message: 'Can not Validate No',
          name: '',
          biller_code: '',
          customer: '',
          product_code: '',
          email: '',
          fee: 0,
          maximum: 0,
          minimum: 0);
    }
  }
}
