import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:landmarkcoop_mobile_app/model/cable_tv_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';

import '../model/airtime_model.dart';

class FlutterWaveService {
  static const String DOMAIN_URL = "https://core.landmarkcooperative.org";

  Future<List<BillsInfoResponseModel>> getBillsList(String billCode, String token) async {
    print('Bill code - $billCode');
    String url = "$DOMAIN_URL/getBillsList/$billCode/$token";

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',        
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
          id: singleBill['id'] ?? '',
          billerCode: singleBill['biller_code'] ?? '',
          name: singleBill['name'] ?? '',
          defaultCommission: singleBill['default_commission'] ?? '',
          country: singleBill['country'] ?? '',
          isAirtime:
              singleBill['is_airtime'] ?? '',
          billerName: singleBill['biller_name'] ?? '',
          itemCode:
              singleBill['item_code'] ?? '',
          shortName:
              singleBill['short_name'] ?? '',
          fee: singleBill['fee'] ?? '',
          commissionOnFee: singleBill['commission_on_fee'] ?? '',
          labelName:
              singleBill['label_name'] ?? '',
          amount: singleBill['amount'] ?? '',
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
      AirtimeRequestModel airtimeRequestModel, String token) async {
    String url = "$DOMAIN_URL/buyAirtime/$token";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: airtimeRequestModel.toJson());

    if (response.statusCode == 200) {
      return 'Successful';
    } else if (response.statusCode == 400) {
      return 'Incomplete Transaction';
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> buyDataBundle(
      DataBundleRequestModel dataBundleRequestModel, String billerCode, String itemCode, String token) async {
    String url = "$DOMAIN_URL/buyDataBundle/$billerCode/$itemCode/$token";
    print(dataBundleRequestModel.toJson());

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
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

  Future<String> buyTvCable(CableRequestModel cableRequestModel, String token) async {
    String url = "$DOMAIN_URL/buyTvCable/$token";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
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
      String itemCode, String billerCode, String customerNo, String token) async {
    String url =
        "$DOMAIN_URL/validateFlutterwaveBill/$itemCode/$customerNo/$billerCode/$token";

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
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

  Future<List<BankListResponseModel>> getAllBanks(String token) async {
    String url = '$DOMAIN_URL/getAllBanks/$token';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
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

  Future<String> bankAccountVerify(BankAccountRequestModel requestModel, String token) async {
    String url = '$DOMAIN_URL/bankAccountVerify/$token';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
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
