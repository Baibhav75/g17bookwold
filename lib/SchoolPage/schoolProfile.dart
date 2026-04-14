import 'package:flutter/material.dart';
import '../Model/school_profile_model.dart';
import '../Service/school_profile_service.dart';

class SchoolProfilePage extends StatefulWidget {
  final String mobileNo;
  const SchoolProfilePage({Key? key, required this.mobileNo})
      : super(key: key);

  @override
  State<SchoolProfilePage> createState() => _SchoolProfilePageState();
}

class _SchoolProfilePageState extends State<SchoolProfilePage> {
  late Future<SchoolProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture =
        SchoolProfileService.fetchProfile(mobileNo: widget.mobileNo);
  }

  Widget _item(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrangeAccent),
        title:
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isEmpty ? "N/A" : value),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("School Profile",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrangeAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<SchoolProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final p = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue.shade100,
                  child:
                  const Icon(Icons.school, size: 50, color: Colors.deepOrangeAccent),
                ),
                const SizedBox(height: 8),
                Text(p.schoolName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Owner: ${p.ownerName}",
                    style: const TextStyle(color: Colors.grey)),

                _section("School Information"),
                _item("School Code", p.schoolId, Icons.badge),

                _item("Account Name", p.accountName, Icons.account_balance),
                _item("Account Code", p.accountCode, Icons.code),
                _item("Type", p.type, Icons.category),
                _item("File No", p.fileNo, Icons.folder),

                _section("Owner Details"),
                _item("Owner Name", p.ownerName, Icons.person),
                _item("Owner Mobile", p.ownerNumber, Icons.phone),

                _section("Principal Details"),
                _item("Principal Name", p.principalName, Icons.person_outline),
                _item("Principal Mobile", p.principalNumber, Icons.phone_android),

                _section("Address"),
                _item("Address", p.address, Icons.home),
                _item("Area", p.area, Icons.location_on),
                _item("District", p.district, Icons.map),
                _item("State", p.state, Icons.public),

                _section("Finance"),
                _item("Opening Balance",
                    "₹ ${p.openingBalance}", Icons.currency_rupee),
                _item("Balance Type", p.balanceType, Icons.account_balance_wallet),

                _section("Other"),
                _item("Manager", p.manager, Icons.supervisor_account),
                _item("Agent Name", p.agentName, Icons.support_agent),
                _item("Transport", p.transportName, Icons.directions_bus),
                _item("Complaint", p.complaintRecord, Icons.report_problem),
              ],
            ),
          );
        },
      ),
    );
  }
}
