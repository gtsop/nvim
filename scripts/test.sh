#!/usr/bin/env sh

WATCH_CMD="find lua -type f \\( -name '*.lua' -o -name '*.test.lua' \\)"

if [ "$1" = "--watch" ]; then
  eval "$WATCH_CMD" | entr -c busted lua
else
  busted lua
fi
