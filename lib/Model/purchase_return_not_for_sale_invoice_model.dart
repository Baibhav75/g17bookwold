class PurchaseReturnNotForSaleInvoiceModel {
  final String status;
  final String billNo;
  final String publication;
  final String date;
  final int totalItems;
  final double grandTotal;
  final List<PurchaseReturnItem> data;

  PurchaseReturnNotForSaleInvoiceModel({
    required this.status,
    required this.billNo,
    required this.publication,
    required this.date,
    required this.totalItems,
    required this.grandTotal,
    required this.data,
  });

  factory PurchaseReturnNotForSaleInvoiceModel.fromJson(
      Map<String, dynamic> json) {
    return PurchaseReturnNotForSaleInvoiceModel(
      status: json['Status'] ?? '',
      billNo: json['BillNo'] ?? '',
      publication: json['Publication'] ?? '',
      date: json['Date'] ?? '',
      totalItems: json['TotalItems'] ?? 0,
      grandTotal: (json['GrandTotal'] ?? 0).toDouble(),
      data: (json['Data'] as List)
          .map((e) => PurchaseReturnItem.fromJson(e))
          .toList(),
    );
  }
}

class PurchaseReturnItem {
  final String bookName;
  final String classes;
  final String subject;
  final int qty;
  final double rate;
  final double totalAmount;
  final String series;

  PurchaseReturnItem({
    required this.bookName,
    required this.classes,
    required this.subject,
    required this.qty,
    required this.rate,
    required this.totalAmount,
    required this.series,
  });

  factory PurchaseReturnItem.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnItem(
      bookName: json['BookName'] ?? '',
      classes: json['Classes'] ?? '',
      subject: json['Subject'] ?? '',
      qty: json['Qty'] ?? 0,
      rate: (json['Rate'] ?? 0).toDouble(),
      totalAmount: (json['TotalAmount'] ?? 0).toDouble(),
      series: json['Series'] ?? '',
    );
  }
}