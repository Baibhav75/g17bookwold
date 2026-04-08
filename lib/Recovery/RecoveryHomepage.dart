import 'package:bookworld/Recovery/recovery_history_screen.dart';
import 'package:flutter/material.dart';
import '../Model/receive_pending_amount_model.dart';
import '../Service/assigned_school_service.dart';
import '../Model/assigned_school_model.dart';
import '../Service/receive_pending_amount_service.dart';
import 'AssignedSchoolScreen.dart';
import 'CollectAmountPage.dart';
import 'RecoveryPendingAmountScreen.dart';
import 'RecoveryProfile.dart';
import 'TransferHistory.dart';
import 'changePasswordRecovery.dart';
import 'counterAmount.dart';

class RecoveryHomePage extends StatefulWidget {
  final String position;
  final String agentName;
  final String mobileNo;
  final String employeeId;   // ✅ Add this

  const RecoveryHomePage({
    Key? key,
    required this.position,
    required this.agentName,
    required this.mobileNo,
    required this.employeeId,   // ✅ use this.

  }) : super(key: key);

  @override
  State<RecoveryHomePage> createState() => _RecoveryHomePageState();
}

class _RecoveryHomePageState extends State<RecoveryHomePage> {
  int _currentIndex = 0;
  final AssignedSchoolService _service = AssignedSchoolService();

  ReceivePendingAmountModel? amountData;
  bool isLoadingAmount = true;


  @override
  void initState() {
    super.initState();
    _loadAmounts();
  }
  void _loadAmounts() async {
    final data = await ReceivePendingAmountService()
        .fetchAmounts(widget.employeeId);

    if (mounted) {
      setState(() {
        amountData = data;
        isLoadingAmount = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFFEF6C00),
        title: const Text(
          "Recovery Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: _buildDashboard(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFEF6C00),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.school), label: "Schools"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ===================== DASHBOARD =====================
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryCards(),
          const SizedBox(height: 20),

          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _menuItem("Assigned Schools", Icons.school, Colors.blue),
              _menuItem("Collect Amount", Icons.payments, Colors.green),
              _menuItem("Recovery History", Icons.history, Colors.orange),
              _menuItem("Pending Dues", Icons.warning, Colors.red),
              _menuItem("Reports", Icons.bar_chart, Colors.purple),
              _menuItem("Profile", Icons.person, Colors.teal),
              _menuItem("Amount\nCounter", Icons.home_repair_service_outlined, Colors.amberAccent),
              _menuItem("Transfer\nHistory", Icons.history_edu_outlined, Colors.blueGrey),

            ],
          ),
        ],
      ),
    );
  }

  // ===================== SUMMARY =====================
  Widget _summaryCards() {
    if (isLoadingAmount) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        _summaryCard(
          "Receive Balance",
          "₹ ${amountData?.receivedAmount.toStringAsFixed(2) ?? "0.00"}",
          Colors.green,
        ),
        const SizedBox(width: 12),
        _summaryCard(
          "Pending Amount",
          "₹ ${amountData?.pendingAmount.toStringAsFixed(2) ?? "0.00"}",
          Colors.red,
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== MENU ITEM =====================
  Widget _menuItem(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () async {

        if (title == "Assigned Schools") {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssignedSchoolScreen(
                employeeId: widget.employeeId,
              ),
            ),
          );
        }
        if (title == "Pending Dues") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RecoveryPendingAmountScreen(
                    employeeId: widget.employeeId,
                  ),
            ),
          );
        }

        if (title == "Recovery History") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RecoveryHistoryListScreen (employeeId: widget.employeeId,
                    // employeeId: widget.employeeId,
                  ),
            ),
          );
        }
        if (title == "Transfer\nHistory") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransferHistory
                  (employeeId: widget.employeeId,
                    // employeeId: widget.employeeId,
                  ),
            ),
          );
        }

        if (title == "Profile") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Recoveryprofile(

                mobileNo: widget.mobileNo,

              ),
            ),
          );
        }

        if (title == "Amount\nCounter") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>CounterAmountPage
                   (agentName:  widget.agentName, pendingAmount: amountData?.pendingAmount ?? 0.0,
                employeeId: widget.employeeId,

                  ),
            ),
          );
        }

        else if (title == "Collect Amount") {

          final data =
          await _service.fetchAssignedSchools(widget.employeeId);

          if (data != null &&
              data.status?.toLowerCase() == "success" &&
              data.data?.schools != null &&
              data.data!.schools!.isNotEmpty) {

            final school = data.data!.schools!.first;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CollectAmountPage(
                  schoolId: school.schoolId ?? "",
                  schoolName: school.schoolName ?? "",
                ),
              ),
            );



          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No schools found")),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }


  // ===================== DRAWER =====================
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: const Color(0xFFEF6C00),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person,
                      size: 36, color: Colors.deepOrange),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.position,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.agentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.mobileNo,
                  style: const TextStyle(color: Colors.white70),
                ),

              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Recoveryprofile(

                    mobileNo: widget.mobileNo,

                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () {
              Navigator.pop(context); // 👈 pehle drawer close karo

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangePasswordRecovery(

                    mobileNo: widget.mobileNo,

                  ),
                ),
              );
            },
          ),
          const Divider(),

          // UI-ONLY LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context); // back to login
            },
          ),
        ],
      ),
    );
  }
}