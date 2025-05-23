# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
#ps -aux | grep alternating_layouts.py 

#kill `ps -aux | grep alternating_layouts.py | awk '{print $2}'` && /home/sanket/.config/i3/scripts/alternating_layouts.py
#VAR1=$(ps -aux | grep alternating_layouts.py | awk '{print $12; exit}')
#VAR2="/home/sanket/.config/i3/scripts/alternating_layouts.py"
#if [[ "$VAR1" != "$VAR2" ]]
#then
  #/home/sanket/.config/i3/scripts/alternating_layouts.py & 
  #disown
#fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export GOPRIVATE=github.com/uptycs,github.com/Uptycs
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL10K_MODE="nerdfont-complete"

source ~/.zplug/init.zsh
zplug "b4b4r07/enhancd", use:init.sh
zplug load

copy(){
    xsel -b < ./$1
}

#eval `ssh-agent -s` &>/dev/null
#ssh-add &>/dev/null
export VAULT_KEY_STORE_PASSWORD='ops#gambit'
echo 'UptycsPune1999@' | sudo -S ls /home/sanket/empty > /dev/null 2>&1

alias vpnConnect='python3 ~/gitlocal/vpn/vpn_connect.py > /home/sanket/gitlocal/vpn/login.conf && echo UptycsPune1999@ | sudo -S openvpn --config ~/gitlocal/vpn/amrut.ovpn --auth-user-pass ~/gitlocal/vpn/login.conf'
#alias vpnDisconnect='echo root | sudo -S systemctl stop openvpn@amrut'
#alias vpnStatus='echo root | sudo -S systemctl status openvpn@amrut'
#alias vpnReload='echo root | sudo -S systemctl stop openvpn@amrut && echo root | sudo -S systemctl start openvpn@amrut'
alias q='exit'
alias v='nvim'
alias vim='nvim'
alias vi='nvim'
alias t='terminator'
alias python='python3'
alias update='sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt autoclean'
alias install='sudo apt install'
#alias execpg='docker exec -it postgres psql -U postgres'
alias execpg='pgcli -h 0.0.0.0  -U postgres --auto-vertical-output '
alias backuppg='docker exec -it postgres pg_dumpall -U postgres > /home/sanket/gitlocal/pgdump/pg_dump_all'
alias restorepg='docker exec -it postgres -U postgres psql -f /home/sanket/gitlocal/pgdump/pg_dump_all postgres'
alias cdcl='cd /home/sanket/gitlocal/uptycs/cloud'
#configdb   
#insightsdb 
#metastoredb
#postgres   
#rangerdb   
#statedb    
#template0  
#template1  


alias sdev='/home/sanket/gitlocal/uptycs/cloud/utilities/startDev.sh && docker stop ingestion'
alias epSubmit='spark-submit  --num-executors 1 --driver-memory 1024m --executor-memory 512m --executor-cores 8 --deploy-mode cluster     --conf "spark.cores.max=10"     --conf "${DRIVER_OPTS}"     --conf "spark.executor.extraClassPath=${UPTYCS_HOME}/cloud/effective-permissions/config/"     --conf "spark.yarn.submit.waitAppCompletion"=true     --master spark://sanket-Precision-3571:7077 --class com.uptycs.EffectivePermissions ${UPTYCS_HOME}/cloud/effective-permissions/target/ep_shaded.jar --spring.config.location=${UPTYCS_HOME}/cloud/effective-permissions/config/application.properties'
alias epSubmitLatest='mvn clean install && spark-submit  --num-executors 1 --driver-memory 1024m --executor-memory 512m --executor-cores 8 --deploy-mode cluster     --conf "spark.cores.max=10"     --conf "${DRIVER_OPTS}"     --conf "spark.executor.extraClassPath=${UPTYCS_HOME}/cloud/effective-permissions/config/"     --conf "spark.yarn.submit.waitAppCompletion"=true     --master spark://sanket-Precision-3571:7077 --class com.uptycs.EffectivePermissions ${UPTYCS_HOME}/cloud/effective-permissions/target/ep_shaded.jar --spring.config.location=${UPTYCS_HOME}/cloud/effective-permissions/config/application.properties'

alias ss='/home/sanket/gitlocal/uptycs/cloud/scripts/status'
alias sr='/home/sanket/gitlocal/uptycs/cloud/scripts/reload'
alias st='/home/sanket/gitlocal/uptycs/cloud/scripts/stop'

#export UPTYCS_PM2_FILE="/home/sanket/gitlocal/query_pm2_no_cq.json"
export UPTYCS_PM2_FILE="/home/sanket/gitlocal/query_pm2.json"
export PATH=$PATH:/home/sanket/.local/bin
export PATH=$PATH:/home/sanket/Downloads/lua-language-server-3.5.0-linux-x64/bin

