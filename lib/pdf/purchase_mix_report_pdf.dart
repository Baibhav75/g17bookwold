import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../Model/PurchaseMixReport_model.dart';

class PurchaseMixReportPdf {
  static Future<File> generate(PurchaseMixReportModel model) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(model),
          pw.SizedBox(height: 10),
          _buildItemsTable(model),
          pw.SizedBox(height: 20),
          _buildFooter(model),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/mix_report_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildHeader(PurchaseMixReportModel model) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
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
              pw.SizedBox(width: 30),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "GJ BOOK WORLD PVT. LTD.",
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nContact: 9354918638",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.black, lineSpacing: 2),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      "Mix Report",
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      "Publication: ${model.publication}",
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 50),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.black, thickness: 1.2),
      ],
    );
  }

  static pw.Widget _buildItemsTable(PurchaseMixReportModel model) {
    Map<String, List<PurchaseItem>> grouped = {};
    for (var item in model.data) {
      if (!grouped.containsKey(item.seriesName)) {
        grouped[item.seriesName] = [];
      }
      grouped[item.seriesName]!.add(item);
    }

    List<pw.TableRow> rows = [];

    // Header
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell("Book Name", isBold: true, align: pw.TextAlign.center),
          _cell("Purchase", isBold: true, align: pw.TextAlign.center),
          _cell("Return", isBold: true, align: pw.TextAlign.center),
          _cell("Net", isBold: true, align: pw.TextAlign.center),
          _cell("Rate", isBold: true, align: pw.TextAlign.center),
          _cell("Amount", isBold: true, align: pw.TextAlign.center),
          _cell("Net Amt", isBold: true, align: pw.TextAlign.center),
        ],
      ),
    );

    grouped.forEach((series, items) {
      // SERIES HEADER
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue50), // Color(0xFFE3F2FD) Equivalent
          children: [
            _cell("SERIES: $series", isBold: true, align: pw.TextAlign.left),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
          ],
        ),
      );

      int totalQty = 0;
      double totalAmount = 0;

      for (var item in items) {
        totalQty += item.netQty;
        totalAmount += item.netAmount;

        rows.add(
          pw.TableRow(
            children: [
              _cell(item.bookName, align: pw.TextAlign.left),
              _cell(item.purchaseQty.toString(), align: pw.TextAlign.center),
              _cell(item.returnQty.toString(), align: pw.TextAlign.center),
              _cell(item.netQty.toString(), align: pw.TextAlign.center),
              _cell(item.rate.toStringAsFixed(2), align: pw.TextAlign.center),
              _cell(item.amount.toStringAsFixed(2), align: pw.TextAlign.center),
              _cell(item.netAmount.toStringAsFixed(2), align: pw.TextAlign.center),
            ],
          ),
        );
      }

      // SUBTOTAL
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.orange100),
          children: [
            _cell("Subtotal", align: pw.TextAlign.right, isBold: true),
            _cell(totalQty.toString(), align: pw.TextAlign.center, isBold: true),
            pw.SizedBox(),
            _cell(totalQty.toString(), align: pw.TextAlign.center, isBold: true),
            pw.SizedBox(),
            _cell("Rs ${totalAmount.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
            _cell("Rs ${totalAmount.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
          ],
        ),
      );
    });

    // GRAND TOTAL
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.green200),
        children: [
          _cell("Grand Total", align: pw.TextAlign.right, isBold: true),
          _cell(model.summary.totalPurchaseQty.toString(), align: pw.TextAlign.center, isBold: true),
          _cell(model.summary.totalReturnQty.toString(), align: pw.TextAlign.center, isBold: true),
          _cell(model.summary.totalPurchaseQty.toString(), align: pw.TextAlign.center, isBold: true), // Mirrored the ui mapping directly
          pw.SizedBox(),
          _cell("Rs ${model.summary.totalAmount.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
          _cell("Rs ${model.summary.totalNetAmount.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1.2),
        6: const pw.FlexColumnWidth(1.2),
      },
      children: rows,
    );
  }

  static pw.Widget _cell(String text, {pw.TextAlign align = pw.TextAlign.left, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 9,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildFooter(PurchaseMixReportModel model) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "MRP Purchase: Rs ${model.summary.totalAmount.toStringAsFixed(2)}",
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal, color: PdfColors.black),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Total Paid: Rs ${model.summary.totalPaidAmount.toStringAsFixed(2)}",
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal, color: PdfColors.black),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Closing Amount: Rs ${model.summary.closingAmount.toStringAsFixed(2)}",
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal, color: PdfColors.black),
            ),
          ],
        ),
      ],
    );
  }
}