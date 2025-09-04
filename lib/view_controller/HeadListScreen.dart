import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:swington_managment/constants/constants.dart';
import 'package:swington_managment/utils/Utils.dart';

import '../utils/ApiInterceptor.dart';

class HeadListScreen extends StatefulWidget {
  final String p_add;
  final String p_edit;
  final String p_delete;
  final String p_view;

  HeadListScreen(this.p_add, this.p_edit, this.p_delete, this.p_view, {super.key});

  @override
  State<HeadListScreen> createState() => _HeadListScreenState();
}

class _HeadListScreenState extends State<HeadListScreen> {
  final Dio _dio = ApiInterceptor.createDio();

  String userid = "";
  String token = "";

  List heads = [];
  bool loading = true;

  final Color themeColor = const Color(0xFFD2B48C);

  @override
  void initState() {
    super.initState();
    initate();
  }

  void initate() async {
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
        "${constants.BASE_URL}get-heads",
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

  Future<void> addHead(String name,String amount) async {
    try {
      final formData = FormData.fromMap({
        "user_id": userid,
        "apiToken": token,
        "name": name,
        "max_limit_amount": amount,
      });

      await _dio.post("${constants.BASE_URL}add-heads", data: formData);
      fetchHeads();
    } catch (e) {
      debugPrint("Add error: $e");
    }
  }

  Future<void> updateHead(String id, String name,String amount) async {
    try {
      final formData = FormData.fromMap({
        "user_id": userid,
        "apiToken": token,
        "head_id": id,
        "name": name,
        "max_limit_amount": amount,
      });

      await _dio.post("${constants.BASE_URL}update-heads", data: formData);
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

      await _dio.post("${constants.BASE_URL}delete-heads", data: formData);
      fetchHeads();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void _showAddEditDialogAdd({String? id, String? currentName, String? currentAmount}) {
    final nameController = TextEditingController(text: currentName ?? "");
    final amountController = TextEditingController(text: currentAmount ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          id == null ? "Add Head" : "Edit Head",
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter head name",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter amount",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
              final name = nameController.text.trim();
              final amount = amountController.text.trim();
              if (name.isNotEmpty && amount.isNotEmpty) {
                if (id == null) {
                  addHead(name, amount);
                } else {
                  updateHead(id, name,amount);
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

      // ✅ Show Add button only if p_add == "1"
      floatingActionButton: widget.p_add == "1"
          ? FloatingActionButton(
        backgroundColor: themeColor,
        onPressed: () => _showAddEditDialogAdd(),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : widget.p_view == "0"
          ? const Center(child: Text("You don’t have permission to view"))
          : heads.isEmpty
          ? const Center(child: Text("No heads found"))
          : Column(
        children: [
          // 🔹 Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Head",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Max Limit",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Actions",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                //  SizedBox(width: 56), // space for action icons
                ],
              ),
            ),
          ),

          // 🔹 List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              itemCount: heads.length,
              itemBuilder: (context, index) {
                final head = heads[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 🔸 Left: Head name + Tags
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                (head["name"] ?? "").toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                             // const SizedBox(height: 8),

                              // Tags row: ONLY "Generate Bill" as requested
                              // Wrap(
                              //   spacing: 8,
                              //   runSpacing: 8,
                              //   children: [
                              //     Container(
                              //       padding:
                              //       const EdgeInsets.symmetric(
                              //           horizontal: 10,
                              //           vertical: 5),
                              //       decoration: BoxDecoration(
                              //         color: Colors.green[50],
                              //         borderRadius:
                              //         BorderRadius.circular(8),
                              //         border: Border.all(
                              //             color: Colors
                              //                 .green.shade200),
                              //       ),
                              //       child: Text(
                              //         "Generate Bill",
                              //         style: TextStyle(
                              //           fontSize: 12.5,
                              //           fontWeight: FontWeight.w600,
                              //           color: Colors.green[700],
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 🔸 Middle-right: Max Limit (single spot -> no duplication)
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius:
                                BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.red.shade200),
                              ),
                              child: Text(
                                (head["max_limit_amount"] ?? "")
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[400],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // 🔸 Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.p_edit == "1")
                              IconButton(
                                tooltip: "Edit",
                                icon: Icon(Icons.edit,
                                    color: themeColor),
                                onPressed: () => _showAddEditDialogAdd(
                                  id: head["id"].toString(),
                                  currentName:
                                  (head["name"] ?? "")
                                      .toString(),
                                  currentAmount:
                                  (head["max_limit_amount"] ??
                                      "")
                                      .toString(),
                                ),
                              ),
                            if (widget.p_delete == "1")
                              IconButton(
                                tooltip: "Delete",
                                icon: Icon(Icons.delete,
                                    color: Colors.red[300]),
                                onPressed: () => _confirmDelete(
                                    head["id"].toString()),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
