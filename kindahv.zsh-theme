# Configuration variables
local COLOR_RED="%{$fg[red]%}"
local COLOR_GREEN="%{$fg[green]%}"
local COLOR_BLUE="%{$fg[blue]%}"
local COLOR_YELLOW="%{$fg[yellow]%}"
local COLOR_GRAY="\033[90m"
local COLOR_RESET="%{$reset_color%}"
local COLOR_RESET_ANSI="\033[0m"
local COLOR_GREEN_ANSI="\033[32m"
local COLOR_YELLOW_ANSI="\033[33m"
local COLOR_RED_ANSI="\033[31m"

local SYMBOL_TIME="⏱"
local SYMBOL_ERROR="↵"
local SYMBOL_DIRTY="●"
local SYMBOL_USER='%(!.#.$)'
local SYMBOL_BRANCH_PREFIX="‹"
local SYMBOL_BRANCH_SUFFIX="›"
local SYMBOL_SEPARATOR="─"
local SYMBOL_CORNER="└"

local TIME_THRESHOLD_MS=100
local TIME_THRESHOLD_MS_WARN=500
local TIME_THRESHOLD_SEC=3

local user_host="%B%(!.${COLOR_RED}.${COLOR_GREEN})%n@%m${COLOR_RESET} "
local current_dir="%B${COLOR_BLUE}%~ ${COLOR_RESET}"
local return_code="%(?..${COLOR_RED}%? ${SYMBOL_ERROR}${COLOR_RESET})"
local conda_prompt='$(conda_prompt_info)'
local vcs_branch='$(git_prompt_info)$(hg_prompt_info)'
local rvm_ruby='$(ruby_prompt_info)'
local venv_prompt='$(virtualenv_prompt_info)'

if [[ "${plugins[@]}" =~ 'kube-ps1' ]]; then
    local kube_prompt='$(kube_ps1)'
else
    local kube_prompt=''
fi

ZSH_THEME_RVM_PROMPT_OPTIONS="i v g"

ZSH_THEME_GIT_PROMPT_PREFIX="${COLOR_YELLOW}${SYMBOL_BRANCH_PREFIX}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${SYMBOL_BRANCH_SUFFIX} ${COLOR_RESET}"
ZSH_THEME_GIT_PROMPT_DIRTY="${COLOR_RED}${SYMBOL_DIRTY}${COLOR_YELLOW}"
ZSH_THEME_GIT_PROMPT_CLEAN="${COLOR_YELLOW}"

ZSH_THEME_HG_PROMPT_PREFIX="$ZSH_THEME_GIT_PROMPT_PREFIX"
ZSH_THEME_HG_PROMPT_SUFFIX="$ZSH_THEME_GIT_PROMPT_SUFFIX"
ZSH_THEME_HG_PROMPT_DIRTY="$ZSH_THEME_GIT_PROMPT_DIRTY"
ZSH_THEME_HG_PROMPT_CLEAN="$ZSH_THEME_GIT_PROMPT_CLEAN"

ZSH_THEME_RUBY_PROMPT_PREFIX="${COLOR_RED}${SYMBOL_BRANCH_PREFIX}"
ZSH_THEME_RUBY_PROMPT_SUFFIX="${SYMBOL_BRANCH_SUFFIX} ${COLOR_RESET}"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="${COLOR_GREEN}${SYMBOL_BRANCH_PREFIX}"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="${SYMBOL_BRANCH_SUFFIX} ${COLOR_RESET}"
ZSH_THEME_VIRTUALENV_PREFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX"
ZSH_THEME_VIRTUALENV_SUFFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"

PROMPT="┌─${conda_prompt}${user_host}${current_dir}${rvm_ruby}${vcs_branch}${venv_prompt}${kube_prompt}
${SYMBOL_CORNER}─%B${SYMBOL_USER}%b "
RPROMPT=''

_command_time_preexec() {
    _command_start_time=$EPOCHREALTIME
    _executed_command="$1"
}

_command_time_precmd() {
    local exit_code=$?
    if [[ -n $_command_start_time ]]; then
        local elapsed=$(( EPOCHREALTIME - _command_start_time ))
        unset _command_start_time

        if [[ "$_executed_command" =~ ^clear($|[[:space:]]) ]]; then
            unset _executed_command
            return
        fi

        unset _executed_command

        local formatted_time
        if (( elapsed < 1 )); then
            formatted_time=$(printf "%.0fms" $(( elapsed * 1000 )))
        elif (( elapsed < 60 )); then
            formatted_time=$(printf "%.1fs" $elapsed)
        elif (( elapsed < 3600 )); then
            local minutes=$(( elapsed / 60 ))
            local seconds=$(( elapsed % 60 ))
            formatted_time=$(printf "%dm%.0fs" $minutes $seconds)
        else
            local hours=$(( elapsed / 3600 ))
            local minutes=$(( (elapsed % 3600) / 60 ))
            local seconds=$(( elapsed % 60 ))
            formatted_time=$(printf "%dh%dm%.0fs" $hours $minutes $seconds)
        fi

        local time_value=$(echo $formatted_time | sed 's/[^0-9.]//g')
        local time_unit=$(echo $formatted_time | sed 's/[0-9.]//g')

        local color
        case $time_unit in
            ms)
                if (( time_value < TIME_THRESHOLD_MS )); then
                    color="$COLOR_GREEN_ANSI"
                elif (( time_value < TIME_THRESHOLD_MS_WARN )); then
                    color="$COLOR_YELLOW_ANSI"
                else
                    color="$COLOR_RED_ANSI"
                fi
                ;;
            s)
                if (( time_value < TIME_THRESHOLD_SEC )); then
                    color="$COLOR_YELLOW_ANSI"
                else
                    color="$COLOR_RED_ANSI"
                fi
                ;;
            *)
                color="$COLOR_RED_ANSI"
                ;;
        esac

        local cols=$(tput cols)
        local time_display=" ${SYMBOL_TIME} ${formatted_time}"
        local error_display=""

        if (( exit_code != 0 )); then
            error_display=" ${exit_code} ${SYMBOL_ERROR}"
        fi

        local status_display="${error_display}${time_display}"
        local status_length=${#status_display}
        local separator_length=$((cols - status_length - 1))

        local separator=""
        for ((i=1; i<=separator_length; i++)); do
            separator+="$SYMBOL_SEPARATOR"
        done

        printf "\033[s"
        printf "\033[1G"
        if (( exit_code != 0 )); then
            printf "${COLOR_GRAY}%s${COLOR_RESET_ANSI}${COLOR_RED_ANSI}%s${COLOR_RESET_ANSI}${color}%s${COLOR_RESET_ANSI}" "$separator" "$error_display" "$time_display"
        else
            printf "${COLOR_GRAY}%s${COLOR_RESET_ANSI}${color}%s${COLOR_RESET_ANSI}" "$separator" "$time_display"
        fi
        printf "\033[u"
        echo
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _command_time_preexec
add-zsh-hook precmd _command_time_precmd
