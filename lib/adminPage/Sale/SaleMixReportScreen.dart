import 'package:flutter/material.dart';
import '/Model/sale_mix_report_mrp_model.dart';
import '/Service/sale_mix_report_service.dart';
import 'package:share_plus/share_plus.dart';
import '../pdf/sale_mix_report_pdf.dart';

class SaleMixReportScreen extends StatefulWidget {
  final String schoolId;


  const SaleMixReportScreen({super.key, required this.schoolId});

  @override
  State<SaleMixReportScreen> createState() =>
      _SaleMixReportScreenState();
}
Future<void> shareReport(SaleMixReportMrpModel data) async {
  final file = await SaleMixReportPdf.generate(data);

  await Share.shareXFiles(
    [XFile(file.path)],
    text: "Sale Mix Report",
  );
}

class _SaleMixReportScreenState extends State<SaleMixReportScreen> {
  late Future<SaleMixReportMrpModel?> future;

  @override
  void initState() {
    super.initState();
    future = SaleMixReportService.fetchReport(widget.schoolId);
  }

  // ================= COMMON CELLS =================

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

  Widget tableCell(String text,
      {TextAlign align = TextAlign.center,
        FontWeight weight = FontWeight.normal}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(fontSize: 12, fontWeight: weight),
      ),
    );
  }

  // ================= HEADER =================

  Widget reportHeader(SaleMixReportMrpModel data) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: const [
                Icon(Icons.menu_book, size: 45, color: Colors.brown),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B4C7E)),
                ),
                SizedBox(height: 6),
                Text(
                  "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638",
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

        const Text(
          "Sale Mix Report",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),

        Text(
          data.schoolName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (data.totalDiscount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Total Discount: ₹${data.totalDiscount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
            ),
          ),
      ],
    );
  }

  // ================= GROUP =================

  Map<String, List<SaleMixItem>> groupData(List<SaleMixItem> list) {
    final map = <String, List<SaleMixItem>>{};
    for (var item in list) {
      final key = "${item.series}|${item.publication}";
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  Map<String, dynamic> subtotal(List<SaleMixItem> items) {
    int sale = 0, ret = 0, net = 0;
    double amount = 0, netAmount = 0, discountAmt = 0;

    for (var e in items) {
      sale += e.saleQty;
      ret += e.returnQty;
      net += e.netQty;
      amount += e.amount;
      netAmount += e.netAmount;
      discountAmt += (e.amount - e.netAmount);
    }

    return {
      "sale": sale,
      "ret": ret,
      "net": net,
      "amount": amount,
      "netAmount": netAmount,
      "discountAmt": discountAmt,
    };
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double width = screenWidth > 800 ? screenWidth - 32 : 1000;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Sale Mix Report"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await future;
              if (data != null) {
                await shareReport(data);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<SaleMixReportMrpModel?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No Data Found"));
          }

          final data = snapshot.data!;
          final grouped = groupData(data.data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reportHeader(data),
                      const SizedBox(height: 20),

                      // ================= TABLE =================
                      Table(
                        border: TableBorder.all(color: Colors.black87),
                        columnWidths: const {
                          0: FlexColumnWidth(4),
                          1: FixedColumnWidth(60),
                          2: FixedColumnWidth(60),
                          3: FixedColumnWidth(60),
                          4: FixedColumnWidth(90),
                          5: FixedColumnWidth(100),
                          6: FixedColumnWidth(80),
                          7: FixedColumnWidth(110),
                        },
                        children: [
                          TableRow(
                            decoration:
                            BoxDecoration(color: Colors.grey.shade200),
                            children: [
                              tableHeader("Book Name"),
                              tableHeader("Sale"),
                              tableHeader("Return"),
                              tableHeader("Net"),
                              tableHeader("Rate"),
                              tableHeader("Amount"),
                              tableHeader("Disc%"),
                              tableHeader("Net Amt"),
                            ],
                          ),

                          ...grouped.entries.expand((entry) {
                            final parts = entry.key.split("|");
                            final series = parts[0];
                            final publication = parts[1];
                            final items = entry.value;

                            final sub = subtotal(items);

                            List<TableRow> rows = [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade50),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      "Series: $series   |   Publication: $publication",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B4C7E),
                                      ),
                                    ),
                                  ),
                                  ...List.generate(7, (_) => const SizedBox()),
                                ],
                              ),
                            ];

                            for (var e in items) {
                              rows.add(
                                TableRow(
                                  children: [
                                    tableCell(e.bookName,
                                        align: TextAlign.left),
                                    tableCell(e.saleQty.toString()),
                                    tableCell(e.returnQty.toString()),
                                    tableCell(e.netQty.toString()),
                                    tableCell(
                                        e.rate.toStringAsFixed(2)),
                                    tableCell(
                                        e.amount.toStringAsFixed(2)),
                                    tableCell(
                                      e.discount > 0 
                                          ? "${e.discount.toStringAsFixed(2)}%" 
                                          : (e.amount > e.netAmount 
                                              ? "${(((e.amount - e.netAmount) / e.amount) * 100).toStringAsFixed(2)}%" 
                                              : "-"),
                                    ),
                                    tableCell(
                                        e.netAmount.toStringAsFixed(2)),
                                  ],
                                ),
                              );
                            }

                            // subtotal row
                            rows.add(
                              TableRow(
                                decoration: BoxDecoration(
                                    color: Colors.orange.shade50),
                                children: [
                                  tableCell("Subtotal",
                                      align: TextAlign.right,
                                      weight: FontWeight.bold),
                                  tableCell(sub["sale"].toString(),
                                      weight: FontWeight.bold),
                                  tableCell(sub["ret"].toString(),
                                      weight: FontWeight.bold),
                                  tableCell(sub["net"].toString(),
                                      weight: FontWeight.bold),
                                  const SizedBox(), // Rate
                                  tableCell(
                                      sub["amount"].toStringAsFixed(2),
                                      weight: FontWeight.bold),
                                  tableCell(
                                    sub["amount"] > 0
                                        ? (((sub["amount"] - sub["netAmount"]) / sub["amount"]) * 100).toStringAsFixed(2) + "%"
                                        : "0%",
                                    weight: FontWeight.bold,
                                  ),
                                  tableCell(
                                      sub["netAmount"].toStringAsFixed(2),
                                      weight: FontWeight.bold),
                                ],
                              ),
                            );

                            return rows;
                          }),

                          // GRAND TOTAL
                          TableRow(
                            decoration: BoxDecoration(
                                color: Colors.green.shade100),
                            children: [
                              tableCell("Grand Total",
                                  align: TextAlign.right,
                                  weight: FontWeight.bold),
                              tableCell(data.totalSaleQty.toString(),
                                  weight: FontWeight.bold),
                              tableCell(data.totalReturnQty.toString(),
                                  weight: FontWeight.bold),
                              tableCell((data.totalSaleQty - data.totalReturnQty).toString(),
                                  weight: FontWeight.bold),
                              const SizedBox(), // Rate
                              tableCell(
                                  data.totalAmount.toStringAsFixed(2),
                                  weight: FontWeight.bold),
                              tableCell(
                                  data.totalAmount > 0
                                      ? (((data.totalAmount - data.totalNetAmount) / data.totalAmount) * 100).toStringAsFixed(2) + "%"
                                      : "0%",
                                  weight: FontWeight.bold),
                              tableCell(
                                  data.totalNetAmount.toStringAsFixed(2),
                                  weight: FontWeight.bold),
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