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
  int batsmanRuns;

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
    this.batsmanRuns = 0,
  });
}
