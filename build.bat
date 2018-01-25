@echo off
REM this assumes that we have the picotool in ../picotool
echo Building.
py -3 ..\picotool\p8tool build game.p8.png --lua main_game.lua
IF %ERRORLEVEL% EQU 0 (
    echo Success. Copying cartridge.
    cp game.p8.png %appdata%\pico-8\carts\game.p8.png
)
