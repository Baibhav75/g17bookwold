import 'package:bookworld/adminPage/Sale/sale_invoice_details_screen.dart';
import 'package:flutter/material.dart';
import '/Model/SaleLedgerDiscount_model.dart';
import '/Service/SaleLedgerDiscount_service.dart';
import 'sale_details_mrp_screen.dart';
import 'package:share_plus/share_plus.dart';
import '/pdf/salePdf/sale_ledger_discount_pdf.dart';

class SaleLedgerDiscountScreen extends StatefulWidget {
  final String schoolId;

  const SaleLedgerDiscountScreen({super.key, required this.schoolId});

  @override
  State<SaleLedgerDiscountScreen> createState() =>
      _SaleLedgerDiscountScreenState();
}
Future<void> shareLedger(SaleLedgerDiscountResponse data) async {
  final file = await SaleLedgerDiscountPdf.generate(data);

  await Share.shareXFiles(
    [XFile(file.path)],
    text: "Sale Ledger Discount Report",
  );
}

class _SaleLedgerDiscountScreenState extends State<SaleLedgerDiscountScreen> {
  late Future<SaleLedgerDiscountResponse?> future;

  @override
  void initState() {
    super.initState();
    future = SaleLedgerDiscountService.fetchLedger(widget.schoolId);
  }

  String formatDate(String date) {
    if (date.isEmpty) return "";
    try {
      final dt = DateTime.parse(date);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      return date.split("T")[0];
    }
  }

  Widget infoCell(String label, String value, {TextAlign align = TextAlign.center}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        textAlign: align,
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _cell(String text, {bool bold = false, Color? color, TextAlign align = TextAlign.center}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }

  Widget invoiceHeaderMRP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: const [
                Icon(Icons.menu_book_sharp, size: 55, color: Color(0xFF5D4037)), // Brownish
                Text(
                  "BOOK WORLD",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  "GJ BOOK WORLD PVT. LTD.",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.normal, color: Color(0xFF2B4C7E)),
                ),
                SizedBox(height: 14),
                Text(
                  "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 0551-2320642\nGST No: 09AAGCG0650B1Z2| CIN No: U22222UP2015PTC068597",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Divider(color: Colors.black, thickness: 2),
        const SizedBox(height: 15),
        const Text(
          "SALE LEDGER STATEMENT",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B4C7E), decoration: TextDecoration.underline),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double invoiceWidth = screenWidth > 900 ? screenWidth - 32 : 1100;
    
    DateTime now = DateTime.now();
    String todayStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Sale Ledger"),
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
      body: FutureBuilder<SaleLedgerDiscountResponse?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No Data Found"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: invoiceWidth,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      invoiceHeaderMRP(),

                      /// 📌 Publication + Address Box
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.black54), bottom: BorderSide(color: Colors.black54))),
                                    child: infoCell("Publication: ", data.schoolName, align: TextAlign.center),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black54))),
                                    child: infoCell("Address: ", data.address, align: TextAlign.center),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                               padding: const EdgeInsets.symmetric(vertical: 8),
                               width: double.infinity,
                               child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(text: "Date: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                                    TextSpan(text: todayStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                               ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15),

                      /// 📊 Ledger Table
                      Table(
                        border: TableBorder.all(color: Colors.black54),
                          columnWidths: const {
                            0: FlexColumnWidth(1.2),
                            1: FlexColumnWidth(4),
                            2: FlexColumnWidth(1.2),
                            3: FlexColumnWidth(1.2),
                            4: FlexColumnWidth(1.5),
                          },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey.shade100),
                            children: [
                              _tableHeaderCell("Date"),
                              _tableHeaderCell("Particulars"),
                              _tableHeaderCell("Debit"),
                              _tableHeaderCell("Credit"),
                              _tableHeaderCell("Balance"),
                            ],
                          ),

                          /// DATA
                          ...data.ledger.map((e) {
                            return TableRow(
                              children: [
                                _cell(e.type == "Opening" ? "" : formatDate(e.date)),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SaleInvoiceDetailsScreen(
                                          billNo: e.particulars.replaceAll(RegExp(r'[^0-9]'), ''),
                                          date: formatDate(e.date),
                                        ),
                                      ),
                                    );
                                  },
                                  child: _cell(
                                    e.particulars,
                                    color: Colors.blue,
                                    align: TextAlign.center,
                                  ),
                                ),

                                _cell("₹${e.debit.toStringAsFixed(2)}", align: TextAlign.right),
                                _cell(e.credit == 0 ? "" : "₹${e.credit.toStringAsFixed(2)}", align: TextAlign.right),
                                _cell("₹${e.balance.toStringAsFixed(2)}", align: TextAlign.right, bold: true),
                              ],
                            );
                          }),

                          /// TOTAL
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey.shade100),
                            children: [
                              _cell(""),
                              _cell("Total :", align: TextAlign.right, bold: true),
                              _cell("₹${data.totalDebit}", align: TextAlign.right, bold: true),
                              _cell("₹${data.totalCredit}", align: TextAlign.right, bold: true),
                              _cell(""),
                            ],
                          ),

                          /// CLOSING BALANCE
                          TableRow(
                            decoration: BoxDecoration(color: Colors.blue.shade50),
                            children: [
                              _cell(""),
                              _cell("Closing Balance :", align: TextAlign.right, bold: true),
                              _cell(""),
                              _cell(""),

                              _cell("₹${data.closingBalance}", align: TextAlign.right, bold: true),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),

                      const Text(
                        "Checked By: ___________________________",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Approved By: ___________________________",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
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