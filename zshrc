# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
if [[ `uname` == "Darwin" ]]; then
  export ZSH="/Users/mattialambertini/.oh-my-zsh"
else
  export ZSH="/home/mattia/.oh-my-zsh"
fi


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

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

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

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
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

HISTSIZE=100000000000
SAVEHIST=10000000000

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker docker-compose kubectl kube-ps1 zsh-completions)
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

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
alias d=docker
alias mypublicip="dig +short myip.opendns.com @resolver1.opendns.com"
export AWS_SDK_LOAD_CONFIG="true"

function setup_aws_credentials() {
    profile_name=$1
    echo $profile_name
    role_arn=$(aws configure get role_arn --profile $profile_name)
    region=$(aws configure get region --profile $profile_name)
    mfa_serial=$(aws configure get mfa_serial --profile $profile_name)
    local stscredentials
    stscredentials=$(aws sts assume-role \
        --profile $profile_name \
        --role-arn "${role_arn}" \
        --role-session-name something \
        --query '[Credentials.SessionToken,Credentials.AccessKeyId,Credentials.SecretAccessKey]' \
        --output text)
    AWS_ACCESS_KEY_ID=$(echo "${stscredentials}" | awk '{print $2}')
    AWS_SECRET_ACCESS_KEY=$(echo "${stscredentials}" | awk '{print $3}')
    AWS_SESSION_TOKEN=$(echo "${stscredentials}" | awk '{print $1}')
    AWS_SECURITY_TOKEN=$(echo "${stscredentials}" | awk '{print $1}')
    AWS_PROFILE=$1
    if [ $region ]
    then
        AWS_DEFAULT_REGION=$region
        export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN AWS_DEFAULT_REGION AWS_PROFILE
    else
        export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN AWS_PROFILE
    fi
}

function setup_aws_credentials_sso() {
    sso_start_url=flowing.awsapps.com
    profile_name=$1
    echo $profile_name
    role_name=$(aws configure get sso_role_name --profile $profile_name)
    region=$(aws configure get region --profile $profile_name)
    sso_region=$(aws configure get sso_region --profile $profile_name)
    account_id=$(aws configure get sso_account_id --profile $profile_name)
    access_token=$(cat `grep -rl ~/.aws/sso/cache/ -e $sso_start_url` |jq -r .accessToken)
    local stscredentials
    stscredentials=$(aws sso get-role-credentials \
      --profile $profile_name \
      --role-name $role_name \
      --account-id $account_id \
      --region $sso_region \
      --access-token $access_token)
    credential_res=$?
    AWS_ACCESS_KEY_ID=$(echo "${stscredentials}" | jq -r .roleCredentials.accessKeyId)
    AWS_SECRET_ACCESS_KEY=$(echo "${stscredentials}" | jq -r .roleCredentials.secretAccessKey)
    AWS_SESSION_TOKEN=$(echo "${stscredentials}" | jq -r .roleCredentials.sessionToken)
    AWS_PROFILE=$1
    AWS_DEFAULT_REGION=$region
    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_REGION AWS_PROFILE
    return $credential_res
}

function terraformsso() {
    if [ -z "$AWS_PROFILE" ]
    then
      echo "please define the environment variable AWS_PROFILE bofore running this"
      return
    fi
    if [ $(aws configure list-profiles |grep -Ec "^$AWS_PROFILE$") -eq 1 ]
    then
        setup_aws_credentials_sso $AWS_PROFILE && echo "SSO credentilas ok" || (echo "Authentication Failed; Did you run aws sso login?"; return 1)
        /usr/local/bin/terraform fmt
        eval "/usr/local/bin/terraform $*"
    else
        echo "Error, please specify variable AWS_PROFILE with a valid profile"
    fi
}

function terraformrolemfa() {
    if [ -z "$AWS_PROFILE" ]
    then
      echo "please define the environment variable AWS_PROFILE bofore running this"
      return
    fi
    if [ $(aws configure get role_arn --profile $AWS_PROFILE) ]
    then
        setup_aws_credentials $AWS_PROFILE && echo "MFA ENABLED" || exit
        /usr/local/bin/terraform fmt
        eval "/usr/local/bin/terraform $*"
    else
        echo "no role_arn for profile  \"$AWS_PROFILE\", please specify variable AWS_PROFILE"
    fi
}

function clearAwsEnv() {
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN AWS_DEFAULT_REGION
}

alias k=kubectl
source <(kubectl completion zsh)
echo 'complete -F __start_kubectl k'

load-tfswitch() {
  local tfswitchrc_path=".tfswitchrc"

  if [ -f "$tfswitchrc_path" ]; then
    tfswitch
  fi
}
add-zsh-hook chpwd load-tfswitch
load-tfswitch

function get_cluster_short() {
  if [[ $1 == *"arn:aws:eks"* ]]; then
    echo "$1" | cut -d "/" -f2 | awk '{print "EKS:"$1}'
  else
    echo "$1"
  fi
}

KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short

PS1='$(kube_ps1)'$PS1
