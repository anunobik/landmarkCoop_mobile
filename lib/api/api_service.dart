import 'dart:convert';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:landmarkcoop_mobile_app/model/complaint_model.dart';
import 'package:landmarkcoop_mobile_app/model/customer_model.dart';
import 'package:landmarkcoop_mobile_app/model/login_model.dart';
import 'package:landmarkcoop_mobile_app/model/other_model.dart';
import 'package:landmarkcoop_mobile_app/model/statement_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/airtime_model.dart';
import '../model/password_model.dart';


class APIService {
  static const String DOMAIN_URL = "https://core.landmarkcooperative.org";
  // static const String DOMAIN_URL = "https://desalmc.herokuapp.com";

  Future<List<ProductResponseModel>> getProducts() async {
    String url = "$DOMAIN_URL/allProducts";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<ProductResponseModel> productList = [];
      for (var singleProduct in data) {
        ProductResponseModel productResponseModel = ProductResponseModel(
          id: singleProduct['id'] ?? 0,
          productName: singleProduct['productName'] ?? '',
          displayName: singleProduct['displayName'] ?? '',
          description: singleProduct['description'] ?? '',
          interestRate: singleProduct['interestRate'] ?? 0.0,
          tenorDays: singleProduct['tenorDays'] ?? 0,
          prematureCharge: singleProduct['prematureCharge'] ?? 0.0,
          normalCharge: singleProduct['normalCharge'] ?? 0.0,
          defaultCharge: singleProduct['defaultCharge'] ?? 0.0,
          serviceCharge: singleProduct['serviceCharge'] ?? 0.0,
          referralPercentageCharge: singleProduct['referralPercentageCharge'] ?? 0.0,
        );

        //Adding user to the list.
        productList.add(productResponseModel);
      }

      return productList;
    } else if (response.statusCode == 400) {
      throw Exception(response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerFeedbackResponseModel> registerCustomer(
      CustomerRequestModel requestModel, String referralNo, String productId) async {
    String url = "$DOMAIN_URL/onlineAccountOpening/$referralNo/$productId";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(status: true, message: response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    String ipAddress;
    String browserInfo = 'mobile_app';
    try {
      ipAddress = await Ipify.ipv4();
    } on Exception catch (e) {
      // TODO
      ipAddress = "IP failed to load";
    }
    String url = "$DOMAIN_URL/loginCustomer/$ipAddress/$browserInfo";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    print('Response code ${response.statusCode}');

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(
        json.decode(response.body),
      );
    } else if (response.statusCode == 400) {
      // CustomerWalletsBalanceModel customerWalletsBalance = CustomerWalletsBalanceModel(id: '', accountNumber: '', balance: '', productName: '', fullName: '', email: '', phoneNo: '');
      List<CustomerWalletsBalanceModel> customerList = [];
      return LoginResponseModel(token: response.body, customerWalletsList: customerList, lastTransactionsList: []);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<LoginResponseModel> pageReload(String token) async {
    String url = "$DOMAIN_URL/onPageReload/$token";

    final response = await http.get(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        });
    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(
        json.decode(response.body),
      );
    } else if (response.statusCode == 400) {
      return throw Exception('Unable to log in');
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> verifyDeposit(AccountTransactionRequestModel requestModel, int flutterwaveTxnId, String token) async {
    String url = "$DOMAIN_URL/verifyDepositMobile/$flutterwaveTxnId/$token";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> verifyDepositPayStack(AccountTransactionRequestModel requestModel, String reference, String token) async {
    String url = "$DOMAIN_URL/verifyDeposit/$reference/$token";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<List<StatementResponseModel>> getAccountStatement(
      String token, String accountNumber, String startDate, String endDate) async {
    String url = "$DOMAIN_URL/getAccountStatement/$token/$accountNumber/$startDate/$endDate";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print('data - $data');

      List<StatementResponseModel> statementList = [];
      for (var singleStatement in data) {
        StatementResponseModel statementResponseModel = StatementResponseModel(
          depositAmount: singleStatement['depositAmount'] ?? 0,
          withdrawalAmount: singleStatement['withdrawalAmount'] ?? 0,
          currentBalance: singleStatement['currentBalance'] ?? 0,
          narration: singleStatement['narration'] ?? '',
          timeCreated: singleStatement['timeCreated'] ?? '',
        );

        //Adding user to the list.
        statementList.add(statementResponseModel);
      }

      return statementList;
    } else if (response.statusCode == 400) {
      throw Exception(response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<LoginResponseModel> additionalAccount(String productId, String token) async {
    String url = "$DOMAIN_URL/additionalWalletAccount/$productId/$token";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        });

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(
        json.decode(response.body),
      );
    } else if (response.statusCode == 400) {
      // CustomerWalletsBalanceModel customerWalletsBalance = CustomerWalletsBalanceModel(id: '', accountNumber: '', balance: '', productName: '', fullName: '', email: '', phoneNo: '');
      List<CustomerWalletsBalanceModel> customerList = [];
      return LoginResponseModel(token: response.body, customerWalletsList: customerList, lastTransactionsList: []);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> bookInvestment(String accountNumber, String amount, int tenor, double rate, int instructionInt, String token) async {
    String url = "$DOMAIN_URL/bookInvestmentOnline/$accountNumber/$amount/$rate/$tenor/$instructionInt/$token";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },);

    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<List<CustomerInvestmentWalletModel>> allInvestments(
      String token) async {
    String url = "$DOMAIN_URL/allCustomerOnlineInvestment/$token";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<CustomerInvestmentWalletModel> customerWalletList = [];
      for (var singleStatement in data) {
        CustomerInvestmentWalletModel customerWalletsBalanceModel = CustomerInvestmentWalletModel(
          id: singleStatement['id'] ?? 0,
          amount: singleStatement['amount'] ?? 0,
          accountNumber: singleStatement['customerAccounts']['accountNumber'] ?? '',
          instruction: singleStatement['instruction'] ?? 0,
          interest: singleStatement['interest'] ?? 0,
          fullName: singleStatement['customerAccounts']['customer']['firstName'] + ' ' + singleStatement['customerAccounts']['customer']['lastName'] ?? '',
          maturityAmount: singleStatement['maturityAmount'] ?? 0,
          maturityTime: singleStatement['maturityTime'] ?? '',
          rate: singleStatement['rate'] ?? 0,
          tenor: singleStatement['tenor'] ?? 0,
          timeCreated: singleStatement['timeCreated'] ?? '',
          wht: singleStatement['wht'] ?? 0,
          displayName: singleStatement['customerAccounts']['products']['displayName'] ?? '',
        );
        //Adding user to the list.
        customerWalletList.add(customerWalletsBalanceModel);
      }

      return customerWalletList;
    } else if (response.statusCode == 400) {
      List<CustomerInvestmentWalletModel> customerWalletList = [];
      return customerWalletList;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> passwordReset(PwdResetRequestModel requestModel) async {
    String url = "$DOMAIN_URL/resetCustomerPassword";

    final response = await http.put(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    if (response.statusCode == 200) {
      return 'Success';
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> changePhoneNo(String phoneNo, String token) async {
    String url = "$DOMAIN_URL/modifyPhoneNumber/$phoneNo/$token";

    final response = await http.put(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },);

    print(response.body);

    if (response.statusCode == 200) {
      return 'Success';
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> modifyPassword(String password, String token) async {
    String ipAddress;
    String browserInfo = 'mobile_app';
    try {
      ipAddress = await Ipify.ipv4();
    } on Exception catch (e) {
      // TODO
      ipAddress = "IP failed to load";
    }

    String url = "$DOMAIN_URL/modifyPassword/$password/$ipAddress/$browserInfo/$token";

    final response = await http.put(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },);

    if (response.statusCode == 200) {
      return 'Success';
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> recordComplaints(ComplaintRequestModel requestModel) async {
    String url = "$DOMAIN_URL/recordComplaints";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());
    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<bool> addDeviceToken(
      PushDeviceTokenRequestModel requestModel, String token) async {
    String url = "$DOMAIN_URL/addDeviceToken/$token";

    final response = await http.put(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());
    print(requestModel.toJson());
    print(response.statusCode);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<LoginResponseModel> biometricLogin(String biometricToken) async {
    String ipAddress;
    String browserInfo = 'mobile_app';
    try {
      ipAddress = await Ipify.ipv4();
    } on Exception catch (e) {
      // TODO
      ipAddress = "IP failed to load";
    }
    String url = "$DOMAIN_URL/biometricLogin/$ipAddress/$browserInfo/$biometricToken";

    final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },);


    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(
        json.decode(response.body),
      );
    } else if (response.statusCode == 400) {
      // CustomerWalletsBalanceModel customerWalletsBalance = CustomerWalletsBalanceModel(id: '', accountNumber: '', balance: '', productName: '', fullName: '', email: '', phoneNo: '');
      List<CustomerWalletsBalanceModel> customerList = [];
      return LoginResponseModel(
          token: 'Please log in using Password to re-authenticate', customerWalletsList: customerList, lastTransactionsList: []);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> logout(String token) async {
    String ipAddress;
    String browserInfo = 'mobile_app';
    try {
      ipAddress = await Ipify.ipv4();
    } on Exception catch (e) {
      // TODO
      ipAddress = "IP failed to load";
    }
    String url = "$DOMAIN_URL/logoutCustomer/$ipAddress/$browserInfo/$token";

    final response = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<CustomerFeedbackResponseModel> registerCustomerWithoutBVN(
      CustomerRequestModel requestModel,
      String referralNo) async {
    String url =
        "$DOMAIN_URL/onlineAccountOpeningWithoutBVN/$referralNo";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerFeedbackResponseModel> registerCustomerWithBVN(
      CustomerRequestModel requestModel, String bvn,
      String referralNo) async {
    String url =
        "$DOMAIN_URL/onlineAccountOpeningWithBVN/$bvn/$referralNo";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerFeedbackResponseModel> verifyPin(
      String pinCode, String token) async {
    String url =
        "$DOMAIN_URL/verifyPincode/$pinCode/$token";

    final response = await http.get(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },);

    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(
          status: false, message: response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerFeedbackResponseModel> externalBankTransfer(
      ExternalBankTransferDetailsRequestModel requestModel) async {
    String url =
        "$DOMAIN_URL/externalBankTransfer";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());


    print(response.body);

    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(
          status: false, message: response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerFeedbackResponseModel> isPinCreated(String token) async {
    String url =
        "$DOMAIN_URL/isPinCreated/$token";

    final response = await http.get(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },);

    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(
          status: false, message: response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerFeedbackResponseModel> createPincode(
      UserPinCodeRequestModel requestModel, String token) async {
    String url =
        "$DOMAIN_URL/createPincode/$token";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(
          status: false, message: response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerFeedbackResponseModel> changePincode(
      UserPinCodeModifyRequestModel requestModel, String token) async {
    String url =
        "$DOMAIN_URL/changePincode/$token";

    final response = await http.put(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());
    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(
          status: false, message: response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerFeedbackResponseModel> updateAccountWithBVN(
      String bvn, String token) async {
    String url =
        "$DOMAIN_URL/updateAccountWithBVN/$bvn/$token";

    final response = await http.put(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },);
    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(
          status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(
          status: false, message: response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<List<ExternalBankTransferHistoryResponseModel>> lastTenTransfers(
      String token) async {
    String url = "$DOMAIN_URL/lastTenTransfers/$token";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<ExternalBankTransferHistoryResponseModel> externalBankTransferList = [];
      for (var singleTransfer in data) {
        ExternalBankTransferHistoryResponseModel externalBankTransferHistoryResponseModel =
        ExternalBankTransferHistoryResponseModel(
          id: singleTransfer['id'] ?? 0,
          destinationAccountName: singleTransfer['destinationAccountName'] ?? '',
          destinationAccountNumber: singleTransfer['destinationAccountNumber'] ?? '',
          destinationBankName: singleTransfer['destinationBankName'] ?? '',
          reference: singleTransfer['reference'] ?? '',
          status: singleTransfer['status'] ?? '',
          amount: singleTransfer['amount'] ?? 0,
          completeMessage: singleTransfer['completeMessage'] ?? '',
          timeCreated: singleTransfer['timeCreated'] ?? '',
        );
        //Adding user to the list.
        externalBankTransferList.add(externalBankTransferHistoryResponseModel);
      }

      return externalBankTransferList;
    } else if (response.statusCode == 400) {
      throw Exception(response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<InstantAirtimeAndDataFeedbackResponseModel> instantAirtimeAndDataRequest(
      InstantAirtimeAndDataRequestModel requestModel, String accountNumber, String token) async {
    String url = "$DOMAIN_URL/instantAirtimeAndDataRequest/$accountNumber/$token";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    print(response.body);

    if (response.statusCode == 200) {
      return InstantAirtimeAndDataFeedbackResponseModel.fromJson(
        json.decode(response.body),
      );
    } else if (response.statusCode == 400) {
      return InstantAirtimeAndDataFeedbackResponseModel(
        result: false,
        id: 0,
        transactionRef: '',
        timeCreated: '',
        phoneNumber: '',
        requestType: '',
        amount: 0,
      );
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> reverseInstantAirtimeFeedback(
      int transactionId, String token) async {
    String url = "$DOMAIN_URL/reversalInstantAirtimeAndData/$transactionId/$token";

    final response = await http.put(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<CustomerAccountDisplayModel> getAccountFromPhone(
      String phoneNo, String token) async {
    String url = "$DOMAIN_URL/getAccountFromPhoneNo/$phoneNo/$token";
    final response = await http.get(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    });
    if (response.statusCode == 200) {
      return CustomerAccountDisplayModel.fromJson(
        json.decode(response.body),
      );
    } else {
      return CustomerAccountDisplayModel(
          accountNumber: 'No Account', displayName: '', phoneNumber: '');
    }
  }

  Future<String> internalTransfer(
      AccountToAccountRequestModel requestModel, String token) async {
    String url = "$DOMAIN_URL/internalAccountTransfer/$token";
    print(requestModel.toJson());
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<OnlineRateResponseModel> getOnlineRate(String token) async {
    String url = "$DOMAIN_URL/getOnlineInvestmentRate/$token";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return OnlineRateResponseModel.fromJson(
        json.decode(response.body),
      );
    } else {
      return OnlineRateResponseModel(
        id: 0,
        oneMonth: 0,
        twoMonth: 0,
        threeMonth: 0,
        fourMonth: 0,
        fiveMonth: 0,
        sixMonth: 0,
        sevenMonth: 0,
        eightMonth: 0,
        nineMonth: 0,
        tenMonth: 0,
        elevenMonth: 0,
        twelveMonth: 0,
      );
    }
  }
  
}
