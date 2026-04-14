import 'package:flutter/material.dart';
import '/Model/receive_collection_model.dart';
import '/Service/receive_collection_service.dart';

class ReceiveCollectionScreen extends StatefulWidget {
  const ReceiveCollectionScreen({super.key});

  @override
  State<ReceiveCollectionScreen> createState() =>
      _ReceiveCollectionScreenState();
}

class _ReceiveCollectionScreenState extends State<ReceiveCollectionScreen> {
  late Future<ReceiveCollectionModel?> future;

  List filteredList = [];
  List originalList = [];
  TextEditingController searchController = TextEditingController();

  void filterSearch(String query) {
    final results = originalList.where((item) {
      return item.schoolName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredList = results;
    });
  }



  @override
  void initState() {
    super.initState();
    future = ReceiveCollectionService.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receive Collection"),
        backgroundColor: Colors.deepOrange,

      ),
      body: FutureBuilder<ReceiveCollectionModel?>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final list = data.data;

          if (originalList.isEmpty) {
            originalList = list;
            filteredList = list;
          }

          return Column(
            children: [

              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: searchController,
                  onChanged: filterSearch,
                  decoration: InputDecoration(
                    hintText: "Search School Name...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              // 🔥 Total Amount
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("₹ ${data.totalAmount.toStringAsFixed(2)}"),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 👉 horizontal
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical, // 👉 vertical
                    child: DataTable(
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text("Sr No")),
                        DataColumn(label: Text("School Name")),
                        DataColumn(label: Text("Address")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Recovery By")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Payment Date")),
                        DataColumn(label: Text("Receipt No")),
                        DataColumn(label: Text("Mode")),
                        DataColumn(label: Text("View")),
                      ],
                      rows: List.generate(filteredList.length, (index) {
                        final item = filteredList[index];

                        return DataRow(cells: [
                          DataCell(Text("${index + 1}")),
                          DataCell(Text(item.schoolName)),
                          DataCell(Text(item.address)),
                          DataCell(Text("₹ ${item.amount}")),
                          DataCell(Text(item.receivedBy)),
                          DataCell(Text(item.status)),
                          DataCell(Text(item.date.split("T")[0])), // ✅ clean date
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
                                    content: Text(item.remarks),
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
          );
        },
      ),
    );
  }
}