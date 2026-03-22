$files = Get-ChildItem -Path "C:\xampp\htdocs\J4U\J4U\web" -Include *.jsp, *.css -Recurse -File

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Remove CSS transitions to make UI interactions instantaneous
    $newContent = $content -replace 'transition:\s*all\s+[0-9.]+s[^;]*;', 'transition: none;'
    $newContent = $newContent -replace 'transition:\s*background\s+[0-9.]+s[^;]*;', 'transition: none;'
    $newContent = $newContent -replace 'transition:\s*transform\s+[0-9.]+s[^;]*;', 'transition: none;'
    $newContent = $newContent -replace 'transition:\s*color\s+[0-9.]+s[^;]*;', 'transition: none;'
    $newContent = $newContent -replace 'transition:\s*opacity\s+[0-9.]+s[^;]*;', 'transition: none;'
    
    # Remove animation delays so elements render immediately
    $newContent = $newContent -replace 'animation-delay:\s*[0-9.]+s;', 'animation-delay: 0s;'
    
    # Remove specific entrance animations like 'fadeUp', 'enterUp', 'popIn'
    $newContent = $newContent -replace 'animation:\s*fadeUp\s+[^;]+;', 'animation: none;'
    $newContent = $newContent -replace 'animation:\s*enterUp\s+[^;]+;', 'animation: none;'
    $newContent = $newContent -replace 'animation:\s*popIn\s+[^;]+;', 'animation: none;'
    $newContent = $newContent -replace 'animation:\s*fadeIn\s+[^;]+;', 'animation: none;'

    if ($content -cne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent
    }
}
Write-Host "Animations successfully reduced across all files."
