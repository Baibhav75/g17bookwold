import 'package:flutter/material.dart';
import '/model/sale_return_mrp_invoice_model.dart';
import '/service/sale_return_mrp_invoice_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '/pdf/sale_return_mrp_invoice_pdf.dart';

class SaleReturnMrpInvoiceScreen extends StatefulWidget {
  final String billNo;

  const SaleReturnMrpInvoiceScreen({super.key, required this.billNo});

  @override
  State<SaleReturnMrpInvoiceScreen> createState() =>
      _SaleReturnMrpInvoiceScreenState();
}

class _SaleReturnMrpInvoiceScreenState
    extends State<SaleReturnMrpInvoiceScreen> {
  late Future<SaleReturnMrpInvoiceModel> future;

  @override
  void initState() {
    super.initState();
    future = SaleReturnMrpInvoiceService.fetchInvoice(widget.billNo);
  }

  Widget tableHeader(String text) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      );

  Widget tableCell(String text,
          {TextAlign align = TextAlign.center,
          FontWeight weight = FontWeight.normal}) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: align,
            style: TextStyle(fontSize: 13, fontWeight: weight)),
      );

  String formatDate(String date) {
    try {
      if (date.contains("T")) {
        final d = DateTime.parse(date);
        return "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
      }
      final d = DateTime.parse(date);
      return "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
    } catch (_) {
      return date;
    }
  }

  Widget invoiceHeader(SaleReturnMrpInvoiceModel data) {
    String formattedDate = formatDate(data.master.date);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_sharp, size: 40, color: Colors.brown),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "GJ BOOK WORLD PVT. LTD.",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B4C7E)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638, 9354918644\nGST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 2),
        const Text(
          "Sale Return Invoice",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.black54),
          children: [
            TableRow(children: [
              tableCell("Invoice No: ${data.master.billNo}",
                  align: TextAlign.left),
              tableCell("Party Name: ${data.master.schoolName}",
                  align: TextAlign.left),
              tableCell("Bill Date: $formattedDate", align: TextAlign.left),
            ]),
            TableRow(children: [
              tableCell("Transport: ${data.master.transport}",
                  align: TextAlign.left),
              tableCell("Address: ${data.master.address}", align: TextAlign.left),
              tableCell("Rec. Date: $formattedDate", align: TextAlign.left),
            ]),
            TableRow(children: [
              tableCell(""),
              tableCell("Remark:", align: TextAlign.left),
              tableCell(""),
            ])
          ],
        ),
      ],
    );
  }

  List<TableRow> buildSeriesRows(List<SaleReturnItem> items) {
    Map<String, List<SaleReturnItem>> grouped = {};

    for (var item in items) {
      String series = item.series;
      grouped.putIfAbsent(series, () => []).add(item);
    }

    List<TableRow> rows = [];
    int index = 1;

    grouped.forEach((series, list) {
      double subtotalQty = 0;
      double subtotalAmount = 0;
      double subtotalAmountWithDisc = 0;
      
      double seriesDiscount = list.isNotEmpty ? list.first.discount : 0;

      rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            const SizedBox(),
            tableCell("Series: $series",
                align: TextAlign.left, weight: FontWeight.bold),
            const SizedBox(),
            const SizedBox(),
            const SizedBox(),
            const SizedBox(),
          ],
        ),
      );

      for (var item in list) {
        subtotalQty += item.qty;
        subtotalAmount += item.totalAmount;
        
        double itemDiscAmount = (item.totalAmount * item.discount) / 100;
        double itemAmountWithDisc = item.totalAmount - itemDiscAmount;
        subtotalAmountWithDisc += itemAmountWithDisc;

        rows.add(
          TableRow(
            children: [
              tableCell("${index++}"),
              tableCell("${item.bookName} - ${item.subject} - ${item.classes}",
                  align: TextAlign.left),
              tableCell(item.qty.toString()),
              tableCell("₹ ${item.rate}"),
              tableCell("₹ ${item.totalAmount.toStringAsFixed(2)}"),
              tableCell(""), 
            ],
          ),
        );
      }

      rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            const SizedBox(),
            tableCell("Subtotal:",
                align: TextAlign.right, weight: FontWeight.bold),
            tableCell(subtotalQty.toString(), weight: FontWeight.bold),
            const SizedBox(),
            tableCell("₹ ${subtotalAmount.toStringAsFixed(2)}",
                weight: FontWeight.bold),
            const SizedBox(),
          ],
        ),
      );

      rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.blue.shade50),
          children: [
            const SizedBox(),
            tableCell("Disc(%):", align: TextAlign.right),
            tableCell("${seriesDiscount.toStringAsFixed(2)}%"),
            const SizedBox(),
            const SizedBox(),
            tableCell("₹ ${subtotalAmountWithDisc.toStringAsFixed(2)}"),
          ],
        ),
      );
    });

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width > 800
        ? MediaQuery.of(context).size.width - 32
        : 1000;

    return Scaffold(
      appBar: AppBar(
        title: Text("MRP Return Invoice ${widget.billNo}"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              try {
                final data = await future;
                final file = await SaleReturnMrpInvoicePdf.generate(data);
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: "Sale Return Invoice ${data.master.billNo}",
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<SaleReturnMrpInvoiceModel>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          double totalQty = 0;
          double totalAmount = 0;
          double totalDiscAmount = 0;
          double totalAmtWithDisc = 0;

          for (var item in data.items) {
            totalQty += item.qty;
            totalAmount += item.totalAmount;
            double discAmt = (item.totalAmount * item.discount) / 100;
            totalDiscAmount += discAmt;
            totalAmtWithDisc += (item.totalAmount - discAmt);
          }
          
          double finalDiscountPct = totalAmount > 0 ? (totalDiscAmount / totalAmount * 100) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      invoiceHeader(data),
                      const SizedBox(height: 20),
                      Table(
                        border: TableBorder.all(color: Colors.black54),
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FlexColumnWidth(4),
                          2: FixedColumnWidth(60),
                          3: FixedColumnWidth(80),
                          4: FixedColumnWidth(100),
                          5: FixedColumnWidth(120),
                        },
                        children: [
                          TableRow(
                            decoration:
                                BoxDecoration(color: Colors.grey.shade300),
                            children: [
                              tableHeader("S.N."),
                              tableHeader("Book Name (Title)"),
                              tableHeader("Qty"),
                              tableHeader("Rate"),
                              tableHeader("Amount"),
                              tableHeader("Amt With Disc."),
                            ],
                          ),
                          ...buildSeriesRows(data.items),
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
                              tableCell(
                                  "₹ ${totalAmount.toStringAsFixed(2)}",
                                  weight: FontWeight.bold),
                              const SizedBox(),
                            ],
                          ),
                          TableRow(
                            decoration:
                                BoxDecoration(color: Colors.cyan.shade100),
                            children: [
                              const SizedBox(),
                              tableCell("Total Discount:",
                                  align: TextAlign.right),
                              tableCell("${finalDiscountPct.toStringAsFixed(2)}%"),
                              const SizedBox(),
                              const SizedBox(),
                              tableCell(
                                  "₹ ${totalAmtWithDisc.toStringAsFixed(4)}"),
                            ],
                          ),
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
