import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../Model/purchase_invoice_mrp_model.dart';

class PurchaseInvoicePdf {
  static Future<File> generate(PurchaseInvoiceMrpModel invoice) async {
    final pdf = pw.Document();
    
    String formattedDate = DateFormat('dd-MM-yyyy').format(invoice.date);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 16),
          _buildInvoiceTitle(),
          pw.SizedBox(height: 16),
          _buildInfoTable(invoice, formattedDate),
          pw.SizedBox(height: 16),
          _buildItemsTable(invoice),
          pw.SizedBox(height: 24),
          _buildFooter(invoice),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/invoice_${invoice.billNo}.pdf");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
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
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.normal, color: PdfColors.black),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638, 9354918644\nGST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800, lineSpacing: 2),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 50), // Balance header
      ],
    );
  }

  static pw.Widget _buildInvoiceTitle() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.black, thickness: 1.5),
        pw.SizedBox(height: 12),
        pw.Center(
          child: pw.Text(
            "Purchase MRP Invoice",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _buildInfoTable(PurchaseInvoiceMrpModel invoice, String formattedDate) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey800, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            _infoCell("Invoice No: ", invoice.billNo),
            _infoCell("Supplier: ", invoice.publication),
            _infoCell("Bill Date: ", formattedDate),
          ],
        ),
        pw.TableRow(
          children: [
            _infoCell("Supplier Invoice No: ", "2254"),
            _infoCell("Address: ", "NO"),
            _infoCell("Rec. Date: ", formattedDate),
          ],
        ),
        pw.TableRow(
          children: [
            _infoCell("ChallanNo: ", ""),
            _infoCell("Transport: ", "MITTAL ROADWAYS"),
            _infoCell("GR No: ", "OO37822"),
          ],
        ),
        pw.TableRow(
          children: [
            _infoCell("Recived Box: ", "7"),
            _infoCell("", ""), // Empty cell
            _infoCell("Pending Box: ", ""),
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
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
          children: [
            pw.TextSpan(
              text: label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildItemsTable(PurchaseInvoiceMrpModel invoice) {
    Map<String, List<PurchaseItem>> groupedItems = {};
    for (var item in invoice.data) {
      if (!groupedItems.containsKey(item.series)) {
        groupedItems[item.series] = [];
      }
      groupedItems[item.series]!.add(item);
    }

    List<pw.TableRow> rows = [];

    // Header Row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          _headerCell("S.N.", isBold: true),
          _headerCell("Book Name (Title)", isBold: true),
          _headerCell("Qty", isBold: true),
          _headerCell("Rate", isBold: true),
          _headerCell("Amount", isBold: true),
          _headerCell("Amt With\nDisc.", isBold: true),
        ],
      ),
    );

    int sn = 1;
    double totalQty = 0;
    double totalAmount = 0;

    groupedItems.forEach((series, items) {
      // Series Header Row
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            pw.SizedBox(),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: pw.Text(
                "Series: $series",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black, fontSize: 10),
              ),
            ),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
            pw.SizedBox(),
          ],
        ),
      );

      // Books in Series
      for (var item in items) {
        double amount = item.qty * item.rate;
        totalQty += item.qty;
        totalAmount += amount;

        rows.add(
          pw.TableRow(
            children: [
              _itemCell(sn.toString(), align: pw.TextAlign.center),
              _itemCell("${item.bookName} - ${item.subject} - Class ${item.classes}"),
              _itemCell(item.qty.toString(), align: pw.TextAlign.center),
              _itemCell(item.rate.toStringAsFixed(2), align: pw.TextAlign.right),
              _itemCell(amount.toStringAsFixed(2), align: pw.TextAlign.right),
              _itemCell(""), // Amt With Disc placeholder
            ],
          ),
        );
        sn++;
      }
    });

    // Subtotal Row
    rows.add(
      pw.TableRow(
        children: [
          pw.SizedBox(),
          _itemCell("Subtotal:", align: pw.TextAlign.right, isBold: true),
          _itemCell(totalQty.toStringAsFixed(0), align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
          _itemCell("Rs ${totalAmount.toStringAsFixed(2)}", align: pw.TextAlign.right, isBold: true),
          pw.SizedBox(),
        ],
      ),
    );

    // Disc(%) Row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue50),
        children: [
          pw.SizedBox(),
          _itemCell("Disc(%) :", align: pw.TextAlign.right, isBold: true),
          _itemCell("0", align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
          pw.SizedBox(),
          _itemCell("Rs ${totalAmount.toStringAsFixed(2)}", align: pw.TextAlign.right, isBold: true),
        ],
      ),
    );

    // Grand Total Row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.green50),
        children: [
          pw.SizedBox(),
          _itemCell("Grand Total:", align: pw.TextAlign.right, isBold: true),
          _itemCell(totalQty.toStringAsFixed(0), align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
          _itemCell("Rs ${totalAmount.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
        ],
      ),
    );

    // Total Discount Row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.lightBlue50),
        children: [
          pw.SizedBox(),
          _itemCell("Total Discount:", align: pw.TextAlign.right, isBold: true),
          _itemCell("0%", align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
          pw.SizedBox(),
          _itemCell("Rs ${totalAmount.toStringAsFixed(2)}", align: pw.TextAlign.right, isBold: true),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey800, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FixedColumnWidth(40),
        3: const pw.FixedColumnWidth(50),
        4: const pw.FixedColumnWidth(60),
        5: const pw.FixedColumnWidth(60),
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
          fontSize: 10,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _itemCell(String text, {pw.TextAlign align = pw.TextAlign.left, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
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

  static pw.Widget _buildFooter(PurchaseInvoiceMrpModel invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
                children: [
                  pw.TextSpan(text: "Invoice Created By: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  const pw.TextSpan(text: "Admin"),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
                children: [
                  pw.TextSpan(text: "Time Taken: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  const pw.TextSpan(text: "1 min 55 sec"),
                ],
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
                children: [
                  pw.TextSpan(text: "After Discount: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: "Rs ${invoice.grandTotal.toStringAsFixed(2)}"),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
                children: [
                  pw.TextSpan(text: "Total Discount Amount: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  const pw.TextSpan(text: "Rs 0.00"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}