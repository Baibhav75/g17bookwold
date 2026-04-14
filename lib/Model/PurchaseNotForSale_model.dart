class PurchaseNotForSaleResponse {
  String message;
  List<PurchaseItem> data;
  double grandTotal;

  PurchaseNotForSaleResponse({
    required this.message,
    required this.data,
    required this.grandTotal,
  });

  factory PurchaseNotForSaleResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseNotForSaleResponse(
      message: json['Message'] ?? '',
      data: (json['Data'] as List)
          .map((e) => PurchaseItem.fromJson(e))
          .toList(),
      grandTotal: (json['GrandTotal'] ?? 0).toDouble(),
    );
  }
}

class PurchaseItem {
  String billNo;
  String publication;
  String publicationId; // ✅ NEW FIELD
  String date;
  double amount;

  PurchaseItem({
    required this.billNo,
    required this.publication,
    required this.publicationId,
    required this.date,
    required this.amount,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      billNo: json['BillNo'] ?? '',
      publication: json['Publication'] ?? '',
      publicationId: json['PublicationId'] ?? '', // ✅ FIX
      date: json['Dates'] ?? '',
      amount: (json['Amount'] ?? 0).toDouble(),
    );
  }
}