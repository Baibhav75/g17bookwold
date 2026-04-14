class SchoolProfileModel {
  final int id;
  final String schoolId;
  final String schoolName;
  final String ownerName;
  final String ownerNumber;
  final String principalName;
  final String principalNumber;
  final double openingBalance;
  final String balanceType;
  final String address;
  final String area;
  final String district;
  final String block;
  final String tahsil;
  final String state;
  final String manager;
  final String agentName;
  final String transportName;
  final String fileNo;
  final String type;
  final String accountCode;
  final String accountName;
  final String complaintRecord;

  SchoolProfileModel({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.ownerName,
    required this.ownerNumber,
    required this.principalName,
    required this.principalNumber,
    required this.openingBalance,
    required this.balanceType,
    required this.address,
    required this.area,
    required this.district,
    required this.block,
    required this.tahsil,
    required this.state,
    required this.manager,
    required this.agentName,
    required this.transportName,
    required this.fileNo,
    required this.type,
    required this.accountCode,
    required this.accountName,
    required this.complaintRecord,
  });

  factory SchoolProfileModel.fromJson(Map<String, dynamic> json) {
    return SchoolProfileModel(
      id: json['Id'] ?? 0,
      schoolId: json['SchoolId'] ?? '',
      schoolName: json['SchoolName'] ?? '',
      ownerName: json['OwnerName'] ?? '',
      ownerNumber: json['OwnerNumber'] ?? '',
      principalName: json['PrincipalName'] ?? '',
      principalNumber: json['PrincipalNumber'] ?? '',
      openingBalance:
      (json['OpeningBalance'] as num?)?.toDouble() ?? 0.0,
      balanceType: json['BalanceType'] ?? '',
      address: json['Address'] ?? '',
      area: json['Area'] ?? '',
      district: json['District'] ?? '',
      block: json['Block'] ?? '',
      tahsil: json['Tahsil'] ?? '',
      state: json['State'] ?? '',
      manager: json['Manager'] ?? '',
      agentName: json['AgentName'] ?? '',
      transportName: json['TransportName'] ?? '',
      fileNo: json['FileNo'] ?? '',
      type: json['Type'] ?? '',
      accountCode: json['AccountCode'] ?? '',
      accountName: json['AccountName'] ?? '',
      complaintRecord: json['ComplaintRecord'] ?? '',
    );
  }
}
