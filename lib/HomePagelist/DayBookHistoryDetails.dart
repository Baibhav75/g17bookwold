import 'package:flutter/material.dart';
import '../Model/daybook_history_details_model.dart';
import '../Service/daybook_history_details_service.dart';
import '/pdf/daybook_history_details_pdf.dart';

class DayBookHistoryDetailsScreen extends StatefulWidget {
  final String mobileNo;

  const DayBookHistoryDetailsScreen({super.key, required this.mobileNo});

  @override
  State<DayBookHistoryDetailsScreen> createState() =>
      _DayBookHistoryDetailsScreenState();
}

class _DayBookHistoryDetailsScreenState
    extends State<DayBookHistoryDetailsScreen> {

  late Future<DayBookDetailsResponse?> future;

  @override
  void initState() {
    super.initState();
    future = DayBookDetailsService.fetchDetails(widget.mobileNo);
  }

  String formatDate(String raw) {
    final dt = DateTime.parse(raw);
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  Widget cell(
      String text, {
        Color? color,
        bool bold = false,
        TextAlign align = TextAlign.left,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      alignment: align == TextAlign.right
          ? Alignment.centerRight
          : align == TextAlign.center
          ? Alignment.center
          : Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        textAlign: align,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Day Book History Details '),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await future;
              if (data != null) {
                await DayBookHistoryDetailsPdf.generateAndShare(data);
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                /// 🔴 HEADER (ADD HERE)
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: const [
                      Icon(Icons.menu_book_sharp,
                          size: 45, color: Colors.brown),
                      Text(
                        "BOOK WORLD",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        "GJ BOOK WORLD PVT. LTD.",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Contact No: 8303173797, 8303173799",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "E-Mail: gjbookworld@gmail.com",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              /// 🔴 TITLE
              const Center(
                child: Text(
                  "SUPPLY INVOICE",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),
              Table(

              border: TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: FixedColumnWidth(60),
                  1: FixedColumnWidth(120),
                  2: FixedColumnWidth(180),
                  3: FixedColumnWidth(100),
                  4: FixedColumnWidth(100),
                  5: FixedColumnWidth(120),
                  6: FixedColumnWidth(120),
                  7: FixedColumnWidth(120),
                  8: FixedColumnWidth(140),
                  9: FixedColumnWidth(300),
                },
                children: [

                  /// 🔵 HEADER
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue.shade200),
                    children: [
                      cell("Sr No", bold: true, align: TextAlign.center),
                      cell("Date & Time", bold: true, align: TextAlign.center),
                      cell("Particular", bold: true),
                      cell("Debit", bold: true, align: TextAlign.right),
                      cell("Credit", bold: true, align: TextAlign.right),
                      cell("Total Balance", bold: true, align: TextAlign.right),
                      cell("Expense Voucher No", bold: true, align: TextAlign.center),
                      cell("Receipt Voucher No", bold: true, align: TextAlign.center),
                      cell("Mobile No", bold: true, align: TextAlign.center),
                      cell("Remarks", bold: true),
                    ],
                  ),

                  /// 🔵 DATA ROWS
                  ...data.data.asMap().entries.map((e) {
                    int i = e.key;
                    var item = e.value;

                    return TableRow(
                      children: [
                        cell("${i + 1}", align: TextAlign.center),
                        cell(formatDate(item.date), align: TextAlign.center),
                        cell(item.name),

                        cell(
                          item.flag == "Debit" ? "₹${item.amount}" : "",
                          color: Colors.red,
                          align: TextAlign.right,
                        ),

                        cell(
                          item.flag == "Credit" ? "₹${item.amount}" : "",
                          color: Colors.green,
                          align: TextAlign.right,
                        ),

                        cell("", align: TextAlign.right),
                        cell(item.expNo, align: TextAlign.center),
                        cell(item.recNo, align: TextAlign.center),
                        cell(item.mobileNo, align: TextAlign.center),
                        cell(item.remarks),
                      ],
                    );

                  }).toList(),

                  /// 🔵 TOTAL ROW
                  TableRow(
                    decoration: const BoxDecoration(color: Colors.black12),
                    children: [
                      cell(""),
                      cell(""),
                      cell("Total", bold: true),
                      cell("₹${data.totalDebit}", bold: true),
                      cell("₹${data.totalCredit}", bold: true),
                      cell(""),
                      cell(""),
                      cell(""),
                      cell(""),
                      cell(""),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(color: Colors.yellow.shade100),
                    children: [
                      cell(""),
                      cell(""),
                      cell("Final Balance", bold: true),
                      cell(""),
                      cell(""),
                      cell("₹${data.balance}",
                          bold: true,
                          align: TextAlign.right,
                          color: Colors.blue),
                      cell(""),
                      cell(""),
                      cell(""),
                      cell(""),
                    ],
                  ),
                ],
              ),
                ]
            ),
            ),

          );
        },
      ),
    );
  }
}