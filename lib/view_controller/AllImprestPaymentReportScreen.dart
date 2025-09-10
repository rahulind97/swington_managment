import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:swington_managment/constants/constants.dart';

class AllImprestPaymentReportScreen extends StatefulWidget {
  final String userId;
  final String apiToken;

  const AllImprestPaymentReportScreen({
    Key? key,
    required this.userId,
    required this.apiToken,
  }) : super(key: key);

  @override
  State<AllImprestPaymentReportScreen> createState() =>
      _AllImprestPaymentReportScreenState();
}

class _AllImprestPaymentReportScreenState
    extends State<AllImprestPaymentReportScreen> {
  List<dynamic> reportData = [];
  List<dynamic> imprestPayment = [];
  List<dynamic> imprestPaidPayment = [];
  int? totalBalance;
  int? remainingBalance;
  bool isLoading = false;

  DateTime? startDate;
  DateTime? endDate;
  int? selectedHeadId;

  List<dynamic> heads = [];

  @override
  void initState() {
    super.initState();
    fetchHeads().then((_) {
      fetchReport(); // fetch report immediately when screen appears
    });
  }

  String formatDate(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  Future<void> fetchHeads() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1/get-heads"),
      );
      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;
   //   request.fields['company_id'] = "2";

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (responseData.statusCode == 200) {
        var jsonBody = json.decode(responseData.body);
        setState(() {
          heads = jsonBody['heads'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching heads: $e");
    }
  }

  Future<void> fetchReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${constants.BASE_URL}allImpresetReport'),
      );

      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;

      if (startDate != null) {
        request.fields['start_date'] = formatDate(startDate!);
      }
      if (endDate != null) {
        request.fields['end_date'] = formatDate(endDate!);
      }
      if (selectedHeadId != null) {
        request.fields['apphead_id'] = selectedHeadId.toString();
      }

      print(request.runtimeType);
      print(request);
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (responseData.statusCode == 200) {
        var jsonBody = json.decode(responseData.body);

        setState(() {
          reportData = jsonBody['reportData'] ?? [];
          imprestPayment = jsonBody['imprest_payment'] ?? [];
          imprestPaidPayment = jsonBody['imprest_paid_payment'] ?? [];
          totalBalance = jsonBody['total_balance'];
          remainingBalance = jsonBody['remaining_blanace'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load report")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> pickDateRange(bool isStart) async {
    DateTime initialDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Widget buildBalanceSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Balance: ₹${totalBalance ?? 0}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Remaining Balance: ₹${remainingBalance ?? 0}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReportDataList() {
    if (reportData.isEmpty) {
      return const Center(child: Text("No report data found"));
    }

    return ListView.builder(
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
                Text("Amount: ₹${item['amount'] ?? 0}"),
                const SizedBox(height: 6),
                Text("Status: ${item['verify_status'] ?? ''}"),
                if (widget.userId == "1") ...[
                  const SizedBox(height: 6),
                  Text("Generated By: ${item['bill_generate_by'] ?? ''}"),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildImprestPaymentList(List<dynamic> list, String type) {
    if (list.isEmpty) {
      return Center(child: Text("No $type data found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
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
                  "Date: ${item['date'] ?? ''}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Received From: ${item['received_from'] ?? ''}"),
                const SizedBox(height: 6),
                Text("Pay To: ${item['pay_to'] ?? ''}"),
                const SizedBox(height: 6),
                Text("Amount: ₹${item['amount'] ?? 0}"),
                const SizedBox(height: 6),
                Text(
                  "Payment Status : ${item['payment_status'] ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => pickDateRange(true),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    startDate == null ? "Start Date" : formatDate(startDate!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => pickDateRange(false),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    endDate == null ? "End Date" : formatDate(endDate!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: selectedHeadId,
          hint: const Text("Select Head"),
          items: heads.map((head) {
            return DropdownMenuItem<int>(
              value: head['id'],
              child: Text(head['name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedHeadId = value;
            });
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: fetchReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD2B48C),
              foregroundColor: Colors.black,
            ),
            child: const Text("Apply Filter"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFD2B48C),
          title: const Text("All Head Report"),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Head Payment"),
              Tab(text: "Imprest In"),
              Tab(text: "Imprest Out"),
            ],
          ),
        ),
        body: Column(
          children: [
            buildBalanceSection(),
            Visibility(
              visible: false,
              child: ExpansionTile(
                title: const Text(
                  "Filters",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: buildFilters(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                children: [
                  buildReportDataList(),
                  buildImprestPaymentList(imprestPayment, "imprest received"),
                  buildImprestPaymentList(imprestPaidPayment, "imprest paid"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
