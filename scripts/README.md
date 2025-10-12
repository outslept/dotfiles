# toolbelt

small cli toolbox.

## build
```sh
cargo build
cargo install --path .
```

## usage
```sh
toolbelt --help
toolbelt <command> -h
```

## commands

archive
```sh
toolbelt archive <path> [-o <out.tar.gz>] [-l 0..9]
# create .tar.gz from file or directory
toolbelt archive ./mydir -o mydir.tar.gz -l 9
```

extract
```sh
toolbelt extract <archive.tar.gz> [-C <dir>]
# extract into directory (default: current dir)
toolbelt extract mydir.tar.gz -C ./out
```

kill-port
```sh
toolbelt kill-port <port>
# kill process(es) listening on TCP port
toolbelt kill-port 3000
```

clean-browsers
```sh
toolbelt clean-browsers
# clear caches for Chrome/Chromium, Edge, Brave, Opera, Firefox
toolbelt clean-browsers
```

clean-node-cache
```sh
toolbelt clean-node-cache
# clear npm/yarn/pnpm/bun caches if installed
toolbelt clean-node-cache
```

flash-iso
```sh
toolbelt flash-iso <image.iso> <device>   # Linux only
# write ISO to /dev/sdX via dd, then eject
toolbelt flash-iso ~/Downloads/ubuntu.iso /dev/sda
```

## aliases
```text
archive: compress
extract: decompress, unpack
kill-port: free-port, free
clean-browsers: clear-browser-caches, clear-browsers
clean-node-cache: clear-js-caches, clear-js-cache, clean-js-cache, clean-npm-cache
flash-iso: iso2sd, iso-to-sd, write-iso
```

## runtime dependencies
- Linux/macOS:
  - `kill-port`: `lsof`
  - `clean-browsers`: `pkill` or `killall`
  - `flash-iso` (Linux): `dd`, `eject`
- Windows:
  - uses built-ins: `netstat`, `taskkill`

## notes
- `flash-iso` is destructive. double‑check the target device. may require `sudo`.

> todo: make flash-iso safe
