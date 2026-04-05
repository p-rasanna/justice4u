const fs = require('fs');
const path = require('path');

const baseDir = 'c:/xampp/htdocs/J4U/J4U';
const ignoreDirs = ['node_modules', 'build', 'dist', '.git', '_archive'];
const extensions = ['.java', '.jsp', '.html', '.css', '.js', '.sql'];

function readFile(fullPath) {
    const buffer = fs.readFileSync(fullPath);
    if (buffer.length >= 2 && buffer[0] === 0xFF && buffer[1] === 0xFE) return buffer.toString('utf16le');
    if (buffer.indexOf(0x00) !== -1) return buffer.toString('utf16le');
    return buffer.toString('utf8');
}

let htmlContent = `<html xmlns:w="urn:schemas-microsoft-com:office:word"><head><meta charset="utf-8">
<style>
  body { font-family: 'Courier New', Courier, monospace; font-size: 9pt; }
  h2 { font-family: Arial, sans-serif; font-size: 13pt; color: #0B192C; background-color: #eef2f7; padding: 6px 10px; margin-top: 24px; border-left: 4px solid #D4AF37; }
  pre { margin: 4px 0 12px 0; white-space: pre-wrap; word-wrap: break-word; line-height: 1.4; }
  hr { border: none; border-top: 1px solid #ccc; margin: 16px 0; }
</style></head><body>
<h1 style="font-family:Arial;color:#0B192C;">Justice4U &mdash; Complete Source Code</h1><hr/>
`;

function walkDir(dir) {
    if (ignoreDirs.includes(path.basename(dir))) return;
    try {
        const files = fs.readdirSync(dir);
        for (const file of files) {
            const fullPath = path.join(dir, file);
            let isDir = false;
            try { isDir = fs.statSync(fullPath).isDirectory(); } catch(e) {}
            if (isDir) {
                walkDir(fullPath);
            } else {
                const ext = path.extname(file);
                if (extensions.includes(ext)) {
                    try {
                        let content = readFile(fullPath).replace(/\x00/g, '');

                        // For SQL: strip INSERT INTO lines to avoid massive dummy data
                        if (ext === '.sql') {
                            content = content.split('\n')
                                .filter(l => !l.trim().toUpperCase().startsWith('INSERT INTO'))
                                .join('\n')
                                .replace(/\n{3,}/g, '\n\n');
                        }

                        const escaped = content
                            .replace(/&/g, '&amp;')
                            .replace(/</g, '&lt;')
                            .replace(/>/g, '&gt;');

                        const relPath = fullPath.replace(baseDir.replace(/\//g,'\\'), '').replace(/\\/g, '/');
                        htmlContent += `<h2>${relPath}</h2>\n<pre>${escaped}</pre>\n`;
                    } catch(e) {}
                }
            }
        }
    } catch(e){}
}

walkDir(baseDir);
htmlContent += `</body></html>`;

fs.writeFileSync('c:/xampp/htdocs/J4U/Justice4U_CodeBase_v3.doc', htmlContent, 'utf8');
console.log('Done! Saved as Justice4U_CodeBase_v3.doc');
