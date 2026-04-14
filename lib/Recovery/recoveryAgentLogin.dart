import 'package:flutter/material.dart';
import '../Service/agent_getman_login_service.dart';
import '../Model/agent_getman_login_model.dart';
import '../Service/secure_storage_service.dart';
import 'RecoveryHomepage.dart';

class RecoveryAgentLogin extends StatefulWidget {
  const RecoveryAgentLogin({Key? key}) : super(key: key);

  @override
  State<RecoveryAgentLogin> createState() => _RecoveryAgentLoginState();
}

class _RecoveryAgentLoginState extends State<RecoveryAgentLogin> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _mobileController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();


  String? _selectedPosition;

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _onLoginTap() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPosition == null) {
      _showMessage("Please select your position");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AgentGetManLoginService.login(
        mobile: _mobileController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!response.isSuccess) {
        _showMessage(response.message);
        return;
      }

      // ✅ BACKEND DOES NOT SEND POSITION
      final String finalPosition = _selectedPosition!;

      if (finalPosition != "RecoveryAgent" &&
          finalPosition != "RecoveryAgentHead") {
        _showMessage("Unauthorized role");
        return;
      }

      if (!mounted) return;

      final secureStorage = SecureStorageService();
      await secureStorage.saveRecoveryAgentCredentials(
        mobile: _mobileController.text.trim(),
        password: _passwordController.text.trim(),
        position: finalPosition,
        agentName: response.agentName,
        employeeId: response.employeeId,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RecoveryHomePage(
            position: finalPosition,
            agentName: response.agentName,
            mobileNo: _mobileController.text.trim(),
            employeeId: response.employeeId,
          ),
        ),
      );
    } catch (e) {
      _showMessage("Login failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Staff Login",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset(
                'assets/MOLL Services Logo.png',
                width: 120,
                height: 120,
              ),

              const SizedBox(height: 40),

              // POSITION DROPDOWN
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                validator: (v) =>
                v == null ? "Please select your position" : null,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge),
                  hintText: "Select Position",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "RecoveryAgentHead",
                    child: Text("Recovery Agent Head"),
                  ),
                  DropdownMenuItem(
                    value: "RecoveryAgent",
                    child: Text("Recovery Agent"),
                  ),
                ],
                onChanged: (v) {
                  setState(() => _selectedPosition = v);
                },
              ),

              const SizedBox(height: 20),

              // MOBILE
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                v == null || v.length != 10
                    ? "Enter valid mobile number"
                    : null,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  hintText: "Mobile Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // PASSWORD
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (v) =>
                v == null || v.length < 6
                    ? "Minimum 6 characters"
                    : null,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onLoginTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
