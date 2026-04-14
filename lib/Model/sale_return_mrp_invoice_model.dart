class SaleReturnMrpInvoiceModel {
  final String status;
  final Master master;
  final double billTotalAmount;
  final List<SaleReturnItem> items;

  SaleReturnMrpInvoiceModel({
    required this.status,
    required this.master,
    required this.billTotalAmount,
    required this.items,
  });

  factory SaleReturnMrpInvoiceModel.fromJson(Map<String, dynamic> json) {
    return SaleReturnMrpInvoiceModel(
      status: json['Status'] ?? '',
      master: Master.fromJson(json['Master']),
      billTotalAmount: (json['BillTotalAmount'] ?? 0).toDouble(),
      items: (json['Items'] as List)
          .map((e) => SaleReturnItem.fromJson(e))
          .toList(),
    );
  }
}

class Master {
  final String billNo;
  final String schoolName;
  final String schoolId;
  final String address;
  final String transport;
  final String date;

  Master({
    required this.billNo,
    required this.schoolName,
    required this.schoolId,
    required this.address,
    required this.transport,
    required this.date,
  });

  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      billNo: json['BillNo'] ?? '',
      schoolName: json['schoolname'] ?? '',
      schoolId: json['SchoolId'] ?? '',
      address: json['Address'] ?? '',
      transport: json['Transport'] ?? '',
      date: json['Dates'] ?? '',
    );
  }
}

class SaleReturnItem {
  final String bookName;
  final String subject;
  final String publication;
  final String classes;
  final String series;
  final int qty;
  final double rate;
  final double totalAmount;
  final double discount;

  SaleReturnItem({
    required this.bookName,
    required this.subject,
    required this.publication,
    required this.classes,
    required this.series,
    required this.qty,
    required this.rate,
    required this.totalAmount,
    required this.discount,
  });

  factory SaleReturnItem.fromJson(Map<String, dynamic> json) {
    return SaleReturnItem(
      bookName: json['BookName'] ?? '',
      subject: json['Subject'] ?? '',
      publication: json['Publication'] ?? '',
      classes: json['Classes'] ?? '',
      series: json['Series'] ?? '',
      qty: json['Qty'] ?? 0,
      rate: (json['Rate'] ?? 0).toDouble(),
      totalAmount: (json['TotalAmount'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
    );
  }
}