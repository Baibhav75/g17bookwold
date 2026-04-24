import 'package:flutter/material.dart';
import '/Model/sale_not_return_list_model.dart';
import '/Service/sale_not_return_list_service.dart';

class SaleNotReturnListScreen extends StatefulWidget {
  const SaleNotReturnListScreen({super.key});

  @override
  State<SaleNotReturnListScreen> createState() =>
      _SaleNotReturnListScreenState();
}

class _SaleNotReturnListScreenState
    extends State<SaleNotReturnListScreen> {

  List<SaleNotReturnItem> list = [];
  List<SaleNotReturnItem> filteredList = [];

  bool isLoading = true;
  double grandTotal = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await SaleNotReturnListService.fetchList();

    setState(() {
      list = data;
      filteredList = data;

      isLoading = false;
    });
  }

  /// 🔍 SEARCH FUNCTION
  void search(String query) {
    final result = list.where((item) {
      return item.billNo.toLowerCase().contains(query.toLowerCase()) ||
          item.schoolName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredList = result;

    });
  }

  /// 💰 TOTAL CALCULATION


  String formatDate(String rawDate) {
    DateTime dt = DateTime.parse(rawDate);
    return "${dt.day}-${dt.month}-${dt.year}";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sample Not For Sale Return List"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: search,
              decoration: InputDecoration(
                hintText: "Search Bill No / School",
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
                width: 680,
                child: Column(
                  children: [

                    /// HEADER
                    Container(
                      color: Colors.deepPurple.shade100,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: const [
                          SizedBox(width: 60, child: Text("Sr No", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 80, child: Text("Bill No", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 240, child: Text("School", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 140, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 140, child: Text("View", style: TextStyle(fontWeight: FontWeight.bold))),

                        ],
                      ),
                    ),

                    /// LIST (FIXED - no Expanded)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
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
                                  width: 240,
                                  child: Text(
                                    item.schoolName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 140, child: Text(formatDate(item.date))),



                                /// ACTION
                                SizedBox(
                                  width: 60,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == "View Discount Details") {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Discount for ${item.billNo}")),
                                        );
                                      } else if (value == "View MRP Details") {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("MRP for ${item.billNo}")),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: "View Discount Details",
                                        child: Text("View Discount"),
                                      ),
                                      PopupMenuItem(
                                        value: "View MRP Details",
                                        child: Text("MRP Details"),
                                      ),
                                    ],
                                    child: const Icon(Icons.visibility, color: Colors.blue),
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

          /// GRAND TOTAL
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.deepPurple,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹ ${grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}