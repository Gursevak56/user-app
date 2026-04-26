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
    // We are looking for something like:
    // = [
    //   {
    //     "name"
    // or
    // = [
    //   {
    //     'title'
    let regex = /=\s*\[\s*\{\s*["']/g;
    if (regex.test(content)) {
      console.log('Found static data pattern in: ' + filePath);
    }
  }
});
