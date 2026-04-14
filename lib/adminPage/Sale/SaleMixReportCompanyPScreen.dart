import 'package:flutter/material.dart';
import '/Model/sale_mix_report_company_p_model.dart';
import '/service/sale_mix_report_company_p_service.dart';
import 'package:share_plus/share_plus.dart';
import '/pdf/salePdf/sale_mix_company_profit_pdf.dart';


class SaleMixReportCompanyPScreen extends StatefulWidget {
  final String schoolId;

  const SaleMixReportCompanyPScreen({super.key, required this.schoolId});

  @override
  State<SaleMixReportCompanyPScreen> createState() =>
      _SaleMixReportCompanyPScreenState();
}

class _SaleMixReportCompanyPScreenState
    extends State<SaleMixReportCompanyPScreen> {
  late Future<SaleMixReportCompanyPModel> future;

  @override
  void initState() {
    super.initState();
    future =
        SaleMixReportCompanyPService.fetchReport(widget.schoolId);
  }
  Future<void> shareReport(SaleMixReportCompanyPModel data) async {
    final file = await SaleMixCompanyProfitPdf.generate(data);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Company Profit Report",
    );
  }

  // ================= HEADER =================

  Widget reportHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: const [
            Icon(Icons.menu_book_sharp, size: 45, color: Colors.brown),
            SizedBox(height: 4),
            Text(
              "BOOK WORLD",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: const [
              Text(
                "GJ BOOK WORLD PVT. LTD.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B4C7E)),
              ),
              SizedBox(height: 6),
              Text(
                "D-1/20, SECTOR 22, GIDA, GORAKHPUR\n"
                    "Cont. - 9354918638, 9354918644\n"
                    "GST No: 09AAGCG0650B1Z2 | CIN No: U22222UP2015PTC068597",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= COMMON =================

  Widget th(String text) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text,
        textAlign: TextAlign.center,
        style:
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
  );

  Widget td(String text,
      {TextAlign align = TextAlign.center,
        FontWeight weight = FontWeight.normal}) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text,
            textAlign: align,
            style: TextStyle(fontSize: 12, fontWeight: weight)),
      );

  // ================= GROUP =================

  Map<String, List<CompanyPItem>> groupData(List<CompanyPItem> list) {
    final map = <String, List<CompanyPItem>>{};
    for (var item in list) {
      final key = "${item.series}|${item.publication}";
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width > 800
        ? MediaQuery.of(context).size.width - 32
        : 1200;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Company Profit Report"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await future;
              if (data != null) {
                await shareReport(data);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<SaleMixReportCompanyPModel>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No Data Found"));
          }

          final data = snapshot.data!;
          final grouped = groupData(data.data);
          double totalRate = data.summary.totalSaleQty == 0
              ? 0
              : data.summary.totalAmount / data.summary.totalSaleQty;


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    /// HEADER
                    reportHeader(),
                    const SizedBox(height: 10),
                    const Divider(thickness: 2),
                    const SizedBox(height: 10),

                    const Text("Company Profit Report",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(data.schoolName),
                    const SizedBox(height: 20),

                    /// 🔥 SECTION WISE UI
                    ...grouped.entries.map((entry) {
                      final parts = entry.key.split("|");
                      final series = parts[0];
                      final pub = parts[1];
                      final items = entry.value;

                      int subSale = 0;
                      int subReturn = 0;
                      int subNet = 0;
                      double subRate = 0;
                      double subAmount = 0;
                      double subNetAmount = 0;

                      for (var e in items) {
                        subSale += e.saleQty;
                        subReturn += e.returnQty;
                        subNet += e.netQty;
                        subRate += e.rate;
                        subAmount += e.amount;
                        subNetAmount += e.netAmount;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, blurRadius: 4)
                          ],
                        ),
                        child: Column(
                          children: [
                            /// BLUE HEADER
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD0D8E8),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Series: $series   |   Publication: $pub",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                            /// TABLE
                            Table(
                              border:
                              TableBorder.all(color: Colors.black87),
                              columnWidths: const {
                                0: FlexColumnWidth(4),
                                1: FixedColumnWidth(70),
                                2: FixedColumnWidth(70),
                                3: FixedColumnWidth(70),
                                4: FixedColumnWidth(80),
                                5: FixedColumnWidth(100),
                                6: FixedColumnWidth(80),
                                7: FixedColumnWidth(80),
                                8: FixedColumnWidth(90),
                                9: FixedColumnWidth(110),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200),
                                  children: [
                                    th("Book Name"),
                                    th("Sale Qty"),
                                    th("Return Qty"),
                                    th("Net Sale"),
                                    th("Rate"),
                                    th("Amount"),
                                    th("PurDisc %"),
                                    th("SaleDisc %"),
                                    th("ProfitDisc %"),
                                    th("Net Amount"),
                                  ],
                                ),

                                ...items.map((e) => TableRow(children: [
                                  td(e.bookName,
                                      align: TextAlign.left),
                                  td(e.saleQty.toString()),
                                  td(e.returnQty.toString()),
                                  td(e.netQty.toString()),
                                  td(e.rate.toStringAsFixed(2)),
                                  td(e.amount.toStringAsFixed(2)),
                                  td(e.purchaseDiscount
                                      .toStringAsFixed(2)),
                                  td(e.saleDiscount
                                      .toStringAsFixed(2)),
                                  td(e.profitDiscount
                                      .toStringAsFixed(2)),
                                  td(e.netAmount
                                      .toStringAsFixed(2)),
                                ])),

                                /// SUBTOTAL
                                TableRow(
                                  decoration: BoxDecoration(
                                      color: Colors.orange.shade50),
                                  children: [
                                    td("Subtotal:",
                                        align: TextAlign.right,
                                        weight: FontWeight.bold),
                                    td(subSale.toString(),
                                        weight: FontWeight.bold),
                                    td(subReturn.toString(),
                                        weight: FontWeight.bold),
                                    td(subNet.toString(),
                                        weight: FontWeight.bold),
                                    td(subRate.toStringAsFixed(2),
                                        weight: FontWeight.bold),
                                    td(subAmount.toStringAsFixed(2),
                                        weight: FontWeight.bold),
                                    td("0.00",
                                        weight: FontWeight.bold),
                                    td("0.00",
                                        weight: FontWeight.bold),
                                    td("0.00",
                                        weight: FontWeight.bold),
                                    td(subNetAmount.toStringAsFixed(2),
                                        weight: FontWeight.bold),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),


                    /// GRAND TOTAL
                    Column(
                      children: [

                        /// 🔹 GRAND TOTAL TABLE ROW
                        Table(
                          border: TableBorder.all(color: Colors.black),
                          columnWidths: const {
                            0: FlexColumnWidth(4),
                            1: FixedColumnWidth(70),
                            2: FixedColumnWidth(70),
                            3: FixedColumnWidth(70),
                            4: FixedColumnWidth(100),
                            5: FixedColumnWidth(120),
                            6: FixedColumnWidth(80),
                            7: FixedColumnWidth(80),
                            8: FixedColumnWidth(90),
                            9: FixedColumnWidth(120),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.green.shade100),
                              children: [
                                _gtCell("Grand Total"),
                                _gtCell(data.summary.totalSaleQty.toString()),
                                _gtCell(data.summary.totalReturnQty.toString()),
                                _gtCell(data.summary.totalSaleQty.toString()),
                                _gtCell(totalRate.toStringAsFixed(2)),
                                _gtCell(data.summary.totalAmount.toStringAsFixed(2)),
                                _gtCell("5.75"), // or dynamic
                                _gtCell("0.00"),
                                _gtCell("5.75"),
                                _gtCell(data.summary.totalNetAmount.toStringAsFixed(2)),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        /// 🔹 BOTTOM SUMMARY TEXT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// LEFT SIDE
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "MRP Sale: ₹${data.summary.totalAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Company Profit: ₹${(data.summary.totalAmount - data.summary.totalNetAmount).toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),

                            /// RIGHT SIDE
                            Text(
                              "School Se lena Amount: ₹${data.summary.totalNetAmount.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _gtCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}