import 'package:flutter/material.dart';
import '/Model/purchase_return_sample_revenew_details_model.dart';
import '/Service/purchase_return_sample_revenew_details_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '/pdf/purchasereturnSampleRevenueDeatils.dart'; // ✅ your pdf file
import 'package:cross_file/cross_file.dart';

class PurchaseReturnNotForSaleInvoiceScreen extends StatefulWidget {
  final String billNo;

  const PurchaseReturnNotForSaleInvoiceScreen({
    super.key,
    required this.billNo,
  });

  @override
  State<PurchaseReturnNotForSaleInvoiceScreen> createState() =>
      _PurchaseReturnNotForSaleInvoiceScreenState();
}

class _PurchaseReturnNotForSaleInvoiceScreenState
    extends State<PurchaseReturnNotForSaleInvoiceScreen> {

  late Future<PurchaseReturnSampleRevenewDetailsModel?> future;

  @override
  void initState() {
    super.initState();
    future =  PurchaseReturnService.fetchInvoice(widget.billNo);
  }

  Widget tableHeader(String text) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 13)),
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
      final d = DateTime.parse(date);
      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return date;
    }
  }

  Widget invoiceHeader(PurchaseReturnSampleRevenewDetailsModel data) {
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
                    "D-1/20, SECTOR 22, GIDA, GORAKHPUR",
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
          "Purchase Return Invoice",
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
              tableCell("Publication: ${data.publication}", align: TextAlign.left),
              tableCell("Bill No: ${data.billNo}", align: TextAlign.left),
              tableCell("Date: ${formatDate(data.date)}", align: TextAlign.left),
            ])
          ],
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
      appBar: AppBar(
        title: const Text("Invoice"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              try {
                final data = await future;

                if (data == null) return;

                final file =
                await PurchaseReturnInvoicePdf.generate(data);

                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: "Invoice ${data.billNo}",
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
      body: FutureBuilder<PurchaseReturnSampleRevenewDetailsModel?>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final totalQty = data.data.fold(
            0,
                (sum, item) => sum + (item.qty ?? 0).toInt(),
          );

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

                      /// 🔹 HEADER
                      invoiceHeader(data),

                      const SizedBox(height: 20),

                      /// 🔹 TABLE
                      Table(
                        border: TableBorder.all(color: Colors.black54),
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FlexColumnWidth(3),
                          2: FixedColumnWidth(60),
                          3: FixedColumnWidth(80),
                          4: FixedColumnWidth(100),
                          5: FixedColumnWidth(120),
                        },
                        children: [
                          /// 🔹 HEADER
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey.shade300),
                            children: [
                              tableHeader("S.N."),
                              tableHeader("Book Name (Title)"),
                              tableHeader("Qty"),
                              tableHeader("Rate"),
                              tableHeader("Amount"),
                              tableHeader("Amt With Disc."),
                            ],
                          ),

                          /// 🔹 DATA WITH SERIES GROUPING
                          ...buildSeriesRows(data.data),

                          /// 🔥 GRAND TOTAL
                          TableRow(
                            decoration: BoxDecoration(color: Colors.green.shade100),
                            children: [
                              const SizedBox(),
                              tableCell("Grand Total:", align: TextAlign.right, weight: FontWeight.bold),
                              tableCell(totalQty.toString(), weight: FontWeight.bold), // ✅ FIXED
                              const SizedBox(),
                              tableCell("₹ ${data.grandTotal.toStringAsFixed(2)}",
                                  weight: FontWeight.bold),
                              const SizedBox(),
                            ],
                          ),

                          /// 🔥 TOTAL DISCOUNT ROW
                          TableRow(
                            children: [
                              const SizedBox(),
                              tableCell("Total Discount:", align: TextAlign.right),
                              tableCell("0.00%"),
                              const SizedBox(),
                              const SizedBox(),
                              tableCell("₹ ${data.grandTotal.toStringAsFixed(4)}"),
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
  List<TableRow> buildSeriesRows(List items) {
    Map<String, List<dynamic>> grouped = {};

    // 🔹 GROUP BY SERIES
    for (var item in items) {
      String series = item.series ?? "Other";
      grouped.putIfAbsent(series, () => []).add(item);
    }

    List<TableRow> rows = [];
    int index = 1;

    grouped.forEach((series, list) {
      double subtotal = 0;
      double totalQty = 0;

      /// 🔹 SERIES HEADER
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

      /// 🔹 ITEMS
      for (var item in list) {
        final qty = item.qty ?? 0;
        final amount = item.totalAmount ?? 0;

        totalQty += qty;          // ✅ qty sum
        subtotal += amount;       // ✅ amount sum (FIXED)

        rows.add(
          TableRow(
            children: [
              tableCell("${index++}"),
              tableCell(item.bookName, align: TextAlign.left),
              tableCell(qty.toString()),
              tableCell("₹ ${item.rate}"),
              tableCell("₹ ${amount.toStringAsFixed(2)}"),
              tableCell(""),
            ],
          ),
        );
      }

      /// 🔹 SUBTOTAL (FIXED)
      rows.add(
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            const SizedBox(),
            tableCell("Subtotal:", align: TextAlign.right, weight: FontWeight.bold),
            tableCell(totalQty.toString(), weight: FontWeight.bold),
            const SizedBox(),
            tableCell("₹ ${subtotal.toStringAsFixed(2)}",
                weight: FontWeight.bold),
            const SizedBox(),
          ],
        ),
      );

      /// 🔹 DISCOUNT (optional)
      rows.add(
        TableRow(
          children: [
            const SizedBox(),
            tableCell("Disc(%):", align: TextAlign.right),
            tableCell("0.00"),
            const SizedBox(),
            const SizedBox(),
            tableCell("₹ ${subtotal.toStringAsFixed(2)}"),
          ],
        ),
      );
    });

    return rows;
  }

}