import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'form_screen.dart';
import 'report_list_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _stationName;
  DateTime? _selectedDate;

  final List<String> stationNames = ['Delhi', 'Mumbai', 'Chennai', 'Kolkata'];

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Score Card')),
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/railway_logo.png',
                            height: 100,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.train,
                              size: 80,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Train Cleanliness Inspection',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Station Name',
                                    prefixIcon: Icon(Icons.location_on),
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _stationName,
                                  hint: Text('Select station'),
                                  items: stationNames.map((station) {
                                    return DropdownMenuItem<String>(
                                      value: station,
                                      child: Text(station),
                                    );
                                  }).toList(),
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Select station name'
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      _stationName = value;
                                    });
                                  },
                                  onSaved: (value) {
                                    _stationName = value;
                                  },
                                ),
                                SizedBox(height: 16),
                                InkWell(
                                  onTap: _pickDate,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Inspection Date',
                                      prefixIcon: Icon(Icons.calendar_today),
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      _selectedDate == null
                                          ? 'Select Date'
                                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.arrow_forward),
                                    label: Text('Start Scoring',
                                        style: TextStyle(fontSize: 16)),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate() &&
                                          _selectedDate != null) {
                                        _formKey.currentState!.save();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FormScreen(
                                              stationName: _stationName!,
                                              inspectionDate: DateFormat('yyyy-MM-dd')
                                                  .format(_selectedDate!),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    icon: Icon(Icons.history),
                                    label: Text('View Past Reports',
                                        style: TextStyle(fontSize: 16)),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReportListScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
