emulate sh -c 'source /etc/profile'
emulate sh -c 'source ${HOME}/.profile'

if [[ $OSTYPE == 'darwin'* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
