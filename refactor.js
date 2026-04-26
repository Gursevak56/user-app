const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

walkDir('lib/view', function(filePath) {
  if (filePath.endsWith('.dart')) {
    let content = fs.readFileSync(filePath, 'utf8');
    let modified = false;

    // 1. Scaffold
    let scaffoldRegex = /Scaffold\(/g;
    if (scaffoldRegex.test(content) && !content.includes('extendBody: true')) {
      content = content.replace(/Scaffold\(/g, 'Scaffold(\n      extendBody: true,\n      extendBodyBehindAppBar: true,\n      resizeToAvoidBottomInset: true,');
      modified = true;
    }

    // 2. SafeArea
    let safeAreaRegex = /SafeArea\(\s*child:/g;
    if (safeAreaRegex.test(content)) {
      content = content.replace(safeAreaRegex, 'SafeArea(\n      top: false,\n      bottom: true,\n      child:');
      modified = true;
    }

    // 3. Padding
    let paddingRegex16 = /EdgeInsets\.all\(\s*16\.?0?\s*\)/g;
    if (paddingRegex16.test(content)) {
      content = content.replace(paddingRegex16, 'EdgeInsets.symmetric(horizontal: 16)');
      modified = true;
    }
    let paddingRegex20 = /EdgeInsets\.all\(\s*20\.?0?\s*\)/g;
    if (paddingRegex20.test(content)) {
      content = content.replace(paddingRegex20, 'EdgeInsets.symmetric(horizontal: 20)');
      modified = true;
    }

    if (modified) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log('Updated: ' + filePath);
    }
  }
});
