import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '/Model/sale_mix_report_company_p_model.dart';

class SaleMixCompanyProfitPdf {
  static Future<File> generate(SaleMixReportCompanyPModel data) async {
    final pdf = pw.Document();

    /// 🔹 GROUPING
    Map<String, List<CompanyPItem>> grouped = {};
    for (var item in data.data) {
      String key = "${item.series}|${item.publication}";
      grouped.putIfAbsent(key, () => []).add(item);
    }

    /// 🔹 TOTAL RATE
    double totalRate = data.summary.totalSaleQty == 0
        ? 0
        : data.summary.totalAmount / data.summary.totalSaleQty;

    /// 🔹 NET QTY
    int totalNetQty =
        data.summary.totalSaleQty - data.summary.totalReturnQty;

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [

          /// 🔷 HEADER
          pw.Column(
            children: [
              pw.Row(
                children: [
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
                                "Cont. - 9354918638",
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

              pw.Text("Company Profit Report",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),

              pw.Text(data.schoolName,
                  style: pw.TextStyle(fontSize: 12)),
            ],
          ),

          pw.SizedBox(height: 15),

          /// 🔷 SECTION WISE (LIKE UI CARDS)
          ...grouped.entries.expand((entry) {
            final parts = entry.key.split("|");
            final series = parts[0];
            final pub = parts[1];
            final items = entry.value;

            int subSale = 0;
            int subReturn = 0;
            int subNet = 0;
            double subAmount = 0;
            double subNetAmount = 0;

            for (var e in items) {
              subSale += e.saleQty;
              subReturn += e.returnQty;
              subNet += e.netQty;
              subAmount += e.amount;
              subNetAmount += e.netAmount;
            }

            double subRate = items.isEmpty
                ? 0
                : items.map((e) => e.rate).reduce((a, b) => a + b) /
                items.length;

            return [

              /// 🔹 SECTION HEADER (BLUE)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                color: PdfColor.fromInt(0xFFD0D8E8),
                child: pw.Text(
                  "Series: $series | Publication: $pub",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),

              /// 🔹 TABLE
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FixedColumnWidth(50),
                  2: const pw.FixedColumnWidth(50),
                  3: const pw.FixedColumnWidth(50),
                  4: const pw.FixedColumnWidth(60),
                  5: const pw.FixedColumnWidth(70),
                  6: const pw.FixedColumnWidth(60),
                  7: const pw.FixedColumnWidth(60),
                  8: const pw.FixedColumnWidth(70),
                  9: const pw.FixedColumnWidth(80),
                },
                children: [

                  /// HEADER
                  pw.TableRow(
                    decoration:
                    pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      cell("Book Name", bold: true),
                      cell("Sale", bold: true),
                      cell("Return", bold: true),
                      cell("Net", bold: true),
                      cell("Rate", bold: true),
                      cell("Amount", bold: true),
                      cell("PurDisc", bold: true),
                      cell("SaleDisc", bold: true),
                      cell("ProfitDisc", bold: true),
                      cell("NetAmt", bold: true),
                    ],
                  ),

                  /// DATA
                  ...items.map((e) => pw.TableRow(children: [
                    cell(e.bookName),
                    cell(e.saleQty.toString()),
                    cell(e.returnQty.toString()),
                    cell(e.netQty.toString()),
                    cell(e.rate.toStringAsFixed(2)),
                    cell(e.amount.toStringAsFixed(2)),
                    cell(e.purchaseDiscount.toStringAsFixed(2)),
                    cell(e.saleDiscount.toStringAsFixed(2)),
                    cell(e.profitDiscount.toStringAsFixed(2)),
                    cell(e.netAmount.toStringAsFixed(2)),
                  ])),

                  /// SUBTOTAL
                  pw.TableRow(
                    decoration:
                    pw.BoxDecoration(color: PdfColors.orange100),
                    children: [
                      cell("Subtotal", bold: true),
                      cell(subSale.toString(), bold: true),
                      cell(subReturn.toString(), bold: true),
                      cell(subNet.toString(), bold: true),
                      cell(subRate.toStringAsFixed(2), bold: true),
                      cell(subAmount.toStringAsFixed(2), bold: true),
                      cell(""),
                      cell(""),
                      cell(""),
                      cell(subNetAmount.toStringAsFixed(2),
                          bold: true),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
            ];
          }),

          /// 🔷 GRAND TOTAL
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration:
                pw.BoxDecoration(color: PdfColors.green100),
                children: [
                  cell("Grand Total", bold: true),
                  cell(data.summary.totalSaleQty.toString(), bold: true),
                  cell(data.summary.totalReturnQty.toString(), bold: true),
                  cell(totalNetQty.toString(), bold: true),
                  cell(totalRate.toStringAsFixed(2), bold: true),
                  cell(data.summary.totalAmount.toStringAsFixed(2),
                      bold: true),
                  cell(""),
                  cell(""),
                  cell(""),
                  cell(data.summary.totalNetAmount.toStringAsFixed(2),
                      bold: true),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          /// 🔷 SUMMARY (BOTTOM)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      "MRP Sale: ₹${data.summary.totalAmount.toStringAsFixed(2)}"),
                  pw.Text(
                      "Company Profit: ₹${(data.summary.totalAmount - data.summary.totalNetAmount).toStringAsFixed(2)}"),
                ],
              ),
              pw.Text(
                  "School Se lena Amount: ₹${data.summary.totalNetAmount.toStringAsFixed(2)}"),
            ],
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        "${dir.path}/company_profit_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget cell(String text,
      {bool bold = false, pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight:
          bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}