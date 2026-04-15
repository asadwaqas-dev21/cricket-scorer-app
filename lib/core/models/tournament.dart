class Tournament {
  String id;
  String name;
  List<String> teamIds;
  List<String> matchIds;
  String startDate;
  bool isCompleted;

  Tournament({
    required this.id,
    required this.name,
    required this.teamIds,
    this.matchIds = const [],
    required this.startDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'teamIds': teamIds,
    'matchIds': matchIds,
    'startDate': startDate,
    'isCompleted': isCompleted,
  };

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
    id: json['id'],
    name: json['name'],
    teamIds: List<String>.from(json['teamIds'] ?? []),
    matchIds: List<String>.from(json['matchIds'] ?? []),
    startDate: json['startDate'],
    isCompleted: json['isCompleted'] ?? false,
  );
}
