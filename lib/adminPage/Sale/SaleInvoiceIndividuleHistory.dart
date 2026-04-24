import 'package:bookworld/adminPage/Sale/sale_details_mrp_screen.dart';
import 'package:bookworld/adminPage/Sale/sale_invoice_details_screen.dart';
import 'package:bookworld/adminPage/Sale/sale_view_mrp_ledger_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../appDart/discrete_circular_loader.dart';
import '/Model/sale_invoice_history_model.dart';
import '/Service/sale_invoice_history_service.dart';
import 'EnterysaleScreen.dart';
import 'SaleLedgerDiscount_screen.dart';
import 'SaleMixReportCompanyPScreen.dart';
import 'SaleMixReportOrderPendingScreen.dart';
import 'SaleMixReportScreen.dart';

class  SaleInvoiceIndividuleScreen extends StatefulWidget {
  const  SaleInvoiceIndividuleScreen({super.key});

  @override
  State< SaleInvoiceIndividuleScreen> createState() =>
      _SaleInvoiceIndividuleScreenState();
}

class _SaleInvoiceIndividuleScreenState
    extends State< SaleInvoiceIndividuleScreen> {

  List<SaleInvoiceHistoryItem> list = [];
  List<SaleInvoiceHistoryItem> filteredList = [];

  bool isLoading = true;
  double grandTotal = 0;
  int totalBills = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final res = await SaleInvoiceHistoryService.fetchList();

    if (res != null) {
      List<SaleInvoiceHistoryItem> sortedData = res.data;

      // Sort logic: Primary - Date (Newest first), Secondary - School Name (A-Z)
      sortedData.sort((a, b) {
        DateTime? dateA = a.date != null ? DateTime.tryParse(a.date!) : null;
        DateTime? dateB = b.date != null ? DateTime.tryParse(b.date!) : null;

        // 🔥 1. TODAY FIRST
        DateTime today = DateTime.now();

        bool isTodayA = dateA != null &&
            dateA.year == today.year &&
            dateA.month == today.month &&
            dateA.day == today.day;

        bool isTodayB = dateB != null &&
            dateB.year == today.year &&
            dateB.month == today.month &&
            dateB.day == today.day;

        if (isTodayA && !isTodayB) return -1;
        if (!isTodayA && isTodayB) return 1;

        // 🔥 2. DATE DESC (Newest first)
        if (dateA != null && dateB != null) {
          int dateCompare = dateB.compareTo(dateA);
          if (dateCompare != 0) return dateCompare;
        }

        // 🔥 3. ALPHABETICAL (A-Z)
        return a.schoolName.toLowerCase().compareTo(b.schoolName.toLowerCase());
      });

      setState(() {
        list = sortedData;
        filteredList = list;
        grandTotal = res.grandTotal;
        totalBills = res.totalBills;
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

  void filterToday() {
    DateTime today = DateTime.now();

    setState(() {
      filteredList = list.where((item) {
        if (item.date == null) return false;

        DateTime? d = DateTime.tryParse(item.date!);
        if (d == null) return false;

        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day;
      }).toList();
    });
  }



  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(rawDate);
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (e) {
      // If parsing fails (e.g. format is already DD-MM-YYYY), return raw or attempt simple split
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Sale Invoice Individual History",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        // 👇 Add this section
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            tooltip: "Add Sale",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SaleInvoiceEntry(), // your screen
                ),
              );
            },
          ),
        ],
      ),

      body: isLoading
          ? const  SchoolLoader ()

          : Column(
        children: [
          // 🔥 SUMMARY CARD (TOP)
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /// TOTAL BILLS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Bills",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$totalBills",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                /// GRAND TOTAL
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Grand Total",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "₹ ${grandTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: search,
                    decoration: InputDecoration(
                      hintText: "Search Bill No / School",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10),


              ],
            ),
          ),


          /// 🔥 TABLE
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 900,
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
                          SizedBox(width: 260, child: Text("School", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 140, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 160, child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 80, child: Text("View", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),

                    /// LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];

                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SaleDetailsMrpScreen(
                                      billNo: item.billNo,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
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
                                    SizedBox(width: 260, child: Text(item.schoolName)),
                                    SizedBox(width: 140, child: Text(formatDate(item.date))),
                                    SizedBox(
                                      width: 160,
                                      child: Text("₹ ${item.totalAmount.toStringAsFixed(2)}"),
                                    ),
                                SizedBox(
                                  width: 120,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {

                                        case "mrp":
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SaleDetailsMrpScreen(
                                                billNo: item.billNo,
                                              ),
                                            ),
                                          );
                                          break;

                                        case "discount":
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SaleInvoiceDetailsScreen(
                                                billNo: item.billNo,
                                              ),
                                            ),
                                          );
                                          break;

                                        case "MRP_ledger":
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>  SaleViewMRPLedgerScreen(
                                                schoolId: item.schoolId,
                                              ),
                                            ),
                                          );
                                          break;

                                        case "Discount":
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>  SaleLedgerDiscountScreen(
                                                schoolId: item.schoolId,
                                              ),
                                            ),
                                          );
                                          break;
                                        case "mix":
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>  SaleMixReportScreen(
                                                schoolId: item.schoolId,
                                              ),
                                            ),
                                          );
                                          break;

                                        case "pending_mix":
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>  SalePendingMixOrderScreen (
                                                schoolId: item.schoolId,
                                              ),
                                            ),
                                          );
                                          break;

                                        case "company_mix":
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SaleMixReportCompanyPScreen (
                                                schoolId: item.schoolId,
                                              ),
                                            ),
                                          );
                                          break;

                                        case "agent_discount":
                                          print("Agent Discount Details");
                                          break;

                                        case "edit":
                                          print("Edit Invoice");
                                          break;

                                        case "add_product":
                                          print("Add Product");
                                          break;

                                        case "ledger":
                                          print("Discount Ledger");
                                          break;



                                      }
                                    },

                                    itemBuilder: (context) => [

                                      const PopupMenuItem(
                                        value: "mrp",
                                        child: Text("View MRP Details"),
                                      ),

                                      const PopupMenuItem(
                                        value: "discount",
                                        child: Text("View Discount Details"),
                                      ),

                                      const PopupMenuItem(
                                        value: "agent_discount",
                                        child: Text("View Agent Discount Details"),
                                      ),

                                      const PopupMenuItem(
                                        value: "edit",
                                        child: Text("Edit Invoice Sale"),
                                      ),

                                      const PopupMenuItem(
                                        value: "add_product",
                                        child: Text("Add New Product"),
                                      ),

                                      const PopupMenuItem(
                                        value: "MRP_ledger",
                                        child: Text("View MRP Ledger"),
                                      ),

                                      const PopupMenuItem(
                                        value: "Discount",
                                        child: Text("Sale Ledger Discount"),
                                      ),

                                      const PopupMenuItem(
                                        value: "mix",
                                        child: Text("View Sale MixReport"),
                                      ),

                                      const PopupMenuItem(
                                        value: "pending_mix",
                                        child: Text("View Sale Pending MixReport"),
                                      ),

                                      const PopupMenuItem(
                                        value: "company_mix",
                                        child: Text("View Sale MixReport Company"),
                                      ),
                                    ],

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