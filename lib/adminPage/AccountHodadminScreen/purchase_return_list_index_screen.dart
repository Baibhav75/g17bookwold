import 'package:flutter/material.dart';
import '../PurchaseReturn/purchase_return_details_screen.dart';
import '/Model/purchase_return_list_index_model.dart';
import '/Service/purchase_return_list_index_service.dart';

class PurchaseReturnListIndexScreen extends StatefulWidget {
  const PurchaseReturnListIndexScreen({super.key});

  @override
  State<PurchaseReturnListIndexScreen> createState() =>
      _PurchaseReturnListIndexScreenState();
}

class _PurchaseReturnListIndexScreenState
    extends State<PurchaseReturnListIndexScreen> {

  List<PurchaseReturnListItem> list = [];
  List<PurchaseReturnListItem> filteredList = [];

  bool isLoading = true;
  double grandTotal = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final res = await PurchaseReturnListIndexService.fetchList();

    if (!mounted) return;

    setState(() {
      if (res != null) {
        list = res.data;
        filteredList = list;
        grandTotal = res.grandTotal;
      }
      isLoading = false;
    });
  }

  void search(String value) {
    final query = value.toLowerCase();

    setState(() {
      filteredList = list.where((item) {
        return item.billNo.toLowerCase().contains(query) ||
            item.publication.toLowerCase().contains(query);
      }).toList();
    });
  }

  String formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return "${dt.day}-${dt.month}-${dt.year}";
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Return List"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          /// 🔥 GRAND TOTAL (AppBar ke niche)
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹ ${grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: search,
              decoration: InputDecoration(
                hintText: "Search Bill No / Publication",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          /// 🔥 TABLE
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 720,
                child: Column(
                  children: [

                    /// HEADER
                    Container(
                      color: Colors.deepPurple.shade100,
                      padding: const EdgeInsets.all(10),
                      child: const Row(
                        children: [
                          SizedBox(width: 60, child: Text("Sr No")),
                          SizedBox(width: 80, child: Text("Bill No")),
                          SizedBox(width: 200, child: Text("Publication")),
                          SizedBox(width: 120, child: Text("Date")),
                          SizedBox(width: 120, child: Text("Amount")),
                          SizedBox(width: 100, child: Text("View")),
                        ],
                      ),
                    ),

                    /// LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];

                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [

                                SizedBox(width: 60, child: Text("${index + 1}")),
                                SizedBox(width: 80, child: Text(item.billNo)),

                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    item.publication,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                SizedBox(width: 120, child: Text(formatDate(item.date))),

                                SizedBox(
                                  width: 120,
                                  child: Text("₹ ${item.amount.toStringAsFixed(2)}"),
                                ),

                                /// 🔥 VIEW DROPDOWN (FINAL FLOW)
                                SizedBox(
                                  width: 100,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {

                                        case "details":
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PurchaseReturnDetailsScreen(billNo: item.billNo),
                                            ),
                                          );
                                          break;

                                        case "ledger":
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("MRP Ledger ${item.billNo}")),
                                          );
                                          break;
                                      }
                                    },

                                    itemBuilder: (context) => const [

                                      PopupMenuItem(
                                        value: "details",
                                        child: Row(
                                          children: [
                                            Icon(Icons.receipt_long, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text("View MRP Details"),
                                          ],
                                        ),
                                      ),

                                      PopupMenuItem(
                                        value: "ledger",
                                        child: Row(
                                          children: [
                                            Icon(Icons.account_balance_wallet, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text("View MRP Ledger"),
                                          ],
                                        ),
                                      ),
                                    ],

                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.visibility, color: Colors.white, size: 16),
                                          SizedBox(width: 5),
                                          Text(
                                            "View",
                                            style: TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}