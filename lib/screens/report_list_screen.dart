// 📁 lib/screens/report_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../services/report_storage_service.dart';
import '../services/pdf_generator.dart';

class ReportListScreen extends StatefulWidget {
  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  String _stationFilter = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Map<String, dynamic>> _filteredReports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await ReportStorageService.filterReports(
      station: _stationFilter.isEmpty ? null : _stationFilter,
      fromDate: _fromDate,
      toDate: _toDate,
    );
    setState(() {
      _filteredReports = reports;
    });
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
        _loadReports();
      });
    }
  }

  void _exportFilteredAsPdf() async {
    final pdf = await PdfGenerator.generateFromJson(_filteredReports);
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Filter by station'),
              onChanged: (val) {
                _stationFilter = val;
                _loadReports();
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(_fromDate == null
                        ? 'From Date'
                        : DateFormat('yyyy-MM-dd').format(_fromDate!)),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _pickDate(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(_toDate == null
                        ? 'To Date'
                        : DateFormat('yyyy-MM-dd').format(_toDate!)),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _pickDate(context, false),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Export Filtered Reports'),
              onPressed: _filteredReports.isEmpty ? null : _exportFilteredAsPdf,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredReports.length,
                itemBuilder: (_, i) {
                  final report = _filteredReports[i];
                  return Card(
                    child: ListTile(
                      title: Text(report['stationName'] ?? 'No Station'),
                      subtitle: Text('Date: ${report['inspectionDate']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
