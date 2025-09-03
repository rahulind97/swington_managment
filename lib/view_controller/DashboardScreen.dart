import 'package:flutter/material.dart';
import 'package:swington_managment/constants/constants.dart';
import 'package:swington_managment/utils/Utils.dart';
import 'package:swington_managment/view_controller/AddBillScreen.dart';
import 'package:swington_managment/view_controller/HeadListScreen.dart';

import 'App Imprest.dart';

class DashboardScreen extends StatefulWidget {
  final List<dynamic> adminPermissions;
  final String  dashboardsettings;

  const DashboardScreen({super.key, required this.adminPermissions,required this.dashboardsettings});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {

  String userid ="";
  String token ="";

  @override
  void initState() {
    initate();
    super.initState();
  }

  void initate()async {
    userid = (await Utils.getStringFromPrefs(constants.USER_ID))!;
    token = (await Utils.getStringFromPrefs(constants.TOKEN))!;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        title: const Text("Dashboard"),
      ),
      body: widget.adminPermissions.isEmpty
          ? const Center(
        child: Text(
          "No Permissions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 buttons per row
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: widget.adminPermissions.length,
        itemBuilder: (context, index) {
          final module = widget.adminPermissions[index];
          return GestureDetector(
            onTap: () {
              print("object");

              if(module["module_id"].toString()=="93"){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBillScreen(userId: userid, apiToken: token,p_add:module["add_permission"].toString(),p_view: module["view_permission"].toString(),approv_permission:widget.dashboardsettings ),
                  ),
                );

              }else if(module["module_id"].toString()=="94"){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HeadListScreen(module["add_permission"].toString(),module["edit_permission"].toString(),module["delete_permission"].toString(),module["view_permission"].toString()  ),
                  ),
                );

              }else if (module["module_id"].toString()=="95"){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppImprestScreen(userId: userid, apiToken: token,p_add:module["add_permission"].toString() ,p_view: module["view_permission"].toString(),),
                  ),
                );
              }


            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
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
          );
        },
      ),
    );
  }
}

