// 📁 lib/services/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static Future<pw.Document> generateFromJson(List<Map<String, dynamic>> reports) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Train Cleanliness Reports')),
          ...reports.map((report) {
            final station = report['stationName'];
            final date = report['inspectionDate'];
            final coaches = report['coaches'] as List;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text('Station: $station'),
                pw.Text('Date: $date'),
                ...coaches.map((coach) {
                  final name = coach['name'];
                  final toilets = coach['toilets'] ?? {};
                  final doors = coach['doorways'] ?? {};
                  final vestibules = coach['vestibules'] ?? {};

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Text('Coach: $name', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text('  Toilets:'),
                      ...toilets.entries.map((e) => pw.Text('    ${e.key}: ${e.value['score']}/10 - ${e.value['remarks']}')),
                      pw.Text('  Doorways:'),
                      ...doors.entries.map((e) => pw.Text('    ${e.key}: ${e.value['score']}/10 - ${e.value['remarks']}')),
                      pw.Text('  Vestibules:'),
                      ...vestibules.entries.map((e) => pw.Text('    ${e.key}: ${e.value['score']}/10 - ${e.value['remarks']}')),
                    ],
                  );
                }),
                pw.Divider(),
              ],
            );
          }),
        ],
      ),
    );

    return pdf;
  }
}
