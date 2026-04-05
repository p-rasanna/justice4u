const fs = require('fs');
const path = require('path');

const baseDir = 'c:/xampp/htdocs/J4U/J4U';
const ignoreDirs = ['node_modules', 'build', 'dist', '.git', '_archive'];
const extensions = ['.java', '.jsp', '.html', '.css', '.js', '.sql'];

let stats = {};
let totalLines = 0;

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
                        const content = fs.readFileSync(fullPath, 'utf8');
                        const lines = content.split('\n').length;
                        stats[fullPath] = lines;
                        totalLines += lines;
                    } catch(e) {}
                }
            }
        }
    } catch(e){}
}

walkDir(baseDir);

const sortedStats = Object.entries(stats)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 30)
    .map(entry => ({ file: entry[0].replace(/\\/g, '/').replace(baseDir + '/', ''), lines: entry[1] }));

fs.writeFileSync('c:/xampp/htdocs/J4U/tmp/lines_out_utf8.json', JSON.stringify({ totalLines, topFiles: sortedStats }, null, 2), 'utf8');
