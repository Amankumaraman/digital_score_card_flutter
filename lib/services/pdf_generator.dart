// 📁 lib/services/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static Future<pw.Document> generateFromJson(List<Map<String, dynamic>> reports) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Train Cleanliness Inspection Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          for (final report in reports) ...[
            pw.SizedBox(height: 8),
            pw.Text("📍 Station: ${report['stationName']}", style: pw.TextStyle(fontSize: 16)),
            pw.Text("📅 Date: ${report['inspectionDate']}", style: pw.TextStyle(fontSize: 16)),
            pw.Divider(),

            for (final coach in report['coaches']) ...[
              pw.SizedBox(height: 12),
              pw.Text("🚆 Coach: ${coach['name']}",
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),

              // Toilets Section
              _buildSectionTable("Toilets", coach['toilets']),

              // Doorways Section
              _buildSectionTable("Doorways", coach['doorways']),

              // Vestibules Section
              _buildSectionTable("Vestibules", coach['vestibules']),

              pw.SizedBox(height: 12),
              pw.Divider(),
            ]
          ],
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildSectionTable(String title, Map<String, dynamic> data) {
    if (data == null || data.isEmpty) return pw.Container();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 6),
        pw.Text(title,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.Table.fromTextArray(
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          headers: ['Parameter', 'Score', 'Remarks'],
          data: data.entries.map((e) {
            final score = e.value['score'] ?? '';
            final remark = e.value['remarks'] ?? '';
            return [e.key, '$score / 10', remark];
          }).toList(),
        ),
      ],
    );
  }
}
