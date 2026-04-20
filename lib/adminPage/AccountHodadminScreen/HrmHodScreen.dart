import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../HRMViewEmployee.dart';
import '../in_out_management_page.dart';
import '../../staffPage/staffhistory.dart';
import '../interviewList.dart';
import '../sell_school_list_page.dart';

class HrmHodScreen extends StatelessWidget {
  final String mobileNo;

  const HrmHodScreen({super.key, required this.mobileNo});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        "title": "View Employee",
        "icon": Icons.badge,
        "color": Colors.blue
      },
      {
        "title": "InOut list",
        "icon": Icons.swap_horiz,
        "color": Colors.green
      },
      {
        "title": "Attendance History",
        "icon": Icons.history,
        "color": Colors.orange
      },
      {
        "title": "Interview List",
        "icon": Icons.question_answer,
        "color": Colors.purple
      },
      {
        "title": "All School List",
        "icon": Icons.school,
        "color": Colors.teal
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HRM HOD",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              /// TITLE
              Text(
                "HRM Management",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),

              /// GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final item = options[index];

                  return InkWell(
                    onTap: () {
                      if (item["title"] == "View Employee") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HRMViewEmployee(),
                          ),
                        );
                      }
                      if (item["title"] == "InOut list") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InOutManagementPage(),
                          ),
                        );
                      }
                      if (item["title"] == "Attendance History") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistoryPage(mobileNo: mobileNo),
                          ),
                        );
                      }
                      if (item["title"] == "Interview List") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InterviewList(),
                          ),
                        );
                      }
                      if (item["title"] == "All School List") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>  SellSchoolListPage(),
                          ),
                        );
                      }
                    },
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
        ),
      ),
    );
  }
}
