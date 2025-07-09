// 📁 lib/screens/review_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/score_provider.dart';
import '../services/report_storage_service.dart';
import '../services/pdf_generator.dart';

class ReviewScreen extends StatelessWidget {
  Future<void> _submitData(BuildContext context) async {
    final provider = Provider.of<ScoreProvider>(context, listen: false);
    final jsonData = provider.toJson();

    try {
      await ReportStorageService.saveReport(jsonData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Local save failed: $e')),
      );
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submitted successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Submission failed.')),
      );
    }
  }

  void _generatePdf(BuildContext context) async {
    final provider = Provider.of<ScoreProvider>(context, listen: false);
    final jsonData = provider.toJson();
    final pdf = await PdfGenerator.generateFromJson([jsonData]);
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScoreProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Review Submission')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('📍 Station: ${provider.stationName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text('📅 Date: ${provider.inspectionDate}',
                style: TextStyle(fontSize: 16)),
            Divider(thickness: 2, height: 24),

            ...provider.scores.entries.map((coachEntry) {
              final coachName = coachEntry.key;
              final sections = coachEntry.value;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🚆 Coach: $coachName',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      ...sections.entries.map((sectionEntry) {
                        final sectionName = sectionEntry.key;
                        final params = sectionEntry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📌 Section: ${sectionName[0].toUpperCase()}${sectionName.substring(1)}',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo),
                            ),
                            DataTable(
                              columnSpacing: 12,
                              columns: const [
                                DataColumn(label: Text('Parameter')),
                                DataColumn(label: Text('Score')),
                                DataColumn(label: Text('Remarks')),
                              ],
                              rows: params.entries.map((paramEntry) {
                                final param = paramEntry.key;
                                final data = paramEntry.value;
                                final score = data['score'] ?? 0;
                                final remarks = data['remarks'] ?? '';

                                return DataRow(cells: [
                                  DataCell(Text(param)),
                                  DataCell(Text('$score')),
                                  DataCell(Text(remarks)),
                                ]);
                              }).toList(),
                            ),
                            SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _generatePdf(context),
            icon: Icon(Icons.picture_as_pdf),
            label: Text("Export PDF"),
            heroTag: 'pdfBtn',
          ),
          SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () => _submitData(context),
            icon: Icon(Icons.send),
            label: Text("Submit"),
            heroTag: 'submitBtn',
          ),
        ],
      ),
    );
  }
}
