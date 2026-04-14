import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../model/purchase_not_for_sale_invoice_model.dart';

class PurchaseNotForSaleInvoicePdf {
  static Future<File> generate(PurchaseNotForSaleInvoiceModel data) async {
    final pdf = pw.Document();

    String formattedDate = data.date.contains("T") ? data.date.split("T")[0] : data.date;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.black, thickness: 1.5),
          pw.SizedBox(height: 10),
          _buildInvoiceTitle(),
          pw.SizedBox(height: 10),
          _buildInfoTable(data, formattedDate),
          pw.SizedBox(height: 16),
          _buildItemsTable(data),
          pw.SizedBox(height: 20),
          _buildFooter(data),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/not_for_sale_invoice_${data.billNo}.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildHeader() {
    return pw.Center(
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
                pw.SizedBox(height: 8),
                pw.Text(
                  "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638, 9354918644\nGST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.black, lineSpacing: 2),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 50),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceTitle() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            "Purchase Not For Sale Invoice",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoTable(PurchaseNotForSaleInvoiceModel data, String formattedDate) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            _infoCell("Invoice No: ", data.billNo),
            _infoCell("Supplier: ", data.publication),
            _infoCell("Bill Date: ", formattedDate),
          ],
        ),
        pw.TableRow(
          children: [
            _infoCell("Supplier Invoice No: ", "1"),
            _infoCell("Address: ", "T-6 1401 ACE PARKWAY SECTOR 150 NOIDA"),
            _infoCell("Rec. Date: ", formattedDate),
          ],
        ),
        pw.TableRow(
          children: [
            _infoCell("Transport: ", "SELF"),
            _infoCell("GR No: ", "123"),
            pw.SizedBox(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _infoCell(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: pw.RichText(
        textAlign: pw.TextAlign.left,
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
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

  static pw.Widget _buildItemsTable(PurchaseNotForSaleInvoiceModel data) {
    Map<String, List<PurchaseItem>> grouped = {};
    for (var item in data.data) {
      if (!grouped.containsKey(item.series)) {
        grouped[item.series] = [];
      }
      grouped[item.series]!.add(item);
    }

    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _headerCell("S.N.", isBold: true),
          _headerCell("Book Name (Title)", isBold: true),
          _headerCell("Qty", isBold: true),
          _headerCell("Rate", isBold: true),
          _headerCell("Amount", isBold: true),
          _headerCell("Amt With Disc.", isBold: true),
        ],
      ),
    );

    int index = 1;
    double totalQty = 0;
    double totalAmount = 0;

    grouped.forEach((series, items) {
      double subQty = 0;
      double subAmount = 0;

      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            pw.SizedBox(),
            _cell("Series: $series", isBold: true, align: pw.TextAlign.left),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
          ],
        ),
      );

      for (var e in items) {
        subQty += e.qty;
        subAmount += e.totalAmount;

        totalQty += e.qty;
        totalAmount += e.totalAmount;

        rows.add(
          pw.TableRow(
            children: [
              _cell("${index++}", align: pw.TextAlign.center),
              _cell("${e.bookName} - ${e.subject} - ${e.classes}", align: pw.TextAlign.left),
              _cell(e.qty.toString(), align: pw.TextAlign.center),
              _cell(e.rate.toStringAsFixed(2), align: pw.TextAlign.center),
              _cell(e.totalAmount.toStringAsFixed(2), align: pw.TextAlign.center),
              pw.SizedBox(), 
            ],
          ),
        );
      }

      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100), 
          children: [
            pw.SizedBox(),
            _cell("Subtotal:", align: pw.TextAlign.right, isBold: true),
            _cell(subQty.toString(), align: pw.TextAlign.center, isBold: true),
            pw.SizedBox(),
            _cell("Rs ${subAmount.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
            pw.SizedBox(),
          ],
        ),
      );
      
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.SizedBox(),
            _cell("Disc(%):", align: pw.TextAlign.right, isBold: true),
            _cell("0", align: pw.TextAlign.center, isBold: true), 
            pw.SizedBox(),
            pw.SizedBox(),
            _cell("Rs ${subAmount.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
          ],
        ),
      );
    });

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.green100),
        children: [
          pw.SizedBox(),
          _cell("Grand Total:", align: pw.TextAlign.right, isBold: true),
          _cell(totalQty.toString(), align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
          _cell("Rs ${totalAmount.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
        ],
      ),
    );

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.cyan100),
        children: [
          pw.SizedBox(),
          _cell("Total Discount:", align: pw.TextAlign.right, isBold: true),
          _cell("0.00%", align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
          pw.SizedBox(),
          _cell("Rs ${totalAmount.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FixedColumnWidth(40),
        3: const pw.FixedColumnWidth(50),
        4: const pw.FixedColumnWidth(70),
        5: const pw.FixedColumnWidth(70),
      },
      children: rows,
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
          fontSize: 9,
          color: PdfColors.black,
        ),
      ),
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

  static pw.Widget _buildFooter(PurchaseNotForSaleInvoiceModel data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Invoice Created By: Admin",
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Time Taken: 0 min 44 sec",
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
          ],
        ),
      ],
    );
  }
}
