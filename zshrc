unsetopt share_history

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='subl'
else
  export EDITOR='nano'
fi

source ~/.bash_aliases



#-------------------------------------------------------------
# Test colors
#-------------------------------------------------------------

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
    screen*) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi
unset force_color_prompt


#-------------------------------------------------------------
# Functions systems infos
#-------------------------------------------------------------

# Returns system load as percentage, i.e., '40' rather than '0.40)'.
function load()
{
    local SYSLOAD=$(cut -d " " -f1 /proc/loadavg | tr -d '.')
    # System load of the current host.
    echo $((10#$SYSLOAD))       # Convert to decimal.
}

# Returns a color indicating system load.
function load_color()
{
    local SYSLOAD=$(load)
    if [ ${SYSLOAD} -gt ${XLOAD} ]; then
        echo -en "$fg_bold[white]$bg[red]"
    elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
        echo -en "$fg[red]" #${Red}
    elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
        echo -en "$fg_bold[red]" #${BRed}
    else
        echo -en "$fg[green]" #${Green}
    fi
}

# Returns a color according to free disk space in $PWD.
function disk_color()
{
    # No 'write' privilege in the current directory.
    local used=$(command df -P "$PWD" |
               awk 'END {print $5} {sub(/%/,"")}')
    if [ ${used} -gt 95 ]; then
        echo -en "$fg_bold[white]$bg[red]"           # Disk almost full (>95%).
    elif [ ${used} -gt 90 ]; then
        echo -en "$fg_bold[red]"            # Free disk space almost gone.
    else
        echo -en "$fg_bold[blue]"           # Free disk space is ok.
    fi
}

# Returns a color according to running/suspended jobs.
function job_color()
{
    if [ $(jobs -s | wc -l) -gt "0" ]; then
        echo -en "$fg_bold[red]"
    elif [ $(jobs -r | wc -l) -gt "0" ] ; then
        echo -en "$fg_bold[magenta]"
    fi
}

function writable_color(){
    if [[ -w "${PWD}" ]]; then
        echo -en "$fg_bold[black]"
    elif [ -s "${PWD}" ] ; then
        echo -en "$fg[red]"
    else
        echo -en "$fg[cyan]"
        # Current directory is size '0' (like /proc, /sys etc).
    fi
}



# Repositories : GIT

_escape(){
    printf "%q" "$*"
}

repositoryStatus() {
#    command git fetch  2>/dev/null

    # https://github.com/magicmonty/bash-git-prompt
    # https://github.com/nojhan/liquidprompt/blob/master/liquidprompt

    local gitdir
    gitdir="$(git rev-parse --git-dir 2>/dev/null)"
    [[ $? -ne 0 || ! $gitdir =~ (.*\/)?\.git.* ]] && return
    local branch="$(git symbolic-ref HEAD 2>/dev/null)"
    if [[ $? -ne 0 || -z "$branch" ]] ; then
        # In detached head state, use commit instead
        branch="$(git rev-parse --short HEAD 2>/dev/null)"
    fi
    [[ $? -ne 0 || -z "$branch" ]] && return
    branch="${branch#refs/heads/}"
    branch=$(_escape "$branch")

    local marks=''
    local stats=`git diff --numstat 2>/dev/null | awk 'NF==3 {plus+=$1; minus+=$2} END {printf("+%d/-%d\n", plus, minus)}'`
    if [[ $stats == "+0/-0" ]]; then
        stats="%{$fg_no_bold[white]%}$stats%{$reset_color%}"
    else
        stats="%{$fg_no_bold[yellow]%}$stats%{$reset_color%}"
    fi

    local stash
    stasj=$(git stash list 2>/dev/null)
    local git_status
    git_status=$(command git status --porcelain -b 2> /dev/null)
    if [[ ! -z "$stash" ]] ; then
        marks="${marks}%"
    fi
    if $(echo "$git_status" | grep '^## .*ahead' &> /dev/null); then
        marks="${marks}%{$fg_bold[red]↑$reset_color%}"
    fi
    if $(echo "$git_status" | grep '^## .*behind' &> /dev/null); then
        marks="${marks}%{$fg_bold[red]↓$reset_color%}"
    fi

    echo -n " %{$fg_bold[green]%}["
    echo -n "$branch$(parse_git_dirty) $stats"
    if [[ -n "$marks" ]] ; then
        echo -n " $marks"
    fi
    echo -n "%{$fg_bold[green]%}]%{$reset_color%}"
}


#-------------------------------------------------------------
# Colorfull Terminal
#-------------------------------------------------------------
# http://tldp.org/LDP/abs/html/sample-bashrc.html

if [ "$color_prompt" = yes ]; then
    # Test connection type:
    #if [ -n "${SSH_CONNECTION}" ]; then
    _ps_ssh_connection=$(who am i | sed -n 's/.*(\(.*\))/\1/p')

    if [[ -z "$_ps_ssh_connection" || "$_ps_ssh_connection" = ":"* ]] ; then
        CNX="$fg_bold[green]"        # Connected on local machine.
    else
        CNX="$fg_bold[red]"        # Connected on remote machine, via ssh
    fi

    # Test user type:
    if [[ ${USER} == "root" ]]; then
        SU="$fg_bold[red]"           # User is root.
    elif [[ ${USER} != $(logname) ]]; then
        SU="$fg[red]"          # User is not login user.
    elif [[ -z "$_ps_ssh_connection" || "$_ps_ssh_connection" = ":"* ]] ; then
        # User is normal (well ... most of us are).
        SU="$fg_bold[magenta]"
    else
        SU="$fg_bold[green]"
    fi

    NCPU=$(grep -c 'processor' /proc/cpuinfo)    # Number of CPUs
    SLOAD=$(( 100*${NCPU} ))        # Small load
    MLOAD=$(( 200*${NCPU} ))        # Medium load
    XLOAD=$(( 400*${NCPU} ))        # Xlarge load

    PROMPT_FIRST_LINE='' #'${debian_chroot:+($debian_chroot)}'
    # User@Host (with connection type info):
    #PROMPT_FIRST_LINE=${PROMPT_FIRST_LINE}"%{$SU%}%n%{$reset_color$fg_bold[black]%}@%{$CNX%}%m%{$(writable_color)%}:%{$reset_color"
    PROMPT_FIRST_LINE=${PROMPT_FIRST_LINE}"$SU$(whoami)$reset_color$fg_bold[black]@$CNX$(hostname -s)$(writable_color):$reset_color"
    # PWD (with 'disk space' info): /// \W : last folder; \w: full path
    #PROMPT_FIRST_LINE=${PROMPT_FIRST_LINE}"$(disk_color)%~%{$reset_color%} "
    # see prompt first line PROMPT_FIRST_LINE=${PROMPT_FIRST_LINE}"$(disk_color)$(pwd)$reset_color"
else
    # PROMPT_FIRST_LINE='${debian_chroot:+($debian_chroot)}%n@%m:%~ \$ '
    PROMPT_FIRST_LINE='$(whoami)@$(hostname -s):$(pwd) '
fi




#-------------------------------------------------------------
# PROMPT
#-------------------------------------------------------------
_zsh_last_current_directory=''
prompt_first_line () {
    local current_directory
    current_directory=`pwd`
    if [[ $_zsh_last_current_directory != $current_directory ]] ; then
        _zsh_last_current_directory="$current_directory"

        if [ "$color_prompt" = yes ]; then
                echo "$PROMPT_FIRST_LINE$(disk_color)$(pwd)$reset_color"
        else
            echo "$PROMPT_FIRST_LINE$(pwd)"
        fi

        if [[ -d .git ]] ; then
            echo -n "Executing git fetch...\r"
            local git_fetch_result=$(git fetch 2>/dev/null)
            echo -n "                      \r"
            if [[ -n "$git_fetch_result" ]] ; then
                echo $git_fetch_result
            fi
            git st 2>/dev/null
        fi
    fi

    if [[ "$TERM" == "screen" ]]; then
        local CMD=${1[(wr)^(*=*|sudo|-*)]}
        echo -ne "\ek$CMD\e\\"
    fi
}
precmd() {
    prompt_first_line
}


# PROMPT="\$(prompt_first_line)"
PROMPT=""

if [ "$color_prompt" = yes ]; then
    # Time of day (with load info):
    PROMPT=${PROMPT}"%{\$(load_color)%}%*%{$reset_color%}"
    # Folder name
    PROMPT=${PROMPT}" %{\$(disk_color)%}%C%{$reset_color%}"
    # Repository status
    PROMPT=${PROMPT}"\$(repositoryStatus)"
    # Prompt (with 'job' info):
    PROMPT=${PROMPT}" %{\$(job_color)%}\$%{$reset_color%} "
else
    PROMPT=${PROMPT}"%* %C \$ "
fi
