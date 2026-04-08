import 'package:bookworld/adminPage/AccountHodadminScreen/GetMixReportPubDiscPage.dart';
import 'package:flutter/material.dart';

import '../AccountHodadminScreen/PubchaseEnterInvoice.dart';
import '../AccountHodadminScreen/PurchaseMixReportScreen.dart';
import '../AccountHodadminScreen/ViewCompanyDiscountScreen.dart';
import '../PurchaseReturn/PurchaseViewMrpLedger.dart';
import '/Model/purchase_history_model.dart';
import '/Service/purchase_history_service.dart';
import 'PurchaseMrpDestails.dart';
import '/adminPage/AccountHodadminScreen/ViewPurchaseDiscountInvoiceScreen.dart';

class SalePurchaseInvoiceHistory extends StatefulWidget {
  const SalePurchaseInvoiceHistory({super.key});

  @override
  State<SalePurchaseInvoiceHistory> createState() =>
      _SalePurchaseInvoicePageState();
}

class _SalePurchaseInvoicePageState
    extends State<SalePurchaseInvoiceHistory> {

  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  bool isSearching = false;

  PurchaseHistoryModel? model;
  List<PurchaseData> filteredList = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();

    /// 🔍 focus listener
    searchFocus.addListener(() {
      setState(() {
        isSearching = searchFocus.hasFocus;
      });
    });
  }

  double get totalAmount {
    double total = 0;
    for (var item in filteredList) {
      total += item.totalAmount;
    }
    return total;
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  loadData() async {
    model = await PurchaseHistoryService.fetchPurchaseHistory();
    filteredList = model!.data;

    setState(() {
      loading = false;
    });
  }

  /// SEARCH FILTER
  void filterData(String query) {
    final result = model!.data.where((item) {
      final billNo = item.billNo.toLowerCase();
      final groups = item.groups.toLowerCase();
      final searchLower = query.toLowerCase();

      return billNo.contains(searchLower) ||
          groups.contains(searchLower);
    }).toList();

    setState(() {
      filteredList = result;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Purchase History"),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: "View List",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PurchaseInvoiceEntry(), // 👈 create this screen
                ),
              );
            },
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [

          /// MAIN UI
          Column(
            children: [

              /// 🔍 SEARCH + TOTAL
              Padding(
                padding: const EdgeInsets.all(12),

                child: Row(
                  children: [

                    /// SEARCH
                    Expanded(
                      flex: isSearching ? 5 : 3,
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocus,
                        onChanged: filterData,
                        decoration: InputDecoration(
                          hintText: "Search BillNo or Groups",
                          prefixIcon: const Icon(Icons.search),

                          /// ❌ clear button
                          suffixIcon: isSearching
                              ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              filterData("");
                              searchFocus.unfocus();
                            },
                          )
                              : null,

                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    /// TOTAL BOX
                    if (!isSearching) ...[
                      const SizedBox(width: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.deepPurple),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Amount",
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              "₹ ${totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              /// 📊 TABLE
              Expanded(
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalController,

                    child: Scrollbar(
                      controller: _horizontalController,
                      thumbVisibility: true,
                      notificationPredicate:
                          (notif) => notif.depth == 1,

                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,

                        child: DataTable(
                          columnSpacing: 25,
                          headingRowColor:
                          MaterialStateProperty.all(
                              Colors.deepPurple.shade50),

                          columns: const [
                            DataColumn(label: Text("SrNo")),
                            DataColumn(label: Text("BillNo")),
                            DataColumn(label: Text("Publication")),
                            DataColumn(label: Text("Date")),
                            DataColumn(label: Text("Groups")),
                            DataColumn(label: Text("GRNO")),
                            DataColumn(label: Text("BOX")),
                            DataColumn(label: Text("Amount")),
                            DataColumn(label: Text("View")),
                          ],

                          rows: filteredList.map((e) {
                            return DataRow(cells: [

                              DataCell(Text(e.srNo.toString())),
                              DataCell(Text(e.billNo)),

                              DataCell(
                                SizedBox(
                                  width: 200,
                                  child: Text(e.publication),
                                ),
                              ),

                              DataCell(
                                  Text(e.date.split("T")[0])),

                              DataCell(Text(e.groups)),

                              DataCell(Text(e.grno ?? "-")),

                              DataCell(Text(e.box ?? "-")),

                              DataCell(
                                Text(
                                    "₹ ${e.totalAmount.toStringAsFixed(2)}"),
                              ),

                              DataCell(
                                PopupMenuButton<String>(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.visibility, color: Colors.blue, size: 18),
                                      SizedBox(width: 5),
                                      Text(
                                        "View",
                                        style: TextStyle(color: Colors.blue, fontSize: 12),
                                      ),
                                    ],
                                  ),

                                  onSelected: (value) {
                                    switch (value) {
                                      case 'view_mrp_invoice':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PurchaseInvoicePage(
                                              billNo: e.billNo.toString(),
                                            ),
                                          ),
                                        );
                                        break;

                                      case 'edit_invoice':
                                        print("Edit Invoice");
                                        break;

                                      case 'add_product':
                                        print("Add Product");
                                        break;

                                      case 'view_image':
                                        print("View Image");
                                        break;

                                      case 'company_discount':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ViewCompanyDiscountScreen(
                                              billNo: e.billNo.toString(),
                                            ),
                                          ),
                                        );
                                        break;

                                      case 'publication_discount':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PurchaseDetailsDiscountInvoiceScreen(
                                              billNo: e.billNo.toString(),
                                            ),
                                          ),
                                        );

                                      case 'only_mrp':
                                        print("Only MRP");
                                        break;

                                      case 'mix_report':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PurchaseMixReportScreen (
                                              publicationId:e.publicationId,
                                            ),
                                          ),
                                        );
                                        break;

                                      case 'stock_register':
                                        print("Stock Register");
                                        break;

                                      case 'mix_pub_disc':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => GetMixReportPubDiscPage(
                                              publicationId: e. publicationId.toString(),
                                            ),
                                          ),
                                        );
                                        break;

                                      case 'mrp_ledger':
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>  PurchaseMrpLedgerScreen(
                                              publicationId: e. publicationId.toString(),
                                            ),

                                          ),
                                        );
                                        break;

                                      case 'company_ledger':
                                        print("Company Ledger");
                                        break;

                                      case 'publication_ledger':
                                        print("Publication Ledger");
                                        break;
                                    }
                                  },

                                  itemBuilder: (context) => [
                                    _menuItem("View MRP Invoice", "view_mrp_invoice"),
                                    _menuItem("Edit Invoice", "edit_invoice"),
                                    _menuItem("Add New Product In Invoice", "add_product"),
                                    _menuItem("View Invoice Image", "view_image"),
                                    _menuItem("View Company Discount Invoice", "company_discount"),
                                    _menuItem("View Publication Discount Invoice", "publication_discount"),
                                    _menuItem("View Only MRP Invoice", "only_mrp"),
                                    _menuItem("View MixReport", "mix_report"),
                                    _menuItem("View Stock Register", "stock_register"),
                                    _menuItem("View MixReport PubDisc", "mix_pub_disc"),
                                    _menuItem("View MRP Ledger", "mrp_ledger"),
                                    _menuItem("View Company Discount Ledger", "company_ledger"),
                                    _menuItem("View Publication Discount Ledger", "publication_ledger"),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// 🔼 TOP BUTTON
          Positioned(
            top: 80,
            right: 10,
            child: _scrollBtn(
              icon: Icons.arrow_upward,
              onTap: () {
                _verticalController.animateTo(
                  0,
                  duration:
                  const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
            ),
          ),

          /// 🔽 BOTTOM BUTTON
          Positioned(
            bottom: 20,
            right: 10,
            child: _scrollBtn(
              icon: Icons.arrow_downward,
              onTap: () {
                _verticalController.animateTo(
                  _verticalController
                      .position.maxScrollExtent,
                  duration:
                  const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 SCROLL BUTTON
  Widget _scrollBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 4,
      color: Colors.deepPurple,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Text(text),
    );
  }
}