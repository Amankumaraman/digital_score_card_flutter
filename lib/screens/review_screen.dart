import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../providers/score_provider.dart';
import '../services/report_storage_service.dart';
import '../services/pdf_generator.dart';
import '../theme/app_theme.dart';

class ReviewScreen extends StatelessWidget {
  Future<void> _submitData(BuildContext context) async {
    final provider = Provider.of<ScoreProvider>(context, listen: false);
    final jsonData = provider.toJson();

    try {
      await ReportStorageService.saveReport(jsonData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report saved locally')),
      );
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
          SnackBar(content: Text('Submission failed. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Submission'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text('📍 Station: ${provider.stationName}',
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text('📅 Date: ${provider.inspectionDate}',
                            style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            ...provider.scores.entries.map((coachEntry) {
              final coachName = coachEntry.key;
              final sections = coachEntry.value;

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.train, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text('Coach: $coachName',
                              style: theme.textTheme.titleMedium),
                        ],
                      ),
                      SizedBox(height: 12),
                      ...sections.entries.map((sectionEntry) {
                        final sectionName = sectionEntry.key;
                        final params = sectionEntry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${sectionName[0].toUpperCase()}${sectionName.substring(1)}',
                              style: AppTheme.sectionHeaderStyle,
                            ),
                            SizedBox(height: 8),
                            Table(
                              border: TableBorder.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('Parameter',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('Score',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('Remarks',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                ...params.entries.map((paramEntry) {
                                  final param = paramEntry.key;
                                  final data = paramEntry.value;
                                  final score = data['score'] ?? 0;
                                  final remarks = data['remarks'] ?? '';

                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(param),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text('$score',
                                            textAlign: TextAlign.center),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Text(remarks),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _submitData(context),
        icon: Icon(Icons.send),
        label: Text("Submit"),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}