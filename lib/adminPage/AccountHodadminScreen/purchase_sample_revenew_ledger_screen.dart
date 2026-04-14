import 'package:flutter/material.dart';
import '/model/purchase_sample_revenew_ledger_model.dart';
import '/service/purchase_sample_revenew_ledger_service.dart';

import 'package:share_plus/share_plus.dart';
import '/pdf/purchase_sample_revenew_ledger_pdf.dart';

class PurchaseSampleRevenewLedgerScreen extends StatefulWidget {
  final String publicationId;

  const PurchaseSampleRevenewLedgerScreen(
      {super.key, required this.publicationId});

  @override
  State<PurchaseSampleRevenewLedgerScreen> createState() =>
      _PurchaseSampleRevenewLedgerScreenState();
}

class _PurchaseSampleRevenewLedgerScreenState
    extends State<PurchaseSampleRevenewLedgerScreen> {
  late Future<PurchaseSampleRevenewLedgerModel> future;

  @override
  void initState() {
    super.initState();
    future = PurchaseSampleRevenewLedgerService.fetchLedger(widget.publicationId);
  }

  Widget cell(String text,
      {FontWeight weight = FontWeight.normal,
        TextAlign align = TextAlign.center}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(text,
          textAlign: align,
          style: TextStyle(fontSize: 12, fontWeight: weight)),
    );
  }

  String formatDate(String date) {
    final parts = date.split("-");
    return "${parts[0]}/${parts[1]}/${parts[2]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sample Ledger"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await future;

              final file =
              await PurchaseSampleRevenewLedgerPdf.generate(data);

              await Share.shareXFiles(
                [XFile(file.path)],
                text: "Sample Ledger ${data.publication.publication}",
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<PurchaseSampleRevenewLedgerModel>(
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
                width: 900,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      /// 🔥 HEADER FIXED
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: const [
                              Icon(Icons.menu_book_sharp,
                                  size: 45, color: Colors.brown),
                              Text("BOOK WORLD",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(width: 30),
                          Column(
                            children: [
                              const Text(
                                "GJ BOOK WORLD PVT. LTD.",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2B4C7E)),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "GST No: ${data.publication.gstNo}",
                                style: const TextStyle(fontSize: 12),
                              )


                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Divider(),

                      /// TITLE
                      const Text(
                        "Purchase Sample Ledger",
                        style: TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 10),

                      /// INFO TABLE
                      Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(children: [
                            cell("Publication: ${data.publication.publication}"),
                            cell("GST: ${data.publication.gstNo}"),
                          ]),
                          TableRow(children: [
                            cell("Address: ${data.publication.address}"),
                            cell(""),
                          ]),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// MAIN TABLE
                      Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            decoration:
                            BoxDecoration(color: Colors.grey.shade300),
                            children: [
                              cell("Date", weight: FontWeight.bold),
                              cell("Particulars", weight: FontWeight.bold),
                              cell("Debit", weight: FontWeight.bold),
                              cell("Credit", weight: FontWeight.bold),
                              cell("Balance", weight: FontWeight.bold),
                            ],
                          ),

                          ...data.data.map((e) {
                            return TableRow(children: [
                              cell(formatDate(e.date)),
                              cell(e.type, align: TextAlign.left),
                              cell("₹${e.debit.toStringAsFixed(0)}"),
                              cell("₹${e.credit.toStringAsFixed(0)}"),
                              cell("₹${e.balance.toStringAsFixed(0)}"),
                            ]);
                          }),

                          /// TOTAL
                          TableRow(
                            decoration:
                            BoxDecoration(color: Colors.green.shade100),
                            children: [
                              const SizedBox(),
                              cell("Total", weight: FontWeight.bold),
                              cell("₹${data.totals.totalDebit.toStringAsFixed(0)}"),
                              cell("₹${data.totals.totalCredit.toStringAsFixed(0)}"),
                              const SizedBox(),
                            ],
                          ),

                          /// CLOSING
                          TableRow(
                            decoration:
                            BoxDecoration(color: Colors.blue.shade100),
                            children: [
                              const SizedBox(),

                              cell("Closing Balance", weight: FontWeight.bold),
                              const SizedBox(),
                              const SizedBox(),

                              cell("₹${data.totals.closingBalance.toStringAsFixed(0)}"),
                            ],
                          ),
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