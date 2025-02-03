#!/bin/sh

# TODO: write a daemon that binds this to Y?

SYSTEM_PATH="$SDCARD_PATH/.system/$PLATFORM"
PAKS_PATH="$SDCARD_PATH/.system/$PLATFORM/paks"

find_random_file() {
    DIR="$1"
    # Get all files except hidden ones and txt/log files, count them
    total=$(find "$DIR" -type f ! -path '*/\.*' ! -name '*.txt' ! -name '*.log' | wc -l)

    if [ "$total" -eq 0 ]; then
        return 1
    fi

    # Generate random number between 1 and total using PID and time
    r="$((($(date +%s) + $$) % total + 1))"

    # Get the r-th file
    find "$DIR" -type f ! -path '*/\.*' ! -name '*.txt' ! -name '*.log' | head -n "$r" | tail -1
}

get_emu_folder() {
    FILEPATH="$1"
    ROMS="$SDCARD_PATH/Roms"

    # Get first folder name by cutting at first /
    echo "${FILEPATH#"$ROMS/"}" | cut -d'/' -f1
}

get_emu_name() {
    EMU_FOLDER="$1"

    # Extract text between parentheses using basic sed
    echo "$EMU_FOLDER" | sed 's/.*(\([^)]*\)).*/\1/'
}

get_emu_path() {
    EMU_NAME="$1"
    platform_emu="$SDCARD_PATH/Emus/$PLATFORM/${EMU_NAME}.pak/launch.sh"
    if [ -f "$platform_emu" ]; then
        echo "$platform_emu"
        return
    fi

    pak_emu="$SDCARD_PATH/Emus/${EMU_NAME}.pak/launch.sh"
    if [ -f "$pak_emu" ]; then
        echo "$pak_emu"
        return
    fi

    return 1
}

main() {
    show_message "Finding a random game..."
    sleep 1

    FILE=$(find_random_file "$SDCARD_PATH/Roms")
    if [ -z "$FILE" ]; then
        show_message "Could not find any games." forever
        exit
    fi

    EMU_FOLDER=$(get_emu_folder "$FILE")
    EMU_NAME=$(get_emu_name "$EMU_FOLDER")
    EMU_PATH=$(get_emu_path "$EMU_NAME")
    if [ -z "$EMU_PATH" ]; then
        show_message "Could not find an emulator for this game." forever
        exit
    fi

    exec "$EMU_PATH" "$FILE"
}

mkdir -p "$progdir/log"
if [ -f "$progdir/log/launch.log" ]; then
    mv "$progdir/log/launch.log" "$progdir/log/launch.log.old"
fi

main "$@" >"$progdir/log/launch.log" 2>&1
