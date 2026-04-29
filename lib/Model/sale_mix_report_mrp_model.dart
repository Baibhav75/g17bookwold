class SaleMixReportMrpModel {
  final String schoolName;
  final int totalSaleQty;
  final int totalReturnQty;
  final double totalAmount;
  final double totalNetAmount;
  final double totalDiscount;
  final List<SaleMixItem> data;

  SaleMixReportMrpModel({
    required this.schoolName,
    required this.totalSaleQty,
    required this.totalReturnQty,
    required this.totalAmount,
    required this.totalNetAmount,
    required this.totalDiscount,
    required this.data,
  });

  factory SaleMixReportMrpModel.fromJson(Map<String, dynamic> json) {
    return SaleMixReportMrpModel(
      schoolName: json['SchoolName'] ?? '',
      totalSaleQty: int.tryParse(json['TotalSaleQty'].toString()) ?? 0,
      totalReturnQty: int.tryParse(json['TotalReturnQty'].toString()) ?? 0,
      totalAmount: double.tryParse(json['TotalAmount'].toString()) ?? 0.0,
      totalNetAmount: double.tryParse(json['TotalNetAmount'].toString()) ?? 0.0,
      totalDiscount: double.tryParse(json['TotalDiscount']?.toString() ?? '') ?? 0.0,
      data: (json['Data'] as List? ?? [])
          .map((e) => SaleMixItem.fromJson(e))
          .toList(),
    );
  }
}

class SaleMixItem {
  final String publication;
  final String series;
  final String bookName;
  final int saleQty;
  final int returnQty;
  final int netQty;
  final double rate;
  final double amount;
  final double discount;
  final double netAmount;

  SaleMixItem({
    required this.publication,
    required this.series,
    required this.bookName,
    required this.saleQty,
    required this.returnQty,
    required this.netQty,
    required this.rate,
    required this.amount,
    required this.discount,
    required this.netAmount,
  });

  factory SaleMixItem.fromJson(Map<String, dynamic> json) {
    return SaleMixItem(
      publication: json['Publication'] ?? '',
      series: json['Series'] ?? '',
      bookName: json['BookName'] ?? '',
      saleQty: int.tryParse(json['SaleQty'].toString()) ?? 0,
      returnQty: int.tryParse(json['SaleReturnQty'].toString()) ?? 0,
      netQty: int.tryParse(json['NetQty'].toString()) ?? 0,
      rate: double.tryParse(json['Rate'].toString()) ?? 0.0,
      amount: double.tryParse(json['Amount'].toString()) ?? 0.0,
      discount: double.tryParse(json['DiscountPercent']?.toString() ?? '') ?? 
                double.tryParse(json['Discount']?.toString() ?? '') ?? 0.0,
      netAmount: double.tryParse(json['NetAmount'].toString()) ?? 0.0,
    );
  }
}