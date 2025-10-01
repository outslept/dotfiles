import sys, subprocess, re

def list_sd():
    try:
        out = subprocess.check_output(["lsblk", "-d", "-o", "NAME", "-n"], text=True)
    except Exception:
        return []
    return ["/dev/" + x.strip() for x in out.splitlines() if re.fullmatch(r"sd[a-z]", x.strip())]

if len(sys.argv) != 3:
    print("Usage: iso2sd <input_file> <output_device>")
    print("Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda")
    print("\nAvailable SD cards:")
    for d in list_sd():
        print(d)
    sys.exit(1)

iso, dev = sys.argv[1], sys.argv[2]
subprocess.run(["sudo", "dd", "bs=4M", "status=progress", "oflag=sync", f"if={iso}", f"of={dev}"], check=True)
subprocess.run(["sudo", "eject", dev], check=False)