class NewRecoverBalanceModel {
  final int srNo;
  final String schoolId;
  final String schoolName;
  final String agentName;
  final String contact;
  final double openingBalance;
  final double totalDebit;
  final double totalPayment;
  final double totalReturn;
  final double netBalance;

  NewRecoverBalanceModel({
    required this.srNo,
    required this.schoolId,
    required this.schoolName,
    required this.agentName,
    required this.contact,
    required this.openingBalance,
    required this.totalDebit,
    required this.totalPayment,
    required this.totalReturn,
    required this.netBalance,
  });

  factory NewRecoverBalanceModel.fromJson(Map<String, dynamic> json) {
    return NewRecoverBalanceModel(
      srNo: json['SrNo'] ?? 0,
      schoolId: json['SchoolId'] ?? '',
      schoolName: json['SchoolName'] ?? '',
      agentName: json['AgentName'] ?? '',
      contact: json['Contact'] ?? '',
      openingBalance: (json['OpeningBalance'] ?? 0).toDouble(),
      totalDebit: (json['TotalDebit'] ?? 0).toDouble(),
      totalPayment: (json['TotalPayment'] ?? 0).toDouble(),
      totalReturn: (json['TotalReturn'] ?? 0).toDouble(),
      netBalance: (json['NetBalance'] ?? 0).toDouble(),
    );
  }
}