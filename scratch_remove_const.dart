import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print('lib directory not found');
    return;
  }

  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // We want to remove `const ` in front of BoxDecoration, TextStyle, LinearGradient, Container, Text, Icon, Padding, Row, Column, Center, SizedBox.
    // We should be careful to only remove the word `const ` when it precedes these, or we can just remove `const BoxDecoration` -> `BoxDecoration`.
    
    final replacements = [
      'const BoxDecoration',
      'const TextStyle',
      'const LinearGradient',
      'const Text',
      'const Icon',
      'const Padding',
      'const Center',
      'const Column',
      'const Row',
      'const Container',
      'const SizedBox',
      'const Scaffold',
      'const AppBar',
      'const EdgeInsets',
      'const Border',
      'const BorderRadius',
      'const Divider',
      'const CircleAvatar',
      'const Color', // wait, const Color(0xFF...) is fine! But let's be careful. AppTheme.textPrimary is NOT const Color(...) it's just AppTheme.textPrimary.
    ];

    bool changed = false;
    for (final repl in replacements) {
      if (repl == 'const Color') continue; // Skip this, it's safe.
      if (content.contains(repl)) {
        content = content.replaceAll(repl, repl.replaceFirst('const ', ''));
        changed = true;
      }
    }
    
    // Also catch `const [Color(0xFF...` inside gradients if we remove const from LinearGradient.
    if (content.contains('const [')) {
       // Only if it's related to gradients or something. Actually just let `const [` remain if possible. 
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated \${file.path}');
    }
  }
}
