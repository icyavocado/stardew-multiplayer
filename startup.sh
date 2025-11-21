#!/bin/bash

# start up supervisord, all daemons should launched by supervisord.
/usr/bin/supervisord -c /home/app/supervisord.conf

if [[ -f /home/app/games/game/StardewValley ]]; then
  mv "/home/app/games/game/StardewValley" "/home/app/games/game/Stardew Valley"
fi

ln -sf /home/app/.config/StardewValley/Saves /home/app/games/game/Mods

while [ -z "$(ls /home/app/.config/StardewValley/ErrorLogs/*.txt 2>/dev/null)" ]
do
  sleep 2
done

tail -F /home/app/.config/StardewValley/**/*
