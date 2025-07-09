class AreaScore {
  int score;
  String remark;

  AreaScore({this.score = 0, this.remark = ''});

  Map<String, dynamic> toJson() => {
    'score': score,
    'remark': remark,
  };
}

class CoachScore {
  Map<String, AreaScore> toilets = {
    'T1': AreaScore(),
    'T2': AreaScore(),
    'T3': AreaScore(),
    'T4': AreaScore(),
  };
  Map<String, AreaScore> doors = {
    'D1': AreaScore(),
    'D2': AreaScore(),
  };
  Map<String, AreaScore> vestibules = {
    'B1': AreaScore(),
    'B2': AreaScore(),
  };

  Map<String, dynamic> toJson() => {
    'toilets': toilets.map((k, v) => MapEntry(k, v.toJson())),
    'doors': doors.map((k, v) => MapEntry(k, v.toJson())),
    'vestibules': vestibules.map((k, v) => MapEntry(k, v.toJson())),
  };
}