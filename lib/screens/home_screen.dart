// 📁 lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'form_screen.dart';
import 'report_list_screen.dart'; // <-- Import the report screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _stationName = '';
  DateTime? _selectedDate;

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Score Card')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                'https://upload.wikimedia.org/wikipedia/hi/7/7b/Indian_Railways_logo.png',
                height: 80,
                errorBuilder: (_, __, ___) => Icon(Icons.train, size: 80),
              ),
              SizedBox(height: 20),
              Text('Start Inspection',
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Station Name'),
                      validator: (v) =>
                      v!.isEmpty ? 'Enter station name' : null,
                      onSaved: (v) => _stationName = v!,
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text(_selectedDate == null
                          ? 'Select Inspection Date'
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                      trailing: Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.arrow_forward),
                      label: Text('Start Scoring'),
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            _selectedDate != null) {
                          _formKey.currentState!.save();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormScreen(
                                stationName: _stationName,
                                inspectionDate: DateFormat('yyyy-MM-dd')
                                    .format(_selectedDate!),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20),

                    // 🔍 View Past Reports Button
                    ElevatedButton.icon(
                      icon: Icon(Icons.folder_open),
                      label: Text('View Past Reports'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ReportListScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
