import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print("Usage: dart fix_textbutton.dart <file_path>");
    exit(1);
  }

  final file = File(args[0]);
  if (!file.existsSync()) {
    print("File not found: ${args[0]}");
    exit(1);
  }

  String content = file.readAsStringSync();

  // Regex to capture TextButton with multiple style: lines
  final regex = RegExp(
      r'style:\s*TextButton\.styleFrom\(([^)]*)\)',
      multiLine: true);

  final matches = regex.allMatches(content).toList();

  if (matches.length > 1) {
    print("Found ${matches.length} style: occurrences in ${file.path}");

    // Collect all properties from styleFrom calls
    final Map<String, String> props = {};
    for (final m in matches) {
      final body = m.group(1) ?? '';
      final parts = body.split(',');
      for (var p in parts) {
        p = p.trim();
        if (p.isEmpty) continue;

        // Fix malformed patterns
        p = p.replaceAll('backgroundColor: color:', 'backgroundColor:');
        p = p.replaceAll('shape: shape:', 'shape:');

        final kv = p.split(':');
        if (kv.length >= 2) {
          final key = kv[0].trim();
          final val = kv.sublist(1).join(':').trim();
          // overwrite → last one wins
          props[key] = val;
        }
      }
    }

    // Build merged styleFrom
    final merged = props.entries.map((e) => '    ${e.key}: ${e.value},').join('\n');

    final replacement = 'style: TextButton.styleFrom(\n$merged\n  )';

    // Replace all style: occurrences with one merged block
    content = content.replaceAll(regex, '');
    // Insert one clean merged style block after "TextButton("
    content = content.replaceFirst(
        RegExp(r'TextButton\('), 'TextButton(\n  $replacement,');

    file.writeAsStringSync(content);
    print("✅ Fixed TextButton styles in ${file.path}");
  } else {
    print("No duplicate style: found in ${file.path}");
  }
}
