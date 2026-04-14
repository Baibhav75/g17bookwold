import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '/Model/sale_invoice_details_model.dart';

class SaleInvoicePdf {
  static Future<File> generate(SaleInvoiceDetailsResponse data) async {
    final pdf = pw.Document();

    String formatDate(String date) {
      try {
        return DateTime.parse(date).toLocal().toString().split(' ')[0];
      } catch (e) {
        return "";
      }
    }

    /// 🔹 GROUPING (Same as UI)
    Map<String, List<SaleInvoiceItem>> groupedItems = {};
    for (var item in data.items) {
      groupedItems.putIfAbsent(item.publication, () => []).add(item);
    }

    double totalQty = 0;
    double totalAmount = 0;

    for (var item in data.items) {
      totalQty += item.qty;
      totalAmount += item.amount;
    }

    int index = 1;

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [

          /// 🔷 HEADER (UI MATCH)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Column(
                children: [
                  pw.Text(
                    "GJ\nBOOK WORLD",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                ],
              ),

              pw.Text(
                "GJ BOOK WORLD PVT. LTD.",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF2B4C7E),
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638, 9354918644\nGST No: 09AAGCG0650B1Z2",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 8),
              ),

              pw.SizedBox(height: 8),
              pw.Divider(),

              pw.Text(
                "Sale Invoice",
                style: pw.TextStyle(fontSize: 14),
              ),

              pw.SizedBox(height: 10),

              /// 🔹 INFO TABLE
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  row3("Invoice No", data.billNo,
                      "Party Name", data.schoolName,
                      "Bill Date", formatDate(data.billDate)),

                  row3("Transport", data.transport.isNotEmpty ? data.transport : "SELF",
                      "Address", data.address,
                      "Rec Date", formatDate(data.receiveDate)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          /// 🔷 MAIN TABLE
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(4),
              2: const pw.FixedColumnWidth(40),
              3: const pw.FixedColumnWidth(50),
              4: const pw.FixedColumnWidth(60),
              5: const pw.FixedColumnWidth(70),
            },
            children: [

              /// HEADER
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  cell("S.N.", bold: true),
                  cell("Book Name (Title)", bold: true),
                  cell("Qty", bold: true),
                  cell("Rate", bold: true),
                  cell("Amount", bold: true),
                  cell("Net Amt.", bold: true),
                ],
              ),

              /// 🔹 GROUP DATA (Publication wise)
              ...groupedItems.entries.expand((entry) {
                String publication = entry.key;
                List<SaleInvoiceItem> group = entry.value;

                double groupQty = 0;
                double groupAmount = 0;

                List<pw.TableRow> rows = [];

                /// PUBLICATION HEADER
                rows.add(
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      cell(""),
                      cell(""),
                      cell(""),
                      cell(""),
                      cell(""),
                      cell("Publication: $publication", bold: true),
                    ],
                  ),
                );

                for (var item in group) {
                  groupQty += item.qty;
                  groupAmount += item.amount;

                  rows.add(
                    pw.TableRow(
                      children: [
                        cell("Rs{index++}"),
                        cell("Rs{item.bookName} - ${item.subject} - ${item.classes}"),
                        cell(item.qty.toStringAsFixed(0)),
                        cell(item.rate.toStringAsFixed(2)),
                        cell(item.amount.toStringAsFixed(2)),
                        cell(item.netAmount.toStringAsFixed(2)),
                      ],
                    ),
                  );
                }

                return rows;
              }),

              /// 🔹 SUBTOTAL
              pw.TableRow(
                children: [
                  cell(""),
                  cell("Subtotal", bold: true),
                  cell(totalQty.toStringAsFixed(0), bold: true),
                  cell(""),
                  cell("Rs ${totalAmount.toStringAsFixed(2)}", bold: true),
                  cell(""),
                ],
              ),

              /// 🔹 DISCOUNT
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.blue100),
                children: [
                  cell(""),
                  cell("Discount", bold: true),
                  cell(""),
                  cell(""),
                  cell(""),
                  cell("Rs ${data.grandDiscount.toStringAsFixed(2)}", bold: true),
                ],
              ),

              /// 🔹 GRAND TOTAL
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.green100),
                children: [
                  cell(""),
                  cell("Grand Total", bold: true),
                  cell(totalQty.toStringAsFixed(0), bold: true),
                  cell(""),
                  cell(""),
                  cell("Rs ${data.grandTotal.toStringAsFixed(2)}", bold: true),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          /// 🔹 FOOTER
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Prepared By: Admin",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("Authorised Signatory",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),

          pw.SizedBox(height: 5),
          pw.Text("Time Taken: 1 min 23 sec"),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/sale_invoice_${data.billNo}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// 🔹 CELL
  static pw.Widget cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// 🔹 INFO ROW
  static pw.TableRow row3(
      String l1, String v1,
      String l2, String v2,
      String l3, String v3,
      ) {
    return pw.TableRow(
      children: [
        cell("$l1: $v1"),
        cell("$l2: $v2"),
        cell("$l3: $v3"),
      ],
    );
  }
}