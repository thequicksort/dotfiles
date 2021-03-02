##############################################
#      Color-coordinated status reporting.   #
##############################################

NORMAL=$(tput sgr0)

export GITLAB_RUNNER_BUILD_PORT="8093"
export RUNNER_GITLAB_PORT_ROUTING_ARG="${GITLAB_RUNNER_BUILD_PORT}:${GITLAB_RUNNER_BUILD_PORT}"
export RUNNER_GITLAB_CONFIG_PATH=$HOME/.gitlab-runner/config.toml

##############################################
#              Fluff and Stuff               #
##############################################

# Nix ZSH completions https://github.com/spwhitt/nix-zsh-completions

# Doing this lets me print my affirmations.

bold () {
    local BOLD=$(tput bold)
    echo -e "$BOLD$*$NORMAL"
}

purple () {
    local PURPLE=$(tput setaf 129; tput bold)
    echo -e "$PURPLE$*$NORMAL"
}

violet () {
    local VIOLET=$(tput setaf 122; tput bold)
    echo -e "$VIOLET$*$NORMAL"
}

affirmations () {
    purple "I love you. I love your life. I love you so much."
    violet "I love myself. I love my life. The world is better with me in it."
}


##############################################
#                OS Utilities                #
##############################################


DEVELOPER_DIRECTORY=$HOME/Developer
GITHUB_DIRECTORY=$DEVELOPER_DIRECTORY/github

isLinux () {
    [ $(uname -s ) = "Linux" ]
}

##############################################
#                Mac-To-Linux                #
##############################################

## MacOS-like aliases for Linux.
if [ $(isLinux) ]; then
    alias open=xdg-open
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi

# # Allow Touch-ID authentication for sudo.
sudo () {
    unset -f sudo
    if [[ "$(uname)" == 'Darwin' ]] && ! grep 'pam_tid.so' /etc/pam.d/sudo --silent; then
      sudo sed -i -e '1s;^;auth       sufficient     pam_tid.so\n;' /etc/pam.d/sudo
    fi
    sudo "$@"
  }

##############################################
#                Hackintosh                  #
##############################################

HACKINTOSH_DIR=$GITHUB_DIRECTORY/hackintosh/

# Get the Mount EFI command.
MOUNT_EFI_COMMAND=$HACKINTOSH_DIR/MountEFI.command
if [ -x  MOUNT_EFI_COMMAND ]; then
    alias mountefi=$MOUNT_EFI_COMMAND
fi


##############################################
#                Productivity                #
##############################################

alias c=clear

export EDITOR="$(whence code) --new-window --wait"

# To stop  ZSH auto-correcting i.e. [nyae]
alias test="nocorrect test"

# Chezmoi does not allow git submodules, so we have to manually update Oh My ZSH, as well as its plugins and themes.
chezmoi_update_all () {
    # Update Oh My ZSH
    OH_MY_ZSH_GITHUB_SOURCE=https://github.com/robbyrussell/oh-my-zsh/archive/master.tar.gz
    OH_MY_ZSH_DEST=/tmp/oh-my-zsh-master.tar.gz
    touch $OH_MY_ZSH_DEST
    echo "Donwloading Oh my zsh from $OH_MY_ZSH_GITHUB_SOURCE"
    curl -L -o $OH_MY_ZSH_DEST  $OH_MY_ZSH_GITHUB_SOURCE&& \
        chezmoi import --strip-components 1 --destination ${HOME}/.oh-my-zsh $OH_MY_ZSH_DEST

    # Update Powerlevel 10K Theme
    P10K_GITHUB_SOURCE=https://github.com/romkatv/powerlevel10k/archive/master.tar.gz
    P10K_DEST=/tmp/p10k.tar.gz
    touch $P10K_DEST
    echo "Donwloading P10K from $P10K_GITHUB_SOURCE"
    curl -L -o $P10K_DEST $P10K_GITHUB_SOURCE && \
        chezmoi import --strip-components 1 --destination $ZSH_CUSTOM/themes/ $P10K_DEST

    # Update Nix shell plugin
    ZSH_NIX_SHELL_GITHUB_SOURCE=https://github.com/chisui/zsh-nix-shell/archive/master.tar.gz
    ZSH_NIX_SHELL_DEST=/tmp/zsh-nix-shell.tar.gz
    touch $ZSH_NIX_SHELL_DEST
    echo "Donwloading P10K from $ZSH_NIX_SHELL_GITHUB_SOURCE"
    curl -L -o $ZSH_NIX_SHELL_DEST $ZSH_NIX_SHELL_GITHUB_SOURCE && \
        chezmoi import --strip-components 1 --destination $ZSH_CUSTOM/plugins/ $ZSH_NIX_SHELL_DEST
}

# Quickly edit your dotfiles.
zshrc () {
    ZSHRC="$HOME/.zshrc"
    POWERLEVEL_10K_ZSH="$HOME/.p10k.zsh"
    ZSH_CUSTOM_RC="$ZSH_CUSTOM/start.zsh"
    NIX_GOODIES="$HOME/.ALL_THE_GOODIES.nix"

    FILES=($ZSH_CUSTOM_RC $POWERLEVEL_10K_ZSH $NIX_GOODIES $ZSHRC)
    if [ -x $(whence chezmoi) ]; then
        purple "Using Chezmoi"
        chezmoi edit --prompt --apply $FILES
    else
        # Don't have Chezmoi installed, just edit things.
        code --new-window -w $FILES && \
            purple "Finished editing, source'ing ~/.zshrc..." \
            && . $ZSHRC
    fi
}

poretitioner () {
    pushd $HOME/Developer/poretitioner
}

# # gitlab-runner () {
# #     # -d --rm -t -i
# #     docker run gitlab/gitlab-runner $@
# # }
# # -p "${GITLAB_RUNNER_BUILD_PORT}:${GITLAB_RUNNER_BUILD_PORT}" 

# gitlab-runner-register () {
#     docker run -it -v gitlab-runner-config:/etc/gitlab-runner/config.toml gitlab/gitlab-runner:latest register --run-untagged --config "$RUNNER_GITLAB_CONFIG_PATH"   --non-interactive  --url "https://gitlab.cs.washington.edu/" --tag-list ubuntu,jdunstan,vm,jdunstan-vm,ubuntu-vm --executor "docker" --docker-image "nixos/nix:latest" $@
#   # --registration-token "hACNWtkLWLtksyWsP8Cv" \
# }

# gitlab-runner-init () {
#     docker --debug run -p "$RUNNER_GITLAB_PORT_ROUTING_ARG" --name gitlab-runner --volume /var/run/docker.sock:/var/run/docker.sock --volume gitlab-runner-config:$RUNNER_GITLAB_CONFIG_PATH gitlab/gitlab-runner:latest --debug $@
# }


kill-debugger () {
    lsof -iTCP:5678 | awk -F" " 'NR>1{ print $2 }' | \
    xargs sh -c 'if [ -n $1 ]; then echo \"Killing process PID $1\" && kill -9 "$1"; else echo "Nothing listening on port"; fi' $0 $1
}

alias killd=kill-debugger

##############################################
#                     Nix                    #
##############################################

# TODO: Replace with Nox
nix-has () {
    nix-env -qa | grep $1
}

##############################################
#                     Main                   #
##############################################

main () {
    #affirmations
    #poretitioner
    #prompt_nix_shell_setup "$@"
}

main
