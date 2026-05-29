#!/bin/bash

# Theme nmtui to be dark instead of bright blue
export NEWT_COLORS='
root=white,black
border=white,black
window=white,black
shadow=white,black
title=cyan,black
button=white,black
actbutton=black,cyan
checkbox=white,black
actcheckbox=black,cyan
entry=white,black
label=white,black
listbox=white,black
actlistbox=black,cyan
textbox=white,black
acttextbox=black,cyan
helpline=black,black
roottext=white,black
'

# Launch ghostty with glassmorphism settings (transparency + blur)
exec ghostty \
  --title=wifi \
  --background-opacity=0.3 \
  --background-blur=20 \
  --background=#0c0c0c \
  --window-decoration=false \
  --font-size=16 \
  --window-padding-x=15 \
  --window-padding-y=15 \
  -e nmtui-connect
