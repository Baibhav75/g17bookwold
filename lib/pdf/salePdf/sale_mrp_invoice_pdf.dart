import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '/Model/sale_details_mrp_model.dart';

class SaleMrpInvoicePdf {
  static Future<File> generate(SaleDetailsMrpResponse data) async {
    final pdf = pw.Document();

    String formatDate(String date) {
      try {
        return DateTime.parse(date).toLocal().toString().split(' ')[0];
      } catch (e) {
        return "";
      }
    }

    /// GROUPING SAME AS UI
    Map<String, List<SaleDetailsMrpItem>> groupedItems = {};
    for (var item in data.items) {
      String key = "${item.series}|${item.publication}";
      groupedItems.putIfAbsent(key, () => []).add(item);
    }

    double totalQty = 0;
    double totalAmount = 0;

    for (var item in data.items) {
      totalQty += item.qty;
      totalAmount += item.totalAmount;
    }

    int index = 1;

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [

          /// 🔷 HEADER (SAME AS UI)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [

              pw.Row(

                children: [
                  /// 🔹 LEFT LOGO TEXT
                  pw.Container(
                    width: 50,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          "GJ",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        pw.Text(
                          "BOOK WORLD",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
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
                        "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638\nGST No: 09AAGCG0650B1Z2",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              pw.Text(
                "Sale MRP Invoice",
                style: pw.TextStyle(fontSize: 14),
              ),

              pw.SizedBox(height: 10),

              /// INFO TABLE
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  row3("Invoice No", data.billNo,
                      "Party Name", data.schoolName,
                      "Bill Date", formatDate(data.billDate)),
                  row3("Transport", "SELF",
                      "Address", "",
                      "Rec. Date", formatDate(data.billDate)),
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
                  cell("Amt With Disc.", bold: true),
                ],
              ),

              /// GROUP DATA
              ...groupedItems.entries.expand((entry) {
                String series = entry.key.split('|')[0];
                String publication = entry.key.split('|')[1];
                List<SaleDetailsMrpItem> group = entry.value;

                double groupQty = 0;
                double groupAmount = 0;

                List<pw.TableRow> rows = [];

                /// SERIES HEADER
                rows.add(
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      cell(""),
                      cell("Series: $series", bold: true),
                      cell(""),
                      cell(""),
                      cell(""),
                      cell("Publication: $publication", bold: true),
                    ],
                  ),
                );

                for (var item in group) {
                  groupQty += item.qty;
                  groupAmount += item.totalAmount;

                  rows.add(
                    pw.TableRow(
                      children: [
                        cell("${index++}"),
                        cell("${item.bookName} - ${item.subject} - ${item.classes}"),
                        cell(item.qty.toStringAsFixed(0)),
                        cell(item.rate.toStringAsFixed(2)),
                        cell(item.totalAmount.toStringAsFixed(2)),
                        cell(item.totalAmount.toStringAsFixed(2)),
                      ],
                    ),
                  );
                }

                /// SUBTOTAL
                rows.add(
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.orange100),
                    children: [
                      cell(""),
                      cell("Series Subtotal", bold: true),
                      cell(groupQty.toStringAsFixed(0), bold: true),
                      cell(""),
                      cell("Rs ${groupAmount.toStringAsFixed(2)}", bold: true),
                      cell("Rs ${groupAmount.toStringAsFixed(2)}", bold: true),
                    ],
                  ),
                );

                return rows;
              }),

              /// TOTAL
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

              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.green100),
                children: [
                  cell(""),
                  cell("Grand Total", bold: true),
                  cell(totalQty.toStringAsFixed(0), bold: true),
                  cell(""),
                  cell("Rs ${data.grandTotal.toStringAsFixed(2)}", bold: true),
                  cell(""),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          pw.Text("Invoice Created By: Admin"),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/invoice_${data.billNo}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// CELL
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

  /// INFO ROW (3 COLUMN)
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