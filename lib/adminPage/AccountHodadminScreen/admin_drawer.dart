import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../BilingPurchase/PurchaseInvoice.dart';
import '../BilingPurchase/purchaseNotForSale.dart';
import '../BilingPurchase/PurchaseSampleRevenew.dart';
import '../PurchaseReturn/PurchaseReturnInvoide.dart';
import '../PurchaseReturn/PurchaseReturnNotForSale.dart';
import '../PurchaseReturn/PurchaseReturnSampleRevenue.dart';
import '../Sale/SaleInvoice.dart';
import '../Sale/SampleSaleInvoice.dart';
import '../SellReturn/SaleReturnInvoice.dart';
import '../SellReturn/SamplesaleReturnInvoice.dart';
import '../ViewProductList.dart';
import '../ViewCompanyPage.dart';
import '../HRMViewEmployee.dart';
import '../in_out_management_page.dart';
import '../interviewList.dart';
import '../sell_school_list_page.dart';
import '../../staffPage/staffhistory.dart';
import '../publication_agreement_page.dart';
import 'HrmHodScreen.dart';

class AdminDrawer extends StatelessWidget {
  final String adminName;
  final String adminEmail;
  final String mobileNo;
  final VoidCallback onLogout;

  const AdminDrawer({
    super.key,
    required this.adminName,
    required this.adminEmail,
    required this.mobileNo,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          /// HEADER
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF6B46C1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 30.sp,
                    color: const Color(0xFF6B46C1),
                  ),
                ),
                SizedBox(height: 10.h),

                Text(
                  adminName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  adminEmail,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),

          /// PRODUCT MANAGEMENT
          _expandableDrawerItem(Icons.inventory_2, 'Product Management', [

            _drawerSubItemNumber(context,'View Product',1, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewProductList()),
              );
            }),

            _drawerSubItemNumber(context,'All Publication',2, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewCompanyPage()),
              );
            }),
          ]),

          /// ACCOUNT
          _expandableDrawerItem(Icons.account_balance_wallet, 'Account', [

            _drawerSubItemNumber(context,'Purchase Invoice',1, () {}),

            _drawerSubItemNumber(context,'Purchase Return',2, () {}),

            _drawerSubItemNumber(context,'Sale Invoice',3, () {}),

            _drawerSubItemNumber(context,'General Cashbook',4, () {}),

            _drawerSubItemNumber(context,'Account Cashbook',5, () {}),
          ]),

          /// BILLING
          _expandableDrawerItem(Icons.receipt, 'Billing', [

            _expandableSubItem('Purchase', [

              _drawerSubItemNumber(context,'Purchase Not For Sale',1, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PurchaseForSale()));
              }),

              _drawerSubItemNumber(context,'Purchase Sample Revenue',2, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => Purchasesamplerevenew()));
              }),

              _drawerSubItemNumber(context,'Purchase Invoice',3, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PurchaseInvoice()));
              }),
            ]),

            _expandableSubItem('Purchase Return', [

              _drawerSubItemNumber(context,'Purchase Return Not For Sale',1, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PuchaseReturnNotForSale()));
              }),

              _drawerSubItemNumber(context,'Purchase Return Sample Revenue',2, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PucchaseReturnSampleRevenue()));
              }),

              _drawerSubItemNumber(context,'Purchase Return Invoice',3, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PuchaseReturnInvoice()));
              }),
            ]),

            _expandableSubItem('Sale', [

              _drawerSubItemNumber(context,'Sale Invoice',1, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => saleInvoice()));
              }),

              _drawerSubItemNumber(context,'Sample Sale Invoice',2, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => samplesaleInvoice()));
              }),
            ]),

            _expandableSubItem('Sell Return', [

              _drawerSubItemNumber(context,'Sale Return Invoice',1, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => saleReturnInvoice()));
              }),

              _drawerSubItemNumber(context,'Sample Sale Return Invoice',2, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SampleSaleReturnInvoice()));
              }),
            ]),
          ]),

          /// ACCOUNT OPENING
          _expandableDrawerItem(Icons.description, 'Account Opening Form', [

            _drawerSubItemNumber(context,'Purchase Account Form',1, () {}),

            _drawerSubItemNumber(context,'Sell Account Form',2, () {}),

            _drawerSubItemNumber(context,'Investor Account Form',3, () {}),

            _drawerSubItemNumber(context,'Vendor Account Form',4, () {}),

            _drawerSubItemNumber(context,'Publication Agreement',5, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PublicationListPage()),
              );
            }),
          ]),

          /// HRM
          _expandableDrawerItem(Icons.people, 'HRM', [

            _drawerSubItemNumber(context,'HRM Dashboard',1, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => HrmHodScreen(mobileNo: mobileNo)));
            }),

            _drawerSubItemNumber(context,'View Employee',2, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => HRMViewEmployee()));
            }),

            _drawerSubItemNumber(context,'InOut list',3, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => InOutManagementPage()));
            }),

            _drawerSubItemNumber(context,'Attendance History',4, () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HistoryPage(mobileNo: mobileNo)));
            }),

            _drawerSubItemNumber(context,'Interview List',5, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => InterviewList()));
            }),

            _drawerSubItemNumber(context,'All School List',6, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => SellSchoolListPage()));
            }),
          ]),

          /// SETTINGS
          _expandableDrawerItem(Icons.settings, 'Setting', [
            _drawerSubItemNumber(context,'Change Password',1, () {})
          ]),

          const Divider(),

          /// LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  /// EXPANDABLE MENU
  Widget _expandableDrawerItem(
      IconData icon, String title, List<Widget> children) {
    return ExpansionTile(
      leading: Icon(icon, color: const Color(0xFF6B46C1)),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
        ),
      ),
      children: children,
    );
  }

  /// NUMBER SUB MENU
  Widget _drawerSubItemNumber(
      BuildContext context,
      String title,
      int index,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: EdgeInsets.only(left: 32.w),
      child: ListTile(
        title: Row(
          children: [

            Container(
              width: 24.w,
              height: 24.h,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF6B46C1),
                shape: BoxShape.circle,
              ),
              child: Text(
                "$index",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  /// NESTED MENU
  Widget _expandableSubItem(String title, List<Widget> children) {
    return ExpansionTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14.sp),
      ),
      children: children,
    );
  }
}