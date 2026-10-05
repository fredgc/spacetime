#!/bin/bash -i
# Used to setup work on the local machine.

if [ -z "$workspace" ]; then 
  export workspace=`sawfish-client -e current-workspace`
fi

if [ `hostname -s` == "raven" ]; then
  #  export FLUTTER_PORT=$(find-port.py)
  # This needs to be registered w/the cloud api console? So we hard code a port.
  export FLUTTER_PORT=5500
  echo "Using port $FLUTTER_PORT"
  echo "Starting local emacs:"
  export USE_DESKTOP=$workspace
  emacs-maybe-client -n -3 plan.md lib/main.dart
  hot-key-start -w $workspace 5 urxvt -geometry 100x28+80-40 -e agy
  (
      # Wait for the window to settle, then split into 3 frames.
      sleep 5;
      emacs-maybe-client -3
  ) &
else
  # This needs to be registered w/the cloud api console?
  export FLUTTER_PORT=5000
  echo "Using port $FLUTTER_PORT"
  echo "Starting remote tmux:"
  export REMOTE=personal
  ssh-remote start-tmux-in-dir published/spacetime spacetime
  ~/setup/setup-ssh-jeeves.sh --no-remember spacetime
fi

chrome-hot-key -n personal -w $workspace -g 1700x1000+0+50 9 "http://localhost:$FLUTTER_PORT"

# chrome-hot-key -n personal -w $workspace -g +0+26 5 "https://flutter.dev/docs/get-started/codelab"

chrome-hot-key -n personal -w $workspace -g 980x1010-1+30 0 \
  "https://console.firebase.google.com/u/0/project/fredgc-spacetime/overview"

chrome-hot-key -n personal -w $workspace -g 950x1000+100+30 t \
  "https://docs.google.com/document/d/19ESr9TL-pdcFNEsN7CH6jGBd29GVWtpy7y3GxRuSSrI/edit?tab=t.cjlbfhsn7amk"

