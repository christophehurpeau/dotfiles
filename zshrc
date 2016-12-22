unsetopt share_history

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='atom'
else
  export EDITOR='nano'
fi

source ~/config-gitted/bash_aliases
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
    local SYSLOAD=$(cut -d " " -f1 /proc/loadavg 2>/dev/null | tr -d '.' || sysctl -n vm.loadavg | cut -d ' ' -f 3 | sed 's/[\.,]//g')
    # System load of the current host.
    echo $((10#$SYSLOAD))       # Convert to decimal.
}

# Returns a color indicating system load.
function load_color()
{
    local SYSLOAD=$(load)
    if [ ${SYSLOAD} -gt ${XLOAD} ]; then
        # echo -en "%F{white}%K{red}"
        echo -n red
    elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
        # echo -en "%F{red}" #${Red}
        echo -n red
    elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
        # echo -en "%B%F{red}" #${BRed}
        echo -n red
    else
        # echo -en "%F{green}" #${Green}
        echo -n green
    fi
}

prompt_date() {
  local SYSLOAD=$(load)
  if [ ${SYSLOAD} -gt ${XLOAD} ]; then
    # echo -en "%F{white}%K{red}"
    prompt_segment white red
  elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
    prompt_segment red black
  elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
    # echo -en "%B%F{red}" #${BRed}
    prompt_segment red black
  else
    # echo -en "%F{green}" #${Green}
    prompt_segment green black
  fi

  echo -n `date +"%H:%M:%S"`
}


# Returns a color according to free disk space in $PWD.
function disk_color()
{
    # No 'write' privilege in the current directory.
    local used=$(command df -P "$PWD" | awk 'END {print $5} {sub(/%/,"")}' | rev | cut -c 2- | rev)
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

    NCPU=`grep -c 'processor' /proc/cpuinfo 2>/dev/null || sysctl -n 'machdep.cpu.core_count'`   # Number of CPUs
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
#

# setopt prompt_subst
# TRAPALRM() {
#     zle reset-prompt
# }
# TMOUT=1


_zsh_empty_command=true
_zsh_command_started=''
magic-enter () {
    zle accept-line
    if [[ -z "${BUFFER##+([[:space:]])}" ]] ; then
        _zsh_empty_command=true
    else
        _zsh_empty_command=false
    fi
}

zle -N magic-enter
bindkey "^M" magic-enter

preexec() {
    if [[ $_zsh_empty_command = false ]] ; then
        _zsh_command_started=$(date +%s)
    fi
}

_zsh_last_current_directory=''
ASYNC_PROC=0
precmd() {
    function async() {
        # save to temp file
        printf "%s" "$(rprompt_cmd)" > "/tmp/zsh_prompt_$$"

        # signal parent
        kill -s USR1 $$
    }

    # do not clear RPROMPT, let it persist

    # kill child if necessary
    if [[ "${ASYNC_PROC}" != 0 ]]; then
        kill -s HUP $ASYNC_PROC >/dev/null 2>&1 || :
    fi

    # add stuff when changing directory
    local current_directory
    current_directory=`pwd`

    RET=$?
    if [[ $_zsh_command_started != '' ]] ; then
        local current_time=$(date +%s)
        if [[ $_zsh_command_started -lt (current_time - 2) ]] || [[ $RET != 0 ]]; then
            local ret_color
            if [ "$color_prompt" = yes ]; then
                if [ $RET = 0 ]; then
                    ret_color="green"
                else
                    ret_color="red"
                fi
            else
                ret_color=""
            fi

            echo -n "\ed$fg[$ret_color]$(date +"%H:%M:%S")$reset_color \$? = $RET"
            echo

            _zsh_command_started=''
        fi
    fi

    if [[ $_zsh_last_current_directory != $current_directory ]] || [[ $_zsh_empty_command = true ]] ; then
        if [ "$color_prompt" = yes ]; then
            echo "$PROMPT_FIRST_LINE$(disk_color)$current_directory$reset_color"
        else
            echo "$PROMPT_FIRST_LINE$current_directory"
        fi

        if [[ $_zsh_last_current_directory != $current_directory ]] ; then
            ls
        fi

        _zsh_last_current_directory="$current_directory"
        _zsh_empty_command=false


        if [[ $_zsh_last_current_directory != $current_directory ]] && [[ -d .git ]] ; then
            echo -n "$fg_bold[magenta]Executing git fetch...\r$reset_color"
            local git_fetch_result=$(git fetch --no-tags --no-recurse-submodules $(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} | sed 's!/! !') 2>/dev/null)
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


    # start background computation
    async &!
    ASYNC_PROC=$!
}

function TRAPUSR1() {
  # read from temp file
  RPROMPT="$(cat /tmp/zsh_prompt_$$)"

  # reset proc number
  ASYNC_PROC=0

  # redisplay
  zle && zle reset-prompt
}


rprompt_cmd() {

}

## Main prompt
build_prompt() {
  if [ "$color_prompt" = yes ]; then
    RETVAL=$?
    prompt_status
    prompt_end
  else
    echo -n "%* %C \$ "
  fi
}

build_rprompt() {
  if [ "$color_prompt" = yes ]; then
    RETVAL=$?
    prompt_git
    prompt_hg
    prompt_date
    prompt_end
    # echo -n "%b%f"
  else
  fi
}

prompt_time_load() {
  # The load segment can have three different states
  local current_state="unknown"
  local cores

  typeset -AH load_states
  load_states=(
    'critical'      'red'
    'warning'       'yellow'
    'normal'        'green'
  )

  if [[ "$OS" == "OSX" ]]; then
    load_avg_1min=$(sysctl vm.loadavg | grep -o -E '[0-9]+(\.|,)[0-9]+' | head -n 1)
    cores=$(sysctl -n hw.logicalcpu)
  else
    load_avg_1min=$(grep -o "[0-9.]*" /proc/loadavg | head -n 1)
    cores=$(nproc)
  fi

  # Replace comma
  load_avg_1min=${load_avg_1min//,/.}

  if [[ "$load_avg_1min" -gt $(bc -l <<< "${cores} * 0.7") ]]; then
    current_state="critical"
  elif [[ "$load_avg_1min" -gt $(bc -l <<< "${cores} * 0.5") ]]; then
    current_state="warning"
  else
    current_state="normal"
  fi

  local time_format="%D{%H:%M:%S}"
  if [[ -n "$POWERLEVEL9K_TIME_FORMAT" ]]; then
    time_format="$POWERLEVEL9K_TIME_FORMAT"
  fi

  "$1_prompt_segment" "${0}_${current_state}" "$2" "${load_states[$current_state]}" "$DEFAULT_COLOR" "$time_format"
}

POWERLEVEL9K_MODE='flat'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status background_jobs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(vcs time_load)

# PROMPT='%{%f%b%k%}$(build_prompt) '
# RPROMPT='%{%f%b%k%}$(build_rprompt)'

source ~/config-gitted/npm_completion
