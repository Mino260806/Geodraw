class SegmentNameMatcher {
  static final RegExp segmentRe = RegExp(r"(\w\W*)(\w\W*)");

  final String name;

  SegmentNameMatcher(this.name);

  SegmentName? match() {
    Match? match = segmentRe.firstMatch(name);
    if (match == null) return null;
    String? dot1 = match.group(1);
    String? dot2 = match.group(2);
    if (dot1 == null || dot2 == null || dot1 == dot2) return null;
    return SegmentName(dot1, dot2);
  }
}

class SegmentName {
  final String dot1;
  final String dot2;

  SegmentName(this.dot1, this.dot2);
}