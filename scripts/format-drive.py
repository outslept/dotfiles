import sys, subprocess, os, getpass, re

def list_drives():
    try:
        out = subprocess.check_output(["lsblk", "-d", "-o", "NAME", "-n"], text=True)
    except Exception:
        return []
    return ["/dev/" + x.strip() for x in out.splitlines() if x.strip()]

if len(sys.argv) != 3:
    print("Usage: format-drive <device> <name>")
    print("Example: format-drive /dev/sda 'My Stuff'")
    print("\nAvailable drives:")
    for d in list_drives():
        print(d)
    sys.exit(1)

dev, label = sys.argv[1], sys.argv[2]
print(f"WARNING: This will completely erase all data on {dev} and label it '{label}'.")
confirm = input("Are you sure you want to continue? (y/N): ").strip()
if not re.match(r"^[Yy]$", confirm):
    sys.exit(0)

subprocess.run(["sudo", "wipefs", "-a", dev], check=True)
subprocess.run(["sudo", "dd", "if=/dev/zero", f"of={dev}", "bs=1M", "count=100", "status=progress"], check=True)
subprocess.run(["sudo", "parted", "-s", dev, "mklabel", "gpt"], check=True)
subprocess.run(["sudo", "parted", "-s", dev, "mkpart", "primary", "ext4", "1MiB", "100%"], check=True)
part = f"{dev}1" if "nvme" not in dev else f"{dev}p1"
subprocess.run(["sudo", "mkfs.ext4", "-L", label, part], check=True)
user = os.environ.get("USER") or getpass.getuser()
mount_path = f"/run/media/{user}/{label}"
subprocess.run(["sudo", "chmod", "-R", "777", mount_path], check=False)
print(f"Drive {dev} formatted and labeled '{label}'.")