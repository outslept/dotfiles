import sys, subprocess, platform

def get_pid_on_port(port):
    system = platform.system()
    
    if system == 'Windows':
        result = subprocess.run(
            f'netstat -ano | findstr :{port} | findstr LISTENING',
            shell=True, capture_output=True, text=True
        )
        if result.stdout:
            return result.stdout.strip().split()[-1]
    else:
        result = subprocess.run(
            f'lsof -ti:{port}',
            shell=True, capture_output=True, text=True
        )
        if result.stdout:
            return result.stdout.strip().split('\n')[0]
    
    return None

def kill_process(pid):
    system = platform.system()
    
    if system == 'Windows':
        subprocess.run(['taskkill', '/F', '/PID', pid], check=True)
    else:
        subprocess.run(['kill', '-9', pid], check=True)

if len(sys.argv) != 2:
    print("Usage: kill_port <port>")
    print("Example: kill_port 3000")
    sys.exit(1)

port = sys.argv[1]

if not port.isdigit():
    print("Error: Port must be a number")
    sys.exit(1)

pid = get_pid_on_port(port)

if not pid:
    print(f"No process found on port {port}")
    sys.exit(1)

kill_process(pid)
print(f"Killed process {pid} on port {port}")