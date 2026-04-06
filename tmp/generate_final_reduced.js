const fs = require('fs');
const path = require('path');

const baseDir = 'c:/xampp/htdocs/J4U/J4U';
const ignoreDirs = ['node_modules', '.git', 'build', 'dist', '_archive', '.nb-gradle', 'uploads'];

// Files to SKIP entirely (pure UI/layout, no logic)
const skipFiles = [
  'Home.html', 'header.html', 'app-layout.css', 'justice4u-tokens.css',
  'main.js', 'script.js',
  'viewcusdet.jsp',           // duplicate of viewcustdetails.jsp
  '_head.jsp', '_topbar.jsp', '_sidebar.jsp', '_footer.jsp',
  'Lawyer.jsp',               // old page, replaced by Lawyer.html
  'error.jsp',
];

// Extensions to include
const extensions = ['.java', '.jsp', '.html', '.css', '.js', '.sql'];

function readFile(fullPath) {
    const buffer = fs.readFileSync(fullPath);
    if (buffer.length >= 2 && buffer[0] === 0xFF && buffer[1] === 0xFE)
        return buffer.toString('utf16le');
    if (buffer.indexOf(0x00) !== -1) return buffer.toString('utf16le');
    return buffer.toString('utf8');
}

// Aggressively strip HTML-only lines from JSP files, keep Java logic
function smartReduceJSP(content) {
    const lines = content.replace(/\r\n/g,'\n').replace(/\x00/g,'').split('\n');
    const result = [];
    let inScriptlet = false;
    let blankCount = 0;

    for (let line of lines) {
        const t = line.trim();
        if (!t) { blankCount++; if (blankCount <= 1) result.push(''); continue; }
        blankCount = 0;

        // Track scriptlet blocks
        if (t.includes('<%') && !t.includes('%>')) inScriptlet = true;
        if (t.includes('%>') && !t.includes('<%')) inScriptlet = false;

        // Always keep: scriptlet lines, page directives, jsp:include
        if (t.startsWith('<%') || t.startsWith('%>') || t.includes('<%=') ||
            t.startsWith('<%@') || t.startsWith('<jsp:') || inScriptlet) {
            result.push(line.trimEnd());
            continue;
        }

        // Always keep: form, input, select, option, button, table, tr, td, th tags (functional HTML)
        const functionalTags = ['<form', '</form', '<input', '<select', '<option', '<button',
            '<table', '</table', '<tr', '</tr', '<td', '</td', '<th', '</th', '<thead', '<tbody',
            '<textarea', '<a href', '<a class'];
        if (functionalTags.some(tag => t.toLowerCase().startsWith(tag))) {
            // Strip verbose class/style attributes to shorten
            let cleaned = line.trimEnd()
                .replace(/\s+class="[^"]*"/g, '')
                .replace(/\s+style="[^"]*"/g, '')
                .replace(/\s+id="[^"]*"/g, '');
            result.push(cleaned);
            continue;
        }

        // SKIP pure layout/styling divs, spans, bootstrap wrappers
        const skipPatterns = [
            /^<div/, /^<\/div/, /^<span/, /^<\/span/, /^<p/, /^<\/p/,
            /^<h[1-6]/, /^<\/h[1-6]/, /^<i /, /^<i>/, /^<\/i/,
            /^<nav/, /^<\/nav/, /^<ul/, /^<\/ul/, /^<li/, /^<\/li/,
            /^<section/, /^<\/section/, /^<main/, /^<\/main/,
            /^<header/, /^<\/header/, /^<footer/, /^<\/footer/,
            /^<small/, /^<\/small/, /^<strong/, /^<\/strong/,
            /^<label/, /^<\/label/,
            /^<!DOCTYPE/, /^<html/, /^<\/html/, /^<head/, /^<\/head/,
            /^<body/, /^<\/body/, /^<title/, /^<\/title/,
            /^<link /, /^<script/, /^<\/script/, /^<meta/,
            /^<jsp:include/, // shared layout includes (head, sidebar, topbar, footer)
        ];
        if (skipPatterns.some(p => p.test(t))) continue;

        result.push(line.trimEnd());
    }

    // Remove consecutive blanks
    return result.join('\n').replace(/\n{3,}/g, '\n\n').trim();
}

