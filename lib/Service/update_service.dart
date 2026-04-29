import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static String getFormattedDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";
  }
  static Future<void> checkForUpdate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // 🔴 1. Check: user already updated?
    bool isUpdated = prefs.getBool("is_app_updated") ?? false;

    if (isUpdated) {
      print("User already updated app");
      return; // ❌ popup kabhi nahi dikhega
    }

    // 📅 2. Daily check
    String today = DateTime.now().toIso8601String().split('T')[0];
    String? lastShownDate = prefs.getString("last_update_popup_date");

    if (lastShownDate == today) {
      print("Already shown today");
      return;
    }

    // ✅ Save today
    await prefs.setString("last_update_popup_date", today);

    _showDialogSafe(context, "https://baibhav75.github.io/Portfolio/");
  }

  // Safe dialog
  static void _showDialogSafe(BuildContext context, String url) {
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUpdateDialog(context, url);
    });
  }

  static void _showUpdateDialog(BuildContext context, String url) {
    String todayDate = getFormattedDate(); // 📅 get date

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Update Available 🚀"),
        content: Text(
          "Date: $todayDate\n\nA new version is available.\nPlease update to continue.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();

              // mark updated
              await prefs.setBool("is_app_updated", true);

              final uri = Uri.parse(url);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}