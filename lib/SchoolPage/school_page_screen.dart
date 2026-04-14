import 'package:bookworld/SchoolPage/schoolChangePassword.dart';
import 'package:bookworld/SchoolPage/schoolProfile.dart';
import 'package:bookworld/SchoolPage/school_order_invoice_page.dart';
import 'package:bookworld/SchoolPage/view_ticket_screen.dart';
import 'package:flutter/material.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/home_screen.dart';
import '../Service/school_profile_service.dart';
import '../Model/school_profile_model.dart';
import '../adminPage/Sale/SaleMixReportScreen.dart';
import 'OrderFormPage.dart';
import 'new_ticket_screen.dart';
import 'orderBooknow.dart';

class SchoolPageScreen extends StatefulWidget {
  const SchoolPageScreen  ({Key? key}) : super(key: key);

  @override
  State<SchoolPageScreen  > createState() => _SchoolPageScreenState();
}

class _SchoolPageScreenState extends State<SchoolPageScreen > {
  int _currentIndex = 0;
  String _schoolId = '';
  String _ownerName = '';
  String _ownerNumber = '';
  String _schoolName = '';

  final SecureStorageService _storageService = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _loadSchoolCredentials();
  }

  Future<void> _loadSchoolCredentials() async {
    try {
      final credentials = await _storageService.getSchoolCredentials();


      final mobileNo = credentials['schoolId'] ?? '';

      if (mobileNo.isEmpty) return;

      // 🔹 Fetch school profile
      final SchoolProfileModel profile =
      await SchoolProfileService.fetchProfile(mobileNo: mobileNo);

      setState(() {
        _schoolId = profile.schoolId; // ✅ CORRECT (SCH035)
        _ownerNumber = mobileNo;
        _schoolName = profile.schoolName;   // ✅ MAIN CHANGE
        _ownerName = profile.ownerName;     // optional
      });
    } catch (e) {
      debugPrint("Error loading school data: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ---------------------- DRAWER ADDED HERE ----------------------
      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFFEF6C00),

        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (_ownerName.isNotEmpty || _ownerNumber.isNotEmpty)
              Text(
                _schoolName.isNotEmpty ? _schoolName : "School Dashboard",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFEF6C00),

        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Agreement"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Oder Now"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Total Sell"),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: "Settings"),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🎨 DRAWER DESIGN (Dashboard • Profile • Settings • Change Password • Logout)
  // ---------------------------------------------------------------------------

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFFEF6C00),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.deepOrangeAccent, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  _ownerName.isNotEmpty ? _ownerName : "School User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),

          // Drawer Items
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.deepOrangeAccent),
            title: const Text("Dashboard"),
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.person, color: Colors.deepOrangeAccent),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SchoolProfilePage(mobileNo: _ownerNumber,), // Replace with your actual profile page
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings, color: Colors.teal),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.key, color: Colors.orange),
            title: const Text("Change Password"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SchoolChangePasswordPage(mobileNo: _ownerNumber,), // Replace with your actual profile page
                ),
              );
            },
          ),

          ExpansionTile(
            leading: const Icon(Icons.settings, color: Colors.teal),
            title: const Text("Ticket"),
            children: [
              ListTile(
                leading: const Icon(Icons.add, color: Colors.blue),
                title: const Text("New Ticket"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewTicketScreen(
                        schoolName: _schoolName, // backend value
                      ),
                    ),
                  );

                  //   MaterialPageRoute(builder: (_) => NewTicketScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list, color: Colors.green),
                title: const Text("View Ticket"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ViewTicketScreen(),
                    ),
                  );

                },
              ),
            ],
          ),
          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAGES (same as before)
  // ---------------------------------------------------------------------------

  Widget _getPage() {
    switch (_currentIndex) {
      case 0:
      // 🏠 Home
        return _buildDashboard();



      default:
        return _buildDashboard();
    }
  }


  // ---------------------------------------------------------------------------
  // 🎨 DASHBOARD UI
  // ---------------------------------------------------------------------------

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBanner(  schoolName: _schoolName, ownerNumber: '',),
          const SizedBox(height: 20), // Reduced from 25

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Dashboard Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Slightly smaller
              ),
              Text(
                "View All",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12), // Reduced from 15

          Container(
            padding: const EdgeInsets.all(16), // Reduced from 20
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12, // Reduced spacing
              crossAxisSpacing: 12, // Reduced spacing
              childAspectRatio: 0.85, // Optimal ratio
              children: [
                _menuItem(
                  "Credit Amount",
                  Icons.account_balance_wallet, // 💰 credit
                  Colors.green,
                      () {

                  },
                ),

                _menuItem(
                  "Debit Amount",
                  Icons.money_off_csred, // 💸 debit
                  Colors.teal,
                      () {
                  },
                ),

                _menuItem(
                  "Total Sell",
                  Icons.trending_up, // 📈 sales
                  Colors.purple,
                      () {
                    setState(() => _currentIndex = 3);
                  },
                ),
                _menuItem(
                  "Oder Stock",
                  Icons.stacked_bar_chart,
                  Colors.purple,
                      () {
                    if (_schoolId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("School data not loaded")),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SaleMixReportScreen(
                          schoolId: _schoolId, // ✅ NO toString needed
                        ),
                      ),
                    );
                  },
                ),
                _menuItem(
                  "Available Stock",
                  Icons.inventory_2, // 📦 stock
                  Colors.blue,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  SchoolOrderInvoicePage(mobileNo: _ownerNumber,),
                      ),
                    );

                  },
                ),

                _menuItem(
                  "Settings",
                  Icons.settings, // ⚙️ settings (FIXED)
                  Colors.blueGrey,
                      () {
                        setState(() => _currentIndex = 4);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SchoolChangePasswordPage (mobileNo: _ownerNumber,),
                          ),
                        );
                    // navigate to settings page
                  },
                ),
                _menuItem(
                  "Order Now",
                  Icons.bookmark_border,
                  Colors.greenAccent,
                      () {
                        setState(() => _currentIndex = 2);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderBookScreen(mobileNo:  _ownerNumber,),
                      ),
                    );
                  },
                ),

              ],

            ),
          ),

          const SizedBox(height: 12),
          //quick Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Quick Activity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Slightly smaller
              ),
              Text(
                "View All",
                style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced from 15

          Container(
            padding: const EdgeInsets.all(12), // Reduced from 20
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 8, // Reduced spacing
              crossAxisSpacing: 8, // Reduced spacing
              childAspectRatio: 0.85, // Optimal ratio
              children: [

                _menuItem(
                  "Agreement",
                  Icons.bookmark_border,
                  Colors.greenAccent,
                      () {
                    setState(() => _currentIndex = 1);
                    // If you still need to navigate to OrderFormPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderFormPage(),
                      ),
                    );
                  },
                ),
                _menuItem("Order Management ", Icons.check_circle, Colors.green, () {
                  setState(() => _currentIndex = 2);
                }),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Placeholder pages
  Widget _buildCollectFeePage() => const Center(child: Text("Collect Fee Page"));
  Widget _buildSearchPage() => const Center(child: Text("Search Page"));
  Widget _buildReceiptsPage() => const Center(child: Text("Receipts Page"));
  Widget _buildReportsPage() => const Center(child: Text("Reports Page"));

  // ---------------------------------------------------------------------------
  // 🚪 LOGOUT
  // ---------------------------------------------------------------------------

  void _logout() async {
    try {
      final storage = SecureStorageService();
      await storage.clearAllCredentials();
    } catch (e) {
      print("Error clearing storage: $e");
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }
}

class AnimatedBanner extends StatefulWidget {
  final String schoolName;
  final String ownerNumber;

  const AnimatedBanner({
    Key? key,
    required this.schoolName,
    required this.ownerNumber,
  }) : super(key: key);


  @override
  _AnimatedBannerState createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<AnimatedBanner>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _slide = Tween<Offset>(
      begin: Offset(-0.05, 0),
      end: Offset(0.05, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepOrangeAccent,
              Colors.deepOrangeAccent,
              Colors.orange,
              Colors.orangeAccent,

            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.campaign, color: Colors.white, size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.schoolName.isNotEmpty
                        ? "Welcome to  ${widget.schoolName} 🎓"
                        : "Welcome Back! Have a productive day 🚀",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (widget.ownerNumber.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Mobile: ${widget.ownerNumber}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
