import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:swington_managment/constants/constants.dart';
import 'package:swington_managment/utils/Utils.dart';
import 'package:swington_managment/view_controller/DashboardScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    // TODO: implement initState

    initate();

    super.initState();
  }
  void initate()async {
    _emailController.text = (await Utils.getStringFromPrefs(constants.EMAIL))!;
    _passwordController.text = (await Utils.getStringFromPrefs(constants.PASSWORD))!;

    setState(() {

    });
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print("🔹 Login Attempt -> email: $email, password: $password");

    if (email.isEmpty || password.isEmpty) {
      print("❌ Email or Password is empty");
      _showError("Email and Password are required");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${constants.BASE_URL}loginappuser"),
      );
      request.fields['username'] = email;
      request.fields['password'] = password;

      print("📤 Sending request to: ${request.url}");
      print("📩 Request fields: ${request.fields}");

      var response = await request.send();
      print("📥 Raw response status: ${response.statusCode}");

      var responseData = await response.stream.bytesToString();
      print("📥 Response body: $responseData");

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        print("✅ Decoded JSON: $data");

        if (data["status"] == 200) {
          List<dynamic> permissions = data["admin_permissions"];
          print("✅ Login success. Permissions: $permissions");
          String userid = data['admin_userdata']['id'].toString();
          String token = data['admin_userdata']['api_token'];
          Utils.saveStringToPrefs(constants.USER_ID, userid.toString());
          Utils.saveStringToPrefs(constants.TOKEN, token);
          Utils.saveStringToPrefs(constants.EMAIL, _emailController.text);
          Utils.saveStringToPrefs(constants.PASSWORD, _passwordController.text);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(adminPermissions: permissions,dashboardsettings: data['admin_userdata']['dashboardsettings'],allCompanies: data["all_company"],currentCompanyId:data["current_company_id"].toString() ,),
            ),
          );
        } else {
          print("⚠️ Login failed: ${data["message"]}");
          _showError(data["message"] ?? "Login failed");
        }
      } else {
        print("❌ Server error code: ${response.statusCode}");
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e, stack) {
      print("🔥 Exception: $e");
      print("📌 StackTrace: $stack");
      _showError("Something went wrong: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }


  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 80,
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2B48C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain, // optional
                    ),
                  ),

                ),
                const SizedBox(height: 20),

                const Text(
                  "Login to your account",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter email",
                    filled: true,
                    fillColor: const Color(0xFFEFF3FF),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),


            TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: "Enter password",
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),

            const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD2B48C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Login",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

