class PurchaseSampleRevenewLedgerModel {
  final bool success;
  final Publication publication;
  final Totals totals;
  final List<LedgerItem> data;

  PurchaseSampleRevenewLedgerModel({
    required this.success,
    required this.publication,
    required this.totals,
    required this.data,
  });

  factory PurchaseSampleRevenewLedgerModel.fromJson(Map<String, dynamic> json) {
    return PurchaseSampleRevenewLedgerModel(
      success: json['success'] ?? false,
      publication: Publication.fromJson(json['publication']),
      totals: Totals.fromJson(json['totals']),
      data: (json['data'] as List)
          .map((e) => LedgerItem.fromJson(e))
          .toList(),
    );
  }
}

class Publication {
  final String publicationId;
  final String publication;
  final String gstNo;
  final String address;

  Publication({
    required this.publicationId,
    required this.publication,
    required this.gstNo,
    required this.address,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      publicationId: json['PublicationId'] ?? '',
      publication: json['Publication'] ?? '',
      gstNo: json['GstNo'] ?? '',
      address: json['Address'] ?? '',
    );
  }
}

class Totals {
  final double totalDebit;
  final double totalCredit;
  final double closingBalance;

  Totals({
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      totalDebit: (json['TotalDebit'] ?? 0).toDouble(),
      totalCredit: (json['TotalCredit'] ?? 0).toDouble(),
      closingBalance: (json['ClosingBalance'] ?? 0).toDouble(),
    );
  }
}

class LedgerItem {
  final String date;
  final String type;
  final String billNo;
  final double debit;
  final double credit;
  final double balance;

  LedgerItem({
    required this.date,
    required this.type,
    required this.billNo,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  factory LedgerItem.fromJson(Map<String, dynamic> json) {
    return LedgerItem(
      date: json['Date'] ?? '',
      type: json['Type'] ?? '',
      billNo: json['BillNo'] ?? '',
      debit: (json['Debit'] ?? 0).toDouble(),
      credit: (json['Credit'] ?? 0).toDouble(),
      balance: (json['Balance'] ?? 0).toDouble(),
    );
  }
}