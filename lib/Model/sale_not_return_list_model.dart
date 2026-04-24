class SaleNotReturnItem {
  final String billNo;
  final String schoolName;
  final String date;

  SaleNotReturnItem({
    required this.billNo,
    required this.schoolName,
    required this.date,
  });

  factory SaleNotReturnItem.fromJson(Map<String, dynamic> json) {
    return SaleNotReturnItem(
      billNo: json['BillNo'] ?? '',
      schoolName: json['SchoolName'] ?? '',
      date: json['Dates'] ?? '',
    );
  }
}