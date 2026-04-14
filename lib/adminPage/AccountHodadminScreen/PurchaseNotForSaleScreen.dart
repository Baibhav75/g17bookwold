import 'package:bookworld/adminPage/AccountHodadminScreen/purchase_not_for_sale_invoice_Deatils.dart';
import 'package:bookworld/adminPage/AccountHodadminScreen/purchase_not_for_sale_ledger_invoiceDetails.dart';
import 'package:flutter/material.dart';
import '../../Model/PurchaseNotForSale_model.dart';
import '../../Service/PurchaseNotForSale_service.dart';

class PurchaseNotForSaleScreen extends StatefulWidget {
  const PurchaseNotForSaleScreen({super.key});

  @override
  State<PurchaseNotForSaleScreen> createState() =>
      _PurchaseNotForSaleScreenState();
}

class _PurchaseNotForSaleScreenState
    extends State<PurchaseNotForSaleScreen> {
  List<PurchaseItem> list = [];
  List<PurchaseItem> filteredList = [];

  bool isLoading = true;
  double grandTotal = 0;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// 🔥 API CALL
  void loadData() async {
    final res = await PurchaseNotForSaleService.fetchList();

    if (res != null) {
      setState(() {
        list = res.data;
        filteredList = list; // 👈 for search
        grandTotal = res.grandTotal;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  /// 🔥 SEARCH FILTER
  void filterSearch(String query) {
    final results = list.where((item) {
      final bill = item.billNo.toLowerCase();
      final pub = item.publication.toLowerCase();
      final input = query.toLowerCase();

      return bill.contains(input) || pub.contains(input);
    }).toList();

    setState(() {
      filteredList = results;
    });
  }

  /// 🔥 DATE FORMAT
  String formatDate(String rawDate) {
    DateTime dt = DateTime.parse(rawDate);
    return "${dt.day}-${dt.month}-${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Not For Sale"),
        backgroundColor: Colors.deepPurple,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Search Bill No / Publication",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          /// 🔥 TABLE HEADER (Horizontal Scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 800,
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: const [
                  Expanded(
                      child: Text("Sr No",
                          style: TextStyle(
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text("Bill No",
                          style: TextStyle(
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text("Publication",
                          style: TextStyle(
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text("Date",
                          style: TextStyle(
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text("Action",
                          style: TextStyle(
                              fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),

          /// 🔥 LIST (Horizontal + Vertical Scroll)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800,
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text("${index + 1}")),
                          Expanded(child: Text(item.billNo)),
                          Expanded(
                            child: Text(
                              item.publication,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                              child: Text(formatDate(item.date))),
                          Expanded(
                            child: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "details") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PurchaseNotForSaleInvoiceScreen(
                                        billNo: item.billNo,
                                      ),
                                    ),
                                  );
                                } else if (value == "ledger") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PurchaseNotForSaleLedgerScreen(
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

                              /// 👇 THIS IS YOUR BUTTON UI
                              /// 🔥 BUTTON UI
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
            ),
          ),

          /// 🔥 GRAND TOTAL
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.deepPurple.shade50,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  grandTotal.toStringAsFixed(2),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}