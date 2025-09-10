import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:swington_managment/constants/constants.dart';
import 'package:swington_managment/utils/Utils.dart';
import 'package:swington_managment/view_controller/AddBillScreen.dart';
import 'package:swington_managment/view_controller/AllImprestPaymentReportScreen.dart';
import 'package:swington_managment/view_controller/DailyReportScreen.dart';
import 'package:swington_managment/view_controller/HeadListScreen.dart';
import 'package:swington_managment/view_controller/LoginScreen.dart';
import 'package:swington_managment/view_controller/SaveDailyReportScreen.dart';
import 'App Imprest.dart';

class DashboardScreen extends StatefulWidget {
  final List<dynamic> adminPermissions;
  final String dashboardsettings;
  final List<dynamic> allCompanies;
  final String currentCompanyId;

  const DashboardScreen({
    super.key,
    required this.adminPermissions,
    required this.dashboardsettings,
    required this.allCompanies,
    required this.currentCompanyId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userid = "";
  String token = "";
  String? selectedCompanyId;

  @override
  void initState() {
    super.initState();
    initate();
  }

  void initate() async {
    userid = (await Utils.getStringFromPrefs(constants.USER_ID))!;
    token = (await Utils.getStringFromPrefs(constants.TOKEN))!;
    selectedCompanyId = widget.currentCompanyId;
    setState(() {});
  }

  Future<void> _switchCompany(String companyId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1/switch-company",
        ),
      );

      request.fields['apiToken'] = token;
      request.fields['user_id'] = userid;
      request.fields['company_id'] = companyId;

      var response = await request.send();
      if (response.statusCode == 200) {
        var res = await http.Response.fromStream(response);
        var data = jsonDecode(res.body);

        if (data["status"] == 200) {

          SnackBar(content: Text("Company switched successfully!"));

          setState(() {
            selectedCompanyId = companyId;
          });
        } else {
          SnackBar(content: Text(data["error_msg"] ?? "Failed to switch company"));

        }
      } else {
        SnackBar(content: Text("Error: ${response.statusCode}"));

      }
    } catch (e) {
      SnackBar(content: Text("Something went wrong: $e"));

    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            if (widget.allCompanies.isNotEmpty)
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCompanyId,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (value) {
                    if (value != null && value != selectedCompanyId) {
                      _switchCompany(value);
                    }
                  },
                  items: widget.allCompanies.map<DropdownMenuItem<String>>((company) {
                    return DropdownMenuItem<String>(
                      value: company["id"].toString(),
                      child: Text(company["name"]),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.adminPermissions.isEmpty
                ? const Center(
              child: Text(
                "No Permissions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 buttons per row
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              itemCount: widget.adminPermissions.length,
              itemBuilder: (context, index) {
                final module = widget.adminPermissions[index];
                return GestureDetector(
                  onTap: () {
                    if (module["module_id"].toString() == "93") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBillScreen(
                            userId: userid,
                            apiToken: token,
                            p_add: module["add_permission"].toString(),
                            p_view: module["view_permission"].toString(),
                            approv_permission: widget.dashboardsettings,
                          ),
                        ),
                      );
                    } else if (module["module_id"].toString() == "94") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HeadListScreen(
                            module["add_permission"].toString(),
                            module["edit_permission"].toString(),
                            module["delete_permission"].toString(),
                            module["view_permission"].toString(),
                          ),
                        ),
                      );
                    } else if (module["module_id"].toString() == "95") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppImprestScreen(
                            userId: userid,
                            apiToken: token,
                            p_add: module["add_permission"].toString(),
                            p_view: module["view_permission"].toString(),
                          ),
                        ),
                      );
                    } else if (module["module_id"].toString() == "98") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllImprestPaymentReportScreen(
                            userId: userid,
                            apiToken: token,
                          ),
                        ),
                      );
                    } else if (module["module_id"].toString() == "99") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DailyReportScreen(
                            userId: userid,
                            apiToken: token,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          module["module_name"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Standout Button ---
          Padding(
            padding: const EdgeInsets.only(bottom: 28.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SaveDailyReportScreen(
                        userId: userid,
                        apiToken: token,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD2B48C),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  "Save Daily Report",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
