class PurchaseSampleInvoiceModel {
  final String status;
  final String billNo;
  final String publication;
  final String date;
  final int totalItems;
  final double grandTotal;
  final List<PurchaseSampleItem> data;

  PurchaseSampleInvoiceModel({
    required this.status,
    required this.billNo,
    required this.publication,
    required this.date,
    required this.totalItems,
    required this.grandTotal,
    required this.data,
  });

  factory PurchaseSampleInvoiceModel.fromJson(Map<String, dynamic> json) {
    return PurchaseSampleInvoiceModel(
      status: json['Status'] ?? '',
      billNo: json['BillNo'] ?? '',
      publication: json['Publication'] ?? '',
      date: json['Date'] ?? '',
      totalItems: json['TotalItems'] ?? 0,
      grandTotal: (json['GrandTotal'] ?? 0).toDouble(),
      data: (json['Data'] as List)
          .map((e) => PurchaseSampleItem.fromJson(e))
          .toList(),
    );
  }
}

class PurchaseSampleItem {
  final String bookName;
  final String classes;
  final String subject;
  final int qty;
  final double rate;
  final double totalAmount;
  final String series;

  PurchaseSampleItem({
    required this.bookName,
    required this.classes,
    required this.subject,
    required this.qty,
    required this.rate,
    required this.totalAmount,
    required this.series,
  });

  factory PurchaseSampleItem.fromJson(Map<String, dynamic> json) {
    return PurchaseSampleItem(
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