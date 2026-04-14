import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '/Model/sale_mix_report_mrp_model.dart';

class SaleMixReportPdf {
  static Future<File> generate(SaleMixReportMrpModel data) async {
    final pdf = pw.Document();

    /// 🔹 CALCULATE TOTAL NET QTY (FIXED POSITION)
    int totalNetQty = 0;
    for (var e in data.data) {
      totalNetQty += e.netQty;
    }


    /// 🔹 GROUPING SAME AS UI
    Map<String, List<SaleMixItem>> grouped = {};
    for (var item in data.data) {
      String key = "${item.series}|${item.publication}";
      grouped.putIfAbsent(key, () => []).add(item);
    }

    /// 🔹 SUBTOTAL FUNCTION
    Map<String, dynamic> subtotal(List<SaleMixItem> items) {
      int sale = 0, ret = 0, net = 0;
      double amount = 0, netAmount = 0;

      for (var e in items) {
        sale += e.saleQty;
        ret += e.returnQty;
        net += e.netQty;
        amount += e.amount;
        netAmount += e.netAmount;
      }

      return {
        "sale": sale,
        "ret": ret,
        "net": net,
        "amount": amount,
        "netAmount": netAmount
      };
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
                            "D-1/20, SECTOR 22, GIDA, GORAKHPUR\nCont. - 9354918638",
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
                "Sale Mix Report",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                data.schoolName,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          /// 🔷 TABLE
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FixedColumnWidth(40),
              2: const pw.FixedColumnWidth(40),
              3: const pw.FixedColumnWidth(40),
              4: const pw.FixedColumnWidth(50),
              5: const pw.FixedColumnWidth(60),
              6: const pw.FixedColumnWidth(50),
              7: const pw.FixedColumnWidth(70),
            },
            children: [

              /// HEADER
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  cell("Book Name", bold: true),
                  cell("Sale", bold: true),
                  cell("Return", bold: true),
                  cell("Net", bold: true),
                  cell("Rate", bold: true),
                  cell("Amount", bold: true),
                  cell("Disc%", bold: true),
                  cell("Net Amt", bold: true),
                ],
              ),

              /// GROUP DATA
              ...grouped.entries.expand((entry) {
                final parts = entry.key.split("|");
                final series = parts[0];
                final publication = parts[1];
                final items = entry.value;

                final sub = subtotal(items);

                List<pw.TableRow> rows = [];

                /// 🔹 GROUP HEADER
                rows.add(
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      cell("Series: $series | Publication: $publication",
                          bold: true),
                      ...List.generate(7, (_) => cell("")),
                    ],
                  ),
                );

                for (var e in items) {
                  rows.add(
                    pw.TableRow(
                      children: [
                        cell(e.bookName),
                        cell(e.saleQty.toString()),
                        cell(e.returnQty.toString()),
                        cell(e.netQty.toString()),
                        cell(e.rate.toStringAsFixed(2)),
                        cell(e.amount.toStringAsFixed(2)),
                        cell(e.discount.toStringAsFixed(2)),
                        cell(e.netAmount.toStringAsFixed(2)),
                      ],
                    ),
                  );
                }

                /// 🔹 SUBTOTAL
                rows.add(
                  pw.TableRow(
                    decoration:
                    pw.BoxDecoration(color: PdfColors.orange100),
                    children: [
                      cell("Subtotal", bold: true),
                      cell(sub["sale"].toString(), bold: true),
                      cell(sub["ret"].toString(), bold: true),
                      cell(sub["net"].toString(), bold: true),
                      cell(""),
                      cell(sub["amount"].toStringAsFixed(2), bold: true),
                      cell(""),
                      cell(sub["netAmount"].toStringAsFixed(2),
                          bold: true),
                    ],
                  ),
                );

                return rows;
              }),


              /// GRAND TOTAL
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.green100),
                children: [
                  cell("Grand Total", bold: true),
                  cell(data.totalSaleQty.toString(), bold: true),
                  cell(data.totalReturnQty.toString(), bold: true),
                  cell(totalNetQty.toString(), bold: true),
                  cell(""),
                  cell(data.totalAmount.toStringAsFixed(2), bold: true),
                  cell(""),
                  cell(data.totalNetAmount.toStringAsFixed(2), bold: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File(
        "${dir.path}/sale_mix_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// 🔹 CELL
  static pw.Widget cell(String text,
      {bool bold = false, pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
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