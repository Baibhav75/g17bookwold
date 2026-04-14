import 'package:bookworld/adminPage/CollectionManagement/receive_collection_screen.dart';
import 'package:bookworld/adminPage/CollectionManagement/recovery_pending_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CollectionHodScreen extends StatelessWidget {
  const CollectionHodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Collection Dashboard"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),

        child: GridView.count(
          crossAxisCount: 2, // ✅ Best for mobile
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.1,

          children: [

            /// 🔹 Pending Payment
            _buildGridCard(
              context,
              title: "Pending Payment",
              icon: Icons.pending_actions,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecoveryPendingScreen(),
                  ),
                );
              },
            ),

            /// 🔹 Received Payment
            _buildGridCard(
              context,
              title: "Received Payment",
              icon: Icons.check_circle,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReceiveCollectionScreen(),
                  ),
                );

              },
            ),

            /// 🔹 Transfer Payment
            _buildGridCard(
              context,
              title: "Transfer Payment",
              icon: Icons.swap_horiz,
              color: Colors.orange,
              onTap: () {
                // TODO: Add screen
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 GRID CARD (FIXED)
  Widget _buildGridCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),

      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ICON
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: color, size: 30.sp),
            ),

            SizedBox(height: 10.h),

            /// TITLE
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}