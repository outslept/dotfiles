import sys, os, tarfile

if len(sys.argv) != 2:
    print("Usage: compress <path>")
    sys.exit(1)

src = os.path.normpath(sys.argv[1])
out = src + ".tar.gz"
with tarfile.open(out, "w:gz") as tf:
    tf.add(src, arcname=os.path.basename(src))