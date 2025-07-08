import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/score_provider.dart';

class ReviewScreen extends StatelessWidget {
  Future<void> _submitData(BuildContext context) async {
    final provider = Provider.of<ScoreProvider>(context, listen: false);
    final jsonData = provider.toJson();

    final response = await http.post(
      Uri.parse('https://httpbin.org/post'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(jsonData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submitted successfully!')));
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed.')));
    }
  }

  void _generatePdf(BuildContext context) async {
    final provider = Provider.of<ScoreProvider>(context, listen: false);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Digital Score Card', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 10),
          pw.Text('Station: ${provider.stationName}'),
          pw.Text('Date: ${provider.inspectionDate}'),
          pw.SizedBox(height: 20),
          ...provider.scores.entries.map((coachEntry) {
            return pw.Column(children: [
              pw.Text('Coach: ${coachEntry.key}', style: pw.TextStyle(fontSize: 18)),
              ...coachEntry.value.entries.map((sectionEntry) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('  Section: ${sectionEntry.key}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ...sectionEntry.value.entries.map((paramEntry) {
                      final score = paramEntry.value['score'];
                      final remarks = paramEntry.value['remarks'];
                      return pw.Text('    ${paramEntry.key}: $score, Remarks: $remarks');
                    }),
                  ],
                );
              }),
              pw.SizedBox(height: 10),
            ]);
          }),
        ],
      ),
    );

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
            Text('Station: ${provider.stationName}', style: TextStyle(fontSize: 16)),
            Text('Date: ${provider.inspectionDate}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ...provider.scores.entries.map((coachEntry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coach: ${coachEntry.key}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...coachEntry.value.entries.map((sectionEntry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('  Section: ${sectionEntry.key}', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...sectionEntry.value.entries.map((paramEntry) {
                          final score = paramEntry.value['score'];
                          final remarks = paramEntry.value['remarks'];
                          return Text('    ${paramEntry.key}: $score, Remarks: $remarks');
                        }).toList(),
                      ],
                    );
                  }).toList(),
                  SizedBox(height: 16),
                ],
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
