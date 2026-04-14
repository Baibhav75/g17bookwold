import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../model/purchase_return_not_for_sale_invoice_model.dart';

class PurchaseReturnNotForSaleInvoicePdf {
  static Future<File> generate(
      PurchaseReturnNotForSaleInvoiceModel data) async {
    final pdf = pw.Document();

    /// CALCULATIONS
    double subtotal = 0;
    for (var item in data.data) {
      subtotal += item.totalAmount;
    }

    double discountPercent = 10;
    double totalDiscount = (subtotal * discountPercent) / 100;
    double grandTotal = subtotal - totalDiscount;

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [

              /// 🔥 HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    children: [
                      pw.Text("📚",
                          style: const pw.TextStyle(fontSize: 25)),
                      pw.Text("BOOK WORLD",
                          style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    children: [
                      pw.Text(
                        "GJ BOOK WORLD PVT. LTD.",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        "D-1/20, SECTOR 22, GIDA, GORAKHPUR",
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              /// TITLE
              pw.Text("Purchase Return Invoice",
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 10),

              /// INFO
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(children: [
                    _cell("Invoice No: ${data.billNo}"),
                    _cell("Date: ${data.date.split('T')[0]}"),
                  ]),
                  pw.TableRow(children: [
                    _cell("Supplier: ${data.publication}"),
                    _cell(""),
                  ]),
                ],
              ),

              pw.SizedBox(height: 10),

              /// TABLE
              pw.Table(
                border: pw.TableBorder.all(),
                children: [

                  /// HEADER
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300),
                    children: [
                      _cell("S.N.", isHeader: true),
                      _cell("Book Name", isHeader: true),
                      _cell("Qty", isHeader: true),
                      _cell("Rate", isHeader: true),
                      _cell("Amount", isHeader: true),
                    ],
                  ),

                  /// DATA
                  ...data.data.asMap().entries.map((entry) {
                    final i = entry.key + 1;
                    final e = entry.value;

                    return pw.TableRow(children: [
                      _cell("$i"),
                      _cell("${e.bookName} - ${e.subject} - ${e.classes}"),
                      _cell("${e.qty}"),
                      _cell("${e.rate.toStringAsFixed(2)}"),
                      _cell("${e.totalAmount.toStringAsFixed(2)}"),
                    ]);
                  }),

                  /// TOTAL
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.red100),
                    children: [
                      _cell(""),
                      _cell("Total", isHeader: true),
                      _cell(""),
                      _cell(""),
                      _cell("₹ ${subtotal.toStringAsFixed(2)}",
                          isHeader: true),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              /// 🔥 SUMMARY
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 200,
                  padding: const pw.EdgeInsets.all(8),
                  decoration:
                  pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Column(
                    children: [
                      _row("Subtotal", subtotal),
                      _row("Disc (%)", discountPercent),
                      _row("Total Discount", totalDiscount),
                      pw.Divider(),
                      _row("Grand Total", grandTotal, isBold: true),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file =
    File("${dir.path}/purchase_return_invoice.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight:
          isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _row(String title, double value,
      {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                fontWeight:
                isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text("₹ ${value.toStringAsFixed(2)}",
            style: pw.TextStyle(
                fontWeight:
                isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }
}