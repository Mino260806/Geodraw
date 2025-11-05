class TriangleNameMatcher {
  static final RegExp triangleRe = RegExp(r"(\w\W*)(\w\W*)(\w\W*)");

  final String name;

  TriangleNameMatcher(this.name);

  TriangleName? match() {
    Match? match = triangleRe.firstMatch(name);
    if (match == null) return null;
    String? dot1 = match.group(1);
    String? dot2 = match.group(2);
    String? dot3 = match.group(3);
    if (dot1 == null || dot2 == null || dot3 == null) return null;
    return TriangleName(dot1, dot2, dot3);
  }
}

class TriangleName {
  final String dot1;
  final String dot2;
  final String dot3;

  TriangleName(this.dot1, this.dot2, this.dot3);
}