# minui-random-game.pak

A MinUI app that starts a random game from the ROMs folder.

## Requirements

This pak is designed and tested on the following MinUI Platforms and devices:

- `tg5040`: Trimui Brick (formerly `tg3040`), Trimui Smart Pro
- `rg35xxplus`: RG-35XX Plus, RG-34XX, RG-35XX H, RG-35XX SP

Use the correct platform for your device.

## Installation

1. Mount your MinUI SD card.
2. Download the latest release from Github. It will be named `Random.Game.pak.zip`.
3. Copy the zip file to `/Tools/$PLATFORM/Random Game.pak.zip`. Please ensure the new zip file name is `Random Game.pak.zip`, without a dot (`.`) between the words `Random` and `Game`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Tools/$PLATFORM/Random Game.pak/launch.sh` file on your SD card.
6. Unmount your SD Card and insert it into your Device.

## Usage

> [!IMPORTANT]
> If the zip file was not extracted correctly, the pak may show up under `Tools > Random Game`. Rename the folder to `Random Game.pak` to fix this.

Browse to `Tools > Random Game` and press `A` to play a random game.

### Debug Logging

Debug logs are written to the`$SDCARD_PATH/.userdata/$PLATFORM/logs/` folder.
