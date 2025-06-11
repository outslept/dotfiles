import subprocess
import os
from pathlib import Path

vscode = 'code.cmd' if os.name == 'nt' else 'code'

config_dir = Path(__file__).parent.parent / 'config' / 'vscode'
config_dir.mkdir(parents=True, exist_ok=True)

extensions = sorted(subprocess.run(
    [vscode, '--list-extensions'],
    capture_output=True,
    text=True
).stdout.splitlines())

with open(config_dir / 'plugin-list.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(extensions))
