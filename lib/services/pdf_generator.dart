import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/score_model.dart';

class PdfGenerator {
  static Future<pw.Document> generateScorePdf({
    required String stationName,
    required String date,
    required Map<String, CoachScore> coachScores,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Train Cleanliness Inspection')),
          pw.Paragraph(text: 'Station: $stationName'),
          pw.Paragraph(text: 'Date: $date'),
          pw.SizedBox(height: 10),
          ...coachScores.entries.map((entry) {
            final coach = entry.key;
            final data = entry.value;
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Coach: $coach', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: 'Toilets:'),
                ...data.toilets.entries.map((e) => pw.Text('  ${e.key}: ${e.value.score}/10 - ${e.value.remark}')),
                pw.Bullet(text: 'Doorways:'),
                ...data.doors.entries.map((e) => pw.Text('  ${e.key}: ${e.value.score}/10 - ${e.value.remark}')),
                pw.Bullet(text: 'Vestibules:'),
                ...data.vestibules.entries.map((e) => pw.Text('  ${e.key}: ${e.value.score}/10 - ${e.value.remark}')),
                pw.SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );

    return pdf;
  }
}
