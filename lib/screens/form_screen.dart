import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/score_provider.dart';
import 'review_screen.dart';
import '../theme/app_theme.dart';

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

  Widget _buildScoreInput(String coach, String section, String param) {
    final provider = Provider.of<ScoreProvider>(context);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(param, style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextFormField(
            decoration: InputDecoration(
              hintText: '0-10',
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (val) => provider.updateScore(
                coach, section, param, int.tryParse(val) ?? 0),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String coach, String section) {
    final provider = Provider.of<ScoreProvider>(context, listen: false);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.toUpperCase(),
              style: AppTheme.sectionHeaderStyle,
            ),
            SizedBox(height: 8),
            ...params.map((param) => Column(
              children: [
                _buildScoreInput(coach, section, param),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Remarks (optional)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 1,
                  onChanged: (val) => provider.updateRemarks(
                      coach, section, param, val),
                ),
                SizedBox(height: 12),
              ],
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Coaches'),
        actions: [
          IconButton(
            icon: Icon(Icons.reviews),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ReviewScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: coachList.length,
          itemBuilder: (_, i) {
            final coach = coachList[i];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.train, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text('Coach $coach',
                            style: AppTheme.cardTitleStyle),
                      ],
                    ),
                    SizedBox(height: 12),
                    ...sections.map((section) =>
                        _buildSectionCard(coach, section)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}