// Reduce Java files: strip verbose boilerplate, keep logic
function smartReduceJava(content) {
    const lines = content.replace(/\r\n/g,'\n').replace(/\x00/g,'').split('\n');
    const result = [];
    let inBlockComment = false;
    let blankCount = 0;

    for (let line of lines) {
        const t = line.trim();
        if (!t) { blankCount++; if (blankCount <= 1) result.push(''); continue; }
        blankCount = 0;

        // Skip block comments
        if (inBlockComment) {
            if (t.includes('*/')) inBlockComment = false;
            continue;
        }
        if (t.startsWith('/*')) { if (!t.includes('*/')) inBlockComment = true; continue; }
        if (t.startsWith('//')) continue;
        if (t.startsWith('*')) continue;

        // Shorten import blocks: keep only 1 line per package group
        if (t.startsWith('import ')) {
            result.push(line.trimEnd());
            continue;
        }

        result.push(line.trimEnd());
    }
    return result.join('\n').replace(/\n{3,}/g, '\n\n').trim();
}

// Reduce CSS: strip entirely (just keep filename as reference)
function smartReduceCSS(content) {
    const lines = content.replace(/\r\n/g,'\n').replace(/\x00/g,'').split('\n');
    let result = [];
    let blank = 0;
    let inBlock = false;
    for (let line of lines) {
        const t = line.trim();
        if (!t) { blank++; if (blank <= 1) result.push(''); continue; }
        blank = 0;
        if (inBlock) { if (t === '}') { inBlock = false; } continue; }
        if (t.startsWith('/*') || t.startsWith('//')) continue;
        if (t.endsWith('{')) { result.push(t); inBlock = true; continue; }
        result.push(line.trimEnd());
    }
    return result.join('\n').replace(/\n{3,}/g, '\n\n').trim();
}

// SQL: keep only CREATE TABLE, skip INSERT INTO and SET/USE
function smartReduceSQL(content) {
    const lines = content.replace(/\r\n/g,'\n').replace(/\x00/g,'').split('\n');
    const result = [];
    let blank = 0;
    for (let line of lines) {
        const t = line.trim();
        if (!t) { blank++; if (blank <= 1) result.push(''); continue; }
        blank = 0;
        const upper = t.toUpperCase();
        if (upper.startsWith('INSERT INTO') || upper.startsWith('SET ') ||
            upper.startsWith('USE ') || upper.startsWith('--') ||
            upper.startsWith('LOCK') || upper.startsWith('UNLOCK') ||
            upper.startsWith('/*!')) continue;
        result.push(line.trimEnd());
    }
    return result.join('\n').replace(/\n{3,}/g, '\n\n').trim();
}

// Group files by module for organized output
const moduleGroups = {
    'Shared Utilities': ['DatabaseConfig.java','PasswordUtil.java','ValidationUtil.java','NotificationService.java','FileUploadUtil.java'],
    'Authentication': ['LoginServlet.java','cust_login.html','cust_login.jsp','cust_login.html','Lawyer_login_form.jsp','internlogin.html','Login.jsp'],
    'Client Registration': ['customer_form.jsp','customer.jsp'],
    'Lawyer Registration': ['Lawyer.html','RegisterServlet.java'],
    'Intern Registration': ['intern.jsp','ProcessInternServlet.java','InternRegistrationDAO.java'],
    'Admin Dashboard & Actions': ['admindashboard.jsp','AdminDashboardServlet.java','AdminDAO.java','user_action.jsp','viewcustomers.jsp','viewlawyers.jsp','viewinterns.jsp','viewlawdetails.jsp'],
    'Case Management': ['case.jsp','AddCaseServlet.java','CaseRequestDAO.java','CaseDAO.java','CaseManagementDAO.java','findlawyer.jsp','clientdashboard.jsp','ClientDashboardServlet.java','client_case_details.jsp','billing.jsp','cancel_lawyer_request.jsp','case_success.jsp'],
    'Lawyer Assignment': ['allotlawyer.jsp','allotlawyerdone.jsp'],
    'Intern Assignment': ['assign_intern_to_lawyer.jsp','process_assign_intern_lawyer.jsp','InternDAO.java','InternDashboardDAO.java'],
    'Lawyer Dashboard': ['LawyerDashboardServlet.java','LawyerDashboardDAO.java','Lawyerdashboard.jsp','manage_hearings.jsp','viewcustdetails.jsp','process_client_request.jsp'],
    'Intern Dashboard': ['interndashboard.jsp','InternDashboardServlet.java','viewcase_intern.jsp','uploadInternWork.jsp'],
    'Messaging System': ['SendMessageServlet.java','caseDiscussion.jsp','send_message.jsp'],
    'Database Schema': ['justice4u_final.sql'],
    'Shared Layout Components': ['app-layout.css','script.js','UserDAO.java','LawyerDAO.java'],
};

