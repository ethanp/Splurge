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

  bool get doneReading => cursorPosition >= rawRow.length;

  String get curChar => rawRow[cursorPosition];

  @override
  bool moveNext() {
    if (doneReading) return false;
    final startsWithQuote = curChar == '"';
    current = startsWithQuote ? _extractFromQuotes() : _extractNoQuotes();
    return !doneReading;
  }

  @override
  String current = '';

  String _extractFromQuotes() {
    // Skip open-quote.
    cursorPosition++;

    final int contentStartIdx = cursorPosition;

    // Find length of quote contents.
    while (curChar != '"' && !doneReading) cursorPosition++;

    // Skip close-quote.
    cursorPosition++;

    // Weird bug in the raw csv where there can be an extra pair of quotes!
    var offset = 0;
    if (!doneReading && curChar == '"') {
      // Skip occasional extraneous quotes.
      cursorPosition += 2;
      offset = 2;
    }

    // Skip comma.
    cursorPosition++;

    // Extract quote contents from whole row string.
    return rawRow.substring(contentStartIdx, cursorPosition - 2 - offset);
  }

  String _extractNoQuotes() {
    final int start = cursorPosition;

    // Find length of contents.
    while (curChar != ',' && !doneReading) cursorPosition++;

    // Skip past the comma.
    cursorPosition++;

    // Extract contents (minus comma).
    return rawRow.substring(start, cursorPosition - 1);
  }
}
