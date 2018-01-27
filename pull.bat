git pull
IF %ERRORLEVEL% EQU 0 (
    xcopy /y game.p8.png %appdata%\pico-8\carts\game.p8.png
    call build.bat
)
