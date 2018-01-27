@echo off
REM requires you to set the environment variable %picotoolpath%
echo Building.

py -3 %picotoolpath%\p8tool build game.p8.png --lua main_game.lua
IF %ERRORLEVEL% EQU 0 (
    echo Success. Copying cartridge.
    xcopy /y game.p8.png %appdata%\pico-8\carts\game.p8.png
)
