import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:swington_managment/constants/constants.dart';
import 'package:swington_managment/utils/Utils.dart';

import '../utils/ApiInterceptor.dart';

class HeadListScreen extends StatefulWidget {
  const HeadListScreen({super.key});

  @override
  State<HeadListScreen> createState() => _HeadListScreenState();
}

class _HeadListScreenState extends State<HeadListScreen> {
  final Dio _dio = ApiInterceptor.createDio();
  final String baseUrl = "https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1";

  String userid ="";
  String token ="";

  List heads = [];
  bool loading = true;

  final Color themeColor = const Color(0xFFD2B48C);

  @override
  void initState() {
    super.initState();
    initate();

  }


  void initate()async {
    userid = (await Utils.getStringFromPrefs(constants.USER_ID))!;
    token = (await Utils.getStringFromPrefs(constants.TOKEN))!;
    fetchHeads();
  }

  Future<void> fetchHeads() async {
    setState(() => loading = true);
    try {
      final formData = FormData.fromMap({
        "user_id": userid,
        "apiToken": token,
      });

      final response = await _dio.post(
        "$baseUrl/get-heads",
        data: formData,
      );

      if (response.data["status"] == 200) {
        setState(() {
          heads = response.data["heads"] ?? [];
          loading = false;
        });
      } else {
        setState(() {
          heads = [];
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
      debugPrint("Fetch error: $e");
    }
  }

  Future<void> addHead(String name) async {
    try {
      final formData = FormData.fromMap({
        "user_id": userid,
        "apiToken": token,
        "name": name,
      });

      await _dio.post("$baseUrl/add-heads", data: formData);
      fetchHeads();
    } catch (e) {
      debugPrint("Add error: $e");
    }
  }

  Future<void> updateHead(String id, String name) async {
    try {
      final formData = FormData.fromMap({
        "user_id": userid,
        "apiToken": token,
        "head_id": id,
        "name": name,
      });

      await _dio.post("$baseUrl/update-heads", data: formData);
      fetchHeads();
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  Future<void> deleteHead(String id) async {
    try {
      final formData = FormData.fromMap({
        "user_id": userid,
        "apiToken": token,
        "head_id": id,
      });

      await _dio.post("$baseUrl/delete-heads", data: formData);
      fetchHeads();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void _showAddEditDialog({String? id, String? currentName}) {
    final controller = TextEditingController(text: currentName ?? "");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          id == null ? "Add Head" : "Edit Head",
          style: TextStyle(
              color: themeColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter head name",
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                if (id == null) {
                  addHead(name);
                } else {
                  updateHead(id, name);
                }
                Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this head?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              deleteHead(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 4,
        title: const Text(
          "Head Screen",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColor,
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : heads.isEmpty
          ? const Center(child: Text("No heads found"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: heads.length,
        itemBuilder: (context, index) {
          final head = heads[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 16),
              title: Text(
                head["name"],
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: themeColor),
                    onPressed: () => _showAddEditDialog(
                      id: head["id"].toString(),
                      currentName: head["name"],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _confirmDelete(head["id"].toString()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
