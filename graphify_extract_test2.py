import json
from graphify.extract import collect_files, extract
from pathlib import Path

with open('graphify_result.json') as f:
    detect = json.load(f)

code_files = []
for f in detect.get('files', {}).get('code', []):
    code_files.extend(collect_files(Path(f)) if Path(f).is_dir() else [Path(f)])

print('Processing ' + str(len(code_files)) + ' code files')
print('Processing first 3 files to test extraction')

# Try extraction on just the first file to test
sample_files = code_files[:1]
result = extract(sample_files)
print('Sample extraction completed')
