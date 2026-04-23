class SalePendingMixOrderModel {
  final String schoolName;
  final List<SalePendingItem> data;
  final Summary summary;

  SalePendingMixOrderModel({
    required this.schoolName,
    required this.data,
    required this.summary,
  });

  factory SalePendingMixOrderModel.fromJson(Map<String, dynamic> json) {
    return SalePendingMixOrderModel(
      schoolName: json['SchoolName']?.toString() ?? '',
      data: (json['Data'] as List? ?? [])
          .map((e) => SalePendingItem.fromJson(e))
          .toList(),
      summary: json['Summary'] != null 
          ? Summary.fromJson(json['Summary']) 
          : Summary(totalOrder: 0, totalSale: 0, totalRate: 0, totalPending: 0),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class SalePendingItem {
  final String publication;
  final String series;
  final String bookName;
  final int totalOrder;
  final int sale;
  final String pending;
  final double rate;

  SalePendingItem({
    required this.publication,
    required this.series,
    required this.bookName,
    required this.totalOrder,
    required this.sale,
    required this.pending,
    required this.rate,
  });

  factory SalePendingItem.fromJson(Map<String, dynamic> json) {
    return SalePendingItem(
      publication: json['Publication']?.toString() ?? '',
      series: json['Series']?.toString() ?? '',
      bookName: json['BookName']?.toString() ?? '',
      totalOrder: SalePendingMixOrderModel._parseInt(json['TotalOrder']),
      sale: SalePendingMixOrderModel._parseInt(json['Sale']),
      pending: json['Pending']?.toString() ?? '',
      rate: SalePendingMixOrderModel._parseDouble(json['Rate']),
    );
  }
}

class Summary {
  final int totalOrder;
  final int totalSale;
  final double totalRate;
  final int totalPending;

  Summary({
    required this.totalOrder,
    required this.totalSale,
    required this.totalRate,
    required this.totalPending,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalOrder: SalePendingMixOrderModel._parseInt(json['TotalOrder']),
      totalSale: SalePendingMixOrderModel._parseInt(json['TotalSale']),
      totalRate: SalePendingMixOrderModel._parseDouble(json['TotalRate']),
      totalPending: SalePendingMixOrderModel._parseInt(json['TotalPending']),
    );
  }
}