// Collect all files
let allFiles = {};
function walkDir(dir) {
    if (ignoreDirs.includes(path.basename(dir))) return;
    try {
        const entries = fs.readdirSync(dir);
        for (const entry of entries) {
            const fullPath = path.join(dir, entry);
            let isDir = false;
            try { isDir = fs.statSync(fullPath).isDirectory(); } catch(e) {}
            if (isDir) walkDir(fullPath);
            else {
                const ext = path.extname(entry);
                if (extensions.includes(ext) && !skipFiles.includes(entry)) {
                    allFiles[entry] = fullPath;
                }
            }
        }
    } catch(e) {}
}
walkDir(baseDir);

// Build HTML document
let htmlSections = '';
let processedFiles = new Set();

for (const [groupName, fileNames] of Object.entries(moduleGroups)) {
    let groupContent = '';
    for (const fileName of fileNames) {
        if (skipFiles.includes(fileName)) continue;
        if (processedFiles.has(fileName)) continue;
        const fullPath = allFiles[fileName];
        if (!fullPath) continue;
        processedFiles.add(fileName);

        try {
            const raw = readFile(fullPath);
            const ext = path.extname(fileName);
            let reduced = '';
            if (ext === '.java') reduced = smartReduceJava(raw);
            else if (ext === '.jsp' || ext === '.html') reduced = smartReduceJSP(raw);
            else if (ext === '.css') reduced = smartReduceCSS(raw);
            else if (ext === '.sql') reduced = smartReduceSQL(raw);
            else reduced = raw.replace(/\r\n/g,'\n').replace(/\x00/g,'');

            if (!reduced || reduced.trim().length < 5) continue;

            const escaped = reduced
                .replace(/&/g,'&amp;')
                .replace(/</g,'&lt;')
                .replace(/>/g,'&gt;');

            groupContent += `<h3>${fileName}</h3>\n<pre>${escaped}</pre>\n`;
        } catch(e) {}
    }

    if (groupContent) {
        htmlSections += `<h2>${groupName}</h2>\n${groupContent}\n`;
    }
}

// Any remaining files not in groups
let uncategorized = '';
for (const [fileName, fullPath] of Object.entries(allFiles)) {
    if (processedFiles.has(fileName)) continue;
    if (skipFiles.includes(fileName)) continue;
    try {
        const raw = readFile(fullPath);
        const ext = path.extname(fileName);
        let reduced = '';
        if (ext === '.java') reduced = smartReduceJava(raw);
        else if (ext === '.jsp' || ext === '.html') reduced = smartReduceJSP(raw);
        else if (ext === '.css') reduced = smartReduceCSS(raw);
        else if (ext === '.sql') reduced = smartReduceSQL(raw);
        else reduced = raw.replace(/\r\n/g,'\n').replace(/\x00/g,'');
        if (!reduced || reduced.trim().length < 5) continue;
        const escaped = reduced.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
        uncategorized += `<h3>${fileName}</h3>\n<pre>${escaped}</pre>\n`;
    } catch(e) {}
}
if (uncategorized) {
    htmlSections += `<h2>Other Components</h2>\n${uncategorized}\n`;
}

const html = `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Justice4U - Final Code (Reduced)</title>
<style>
  body { font-family: 'Times New Roman', serif; font-size: 11pt; margin: 35px 45px; }
  h1 { font-size: 20pt; color: #0B192C; text-align: center; border-bottom: 3px double #D4AF37; padding-bottom: 10px; }
  .sub { text-align:center; color:#555; font-size:10pt; margin-bottom:30px; }
  h2 { font-size: 14pt; color: #0B192C; background:#f0f4f8; border-left:4px solid #D4AF37; padding:6px 12px; margin-top:36px; page-break-before: always; }
  h2:first-of-type { page-break-before: avoid; }
  h3 { font-size: 11pt; color: #1a3a5c; border-bottom:1px dashed #ccc; margin-top:20px; margin-bottom:4px; }
  pre {
    font-family: 'Courier New', monospace;
    font-size: 8pt;
    background: #fafafa;
    border-left: 3px solid #D4AF37;
    padding: 8px 12px;
    white-space: pre-wrap;
    word-wrap: break-word;
    margin: 4px 0 14px 0;
    line-height: 1.5;
  }
</style>
</head>
<body>
<h1>Justice4U — Final Source Code</h1>
<p class="sub">Online Legal Consultation Platform | JSP / Servlet / MySQL<br>Organized by Module | Logic-Only View</p>
${htmlSections}
</body>
</html>`;

fs.writeFileSync('c:/xampp/htdocs/J4U/Justice4U_Final_Reduced.doc', html, 'utf8');
console.log('Done! Saved as Justice4U_Final_Reduced.doc');
