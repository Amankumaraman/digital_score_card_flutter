import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../services/report_storage_service.dart';
import '../services/pdf_generator.dart';
import '../theme/app_theme.dart';

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
      appBar: AppBar(title: Text('Inspection Reports')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Filter by station',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        _stationFilter = val;
                        _loadReports();
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(context, true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'From Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _fromDate == null
                                    ? 'Select Date'
                                    : DateFormat('yyyy-MM-dd').format(_fromDate!),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(context, false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'To Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _toDate == null
                                    ? 'Select Date'
                                    : DateFormat('yyyy-MM-dd').format(_toDate!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text('Export Filtered Reports'),
                        onPressed: _filteredReports.isEmpty ? null : _exportFilteredAsPdf,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredReports.isEmpty
                ? Center(
              child: Text('No reports found',
                  style: TextStyle(fontSize: 16)),
            )
                : ListView.builder(
              itemCount: _filteredReports.length,
              itemBuilder: (_, i) {
                final report = _filteredReports[i];
                return Card(
                  margin: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.article,
                        color: Colors.indigo),
                    title: Text(report['stationName'] ?? 'No Station',
                        style: TextStyle(
                            fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        'Date: ${report['inspectionDate']}'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Add functionality to view report details
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}