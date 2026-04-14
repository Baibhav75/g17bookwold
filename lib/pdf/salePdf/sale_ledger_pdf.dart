import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '/Model/sale_view_mrp_ledger_model.dart';

class SaleLedgerPdf {
  static Future<File> generate(SaleViewMRPLedgerResponse data) async {
    final pdf = pw.Document();

    String formatDate(String raw) {
      try {
        return DateTime.parse(raw).toLocal().toString().split(' ')[0];
      } catch (e) {
        return "";
      }
    }

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
                "GIDA GORAKHPUR\nCont: 7905891950",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 8),
              ),

              pw.SizedBox(height: 8),
              pw.Divider(),

              pw.Text(
                "Sale Ledger Statement",
                style: pw.TextStyle(fontSize: 14),
              ),

              pw.SizedBox(height: 10),

              /// 🔹 SCHOOL INFO TABLE
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      cell("School: ${data.schoolName}", bold: true),
                      cell("Address: ${data.address}", bold: true),
                    ],
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          /// 🔷 MAIN TABLE
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(2),
            },
            children: [

              /// 🔹 HEADER ROW
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  cell("Date", bold: true),
                  cell("Particulars", bold: true),
                  cell("Debit", bold: true),
                  cell("Credit", bold: true),
                  cell("Balance", bold: true),
                ],
              ),

              /// 🔹 DATA ROWS
              ...data.ledger.map((e) {
                final isOpening = e.particulars.toLowerCase().contains("opening");

                return pw.TableRow(
                  decoration: isOpening
                      ? pw.BoxDecoration(color: PdfColors.green100)
                      : null,
                  children: [
                    cell(formatDate(e.date)),

                    cell(
                      e.particulars,
                      bold: true,
                      color: isOpening ? PdfColors.green800 : PdfColors.blue,
                    ),

                    cell("Rs ${e.debit.toStringAsFixed(2)}"),
                    cell("Rs ${e.credit.toStringAsFixed(2)}"),
                    cell("Rs ${e.balance.toStringAsFixed(2)}"),
                  ],
                );
              }).toList(),

              /// 🔹 TOTAL ROW
              pw.TableRow(
                children: [
                  cell(""),
                  cell("Total", bold: true),
                  cell("Rs ${data.totalDebit.toStringAsFixed(2)}", bold: true),
                  cell("Rs ${data.totalCredit.toStringAsFixed(2)}", bold: true),
                  cell(""),
                ],
              ),

              /// 🔹 CLOSING BALANCE
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  cell(""),
                  cell("Closing Balance", bold: true),
                  cell(""),
                  cell(""),
                  cell("Rs ${data.closingBalance.toStringAsFixed(2)}",
                      bold: true),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          /// 🔹 FOOTER
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Checked By: __________"),
              pw.Text("Approved By: __________"),
            ],
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        "${dir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// 🔹 CELL WIDGET
  static pw.Widget cell(String text,
      {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }
}