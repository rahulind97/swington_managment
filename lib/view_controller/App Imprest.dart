import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:swington_managment/constants/constants.dart';
import 'package:swington_managment/utils/Utils.dart';
import 'package:swington_managment/view_controller/ImprestPaymentReportScreen.dart';
import '../utils/ApiInterceptor.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class AppImprestScreen extends StatefulWidget {
  final String userId;
  final String apiToken;
  final String p_add;
  final String p_view;

  const AppImprestScreen({
    super.key,
    required this.userId,
    required this.apiToken,
    required this.p_add,
    required this.p_view,
  });

  @override
  State<AppImprestScreen> createState() => _AppImprestScreenState();
}

class _AppImprestScreenState extends State<AppImprestScreen> {
  final _amountController = TextEditingController();
  String? _selectedHeadId;
  String? _toUserId;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isFetchingHeads = false;
  String userid = "";
  String token = "";
  List<Map<String, dynamic>> _heads = [];
  List<Map<String, dynamic>> _users = [];
  final Dio _dio = ApiInterceptor.createDio();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    initate();
  }

  void initate() async {
    userid = (await Utils.getStringFromPrefs(constants.USER_ID))!;
    token = (await Utils.getStringFromPrefs(constants.TOKEN))!;
    _fetchHeads();
    fetchUsers();
  }

  Future<void> _fetchHeads() async {
    setState(() => _isFetchingHeads = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${constants.BASE_URL}get-heads"),
      );

      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        if (data["status"] == 200 && data["heads"] != null) {
          setState(() {
            _heads = List<Map<String, dynamic>>.from(data["heads"]);
          });
        } else {
          _showError("Failed to fetch heads: ${data["message"] ?? ''}");
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Error fetching heads: $e");
    }
    setState(() => _isFetchingHeads = false);
  }

  Future<void> fetchUsers() async {
    try {
      final response = await _dio.post(
        "${constants.BASE_URL}get-users-lists",
        data: FormData.fromMap({
          "user_id": userid,
          "apiToken": token,
        }),
      );

      if (response.statusCode == 200) {
        if (response.data["status"] == 200 && response.data["heads"] != null) {
          setState(() {
            _users = List<Map<String, dynamic>>.from(response.data["heads"]);
          });
        } else {
          _showError("Failed to fetch users: ${response.data["message"] ?? ''}");
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error: $e");
    }
  }

  Future<void> makeImperestPayment() async {
    if (_selectedHeadId == null ||
        _toUserId == null ||
        _amountController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.post(
        "${constants.BASE_URL}imperest-payment",
        data: FormData.fromMap({
          "user_id": widget.userId,
          "to_user_id": _toUserId,
          "amount": _amountController.text.trim(),
          "date": DateFormat("yyyy-MM-dd").format(_selectedDate!),
          "apiToken": widget.apiToken,
          "head_id": _selectedHeadId,
        }),
      );

      if (response.statusCode == 200) {
        if (response.data["status"] == 200) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data["message"])),
          );
          Navigator.pop(context, true);
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data["message"] ?? "Payment failed")),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("🔥 Error: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        title: const Text("App Imprest"),
        actions: [
          if (widget.p_view == "1") // 👈 Show report button only if p_view = 1
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: "View Report",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImprestPaymentReportScreen(
                      userId: widget.userId,
                      apiToken: widget.apiToken,
                    ),
                  ),
                );
              },
            ),
        ],
      ),

      body: _isFetchingHeads
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: (widget.p_add == "1") // 👈 Show form only if p_add = 1
            ? Container(
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
            children: [
              // Head Dropdown
              DropdownButtonFormField<String>(
                value: _selectedHeadId,
                decoration: InputDecoration(
                  hintText: "Select Head",
                  filled: true,
                  fillColor: const Color(0xFFEFF3FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _heads.map((head) {
                  return DropdownMenuItem(
                    value: head["id"].toString(),
                    child: Text(head["name"]),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _selectedHeadId = value;
                }),
              ),
              const SizedBox(height: 15),

              // User Dropdown
              DropdownButtonFormField<String>(
                value: _toUserId,
                decoration: InputDecoration(
                  hintText: "Select User",
                  filled: true,
                  fillColor: const Color(0xFFEFF3FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _users.map((user) {
                  final firstName = user["first_name"] ?? "";
                  final lastName = user["last_name"] ?? "";
                  return DropdownMenuItem(
                    value: user["id"].toString(),
                    child: Text("$firstName $lastName".trim()),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _toUserId = value;
                }),
              ),
              const SizedBox(height: 15),

              // Amount
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter Amount",
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 15),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: "Select Date",
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                    ),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? "Select Date"
                        : DateFormat("yyyy-MM-dd").format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : makeImperestPayment,
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
                    "Submit Bill",
                    style: TextStyle(
                        fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        )
            : const Center(
          child: Text(
            "🚫 You don’t have permission to add Imprest.",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
