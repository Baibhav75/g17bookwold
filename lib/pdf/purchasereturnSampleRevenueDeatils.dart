import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '/Model/purchase_return_sample_revenew_details_model.dart';

class PurchaseReturnInvoicePdf {
  static Future<File> generate(
      PurchaseReturnSampleRevenewDetailsModel data) async {

    final pdf = pw.Document();

    /// 🔹 TOTAL QTY (FIXED)
    final int totalQty = data.data.fold<int>(
      0,
          (sum, item) => sum + (item.qty ?? 0).toInt(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [

              /// 🔹 HEADER
              pw.Text(
                "GJ BOOK WORLD PVT. LTD.",
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                "D-1/20, SECTOR 22, GIDA, GORAKHPUR",
                style: const pw.TextStyle(fontSize: 10),
              ),

              pw.Divider(),

              pw.Text(
                "Purchase Return Invoice",
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 10),

              /// 🔹 INFO TABLE
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(children: [
                    _cell("Publication: ${data.publication}"),
                    _cell("Bill No: ${data.billNo}"),
                    _cell("Date: ${data.date}"),
                  ])
                ],
              ),

              pw.SizedBox(height: 20),

              /// 🔹 MAIN TABLE
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(40),
                  3: const pw.FixedColumnWidth(50),
                  4: const pw.FixedColumnWidth(60),
                  5: const pw.FixedColumnWidth(70),
                },
                children: [

                  /// 🔹 HEADER
                  pw.TableRow(
                    decoration:
                    pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _cell("S.N."),
                      _cell("Book Name"),
                      _cell("Qty"),
                      _cell("Rate"),
                      _cell("Amount"),
                      _cell("Amt Disc"),
                    ],
                  ),

                  /// 🔹 SERIES DATA
                  ..._buildSeriesRows(data),

                  /// 🔥 GRAND TOTAL
                  pw.TableRow(
                    decoration:
                    pw.BoxDecoration(color: PdfColors.green100),
                    children: [
                      pw.Container(),
                      _cell("Grand Total"),
                      _cell(totalQty.toString()), // ✅ FIXED
                      pw.Container(),
                      _cell("₹ ${data.grandTotal.toStringAsFixed(2)}"),
                      pw.Container(),
                    ],
                  ),

                  /// 🔥 DISCOUNT
                  pw.TableRow(
                    children: [
                      pw.Container(),
                      _cell("Total Discount"),
                      _cell("0.00%"),
                      pw.Container(),
                      pw.Container(),
                      _cell("₹ ${data.grandTotal.toStringAsFixed(2)}"),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/purchase_invoice.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// 🔹 COMMON CELL
  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  /// 🔹 SERIES GROUPING (FULL FIXED)
  static List<pw.TableRow> _buildSeriesRows(
      PurchaseReturnSampleRevenewDetailsModel data) {

    Map<String, List<dynamic>> grouped = {};

    for (var item in data.data) {
      String series = item.series ?? "Other";
      grouped.putIfAbsent(series, () => []).add(item);
    }

    List<pw.TableRow> rows = [];
    int index = 1;

    grouped.forEach((series, list) {
      double subtotal = 0;
      int totalQty = 0; // ✅ FIXED TYPE

      /// SERIES HEADER
      rows.add(
        pw.TableRow(
          decoration:
          pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Container(),
            _cell("Series: $series"),
            pw.Container(),
            pw.Container(),
            pw.Container(),
            pw.Container(),
          ],
        ),
      );

      /// ITEMS
      for (var item in list) {
        final int qty = (item.qty ?? 0).toInt(); // ✅ FIXED
        final double amount = (item.totalAmount ?? 0).toDouble();

        totalQty += qty;
        subtotal += amount;

        rows.add(
          pw.TableRow(children: [
            _cell("${index++}"),
            _cell(item.bookName),
            _cell(qty.toString()), // ✅ FIXED
            _cell("₹ ${item.rate}"),
            _cell("₹ ${amount.toStringAsFixed(2)}"),
            pw.Container(),
          ]),
        );
      }

      /// SUBTOTAL
      rows.add(
        pw.TableRow(
          decoration:
          pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            pw.Container(),
            _cell("Subtotal"),
            _cell(totalQty.toString()), // ✅ FIXED
            pw.Container(),
            _cell("₹ ${subtotal.toStringAsFixed(2)}"),
            pw.Container(),
          ],
        ),
      );

      /// DISCOUNT
      rows.add(
        pw.TableRow(children: [
          pw.Container(),
          _cell("Disc (%)"),
          _cell("0.00"),
          pw.Container(),
          pw.Container(),
          _cell("₹ ${subtotal.toStringAsFixed(2)}"),
        ]),
      );
    });

    return rows;
  }
}