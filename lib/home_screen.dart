import 'package:bookworld/staffPage/staff_login_page.dart';
import 'package:flutter/material.dart';
import 'AgentStaff/agentLoginPage.dart';
import 'Hr_Page/hrLogin_screen.dart';
import 'Recovery/RecoveryHomepage.dart';
import 'Recovery/recoveryAgentLogin.dart';
import 'SchoolPage/school login.dart';
import 'adminPage/adminLogin.dart';
import 'counterPage/counterLogin.dart';
import 'Service/update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _rotateAnim;
  late Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    UpdateService.checkForUpdate(context);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnim = Tween<double>(
      begin: 2.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _rotateAnim = Tween<double>(
      begin: -0.12,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _contentOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'GJ Book World',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  children: [
                    const SizedBox(height: 6),

                    // 🔥 Animated Logo
                    Opacity(
                      opacity: _opacityAnim.value,
                      child: Transform.rotate(
                        angle: _rotateAnim.value,
                        child: Transform.scale(
                          scale: _scaleAnim.value,
                          child: SizedBox(
                            height: 195,
                            child: Image.asset(
                              "assets/G17 book word.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Animated Welcome Text
                    Opacity(
                      opacity: _contentOpacity.value,
                      child: Text(
                        'Welcome to GJ Book World',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Opacity(
                      opacity: _contentOpacity.value,
                      child: Text(
                        'Please select your login type',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Animated Grid
                    Opacity(
                      opacity: _contentOpacity.value,
                      child: SizedBox(
                        height: 420,
                        child: GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85,
                          children: [
                            _loginTile(
                              title: "School",
                              icon: Icons.school,
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const SchoolLoginPage()),
                                );
                              },
                            ),
                            _loginTile(
                              title: "Counter",
                              icon: Icons.point_of_sale,
                              color: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const CounterLoginPage()),
                                );
                              },
                            ),


                            _loginTile(
                              title: "Recovery",
                              icon: Icons.people,
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const  RecoveryAgentLogin()),
                                );
                              },
                            ),
                            _loginTile(
                              title: "Agent",
                              icon: Icons.real_estate_agent,
                              color: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const StaffLoginPage()),
                                );
                              },
                            ),
                            _loginTile(
                              title: "HR",
                              icon: Icons.person_outline,
                              color: Colors.teal,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const hrLoginScreen()),
                                );
                              },
                            ),

                            _loginTile(
                              title: "Staff",
                              icon: Icons.people,
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const AgentStaffLoginPage()),
                                );
                              },
                            ),
                            _loginTile(
                              title: "Admin",
                              icon: Icons.admin_panel_settings,
                              color: Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const AdminLoginPage()),
                                );
                              },
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Login Tile
  Widget _loginTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
