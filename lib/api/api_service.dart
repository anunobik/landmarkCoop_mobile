import 'dart:convert';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:http/http.dart' as http;

import '../model/airtime_model.dart';
import '../model/complaint_model.dart';
import '../model/customer_model.dart';
import '../model/loan_model.dart';
import '../model/login_model.dart';
import '../model/other_model.dart';
import '../model/password_model.dart';
import '../model/statement_model.dart';

class APIService {
  final String subdomain_url;

  APIService({required this.subdomain_url});

  Future<List<ProductResponseModel>> getProducts() async {
    String url = "$subdomain_url/allProducts";

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
          referralPercentageCharge:
          singleProduct['referralPercentageCharge'] ?? 0.0,
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
      CustomerRequestModel requestModel,
      String referralNo,
      String productId,
      String branchId) async {
    String url =
        "$subdomain_url/onlineAccountOpening/$referralNo/$productId/$branchId";

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
          status: true, message: response.body);
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
    String url = "$subdomain_url/loginCustomer/$ipAddress/$browserInfo";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(
        json.decode(response.body),
      );
    } else if (response.statusCode == 400) {
      // CustomerWalletsBalanceModel customerWalletsBalance = CustomerWalletsBalanceModel(id: '', accountNumber: '', balance: '', productName: '', fullName: '', email: '', phoneNo: '');
      List<CustomerWalletsBalanceModel> customerList = [];
      return LoginResponseModel(
          token: response.body, customerWalletsList: customerList);
    } else {
      throw Exception('Failed to load data!');
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
    String url =
        "$subdomain_url/biometricLogin/$ipAddress/$browserInfo/$biometricToken";

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(
        json.decode(response.body),
      );
    } else if (response.statusCode == 400) {
      // CustomerWalletsBalanceModel customerWalletsBalance = CustomerWalletsBalanceModel(id: '', accountNumber: '', balance: '', productName: '', fullName: '', email: '', phoneNo: '');
      List<CustomerWalletsBalanceModel> customerList = [];
      return LoginResponseModel(
          token: 'Please log in using Password to re-authenticate',
          customerWalletsList: customerList);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<LoginResponseModel> pageReload(String token) async {
    String url = "$subdomain_url/onPageReload/$token";

    final response = await http.get(Uri.parse(url), headers: <String, String>{
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

  Future<String> verifyDeposit(AccountTransactionRequestModel requestModel,
      int flutterwaveTxnId, String txnRef, String token) async {
    String url =
        "$subdomain_url/verifyDepositMobile/$flutterwaveTxnId/$txnRef/$token";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());
    print(response.statusCode);

    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 400) {
      pageReload(token);
      return response.body;
    } else {
      pageReload(token);
      throw Exception('Failed to load data!');
    }
  }

  Future<String> verifyDepositPayStack(
      AccountTransactionRequestModel requestModel,
      String reference,
      String token) async {
    String url = "$subdomain_url/verifyDeposit/$reference/$token";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

    if (response.statusCode == 200) {
      return response.body;
    } else if (response.statusCode == 400) {
      pageReload(token);
      return response.body;
    } else {
      pageReload(token);
      throw Exception('Failed to load data!');
    }
  }

  Future<List<StatementResponseModel>> getAccountStatement(String token,
      String accountNumber, String startDate, String endDate) async {
    String url =
        "$subdomain_url/getAccountStatement/$token/$accountNumber/$startDate/$endDate";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

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

  Future<LoginResponseModel> additionalAccount(String productId,
      String branchId, String token) async {
    String url =
        "$subdomain_url/additionalWalletAccount/$productId/$branchId/$token";

    final response = await http.post(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    });

    if (response.statusCode == 200) {
      return LoginResponseModel.fromJson(
        json.decode(response.body),
      );
    } else if (response.statusCode == 400) {
      // CustomerWalletsBalanceModel customerWalletsBalance = CustomerWalletsBalanceModel(id: '', accountNumber: '', balance: '', productName: '', fullName: '', email: '', phoneNo: '');
      List<CustomerWalletsBalanceModel> customerList = [];
      return LoginResponseModel(
          token: response.body, customerWalletsList: customerList);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerFeedbackResponseModel> bookInvestment(String accountNumber, String amount, int tenor,
      double rate, int instructionInt, int productId, String token) async {
    String url =
        "$subdomain_url/bookInvestmentPlanOnline/$accountNumber/$amount/$rate/$tenor/$instructionInt/$productId/$token";
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

    if (response.statusCode == 200) {
      return CustomerFeedbackResponseModel(status: true, message: response.body);
    } else if (response.statusCode == 400) {
      return CustomerFeedbackResponseModel(status: false, message: response.body);
    } else {
      return CustomerFeedbackResponseModel(status: true, message: 'Failed to load data!');
    }
  }

  Future<List<CustomerInvestmentWalletModel>> allInvestments(
      String token) async {
    String url = "$subdomain_url/allCustomerOnlineInvestment/$token";

    final response = await http.get(Uri.parse(url));
    print(response.toString());
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<CustomerInvestmentWalletModel> customerWalletList = [];
      for (var singleStatement in data) {
        CustomerInvestmentWalletModel customerWalletsBalanceModel =
        CustomerInvestmentWalletModel(
          id: singleStatement['id'] ?? 0,
          amount: singleStatement['amount'] ?? 0,
          accountNumber:
          singleStatement['customerAccounts']['accountNumber'] ?? '',
          instruction: singleStatement['instruction'] ?? 0,
          interest: singleStatement['interest'] ?? 0,
          fullName: singleStatement['customerAccounts']['customer']
          ['firstName'] +
              ' ' +
              singleStatement['customerAccounts']['customer']['lastName'] ??
              '',
          maturityAmount: singleStatement['maturityAmount'] ?? 0,
          maturityTime: singleStatement['maturityTime'] ?? '',
          rate: singleStatement['rate'] ?? 0,
          tenor: singleStatement['tenor'] ?? 0,
          timeCreated: singleStatement['timeCreated'] ?? '',
          wht: singleStatement['wht'] ?? 0,
          product: singleStatement['customerAccounts']['products']['products']['displayName'] ?? '',
        );
        //Adding user to the list.
        customerWalletList.add(customerWalletsBalanceModel);
      }

      return customerWalletList;
    } else if (response.statusCode == 400) {
      throw Exception(response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> passwordReset(PwdResetRequestModel requestModel) async {
    String url = "$subdomain_url/resetCustomerPassword";

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
    String url = "$subdomain_url/modifyPhoneNumber/$phoneNo/$token";

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

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

    String url =
        "$subdomain_url/modifyPassword/$password/$ipAddress/$browserInfo/$token";

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

    if (response.statusCode == 200) {
      return 'Success';
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<String> recordComplaints(ComplaintRequestModel requestModel) async {
    String url = "$subdomain_url/recordComplaints";

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

  Future<GatewayResponseModel> getActivePaymentGateway() async {
    String url = "$subdomain_url/getActivePaymentGateway";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return GatewayResponseModel.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception(response.body);
    }
  }

  Future<String> withdrawalRequest(WithdrawalRequestModel requestModel,
      String token) async {
    String url = "$subdomain_url/cashWithdrawalRequest/$token";
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

  Future<OnlineRateResponseModel> getOnlineRate(String token) async {
    String url = "$subdomain_url/getOnlineInvestmentRate/$token";

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

  Future<List<BranchResponseModel>> getAllBranches() async {
    String url = "$subdomain_url/getAllBranches";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<BranchResponseModel> branchList = [];
      for (var singleStatement in data) {
        BranchResponseModel branchResponseModel = BranchResponseModel(
          id: singleStatement['id'] ?? 0,
          branchName: singleStatement['branchName'] ?? '',
          displayName: singleStatement['displayName'] ?? '',
          address: singleStatement['address'] ?? '',
        );

        //Adding user to the list.
        branchList.add(branchResponseModel);
      }

      return branchList;
    } else if (response.statusCode == 400) {
      throw Exception(response.body);
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<CustomerAccountDisplayModel> getAccountFromPhone(String phoneNo,
      String token) async {
    String url = "$subdomain_url/getAccountFromPhoneNo/$phoneNo/$token";
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

  Future<String> internalTransfer(AccountToAccountRequestModel requestModel,
      String token) async {
    String url = "$subdomain_url/internalAccountTransfer/$token";
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

  Future<bool> addDeviceToken(PushDeviceTokenRequestModel requestModel,
      String token) async {
    String url = "$subdomain_url/addDeviceToken/$token";

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

  Future<String> logout(String token) async {
    String ipAddress;
    String browserInfo = 'mobile_app';
    try {
      ipAddress = await Ipify.ipv4();
    } on Exception catch (e) {
      // TODO
      ipAddress = "IP failed to load";
    }
    String url = "$subdomain_url/logoutCustomer/$ipAddress/$browserInfo/$token";

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<CustomerFeedbackResponseModel> registerCustomerWithoutBVN(
      CustomerRequestModel requestModel, String referralNo) async {
    String url = "$subdomain_url/onlineAccountOpeningWithoutBVN/$referralNo";

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
      CustomerRequestModel requestModel, String bvn, String referralNo) async {
    String url = "$subdomain_url/onlineAccountOpeningWithBVN/$bvn/$referralNo";

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

  Future<CustomerFeedbackResponseModel> verifyPin(String pinCode,
      String token) async {
    String url = "$subdomain_url/verifyPincode/$pinCode/$token";

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

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
    String url = "$subdomain_url/externalBankTransfer";
    print(requestModel.toJson());
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
    String url = "$subdomain_url/isPinCreated/$token";

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

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
    String url = "$subdomain_url/createPincode/$token";

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
    String url = "$subdomain_url/changePincode/$token";

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

  Future<CustomerFeedbackResponseModel> updateAccountWithBVN(String bvn,
      String token) async {
    String url = "$subdomain_url/updateAccountWithBVN/$bvn/$token";

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );
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
    String url = "$subdomain_url/lastTenTransfers/$token";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<ExternalBankTransferHistoryResponseModel> externalBankTransferList =
      [];
      for (var singleTransfer in data) {
        ExternalBankTransferHistoryResponseModel
        externalBankTransferHistoryResponseModel =
        ExternalBankTransferHistoryResponseModel(
          id: singleTransfer['id'] ?? 0,
          destinationAccountName:
          singleTransfer['destinationAccountName'] ?? '',
          destinationAccountNumber:
          singleTransfer['destinationAccountNumber'] ?? '',
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

  Future<InstantAirtimeAndDataFeedbackResponseModel>
  instantAirtimeAndDataRequest(InstantAirtimeAndDataRequestModel requestModel,
      String accountNumber,
      String token) async {
    String url =
        "$subdomain_url/instantAirtimeAndDataRequest/$accountNumber/$token";

    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: requestModel.toJson());

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

  Future<String> reverseInstantAirtimeFeedback(int transactionId,
      String token) async {
    String url =
        "$subdomain_url/reversalInstantAirtimeAndData/$transactionId/$token";

    final response = await http.put(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return response.body;
    }
  }

  Future<OnlineRateResponseModel> getOnlineLoanRate(String token) async {
    String url = "$subdomain_url/getOnlineLoanRate/$token";

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

  Future<CustomerFeedbackResponseModel> loanRequest(
      LoanRequestModel requestModel, String productId, String token) async {
    String url = "$subdomain_url/loanRequest/$productId/$token";

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

  Future<CustomerFeedbackResponseModel> resetPinCode(String password,
      String token) async {
    String url = "$subdomain_url/resetPincode/$password/$token";

    final response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

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

  Future<List<CustomerBeneficiaryResponseModel>> spoolCustomerBeneficiaries(
      String token) async {
    String url = '$subdomain_url/spoolCustomerBeneficiaries/$token';
    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<CustomerBeneficiaryResponseModel> beneficiaries = [];
      for (var singleBeneficiary in data) {
        CustomerBeneficiaryResponseModel customerBeneficiaryResponseModel =
        CustomerBeneficiaryResponseModel(
          id: singleBeneficiary['id'] ?? 0,
          beneficiaryAccountName:
          singleBeneficiary['beneficiaryAccountName'] ?? '',
          beneficiaryAccountNumber:
          singleBeneficiary['beneficiaryAccountNumber'] ?? '',
          beneficiaryBankName: singleBeneficiary['beneficiaryBankName'] ?? '',
          beneficiaryBankCode: singleBeneficiary['beneficiaryBankCode'] ?? '',
        );

        //Adding user to the list.
        beneficiaries.add(customerBeneficiaryResponseModel);
      }

      return beneficiaries;
    } else {
      throw Exception(response.body);
    }
  }

  Future<CustomerFeedbackResponseModel> removeCustomerBeneficiary(
      String beneficiaryId, String token) async {
    String url =
        "$subdomain_url/removeCustomerBeneficiary/$beneficiaryId/$token";

    final response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

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

  Future<CustomerFeedbackResponseModel> addCustomerBeneficiary(
      CustomerBeneficiaryRequestModel requestModel, String token) async {
    String url = "$subdomain_url/addCustomerBeneficiary/$token";

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

}
