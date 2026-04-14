class PurchaseSampleRevenueResponse {
  final String message;
  final List<PurchaseSampleItem> data;
  final double grandTotal;

  PurchaseSampleRevenueResponse({
    required this.message,
    required this.data,
    required this.grandTotal,
  });

  factory PurchaseSampleRevenueResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseSampleRevenueResponse(
      message: json['Message'] ?? '',
      data: (json['Data'] as List)
          .map((e) => PurchaseSampleItem.fromJson(e))
          .toList(),
      grandTotal: (json['GrandTotal'] ?? 0).toDouble(),
    );
  }
}

class PurchaseSampleItem {
  final String billNo;
  final String publicationId;
  final String publication;
  final String date;
  final double amount;

  PurchaseSampleItem({
    required this.billNo,
    required this.publicationId,
    required this.publication,
    required this.date,
    required this.amount,
  });

  factory PurchaseSampleItem.fromJson(Map<String, dynamic> json) {
    return PurchaseSampleItem(
      billNo: json['BillNo'].toString(),
      publicationId: json['PublicationId'] ?? '', // ✅ ADD THIS
      publication: json['Publication'] ?? '',
      date: json['Dates'] ?? '',
      amount: (json['Amount'] ?? 0).toDouble(),
    );
  }
}