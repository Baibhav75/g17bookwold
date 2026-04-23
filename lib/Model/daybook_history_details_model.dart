class DayBookDetailsResponse {
  final List<DayBookDetails> data;
  final double totalDebit;
  final double totalCredit;
  final double balance;

  DayBookDetailsResponse({
    required this.data,
    required this.totalDebit,
    required this.totalCredit,
    required this.balance,
  });

  factory DayBookDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DayBookDetailsResponse(
      data: (json['Data'] as List)
          .map((e) => DayBookDetails.fromJson(e))
          .toList(),
      totalDebit: (json['TotalDebit'] ?? 0).toDouble(),
      totalCredit: (json['TotalCredit'] ?? 0).toDouble(),
      balance: (json['Balance'] ?? 0).toDouble(),
    );
  }
}

class DayBookDetails {
  final int id;
  final String name;
  final String flag;
  final double amount;
  final String date;
  final String mobileNo;
  final String remarks;
  final String expNo;
  final String recNo;
  final String? image;

  DayBookDetails({
    required this.id,
    required this.name,
    required this.flag,
    required this.amount,
    required this.date,
    required this.mobileNo,
    required this.remarks,
    required this.expNo,
    required this.recNo,
    this.image,
  });

  factory DayBookDetails.fromJson(Map<String, dynamic> json) {
    return DayBookDetails(
      id: json['id'],
      name: json['ParicularName'] ?? '',
      flag: json['Flag'] ?? '',
      amount: (json['Amount'] ?? 0).toDouble(),
      date: json['Createdatetime'] ?? '',
      mobileNo: json['MobileNo'] ?? '',
      remarks: json['Remarks'] ?? '',
      expNo: json['ExpenceBowcherNo'] ?? '',
      recNo: json['ReceiptBowcherNo'] ?? '',
      image: json['image'],
    );
  }
}