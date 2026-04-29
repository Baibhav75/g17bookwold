import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/Model/sale_return_sample_model.dart';
import '/Service/sale_return_sample_service.dart';
import '/pdf/salePdf/saleSampleReturnDiscount.dart';

class SaleReturnSampleScreen extends StatefulWidget {
  final String billNo;

  const SaleReturnSampleScreen({super.key, required this.billNo});

  @override
  State<SaleReturnSampleScreen> createState() => _SaleReturnSampleScreenState();
}

class _SaleReturnSampleScreenState extends State<SaleReturnSampleScreen> {
  late Future<SaleReturnSampleModel> future;

  @override
  void initState() {
    super.initState();
    future = SaleReturnSampleService.fetchData(widget.billNo);
  }

  Widget tableHeader(String text) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
      );

  Widget tableCell(String text,
          {TextAlign align = TextAlign.center,
          FontWeight weight = FontWeight.normal,
          Color? textColor}) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: align,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: weight,
                color: textColor ?? Colors.black87)),
      );

  String formatDate(String date) {
    try {
      if (date.isEmpty) return "";
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

  Widget invoiceHeader(SaleReturnSampleModel data) {
    String formattedDate = formatDate(data.master.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_sharp, size: 40, color: Colors.brown),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "GJ BOOK WORLD PVT. LTD.",
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2B4C7E)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638, 9354918644\nGST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                    style: GoogleFonts.outfit(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 2),
        Text(
          "Sale Return Sample Invoice",
          style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.black54),
          children: [
            TableRow(children: [
              tableCell("Invoice No: ${data.master.billNo}", align: TextAlign.left),
              tableCell("Party Name: ${data.master.schoolName}", align: TextAlign.left),
              tableCell("Bill Date: $formattedDate", align: TextAlign.left),
            ]),
            TableRow(children: [
              tableCell("Transport: ${data.master.transport.isEmpty ? 'BY HAND' : data.master.transport}", align: TextAlign.left),
              tableCell("Address: ${data.master.address}", align: TextAlign.left),
              tableCell("Remark: ${data.master.remark.isEmpty ? 'SAMPLE' : data.master.remark}", align: TextAlign.left),
            ]),
          ],
        ),
      ],
    );
  }

  List<TableRow> buildSeriesRows(SaleReturnSampleModel data) {
    Map<String, List<Item>> grouped = {};

    for (var item in data.items) {
      grouped.putIfAbsent(item.series, () => []).add(item);
    }

    List<TableRow> rows = [];
    int index = 1;

    grouped.forEach((series, list) {
      String publication = data.master.publication;

      rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            const SizedBox(),
            tableCell("Series: $series", align: TextAlign.left, weight: FontWeight.bold),
            const SizedBox(),
            const SizedBox(),
            const SizedBox(),
            tableCell("Publication: $publication", align: TextAlign.right, weight: FontWeight.bold),
          ],
        ),
      );

      for (var item in list) {
        rows.add(
          TableRow(
            children: [
              tableCell("${index++}"),
              tableCell("${item.bookName} - ${item.classes}", align: TextAlign.left),
              tableCell(item.qty.toString()),
              tableCell("₹ ${item.rate}"),
              tableCell("₹ ${item.total.toStringAsFixed(2)}"),
              tableCell(""),
            ],
          ),
        );
      }

      final summary = data.seriesSummary.firstWhere(
        (s) => s.series == series,
        orElse: () => SeriesSummary(series: series, qty: 0, total: 0),
      );

      rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            const SizedBox(),
            tableCell("Subtotal:", align: TextAlign.right, weight: FontWeight.bold),
            tableCell(summary.qty.toString(), weight: FontWeight.bold),
            const SizedBox(),
            tableCell("₹ ${summary.total.toStringAsFixed(2)}", weight: FontWeight.bold),
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
            tableCell("0.00", align: TextAlign.center),
            const SizedBox(),
            const SizedBox(),
            tableCell("₹ ${summary.total.toStringAsFixed(4)}"),
          ],
        ),
      );
    });

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale Return Sample"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final data = await future;
              generateAndSharePDF(data);
            },
          )
        ],
      ),
      body: FutureBuilder<SaleReturnSampleModel>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No Data Found"));
          }

          final data = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth > 800
                  ? constraints.maxWidth - 32
                  : 1000;

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: width,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
                              ...buildSeriesRows(data),
                              TableRow(
                                decoration:
                                    BoxDecoration(color: Colors.green.shade100),
                                children: [
                                  const SizedBox(),
                                  tableCell("Grand Total:",
                                      align: TextAlign.right,
                                      weight: FontWeight.bold),
                                  tableCell(data.grandQty.toString(),
                                      weight: FontWeight.bold),
                                  const SizedBox(),
                                  tableCell(
                                      "₹ ${data.grandTotal.toStringAsFixed(2)}",
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
                                      align: TextAlign.right,
                                      weight: FontWeight.bold),
                                  tableCell("0.00%", weight: FontWeight.bold),
                                  const SizedBox(),
                                  const SizedBox(),
                                  tableCell(
                                      "₹ ${data.finalAmount.toStringAsFixed(4)}",
                                      weight: FontWeight.bold),
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
          );
        },
      ),
    );
  }
}
