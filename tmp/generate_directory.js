const fs = require('fs');
const path = require('path');

const baseDir = 'c:/xampp/htdocs/J4U/J4U';
const ignoreDirs = ['node_modules', '.git', 'build', 'dist', '_archive', '.nb-gradle'];

let treeLines = [];
let totalFiles = 0;
let totalDirs = 0;

function walkDir(dir, prefix, relPath) {
    let entries;
    try { entries = fs.readdirSync(dir); } catch(e) { return; }

    // Sort: directories first, then files, both alphabetically
    const dirs = entries.filter(e => {
        try { return fs.statSync(path.join(dir, e)).isDirectory() && !ignoreDirs.includes(e); } catch(e) { return false; }
    }).sort();
    const files = entries.filter(e => {
        try { return fs.statSync(path.join(dir, e)).isFile(); } catch(e) { return false; }
    }).sort();

    const all = [...dirs, ...files];

    all.forEach((entry, idx) => {
        const fullPath = path.join(dir, entry);
        const isLast = idx === all.length - 1;
        const connector = isLast ? '└── ' : '├── ';
        const childPrefix = isLast ? '    ' : '│   ';

        let isDir = false;
        try { isDir = fs.statSync(fullPath).isDirectory(); } catch(e) {}

        if (isDir) {
            if (ignoreDirs.includes(entry)) return;
            totalDirs++;
            treeLines.push(prefix + connector + '📁 ' + entry + '/');
            walkDir(fullPath, prefix + childPrefix, relPath + '/' + entry);
        } else {
            totalFiles++;
            // Get size
            let size = '';
            try {
                const bytes = fs.statSync(fullPath).size;
                if (bytes < 1024) size = bytes + ' B';
                else if (bytes < 1024*1024) size = (bytes/1024).toFixed(1) + ' KB';
                else size = (bytes/(1024*1024)).toFixed(1) + ' MB';
            } catch(e) {}
            const ext = path.extname(entry).toLowerCase();
            let icon = '📄';
            if (['.java'].includes(ext)) icon = '☕';
            else if (['.jsp', '.html'].includes(ext)) icon = '🌐';
            else if (['.css'].includes(ext)) icon = '🎨';
            else if (['.js'].includes(ext)) icon = '⚡';
            else if (['.sql'].includes(ext)) icon = '🗄️';
            else if (['.xml'].includes(ext)) icon = '⚙️';
            else if (['.png','.jpg','.gif','.ico'].includes(ext)) icon = '🖼️';
            treeLines.push(prefix + connector + icon + ' ' + entry + '  <span class="sz">[' + size + ']</span>');
        }
    });
}

// Walk and build tree
walkDir(baseDir, '', '');

const treeHtml = treeLines.join('\n');

const html = `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Justice4U - Project File Directory</title>
<style>
  body { font-family: Arial, sans-serif; font-size: 11pt; margin: 40px; }
  h1 { font-size: 20pt; color: #0B192C; text-align: center; border-bottom: 3px double #D4AF37; padding-bottom: 10px; margin-bottom: 6px; }
  .subtitle { text-align: center; color: #555; font-size: 10pt; margin-bottom: 30px; }
  .stats { background: #f0f4f8; border-left: 4px solid #D4AF37; padding: 10px 16px; margin-bottom: 20px; font-size: 10pt; }
  pre {
    font-family: 'Courier New', monospace;
    font-size: 9pt;
    line-height: 1.7;
    background: #fafafa;
    border: 1px solid #e0e0e0;
    padding: 20px;
    white-space: pre-wrap;
    word-wrap: break-word;
  }
  .sz { color: #888; font-size: 8pt; }
</style>
</head>
<body>
<h1>Justice4U &mdash; Complete Project File Directory</h1>
<p class="subtitle">Full Project Structure &bull; JSP / Servlet / MySQL Platform</p>

<div class="stats">
  <strong>📁 Total Directories:</strong> ${totalDirs} &nbsp;&nbsp;
  <strong>📄 Total Files:</strong> ${totalFiles} &nbsp;&nbsp;
  <strong>📂 Root:</strong> J4U/J4U/
</div>

<pre>📁 J4U/ (Project Root)
${treeHtml}
</pre>

</body>
</html>`;

fs.writeFileSync('c:/xampp/htdocs/J4U/Justice4U_FileDirectory.doc', html, 'utf8');
console.log(`Done! Total dirs: ${totalDirs}, Total files: ${totalFiles}`);
console.log('Saved as Justice4U_FileDirectory.doc');
