import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '/Model/sample_sale_bill_ledger_model.dart';

class SampleSaleBillLedgerPdf {

  static Future<void> generateAndShare(
      SampleSaleLedgerResponse ledger) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(25),

        build: (context) => [

          /// 🔴 HEADER (MATCH UI)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 80,
                child: pw.Column(
                  children: [

                    pw.Text("GJ",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text("BOOK WORLD",
                        style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),

              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "GJ BOOK WORLD PVT. LTD.",
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text("D-1/20, SECTOR 22, GIDA, GORAKHPUR",
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text("Cont. - 0551-2320642",
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        "GST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                        style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),
          pw.Divider(thickness: 1.5),

          /// 🔵 TITLE
          pw.Center(
            child: pw.Text(
              "Sale Sample Ledger Statement",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),

          pw.SizedBox(height: 15),

          /// 🟦 INFO BOX
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
            ),
            child: pw.Column(
              children: [

                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Publication: ${ledger.school.refName}",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ),

                    pw.Container(width: 1, height: 30, color: PdfColors.black),

                    pw.Expanded(
                      flex: 4,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Address: ${ledger.school.area}",
                        ),
                      ),
                    ),
                  ],
                ),

                pw.Divider(height: 1),

                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    "Date: ${DateTime.now().toString().split(' ')[0]}",
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 15),

          /// 📊 TABLE (MATCH UI STRUCTURE)
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(4),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(2),
            },
            children: [

              /// HEADER
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: _headerRow(),
              ),

              /// DATA
              ...ledger.data.map((e) => pw.TableRow(
                children: [
                  _cell(_formatDate(e.date)),
                  _cell(e.type),
                  _cell(e.particulars),
                  _cell(e.debit == 0 ? "" : "${e.debit}"),
                  _cell(e.credit == 0 ? "" : "${e.credit}"),
                ],
              )),

              /// TOTAL
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _cell(""),
                  _cell(""),
                  _cell("Total :", bold: true),
                  _cell("${ledger.totalDebit}", bold: true),
                  _cell("${ledger.totalCredit}", bold: true),
                ],
              ),

              /// CLOSING
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                children: [
                  _cell(""),
                  _cell(""),
                  _cell("Closing Balance :", bold: true),
                  _cell(""),
                  _cell("${ledger.closingBalance}", bold: true),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 40),

          /// ✍️ SIGNATURE
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

    /// SAVE + SHARE
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/ledger_invoice.pdf");

    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)]);
  }

  /// HEADER CELLS
  static List<pw.Widget> _headerRow() {
    return [
      _cell("Date", bold: true),
      _cell("Vch No", bold: true),
      _cell("Particulars", bold: true),
      _cell("Debit", bold: true),
      _cell("Credit", bold: true),
    ];
  }

  /// CELL
  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 10,
        ),
      ),
    );
  }

  static String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (_) {
      return raw;
    }
  }
}