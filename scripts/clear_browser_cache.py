import os, shutil, subprocess, glob
from pathlib import Path

def clear_browser_caches():
    user = os.environ['USERPROFILE']
    browsers = [
        ('Chrome', f'{user}\\AppData\\Local\\Google\\Chrome\\User Data\\Default\\Cache'),
        ('Edge', f'{user}\\AppData\\Local\\Microsoft\\Edge\\User Data\\Default\\Cache'),
        ('Firefox', f'{user}\\AppData\\Local\\Mozilla\\Firefox\\Profiles\\*\\cache2'),
        ('Opera', f'{user}\\AppData\\Roaming\\Opera Software\\Opera Stable\\Cache'),
        ('Brave', f'{user}\\AppData\\Local\\BraveSoftware\\Brave-Browser\\User Data\\Default\\Cache')
    ]
    
    # Kill browser processes first
    processes = ['chrome.exe', 'msedge.exe', 'firefox.exe', 'opera.exe', 'brave.exe']
    for proc in processes:
        subprocess.run(f'taskkill /f /im {proc}', shell=True, capture_output=True)
    
    for name, path in browsers:
        if '*' in path:
            for cache_dir in glob.glob(path):
                if Path(cache_dir).exists():
                    shutil.rmtree(cache_dir, ignore_errors=True)
                    print(f"Cleared {name} cache")
        elif Path(path).exists():
            shutil.rmtree(path, ignore_errors=True)
            print(f"Cleared {name} cache")

clear_browser_caches()