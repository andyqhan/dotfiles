#!/bin/sh
# Wrapper invoked by Skim cmd-shift-click reverse search.
# Skim is configured to call this with: "%file" %line.
#
# Skim doesn't pass click-modifier info, so we ask macOS directly:
#   NSEvent.modifierFlags returns the current modifier bitmask. By the time
#   this script runs (~50ms after the click), the user is usually still
#   holding the keys. If control is held → open in a NEW frame.
#
#   ⌘-Shift-Click           → existing frame (default)
#   ⌘-Ctrl-Shift-Click      → new frame
#
# NSEventModifierFlagControl = 1 << 18 = 262144

flags=$(/usr/bin/osascript -l JavaScript -e \
  'ObjC.import("AppKit"); $.NSEvent.modifierFlags' 2>/dev/null)

# osascript may return a float like "262146.0"; strip everything after the dot.
flags=${flags%%.*}
flags=${flags:-0}

if [ $((flags & 262144)) -ne 0 ]; then
  exec /opt/homebrew/bin/emacsclient --no-wait \
    --eval "(amh/skim-reverse-search-new-frame \"$1\" $2)"
else
  exec /opt/homebrew/bin/emacsclient --no-wait \
    --eval "(amh/skim-reverse-search \"$1\" $2)"
fi
