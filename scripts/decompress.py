import sys, tarfile

if len(sys.argv) != 2:
    print("Usage: decompress <archive.tar.gz>")
    sys.exit(1)

with tarfile.open(sys.argv[1], "r:gz") as tf:
    tf.extractall()