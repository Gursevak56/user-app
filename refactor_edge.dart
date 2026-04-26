import 'dart:io';

void main() {
  final dir = Directory('lib/view');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // 1. Add extendBody, extendBodyBehindAppBar, resizeToAvoidBottomInset to Scaffold
    final scaffoldRegex = RegExp(r'Scaffold\(');
    if (scaffoldRegex.hasMatch(content)) {
      if (!content.contains('extendBody: true')) {
        content = content.replaceAll(scaffoldRegex, 'Scaffold(\n      extendBody: true,\n      extendBodyBehindAppBar: true,\n      resizeToAvoidBottomInset: true,');
        modified = true;
      }
    }

    // 2. Change SafeArea() to SafeArea(top: false, bottom: true)
    final safeAreaRegex1 = RegExp(r'SafeArea\(\s*child:');
    if (safeAreaRegex1.hasMatch(content)) {
      content = content.replaceAll(safeAreaRegex1, 'SafeArea(\n      top: false,\n      bottom: true,\n      child:');
      modified = true;
    }
    
    final safeAreaRegex2 = RegExp(r'SafeArea\(\s*\n?\s*child:');
    if (safeAreaRegex2.hasMatch(content)) {
       // just in case
    }

    // 3. Change EdgeInsets.all(16) to EdgeInsets.symmetric(horizontal: 16) where appropriate. Let's do it carefully.
    // Wait, let's only target padding that looks like it's a root padding.
    // Or just all EdgeInsets.all(16) to EdgeInsets.symmetric(horizontal: 16) as requested.
    // "Modern apps avoid vertical padding near screen edges."
    // Let's replace EdgeInsets.all(16) -> EdgeInsets.symmetric(horizontal: 16)
    // EdgeInsets.all(20) -> EdgeInsets.symmetric(horizontal: 20)
    
    final paddingRegex16 = RegExp(r'EdgeInsets\.all\(\s*16\.?0?\s*\)');
    if (paddingRegex16.hasMatch(content)) {
      content = content.replaceAll(paddingRegex16, 'EdgeInsets.symmetric(horizontal: 16)');
      modified = true;
    }
    
    final paddingRegex20 = RegExp(r'EdgeInsets\.all\(\s*20\.?0?\s*\)');
    if (paddingRegex20.hasMatch(content)) {
      content = content.replaceAll(paddingRegex20, 'EdgeInsets.symmetric(horizontal: 20)');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Updated: ${file.path}');
    }
  }
}
