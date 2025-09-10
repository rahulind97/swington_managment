import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DailyWiseReportScreen extends StatefulWidget {
  final String userId;
  final String apiToken;
  final String date;

  const DailyWiseReportScreen({
    Key? key,
    required this.userId,
    required this.apiToken,
    required this.date,
  }) : super(key: key);

  @override
  State<DailyWiseReportScreen> createState() => _DailyWiseReportScreenState();
}

class _DailyWiseReportScreenState extends State<DailyWiseReportScreen> {
  List<dynamic> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDailyWiseReport();
  }

  Future<void> fetchDailyWiseReport() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "https://blueviolet-spoonbill-658373.hostingersite.com/demotesting/api/v1/fetch-daily-report",
        ),
      );
      request.fields['user_id'] = widget.userId;
      request.fields['apiToken'] = widget.apiToken;
      request.fields['date'] = widget.date;

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      var data = json.decode(responseData);
      if (data['status'] == 200) {
        setState(() {
          reports = data['day_wise_report'];
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

  void openImagePreview(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        title: Text("Report for ${widget.date}"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
          ? const Center(child: Text("No reports available"))
          : ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Remark: ${report['remark'] ?? ''}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Added by: ${report['added_by'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (report['attachment'] != null &&
                      report['attachment'].isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        report['attachment'].length,
                            (imgIndex) {
                          String imageUrl =
                          report['attachment'][imgIndex];
                          return GestureDetector(
                            onTap: () => openImagePreview(imageUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                    Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.grey),
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
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

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2B48C),
        title: const Text("Image Preview"),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, color: Colors.white, size: 50),
          ),
        ),
      ),
    );
  }
}
