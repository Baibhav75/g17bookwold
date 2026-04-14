class PurchaseNotForSaleInvoiceModel {
  final String status;
  final String billNo;
  final String publication;
  final String date;
  final int totalItems;
  final double grandTotal;
  final List<PurchaseItem> data;

  PurchaseNotForSaleInvoiceModel({
    required this.status,
    required this.billNo,
    required this.publication,
    required this.date,
    required this.totalItems,
    required this.grandTotal,
    required this.data,
  });

  factory PurchaseNotForSaleInvoiceModel.fromJson(Map<String, dynamic> json) {
    return PurchaseNotForSaleInvoiceModel(
      status: json['Status'] ?? '',
      billNo: json['BillNo'] ?? '',
      publication: json['Publication'] ?? '',
      date: json['Date'] ?? '',
      totalItems: json['TotalItems'] ?? 0,
      grandTotal: (json['GrandTotal'] as num?)?.toDouble() ?? 0,
      data: (json['Data'] as List<dynamic>)
          .map((e) => PurchaseItem.fromJson(e))
          .toList(),
    );
  }
}

class PurchaseItem {
  final String bookName;
  final String classes;
  final String subject;
  final int qty;
  final double rate;
  final String boardName;
  final double totalAmount;
  final String series;

  PurchaseItem({
    required this.bookName,
    required this.classes,
    required this.subject,
    required this.qty,
    required this.rate,
    required this.boardName,
    required this.totalAmount,
    required this.series,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      bookName: json['BookName'] ?? '',
      classes: json['Classes'] ?? '',
      subject: json['Subject'] ?? '',
      qty: json['Qty'] ?? 0,
      rate: (json['Rate'] as num?)?.toDouble() ?? 0,
      boardName: json['BoardName'] ?? '',
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0,
      series: json['Series'] ?? '',
    );
  }
}