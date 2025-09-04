import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HeadBillReportScreen extends StatefulWidget {
  final String userId;
  final String apiToken;
  final String approv_permission;

  const HeadBillReportScreen({
    super.key,
    required this.userId,
    required this.apiToken,
    required this.approv_permission,
  });

  @override
  State<HeadBillReportScreen> createState() => _HeadBillReportScreenState();
}

class _HeadBillReportScreenState extends State<HeadBillReportScreen> {
  bool isLoading = false;
  bool _isFetchingHeads = false;
  List<dynamic> billReport = [];
  List<Map<String, dynamic>> _heads = [];
  String? _selectedHeadId;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchHeads();
    fetchBillReport(); // initial load
  }

  Future<void> _fetchHeads() async {
    setState(() => _isFetchingHeads = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1/get-heads"),
      );

      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        if (data["status"] == 200 && data["heads"] != null) {
          setState(() {
            _heads = [
              {"id": "all", "name": "All"},
              ...List<Map<String, dynamic>>.from(data["heads"]),
            ];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching heads: $e");
    }
    setState(() => _isFetchingHeads = false);
  }

  Future<void> fetchBillReport() async {
    setState(() => isLoading = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1/head-wise-report",
        ),
      );

      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;

      if (_startDate != null) {
        request.fields['start_date'] =
        "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}";
      }
      if (_endDate != null) {
        request.fields['end_date'] =
        "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}";
      }
      if (_selectedHeadId != null) {
        request.fields['apphead_id'] = _selectedHeadId!;
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        setState(() {
          billReport = data['generate_bill_report'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching reports: $e");
    }
    setState(() => isLoading = false);
  }


  Future<void> _approveBill({required String billId, required String headId}) async {
    try {
      print("🔄 Approve Bill API called...");
      print("➡️ Sending Data:");
      print("user_id: ${widget.userId}");
      print("apiToken: ${widget.apiToken}");
      print("head_id: $headId");
      print("bill_id: $billId");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1/verify-generates_bills",
        ),
      );

      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;
      request.fields['head_id'] = headId;
      request.fields['bill_id'] = billId;

      print("📦 Request Fields: ${request.fields}");

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("📥 Response Code: ${response.statusCode}");
      print("📥 Raw Response Body: $responseBody");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        print("✅ Parsed Response: $data");

        if (data['status'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bill Approved Successfully")),
          );

          // 🔄 Refresh report after approval
          fetchBillReport();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Approval failed")),
          );
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server Error: ${response.statusCode}")),
        );
      }
    } catch (e, stack) {
      print("💥 Exception in Approve API: $e");
      print("📌 Stacktrace: $stack");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error approving bill: $e")),
      );
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Head Bill Report"),
        backgroundColor: const Color(0xFFD2B48C),
      ),
      body: Column(
        children: [
          // 🔽 Filters
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: true),
                        child: Text("Start: ${_formatDate(_startDate)}"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: false),
                        child: Text("End: ${_formatDate(_endDate)}"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 🔽 Dropdown Heads
                _isFetchingHeads
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Head",
                  ),
                  value: _selectedHeadId,
                  items: _heads
                      .map((h) => DropdownMenuItem(
                    value: h["id"].toString(),
                    child: Text(h["name"].toString()),
                  ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedHeadId = val;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // 🔍 Apply Filter Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD2B48C),
                  ),
                  onPressed: fetchBillReport,
                  icon: const Icon(Icons.search),
                  label: const Text("Apply Filter"),
                ),
              ],
            ),
          ),

          // 📊 Report List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : billReport.isEmpty
                ? const Center(
              child: Text(
                "No Bill Reports Found",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: billReport.length,
              itemBuilder: (context, index) {
                var item = billReport[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date: ${item['date'] ?? ''}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Head: ${item['head'] ?? ''}"),
                        const SizedBox(height: 6),
                        Text("Mode: ${item['mode'] ?? ''}"),
                        const SizedBox(height: 6),

                        // ✅ Amount + Approval Status
                        // ✅ Amount + Approval Status + Approve Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Amount: ₹${item['amount'] ?? 0}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     if (item['verify_status'] != null)
                            //       Text(
                            //         item['verify_status'].toString(),
                            //         style: TextStyle(
                            //           fontWeight: FontWeight.bold,
                            //           color: item['verify_status'].toString() == "APPROVE"
                            //               ? Colors.green
                            //               : Colors.orange,
                            //         ),
                            //       ),
                            //     const SizedBox(width: 8),
                            //     // ✅ Show tick only if status is PENDING
                            //     if (widget.approv_permission.split(',').contains("verifyheadbill") &&
                            //         item['verify_status'].toString() == "PENDING")
                            //       IconButton(
                            //         icon: const Icon(Icons.check_circle, color: Colors.green),
                            //         onPressed: () async {
                            //           print("object111");
                            //           await _approveBill(
                            //             billId: item['id'].toString(),
                            //             headId: item['head_id'].toString(),
                            //           );
                            //         },
                            //       ),
                            //   ],
                            // ),
                          ],
                        ),


                        const SizedBox(height: 6),
                        if (widget.userId == "1") ...[
                          const Text(
                              "Bill Generated By: Leena Sharma"),
                          const SizedBox(height: 6),
                        ],
                        if (item['bill_photo'] != null &&
                            item['bill_photo']
                                .toString()
                                .isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenImage(
                                    imageUrl: item['bill_photo'],
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item['bill_photo'],
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return const Text(
                                      "Image not available");
                                },
                              ),
                            ),
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

/// ✅ Full Screen Image Viewer
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                "Failed to load image",
                style: TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}
