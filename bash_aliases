#/bin/bash

alias mkdir='mkdir -p'

# ls
alias la='ls -la'
alias ll='ls -l'

# cd 
alias ~="cd ~"
alias u='cd ../'
alias uu='cd ../../'
alias uuu='cd ../../../'
alias uuuu='cd ../../../../'

# modernized tools
if command -v exa &> /dev/null
then
  alias l='exa -h'
  alias ls='exa -h'
  alias la='exa -ah'
  alias ll='exa -lh'
fi

if command -v bat &> /dev/null
then
  alias cat='bat'
fi


# Git Aliases
alias gd="git diff"
alias gdc="git diff --cached"
alias gcl='git clone'
alias ga='git add'
alias gall='git add .'
alias g='git'
alias gs='git status'
alias gss='git status -s'
alias gl='git pull'
alias gpr='git pull --rebase'
alias gpp='git pull && git push'
alias gup='git fetch && git rebase'
alias gp='git push'
alias gpo='git push origin'
alias gdv='git diff -w "$@" | vim -R -'
alias gc='git commit -v'
alias gca='git commit --amend'
alias gcm='git commit -v -m'
alias gsh="git show"
alias gb='git branch'
alias gcp='git cherry-pick'
alias gco='git checkout'
alias gll='git log --graph --pretty=oneline --abbrev-commit'
alias gg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
gpuo() {
    git push -u origin $(git rev-parse --abbrev-ref HEAD)
}
alias gcob='gco -b"
alias gcan="gca --no-edit"


# apt
alias ud='sudo apt update && sudo apt upgrade'
alias ar='sudo apt autoremove'

# Pacman alias examples
alias pacupg='sudo pacman -Syu'		# Synchronize with repositories and then upgrade packages that are out of date on the local system.
alias pacin='sudo pacman -S'		# Install specific package(s) from the repositories
alias pacins='sudo pacman -U'		# Install specific package not from the repositories but from a file 
alias pacre='sudo pacman -R'		# Remove the specified package(s), retaining its configuration(s) and required dependencies
alias pacrem='sudo pacman -Rns'		# Remove the specified package(s), its configuration(s) and unneeded dependencies
alias pacrep='pacman -Si'		# Display information about a given package in the repositories
alias pacreps='pacman -Ss'		# Search for package(s) in the repositories
alias pacloc='pacman -Qi'		# Display information about a given package in the local database
alias paclocs='pacman -Qs'		# Search for package(s) in the local database
alias paclo="pacman -Qdt"		# List all packages which are orphaned
alias pacc="sudo pacman -Scc"		# Clean cache - delete all not currently installed package files
alias paclf="pacman -Ql"		# List all files installed by a given package
alias pacexpl="pacman -D --asexp"	# Mark one or more installed packages as explicitly installed 
alias pacimpl="pacman -D --asdep"	# Mark one or more installed packages as non explicitly installed

# '[r]emove [o]rphans' - recursively remove ALL orphaned packages
alias pacro="pacman -Qtdq > /dev/null && sudo pacman -Rns \$(pacman -Qtdq | sed -e ':a;N;$!ba;s/\n/ /g')"

# Additional pacman alias examples
alias pacupd='sudo pacman -Sy && sudo abs'         # Update and refresh the local package and ABS databases against repositories
alias pacinsd='sudo pacman -S --asdeps'            # Install given package(s) as dependencies
alias pacmir='sudo pacman -Syy'                    # Force refresh of all package lists after updating /etc/pacman.d/mirrorlistwq

# vim aliases
alias vimj='vim *.java'
alias vimp='vim *.py'

# scrot aliases
alias scrn='scrot -m -c -d 5 ~/pictures/screenshots'
alias scrs='scrot -s ~/pictures/screenshots'

# vim-like exit
# alias :q='exit'
