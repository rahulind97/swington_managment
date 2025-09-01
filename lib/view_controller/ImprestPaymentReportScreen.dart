import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:swington_managment/constants/constants.dart';

class ImprestPaymentReportScreen extends StatefulWidget {
  final String userId;
  final String apiToken;

  const ImprestPaymentReportScreen({
    Key? key,
    required this.userId,
    required this.apiToken,
  }) : super(key: key);

  @override
  State<ImprestPaymentReportScreen> createState() =>
      _ImprestPaymentReportScreenState();
}

class _ImprestPaymentReportScreenState
    extends State<ImprestPaymentReportScreen> {
  List<dynamic> reportData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  Future<void> fetchReport() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${constants.BASE_URL}imperest-payment-report'),
      );
      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (responseData.statusCode == 200) {
        var jsonBody = json.decode(responseData.body);
        setState(() {
          reportData = jsonBody['reportData'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load report")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        title: const Text("Imprest Payment Report"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reportData.isEmpty
          ? const Center(child: Text("No report data found"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reportData.length,
        itemBuilder: (context, index) {
          var item = reportData[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date: ${item['bill_date'] ?? ''}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text("Head: ${item['head'] ?? ''}"),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("In Balance: ${item['in_balance']}"),
                      Text("Out: ${item['out_amount']}"),
                      Text(
                        "Balance: ${item['balance']}",
                        style: TextStyle(
                          color: (item['balance'] ?? 0) < 0
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
