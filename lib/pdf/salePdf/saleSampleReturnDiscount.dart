import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../Model/sale_return_sample_model.dart';

Future<void> generateAndSharePDF(SaleReturnSampleModel data) async {
  final pdf = pw.Document();

  pw.Widget header() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Icon(pw.IconData(0xe865)), // book icon
            pw.SizedBox(width: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "GJ BOOK WORLD PVT. LTD.",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "D-1/20, SECTOR 22, GIDA, GORAKHPUR",
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "Cont. - 9354918638, 9354918644",
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  "GST No: 09AAGCG0650B1Z2",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            )
          ],
        ),
        pw.Divider(),

        pw.Center(
          child: pw.Text(
            "Sale Return Sample Invoice",
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),

        pw.SizedBox(height: 10),

        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text("Invoice No: ${data.master.billNo}"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text("Party: ${data.master.schoolName}"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text("Date: ${data.master.date}"),
              ),
            ]),
            pw.TableRow(children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text("Transport: ${data.master.transport}"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text("Address: ${data.master.address}"),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text("Remark: ${data.master.remark}"),
              ),
            ]),
          ],
        ),
      ],
    );
  }

  List<pw.TableRow> buildRows() {
    Map<String, List<Item>> grouped = {};

    for (var item in data.items) {
      grouped.putIfAbsent(item.series, () => []).add(item);
    }

    int index = 1;
    List<pw.TableRow> rows = [];

    grouped.forEach((series, list) {
      // Series Header
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Text(""),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text("Series: $series",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Text(""),
            pw.Text(""),
            pw.Text(""),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                "Publication: ${data.master.publication}",
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      // Items
      for (var item in list) {
        rows.add(
          pw.TableRow(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text("${index++}"),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text("${item.bookName} - ${item.classes}"),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text("${item.qty}"),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(" ${item.rate}"),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(" ${item.total.toStringAsFixed(2)}"),
            ),
            pw.Text(""),
          ]),
        );
      }

      final summary = data.seriesSummary.firstWhere(
            (s) => s.series == series,
        orElse: () => SeriesSummary(series: series, qty: 0, total: 0),
      );

      // Subtotal
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Text(""),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text("Subtotal:",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Text("${summary.qty}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(""),
            pw.Text(" ${summary.total.toStringAsFixed(2)}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(""),
          ],
        ),
      );
    });

    return rows;
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        header(),
        pw.SizedBox(height: 15),

        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FixedColumnWidth(30),
            1: const pw.FlexColumnWidth(4),
            2: const pw.FixedColumnWidth(50),
            3: const pw.FixedColumnWidth(60),
            4: const pw.FixedColumnWidth(70),
            5: const pw.FixedColumnWidth(80),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey400),
              children: [
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text("S.N.")),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text("Book Name")),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text("Qty")),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text("Rate")),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text("Amount")),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text("Amt With Disc")),
              ],
            ),

            ...buildRows(),

            // Grand Total
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.green200),
              children: [
                pw.Text(""),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text("Grand Total:",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Text("${data.grandQty}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(""),
                pw.Text(" ${data.grandTotal.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(""),
              ],
            ),

            // Discount
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.cyan100),
              children: [
                pw.Text(""),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text("Total Discount:",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Text("0.00%"),
                pw.Text(""),
                pw.Text(""),
                pw.Text(" ${data.finalAmount.toStringAsFixed(4)}"),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: "sale_return_sample.pdf",
  );
}