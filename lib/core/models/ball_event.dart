class BallEvent {
  int runs;
  bool isWicket;
  String extraType;
  String strikerId;
  String bowlerId;
  String wagonDirection;
  String pitchZone;
  String wicketType;
  String? catcherId;
  String? outPlayerId;
  int batsmanRuns;
  int innings;

  BallEvent({
    required this.runs,
    this.isWicket = false,
    this.extraType = "",
    required this.strikerId,
    required this.bowlerId,
    this.wagonDirection = "",
    this.pitchZone = "",
    this.wicketType = "",
    this.catcherId,
    this.outPlayerId,
    this.batsmanRuns = 0,
    this.innings = 1,
  });

  Map<String, dynamic> toJson() => {
        'runs': runs,
        'isWicket': isWicket,
        'extraType': extraType,
        'strikerId': strikerId,
        'bowlerId': bowlerId,
        'wagonDirection': wagonDirection,
        'pitchZone': pitchZone,
        'wicketType': wicketType,
        'catcherId': catcherId,
        'outPlayerId': outPlayerId,
        'batsmanRuns': batsmanRuns,
        'innings': innings,
      };

  factory BallEvent.fromJson(Map<String, dynamic> json) => BallEvent(
        runs: json['runs'],
        isWicket: json['isWicket'] ?? false,
        extraType: json['extraType'] ?? "",
        strikerId: json['strikerId'],
        bowlerId: json['bowlerId'],
        wagonDirection: json['wagonDirection'] ?? "",
        pitchZone: json['pitchZone'] ?? "",
        wicketType: json['wicketType'] ?? "",
        catcherId: json['catcherId'],
        outPlayerId: json['outPlayerId'],
        batsmanRuns: json['batsmanRuns'] ?? 0,
        innings: json['innings'] ?? 1,
      );
}
