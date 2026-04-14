import 'package:flutter/material.dart';
import '/model/purchase_not_for_sale_ledger_model.dart';
import '/service/purchase_not_for_sale_ledger_service.dart';
import 'package:share_plus/share_plus.dart';
import '/pdf/purchase_not_for_sale_ledger_pdf.dart';

class PurchaseNotForSaleLedgerScreen extends StatefulWidget {
  final String publicationId;

  const PurchaseNotForSaleLedgerScreen(
      {super.key, required this.publicationId});

  @override
  State<PurchaseNotForSaleLedgerScreen> createState() =>
      _PurchaseNotForSaleLedgerScreenState();
}

String getBillNoFromType(String type) {
  final parts = type.split(" ");
  return parts.isNotEmpty ? parts.last : "";
}

class _PurchaseNotForSaleLedgerScreenState
    extends State<PurchaseNotForSaleLedgerScreen> {
  late Future<PurchaseNotForSaleLedgerModel> future;

  @override
  void initState() {
    super.initState();
    future =
        PurchaseNotForSaleLedgerService.fetchLedger(widget.publicationId);
  }

  Widget tableHeader(String text) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text,
        textAlign: TextAlign.center,
        style:
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
  );

  Widget tableCell(String text,
      {TextAlign align = TextAlign.center,
        FontWeight weight = FontWeight.normal}) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: align,
            style: TextStyle(fontSize: 12, fontWeight: weight)),
      );

  Widget infoCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: label,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
            TextSpan(text: value, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String formatDate(String date) {
    try {
      if (date.contains("T")) {
        final d = DateTime.parse(date);
        return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
      }

      if (date.contains("-")) {
        final parts = date.split("-");
        if (parts.length == 3) {
          return "${parts[0]}/${parts[1]}/${parts[2]}";
        }
      }

      return date;
    } catch (e) {
      return date;
    }
  }

  Widget invoiceHeader(PurchaseNotForSaleLedgerModel data) {
    final d = DateTime.now();
    String currentDate = "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: const [
                Icon(Icons.menu_book_sharp, size: 45, color: Colors.brown),
                Text("BOOK WORLD",
                    style:
                    TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              children: const [
                Text(
                  "GJ BOOK WORLD PVT. LTD.",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B4C7E)),
                ),
                SizedBox(height: 8),
                Text(
                  "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 0551-2320642\nGST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 2),
        const SizedBox(height: 10),

        const Text("Purchase Ladger Statement",
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              decoration: TextDecoration.underline,
              color: Color(0xFF003366)
            )),

        const SizedBox(height: 10),

        Table(
          border: TableBorder.all(color: Colors.black54),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(0.5),
          },
          children: [
            TableRow(children: [
              infoCell("Publication: ", data.publication.publication),
              infoCell("Address: ", data.publication.address),
              infoCell("GST No: ", data.publication.gstNo.isNotEmpty ? data.publication.gstNo : "0"),
            ]),
          ],
        ),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black54),
              left: BorderSide(color: Colors.black54),
              right: BorderSide(color: Colors.black54),
            ),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Date: $currentDate",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width > 800
        ? MediaQuery.of(context).size.width - 32
        : 1000;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Purchase Ledger Statement"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await future;
              final file = await PurchaseNotForSaleLedgerPdf.generate(data);
              await Share.shareXFiles(
                [XFile(file.path)],
                text: "Ledger ${data.publication.publication}",
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<PurchaseNotForSaleLedgerModel>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      invoiceHeader(data),

                      const SizedBox(height: 15),

                      /// TABLE
                      Table(
                        border: TableBorder.all(color: Colors.black54),
                        columnWidths: const {
                          0: FixedColumnWidth(100),
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(2),
                          3: FixedColumnWidth(100),
                          4: FixedColumnWidth(120),
                        },
                        children: [
                          TableRow(
                            decoration:
                            BoxDecoration(color: Colors.grey.shade200),
                            children: [
                              tableHeader("Date"),
                              tableHeader("Vch No"),
                              tableHeader("Particulars"),
                              tableHeader("Debit"),
                              tableHeader("Credit"),
                            ],
                          ),

                          ...data.data.map((e) {
                            final billNo = getBillNoFromType(e.type);
                            final formattedDate = formatDate(e.date);

                            return TableRow(children: [
                              tableCell(formattedDate),
                              tableCell(e.type),
                              tableCell("Invoice No. $billNo & Dt. $formattedDate"),
                              tableCell(e.debit > 0 ? "₹${e.debit.toStringAsFixed(2)}" : ""),
                              tableCell(e.credit > 0 ? "₹${e.credit.toStringAsFixed(2)}" : ""),
                            ]);
                          }),

                          /// TOTAL
                          TableRow(
                            decoration:
                            BoxDecoration(color: Colors.grey.shade100),
                            children: [
                              const SizedBox(), 
                              const SizedBox(), 
                              tableCell("Total :", weight: FontWeight.bold, align: TextAlign.right),
                              tableCell("₹${data.totals.totalDebit.toStringAsFixed(2)}",
                                  weight: FontWeight.bold),
                              tableCell("₹${data.totals.totalCredit.toStringAsFixed(2)}",
                                  weight: FontWeight.bold),
                            ],
                          ),

                          /// CLOSING
                          TableRow(
                            decoration:
                            BoxDecoration(color: Colors.blue.shade50),
                            children: [
                              const SizedBox(), 
                              const SizedBox(), 
                              tableCell("Closing Balance :", weight: FontWeight.bold, align: TextAlign.right),
                              const SizedBox(),
                              tableCell("₹${data.totals.closingBalance.toStringAsFixed(2)}",
                                  weight: FontWeight.bold),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// FOOTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: const [
                                Text("Checked By: ____________________", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                SizedBox(height: 25),
                                Text("Approved By: ____________________", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                             ]
                           )
                        ],
                      )
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