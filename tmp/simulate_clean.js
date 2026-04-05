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

function cleanCode(content, ext) {
    let lines = content.replace(/\r\n/g, '\n').replace(/\x00/g, '').split('\n');
    let result = [];
    let inBlockComment = false;

    for (let line of lines) {
        const trimmed = line.trim();

        // Java/JS block comments
        if (ext === '.java' || ext === '.js') {
            if (inBlockComment) {
                if (trimmed.includes('*/')) inBlockComment = false;
                continue;
            }
            if (trimmed.startsWith('/*')) {
                if (!trimmed.includes('*/')) inBlockComment = true;
                continue;
            }
            if (trimmed.startsWith('//')) continue;
        }

        // HTML/JSP comments
        if (ext === '.html' || ext === '.jsp') {
            if (inBlockComment) {
                if (trimmed.includes('-->')) inBlockComment = false;
                continue;
            }
            if (trimmed.startsWith('<!--')) {
                if (!trimmed.includes('-->')) inBlockComment = true;
                continue;
            }
            // JSP Java comments inside scriptlets
            if (trimmed.startsWith('//')) continue;
            // Block comment stars
            if (trimmed.startsWith('*') && !trimmed.startsWith('*/')) continue;
        }

        // CSS comments
        if (ext === '.css') {
            if (inBlockComment) {
                if (trimmed.includes('*/')) inBlockComment = false;
                continue;
            }
            if (trimmed.startsWith('/*')) {
                if (!trimmed.includes('*/')) inBlockComment = true;
                continue;
            }
        }

        // Skip blank lines
        if (trimmed === '') continue;

        // Reduce indent: 4 spaces -> 2 spaces
        const indent = line.match(/^(\s*)/)[1];
        const reducedIndent = indent.replace(/    /g, '  ');
        result.push(reducedIndent + trimmed);
    }

    return result.join('\n');
}

let totalBefore = 0, totalAfter = 0;
let fileStats = [];

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
                        const content = readFile(fullPath);
                        const before = content.split('\n').length;
                        const cleaned = cleanCode(content, ext);
                        const after = cleaned.split('\n').length;
                        totalBefore += before;
                        totalAfter += after;
                        const saved = before - after;
                        if (saved > 5) {
                            fileStats.push({ file: fullPath.replace(baseDir.replace(/\//g,'\\'), '').replace(/\\/g, '/'), before, after, saved });
                        }
                    } catch(e) {}
                }
            }
        }
    } catch(e){}
}

walkDir(baseDir);
fileStats.sort((a, b) => b.saved - a.saved);

console.log('=== SIMULATION RESULTS ===');
console.log(`Before: ${totalBefore} lines`);
console.log(`After:  ${totalAfter} lines`);
console.log(`Saved:  ${totalBefore - totalAfter} lines (${((totalBefore - totalAfter)/totalBefore*100).toFixed(1)}%)`);
console.log(`\nEstimated pages before: ~${Math.round(totalBefore / 50)}`);
console.log(`Estimated pages after:  ~${Math.round(totalAfter / 50)}`);
console.log(`\nTop files by lines saved:`);
fileStats.slice(0,20).forEach(f => console.log(`  ${f.file}: ${f.before} -> ${f.after} (saved ${f.saved})`));
