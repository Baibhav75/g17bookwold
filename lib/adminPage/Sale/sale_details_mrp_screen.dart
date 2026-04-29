import 'package:flutter/material.dart';
import '/Model/sale_details_mrp_model.dart';
import '/Service/sale_details_mrp_service.dart';
import 'package:share_plus/share_plus.dart';
import '/pdf/salePdf/sale_mrp_invoice_pdf.dart';

class SaleDetailsMrpScreen extends StatefulWidget {
  final String billNo;
  final String? date;

  const SaleDetailsMrpScreen({super.key, required this.billNo, this.date});

  @override
  State<SaleDetailsMrpScreen> createState() =>
      _SaleDetailsMrpScreenState();
}
Future<void> shareInvoice(SaleDetailsMrpResponse data) async {
  final file = await SaleMrpInvoicePdf.generate(data);

  await Share.shareXFiles(
    [XFile(file.path)],
    text: "Invoice ${data.billNo}",
  );
}

class _SaleDetailsMrpScreenState extends State<SaleDetailsMrpScreen> {
  late Future<SaleDetailsMrpResponse?> future;

  @override
  void initState() {
    super.initState();
    future = SaleDetailsMrpService.fetchDetails(widget.billNo);
  }

  Widget infoCell(String label, String value, {TextAlign align = TextAlign.center}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        textAlign: align,
      ),
    );
  }

  Widget tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget tableCell(String text, {TextAlign align = TextAlign.center, FontWeight weight = FontWeight.normal}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(fontSize: 12, fontWeight: weight),
      ),
    );
  }

  Widget invoiceHeaderMRP(SaleDetailsMrpResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: const [
                Icon(Icons.menu_book_sharp, size: 45, color: Colors.brown),
                Text(
                  "BOOK WORLD",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  "GJ BOOK WORLD PVT. LTD.",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B4C7E)),
                ),
                SizedBox(height: 8),
                Text(
                  "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638, 9354918644\nGST No: 09AAGCG0650B1Z2| CIN No: U22222UP2015PTC068597",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(color: Colors.black, thickness: 2),
        const SizedBox(height: 10),
        const Text(
          "SAlE MRP INVOICE",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: Color(0xFF2B4C7E)),
        ),
        const SizedBox(height: 15),
        Table(
          border: TableBorder.all(color: Colors.black87),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(children: [
              infoCell("Invoice No: ", data.billNo),
              infoCell("Party Name: ", data.schoolName),
              infoCell("Bill Date: ", widget.date ?? (data.billDate.isNotEmpty ? data.billDate.toString().split("T")[0] : "")),
            ]),
            TableRow(children: [
              infoCell("Transport: ", "SELF"),
              infoCell("Address: ", ""),
              infoCell("Rec. Date: ", widget.date ?? (data.billDate.isNotEmpty ? data.billDate.toString().split("T")[0] : "")),
            ]),
            TableRow(children: [
               const SizedBox(),
               infoCell("Remark: ", ""),
               const SizedBox(),
            ]),
            TableRow(children: [
               infoCell("Vehicle No: ", ""),
               infoCell("Vehicle Driver Name: ", ""),
               infoCell("Vehicle Driver Mo No: ", ""),
            ]),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double invoiceWidth = screenWidth > 800 ? screenWidth - 32 : 1000;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("MRP Invoice ${widget.billNo}"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await future;
              if (data != null) {
                await shareInvoice(data);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<SaleDetailsMrpResponse?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No Data Found"));
          }
          final data = snapshot.data!;

          Map<String, List<SaleDetailsMrpItem>> groupedItems = {};
          for (var item in data.items) {
            String key = "${item.series}|${item.publication}";
            if (!groupedItems.containsKey(key)) {
              groupedItems[key] = [];
            }
            groupedItems[key]!.add(item);
          }

          int index = 1;
          double totalQty = 0;
          double totalAmount = 0;

          for (var item in data.items) {
            totalQty += item.qty;
            totalAmount += item.totalAmount;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: invoiceWidth,
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                      invoiceHeaderMRP(data),
                      const SizedBox(height: 15),
                      Table(
                        border: TableBorder.all(color: Colors.black87),
                        columnWidths: const {
                          0: FixedColumnWidth(50),
                          1: FlexColumnWidth(4),
                          2: FixedColumnWidth(60),
                          3: FixedColumnWidth(80),
                          4: FixedColumnWidth(100),
                          5: FixedColumnWidth(120),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey.shade200),
                            children: [
                              tableHeader("S.N."),

                              tableHeader("Book Name (Title)"),
                              tableHeader("Qty"),
                              tableHeader("Rate"),
                              tableHeader("Amount"),
                              tableHeader("Amt With Disc."),
                            ],
                          ),
                          ...groupedItems.entries.expand((entry) {
                            String series = entry.key.split('|')[0];
                            String publication = entry.key.split('|')[1];
                            List<SaleDetailsMrpItem> group = entry.value;

                            double groupQty = 0;
                            double groupAmount = 0;
                            double groupDiscAmount = 0;

                            List<TableRow> rows = [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade50),
                                children: [
                                  const SizedBox(),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      "Series: $series",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF2B4C7E),
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  const SizedBox(),
                                  const SizedBox(),
                                  const SizedBox(),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      "Publication: $publication",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF2B4C7E),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ];

                            for (var item in group) {
                              double amtWithDisc = item.totalAmount; // change if discount field exists

                              groupQty += item.qty;
                              groupAmount += item.totalAmount;
                              groupDiscAmount += amtWithDisc;

                              rows.add(
                                TableRow(
                                  children: [
                                    tableCell("${index++}"),
                                    tableCell(
                                      "${item.bookName} - ${item.subject} - ${item.classes}",
                                      align: TextAlign.left,
                                    ),
                                    tableCell(item.qty.toStringAsFixed(0)),
                                    tableCell(item.rate.toStringAsFixed(2)),
                                    tableCell(item.totalAmount.toStringAsFixed(2)),
                                    tableCell(amtWithDisc.toStringAsFixed(2)),
                                  ],
                                ),
                              );
                            }




                            return rows;
                          }),

                          TableRow(
                            children: [
                              const SizedBox(),
                              tableCell("Subtotal:", align: TextAlign.right, weight: FontWeight.bold),
                              tableCell(totalQty.toStringAsFixed(0), weight: FontWeight.bold),
                              const SizedBox(),
                              tableCell("₹ ${totalAmount.toStringAsFixed(2)}", weight: FontWeight.bold),
                              const SizedBox(),
                            ],
                          ),

                          TableRow(
                            decoration: BoxDecoration(color: Colors.blue.shade50),
                            children: [
                              const SizedBox(),
                              tableCell("Disc(%) :", align: TextAlign.right, weight: FontWeight.bold),
                              tableCell("0.00", weight: FontWeight.bold),
                              const SizedBox(),
                              const SizedBox(),
                              tableCell("₹ ${totalAmount.toStringAsFixed(4)}", weight: FontWeight.bold),
                            ],
                          ),

                          TableRow(
                            decoration: BoxDecoration(color: Colors.green.shade100),
                            children: [
                              const SizedBox(),
                              tableCell("Grand Total:", align: TextAlign.right, weight: FontWeight.bold),
                              tableCell(totalQty.toStringAsFixed(0), weight: FontWeight.bold),
                              const SizedBox(),
                              tableCell("₹ ${data.grandTotal.toStringAsFixed(2)}", weight: FontWeight.bold),
                              const SizedBox(),
                            ],
                          ),

                          TableRow(
                            decoration: BoxDecoration(color: Colors.cyan.shade50),
                            children: [
                              const SizedBox(),
                              tableCell("Total Discount:", align: TextAlign.right, weight: FontWeight.bold),
                              tableCell("0.00%", weight: FontWeight.bold),
                              const SizedBox(),
                              const SizedBox(),
                              tableCell("₹ ${data.grandTotal.toStringAsFixed(4)}", weight: FontWeight.bold),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Text("Invoice Created By: Admin", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Hardcoded time taken placeholder
                      const Text("Time Taken: 1 min 23 sec", style: TextStyle(fontWeight: FontWeight.bold)),
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
