git config --global alias.undo 'reset --soft HEAD~1'

git config --global alias.lg 'log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

git config --global alias.s 'status -s'

git config --global alias.last 'log -1 HEAD --stat'

git config --global alias.discard 'checkout -- .'

git config --global alias.ac '!git add -A && git commit -m'

git config --global alias.undo-first 'update-ref -d HEAD'

Write-Host "Git aliases have been successfully configured!"
