const fs = require('fs');
const path = require('path');

const baseDir = 'c:/xampp/htdocs/J4U/J4U';
const ignoreDirs = ['node_modules', 'build', 'dist', '.git', '_archive'];
const extensions = ['.java', '.jsp', '.html', '.css', '.js'];
// NOTE: We skip .sql so we don't break any SQL structure

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

    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];
        const trimmed = line.trim();

        // Java / JS: handle block comments and single-line comments
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

        // HTML / JSP: handle HTML comments and JSP/Java inline comments
        if (ext === '.html' || ext === '.jsp') {
            if (inBlockComment) {
                if (trimmed.includes('-->')) inBlockComment = false;
                continue;
            }
            if (trimmed.startsWith('<!--')) {
                if (!trimmed.includes('-->')) inBlockComment = true;
                continue;
            }
            // Java-style single line comments inside JSP scriptlets
            if (trimmed.startsWith('//')) continue;
            // Block comment mid-lines inside scriptlets
            if (trimmed.startsWith('*') && !trimmed.startsWith('*/') && !trimmed.startsWith('*{')) continue;
            if (trimmed.startsWith('/*') && !trimmed.includes('*/')) { inBlockComment = true; continue; }
            if (trimmed.startsWith('/*') && trimmed.includes('*/')) continue;
        }

        // CSS: handle block comments
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

        // Skip completely blank lines
        if (trimmed === '') continue;

        // Reduce 4-space indents to 2-space
        const indent = line.match(/^(\s*)/)[1];
        const reducedIndent = indent.replace(/    /g, '  ');
        result.push(reducedIndent + trimmed);
    }

    // Allow max 1 consecutive blank line (already stripped above, just clean joins)
    return result.join('\n');
}

let totalBefore = 0, totalAfter = 0;
let filesProcessed = 0;

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
                        // Write the cleaned content back
                        fs.writeFileSync(fullPath, cleaned, 'utf8');
                        filesProcessed++;
                        if (before !== after) {
                            console.log(`  Cleaned: ${file} (${before} -> ${after}, saved ${before-after})`);
                        }
                    } catch(e) {
                        console.log(`  SKIPPED (error): ${fullPath} - ${e.message}`);
                    }
                }
            }
        }
    } catch(e){}
}

console.log('Starting cleaning...\n');
walkDir(baseDir);
console.log(`\n=== DONE ===`);
console.log(`Files processed: ${filesProcessed}`);
console.log(`Lines before: ${totalBefore}`);
console.log(`Lines after:  ${totalAfter}`);
console.log(`Lines saved:  ${totalBefore - totalAfter}`);
