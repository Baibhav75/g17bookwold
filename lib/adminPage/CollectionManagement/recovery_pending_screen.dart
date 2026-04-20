import 'package:flutter/material.dart';
import '/Model/recovery_pending_list_model.dart';
import '/service/recovery_pending_service.dart';
import 'package:intl/intl.dart';

class RecoveryPendingScreen extends StatefulWidget {
  const RecoveryPendingScreen({super.key});

  @override
  State<RecoveryPendingScreen> createState() =>
      _RecoveryPendingScreenState();
}

class _RecoveryPendingScreenState extends State<RecoveryPendingScreen> {
  bool isLoading = true;
  String? errorMessage;
  Set<int> selectedIndexes = {};

  List<RecoveryItem> filteredList = [];
  List<RecoveryItem> originalList = [];

  TextEditingController searchController = TextEditingController();

  double totalAmount = 0.0;

  String formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';

    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('d/M/yyyy').format(date); // ✅ 2/12/2025
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final value = await RecoveryPendingService.fetchData();

      if (value != null) {
        setState(() {
          originalList = value.data;
          filteredList = value.data;
          totalAmount = value.totalAmount;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "No data found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      setState(() => filteredList = originalList);
      return;
    }

    final results = originalList.where((item) {
      return item.schoolName
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    setState(() => filteredList = results);
  }

  double getFilteredTotal() {
    return filteredList.fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Recovery"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Search School...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 🔥 Total Amount
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.purple.shade100,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Pending",
                    style:
                    TextStyle(fontWeight: FontWeight.bold)),
                Text("₹ ${getFilteredTotal().toStringAsFixed(2)}"),
              ],
            ),
          ),

          // 📊 TABLE
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text("Select")), // ✅ NEW
                    DataColumn(label: Text("Sr No")),
                    DataColumn(label: Text("School Name")),
                    DataColumn(label: Text("Address")),
                    DataColumn(label: Text("Amount")),
                    DataColumn(label: Text("Recovery By")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Receipt")),
                    DataColumn(label: Text("Mode")),
                    DataColumn(label: Text("View")),
                  ],
                  rows: List.generate(filteredList.length,
                          (index) {
                        final item = filteredList[index];

                        return DataRow(
                            selected: selectedIndexes.contains(index),
                            cells: [
                              /// ✅ CHECKBOX CELL
                              DataCell(
                                Checkbox(
                                  value: selectedIndexes.contains(index),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedIndexes.add(index);

                                        /// 🔥 POPUP WHEN CHECKED
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(item.schoolName),
                                            content: Text(
                                              "Amount: ₹${item.amount}\n"
                                                  "Status: ${item.status}\n"
                                                  "Recovery By: ${item.receivedBy}",
                                            ),
                                          ),
                                        );

                                      } else {
                                        selectedIndexes.remove(index);
                                      }
                                    });
                                  },
                                ),
                              ),

                              /// Sr No
                              DataCell(Text("${index + 1}")),

                              DataCell(Text(item.schoolName)),
                          DataCell(Text(item.schoolAddress)),
                          DataCell(Text("₹ ${item.amount}")),
                          DataCell(Text(item.receivedBy)),
                          DataCell(Text(item.status)),
                              DataCell(Text(formatDate(item.date))),
                          DataCell(Text(item.receiptNo)),
                          DataCell(Text(item.paymentMode)),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(item.schoolName),
                                    content: Text(
                                        "Amount: ₹${item.amount}\nStatus: ${item.status}"),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]);
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}