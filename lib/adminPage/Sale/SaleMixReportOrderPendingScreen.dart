import 'package:flutter/material.dart';
import '/Model/sale_pending_mix_order_model.dart';
import '/service/sale_pending_mix_order_service.dart';
import 'package:share_plus/share_plus.dart';
import '/pdf/salePdf/sale_pending_mix_pdf.dart';

class SalePendingMixOrderScreen extends StatefulWidget {
  final String schoolId;

  const SalePendingMixOrderScreen({super.key, required this.schoolId});

  @override
  State<SalePendingMixOrderScreen> createState() =>
      _SalePendingMixOrderScreenState();
}

class _SalePendingMixOrderScreenState
    extends State<SalePendingMixOrderScreen> {
  late Future<SalePendingMixOrderModel> future;

  @override
  void initState() {
    super.initState();
    future = SalePendingMixOrderService.fetchReport(widget.schoolId);
  }
  Future<void> shareReport(SalePendingMixOrderModel data) async {
    final file = await SalePendingMixPdf.generate(data);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Sale Pending Mix Report",
    );
  }

  // ================= COMMON =================

  Widget th(String text) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text,
        textAlign: TextAlign.center,
        style:
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
  );

  Widget td(String text,
      {TextAlign align = TextAlign.center,
        FontWeight weight = FontWeight.normal}) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: align,
            style: TextStyle(fontSize: 12, fontWeight: weight)),
      );

  // ================= GROUP =================

  Map<String, List<SalePendingItem>> groupData(List<SalePendingItem> list) {
    final map = <String, List<SalePendingItem>>{};
    for (var item in list) {
      final key = "${item.series}|${item.publication}";
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width > 800
        ? MediaQuery.of(context).size.width - 32
        : 1100;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Sale Pending Mix"),
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
      body: FutureBuilder<SalePendingMixOrderModel>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final grouped = groupData(data.data);

          int srNo = 1; // ✅ GLOBAL SR NO

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 LEFT SIDE ICON
                      Column(
                        children: const [
                          Icon(Icons.menu_book, size: 45, color: Colors.brown),
                          SizedBox(height: 5),
                          Text(
                            "BOOK WORLD",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      /// 🔹 CENTER CONTENT
                      Expanded(
                        child: Column(
                          children: const [
                            Text(
                              "GJ BOOK WORLD PVT. LTD.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2B4C7E),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                            SizedBox(height: 6),

                          ],
                        ),
                      ),
                      const SizedBox(width: 40),

                      // ================= HEADER =================
                      const Center(


                        child: Text(
                          "Sale and Order Pending Mix Report",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(child: Text(data.schoolName)),
                      const SizedBox(height: 20),

                      // ================= TABLE =================
                      Table(
                        border: TableBorder.all(color: Colors.black87),
                        columnWidths: const {
                          0: FlexColumnWidth(4),
                          1: FixedColumnWidth(100),
                          2: FixedColumnWidth(80),
                          3: FixedColumnWidth(80),
                          4: FixedColumnWidth(100),
                        },
                        children: [
                          /// HEADER
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey.shade200),
                            children: [
                              th("Book Name"),
                              th("TotalOrder"),
                              th("Sale"),
                              th("Pending"),
                              th("Rate"),
                            ],
                          ),

                          ...grouped.entries.expand((entry) {
                            final parts = entry.key.split("|");
                            final series = parts[0];
                            final pub = parts[1];
                            final items = entry.value;

                            int subOrder = 0;
                            int subSale = 0;
                            int subPending = 0;
                            double subRate = 0;

                            List<TableRow> rows = [];

                            /// ✅ FULL WIDTH SERIES HEADER
                            rows.add(
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      "Series: $series   |   Publication: $pub",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B4C7E),
                                      ),
                                    ),
                                  ),
                                  ...List.generate(4, (_) => const SizedBox()),
                                ],
                              ),
                            );

                            /// DATA ROWS
                            for (var e in items) {
                              int pendingVal =
                                  int.tryParse(e.pending.replaceAll("+", "")) ?? 0;

                              subOrder += e.totalOrder;
                              subSale += e.sale;
                              subPending += pendingVal;
                              subRate += e.rate;

                              rows.add(
                                TableRow(
                                  children: [
                                    td(e.bookName, align: TextAlign.left),
                                    td(e.totalOrder.toString()),
                                    td(e.sale.toString()),
                                    td(e.pending),
                                    td(e.rate.toStringAsFixed(2)),
                                  ],
                                ),
                              );
                            }

                            /// SUBTOTAL ROW
                            rows.add(
                              TableRow(
                                decoration: BoxDecoration(color: Colors.orange.shade50),
                                children: [
                                  td("Subtotal:",
                                      align: TextAlign.right, weight: FontWeight.bold),
                                  td(subOrder.toString(), weight: FontWeight.bold),
                                  td(subSale.toString(), weight: FontWeight.bold),
                                  td("+$subPending", weight: FontWeight.bold),
                                  td(subRate.toStringAsFixed(2), weight: FontWeight.bold),
                                ],
                              ),
                            );

                            return rows;
                          }),

                          /// GRAND TOTAL
                          TableRow(
                            decoration: BoxDecoration(color: Colors.green.shade100),
                            children: [
                              td("Grand Total:",
                                  align: TextAlign.right, weight: FontWeight.bold),
                              td(data.summary.totalOrder.toString(),
                                  weight: FontWeight.bold),
                              td(data.summary.totalSale.toString(),
                                  weight: FontWeight.bold),
                              td(data.summary.totalPending.toString(),
                                  weight: FontWeight.bold),
                              td(data.summary.totalRate.toStringAsFixed(2),
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
      ),
    );
  }
}