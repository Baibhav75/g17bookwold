import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../appDart/discrete_circular_loader.dart';
import '../Sale/sale_view_mrp_ledger_screen.dart';
import '/Model/NewRecoverBalanceModel.dart';
import '/Service/new_recover_balance_service.dart';

class NewRecoverBalanceScreen extends StatefulWidget {
  const NewRecoverBalanceScreen({super.key});

  @override
  State<NewRecoverBalanceScreen> createState() =>
      _NewRecoverBalanceScreenState();

}

class _NewRecoverBalanceScreenState
    extends State<NewRecoverBalanceScreen> {

  List<NewRecoverBalanceModel> list = [];
  List<NewRecoverBalanceModel> filteredList = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  double totalOpening = 0;
  double totalDebit = 0;
  double totalPayment = 0;
  double totalReturn = 0;
  double finalNet = 0;

  final formatter = NumberFormat('#,##,##0.00');

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    final data = await NewRecoverBalanceService.fetchData(1);

    if (data.isNotEmpty) {
      list = data;
      filteredList = data;
    }

    calculateTotals();

    setState(() => isLoading = false);
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredList = list;
      } else {
        filteredList = list
            .where((item) =>
                item.schoolName.toLowerCase().contains(query.toLowerCase()) ||
                item.agentName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      calculateTotals();
    });
  }

  void calculateTotals() {
    totalOpening = 0;
    totalDebit = 0;
    totalPayment = 0;
    totalReturn = 0;
    finalNet = 0;

    for (var item in filteredList) {
      totalOpening += item.openingBalance;
      totalDebit += item.totalDebit;
      totalPayment += item.totalPayment;
      totalReturn += item.totalReturn;
      finalNet += item.netBalance;
    }
  }


  String format(double value) => "₹ ${formatter.format(value)}";

  Color amountColor(double value, {bool isDebit = false}) {
    if (isDebit) return Colors.red;
    if (value > 0) return Colors.green;
    if (value < 0) return Colors.red;
    return Colors.black;
  }

  Widget cell(String text,
      {double width = 100,
        Color? color,
        bool bold = false,
        TextAlign align = TextAlign.center}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: color ?? Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    double tableWidth =
        50 + 260 + 180 + 130 + 100 + 120 + 120 + 100 + 140;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ACCOUNT WISE OUTSTANDING REPORT"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),


      body: isLoading
          ? const Padding(
        padding: EdgeInsets.all(12),
        child: SchoolLoader(), // ✅ your shimmer loader
      )
      : Column(
        children: [
          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search School or Agent name...",
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
            ),
          ),

          /// 🔥 TABLE
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [

                    /// HEADER
                    Container(
                      color: Colors.blueGrey.shade100,
                      child: Row(
                        children: [
                          cell("Sr No", width: 50, bold: true),
                          cell("School Name", width: 260, bold: true),
                          cell("Agent Name", width: 180, bold: true),
                          cell("Contact No", width: 130, bold: true),
                          cell("Opening", width: 100, bold: true),
                          cell("Total Debit", width: 120, bold: true),
                          cell("Payment", width: 120, bold: true),
                          cell("Return", width: 100, bold: true),
                          cell("Total Balance", width: 140, bold: true),
                        ],
                      ),
                    ),

                    /// BODY + TOTAL
                    Expanded(
                      child: Column(
                        children: [

                          /// LIST
                          Flexible( // ✅ IMPORTANT CHANGE
                            child: ListView.builder(
                              controller: _scrollController, // ✅ ADD THIS LINE
                              itemCount: filteredList.length,

                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SaleViewMRPLedgerScreen(
                                            schoolId: item.schoolId,
                                          ),
                                        ),
                                      );
                                    },

                                  child:  Row(
                                  children: [
                                    cell("${item.srNo}", width: 50),
                                    cell(item.schoolName, width: 260, align: TextAlign.left, color: Colors.blue,
                                      bold: true,),
                                    cell(item.agentName, width: 180),
                                    cell(item.contact, width: 130),
                                    cell(format(item.openingBalance), width: 100),
                                    cell(format(item.totalDebit), width: 120, color: Colors.red),
                                    cell(format(item.totalPayment), width: 120, color: Colors.green),
                                    cell(format(item.totalReturn), width: 100, color: Colors.green),
                                    cell(format(item.netBalance), width: 140),
                                  ],

                                ),
                                );
                              },
                            ),
                          ),

                          /// TOTAL ROW
                          Container(
                            color: Colors.grey.shade200,
                            child: Row(
                              children: [
                                cell("Total", width: 50, bold: true),
                                cell("", width: 260),
                                cell("", width: 180),
                                cell("", width: 130),
                                cell(format(totalOpening), width: 100, bold: true),
                                cell(format(totalDebit), width: 120, color: Colors.red, bold: true),
                                cell(format(totalPayment), width: 120, color: Colors.green, bold: true),
                                cell(format(totalReturn), width: 100, color: Colors.green, bold: true),
                                cell("", width: 140),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 🔥 FINAL NET OUTSTANDING
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.blueGrey.shade700,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Final Net Outstanding",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  format(finalNet),
                  style: TextStyle(
                    color:
                    finalNet >= 0 ? Colors.greenAccent : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: const Icon(Icons.arrow_upward),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            mini: true,
            onPressed: () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}