## curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-aliases.sh | bash

echo '
alias l="ls -al"
alias psg="ps xau | grep "
alias h="history"
alias tf="tail -f"
alias tma="tmux attach"
alias fgi="find . | grep -i "
alias fg="find . | grep "
alias docp="docker ps"
alias docr="docker run"
alias doc="docker"
' > ~/.bash_aliases
