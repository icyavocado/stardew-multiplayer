#!/bin/bash

if [ -n "$RESOLUTION" ]; then
    sed -i "s/1366x768/$RESOLUTION/" /home/app/supervisord.conf
fi

# start up supervisord, all daemons should launched by supervisord.
/usr/bin/supervisord -c /home/app/supervisord.conf

if [[ -f /home/app/games/game/StardewValley ]]; then
  mv "/home/app/games/game/StardewValley" "/home/app/games/game/Stardew Valley"
fi

sleep 2
tail -F /home/app/logs/*
