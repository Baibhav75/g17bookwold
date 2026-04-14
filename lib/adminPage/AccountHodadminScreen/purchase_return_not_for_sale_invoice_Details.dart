import 'package:flutter/material.dart';
import '/model/purchase_return_not_for_sale_invoice_model.dart';
import '/service/purchase_return_not_for_sale_invoice_service.dart';
import 'package:share_plus/share_plus.dart';
import '/pdf/purchase_return_not_for_sale_invoice_pdf.dart';

class PurchaseReturnNotForSaleInvoiceScreen extends StatefulWidget {
  final String billNo;

  const PurchaseReturnNotForSaleInvoiceScreen(
      {super.key, required this.billNo});

  @override
  State<PurchaseReturnNotForSaleInvoiceScreen> createState() =>
      _PurchaseReturnNotForSaleInvoiceScreenState();
}

class _PurchaseReturnNotForSaleInvoiceScreenState
    extends State<PurchaseReturnNotForSaleInvoiceScreen> {
  late Future<PurchaseReturnNotForSaleInvoiceModel> future;

  @override
  void initState() {
    super.initState();
    future =
        PurchaseReturnNotForSaleInvoiceService.fetchInvoice(widget.billNo);
  }

  Map<String, List<PurchaseReturnItem>> groupData(List<PurchaseReturnItem> list) {
    final map = <String, List<PurchaseReturnItem>>{};
    for (var item in list) {
      map.putIfAbsent(item.series, () => []).add(item);
    }
    return map;
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
    final d = DateTime.parse(date);
    return "${d.day}/${d.month}/${d.year}";
  }

  Widget _row(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight:
                  isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchase Return Invoice"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await future;

              final file =
              await PurchaseReturnNotForSaleInvoicePdf.generate(data);

              await Share.shareXFiles(
                [XFile(file.path)],
                text: "Purchase Return Invoice ${data.billNo}",
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<PurchaseReturnNotForSaleInvoiceModel>(
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
          double subtotal = 0;


          for (var item in data.data) {
            subtotal += item.totalAmount;
            totalQty += item.qty;
          }

// 👉 Example discount (you can make dynamic later)
          double discountPercent = 10; // change as needed

          double totalDiscount = (subtotal * discountPercent) / 100;
          double grandTotal = subtotal - totalDiscount;


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

                      /// 🔥 HEADER
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
                            children: const [
                              Text(
                                "GJ BOOK WORLD PVT. LTD.",
                                style: TextStyle(
                                    fontSize: 20,
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
                      const Divider(),

                      const Text("Purchase Return Invoice",
                          style: TextStyle(fontSize: 16)),

                      const Divider(),

                      /// 🔹 INFO TABLE
                      Table(
                        border: TableBorder.all(),
                        children: [
                          /// HEADER
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey.shade300),
                            children: [
                              cell("S.N.", weight: FontWeight.bold),
                              cell("Book Name", weight: FontWeight.bold),
                              cell("Qty", weight: FontWeight.bold),
                              cell("Rate", weight: FontWeight.bold),
                              cell("Amount", weight: FontWeight.bold),
                            ],
                          ),

                          /// DATA
                          ...grouped.entries.expand((entry) {
                            final items = entry.value;

                            List<TableRow> rows = [];

                            rows.add(
                              TableRow(children: [
                                const SizedBox(),
                                cell("Series: ${entry.key}",
                                    align: TextAlign.left,
                                    weight: FontWeight.bold),
                                const SizedBox(),
                                const SizedBox(),
                                const SizedBox(),
                              ]),
                            );

                            for (var e in items) {
                              rows.add(TableRow(children: [
                                cell("${index++}"),
                                cell("${e.bookName} - ${e.subject} - ${e.classes}",
                                    align: TextAlign.left),
                                cell(e.qty.toString()),
                                cell(e.rate.toStringAsFixed(2)),
                                cell(e.totalAmount.toStringAsFixed(2)),
                              ]));
                            }

                            return rows;
                          }),

                          /// 🔥 SUBTOTAL
                          TableRow(
                            children: [
                              const SizedBox(),
                              cell("Subtotal",
                                  align: TextAlign.right, weight: FontWeight.bold),
                              const SizedBox(),

                              cell("₹ ${subtotal.toStringAsFixed(2)}",
                                  weight: FontWeight.bold),
                              const SizedBox(),
                            ],
                          ),

                          /// 🔥 DISCOUNT %
                          TableRow(
                            children: [
                              const SizedBox(),
                              cell("Disc (%)", align: TextAlign.right),
                              const SizedBox(),
                              const SizedBox(),
                              cell("${discountPercent.toStringAsFixed(0)} %"),
                            ],
                          ),

                          /// 🔥 TOTAL DISCOUNT
                          TableRow(
                            children: [
                              const SizedBox(),
                              cell("Total Discount", align: TextAlign.right),
                              const SizedBox(),

                              cell("₹ ${totalDiscount.toStringAsFixed(2)}"),
                              const SizedBox(),
                            ],
                          ),

                          /// 🔥 GRAND TOTAL
                          TableRow(
                            decoration: BoxDecoration(color: Colors.red.shade100),
                            children: [
                              const SizedBox(),
                              cell("Grand Total",
                                  align: TextAlign.right,
                                  weight: FontWeight.bold),
                              const SizedBox(),
                              const SizedBox(),
                              cell("₹ ${grandTotal.toStringAsFixed(2)}",
                                  weight: FontWeight.bold),
                            ],
                          ),
                        ],
                      ),


                      /// 🔥 SUMMARY (OUTSIDE TABLE ✅)

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