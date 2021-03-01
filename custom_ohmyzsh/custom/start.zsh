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

isLinux () {
    [ $(uname -s ) = "Linux" ]
}

##############################################
#                Productivity                #
##############################################

alias c=clear

EDITOR=code

## MacOS-like aliases for Linux.
if [ $(isLinux) ]; then
    alias open=xdg-open
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi

# To stop  ZSH auto-correcting i.e. [nyae]
alias test="nocorrect test"

zshrc () {
    ZSHRC="$HOME/.zshrc"
    POWERLEVEL_10K_ZSH="$HOME/.p10k.zsh"
    ZSH_CUSTOM_RC="$ZSH_CUSTOM/start.zsh"
    code --new-window -w "$ZSH_CUSTOM_RC" "$POWERLEVEL_10K_ZSH" "$ZSHRC" && \
        purple "Finished editing, source'ing ~/.zshrc..." \
        && . $ZSHRC
}

poretitioner () {
    pushd $HOME/Developer/poretitioner
}

# gitlab-runner () {
#     # -d --rm -t -i
#     docker run gitlab/gitlab-runner $@
# }
# -p "${GITLAB_RUNNER_BUILD_PORT}:${GITLAB_RUNNER_BUILD_PORT}" 

gitlab-runner-register () {
    docker run -it -v gitlab-runner-config:/etc/gitlab-runner/config.toml gitlab/gitlab-runner:latest register --run-untagged --config "$RUNNER_GITLAB_CONFIG_PATH"   --non-interactive  --url "https://gitlab.cs.washington.edu/" --tag-list ubuntu,jdunstan,vm,jdunstan-vm,ubuntu-vm --executor "docker" --docker-image "nixos/nix:latest" $@
  # --registration-token "hACNWtkLWLtksyWsP8Cv" \
}

gitlab-runner-init () {
    docker --debug run -p "$RUNNER_GITLAB_PORT_ROUTING_ARG" --name gitlab-runner --volume /var/run/docker.sock:/var/run/docker.sock --volume gitlab-runner-config:$RUNNER_GITLAB_CONFIG_PATH gitlab/gitlab-runner:latest --debug $@
}


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
#POWERLEVEL10K_LEFT_PROMPT_ELEMENTS=(nix_shell)
main
