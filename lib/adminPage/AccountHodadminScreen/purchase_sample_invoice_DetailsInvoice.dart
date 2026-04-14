import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '/model/purchase_sample_invoice_model.dart';
import '/service/purchase_sample_invoice_service.dart';
import '/pdf/purchase_sample_invoice_pdf.dart';

class PurchaseSampleInvoiceScreen extends StatefulWidget {
  final String billNo;

  const PurchaseSampleInvoiceScreen({super.key, required this.billNo});

  @override
  State<PurchaseSampleInvoiceScreen> createState() =>
      _PurchaseSampleInvoiceScreenState();
}

class _PurchaseSampleInvoiceScreenState
    extends State<PurchaseSampleInvoiceScreen> {
  late Future<PurchaseSampleInvoiceModel> future;

  @override
  void initState() {
    super.initState();
    future = PurchaseSampleInvoiceService.fetchInvoice(widget.billNo);
  }

  Future<void> shareInvoice(PurchaseSampleInvoiceModel data) async {
    final file = await PurchaseSampleInvoicePdf.generate(data);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Invoice ${data.billNo}",
    );
  }

  // ================= COMMON =================

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
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            TextSpan(text: value, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget invoiceHeader(PurchaseSampleInvoiceModel data) {
    String formattedDate = data.date;
    try {
      if (data.date.contains("T")) {
         final d = DateTime.parse(data.date);
         formattedDate = "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
      }
    } catch(e) {}

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
                  "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638, 9354918644\nGST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
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

        const Text("Sample Purchase Invoice",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: Color(0xFF2B4C7E))),

        const SizedBox(height: 10),

        Table(
          border: TableBorder.all(),
          children: [
            TableRow(children: [
              infoCell("Invoice No: ", data.billNo),
              infoCell("Supplier: ", data.publication),
              infoCell("Bill Date: ", formattedDate),
            ]),
            TableRow(children: [
              infoCell("Supplier Invoice No: ", "1"),
              infoCell("Address: ", "1ST FLOOR VISHAL MARKET COMMERCIAL COMPLEX,WEST MUKHARJINAGAR"),
              infoCell("Rec. Date: ", formattedDate),
            ]),
            TableRow(children: [
              infoCell("Transport: ", "SELF"),
              infoCell("GR No: ", "1"),
              const SizedBox(),
            ]),
          ],
        ),
      ],
    );
  }

  // ================= GROUP =================

  Map<String, List<PurchaseSampleItem>> groupData(List<PurchaseSampleItem> list) {
    final map = <String, List<PurchaseSampleItem>>{};
    for (var item in list) {
      map.putIfAbsent(item.series, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width > 800
        ? MediaQuery.of(context).size.width - 32
        : 1000;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Invoice ${widget.billNo}"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf), 
            onPressed: () async {
              final data = await future;
              await shareInvoice(data);
            },
          ),
        ],
      ),

      body: FutureBuilder<PurchaseSampleInvoiceModel>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final grouped = groupData(data.data);

          int index = 1;
          double totalQty = 0;
          double totalAmount = 0;

          for (var item in data.data) {
            totalQty += item.qty;
            totalAmount += item.totalAmount;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      invoiceHeader(data),
                      const SizedBox(height: 15),

                      /// TABLE
                      Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FlexColumnWidth(4),
                          2: FixedColumnWidth(50),
                          3: FixedColumnWidth(70),
                          4: FixedColumnWidth(90),
                          5: FixedColumnWidth(100),
                        },
                        children: [
                          TableRow(
                            decoration:
                            BoxDecoration(color: Colors.grey.shade200),
                            children: [
                              tableHeader("S.N."),
                              tableHeader("Book Name (Title)"),
                              tableHeader("Qty"),
                              tableHeader("Rate"),
                              tableHeader("Amount"),
                              tableHeader("Amt With Disc."),
                            ],
                          ),

                          ...grouped.entries.expand((entry) {
                            final series = entry.key;
                            final items = entry.value;

                            double subQty = 0;
                            double subAmount = 0;

                            List<TableRow> rows = [
                              TableRow(
                                decoration:
                                BoxDecoration(color: Colors.grey.shade50),
                                children: [
                                  const SizedBox(),
                                  tableCell("Series: $series",
                                      align: TextAlign.left,
                                      weight: FontWeight.bold),
                                  const SizedBox(),
                                  const SizedBox(),
                                  const SizedBox(),
                                  const SizedBox(),
                                ],
                              ),
                            ];

                            for (var e in items) {
                              subQty += e.qty;
                              subAmount += e.totalAmount;

                              rows.add(TableRow(children: [
                                tableCell("${index++}"),
                                tableCell(
                                    "${e.bookName} - ${e.subject} - ${e.classes}",
                                    align: TextAlign.left),
                                tableCell(e.qty.toString()),
                                tableCell(e.rate.toStringAsFixed(2)),
                                tableCell(e.totalAmount.toStringAsFixed(2)),
                                const SizedBox(), 
                              ]));
                            }

                            /// SUBTOTAL
                            rows.add(
                              TableRow(
                                decoration:
                                BoxDecoration(color: Colors.grey.shade50), 
                                children: [
                                  const SizedBox(),
                                  tableCell("Subtotal:",
                                      align: TextAlign.right,
                                      weight: FontWeight.bold),
                                  tableCell(subQty.toString(),
                                      weight: FontWeight.bold),
                                  const SizedBox(),
                                  tableCell("₹ ${subAmount.toStringAsFixed(2)}",
                                      weight: FontWeight.bold),
                                  const SizedBox(),
                                ],
                              ),
                            );

                            /// DISC(%) FOR SERIES
                            rows.add(
                              TableRow(
                                decoration: BoxDecoration(color: Colors.blue.shade50),
                                children: [
                                  const SizedBox(),
                                  tableCell("Dis (0.00)% :",
                                      align: TextAlign.right, weight: FontWeight.bold),
                                  const SizedBox(),
                                  const SizedBox(),
                                  tableCell("₹ 0.0000", weight: FontWeight.bold),
                                  tableCell("₹ ${subAmount.toStringAsFixed(4)}", weight: FontWeight.bold),
                                ],
                              ),
                            );

                            return rows;
                          }),

                          /// GRAND TOTAL
                          TableRow(
                            decoration:
                            BoxDecoration(color: Colors.green.shade100),
                            children: [
                              const SizedBox(),
                              tableCell("Grand Total:",
                                  align: TextAlign.right,
                                  weight: FontWeight.bold),
                              tableCell(totalQty.toString(),
                                  weight: FontWeight.bold),
                              const SizedBox(),
                              tableCell("₹ ${totalAmount.toStringAsFixed(2)}",
                                  weight: FontWeight.bold),
                              const SizedBox(),
                            ],
                          ),

                          /// TOTAL DISCOUNT
                          TableRow(
                            decoration: BoxDecoration(color: Colors.cyan.shade100),
                            children: [
                              const SizedBox(),
                              tableCell("Total Discount:",
                                  align: TextAlign.right, weight: FontWeight.bold),
                              const SizedBox(),
                              const SizedBox(),
                              tableCell("₹ 0.0000", weight: FontWeight.bold),
                              tableCell("₹ ${totalAmount.toStringAsFixed(4)}", weight: FontWeight.bold),
                            ],
                          ),

                        ],
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