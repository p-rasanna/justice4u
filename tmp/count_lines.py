import os
import glob
import json

base_dir = "c:/xampp/htdocs/J4U/J4U"
ignore_dirs = ['node_modules', 'build', 'dist', '.git', '_archive']
extensions = ['.java', '.jsp', '.html', '.css', '.js', '.sql']

stats = {}
total_lines = 0

for root, dirs, files in os.walk(base_dir):
    dirs[:] = [d for d in dirs if d not in ignore_dirs]
    for file in files:
        if any(file.endswith(ext) for ext in extensions):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    lines = len(f.readlines())
                    stats[path] = lines
                    total_lines += lines
            except Exception:
                pass

sorted_stats = dict(sorted(stats.items(), key=lambda item: item[1], reverse=True)[:30])
print(json.dumps({"total_lines": total_lines, "top_files": sorted_stats}, indent=2))
