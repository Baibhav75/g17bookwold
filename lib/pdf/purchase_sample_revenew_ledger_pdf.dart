import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../model/purchase_sample_revenew_ledger_model.dart';

class PurchaseSampleRevenewLedgerPdf {
  static Future<File> generate(
      PurchaseSampleRevenewLedgerModel data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [

              /// 🔥 HEADER (LIKE UI)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [

                  /// LEFT ICON TEXT
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

                  /// COMPANY DETAILS
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
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638, 9354918644\nGST No: 09AAGCG0650B1Z2",
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              /// TITLE
              pw.Text(
                "Purchase Sample Ledger",
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 10),

              /// 🔥 INFO BOX (LIKE UI TABLE)
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(children: [
                    _cell("Publication: ${data.publication.publication}"),
                    _cell("GST: ${data.publication.gstNo}"),
                  ]),
                  pw.TableRow(children: [
                    _cell("Address: ${data.publication.address}"),
                    _cell(""),
                  ]),
                ],
              ),

              pw.SizedBox(height: 10),

              /// 🔥 MAIN TABLE
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(60),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(70),
                  3: const pw.FixedColumnWidth(70),
                  4: const pw.FixedColumnWidth(80),
                },
                children: [

                  /// HEADER
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300),
                    children: [
                      _cell("Date", isHeader: true),
                      _cell("Particulars", isHeader: true),
                      _cell("Debit", isHeader: true),
                      _cell("Credit", isHeader: true),
                      _cell("Balance", isHeader: true),
                    ],
                  ),

                  /// DATA
                  ...data.data.map((e) {
                    return pw.TableRow(children: [
                      _cell(e.date),
                      _cell(e.type),
                      _cell("₹${e.debit.toStringAsFixed(0)}"),
                      _cell("₹${e.credit.toStringAsFixed(0)}"),
                      _cell("₹${e.balance.toStringAsFixed(0)}"),
                    ]);
                  }),

                  /// TOTAL
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.green100),
                    children: [
                      _cell("Total", isHeader: true),
                      _cell(""),
                      _cell(
                          "₹${data.totals.totalDebit.toStringAsFixed(0)}",
                          isHeader: true),
                      _cell(
                          "₹${data.totals.totalCredit.toStringAsFixed(0)}",
                          isHeader: true),
                      _cell(""),
                    ],
                  ),

                  /// CLOSING
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.blue100),
                    children: [
                      _cell("Closing Balance", isHeader: true),
                      _cell(""),
                      _cell(""),
                      _cell(""),
                      _cell(
                          "₹${data.totals.closingBalance.toStringAsFixed(0)}",
                          isHeader: true),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              /// FOOTER
              pw.Row(
                mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Checked By: __________",
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.Text("Authorized Signatory",
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              )
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/sample_ledger_pro.pdf");

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
}