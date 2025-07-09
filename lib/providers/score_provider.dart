import 'package:flutter/foundation.dart';

class ScoreProvider extends ChangeNotifier {
  late String stationName;
  late String inspectionDate;
  List<String> coachList = [];

  Map<String, Map<String, Map<String, dynamic>>> scores = {};

  void initialize(String station, String date, List<String> coaches) {
    stationName = station;
    inspectionDate = date;
    coachList = coaches;

    for (var coach in coaches) {
      scores[coach] = {
        'toilets': {},
        'doorways': {},
        'vestibules': {},
      };
    }
    notifyListeners();
  }

  void updateScore(String coach, String section, String param, int value) {
    scores[coach]?[section]?[param] ??= {};
    scores[coach]![section]![param] = {
      'score': value,
      'remarks': scores[coach]![section]![param]?['remarks']
    };
    notifyListeners();
  }

  void updateRemarks(String coach, String section, String param, String value) {
    scores[coach]?[section]?[param] ??= {};
    scores[coach]![section]![param] = {
      'score': scores[coach]![section]![param]?['score'] ?? 0,
      'remarks': value
    };
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'stationName': stationName,
      'inspectionDate': inspectionDate,
      'coaches': coachList.map((coach) {
        return {
          'name': coach,
          'toilets': scores[coach]!['toilets'],
          'doorways': scores[coach]!['doorways'],
          'vestibules': scores[coach]!['vestibules'],
        };
      }).toList()
    };
  }
}