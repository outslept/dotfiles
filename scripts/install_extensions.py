import subprocess, os, sys, argparse
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--file', '-f', default='../config/vscode/plugin-list.txt')
args = parser.parse_args()

plugin_list = Path(args.file)
if not plugin_list.exists():
    print(f"Error: Plugin list file not found: {plugin_list}", file=sys.stderr)
    sys.exit(1)

vscode = 'code.cmd' if os.name == 'nt' else 'code'
extensions = [line.strip() for line in plugin_list.read_text().splitlines() if line.strip()]

for i, ext in enumerate(extensions, 1):
    print(f"Progress: [{i}/{len(extensions)}]")
    print(f"Installing extension: {ext}")
    subprocess.run([vscode, '--install-extension', ext])
