import 'package:bookworld/adminPage/Sale/sale_details_mrp_screen.dart';
import 'package:bookworld/adminPage/Sale/sale_invoice_details_screen.dart';
import 'package:flutter/material.dart';
import '../SellReturn/sale_return_mrp_invoice_screenInvoice.dart';
import '/Model/sale_view_mrp_ledger_model.dart';
import '/Service/sale_view_mrp_ledger_service.dart';
import 'package:share_plus/share_plus.dart';
import '/pdf/salePdf/sale_ledger_pdf.dart';

class SaleViewMRPLedgerScreen extends StatefulWidget {
  final String schoolId;

  const SaleViewMRPLedgerScreen({super.key, required this.schoolId});

  @override
  State<SaleViewMRPLedgerScreen> createState() =>
      _SaleViewMRPLedgerScreenState();
}
Future<void> shareLedger(SaleViewMRPLedgerResponse data) async {
  final file = await SaleLedgerPdf.generate(data);


  await Share.shareXFiles(
    [XFile(file.path)],
    text: "Sale Ledger Report",
  );
}

class _SaleViewMRPLedgerScreenState
    extends State<SaleViewMRPLedgerScreen> {

  late Future<SaleViewMRPLedgerResponse?> future;

  @override
  void initState() {
    super.initState();
    future = SaleViewMRPLedgerService.fetchLedger(widget.schoolId);
  }

  Widget cell(String text, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black,
        ),
      ),
    );
  }

  String formatDate(String raw) {
    final dt = DateTime.parse(raw);
    return "${dt.day}/${dt.month}/${dt.year}";
  }
  String date = ""; // example

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Ledger"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await future;
              if (data != null) {
                await shareLedger(data);
              }
            },
          ),
        ],
      ),

      body: FutureBuilder<SaleViewMRPLedgerResponse?>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          /// ✅ YAHI ADD KARO (IMPORTANT)
          final debitCount =
              data.ledger.where((e) => e.debit > 0).length;

          final creditCount =
              data.ledger.where((e) => e.credit > 0).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            /// 🔥 VERTICAL SCROLL
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 🔥 HORIZONTAL SCROLL

              child: SizedBox(
                width: 900, // 🔥 FIX WIDTH (important)

                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.grey.withOpacity(0.2),
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: const [
                              Icon(Icons.menu_book_sharp,
                                  size: 45, color: Colors.brown),
                              Text(
                                "BOOK WORLD",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: const [
                              Text(
                                "GJ BOOK WORLD PVT. LTD.",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "GIDA GORAKHPUR\nCont: 7905891950",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Divider(),

                      const SizedBox(height: 10),

                      /// TITLE
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "MRP ",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: "Sale Ledger Statement",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔥 SCHOOL INFO
                      Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(children: [
                            cell("School: ${data.schoolName}"),
                            cell("Address: ${data.address}"),
                          ]),
                        ],
                      ),

// 👇 DATE (CENTER PERFECT)
                      const SizedBox(height: 6),

                      Center(
                        child: Text(
                          "Date: $date",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔥 TABLE HEADER
                      Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration:
                            const BoxDecoration(color: Colors.grey),
                            children: [
                              cell("Date", bold: true),
                              cell("Particulars", bold: true),
                              cell("Debit", bold: true),
                              cell("Credit", bold: true),
                              cell("Balance", bold: true),
                            ],
                          ),
                        ],
                      ),

                      /// 🔥 DATA
                      Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1),
                        },
                        children: [

                          /// 🔥 DATA ROWS
                          ...data.ledger.map((e) {
                            final isOpening =
                            e.particulars.toLowerCase().contains("opening");

                            final isReceipt =
                            e.particulars.toLowerCase().contains("receipt");

                            return TableRow(
                              decoration: BoxDecoration(
                                color: isOpening ? Colors.green.shade100 : null,
                              ),
                              children: [
                                cell(
                                  isOpening ? "" : formatDate(e.date),
                                ),

                                GestureDetector(
                                  onTap: isReceipt
                                      ? null // ❌ click disable
                                      : () {
                                    final billNo = e.particulars
                                        .replaceAll(RegExp(r'[^0-9]'), '');
                                    final formattedDate = formatDate(e.date);

                                    if (e.particulars.toLowerCase().contains("return")) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SaleReturnMrpInvoiceScreen(
                                            billNo: billNo,
                                            date: formattedDate,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SaleInvoiceDetailsScreen(
                                            billNo: billNo,
                                            date: formattedDate,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: cell(
                                    e.particulars,
                                    bold: true,
                                    color: isOpening
                                        ? Colors.green.shade900
                                        : e.particulars.toLowerCase().contains("receipt")
                                        ? Colors.black
                                        : Colors.blue,
                                  ),
                                ),

                                cell(
                                  (e.debit == null || e.debit == 0)
                                      ? ""
                                      : "₹ ${e.debit}",
                                ),

                                cell(
                                  (e.credit == null || e.credit == 0)
                                      ? ""
                                      : "₹ ${e.credit}",
                                ),
                                cell("₹ ${e.balance}"),
                              ],
                            );
                          }).toList(),


                          /// 🔥 TOTAL ROW (Same Line Alignment)
                          TableRow(
                            decoration: const BoxDecoration(color: Colors.black12),
                            children: [
                              cell(""),
                              cell("Total :", bold: true),

                              cell("₹ ${data.totalDebit}"),
                              cell("₹ ${data.totalCredit}"),
                              cell(""),
                            ],
                          ),

                          /// 🔥 CLOSING BALANCE
                          TableRow(
                            children: [
                              cell(""),
                              cell("Closing Balance :", bold: true),
                              cell(""),
                              cell(""),
                              cell("₹ ${data.closingBalance}", bold: true),
                            ],
                          ),
                        ],
                      ),


                       SizedBox(height: 30),

                      /// FOOTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Checked By: __________"),
                          Text("Approved By: __________"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}