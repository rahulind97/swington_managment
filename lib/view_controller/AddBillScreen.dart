import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:swington_managment/constants/constants.dart';
import 'package:swington_managment/utils/Utils.dart';

class AddBillScreen extends StatefulWidget {
  final String userId;
  final String apiToken;

  const AddBillScreen({
    super.key,
    required this.userId,
    required this.apiToken,
  });

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _amountController = TextEditingController();
  String? _selectedHeadId;
  String? _selectedBillType;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isFetchingHeads = false;
  String userid ="";
  String token ="";
  List<Map<String, dynamic>> _heads = [];

  @override
  void initState() {
    super.initState();
    initate();
  }

  void initate()async {
    userid = (await Utils.getStringFromPrefs(constants.USER_ID))!;
    token = (await Utils.getStringFromPrefs(constants.TOKEN))!;
    _fetchHeads();
  }

  Future<void> _fetchHeads() async {
    setState(() => _isFetchingHeads = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1/get-heads"),
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitBill() async {
    if (_selectedHeadId == null ||
        _selectedBillType == null ||
        _amountController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1/addBills"),
      );

      request.fields['head_id'] = _selectedHeadId!;
      request.fields['amount'] = _amountController.text.trim();
      request.fields['bill_type'] = _selectedBillType!;
      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;

      request.files.add(await http.MultipartFile.fromPath('bill_photo', _selectedImage!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        if (data["status"] == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Bill added successfully")),
          );
          Navigator.pop(context);
        } else {
          _showError(data["message"] ?? "Failed to add bill");
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Something went wrong: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        title: const Text("Add Bill"),
      ),
      body: _isFetchingHeads
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
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
                onChanged: (value) {
                  setState(() {
                    _selectedHeadId = value;
                  });
                },
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
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 15),

              // Bill Type
              DropdownButtonFormField<String>(
                value: _selectedBillType,
                decoration: InputDecoration(
                  hintText: "Select Bill Type",
                  filled: true,
                  fillColor: const Color(0xFFEFF3FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "imprest", child: Text("Imprest")),
                  DropdownMenuItem(value: "normal", child: Text("Normal")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBillType = value;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Bill Photo
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _selectedImage == null
                      ? const Center(child: Text("Tap to upload bill photo"))
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBill,
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
                    style: TextStyle(fontSize: 16, color: Colors.white),
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

