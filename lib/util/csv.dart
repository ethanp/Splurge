class ValueGeneratorCommaSeparated extends Iterable<String> {
  ValueGeneratorCommaSeparated(this.rawRow);

  final String rawRow;

  @override
  Iterator<String> get iterator => _CommaSeparatedValueSplitter(rawRow);
}

class _CommaSeparatedValueSplitter extends Iterator<String> {
  _CommaSeparatedValueSplitter(this.rawRow);

  final String rawRow;

  int cursorPosition = 0;

  bool get done => cursorPosition >= rawRow.length;

  String get curChar => rawRow[cursorPosition];

  @override
  bool moveNext() {
    if (done) return false;
    current = curChar == '"' ? _extractFromQuotes() : _extractNoQuotes();
    return !done;
  }

  @override
  String current = '';

  String _extractFromQuotes() {
    int openQuoteLoc = cursorPosition;
    cursorPosition++;
    while (curChar != '"' && !done) {
      cursorPosition++;
    }
    cursorPosition++; // Close quote

    // Weird bug in the raw csv where there can be an extra pair of quotes!
    var offset = 0;
    if (!done && curChar == '"') {
      cursorPosition += 2; // skip the quotes
      offset = 2;
    }

    cursorPosition++; // Comma
    return rawRow.substring(openQuoteLoc + 1, cursorPosition - 2 - offset);
  }

  String _extractNoQuotes() {
    int start = cursorPosition;
    while (curChar != ',' && !done) {
      cursorPosition++;
    }
    cursorPosition++;
    return rawRow.substring(start, cursorPosition - 1);
  }
}
