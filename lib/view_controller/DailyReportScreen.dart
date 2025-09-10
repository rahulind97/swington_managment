import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:swington_managment/view_controller/DailyWiseReportScreen.dart';
import 'package:intl/intl.dart';

class DailyReportScreen extends StatefulWidget {
  final String userId;
  final String apiToken;

  const DailyReportScreen({
    Key? key,
    required this.userId,
    required this.apiToken,
  }) : super(key: key);

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  List<dynamic> dayWiseReport = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDayWiseReport();
  }

  Future<void> fetchDayWiseReport() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1/dayWiseReport",
        ),
      );
      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      var data = json.decode(responseData);
      if (data['status'] == 200) {
        setState(() {
          dayWiseReport = data['day_wise_report'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching report: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        title: const Text("Daily Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: () {
              print("Download clicked");
              // Later you can add PDF/Excel download here
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dayWiseReport.isEmpty
          ? const Center(child: Text("No reports available"))
          : ListView.builder(
        itemCount: dayWiseReport.length,
        itemBuilder: (context, index) {
          final report = dayWiseReport[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.date_range,
                  color: Colors.brown),
              title: Text(
                report['date'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

// inside onTap of the ListTile
                onTap: () {
              // Convert date from dd-MM-yyyy → yyyy-MM-dd
              String formattedDate = "";
              try {
          final inputFormat = DateFormat("dd-MM-yyyy");
          final outputFormat = DateFormat("yyyy-MM-dd");
          formattedDate = outputFormat.format(inputFormat.parse(report['date']));
          } catch (e) {
            formattedDate = report['date']; // fallback if parsing fails
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyWiseReportScreen(
                userId: widget.userId,
                apiToken: widget.apiToken,
                date: formattedDate, // pass formatted date
              ),
            ),
          );
        }


          ),
          );
        },
      ),
    );
  }
}
