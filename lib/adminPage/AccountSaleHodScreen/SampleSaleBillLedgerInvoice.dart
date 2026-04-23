import 'package:flutter/material.dart';
import '../../pdf/salePdf/sample_sale_bill_ledger_pdf.dart';
import '/Model/sample_sale_bill_ledger_model.dart';
import '/Service/sample_sale_bill_ledger_service.dart';

class SampleSaleBillLedgerInvoice extends StatefulWidget {
  final String schoolName;

  const SampleSaleBillLedgerInvoice({super.key, required this.schoolName});

  @override
  State<SampleSaleBillLedgerInvoice> createState() =>
      _SampleSaleBillLedgerInvoiceState();
}

class _SampleSaleBillLedgerInvoiceState extends State<SampleSaleBillLedgerInvoice> {
  SampleSaleLedgerResponse? ledger;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLedger();
  }

  void loadLedger() async {
    final res = await SampleSaleLedgerService.fetchLedger(widget.schoolName);

    setState(() {
      ledger = res;
      isLoading = false;
    });
  }

  String formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year}";
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text("Ledger Statement"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (ledger != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                SampleSaleBillLedgerPdf.generateAndShare(ledger!);
              },
            )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ledger == null
          ? const Center(child: Text("No Data Found"))
          : Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 👉 HORIZONTAL
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // 👉 VERTICAL
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    width: 1100,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// 🔴 HEADER
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo
                                SizedBox(
                                  width: 120,
                                  child: Column(
                                    children: [
                                      const Icon(Icons.menu_book, size: 50, color: Color(0xFF3E2723)),
                                      const Text("GJ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF3E2723))),
                                      const Text("BOOK WORLD", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text(
                                        "GJ BOOK WORLD PVT. LTD.",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF333333),
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      const Text(
                                        "D-1/20, SECTOR 22, GIDA, GORAKHPUR",
                                        style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "Cont. - 0551-2320642",
                                        style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "GST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                                        style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 120), // Balance logo space
                              ],
                            ),
                            
                            const SizedBox(height: 15),
                            const Divider(color: Colors.black, thickness: 1.5),
                            const SizedBox(height: 15),

                            /// TITLE
                            const Center(
                              child: Text(
                                "Sale Sample Ladger Statement",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF2B4C7E),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),

                            /// 🟦 PUBLICATION INFO CARD
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(color: Colors.black, fontSize: 13),
                                          children: [
                                            const TextSpan(text: "Publication: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(text: ledger!.school.refName.toUpperCase()),
                                          ]
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, height: 35, color: Colors.black54),
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(color: Colors.black, fontSize: 13),
                                          children: [
                                            const TextSpan(text: "Address: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                            TextSpan(text: ledger!.school.area.toUpperCase()),
                                          ]
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Date
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.black54, width: 1),
                                  right: BorderSide(color: Colors.black54, width: 1),
                                  bottom: BorderSide(color: Colors.black54, width: 1),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black, fontSize: 13),
                                  children: [
                                    const TextSpan(text: "Date: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: formatDate(DateTime.now().toString())),
                                  ]
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            /// 📊 TABLE (MATCHING IMAGE)
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.black54, width: 1),
                                  left: BorderSide(color: Colors.black54, width: 1),
                                  right: BorderSide(color: Colors.black54, width: 1),
                                )
                              ),
                              child: Column(
                                children: [
                                  /// HEADER
                                  _tableRow(
                                    [
                                      _cell("Date", 15, center: true, isBold: true),
                                      _cell("Vch No", 20, center: true, isBold: true),
                                      _cell("Particulars", 40, center: true, isBold: true),
                                      _cell("Debit", 12, center: true, isBold: true),
                                      _cell("Credit", 13, center: true, isBold: true, rightBorder: false),
                                    ],
                                    bgColor: Colors.grey.shade100,
                                  ),

                                  /// DATA
                                  ...ledger!.data.map((e) {
                                    return _tableRow([
                                      _cell(formatDate(e.date), 15, center: true),
                                      _cell(e.type, 20, center: true),
                                      _cell(e.particulars, 40),
                                      _cell(e.debit == 0 ? "" : "₹${e.debit.toStringAsFixed(2)}", 12, center: true),
                                      _cell(e.credit == 0 ? "" : "₹${e.credit.toStringAsFixed(2)}", 13, center: true, rightBorder: false),
                                    ]);
                                  }),

                                  /// TOTAL
                                  _tableRow(
                                    [
                                      _cell("", 15),
                                      _cell("", 20),
                                      _cell("Total :", 40, right: true, isBold: true),
                                      _cell("₹${ledger!.totalDebit.toStringAsFixed(2)}", 12, center: true, isBold: true),
                                      _cell("₹${ledger!.totalCredit.toStringAsFixed(2)}", 13, center: true, isBold: true, rightBorder: false),
                                    ],
                                    bgColor: Colors.grey.shade200,
                                  ),

                                  /// CLOSING BALANCE
                                  _tableRow(
                                    [
                                      _cell("Closing Balance :", 87, right: true, isBold: true),
                                      _cell("₹${ledger!.closingBalance.toStringAsFixed(2)}", 13, center: true, isBold: true, rightBorder: false),
                                    ],
                                    bgColor: Colors.blue.shade50,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 50),

                            /// ✍️ SIGNATURE
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Checked By: ____________________",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF444444)),
                                ),
                                SizedBox(height: 25),
                                Text(
                                  "Approved By: ____________________",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF444444)),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),
      )
    );
  }

  /// 🔹 TABLE ROW
  Widget _tableRow(List<Widget> cells, {Color? bgColor}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: const Border(bottom: BorderSide(color: Colors.black54, width: 1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ),
    );
  }

  /// 🔹 TABLE CELL
  Widget _cell(String text, int flex, {bool right = false, bool center = false, bool isBold = false, bool rightBorder = true}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: rightBorder ? const Border(right: BorderSide(color: Colors.black54, width: 1)) : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        alignment: right ? Alignment.centerRight : (center ? Alignment.center : Alignment.centerLeft),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}