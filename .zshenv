export ZSH_AUTOSUGGEST_STRATEGY=(history)
if [ -f "/Applications/Emacs.app/Contents/MacOS/Emacs" ]; then
  export EMACS="/Applications/Emacs.app/Contents/MacOS/Emacs"
  alias emacs="$EMACS -nw"
fi

if [ -f "/Applications/Emacs.app/Contents/MacOS/bin/emacsclient" ]; then
  alias emacsclient="/Applications/Emacs.app/Contents/MacOS/bin/emacsclient"
fi

