import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../Model/purchase_details_discount_invoice_model.dart';

class PurchaseDiscountInvoicePdf {
  static Future<File> generate(PurchaseDetailsDiscountInvoiceModel data) async {
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
    final file = File("${dir.path}/discount_invoice_${data.billNo}.pdf");

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
            "Purchase Discount Invoice",
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

  static pw.Widget _buildInfoTable(PurchaseDetailsDiscountInvoiceModel data, String formattedDate) {
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
            _infoCell("Supplier Invoice No: ", ""),
            _infoCell("Address: ", "D-247/8 SECTOR63, NOIDA 201301"),
            _infoCell("Rec. Date: ", formattedDate),
          ],
        ),
        pw.TableRow(
          children: [
            _infoCell("Challan No: ", ""),
            _infoCell("Transport: ", "SAFE EXPRESS"),
            _infoCell("GR No: ", ""),
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

  static pw.Widget _buildItemsTable(PurchaseDetailsDiscountInvoiceModel data) {
    Map<String, List<PurchaseItem>> grouped = {};
    for (var item in data.data) {
      if (!grouped.containsKey(item.series)) {
        grouped[item.series] = [];
      }
      grouped[item.series]!.add(item);
    }

    List<pw.TableRow> rows = [];

    // Header
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
    double totalDiscountAmount = 0;
    double totalAmtWithDisc = 0;

    grouped.forEach((series, items) {
      double subQty = 0;
      double subAmount = 0;
      double subDiscAmount = 0;
      double subAmtWithDisc = 0;

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
        
        double itemDiscAmount = e.totalAmount * (e.publicationDiscount / 100);
        double itemAmtWithDisc = e.totalAmount - itemDiscAmount;
        
        subDiscAmount += itemDiscAmount;
        subAmtWithDisc += itemAmtWithDisc;

        totalQty += e.qty;
        totalAmount += e.totalAmount;
        totalDiscountAmount += itemDiscAmount;
        totalAmtWithDisc += itemAmtWithDisc;

        rows.add(
          pw.TableRow(
            children: [
              _cell("${index++}", align: pw.TextAlign.center),
              _cell("${e.bookName} - ${e.subject} - ${e.classes}", align: pw.TextAlign.left),
              _cell(e.qty.toString(), align: pw.TextAlign.center),
              _cell(e.rate.toStringAsFixed(2), align: pw.TextAlign.center),
              _cell(e.totalAmount.toStringAsFixed(2), align: pw.TextAlign.center),
              _cell(itemAmtWithDisc.toStringAsFixed(2), align: pw.TextAlign.center),
            ],
          ),
        );
      }

      double avgDiscSeries = subAmount > 0 ? (subDiscAmount / subAmount) * 100 : 0;

      // SUBTOTAL
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.orange100),
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
      
      // DISC(%)
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            pw.SizedBox(),
            _cell("Disc(%):", align: pw.TextAlign.right, isBold: true),
            _cell(avgDiscSeries.toStringAsFixed(1), align: pw.TextAlign.center, isBold: true),
            pw.SizedBox(),
            pw.SizedBox(),
            _cell("Rs ${subAmtWithDisc.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
          ],
        ),
      );
    });

    // GRAND TOTAL
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

    // TOTAL DISCOUNT
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.cyan100),
        children: [
          pw.SizedBox(),
          _cell("Total Discount:", align: pw.TextAlign.right, isBold: true),
          _cell(totalAmount > 0 ? "${((totalDiscountAmount / totalAmount) * 100).toStringAsFixed(1)}%" : "0%", align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
          pw.SizedBox(),
          _cell("Rs ${totalAmtWithDisc.toStringAsFixed(2)}", align: pw.TextAlign.center, isBold: true),
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

  static pw.Widget _buildFooter(PurchaseDetailsDiscountInvoiceModel data) {
    double totalQty = 0;
    double totalAmount = 0;
    double totalDiscountAmount = 0;
    double totalAmtWithDisc = 0;

    for (var item in data.data) {
      double itemDiscAmount = item.totalAmount * (item.publicationDiscount / 100);
      double itemAmtWithDisc = item.totalAmount - itemDiscAmount;
      
      totalQty += item.qty;
      totalAmount += item.totalAmount;
      totalDiscountAmount += itemDiscAmount;
      totalAmtWithDisc += itemAmtWithDisc;
    }

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
              "Time Taken: 1 min 1 sec",
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "After Discount: Rs ${totalAmtWithDisc.toStringAsFixed(2)}",
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Total Discount Amount: Rs ${totalDiscountAmount.toStringAsFixed(2)}",
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
          ],
        ),
      ],
    );
  }
}