import 'package:flutter/material.dart';
import 'package:swington_managment/constants/constants.dart';
import 'package:swington_managment/utils/Utils.dart';
import 'package:swington_managment/view_controller/AddBillScreen.dart';
import 'package:swington_managment/view_controller/DailyReportScreen.dart';
import 'package:swington_managment/view_controller/HeadBillReportScreen.dart';
import 'package:swington_managment/view_controller/HeadListScreen.dart';
import 'package:swington_managment/view_controller/LoginScreen.dart';
import 'package:swington_managment/view_controller/SaveDailyReportScreen.dart';
import 'App Imprest.dart';

class DashboardScreen extends StatefulWidget {
  final List<dynamic> adminPermissions;
  final String dashboardsettings;

  const DashboardScreen({
    super.key,
    required this.adminPermissions,
    required this.dashboardsettings,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userid = "";
  String token = "";

  @override
  void initState() {
    super.initState();
    initate();
  }

  void initate() async {
    userid = (await Utils.getStringFromPrefs(constants.USER_ID))!;
    token = (await Utils.getStringFromPrefs(constants.TOKEN))!;
    setState(() {});
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
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    } else if (module["module_id"].toString() == "97" ||
                        module["module_id"].toString() == "98") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HeadBillReportScreen(
                            userId: userid,
                            apiToken: token,
                            approv_permission: "1",
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
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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
