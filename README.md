# Global Game Jam 2018

This is an experiment that uses the fantasy console Pico-8.

## Requirements

- [Pico8tool](https://github.com/dansanderson/picotool)
- Python 3.6

## Building the project

Assuming you're using Windows: Set the environment variable `%picotoolpath%` to point to your picotool clone-directory:

```
set picotoolpath C:\path\to\picotool
```

Simply run the `build.bat`, which expects that the picotool was cloned to the directory above the project. If the build is successful, the script also copies the cartridge into the location that Pico-8 expects. Launch pico-8 and run the game by

```
LOAD GAME.P8.PNG
RUN
```

The bat-script simply is a wrapper around the picotool that runs the build command and copies the cartridge to the expected location on Windows.
