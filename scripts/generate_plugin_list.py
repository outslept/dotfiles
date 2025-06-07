import subprocess
import os

vscode = 'code.cmd' if os.name == 'nt' else 'code'

extensions = sorted(subprocess.run(
    [vscode, '--list-extensions'],
    capture_output=True,
    text=True
).stdout.splitlines())

with open('plugin-list.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(extensions))