run(){
       case $1 in 
           *.cpp)   g++ -std=c++17 -Wshadow -Wall $1 -o a.out -g -fsanitize=address -fsanitize=undefined -D_GLIBCXX_DEBUG  && time ./a.out ;;
           *.cpp) g++ -std=c++17 -Wshadow -Wall $1 -o a.out -O2 -Wno-unused-result && time ./a.out ;;
           *)   echo "'$1' cannot be compiles & run";;
       esac 
}

frun(){
       case $1 in 
           *.cpp) g++ -std=c++17 -Wshadow -Wall $1 -o a.out -O2 -Wno-unused-result && time ./a.out ;;
           *)   echo "'$1' cannot be compiles & run";;
       esac 
}

#if [ -f ~/.ssh/agent.env ] ; then
    #. ~/.ssh/agent.env > /dev/null
    #if ! kill -0 $SSH_AGENT_PID > /dev/null 2>&1; then
        #echo "Stale agent file found. Spawning a new agent. "
        #eval `ssh-agent | tee ~/.ssh/agent.env`
        #ssh-add
    #fi
#else
    #echo "Starting ssh-agent"
    #eval `ssh-agent | tee ~/.ssh/agent.env`
    #ssh-add
#fi





##UPTYCS
export UPTYCS_HOME="/home/sanket/gitlocal/uptycs"
export UPTYCS_WEB_HOME="/home/sanket/gitlocal/uptycs-web"
export UPTYCS_USER="stupe"
export ARTIFACTS_HOME="/home/sanket/gitlocal/artifacts"
export UPTYCS_HELP_HOME="/home/sanket/gitlocal/uptycs-help"
export ASK_UPTYCS_HOME="/home/sanket/gitlocal/ask-uptycs"
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/sanket/go/bin
export DRIVER_OPTS="spark.driver.extraJavaOptions= -Dlog.name=stsDetection -Duptycs.home=${UPTYCS_HOME} -Dlog4j.configuration=file://${UPTYCS_HOME}/cloud/effective-permissions/config/log4j.properties -Dcluster.id=default_cluster"
export CONFIG_DIR="/home/sanket/gitlocal/config"
export CONFIG_HOME="${CONFIG_DIR}/generated_files/localhost"


alias relogindocker='$(aws ecr get-login --region us-east-1 --profile uptycs-dev --no-include-email --registry-ids 267292272963)'
alias reloginecr='aws-google-auth -p uptycs-dev -k'

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    #git
    zsh-autosuggestions 
    zsh-syntax-highlighting
    zsh-peco-history
  )

source $ZSH/oh-my-zsh.sh

# Enable highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

# Override highlighter colors
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=009
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=009,standout
ZSH_HIGHLIGHT_STYLES[alias]=fg=white,bold
ZSH_HIGHLIGHT_STYLES[builtin]=fg=white,bold
ZSH_HIGHLIGHT_STYLES[function]=fg=white,bold
ZSH_HIGHLIGHT_STYLES[command]=fg=white,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=white,underline
ZSH_HIGHLIGHT_STYLES[commandseparator]=none
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=009
ZSH_HIGHLIGHT_STYLES[path]=fg=214,underline
ZSH_HIGHLIGHT_STYLES[globbing]=fg=063
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=white,underline
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=none
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=063
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=009
ZSH_HIGHLIGHT_STYLES[assign]=none
ZSH_AUTOSUGGEST_MANUAL_REBIND=t
DISABLE_AUTO_UPDATE=true
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

findDir(){
    cd
}

bindkey -s 'fd' 'findDir \n'
bindkey -s 'fj' '^r'
export ZPLUG_HOME=~/.zplug
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='rg --hidden --no-ignore --files'

lazy_load_nvm() {
  unset -f node nvm
  export NVM_DIR=~/.nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
}

node() {
  lazy_load_nvm
  node $@
}

nvm() {
  lazy_load_nvm
  node $@
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"   This loads nvm bash_completion
#export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# The next line updates PATH for the Google Cloud SDK.
#if [ -f '/home/sanket/Music/google-cloud-sdk/path.zsh.inc' ]; then . '/home/sanket/Music/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
#if [ -f '/home/sanket/Music/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/sanket/Music/google-cloud-sdk/completion.zsh.inc'; fi
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
bash ~/ssh_agent.sh &&

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/sanket/gitlocal/gcp_roles/google-cloud-sdk/path.zsh.inc' ]; then . '/home/sanket/gitlocal/gcp_roles/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/sanket/gitlocal/gcp_roles/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/sanket/gitlocal/gcp_roles/google-cloud-sdk/completion.zsh.inc'; fi

alias ls='eza --icons --group-directories-first --color=always'
alias la='eza --icons -l -T --group-directories-first --color=always'
alias ll='eza --icons -l --group-directories-first --color=always'
