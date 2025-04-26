git config --global alias.st 'status'
git config --global alias.s 'status -s'
git config --global alias.br 'branch'
git config --global alias.cm 'commit'
git config --global alias.co 'checkout'
git config --global alias.re 'restore'
git config --global alias.sw 'switch'
git config --global alias.pick 'cherry-pick'

git config --global alias.undo 'reset --soft HEAD~1'
git config --global alias.uncommit 'reset --soft HEAD^'
git config --global alias.amend 'commit --amend'
git config --global alias.nuke 'reset --hard'
git config --global alias.discard 'checkout -- .'
git config --global alias.unstage 'reset HEAD --'
git config --global alias.revertfile 'checkout --'
git config --global alias.purge 'clean -fd'
git config --global alias.undo-first 'update-ref -d HEAD'

git config --global alias.cob 'checkout -b'
git config --global alias.trim '!f() { git branch | grep -v "main" | grep -v "master" | grep -v "^*" | xargs git branch -D; git remote prune origin; }; f'

git config --global alias.lg 'log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
git config --global alias.last 'log -1 HEAD --stat'
git config --global alias.ls 'log --oneline'
git config --global alias.smartlog "log --graph --pretty=format:'commit: %C(bold red)%h%Creset %C(red)<%H>%Creset %C(bold magenta)%d %Creset%ndate: %C(bold yellow)%cd %Creset%C(yellow)%cr%Creset%nauthor: %C(bold blue)%an%Creset %C(blue)<%ae>%Creset%n%C(cyan)%s%n%Creset'"
git config --global alias.sl '!git smartlog'
git config --global alias.me "!git smartlog --author='$(git config user.name)'"
git config --global alias.log-commit "log -1 --pretty=format:'commit: %C(bold red)%h%Creset %C(red)<%H>%Creset %C(bold magenta)%d %Creset%ndate: %C(bold yellow)%cd %Creset%C(yellow)%cr%Creset%nauthor: %C(bold blue)%an%Creset %C(blue)<%ae>%Creset%n%n%C(bold cyan)%s%n%n%C(cyan)%b%n%Creset'"
git config --global alias.logcm '!git log-commit'

git config --global alias.authors-list 'shortlog -e -s -n'
git config --global alias.authors-count 'shortlog -s -n'

git config --global alias.aliases '!f() { git config --global -l | grep alias | sort; }; f'
git config --global alias.find '!f() { git ls-files | grep "$1"; }; f'
git config --global alias.today '!git log --since=midnight --author="$(git config user.name)" --oneline'
git config --global alias.standup '!git log --since="yesterday" --author="$(git config user.name)" --pretty=format:"%Cred%h%Creset - %s %Cgreen(%cr)%Creset"'

Write-Host "Git aliases have been successfully configured!"
Write-Host "Type 'git aliases' to see all available aliases."
