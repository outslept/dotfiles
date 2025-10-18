<details>
<summary>current extensions</summary>

```
antfu.iconify
antfu.unocss
ardenivanov.svelte-intellisense
astro-build.astro-vscode
bradlc.vscode-tailwindcss
cardinal90.multi-cursor-case-preserve
dbaeumer.vscode-eslint
denoland.vscode-deno
dustypomerleau.rust-syntax
eamodio.gitlens
expo.vscode-expo-tools
fabiospampinato.vscode-diff
fey.oscura
formulahendry.code-runner
foxundermoon.shell-format
github.vscode-github-actions
github.vscode-pull-request-github
golang.go
ionutvmi.path-autocomplete
letrieu.expand-region
meganrogge.template-string-converter
miguelsolorio.symbols
ms-azuretools.vscode-containers
ms-azuretools.vscode-docker
ms-playwright.playwright
ms-python.debugpy
ms-python.python
ms-python.vscode-pylance
ms-python.vscode-python-envs
ms-vscode-remote.remote-containers
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
ms-vscode-remote.remote-wsl
ms-vscode-remote.vscode-remote-extensionpack
ms-vscode.js-debug-nightly
ms-vscode.makefile-tools
ms-vscode.powershell
ms-vscode.remote-explorer
ms-vscode.remote-server
ms-vscode.vscode-js-profile-flame
ms-vscode.vscode-typescript-next
mtxr.sqltools
mtxr.sqltools-driver-sqlite
premparihar.gotestexplorer
qwtel.sqlite-viewer
redhat.vscode-yaml
ritwickdey.liveserver
rust-lang.rust-analyzer
sainnhe.gruvbox-material
semanticdiff.semanticdiff
sonarsource.sonarlint-vscode
svelte.svelte-vscode
tamasfe.even-better-toml
timonwong.shellcheck
tompollak.lazygit-vscode
tomrijndorp.find-it-faster
unifiedjs.vscode-mdx
usernamehw.errorlens
vitest.explorer
vscodevim.vim
vue.volar
yoavbls.pretty-ts-errors
yzhang.markdown-all-in-one
```

</details>

## export extensions

bash/zsh
```sh
code --list-extensions | sort
```

powershell
```powershell
code --list-extensions | Sort-Object
```

## install (bash/zsh)

edit the list if needed; then run.

```sh
exts=(
  'rust-lang.rust-analyzer'
  <!-- ... -->
)
for e in "${exts[@]}"; do
  echo "installing $e"
  code --install-extension "$e"
done
```

## install (powershell)

edit the list if needed; then run.

```powershell
$exts = @(
  'rust-lang.rust-analyzer',
 # ...
)
foreach ($e in $exts) {
  Write-Host "installing $e"
  code --install-extension $e
}
```
