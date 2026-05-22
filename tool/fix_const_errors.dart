import 'dart:io';

void main() {
  final logFile = File(r'C:\Users\Mrezz\.gemini\antigravity-ide\brain\b80cdbb9-e259-429c-b18c-b59d79a8324c\.system_generated\tasks\task-264.log');
  if (!logFile.existsSync()) {
    print('Log file not found!');
    return;
  }

  final projectRoot = r'd:\Rezza\Self Project\corebussiness';
  final lines = logFile.readAsLinesSync();
  final errorPattern = RegExp(r'error - Methods can.* - (lib\\.*\.dart):(\d+):\d+ - const_eval_method_invocation');

  final Map<String, Set<int>> fileErrors = {};

  for (final line in lines) {
    final match = errorPattern.firstMatch(line);
    if (match != null) {
      final relativePath = match.group(1)!;
      final lineNum = int.parse(match.group(2)!);
      final absolutePath = '$projectRoot\\$relativePath';

      fileErrors.putIfAbsent(absolutePath, () => {}).add(lineNum);
    }
  }

  print('Found errors in ${fileErrors.length} files.');

  int totalFixed = 0;

  for (final entry in fileErrors.entries) {
    final filePath = entry.key;
    final errorLines = entry.value.toList()..sort((a, b) => b.compareTo(a)); // sort descending to not mess up indices if we add/remove chars, though we just modify in-place.
    
    final file = File(filePath);
    if (!file.existsSync()) {
      print('File not found: $filePath');
      continue;
    }

    var fileContentLines = file.readAsLinesSync();
    bool fileModified = false;

    for (final lineNum in errorLines) {
      // lineNum is 1-indexed, so index is lineNum - 1
      final targetIndex = lineNum - 1;
      if (targetIndex >= fileContentLines.length) continue;

      // Look at the line and preceding lines
      int foundIndex = -1;
      for (int i = 0; i < 20; i++) {
        final checkIndex = targetIndex - i;
        if (checkIndex < 0) break;

        final lineText = fileContentLines[checkIndex];
        if (lineText.contains('const ')) {
          foundIndex = checkIndex;
          break;
        }
      }

      if (foundIndex != -1) {
        final lineText = fileContentLines[foundIndex];
        // Replace 'const ' with '' only where it makes sense (e.g. matching word bounds or specific keywords)
        // Let's do a simple replace of the first occurrence of 'const ' on that line
        final newLineText = lineText.replaceFirst('const ', '');
        if (newLineText != lineText) {
          fileContentLines[foundIndex] = newLineText;
          fileModified = true;
          totalFixed++;
          print('Fixed const in $filePath at line ${foundIndex + 1}: "${lineText.trim()}" -> "${newLineText.trim()}"');
        }
      } else {
        print('Could not find const for error at line $lineNum in $filePath');
      }
    }

    if (fileModified) {
      file.writeAsStringSync(fileContentLines.join('\n'));
    }
  }

  print('\n══════════════════════════════════════════');
  print('Fixed $totalFixed invalid const instances!');
  print('══════════════════════════════════════════');
}
