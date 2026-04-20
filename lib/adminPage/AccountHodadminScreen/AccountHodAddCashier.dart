import 'package:flutter/material.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController receivedController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController recoveryNameController = TextEditingController();
  final TextEditingController recoveryBoyController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController districtController = TextEditingController();

  String? selectedType;
  String? collectedBy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cashier"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// 🔷 Header
                Row(
                  children: const [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "Payment",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 25),

                /// FORM FIELDS
                buildDropdown(
                  title: "Select Type",
                  value: selectedType,
                  items: ["Cash", "Online", "Cheque"],
                  onChanged: (val) {
                    setState(() => selectedType = val);
                  },
                ),

                buildTextField("Amount", amountController),

                buildTextField(
                  "Received Amount",
                  receivedController,
                  hint: "Enter amount here",
                ),

                buildDropdown(
                  title: "Collected By (Office)",
                  value: collectedBy,
                  items: ["Admin", "Staff", "Manager"],
                  onChanged: (val) {
                    setState(() => collectedBy = val);
                  },
                ),

                buildTextField(
                  "Remarks",
                  remarksController,
                  maxLines: 3,
                ),

                buildTextField("Recovery Name", recoveryNameController),
                buildTextField("RecoveryBoyNo", recoveryBoyController),
                buildTextField("School Address", addressController),
                buildTextField("School Block", blockController),
                buildTextField("School District", districtController),

                const SizedBox(height: 20),

                /// ✅ SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Save logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      "Save Payment",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 TextField Widget
  Widget buildTextField(
      String title,
      TextEditingController controller, {
        String? hint,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(title),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Dropdown Widget
  Widget buildDropdown({
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(title),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              hint: const Text("-- Select --"),
              items: items
                  .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}