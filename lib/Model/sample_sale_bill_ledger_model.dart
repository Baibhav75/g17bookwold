class SampleSaleLedgerResponse {
  final String status;
  final String message;
  final School school;
  final List<LedgerItem> data;
  final double totalDebit;
  final double totalCredit;
  final double closingBalance;

  SampleSaleLedgerResponse({
    required this.status,
    required this.message,
    required this.school,
    required this.data,
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
  });

  factory SampleSaleLedgerResponse.fromJson(Map<String, dynamic> json) {
    return SampleSaleLedgerResponse(
      status: json['Status'],
      message: json['Message'],
      school: School.fromJson(json['School']),
      data: (json['Data'] as List)
          .map((e) => LedgerItem.fromJson(e))
          .toList(),
      totalDebit: (json['TotalDebit'] ?? 0).toDouble(),
      totalCredit: (json['TotalCredit'] ?? 0).toDouble(),
      closingBalance: (json['ClosingBalance'] ?? 0).toDouble(),
    );
  }
}

class School {
  final String refName;
  final String district;
  final String area;
  final String state;

  School({
    required this.refName,
    required this.district,
    required this.area,
    required this.state,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      refName: json['RefName'] ?? '',
      district: json['District'] ?? '',
      area: json['Area'] ?? '',
      state: json['State'] ?? '',
    );
  }
}

class LedgerItem {
  final String date;
  final String type;
  final String particulars;
  final double debit;
  final double credit;

  LedgerItem({
    required this.date,
    required this.type,
    required this.particulars,
    required this.debit,
    required this.credit,
  });

  factory LedgerItem.fromJson(Map<String, dynamic> json) {
    return LedgerItem(
      date: json['Date'] ?? '',
      type: json['Type'] ?? '',
      particulars: json['Particulars'] ?? '',
      debit: (json['Debit'] ?? 0).toDouble(),
      credit: (json['Credit'] ?? 0).toDouble(),
    );
  }
}