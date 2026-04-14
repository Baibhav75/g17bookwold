import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bookworld/Service/admin_login_service.dart';
import 'package:bookworld/Service/agent_login_service.dart';
import 'package:bookworld/adminPage/admin_page.dart';
import 'package:bookworld/staffPage/staff_page.dart';
import 'package:bookworld/staffPage/attendanceCheckOut.dart';
import 'package:bookworld/SchoolPage/school_page_screen.dart';
import 'package:bookworld/counterPage/counter_main_page.dart';
import 'package:bookworld/home_screen.dart';
import 'package:bookworld/AgentStaff/agentStaffPage.dart';
import 'package:bookworld/Recovery/RecoveryHomepage.dart';

/// Service for securely storing and retrieving user credentials
/// Also handles authentication and auto-login functionality


import '../AgentStaff/getmanHomePage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Login services
  final AdminLoginService _adminLoginService = AdminLoginService();
  final AgentLoginService _agentLoginService = AgentLoginService();

  // Storage keys
  static const String _keyUserType = 'user_type';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';

  // Admin keys
  static const String _keyAdminMobileNo = 'admin_mobile_no';
  static const String _keyAdminPassword = 'admin_password';
  static const String _keyAdminName = 'admin_name';
  static const String _keyAdminEmail = 'admin_email';

  // Staff keys
  static const String _keyStaffUsername = 'staff_username';
  static const String _keyStaffPassword = 'staff_password';
  static const String _keyStaffEmployeeType = 'staff_employee_type';
  static const String _keyStaffAgentName = 'staff_agent_name';
  static const String _keyStaffEmployeeId = 'staff_employee_id';
  static const String _keyStaffMobileNo = 'staff_mobile_no';
  static const String _keyStaffEmail = 'staff_email';

  // School keys
  static const String _keySchoolId = 'school_id';
  static const String _keySchoolUsername = 'school_username';
  static const String _keySchoolPassword = 'school_password';

  // Security Guard specific keys
  static const String _keyGuardName = 'guard_name';
  static const String _keyGuardEmail = 'guard_email';
  static const String _keyGuardRole = 'guard_role';

  // Agent specific keys
  static const String _keyAgentId = 'agent_id';
  static const String _keyAgentEmail = 'agent_email';
  static const String _keyAgentPosition = 'agent_position';
  static const String _keyAgentTotalBills = 'agent_total_bills';

  // Attendance check-in keys
  static const String _keyCheckInStatus = 'checkin_status';
  static const String _keyCheckInTime = 'checkin_time';
  static const String _keyCheckInPhotoPath = 'checkin_photo_path';
  static const String _keyCheckInLatitude = 'checkin_latitude';
  static const String _keyCheckInLongitude = 'checkin_longitude';
  static const String _keyCheckInAddress = 'checkin_address';

  // Enhanced check-in keys
  static const String _keyCheckInEmployeeId = 'checkin_employee_id';
  static const String _keyCheckInMobile = 'checkin_mobile';
  static const String _keyCheckInState = 'checkin_state';
  static const String _keyHasPendingCheckIn = 'has_pending_checkin';
  static const String _keyCheckInSyncStatus = 'checkin_sync_status';

  // Counter keys
  static const String _keyCounterId = 'counter_id';
  static const String _keyCounterPassword = 'counter_password';
  static const String _keyCounterName = 'counter_name';
  static const String _keyCounterMobile = 'counter_mobile';

  // Recovery Agent keys
  static const String _keyRecoveryAgentMobile = 'recovery_agent_mobile';
  static const String _keyRecoveryAgentPassword = 'recovery_agent_password';
  static const String _keyRecoveryAgentPosition = 'recovery_agent_position';
  static const String _keyRecoveryAgentName = 'recovery_agent_name';
  static const String _keyRecoveryAgentEmployeeId = 'recovery_agent_employee_id';


  // ===========================================================================
  // ✅ SAVE METHODS
  // ===========================================================================

  /// Save admin credentials
  Future<void> saveAdminCredentials({
    required String mobileNo,
    required String password,

    String? adminName,
    String? adminEmail,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'admin');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyAdminMobileNo, value: mobileNo);
      await _storage.write(key: _keyAdminPassword, value: password);

      if (adminName != null) {
        await _storage.write(key: _keyAdminName, value: adminName);
      }

      if (adminEmail != null) {
        await _storage.write(key: _keyAdminEmail, value: adminEmail);
      }
    } catch (e) {
      throw Exception('Failed to save admin credentials: $e');
    }
  }

  /// Save staff credentials
  Future<void> saveStaffCredentials({
    required String username,
    required String password,
    String? employeeType,
    String? agentName,
    String? employeeId,
    String? mobileNo,
    String? email,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'staff');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyStaffUsername, value: username);
      await _storage.write(key: _keyStaffPassword, value: password);

      if (employeeId != null) {
        await _storage.write(key: _keyStaffEmployeeId, value: employeeId);
      }

      if (employeeType != null && employeeType.isNotEmpty) {
        await _storage.write(
          key: _keyStaffEmployeeType,
          value: employeeType,
        );
      }


      if (agentName != null) {
        await _storage.write(key: _keyStaffAgentName, value: agentName);
      }


      if (mobileNo != null) {
        await _storage.write(key: _keyStaffMobileNo, value: mobileNo);
      }

      if (email != null) {
        await _storage.write(key: _keyStaffEmail, value: email);
      }
    } catch (e) {
      throw Exception('Failed to save staff credentials: $e');
    }
  }

  /// ✅ Save Agent credentials
  Future<void> saveAgentCredentials({
    required String employeeId,
    required String mobile,
    required String password,
    required String name,
    required String email,
    required String position,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'agent');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyUserId, value: employeeId);
      await _storage.write(key: _keyStaffEmployeeId, value: employeeId);
      await _storage.write(key: _keyStaffMobileNo, value: mobile);
      await _storage.write(key: _keyStaffPassword, value: password);
      await _storage.write(key: _keyStaffAgentName, value: name);
      await _storage.write(key: _keyAgentEmail, value: email);
      await _storage.write(key: _keyAgentPosition, value: position);
      await _storage.write(key: _keyStaffEmail, value: email);
    } catch (e) {
      throw Exception('Failed to save agent credentials: $e');
    }
  }

  /// ✅ Save Guard credentials
  Future<void> saveGuardCredentials({
    required String employeeId,
    required String mobile,
    required String password,
    required String name,
    required String email,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'guard');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyUserId, value: employeeId);
      await _storage.write(key: _keyStaffEmployeeId, value: employeeId);
      await _storage.write(key: _keyStaffMobileNo, value: mobile);
      await _storage.write(key: _keyStaffPassword, value: password);
      await _storage.write(key: _keyGuardName, value: name);
      await _storage.write(key: _keyGuardEmail, value: email);
      await _storage.write(key: _keyGuardRole, value: 'SECURITY_GUARD');
      await _storage.write(key: _keyStaffEmail, value: email);
    } catch (e) {
      throw Exception('Failed to save guard credentials: $e');
    }
  }

  /// Save Agent/GetMan credentials (Legacy method)
  Future<void> saveAgentGetManCredentials({
    required String mobileNo,
    required String role,
    required String name,
    required String email,
    String? employeeId,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'staff');
      await _storage.write(key: _keyStaffEmployeeType, value: role);

      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keyStaffMobileNo, value: mobileNo);

      await _storage.write(key: _keyStaffAgentName, value: name); // Keeping original key for safety
      await _storage.write(key: _keyStaffEmail, value: email);


      final existingRole = await _storage.read(key: _keyStaffEmployeeType);
      if (existingRole == null || existingRole.isEmpty) {
        await _storage.write(key: _keyStaffEmployeeType, value: role);
        debugPrint('🔐 Role set to: $role');
      } else {
        debugPrint('🔒 Role preservation: Kept existing role $existingRole instead of overwriting with $role');
        // If we are truly logging in as a NEW user, clearAllCredentials should have been called first.
      }

      // Always save employeeId - use mobile as fallback if not provided or empty
      final employeeIdToSave = (employeeId != null && employeeId.trim().isNotEmpty)
          ? employeeId.trim()
          : mobileNo;
      await _storage.write(key: _keyStaffEmployeeId, value: employeeIdToSave);
      debugPrint('Saved employeeId to storage: $employeeIdToSave');

      // Save based on role
      if (role == 'AGENT') {
        await _storage.write(key: _keyAgentEmail, value: email);
      } else if (role == 'SECURITY_GUARD') {
        await _storage.write(key: _keyGuardName, value: name);
        await _storage.write(key: _keyGuardEmail, value: email);
      }
    } catch (e) {
      throw Exception('Failed to save Agent/GetMan credentials: $e');
    }
  }

  /// Save school credentials
  Future<void> saveSchoolCredentials({
    required String schoolId,
    required String username,
    required String password,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'school');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      await _storage.write(key: _keySchoolId, value: schoolId);
      await _storage.write(key: _keySchoolUsername, value: username);
      await _storage.write(key: _keySchoolPassword, value: password);
    } catch (e) {
      throw Exception('Failed to save school credentials: $e');
    }
  }

  /// Save counter credentials
  Future<void> saveCounterCredentials({
    required String counterId,
    required String password,
    required String counterName,
    required String mobileNo,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'counter');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');

      await _storage.write(key: _keyCounterId, value: counterId);
      await _storage.write(key: _keyCounterPassword, value: password);
      await _storage.write(key: _keyCounterName, value: counterName);
      await _storage.write(key: _keyCounterMobile, value: mobileNo);

      debugPrint('✅ Counter credentials saved');
      debugPrint('   Counter ID: $counterId');
      debugPrint('   Counter Name: $counterName');
      debugPrint('   Counter Mobile: $mobileNo');
    } catch (e) {
      throw Exception('Failed to save counter credentials: $e');
    }
  }

  /// Save Recovery Agent credentials
  Future<void> saveRecoveryAgentCredentials({
    required String mobile,
    required String password,
    required String position,
    required String agentName,
    required String employeeId,
  }) async {
    try {
      await _storage.write(key: _keyUserType, value: 'recovery_agent');
      await _storage.write(key: _keyIsLoggedIn, value: 'true');
      
      await _storage.write(key: _keyRecoveryAgentMobile, value: mobile);
      await _storage.write(key: _keyRecoveryAgentPassword, value: password);
      await _storage.write(key: _keyRecoveryAgentPosition, value: position);
      await _storage.write(key: _keyRecoveryAgentName, value: agentName);
      await _storage.write(key: _keyRecoveryAgentEmployeeId, value: employeeId);
      
      debugPrint('✅ Recovery Agent credentials saved');
    } catch (e) {
      throw Exception('Failed to save Recovery Agent credentials: $e');
    }
  }


  // ===========================================================================
  // ✅ GET METHODS
  // ===========================================================================

  /// Get admin credentials
  Future<Map<String, String?>> getAdminCredentials() async {
    try {
      final mobileNo = await _storage.read(key: _keyAdminMobileNo);
      final password = await _storage.read(key: _keyAdminPassword);
      final name = await _storage.read(key: _keyAdminName);
      final email = await _storage.read(key: _keyAdminEmail);

      return {
        'mobileNo': mobileNo,
        'password': password,
        'name': name,
        'email': email,
      };
    } catch (e) {
      throw Exception('Failed to get admin credentials: $e');
    }
  }

  /// Get staff credentials
  Future<Map<String, String?>> getStaffCredentials() async {
    try {
      final username = await _storage.read(key: _keyStaffUsername);
      final password = await _storage.read(key: _keyStaffPassword);
      final employeeType = await _storage.read(key: _keyStaffEmployeeType);
      final agentName = await _storage.read(key: _keyStaffAgentName);
      final mobileNo = await _storage.read(key: _keyStaffMobileNo);
      final email = await _storage.read(key: _keyStaffEmail);
      final employeeId = await _storage.read(key: _keyStaffEmployeeId);

      return {
        'username': username,
        'password': password,
        'employeeType': employeeType,
        'agentName': agentName,
        'mobileNo': mobileNo,
        'email': email,
        'employeeId': employeeId,
      };
    } catch (e) {
      throw Exception('Failed to get staff credentials: $e');
    }
  }

  /// ✅ Get all user details
  Future<Map<String, String?>> getUserDetails() async {
    try {
      final userType = await getUserType();

      Map<String, String?> details = {
        'userType': userType,
        'employeeId': await getStaffEmployeeId(),
        'mobile': await getStaffMobileNo(),
        'name': await getStaffName(),
        'email': await getStaffEmail(),
        'role': await getStaffEmployeeType(),
      };

      // Get additional details based on user type
      if (userType == 'guard') {
        details['guardName'] = await _storage.read(key: _keyGuardName);
        details['guardEmail'] = await _storage.read(key: _keyGuardEmail);
      } else if (userType == 'agent') {
        details['agentEmail'] = await _storage.read(key: _keyAgentEmail);
        details['position'] = await _storage.read(key: _keyAgentPosition);
      }

      return details;
    } catch (e) {
      return {};
    }
  }

  /// Get school credentials
  Future<Map<String, String?>> getSchoolCredentials() async {
    try {
      final schoolId = await _storage.read(key: _keySchoolId);
      final username = await _storage.read(key: _keySchoolUsername);
      final password = await _storage.read(key: _keySchoolPassword);

      return {
        'schoolId': schoolId,
        'username': username,
        'password': password,
      };
    } catch (e) {
      throw Exception('Failed to get school credentials: $e');
    }
  }

  // ===========================================================================
  // ✅ SPECIFIC GETTERS
  // ===========================================================================

  /// Get staff employee ID
  Future<String?> getStaffEmployeeId() async {
    try {
      final employeeId = await _storage.read(key: _keyStaffEmployeeId);
      return employeeId;
    } catch (e) {
      return null;
    }
  }

  /// Get staff mobile number
  Future<String?> getStaffMobileNo() async {
    try {
      return await _storage.read(key: _keyStaffMobileNo);
    } catch (e) {
      return null;
    }
  }

  /// Get staff employee type
  Future<String?> getStaffEmployeeType() async {
    try {
      return await _storage.read(key: _keyStaffEmployeeType);
    } catch (e) {
      return null;
    }
  }

  /// Get staff name
  Future<String?> getStaffName() async {
    try {
      return await _storage.read(key: _keyStaffAgentName) ??
          await _storage.read(key: _keyGuardName);
    } catch (e) {
      return null;
    }
  }

  /// Get staff email
  Future<String?> getStaffEmail() async {
    try {
      return await _storage.read(key: _keyStaffEmail) ??
          await _storage.read(key: _keyAgentEmail) ??
          await _storage.read(key: _keyGuardEmail);
    } catch (e) {
      return null;
    }
  }

  /// Get staff password
  Future<String?> getStaffPassword() async {
    try {
      return await _storage.read(key: _keyStaffPassword);
    } catch (e) {
      return null;
    }
  }

  /// Get guard name
  Future<String?> getGuardName() async {
    try {
      return await _storage.read(key: _keyGuardName);
    } catch (e) {
      return null;
    }
  }

  /// Get guard email
  Future<String?> getGuardEmail() async {
    try {
      return await _storage.read(key: _keyGuardEmail);
    } catch (e) {
      return null;
    }
  }

  /// Get agent email
  Future<String?> getAgentEmail() async {
    try {
      return await _storage.read(key: _keyAgentEmail);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCounterId() async {
    return await _storage.read(key: _keyCounterId);
  }

  Future<String?> getCounterName() async {
    return await _storage.read(key: _keyCounterName);
  }

  Future<String?> getCounterPassword() async {
    return await _storage.read(key: _keyCounterPassword);
  }

  Future<String?> getCounterMobile() async {
    return await _storage.read(key: _keyCounterMobile);
  }

  /// Get Recovery Agent credentials
  Future<Map<String, String?>> getRecoveryAgentCredentials() async {
    try {
      final mobile = await _storage.read(key: _keyRecoveryAgentMobile);
      final password = await _storage.read(key: _keyRecoveryAgentPassword);
      final position = await _storage.read(key: _keyRecoveryAgentPosition);
      final agentName = await _storage.read(key: _keyRecoveryAgentName);
      final employeeId = await _storage.read(key: _keyRecoveryAgentEmployeeId);

      return {
        'mobile': mobile,
        'password': password,
        'position': position,
        'agentName': agentName,
        'employeeId': employeeId,
      };
    } catch (e) {
      throw Exception('Failed to get Recovery Agent credentials: $e');
    }
  }

  /// Save agent school sale data (agentId and totalBills)
  Future<void> saveAgentSchoolSaleData({
    required String agentId,
    required int totalBills,
  }) async {
    try {
      await _storage.write(key: _keyAgentId, value: agentId);
      await _storage.write(key: _keyAgentTotalBills, value: totalBills.toString());
      debugPrint('✅ Agent school sale data saved');
      debugPrint('   Agent ID: $agentId');
      debugPrint('   Total Bills: $totalBills');
    } catch (e) {
      throw Exception('Failed to save agent school sale data: $e');
    }
  }

  /// Get agent ID
  Future<String?> getAgentId() async {
    try {
      return await _storage.read(key: _keyAgentId);
    } catch (e) {
      return null;
    }
  }

  /// Get agent total bills
  Future<int?> getAgentTotalBills() async {
    try {
      final totalBillsStr = await _storage.read(key: _keyAgentTotalBills);
      if (totalBillsStr != null && totalBillsStr.isNotEmpty) {
        return int.tryParse(totalBillsStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===========================================================================
  // ✅ CHECK-IN METHODS (UPDATED)
  // ===========================================================================

  /// Save check-in data with enhanced fields
  Future<void> saveCheckInData({
    required DateTime checkInTime,
    required String photoPath,
    required double latitude,
    required double longitude,
    required String address,
    String? employeeId,
    String? mobile,
    String? state,
  }) async {
    try {
      await _storage.write(key: _keyCheckInStatus, value: 'true');
      await _storage.write(
        key: _keyCheckInTime,
        value: checkInTime.toIso8601String(),
      );
      await _storage.write(key: _keyCheckInPhotoPath, value: photoPath);
      await _storage.write(
        key: _keyCheckInLatitude,
        value: latitude.toString(),
      );
      await _storage.write(
        key: _keyCheckInLongitude,
        value: longitude.toString(),
      );
      await _storage.write(key: _keyCheckInAddress, value: address);

      // Save additional fields for better syncing
      if (employeeId != null && employeeId.isNotEmpty) {
        await _storage.write(key: _keyCheckInEmployeeId, value: employeeId);
      }

      if (mobile != null && mobile.isNotEmpty) {
        await _storage.write(key: _keyCheckInMobile, value: mobile);
      }

      if (state != null && state.isNotEmpty) {
        await _storage.write(key: _keyCheckInState, value: state);
      }

      await _storage.write(key: _keyHasPendingCheckIn, value: 'true');
      await _storage.write(key: _keyCheckInSyncStatus, value: 'pending_sync');

      debugPrint('✅ Check-in data saved locally');
      debugPrint('   Time: $checkInTime');
      debugPrint('   Location: $address');
      debugPrint('   Employee ID: ${employeeId ?? "Not saved"}');
      debugPrint('   State: ${state ?? "Not saved"}');
    } catch (e) {
      debugPrint('❌ Error saving check-in data: $e');
      throw Exception('Failed to save check-in data: $e');
    }
  }

  /// Save check-in data specifically for IT staff (no lat/long required)
  Future<void> saveItCheckInData({
    required DateTime checkInTime,
    required String photoPath,
    required String address,
    String? employeeId,
    String? mobile,
    String? state,
  }) async {
    try {
      await _storage.write(key: _keyCheckInStatus, value: 'true');
      await _storage.write(
        key: _keyCheckInTime,
        value: checkInTime.toIso8601String(),
      );
      await _storage.write(key: _keyCheckInPhotoPath, value: photoPath);

      // Default dummy coordinates for IT check-in
      await _storage.write(key: _keyCheckInLatitude, value: "0.0");
      await _storage.write(key: _keyCheckInLongitude, value: "0.0");

      await _storage.write(key: _keyCheckInAddress, value: address);

      // Save additional fields
      if (employeeId != null && employeeId.isNotEmpty) {
        await _storage.write(key: _keyCheckInEmployeeId, value: employeeId);
      }

      if (mobile != null && mobile.isNotEmpty) {
        await _storage.write(key: _keyCheckInMobile, value: mobile);
      }

      // Default state if not provided
      final stateToSave = state ?? "NA";
      await _storage.write(key: _keyCheckInState, value: stateToSave);

      await _storage.write(key: _keyHasPendingCheckIn, value: 'true');
      await _storage.write(key: _keyCheckInSyncStatus, value: 'pending_sync');

      debugPrint('✅ IT Check-in data saved locally');
      debugPrint('   Time: $checkInTime');
      debugPrint('   Location: $address');
      debugPrint('   Employee ID: ${employeeId ?? "Not saved"}');
    } catch (e) {
      debugPrint('❌ Error saving IT check-in data: $e');
      throw Exception('Failed to save IT check-in data: $e');
    }
  }

  /// Get check-in data with enhanced fields
  Future<Map<String, String?>> getCheckInData() async {
    try {
      final status = await _storage.read(key: _keyCheckInStatus);
      final time = await _storage.read(key: _keyCheckInTime);
      final photoPath = await _storage.read(key: _keyCheckInPhotoPath);
      final latitude = await _storage.read(key: _keyCheckInLatitude);
      final longitude = await _storage.read(key: _keyCheckInLongitude);
      final address = await _storage.read(key: _keyCheckInAddress);

      // Get enhanced fields
      final employeeId = await _storage.read(key: _keyCheckInEmployeeId);
      final mobile = await _storage.read(key: _keyCheckInMobile);
      final state = await _storage.read(key: _keyCheckInState);
      final syncStatus = await _storage.read(key: _keyCheckInSyncStatus);
      final hasPending = await _storage.read(key: _keyHasPendingCheckIn);

      return {
        'status': status,
        'time': time,
        'photoPath': photoPath,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'employeeId': employeeId,
        'mobile': mobile,
        'state': state,
        'syncStatus': syncStatus,
        'hasPending': hasPending,
      };
    } catch (e) {
      debugPrint('Error getting check-in data: $e');
      return {};
    }
  }

  /// Check if user has checked in
  Future<bool> hasCheckedIn() async {
    try {
      final status = await _storage.read(key: _keyCheckInStatus);
      return status == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Check if there's a pending check-in that needs sync
  Future<bool> hasPendingCheckIn() async {
    try {
      final hasPending = await _storage.read(key: _keyHasPendingCheckIn);
      return hasPending == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Mark check-in as synced to server
  Future<void> markCheckInAsSynced() async {
    try {
      await _storage.write(key: _keyCheckInSyncStatus, value: 'synced');
      await _storage.write(key: _keyHasPendingCheckIn, value: 'false');
      debugPrint('✅ Check-in marked as synced');
    } catch (e) {
      debugPrint('Error marking check-in as synced: $e');
    }
  }

  /// Sync pending check-in data
  Future<void> syncPendingCheckIn() async {
    try {
      final pendingData = await getCheckInData();
      if (pendingData.isEmpty) {
        debugPrint('No pending check-in data to sync');
        return;
      }

      final syncStatus = pendingData['syncStatus'];
      if (syncStatus == 'synced') {
        debugPrint('Check-in already synced');
        return;
      }

      debugPrint('🔄 Syncing pending check-in data...');
      debugPrint('   Employee ID: ${pendingData['employeeId']}');
      debugPrint('   Time: ${pendingData['time']}');
      debugPrint('   Status: $syncStatus');

      // Note: This is where you would implement actual sync logic
      // For now, just mark as synced
      await markCheckInAsSynced();

    } catch (e) {
      debugPrint('Error syncing pending check-in: $e');
    }
  }

  /// Clear all check-in data
  Future<void> clearCheckInData() async {
    try {
      await _storage.delete(key: _keyCheckInStatus);
      await _storage.delete(key: _keyCheckInTime);
      await _storage.delete(key: _keyCheckInPhotoPath);
      await _storage.delete(key: _keyCheckInLatitude);
      await _storage.delete(key: _keyCheckInLongitude);
      await _storage.delete(key: _keyCheckInAddress);
      await _storage.delete(key: _keyCheckInEmployeeId);
      await _storage.delete(key: _keyCheckInMobile);
      await _storage.delete(key: _keyCheckInState);
      await _storage.delete(key: _keyHasPendingCheckIn);
      await _storage.delete(key: _keyCheckInSyncStatus);

      debugPrint('✅ Check-in data cleared from storage');
    } catch (e) {
      debugPrint('Error clearing check-in data: $e');
      throw Exception('Failed to clear check-in data: $e');
    }
  }

  // ===========================================================================
  // ✅ UTILITY METHODS
  // ===========================================================================

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await _storage.read(key: _keyIsLoggedIn);
      return isLoggedIn == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Get current user type
  Future<String?> getUserType() async {
    try {
      return await _storage.read(key: _keyUserType);
    } catch (e) {
      return null;
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId) ??
          await getStaffEmployeeId();
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored credentials
  Future<void> clearAllCredentials() async {
    try {
      // Clear authentication keys
      await _storage.delete(key: _keyUserType);
      await _storage.delete(key: _keyIsLoggedIn);
      await _storage.delete(key: _keyUserId);

      // Clear admin credentials
      await _storage.delete(key: _keyAdminMobileNo);
      await _storage.delete(key: _keyAdminPassword);
      await _storage.delete(key: _keyAdminName);
      await _storage.delete(key: _keyAdminEmail);

      // Clear staff credentials
      await _storage.delete(key: _keyStaffUsername);
      await _storage.delete(key: _keyStaffPassword);
      await _storage.delete(key: _keyStaffEmployeeType);
      await _storage.delete(key: _keyStaffAgentName);
      await _storage.delete(key: _keyStaffEmployeeId);
      await _storage.delete(key: _keyStaffMobileNo);
      await _storage.delete(key: _keyStaffEmail);

      // Clear school credentials
      await _storage.delete(key: _keySchoolId);
      await _storage.delete(key: _keySchoolUsername);
      await _storage.delete(key: _keySchoolPassword);

      // Clear guard credentials
      await _storage.delete(key: _keyGuardName);
      await _storage.delete(key: _keyGuardEmail);
      await _storage.delete(key: _keyGuardRole);

      // Clear agent credentials
      await _storage.delete(key: _keyAgentId);
      await _storage.delete(key: _keyAgentEmail);
      await _storage.delete(key: _keyAgentPosition);
      await _storage.delete(key: _keyAgentTotalBills);

      // Clear counter credentials
      await _storage.delete(key: _keyCounterId);
      await _storage.delete(key: _keyCounterPassword);
      await _storage.delete(key: _keyCounterName);

      // Clear Recovery Agent credentials
      await _storage.delete(key: _keyRecoveryAgentMobile);
      await _storage.delete(key: _keyRecoveryAgentPassword);
      await _storage.delete(key: _keyRecoveryAgentPosition);
      await _storage.delete(key: _keyRecoveryAgentName);
      await _storage.delete(key: _keyRecoveryAgentEmployeeId);


      // Clear check-in data
      await clearCheckInData();
    } catch (e) {
      throw Exception('Failed to clear credentials: $e');
    }
  }

  // ===========================================================================
  // ✅ AUTHENTICATION METHODS
  // ===========================================================================

  /// Logout user (alias for clearAllCredentials)
  Future<void> logout() async {
    await clearAllCredentials();
  }

  /// Check login status (alias for isLoggedIn)
  Future<bool> checkLoginStatus() async {
    return await isLoggedIn();
  }

  /// Get current user type (alias for getUserType)
  Future<String?> getCurrentUserType() async {
    return await getUserType();
  }

  /// -------------------------------------------------------------------------
  /// Decide Initial Screen (Auto-login)
  /// -------------------------------------------------------------------------
  Future<Widget> getInitialScreen() async {
    try {
      final isLoggedIn = await this.isLoggedIn();

      if (!isLoggedIn) return const HomeScreen();

      final userType = await getUserType();

      switch (userType) {
        case 'admin':
          return await _getAdminScreen();

        case 'staff':
          return await _getStaffScreen();

        case 'school':
          return await _getSchoolScreen();

        case 'counter':
          return const CounterMainPage();

        case 'recovery_agent':
          return await _getRecoveryAgentScreen();

        default:
          return const HomeScreen();
      }
    } catch (e) {
      return const HomeScreen();
    }
  }

  /// -------------------------------------------------------------------------
  /// Auto Login → Admin Section
  /// -------------------------------------------------------------------------
  Future<Widget> _getAdminScreen() async {
    try {
      final credentials = await getAdminCredentials();
      final mobileNo = credentials['mobileNo'];
      final password = credentials['password'];

      if (mobileNo == null || password == null) {
        await clearAllCredentials();
        return const HomeScreen();
      }

      final loginResponse = await _adminLoginService.performLogin(
        mobileNo: mobileNo,
        password: password,
      );

      if (loginResponse.isSuccess) {
        return AdminPage(userData: loginResponse);
      } else {
        await clearAllCredentials();
        return const HomeScreen();
      }
    } catch (e) {
      await clearAllCredentials();
      return const HomeScreen();
    }
  }

  /// -------------------------------------------------------------------------
  /// Auto Login → Staff (AgentStaff / Staff)
  /// -------------------------------------------------------------------------
  /// -------------------------------------------------------------------------
  /// Auto Login → Staff (AgentStaff / Staff)
  /// -------------------------------------------------------------------------
  Future<Widget> _getStaffScreen() async {
    try {
      // 1. Retrieve stored credentials
      final credentials = await getStaffCredentials();
      final mobileNo = credentials['mobileNo'];
      final employeeType = credentials['employeeType'];
      final agentName = credentials['agentName'];
      final password = credentials['password'];
      final email = credentials['email'];

      debugPrint('🚀 Auto-Login: Staff');
      debugPrint('   Mobile: $mobileNo');
      debugPrint('   Role: $employeeType');
      debugPrint('   Name: $agentName');

      // 2. Validate essential credentials
      if (mobileNo == null || mobileNo.isEmpty) {
        debugPrint('⚠️ Missing mobile number, logging out.');
        await clearAllCredentials();
        return const HomeScreen();
      }

      if (password == null || password.isEmpty) {
        debugPrint('⚠️ Missing password, logging out.');
        await clearAllCredentials();
        return const HomeScreen();
      }

      // 3. STRICT ROLE-BASED NAVIGATION
      if (employeeType != null &&
          employeeType.toUpperCase() == "SECURITY_GUARD") {
        debugPrint('✅ Routing to: getmanHomePage (Guards)');
        return const getmanHomePage();
      } else {
        // Route to StaffPage for AGENT and other staff types
        debugPrint('✅ Routing to: StaffPage (Agent/IT/Other)');
        
        // Check if user has already checked in - OPTIONAL: just for logging
        final hasCheckedIn = await this.hasCheckedIn();
        if (hasCheckedIn) {
          debugPrint('ℹ️ User has active check-in. They will see it on their dashboard.');
        }
        
        return StaffPage(
          agentName: agentName ?? "Staff",
          employeeType: employeeType ?? "AGENT",
          email: email ?? "",
          password: password,
          mobile: mobileNo,
        );
      }

    } catch (e) {
      debugPrint('Error in _getStaffScreen: $e');
      await clearAllCredentials();
      return const HomeScreen();
    }
  }



  /// -------------------------------------------------------------------------
  /// Auto Login → School
  /// -------------------------------------------------------------------------
  Future<Widget> _getSchoolScreen() async {
    return const SchoolPageScreen();
  }

  /// -------------------------------------------------------------------------
  /// Auto Login → Recovery Agent
  /// -------------------------------------------------------------------------
  Future<Widget> _getRecoveryAgentScreen() async {
    try {
      final credentials = await getRecoveryAgentCredentials();
      final mobile = credentials['mobile'];
      final position = credentials['position'];
      final agentName = credentials['agentName'];
      final employeeId = credentials['employeeId'];

      if (mobile == null || position == null || agentName == null || employeeId == null) {
         await clearAllCredentials();
         return const HomeScreen();
      }

      return RecoveryHomePage(
        position: position,
        agentName: agentName,
        mobileNo: mobile,
        employeeId: employeeId,
      );
    } catch (e) {
      await clearAllCredentials();
      return const HomeScreen();
    }
  }

  /// ✅ Check if employee ID exists
  Future<bool> hasEmployeeId() async {
    try {
      final employeeId = await getStaffEmployeeId();
      return employeeId != null && employeeId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// ✅ Print all stored data (for debugging)
  Future<void> printAllStorage() async {
    try {
      final allKeys = await _storage.readAll();
      debugPrint('=== Secure Storage Contents ===');
      allKeys.forEach((key, value) {
        debugPrint('$key: $value');
      });
      debugPrint('===============================');
    } catch (e) {
      debugPrint('Error reading storage: $e');
    }
  }

  // Add this at the top of your class for debugging
  static void debugPrint(String message) {
    print('[SecureStorageService] $message');
  }
}//read karo and update akro