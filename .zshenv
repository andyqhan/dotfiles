export ZSH_AUTOSUGGEST_STRATEGY=(history)
if [ -f "/Applications/emacs-28.app/Contents/MacOS/Emacs" ]; then
  export EMACS="/Applications/emacs-28.app/Contents/MacOS/Emacs"
  alias emacs="$EMACS -nw"
fi

if [ -f "/Applications/emacs-28.app/Contents/MacOS/bin/emacsclient" ]; then
  alias emacsclient="/Applications/emacs-28.app/Contents/MacOS/bin/emacsclient"
fi
