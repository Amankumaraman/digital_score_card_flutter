import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReportStorageService {
  static const _key = 'local_reports';

  static Future<void> saveReport(Map<String, dynamic> report) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];
    existing.add(jsonEncode(report));
    await prefs.setStringList(_key, existing);
  }

  static Future<List<Map<String, dynamic>>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> filterReports({
    String? station,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final reports = await loadReports();
    return reports.where((r) {
      final matchStation = station == null ||
          (r['stationName'] as String).toLowerCase().contains(station.toLowerCase());
      final date = DateTime.tryParse(r['inspectionDate'] ?? '');
      final matchDate = date != null &&
          (fromDate == null || date.isAfter(fromDate.subtract(Duration(days: 1)))) &&
          (toDate == null || date.isBefore(toDate.add(Duration(days: 1))));
      return matchStation && matchDate;
    }).toList();
  }
}