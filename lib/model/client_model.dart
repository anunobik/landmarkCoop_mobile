import 'dart:convert';

class ClientResponseModel {
  final String clientName;
  final String subDomainName;
  final String rechargeCardNo;
  final int isActive;

  ClientResponseModel(
      {required this.clientName, required this.subDomainName, required this.rechargeCardNo, required this.isActive});

  factory ClientResponseModel.fromJson(Map<String, dynamic> json) {
    return ClientResponseModel(
      clientName: json['clientName'] ?? '',
      subDomainName: json['subDomainName'] ?? '',
      rechargeCardNo: json['rechargeCardNo'] ?? '',
      isActive: json['isActive'] ?? 0,
    );
  }
}