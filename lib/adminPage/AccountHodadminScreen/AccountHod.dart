import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../HomePagelist/addDayBook.dart';
import '../../HomePagelist/dayBookHistory.dart';
import '../Sale/SaleScreen.dart';
import 'AccountHodAddCashier.dart';
import 'PURCHASE.dart';

class AccountHodScreen extends StatelessWidget {
  const AccountHodScreen({super.key});

  /// OPTIONS
  static final List<Map<String, dynamic>> _options = [
    {
      "title": "PURCHASE",
      "icon": Icons.shopping_bag,
      "color": Colors.orange,
    },
    {
      "title": "SALE",
      "icon": Icons.point_of_sale,
      "color": Colors.green,
    },
    {
      "title": "CASH BOOK\nHISTORY",
      "icon": Icons.account_balance_wallet,
      "color": Colors.blue,
    },
    {
      "title": "ADD DAY\nBOOK",
      "icon": Icons.add_business,
      "color": Colors.deepPurple,
    },
    {
      "title": "EXPENSE",
      "icon": Icons.money_off,
      "color": Colors.red,
    },
    {
      "title": "REVENUE",
      "icon": Icons.trending_up,
      "color": Colors.teal,
    },
    {
      "title": "ADD CASHIER",
      "icon": Icons.money,
      "color": Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        title: Text(
          "Account HOD",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: _buildAccountHodSection(context),
      ),
    );
  }

  /// MAIN CONTAINER
  Widget _buildAccountHodSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE
          Text(
            "Account Management",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10.h),

          /// GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _options.length,

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 4.h,
              childAspectRatio: 0.50,
            ),

            itemBuilder: (context, index) {
              final item = _options[index];

              return InkWell(
                onTap: () => _navigate(context, item["title"]),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    /// ICON CARD
                    Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: (item["color"] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        item["icon"],
                        size: 32.sp,
                        color: item["color"],
                      ),
                    ),

                    SizedBox(height: 8.h),

                    /// TITLE
                    Text(
                      item["title"],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// NAVIGATION
  void _navigate(BuildContext context, String title) {
    switch (title) {

      case "PURCHASE":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PurchaseManagementPage(),
          ),
        );
        break;

      case "SALE":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SaleManagementPage(),
          ),
        );
        break;

      case "CASH BOOK\nHISTORY":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DayBookHistory(),
          ),
        );
        break;

      case "ADD DAY\nBOOK":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddDayBook(),
          ),
        );
        break;

      case "ADD CASHIER":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CashierScreen (),
          ),
        );
        break;
    }
  }
}

  /// CARD WIDGET
  Widget _optionCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 24.sp,
                color: color,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
