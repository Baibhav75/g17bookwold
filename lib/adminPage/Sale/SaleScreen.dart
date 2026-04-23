import 'package:bookworld/adminPage/Sale/saleHistoryList.dart';
import 'package:bookworld/adminPage/Sale/sale_history_details_page.dart';
import 'package:bookworld/adminPage/Sale/sale_invoice_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../AccountSaleHodScreen/sale_return_list_screen.dart';
import '../AccountSaleHodScreen/sale_sample_not_for_sale_screen.dart';
import '../AccountSaleHodScreen/sale_sample_return_list_screen.dart';
import '../AccountSaleHodScreen/sample_sale_billing_screen.dart';
import '../Sale/SaleInvoice.dart';
import '../Sale/SampleSaleInvoice.dart';
import 'EnterysaleScreen.dart';
import 'SaleInvoiceIndividuleHistory.dart';

class SaleManagementPage extends StatelessWidget {
  const SaleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B46C1),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Sale Management",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          /// SALE SECTION
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: ExpansionTile(
              title: Text(
                "Sale",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              children: [
                _saleItem(
                  context,
                  1,
                  "Sale Invoice Individual",
                  const SaleInvoiceIndividuleScreen (),
                ),

                _saleItem(
                  context,
                  1,
                  "Sale Club View",
                  const SaleInvoiceClubHistoryScreen (),
                ),

                _saleItem(
                  context,
                  2,
                  "Sale Brand Sample Billing",
                  const SampleSaleBillingScreen(),
                ),

                _saleItem(
                  context,
                  3,
                  "Sale Sample Not For Sale",
                  const SaleSampleNotForSaleScreen(), // replace with correct page
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// SALE RETURN SECTION
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: ExpansionTile(
              title: Text(
                "Sale Return",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              children: [

                _saleItem(
                  context,
                  1,
                  "Sale Return",
                  const SaleReturnListScreen(), // replace page
                ),

                _saleItem(
                  context,
                  2,
                  "Sample Billing Sale Return",
                  const SaleSampleReturnListScreen(), // replace page
                ),

                _saleItem(
                  context,
                  3,
                  "Sale Sample Not For Return",
                  const SaleSampleReturnListScreen(), // replace page
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// COMMON SALE ITEM
  Widget _saleItem(
      BuildContext context,
      int index,
      String title,
      Widget page,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: InkWell(
        borderRadius: BorderRadius.circular(10),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),

          child: Row(
            children: [

              /// NUMBER BADGE
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,

                decoration: const BoxDecoration(
                  color: Color(0xFF6B46C1),
                  shape: BoxShape.circle,
                ),

                child: Text(
                  index.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// TITLE
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}