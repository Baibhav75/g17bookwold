import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../model/purchase_not_for_sale_ledger_model.dart';

class PurchaseNotForSaleLedgerPdf {
  static Future<File> generate(PurchaseNotForSaleLedgerModel data) async {
    final pdf = pw.Document();

    String getBillNoFromType(String type) {
      final parts = type.split(" ");
      return parts.isNotEmpty ? parts.last : "";
    }

    String formatDate(String date) {
      try {
        if (date.contains("T")) {
          final d = DateTime.parse(date);
          return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
        }
        if (date.contains("-")) {
          final parts = date.split("-");
          if (parts.length == 3) {
            return "${parts[0]}/${parts[1]}/${parts[2]}";
          }
        }
        return date;
      } catch (e) {
        return date;
      }
    }

    final d = DateTime.now();
    String currentDate = "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            /// HEADER
            pw.Row(
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
                      pw.SizedBox(height: 8),
                      pw.Text(
                        "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 0551-2320642\nGST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.black, lineSpacing: 2),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 50),
              ],
            ),

            pw.SizedBox(height: 10),
            pw.Divider(color: PdfColors.black, thickness: 1.5),
            pw.SizedBox(height: 10),

            pw.Center(
              child: pw.Text(
                "Purchase Ladger Statement",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                  color: const PdfColor.fromInt(0xFF003366),
                ),
              ),
            ),

            pw.SizedBox(height: 15),

            /// INFO TABLE
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(0.5),
              },
              children: [
                pw.TableRow(
                  children: [
                    _infoCell("Publication: ", data.publication.publication),
                    _infoCell("Address: ", data.publication.address),
                    _infoCell("GST No: ", data.publication.gstNo.isNotEmpty ? data.publication.gstNo : "0"),
                  ],
                ),
              ],
            ),
            
            pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 0.5),
                  left: pw.BorderSide(width: 0.5),
                  right: pw.BorderSide(width: 0.5),
                )
              ),
              padding: const pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text("Date: $currentDate", style: pw.TextStyle(fontSize: 10, color: PdfColors.black, fontWeight: pw.FontWeight.bold)),
            ),

            pw.SizedBox(height: 15),

            /// TABLE
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(60),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FixedColumnWidth(50),
                4: const pw.FixedColumnWidth(60),
              },
              children: [
                /// HEADER
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _headerCell("Date", isBold: true),
                    _headerCell("Vch No", isBold: true),
                    _headerCell("Particulars", isBold: true),
                    _headerCell("Debit", isBold: true),
                    _headerCell("Credit", isBold: true),
                  ],
                ),

                /// DATA
                ...data.data.map((e) {
                   final billNo = getBillNoFromType(e.type);
                   final formattedDate = formatDate(e.date);
                   return pw.TableRow(
                    children: [
                      _cell(formattedDate, align: pw.TextAlign.center),
                      _cell(e.type, align: pw.TextAlign.center),
                      _cell("Invoice No. $billNo & Dt. $formattedDate", align: pw.TextAlign.center),
                      _cell(e.debit > 0 ? "Rs${e.debit.toStringAsFixed(2)}" : "", align: pw.TextAlign.center),
                      _cell(e.credit > 0 ? "Rs${e.credit.toStringAsFixed(2)}" : "", align: pw.TextAlign.center),
                    ],
                  );
                }),

                /// TOTAL
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    _cell("Total :", isBold: true, align: pw.TextAlign.right),
                    _cell("Rs${data.totals.totalDebit.toStringAsFixed(2)}", isBold: true, align: pw.TextAlign.center),
                    _cell("Rs${data.totals.totalCredit.toStringAsFixed(2)}", isBold: true, align: pw.TextAlign.center),
                  ],
                ),

                /// CLOSING
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue50), 
                  children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    _cell("Closing Balance :", isBold: true, align: pw.TextAlign.right),
                    pw.SizedBox(), 
                    _cell("Rs${data.totals.closingBalance.toStringAsFixed(2)}", isBold: true, align: pw.TextAlign.center),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            /// FOOTER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                     pw.Text("Checked By: ____________________", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                     pw.SizedBox(height: 15),
                     pw.Text("Approved By: ____________________", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ]
                )
              ],
            )
          ];
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/ledger_${data.publication.publication}.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _infoCell(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: pw.RichText(
        textAlign: pw.TextAlign.center,
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          children: [
            pw.TextSpan(
              text: label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  static pw.Widget _headerCell(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 10,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _cell(String text, {pw.TextAlign align = pw.TextAlign.left, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 10,
          color: PdfColors.black,
        ),
      ),
    );
  }
}