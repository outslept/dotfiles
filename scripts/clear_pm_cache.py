import subprocess, shutil

def clear_js_caches():
    managers = [
        ('npm', ['npm', 'cache', 'clean', '--force']),
        ('yarn', ['yarn', 'cache', 'clean']),
        ('pnpm', ['pnpm', 'store', 'prune']),
        ('bun', ['bun', 'pm', 'cache', 'rm'])
    ]
    
    for name, cmd in managers:
        if shutil.which(name):
            result = subprocess.run(cmd, capture_output=True, shell=True)
            if result.returncode == 0:
                print(f"Cleared {name} cache")

clear_js_caches()