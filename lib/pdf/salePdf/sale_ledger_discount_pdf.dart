import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '/Model/SaleLedgerDiscount_model.dart';

class SaleLedgerDiscountPdf {
  static Future<File> generate(SaleLedgerDiscountResponse data) async {
    final pdf = pw.Document();

    String formatDate(String date) {
      try {
        return DateTime.parse(date).toLocal().toString().split(' ')[0];
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

              pw.Row(
                children: [

                  /// 🔹 LEFT LOGO TEXT
                  pw.Container(
                    width: 60,
                    child: pw.Column(
                      children: [
                        pw.Text("GJ",
                            style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text("BOOK WORLD",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 20),

                  /// 🔹 CENTER COMPANY
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            "GJ BOOK WORLD PVT. LTD.",
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF2B4C7E),
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            "D-1/20, SECTOR 22, GIDA, GORAKHPUR\n"
                                "Cont. - 0551-2320642\n"
                                "GST No: 09AAGCG0650B1Z2",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 60),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              pw.Text(
                "Sale Ledger Statement",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          /// 🔷 PUBLICATION + ADDRESS BOX (UI MATCH)
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
            ),
            child: pw.Column(
              children: [

                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                            bottom: pw.BorderSide(),
                          ),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Publication: ${data.schoolName}",
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(),
                          ),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Address: ${data.address}",
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    "Date: ${DateTime.now().toString().split(' ')[0]}",
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 15),

          /// 🔷 LEDGER TABLE
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(4),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.5),
            },
            children: [

              /// HEADER
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  cell("Date", bold: true),
                  cell("Vch No", bold: true),
                  cell("Particulars", bold: true),
                  cell("Debit", bold: true),
                  cell("Credit", bold: true),
                  cell("Balance", bold: true),
                ],
              ),

              /// DATA
              ...data.ledger.map((e) {
                return pw.TableRow(
                  children: [
                    cell(formatDate(e.date)),
                    cell(e.type),
                    cell(e.particulars, color: PdfColors.blue),
                    cell("Rs${e.debit.toStringAsFixed(2)}",
                        align: pw.TextAlign.right),
                    cell(
                        e.credit == 0
                            ? ""
                            : "Rs${e.credit.toStringAsFixed(2)}",
                        align: pw.TextAlign.right),
                    cell("Rs${e.balance.toStringAsFixed(2)}",
                        bold: true,
                        align: pw.TextAlign.right),
                  ],
                );
              }).toList(),

              /// TOTAL
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  cell(""),
                  cell(""),
                  cell("Total", bold: true, align: pw.TextAlign.right),
                  cell("Rs${data.totalDebit.toStringAsFixed(2)}",
                      bold: true,
                      align: pw.TextAlign.right),
                  cell("Rs${data.totalCredit.toStringAsFixed(2)}",
                      bold: true,
                      align: pw.TextAlign.right),
                  cell(""),
                ],
              ),

              /// CLOSING BALANCE
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.blue100),
                children: [
                  cell(""),
                  cell(""),
                  cell(""),
                  cell(""),
                  cell("Closing Balance", bold: true, align: pw.TextAlign.right),
                  cell("Rs${data.closingBalance.toStringAsFixed(2)}",
                      bold: true,
                      align: pw.TextAlign.right),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          /// 🔷 FOOTER
          pw.Text("Checked By: ___________________________"),
          pw.SizedBox(height: 10),
          pw.Text("Approved By: ___________________________"),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        "${dir.path}/ledger_discount_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// 🔹 CELL
  static pw.Widget cell(String text,
      {bool bold = false,
        PdfColor? color,
        pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }
}