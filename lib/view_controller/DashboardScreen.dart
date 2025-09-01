import 'package:flutter/material.dart';
import 'package:swington_managment/constants/constants.dart';
import 'package:swington_managment/utils/Utils.dart';
import 'package:swington_managment/view_controller/AddBillScreen.dart';

class DashboardScreen extends StatefulWidget {
  final List<dynamic> adminPermissions;

  const DashboardScreen({super.key, required this.adminPermissions});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {

  String userid ="";
  String token ="";

  @override
  void initState() {
    // TODO: implement initState
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
      body: GridView.builder(
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

              if(module["module_id"]=="93"){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBillScreen(userId: userid, apiToken: token),
                  ),
                );

              }else if(module["module_id"]=="94"){

              }else if (module["module_id"]=="95"){

              }



              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(


                    "Clicked on ${module["module_name"]} (ID: ${module["module_id"]})",



                  ),
                ),
              );
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

