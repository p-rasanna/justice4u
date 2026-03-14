$schemaFile = "c:\xampp\htdocs\J4U\J4U\j4u_database.sql"
$srcDir = "c:\xampp\htdocs\J4U\J4U"

# Extract valid table names from schema
$validTables = @()
$schemaContent = Get-Content $schemaFile
foreach ($line in $schemaContent) {
    if ($line -match 'CREATE TABLE IF NOT EXISTS `([^`]+)`') {
        $validTables += $matches[1]
    } elseif ($line -match 'CREATE TABLE [^`]?([a-zA-Z0-9_]+)[^`]? \(') {
        $validTables += $matches[1]
    }
}
$validTables = $validTables | Sort-Object -Unique

Write-Host "Valid Tables found in schema:"
$validTables

# Search for SQL queries in JSPs and Java files
$filesToScan = Get-ChildItem -Path $srcDir -Include *.jsp,*.java -File -Recurse | Where-Object { $_.FullName -notmatch "\\WEB-INF" -and $_.FullName -notmatch "\\test" -and $_.FullName -notmatch "\\build" }

$invalidQueries = @()
$queryCount = 0

foreach ($file in $filesToScan) {
    $content = Get-Content $file.FullName
    foreach ($line in $content) {
        # very basic regex for SELECT FROM, UPDATE, INSERT INTO, DELETE FROM
        if ($line -match '(?i)(?:FROM|INTO|UPDATE)\s+([a-zA-Z0-9_]+)') {
            $table = $matches[1].ToLower()
            $queryCount++
            # skip SQL keywords that might get matched
            if ($table -in "select", "insert", "update", "delete", "where", "set", "values", "the", "a") { continue }
            
            if ($validTables -notcontains $table) {
                # Could be a string like "String from = request..." or something. We need context.
                if ($line -match '(?i)"[^"]*(?:FROM|INTO|UPDATE)\s+[a-zA-Z0-9_]+') {
                    $invalidQueries += [PSCustomObject]@{
                        File = $file.Name
                        Table = $table
                        Line = $line.Trim()
                    }
                }
            }
        }
    }
}

Write-Host "`nTotal SQL-like statements parsed: $queryCount"
if ($invalidQueries.Count -gt 0) {
    Write-Host "Found $($invalidQueries.Count) potential invalid table references in SQL strings!"
    $invalidQueries | Format-Table -AutoSize
} else {
    Write-Host "All queried tables seem to match the database schema!"
}
