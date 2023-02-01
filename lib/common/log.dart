part of './index.dart';


final logger = VisualLogger(
  filter: ProductionFilter(),
  output: VisualOutput(),
  printer: VisualPrinter(
    realPrinter: VisualPrefixPrinter(
      methodCount: 1,
      lineLength: () {
        int lineLength;
        try {
          lineLength = stdout.terminalColumns;
        } catch (e) {
          lineLength = 80;
        }
        return lineLength;
      }(),
      colors: stdout.supportsAnsiEscapes, // Colorful log messages
      printEmojis: false,
      printTime: true,
    ),
  ),
);