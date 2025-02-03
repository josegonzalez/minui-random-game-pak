# trimui-brick-random-game.pak

A TrimUI Brick app that starts a random game from the ROMs folder.

## Requirements

- Docker (for building)

## Building

```shell
make release
```

## Installation

1. Mount your TrimUI Brick SD card.
2. Download the latest release from Github. It will be named `Random.Game.pak.zip`.
3. Copy the zip file to `/Tools/tg5040/Random Game.pak.zip`. Please ensure the new zip file name is `Random Game.pak.zip`, without a dot (`.`) between the words `Random` and `Game`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Tools/tg5040/Random Game.pak/launch.sh` file on your SD card.
6. Unmount your SD Card and insert it into your TrimUI Brick.

> [!NOTE]
> The device directory changed from `/Tools/tg3040` to `/Tools/tg5040` in `MinUI-20250126-0` - released 2025-01-26. If you are using an older version of MinUI, use `/Tools/tg3040` instead.

## Usage

> [!IMPORTANT]
> If the zip file was not extracted correctly, the pak may show up under `Tools > Random Game`. Rename the folder to `Random Game.pak` to fix this.

Browse to `Tools > Random Game` and press `A` to play a random game.
