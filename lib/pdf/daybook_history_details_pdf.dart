import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Model/daybook_history_details_model.dart';

class DayBookHistoryDetailsPdf {

  /// Format date (same as UI)
  static String formatDate(String raw) {
    final dt = DateTime.parse(raw);
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  /// MAIN FUNCTION
  static Future<void> generateAndShare(
      DayBookDetailsResponse data) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [

          /// 🔴 HEADER
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [

              /// LOGO TEXT
              pw.Column(
                children: [
                  pw.Icon(pw.IconData(0xe0af), size: 30),
                  pw.Text(
                    "BOOK WORLD",
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
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
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text("Contact No: 8303173797, 8303173799",
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text("E-Mail: gjbookworld@gmail.com",
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 10),

          /// 🔴 TITLE
          pw.Center(
            child: pw.Text(
              "SUPPLY INVOICE",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          /// 🔵 TABLE
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FixedColumnWidth(60),
              2: const pw.FixedColumnWidth(100),
              3: const pw.FixedColumnWidth(60),
              4: const pw.FixedColumnWidth(60),
              5: const pw.FixedColumnWidth(70),
              6: const pw.FixedColumnWidth(80),
              7: const pw.FixedColumnWidth(80),
              8: const pw.FixedColumnWidth(90),
              9: const pw.FixedColumnWidth(180),
            },
            children: [

              /// HEADER ROW
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.blue100),
                children: [
                  _cell("Sr No", center: true, bold: true),
                  _cell("Date", center: true, bold: true),
                  _cell("Particular", bold: true),
                  _cell("Debit", right: true, bold: true),
                  _cell("Credit", right: true, bold: true),
                  _cell("Balance", right: true, bold: true),
                  _cell("Exp No", center: true, bold: true),
                  _cell("Rec No", center: true, bold: true),
                  _cell("Mobile", center: true, bold: true),
                  _cell("Remarks", bold: true),
                ],
              ),

              /// DATA ROWS
              ...data.data.asMap().entries.map((e) {
                int i = e.key;
                var item = e.value;

                return pw.TableRow(
                  children: [
                    _cell("${i + 1}", center: true),
                    _cell(formatDate(item.date), center: true),
                    _cell(item.name),

                    _cell(
                      item.flag == "Debit"
                          ? "₹${item.amount}"
                          : "",
                      right: true,
                      color: PdfColors.red,
                    ),

                    _cell(
                      item.flag == "Credit"
                          ? "₹${item.amount}"
                          : "",
                      right: true,
                      color: PdfColors.green,
                    ),

                    _cell("", right: true),
                    _cell(item.expNo, center: true),
                    _cell(item.recNo, center: true),
                    _cell(item.mobileNo, center: true),
                    _cell(item.remarks),
                  ],
                );
              }).toList(),

              /// TOTAL
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300),
                children: [
                  _cell(""),
                  _cell(""),
                  _cell("Total", bold: true),
                  _cell("₹{data.totalDebit}",
                      right: true, bold: true),
                  _cell("₹{data.totalCredit}",
                      right: true, bold: true),
                  _cell(""),
                  _cell(""),
                  _cell(""),
                  _cell(""),
                  _cell(""),
                ],
              ),

              /// FINAL BALANCE
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                    color: PdfColors.yellow100),
                children: [
                  _cell(""),
                  _cell(""),
                  _cell("Final Balance", bold: true),
                  _cell(""),
                  _cell(""),
                  _cell("₹${data.balance}",
                      right: true,
                      bold: true,
                      color: PdfColors.blue),
                  _cell(""),
                  _cell(""),
                  _cell(""),
                  _cell(""),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    /// SHARE PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "DayBook_Ledger.pdf",
    );
  }

  /// CELL DESIGN
  static pw.Widget _cell(
      String text, {
        bool bold = false,
        bool center = false,
        bool right = false,
        PdfColor? color,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: center
            ? pw.TextAlign.center
            : right
            ? pw.TextAlign.right
            : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          color: color ?? PdfColors.black,
          fontWeight:
          bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}