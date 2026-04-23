import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../../Model/sale_pending_mix_order_model.dart';

class SalePendingMixPdf {
  static Future<File> generate(SalePendingMixOrderModel data) async {
    final pdf = pw.Document();

    /// 🔹 GROUPING (same as UI)
    Map<String, List<SalePendingItem>> grouped = {};
    for (var item in data.data) {
      String key = "${item.series}|${item.publication}";
      grouped.putIfAbsent(key, () => []).add(item);
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(16),
        maxPages: 100,

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
          /// 🔷 HEADER
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "Sale and Order Pending Mix Report",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                data.schoolName,
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          /// 🔷 TABLE
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FixedColumnWidth(60),
              2: const pw.FixedColumnWidth(60),
              3: const pw.FixedColumnWidth(70),
              4: const pw.FixedColumnWidth(60),
            },
            children: [

              /// HEADER
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  cell("Book Name", bold: true),
                  cell("Order", bold: true),
                  cell("Sale", bold: true),
                  cell("Pending", bold: true),
                  cell("Rate", bold: true),
                ],
              ),

              /// 🔹 GROUP DATA
              ...grouped.entries.expand((entry) {
                final parts = entry.key.split("|");
                final series = parts[0];
                final publication = parts[1];
                final items = entry.value;

                int subOrder = 0;
                int subSale = 0;
                int subPending = 0;
                double subRate = 0;

                List<pw.TableRow> rows = [];

                /// GROUP HEADER
                rows.add(
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      cell("Series: $series | Publication: $publication",
                          bold: true),
                      ...List.generate(4, (_) => cell("")),
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
                    pw.TableRow(
                      children: [
                        cell(e.bookName),
                        cell(e.totalOrder.toString()),
                        cell(e.sale.toString()),
                        cell(e.pending),
                        cell(e.rate.toStringAsFixed(2)),
                      ],
                    ),
                  );
                }

                /// SUBTOTAL
                rows.add(
                  pw.TableRow(
                    decoration:
                    pw.BoxDecoration(color: PdfColors.orange100),
                    children: [
                      cell("Subtotal", bold: true),
                      cell(subOrder.toString(), bold: true),
                      cell(subSale.toString(), bold: true),
                      cell("+$subPending", bold: true),
                      cell(subRate.toStringAsFixed(2), bold: true),
                    ],
                  ),
                );

                return rows;
              }),

              /// 🔹 GRAND TOTAL
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.green100),
                children: [
                  cell("Grand Total", bold: true),
                  cell(data.summary.totalOrder.toString(), bold: true),
                  cell(data.summary.totalSale.toString(), bold: true),
                  cell(data.summary.totalPending.toString(), bold: true),
                  cell(data.summary.totalRate.toStringAsFixed(2),
                      bold: true),
                ],
              ),
            ],
          ),
        ],
      ),
      ],

      ),

    );

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File("${dir.path}/SalePendingMixReport_$timestamp.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// 🔹 CELL
  static pw.Widget cell(String text,
      {bool bold = false, pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight:
          bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}