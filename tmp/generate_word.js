const fs = require('fs');
const path = require('path');

const baseDir = 'c:/xampp/htdocs/J4U/J4U';
const ignoreDirs = ['node_modules', 'build', 'dist', '.git', '_archive'];
const extensions = ['.java', '.jsp', '.html', '.css', '.js', '.sql'];

let htmlContent = `
<html xmlns:w="urn:schemas-microsoft-com:office:word">
<head>
<meta charset="utf-8">
<style>
    body { font-family: 'Courier New', Courier, monospace; font-size: 9pt; }
    h2 { font-family: Arial, sans-serif; font-size: 14pt; color: #0B192C; background-color: #f1f1f1; padding: 5px; margin-top: 20px;}
    pre { margin: 0; white-space: pre-wrap; word-wrap: break-word; }
</style>
</head>
<body>
<h1>Justice4U Codebase Documentation</h1>
<hr/>
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
                if (extensions.some(ext => fullPath.endsWith(ext))) {
                    try {
                        const buffer = fs.readFileSync(fullPath);
                        let content = '';
                        
                        // Detect UTF-16LE BOM
                        if (buffer.length >= 2 && buffer[0] === 0xFF && buffer[1] === 0xFE) {
                            content = buffer.toString('utf16le');
                        } else if (buffer.indexOf(0x00) !== -1) {
                            // If there are null bytes, it's likely UTF16LE without BOM
                            content = buffer.toString('utf16le');
                        } else {
                            content = buffer.toString('utf8');
                        }
                        
                        // "reduce the codes" logic for output:
                        let reduced = content.replace(/\r\n/g, '\n')
                                             .replace(/\n\s*\n\s*\n/g, '\n\n')
                                             .replace(/    /g, '  ');

                        if (fullPath.includes('justice4u_final.sql')) {
                            const lines = reduced.split('\n');
                            const filtered = lines.filter(l => !l.trim().toUpperCase().startsWith('INSERT INTO'));
                            reduced = filtered.join('\n').replace(/\n\s*\n/g, '\n'); 
                        }

                        reduced = reduced.replace(/\x00/g, '');
                        reduced = reduced.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

                        htmlContent += `<h2>File: ${fullPath.replace(baseDir+'/', '')}</h2>\n`;
                        htmlContent += `<pre>${reduced}</pre>\n`;
                        
                    } catch(e) {}
                }
            }
        }
    } catch(e){}
}

walkDir(baseDir);

htmlContent += `</body></html>`;

fs.writeFileSync('c:/xampp/htdocs/J4U/Justice4U_CodeBase_v2.doc', htmlContent, 'utf8');
console.log("Done generating Word doc.");
