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
  bool isLoading = true;

  double totalOpening = 0;
  double totalDebit = 0;
  double totalPayment = 0;
  double totalReturn = 0;
  double finalNet = 0;

  final formatter = NumberFormat('#,##,##0.00');

  ScrollController _scrollController = ScrollController();

  int page = 1;
  bool isFetchingMore = false;
  bool hasMore = true;
  @override
  void initState() {
    super.initState();
    loadData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {

        if (hasMore) {
          loadData(isLoadMore: true); // ✅ lazy load trigger
        }
      }
    });
  }

  Future<void> loadData({bool isLoadMore = false}) async {

    if (isLoadMore == false) {
      isLoading = true;
      setState(() {});
    }

    final data = await NewRecoverBalanceService.fetchData(page);

    if (data.isNotEmpty) {
      if (isLoadMore) {
        list.addAll(data);
      } else {
        list = data;
      }

      page++; // next page
    } else {
      hasMore = false;
    }

    calculateTotals();

    setState(() {
      isLoading = false; // ✅ correct
    });
  }
  void calculateTotals() {
    totalOpening = 0;
    totalDebit = 0;
    totalPayment = 0;
    totalReturn = 0;
    finalNet = 0;

    for (var item in list) {
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
                              itemCount: list.length + (hasMore ? 1 : 0), // ✅ CHANGE THIS LINE

                              itemBuilder: (context, index) {

                                /// 🔥 ADD THIS BLOCK HERE (TOP of itemBuilder)
                                if (index == list.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final item = list[index];
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
    );
  }
}