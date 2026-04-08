import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../Model/GetMixReportPubDisc_model.dart';

class MixReportPubDiscPdf {
  static Future<File> generate(GetMixReportPubDiscModel report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.black, thickness: 1),
          pw.SizedBox(height: 10),
          _buildTitle(report),
          pw.SizedBox(height: 16),
          _buildItemsTable(report),
          pw.SizedBox(height: 20),
          _buildSummary(report),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/mix_pub_disc_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildHeader() {
    return pw.Center(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            "GJ BOOK WORLD PVT. LTD.",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "D-1/20, SECTOR 22, GIDA, GORAKHPUR",
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.black),
          ),
          pw.Text(
            "Contact: 9354918638",
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTitle(GetMixReportPubDiscModel report) {
    return pw.Center(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            "Mix Report Publication Discount",
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "Publication: ${report.publication}",
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(GetMixReportPubDiscModel report) {
    double grandQty = 0;
    double grandAmount = 0;
    double grandNetAmount = 0;

    Map<String, List<MixReportItem>> grouped = {};
    for (var item in report.data) {
      if (!grouped.containsKey(item.series)) {
        grouped[item.series] = [];
      }
      grouped[item.series]!.add(item);
    }

    List<pw.TableRow> rows = [];

    // Header Row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _headerCell("Book Name"),
          _headerCell("Purchase Qty"),
          _headerCell("Return Qty"),
          _headerCell("Net Qty"),
          _headerCell("Rate"),
          _headerCell("Amount"),
          _headerCell("Discount %"),
          _headerCell("Net Amount"),
        ],
      ),
    );

    grouped.forEach((series, items) {
      double subPurchaseQty = 0;
      double subReturnQty = 0;
      double subNetQty = 0;
      double subAmount = 0;
      double subNetAmount = 0;

      // Series Header Row
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                "Series: ${series.isNotEmpty ? series : 'N/A'}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.black),
              ),
            ),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
          ],
        ),
      );

      // Items
      for (var item in items) {
        subPurchaseQty += item.purchaseQty;
        subReturnQty += item.returnQty;
        subNetQty += item.netQty;
        subAmount += item.amount;
        subNetAmount += item.netAmount;

        rows.add(
          pw.TableRow(
            children: [
              _cell(item.bookName),
              _cell(item.purchaseQty.toString(), center: true),
              _cell(item.returnQty.toString(), center: true),
              _cell(item.netQty.toString(), center: true),
              _cell(item.rate.toStringAsFixed(2), right: true),
              _cell(item.amount.toStringAsFixed(2), right: true),
              _cell(item.discount.toStringAsFixed(2), center: true),
              _cell(item.netAmount.toStringAsFixed(2), right: true),
            ],
          ),
        );
      }

      // Subtotal Row
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.orange100),
          children: [
            _cell("Subtotal", right: true, isBold: true),
            _cell(subPurchaseQty.toString(), center: true, isBold: true),
            _cell(subReturnQty.toString(), center: true, isBold: true),
            _cell(subNetQty.toString(), center: true, isBold: true),
            _cell("", right: true),
            _cell(subAmount.toStringAsFixed(2), right: true, isBold: true),
            _cell("0.00%", center: true, isBold: true),
            _cell(subNetAmount.toStringAsFixed(2), right: true, isBold: true),
          ],
        ),
      );

      grandQty += subNetQty; // Maintaining grand logic matching subNetQty equivalent
      grandAmount += subAmount;
      grandNetAmount += subNetAmount;
    });

    // Grand Total Row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.green300),
        children: [
          _cell("Grand Total", right: true, isBold: true),
          _cell(grandQty.toString(), center: true, isBold: true), // Following original display logic or close to it
          _cell("", center: true),
          _cell(grandQty.toString(), center: true, isBold: true),
          _cell("", right: true),
          _cell(grandAmount.toStringAsFixed(2), right: true, isBold: true),
          _cell("0.00%", center: true, isBold: true),
          _cell(grandNetAmount.toStringAsFixed(2), right: true, isBold: true),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1.2),
        6: const pw.FlexColumnWidth(1),
        7: const pw.FlexColumnWidth(1.2),
      },
      children: rows,
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _cell(String text, {bool center = false, bool right = false, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: center ? pw.TextAlign.center : (right ? pw.TextAlign.right : pw.TextAlign.left),
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 8,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildSummary(GetMixReportPubDiscModel report) {
    double totalAmount = report.data.fold(0.0, (sum, item) => sum + item.netAmount);
    double totalPaid = 0;
    double closingAmount = totalAmount - totalPaid;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 1, color: PdfColors.black),
        pw.SizedBox(height: 10),
        pw.Text(
          "MRP Purchase: Rs ${totalAmount.toStringAsFixed(2)}",
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  "Total Paid: Rs ${totalPaid.toStringAsFixed(2)}",
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  "Closing Amount: Rs ${closingAmount.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}