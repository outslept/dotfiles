import sys, os, subprocess

if len(sys.argv) != 2:
    print("Usage: img2jpg <input_image>")
    sys.exit(1)

src = sys.argv[1]
out = os.path.splitext(src)[0] + ".jpg"
subprocess.run(["magick", src, "-quality", "95", "-strip", out], check=True)