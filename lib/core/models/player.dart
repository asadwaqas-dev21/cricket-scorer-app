class Player {
  String id;
  String name;
  int runsScored;
  int ballsFaced;
  int wicketsTaken;
  int oversBowled;
  int runsConceded;
  int catches;
  int mvpPoints;
  int fours;
  int sixes;

  Player({
    required this.id,
    required this.name,
    this.runsScored = 0,
    this.ballsFaced = 0,
    this.wicketsTaken = 0,
    this.oversBowled = 0,
    this.runsConceded = 0,
    this.catches = 0,
    this.mvpPoints = 0,
    this.fours = 0,
    this.sixes = 0,
  });

  double get strikeRate =>
      runsScored > 0 && ballsFaced > 0 ? (runsScored / ballsFaced) * 100 : 0.0;
  double get economy => oversBowled > 0 ? runsConceded / oversBowled : 0.0;

  void updateMVPPoints() {
    mvpPoints = runsScored + (wicketsTaken * 20) + (catches * 10);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'runsScored': runsScored,
    'ballsFaced': ballsFaced,
    'wicketsTaken': wicketsTaken,
    'oversBowled': oversBowled,
    'runsConceded': runsConceded,
    'catches': catches,
    'mvpPoints': mvpPoints,
    'fours': fours,
    'sixes': sixes,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    runsScored: json['runsScored'] ?? 0,
    ballsFaced: json['ballsFaced'] ?? 0,
    wicketsTaken: json['wicketsTaken'] ?? 0,
    oversBowled: json['oversBowled'] ?? 0,
    runsConceded: json['runsConceded'] ?? 0,
    catches: json['catches'] ?? 0,
    mvpPoints: json['mvpPoints'] ?? 0,
    fours: json['fours'] ?? 0,
    sixes: json['sixes'] ?? 0,
  );
}
