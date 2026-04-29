import 'package:flutter/material.dart';
import '../SellReturn/sale_return_mrp_invoice_screenInvoice.dart';
import '/Model/sale_return_list_model.dart';
import '/Service/sale_return_list_service.dart';

class SaleReturnListScreen extends StatefulWidget {
  const SaleReturnListScreen({super.key});

  @override
  State<SaleReturnListScreen> createState() => _SaleReturnListScreenState();
}

class _SaleReturnListScreenState extends State<SaleReturnListScreen> {
  List<SaleReturnItem> list = [];
  List<SaleReturnItem> filteredList = [];

  bool isLoading = true;
  double grandTotal = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void loadData() async {
    final res = await SaleReturnListService.fetchList();

    if (res != null) {
      setState(() {
        list = res.data;
        filteredList = list;
        grandTotal = res.grandTotal;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void search(String value) {
    setState(() {
      filteredList = list.where((item) {
        return item.billNo.toLowerCase().contains(value.toLowerCase()) ||
            item.schoolName.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  /// ✅ SAFE DATE FORMAT
  String formatDate(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate);
      return "${dt.day}-${dt.month}-${dt.year}";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale Return List"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btnUp",
            mini: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            onPressed: () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: const Icon(Icons.arrow_upward),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btnDown",
            mini: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            onPressed: () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredList.isEmpty
          ? const Center(child: Text("No Data Found"))
          : Column(
        children: [

          /// 🔥 GRAND TOTAL
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
                const Text("Grand Total",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("₹ ${grandTotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

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
                width: 820,
                child: Column(
                  children: [

                    /// HEADER
                    Container(
                      color: Colors.deepPurple.shade100,
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: const [
                          SizedBox(width: 60, child: Text("Sr No")),
                          SizedBox(width: 80, child: Text("Bill No")),
                          SizedBox(width: 240, child: Text("School")),
                          SizedBox(width: 140, child: Text("Date")),
                          SizedBox(width: 140, child: Text("Amount")),
                          SizedBox(width: 100, child: Text("Action")),
                        ],
                      ),
                    ),

                    /// LIST
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
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

                                /// ✅ FIXED SCHOOL
                                SizedBox(
                                  width: 240,
                                  child: Text(
                                    item.schoolName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                SizedBox(width: 140, child: Text(formatDate(item.date))),

                                SizedBox(
                                  width: 140,
                                  child: Text("₹ ${item.amount.toStringAsFixed(2)}"),
                                ),

                                /// ACTION
                                SizedBox(
                                  width: 100,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == "details") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SaleReturnMrpInvoiceScreen(
                                              billNo: item.billNo,
                                            ),
                                          ),
                                        );
                                      } else if (value == "ledger") {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Ledger for ${item.billNo}")),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: "details",
                                        child: Text("MRP Details"),
                                      ),
                                      const PopupMenuItem(
                                        value: "ledger",
                                        child: Text("MRP Ledger"),
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
        ],
      ),
    );
  }
}