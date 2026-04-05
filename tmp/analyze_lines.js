const fs = require('fs');
const path = require('path');

const baseDir = 'c:/xampp/htdocs/J4U/J4U';
const ignoreDirs = ['node_modules', 'build', 'dist', '.git', '_archive'];
const extensions = ['.java', '.jsp', '.html', '.css', '.js', '.sql'];

let allFiles = [];

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
            } else if (extensions.some(ext => fullPath.endsWith(ext))) {
                try {
                    const buffer = fs.readFileSync(fullPath);
                    let content = '';
                    if (buffer.length >= 2 && buffer[0] === 0xFF && buffer[1] === 0xFE) {
                        content = buffer.toString('utf16le');
                    } else if (buffer.indexOf(0x00) !== -1) {
                        content = buffer.toString('utf16le');
                    } else {
                        content = buffer.toString('utf8');
                    }
                    content = content.replace(/\x00/g, '');

                    const allLines = content.split('\n').length;
                    
                    // Count blank lines
                    const blankLines = content.split('\n').filter(l => l.trim() === '').length;
                    
                    // Count comment-only lines
                    const commentLines = content.split('\n').filter(l => {
                        const t = l.trim();
                        return t.startsWith('//') || t.startsWith('*') || t.startsWith('/*') || t === '<!--' || t.startsWith('<!--') || t === '-->' || t === '*/';
                    }).length;

                    // Count INSERT lines in SQL
                    const insertLines = content.split('\n').filter(l => l.trim().toUpperCase().startsWith('INSERT INTO')).length;

                    allFiles.push({
                        file: fullPath.replace(baseDir.replace(/\//g, '\\'), '').replace(/\\/g, '/'),
                        allLines,
                        blankLines,
                        commentLines,
                        insertLines,
                        potentialSaving: blankLines + commentLines + insertLines
                    });
                } catch(e) {}
            }
        }
    } catch(e){}
}

walkDir(baseDir);

allFiles.sort((a, b) => b.allLines - a.allLines);

const total = allFiles.reduce((s, f) => s + f.allLines, 0);
const totalBlanks = allFiles.reduce((s, f) => s + f.blankLines, 0);
const totalComments = allFiles.reduce((s, f) => s + f.commentLines, 0);
const totalInserts = allFiles.reduce((s, f) => s + f.insertLines, 0);

console.log(`TOTAL LINES: ${total}`);
console.log(`TOTAL BLANK LINES: ${totalBlanks}`);
console.log(`TOTAL COMMENT LINES: ${totalComments}`);
console.log(`TOTAL INSERT LINES (SQL): ${totalInserts}`);
console.log(`MAX REMOVABLE: ${totalBlanks + totalComments + totalInserts}`);
console.log(`\nTop 30 files by line count:`);
allFiles.slice(0,30).forEach(f => {
    console.log(`  [${f.allLines} lines | -${f.potentialSaving} removable] ${f.file}`);
});
