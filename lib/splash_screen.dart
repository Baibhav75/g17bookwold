import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:bookworld/Service/secure_storage_service.dart';
import 'package:bookworld/Service/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '/Service/update_service.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _rotationAnimation;

  final SecureStorageService _storageService = SecureStorageService();

  @override
  void initState() {
    super.initState();

    // Animation Controller (slower for clarity)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Scale Animation (BIG to normal)
    _scaleAnimation = Tween<double>(
      begin: 3.2,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    // Image Opacity Animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: Curves.easeIn),
      ),
    );

    // Text Opacity Animation (delayed)
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Rotation Animation (slight tilt)
    _rotationAnimation = Tween<double>(
      begin: -0.15,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // 3️⃣ Animation start
    _controller.forward();

    _checkPermissionAndProceed();

  }

  Future<void> _checkPermissionAndProceed() async {
    final isGranted =
    await PermissionService.requestAllRequiredPermissions();

    if (!isGranted) {
      _showPermissionDialog();
      return;
    }

    // Permission mil gayi → existing flow
    _navigateToAppropriateScreen();
  }


  Future<void> _navigateToAppropriateScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final initialScreen = await _storageService.getInitialScreen();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => initialScreen),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white
                                  .withOpacity(0.6 * _opacityAnimation.value),
                              blurRadius: 45,
                              spreadRadius: 12,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset(
                            'assets/MOLL Services Logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white,
                                child: Image.asset(
                                  'assets/bookimg.png',
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App Title
                Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: const Text(
                    'GJ Book World',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Subtitle
                Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: const Text(
                    'Education Management System',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Loader
                Opacity(
                  opacity: _controller.value > 0.75 ? 1.0 : 0.0,
                  child: Column(
                    children: const [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          AlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
              "Camera aur Background Location permission ke bina "
                  "app ka use possible nahi hai.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  openAppSettings();
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
    );
  }

}