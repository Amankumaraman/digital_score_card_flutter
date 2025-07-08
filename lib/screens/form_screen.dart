import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/score_provider.dart';
import 'review_screen.dart';

class FormScreen extends StatefulWidget {
  final String stationName;
  final String inspectionDate;

  const FormScreen({
    required this.stationName,
    required this.inspectionDate,
  });

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final List<String> coachList = ['A1', 'A2', 'B1'];
  final List<String> sections = ['toilets', 'doorways', 'vestibules'];
  final List<String> params = ['Cleanliness', 'Condition', 'Smell'];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ScoreProvider>(context, listen: false);
    provider.initialize(widget.stationName, widget.inspectionDate, coachList);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScoreProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Score Coaches')),
      body: ListView.builder(
        itemCount: coachList.length,
        itemBuilder: (_, i) {
          final coach = coachList[i];
          return Card(
            margin: EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coach $coach', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  for (final section in sections)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        Text(section.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        for (final param in params)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(param)),
                                  SizedBox(
                                    width: 80,
                                    child: TextFormField(
                                      decoration: InputDecoration(hintText: '0-10'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) => provider.updateScore(coach, section, param, int.tryParse(val) ?? 0),
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                decoration: InputDecoration(hintText: 'Remarks (optional)'),
                                onChanged: (val) => provider.updateRemarks(coach, section, param, val),
                              ),
                              SizedBox(height: 10),
                            ],
                          )
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.reviews),
        label: Text('Review'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewScreen()));
        },
      ),
    );
  }
}
