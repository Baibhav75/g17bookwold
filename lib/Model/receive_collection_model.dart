class ReceiveCollectionModel {
  final int count;
  final double totalAmount;
  final List<ReceiveItem> data;

  ReceiveCollectionModel({
    required this.count,
    required this.totalAmount,
    required this.data,
  });

  factory ReceiveCollectionModel.fromJson(Map<String, dynamic> json) {
    return ReceiveCollectionModel(
      count: json['Count'] ?? 0,
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0.0,
      data: (json['Data'] as List?)
          ?.map((e) => ReceiveItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ReceiveItem {
  final int id;
  final String schoolId;
  final String schoolName;
  final String address;
  final double amount;
  final String paymentMode;
  final String receivedBy;
  final String status;
  final String date;
  final String receiptNo;
  final String remarks;

  ReceiveItem({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.address,
    required this.amount,
    required this.paymentMode,
    required this.receivedBy,
    required this.status,
    required this.date,
    required this.receiptNo,
    required this.remarks,
  });

  factory ReceiveItem.fromJson(Map<String, dynamic> json) {
    return ReceiveItem(
      id: json['id'] ?? 0,
      schoolId: json['SchoolId'] ?? '',
      schoolName: json['SchoolName'] ?? '',
      address: json['SchoolAddress'] ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: json['Paymentmode'] ?? '',
      receivedBy: json['RecivedByFromSchool'] ?? '',
      status: json['Status'] ?? '',
      date: json['Date'] ?? '',
      receiptNo: json['ReciptNo'] ?? '',
      remarks: json['Remarks'] ?? '',
    );
  }
}