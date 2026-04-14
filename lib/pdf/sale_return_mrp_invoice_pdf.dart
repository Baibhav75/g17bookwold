import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../model/sale_return_mrp_invoice_model.dart'; // Make sure this path is correct

class SaleReturnMrpInvoicePdf {
  static Future<File> generate(SaleReturnMrpInvoiceModel data) async {
    final pdf = pw.Document();

    String formattedDate = data.master.date;
    try {
      if (data.master.date.contains("T")) {
        final d = DateTime.parse(data.master.date);
        formattedDate = "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
      } else {
        final d = DateTime.parse(data.master.date);
        formattedDate = "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
      }
    } catch (e) {
      // Ignored
    }

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
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/sale_return_mrp_invoice_${data.master.billNo}.pdf");

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
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638, 9354918644\nGST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: 10, color: PdfColors.black, lineSpacing: 2),
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
            "Sale Return Invoice",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoTable(SaleReturnMrpInvoiceModel data, String formattedDate) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            _infoCell("Invoice No: ", data.master.billNo),
            _infoCell("Party Name: ", data.master.schoolName),
            _infoCell("Bill Date: ", formattedDate),
          ],
        ),
        pw.TableRow(
          children: [
            _infoCell("Transport: ", data.master.transport),
            _infoCell("Address: ", data.master.address),
            _infoCell("Rec. Date: ", formattedDate),
          ],
        ),
        pw.TableRow(
          children: [
            pw.SizedBox(),
            _infoCell("Remark: ", ""),
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
        textAlign: pw.TextAlign.center,
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
          children: [
            pw.TextSpan(
              text: label,
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildItemsTable(SaleReturnMrpInvoiceModel data) {
    Map<String, List<SaleReturnItem>> grouped = {};
    for (var item in data.items) {
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
    double totalDiscountAmount = 0; // If any discount logic applies
    double totalAmountWithDiscount = 0;

    grouped.forEach((series, items) {
      double subQty = 0;
      double subAmount = 0;
      double subAmountWithDiscount = 0;

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
        
        // Calculate amount with discount (if discount exists, handled below)
        double itemDiscAmount = (e.totalAmount * e.discount) / 100;
        double itemAmountWithDiscount = e.totalAmount - itemDiscAmount;
        
        subAmountWithDiscount += itemAmountWithDiscount;

        totalQty += e.qty;
        totalAmount += e.totalAmount;
        totalAmountWithDiscount += itemAmountWithDiscount;
        totalDiscountAmount += itemDiscAmount;

        rows.add(
          pw.TableRow(
            children: [
              _cell("${index++}", align: pw.TextAlign.center),
              _cell("${e.bookName} - ${e.subject} - ${e.classes}",
                  align: pw.TextAlign.left),
              _cell(e.qty.toString(), align: pw.TextAlign.center),
              _cell(e.rate.toStringAsFixed(2), align: pw.TextAlign.center),
              _cell(e.totalAmount.toStringAsFixed(2),
                  align: pw.TextAlign.center),
              pw.SizedBox(), // Detail rows don't show amt with disc typically based on image, or empty
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
            _cell("Rs ${subAmount.toStringAsFixed(2)}",
                align: pw.TextAlign.center, isBold: true),
            pw.SizedBox(),
          ],
        ),
      );

      if (items.isNotEmpty && items.first.discount > 0) {
        rows.add(
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blue50),
            children: [
              pw.SizedBox(),
              _cell("Disc(%):", align: pw.TextAlign.right, isBold: true),
              _cell("${items.first.discount.toStringAsFixed(2)}%", align: pw.TextAlign.center, isBold: true),
              pw.SizedBox(),
              pw.SizedBox(),
              _cell("Rs ${subAmountWithDiscount.toStringAsFixed(2)}",
                  align: pw.TextAlign.center, isBold: true),
            ],
          ),
        );
      } else {
         rows.add(
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blue50),
            children: [
              pw.SizedBox(),
              _cell("Disc(%):", align: pw.TextAlign.right, isBold: true),
              _cell("0", align: pw.TextAlign.center, isBold: true),
              pw.SizedBox(),
              pw.SizedBox(),
              _cell("Rs ${subAmount.toStringAsFixed(2)}",
                  align: pw.TextAlign.center, isBold: true),
            ],
          ),
        );
      }
    });

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.green100),
        children: [
          pw.SizedBox(),
          _cell("Grand Total:", align: pw.TextAlign.right, isBold: true),
          _cell(totalQty.toString(), align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
          _cell("Rs ${totalAmount.toStringAsFixed(2)}",
              align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
        ],
      ),
    );

    double finalDiscountPct = totalAmount > 0 ? (totalDiscountAmount / totalAmount * 100) : 0.0;

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.cyan100),
        children: [
          pw.SizedBox(),
          _cell("Total Discount:", align: pw.TextAlign.right, isBold: true),
          _cell("${finalDiscountPct.toStringAsFixed(2)}%", align: pw.TextAlign.center, isBold: true),
          pw.SizedBox(),
          pw.SizedBox(),
          _cell("Rs ${totalAmountWithDiscount.toStringAsFixed(2)}",
              align: pw.TextAlign.center, isBold: true),
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

  static pw.Widget _cell(String text,
      {pw.TextAlign align = pw.TextAlign.left, bool isBold = false}) {
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
}
