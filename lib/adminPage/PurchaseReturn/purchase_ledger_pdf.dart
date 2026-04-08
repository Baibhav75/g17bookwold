import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '/Model/PurchaseMrpLedger_model.dart';

Future<File> generateLedgerPdf(PurchaseMrpLedgerModel model) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        _buildHeader(model),
        pw.SizedBox(height: 10),
        _buildTable(model),
      ],
    ),
  );

  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.pdf");

  await file.writeAsBytes(await pdf.save());

  return file;
}

pw.Widget _buildHeader(PurchaseMrpLedgerModel model) {
  return pw.Column(
    children: [
      /// COMPANY
      pw.Text(
        "GJ BOOK WORLD PVT. LTD.",
        style: pw.TextStyle(
          fontSize: 22,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 5),

      pw.Text(
        "D-1/20, SECTOR 22, GIDA, GORAKHPUR",
        style: const pw.TextStyle(fontSize: 14, color: PdfColors.black),
      ),
      pw.Text(
        "Contact: 9354918638",
        style: const pw.TextStyle(fontSize: 14, color: PdfColors.black),
      ),

      pw.SizedBox(height: 10),
      pw.Divider(color: PdfColors.black, thickness: 1.2),
      pw.SizedBox(height: 10),

      /// TITLE
      pw.Text(
        "Purchase Ledger Statement",
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          decoration: pw.TextDecoration.underline,
          color: PdfColors.black,
        ),
      ),

      pw.SizedBox(height: 5),

      /// PUBLICATION
      pw.Text(
        "Publication: ${model.publication.publication}",
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),

      pw.SizedBox(height: 10),

      /// DATE
      pw.Text(
        "Date: ${DateTime.now().toString().split(" ")[0]}",
        style: const pw.TextStyle(fontSize: 12, color: PdfColors.black),
      ),
    ],
  );
}

pw.Widget _buildTable(PurchaseMrpLedgerModel model) {
  List<pw.TableRow> rows = [];

  // HEADER
  rows.add(
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _cell("Date", isHeader: true),
        _cell("Type/Vch No", isHeader: true),
        _cell("Particulars", isHeader: true),
        _cell("Debit", isHeader: true, align: pw.TextAlign.right),
        _cell("Credit", isHeader: true, align: pw.TextAlign.right),
        _cell("Balance", isHeader: true, align: pw.TextAlign.right),
      ],
    ),
  );

  double currentBalance = 0;

  for (var e in model.data) {
    currentBalance += e.credit;
    currentBalance -= e.debit;

    rows.add(
      pw.TableRow(
        children: [
          _cell(e.date.split("T")[0]),
          _cell(e.type),
          _cell("Invoice No. ${e.billNo} & Dt. ${e.date.split("T")[0]}"),
          _cell(e.debit == 0.0 ? "" : "Rs ${e.debit.toStringAsFixed(2)}", align: pw.TextAlign.right),
          _cell(e.credit == 0.0 ? "" : "Rs ${e.credit.toStringAsFixed(2)}", align: pw.TextAlign.right),
          _cell("Rs ${currentBalance.toStringAsFixed(2)}", align: pw.TextAlign.right),
        ],
      ),
    );
  }

  // TOTAL ROW
  rows.add(
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        pw.SizedBox(),
        pw.SizedBox(),
        _cell("Total :", isTotal: true, align: pw.TextAlign.right),
        _cell("Rs ${model.summary.totalDebit.toStringAsFixed(2)}", isTotal: true, align: pw.TextAlign.right),
        _cell("Rs ${model.summary.totalCredit.toStringAsFixed(2)}", isTotal: true, align: pw.TextAlign.right),
        pw.SizedBox(),
      ],
    ),
  );

  // CLOSING BALANCE
  rows.add(
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFDDE3EC)),
      children: [
        pw.SizedBox(),
        pw.SizedBox(),
        _cell("Closing Balance :", isTotal: true, align: pw.TextAlign.right),
        pw.SizedBox(),
        pw.SizedBox(),
        _cell("Rs ${model.summary.balance.toStringAsFixed(2)}", isTotal: true, align: pw.TextAlign.right),
      ],
    ),
  );

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
    columnWidths: {
      0: const pw.FlexColumnWidth(1.2),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(2.6),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(1),
      5: const pw.FlexColumnWidth(1.2),
    },
    children: rows,
  );
}

pw.Widget _cell(String text, {pw.TextAlign align = pw.TextAlign.left, bool isHeader = false, bool isTotal = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        fontWeight: (isHeader || isTotal) ? pw.FontWeight.bold : pw.FontWeight.normal,
        fontSize: 10,
        color: PdfColors.black,
      ),
    ),
  );
}