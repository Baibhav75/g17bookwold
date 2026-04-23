import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '/Model/sale_pending_mix_order_model.dart';

class SalePendingMixPdfService {

  /// ================= MAIN FUNCTION =================
  static Future<void> generateAndShare(SalePendingMixOrderModel data) async {
    final pdf = pw.Document();

    final grouped = _groupData(data.data);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),

        build: (context) => [

          /// ================= HEADER =================
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Column(
                children: [
                  pw.Icon(pw.IconData(0xe865)), // optional icon
                  pw.Text("BOOK WORLD",
                      style: pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.SizedBox(width: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    "GJ BOOK WORLD PVT. LTD.",
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "D-1/20, SECTOR 22, GIDA, GORAKHPUR\n"
                        "Cont. - 9354918638, 9354918644\n"
                        "GST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "Sale and Order Pending Mix Report",
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          pw.Center(
            child: pw.Text(
              data.schoolName,
              style: pw.TextStyle(fontSize: 12),
            ),
          ),

          pw.SizedBox(height: 15),

          /// ================= TABLE =================
          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
            },
            children: [

              /// HEADER
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _th("Book Name"),
                  _th("Total"),
                  _th("Sale"),
                  _th("Pending"),
                  _th("Rate"),
                ],
              ),

              /// DATA GROUP
              ...grouped.entries.expand((entry) {
                final parts = entry.key.split("|");
                final series = parts[0];
                final pub = parts[1];
                final items = entry.value;

                int subOrder = 0;
                int subSale = 0;
                int subPending = 0;
                double subRate = 0;

                List<pw.TableRow> rows = [];

                /// SERIES HEADER
                rows.add(
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          "Series: $series | Publication: $pub",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9),
                        ),
                      ),
                      ...List.generate(4, (_) => pw.SizedBox()),
                    ],
                  ),
                );

                /// ROWS
                for (var e in items) {
                  int pendingVal =
                      int.tryParse(e.pending.replaceAll("+", "")) ?? 0;

                  subOrder += e.totalOrder;
                  subSale += e.sale;
                  subPending += pendingVal;
                  subRate += e.rate;

                  rows.add(
                    pw.TableRow(
                      children: [
                        _td(e.bookName, alignLeft: true),
                        _td(e.totalOrder.toString()),
                        _td(e.sale.toString()),
                        _td(e.pending),
                        _td(e.rate.toStringAsFixed(2)),
                      ],
                    ),
                  );
                }

                /// SUBTOTAL
                rows.add(
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.orange50),
                    children: [
                      _td("Subtotal:", bold: true),
                      _td(subOrder.toString(), bold: true),
                      _td(subSale.toString(), bold: true),
                      _td("+$subPending", bold: true),
                      _td(subRate.toStringAsFixed(2), bold: true),
                    ],
                  ),
                );

                return rows;
              }),

              /// GRAND TOTAL
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green100),
                children: [
                  _td("Grand Total:", bold: true),
                  _td(data.summary.totalOrder.toString(), bold: true),
                  _td(data.summary.totalSale.toString(), bold: true),
                  _td(data.summary.totalPending.toString(), bold: true),
                  _td(data.summary.totalRate.toStringAsFixed(2), bold: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    /// ================= SAVE =================
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/sale_pending_mix.pdf");

    await file.writeAsBytes(await pdf.save());

    /// ================= SHARE =================
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Sale Pending Mix Report",
    );
  }

  /// ================= GROUP =================
  static Map<String, List<SalePendingItem>> _groupData(
      List<SalePendingItem> list) {
    final map = <String, List<SalePendingItem>>{};
    for (var item in list) {
      final key = "${item.series}|${item.publication}";
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// ================= TABLE DESIGN =================
  static pw.Widget _th(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold, fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _td(String text,
      {bool bold = false, bool alignLeft = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 9,
        ),
        textAlign:
        alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
      ),
    );
  }
}