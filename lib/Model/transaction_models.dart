
class TransactionResponse {
  final List<DayBookData> data;

  TransactionResponse({required this.data});

  factory TransactionResponse.fromJson(List<dynamic> json) {
    return TransactionResponse(
      data: json.map((day) => DayBookData.fromJson(day)).toList(),
    );
  }

  // Helper method to get all transactions flattened
  List<Transaction> getAllTransactions() {
    final List<Transaction> allTransactions = [];
    for (final dayData in data) {
      allTransactions.addAll(dayData.transactions);
    }
    return allTransactions;
  }
}

class DayBookData {
  final String date;
  final List<Transaction> transactions;
  final double totalDebit;
  final double totalCredit;
  final double finalBalance;
  final double? totalOpening;
  final double openingBalance;
  final double todayOpeningBalance;
  final double nextDayFinalBalance;

  DayBookData({
    required this.date,
    required this.transactions,
    required this.totalDebit,
    required this.totalCredit,
    required this.finalBalance,
    this.totalOpening,
    required this.openingBalance,
    required this.todayOpeningBalance,
    required this.nextDayFinalBalance,
  });

  factory DayBookData.fromJson(Map<String, dynamic> json) {
    final transactions = (json['Transactions'] as List? ?? [])
        .map((transaction) => Transaction.fromJson(transaction))
        .toList();

    return DayBookData(
      date: json['Date']?.toString() ?? '',
      transactions: transactions,
      totalDebit: _parseDouble(json['TotalDebit'] ?? json['Totaldebit']),
      totalCredit: _parseDouble(json['TotalCredit'] ?? json['Totalcredit']),
      finalBalance: _parseDouble(json['FinalBalance'] ?? json['Finalbalance']),
      totalOpening: _parseDouble(json['TotalOpening'] ?? json['Totalopening']),
      openingBalance: _parseDouble(json['OpeningBalance'] ?? json['Openingbalance']),
      todayOpeningBalance: _parseDouble(json['TodayOpeningBalance'] ?? json['Todayopeningbalance']),
      nextDayFinalBalance: _parseDouble(json['NextDayFinalBalance'] ?? json['Nextdayfinalbalance']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();

    if (value is String) {
      final cleaned = value
          .replaceAll('₹', '')
          .replaceAll(',', '')
          .trim();

      return double.tryParse(cleaned) ?? 0.0;
    }

    return 0.0;
  }
}

class Transaction {
  final int id;
  final String particularName;
  final String flag;
  final double amount;
  double? totalBalance;
  final String createdDateTime;
  final double? openingBalance;
  final String? expenseBowcherNo;
  final String? receiptBowcherNo;
  final String? remark;
  final String? mobileNo;
  final String? remarks;
  final String? image;

  Transaction({
    required this.id,
    required this.particularName,
    required this.flag,
    required this.amount,
    this.totalBalance,
    required this.createdDateTime,
    this.openingBalance,
    this.expenseBowcherNo,
    this.receiptBowcherNo,
    this.remark,
    this.mobileNo,
    this.remarks,
    this.image,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: (json['id'] as num?)?.toInt() ?? 0,
      particularName: json['ParicularName']?.toString() ?? 'N/A',
      flag: json['Flag']?.toString() ?? '',
      amount: DayBookData._parseDouble(json['Amount'] ?? json['amount']),
      totalBalance: DayBookData._parseDouble(json['TotalBalance'] ?? json['Totalbalance'] ?? json['Total_Balance']),
      createdDateTime: (json['Createdatetime'] ?? json['CreatedDateTime'] ?? json['created_at'])?.toString() ?? '',
      openingBalance: DayBookData._parseDouble(json['OpeningBalance'] ?? json['Openingbalance']),
      expenseBowcherNo: json['ExpenceBowcherNo']?.toString(),
      receiptBowcherNo: json['ReceiptBowcherNo']?.toString(),
      remark: json['Remark']?.toString(),
      mobileNo: json['MobileNo']?.toString(),
      remarks: json['Remarks']?.toString(),
      image: json['image']?.toString(),
    );
  }

  // Helper methods
  double? get debit => flag.toLowerCase() == 'debit' ? amount : null;
  double? get credit => flag.toLowerCase() == 'credit' ? amount : null;

  bool get hasImage => image != null && image!.isNotEmpty && image != '/image/' && image != 'null';

  String get imageUrl {
    if (!hasImage) return '';
    if (image!.startsWith('/')) {
      return 'https://gj.realhomes.co.in$image';
    }
    return image!;
  }
}