class StatementResponseModel {
  final double depositAmount;
  final double withdrawalAmount;
  final double currentBalance;
  final String narration;
  final String timeCreated;

  StatementResponseModel({required this.depositAmount, required this.withdrawalAmount, required this.currentBalance, required this.narration, required this.timeCreated});

  factory StatementResponseModel.fromJson(Map<String, dynamic> json) {
    return StatementResponseModel(
      depositAmount: json['depositAmount'] ?? 0,
      withdrawalAmount: json['withdrawalAmount'] ?? 0,
      currentBalance: json['currentBalance'] ?? 0,
      narration: json['narration'] ?? '',
      timeCreated: json['timeCreated'] ?? '',
    );
  }
}