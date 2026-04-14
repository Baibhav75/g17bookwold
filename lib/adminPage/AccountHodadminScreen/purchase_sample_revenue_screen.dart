import 'package:bookworld/adminPage/AccountHodadminScreen/purchase_not_for_sale_invoice_Deatils.dart';
import 'package:bookworld/adminPage/AccountHodadminScreen/purchase_sample_invoice_DetailsInvoice.dart';
import 'package:bookworld/adminPage/AccountHodadminScreen/purchase_sample_revenew_ledger_screen.dart';
import 'package:flutter/material.dart';
import '/Model/purchase_sample_revenue_list_model.dart';
import '/Service/purchase_sample_revenue_service.dart';

class PurchaseSampleRevenueScreen extends StatefulWidget {
  const PurchaseSampleRevenueScreen({super.key});

  @override
  State<PurchaseSampleRevenueScreen> createState() =>
      _PurchaseSampleRevenueScreenState();
}

class _PurchaseSampleRevenueScreenState
    extends State<PurchaseSampleRevenueScreen> {

  List<PurchaseSampleItem> list = [];
  List<PurchaseSampleItem> filteredList = [];

  bool isLoading = true;
  double grandTotal = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final res = await PurchaseSampleRevenueService.fetchList();

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
            item.publication.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  String formatDate(String rawDate) {
    DateTime dt = DateTime.parse(rawDate);
    return "${dt.day}-${dt.month}-${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sample Purchase List"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          /// 🔍 SEARCH BAR
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

          /// 🔥 TABLE (HORIZONTAL + VERTICAL SCROLL)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 700, // 👈 important for horizontal scroll
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
                          SizedBox(width: 200, child: Text("Publication", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 120, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 120, child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 80, child: Text("View", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),

                    /// LIST (VERTICAL SCROLL)
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
                                SizedBox(
                                  width: 80,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == "details") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PurchaseSampleInvoiceScreen (
                                              billNo: item.billNo,
                                            ),
                                          ),
                                        );
                                      } else if (value == "ledger") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PurchaseSampleRevenewLedgerScreen (
                                              publicationId: item.publicationId,
                                            ),
                                          ),
                                        );

                                      }
                                    },

                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: "details",
                                        child: Row(
                                          children: [
                                            Icon(Icons.receipt_long, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text("View Details"),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: "ledger",
                                        child: Row(
                                          children: [
                                            Icon(Icons.account_balance_wallet, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text("View Ledger"),
                                          ],
                                        ),
                                      ),
                                    ],

                                    /// 👇 THIS IS YOUR ICON (CLICK AREA)
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