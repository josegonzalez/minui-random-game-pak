#!/bin/sh
echo "$0" "$@"
progdir="$(dirname "$0")"
cd "$progdir" || exit 1
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$progdir/lib"
echo 1 >/tmp/stay_awake
trap "rm -f /tmp/stay_awake" EXIT INT TERM HUP QUIT

find_random_file() {
    DIR="$1"
    total=$(find "$DIR" -type f ! -path '*/\.*' ! -name '*.txt' ! -name '*.log' | wc -l)

    if [ "$total" -eq 0 ]; then
        return 1
    fi

    r="$((($(date +%s) + $$) % total + 1))"

    # Get the r-th file
    find "$DIR" -type f ! -path '*/\.*' ! -name '*.txt' ! -name '*.log' | head -n "$r" | tail -1
}

get_emu_folder() {
    FILEPATH="$1"
    ROMS="$SDCARD_PATH/Roms"

    echo "${FILEPATH#"$ROMS/"}" | cut -d'/' -f1
}

get_emu_name() {
    EMU_FOLDER="$1"

    echo "$EMU_FOLDER" | sed 's/.*(\([^)]*\)).*/\1/'
}

get_emu_path() {
    EMU_NAME="$1"
    platform_emu="$SDCARD_PATH/Emus/$PLATFORM/${EMU_NAME}.pak/launch.sh"
    if [ -f "$platform_emu" ]; then
        echo "$platform_emu"
        return
    fi

    pak_emu="$SDCARD_PATH/.system/$PLATFORM/paks/Emus/${EMU_NAME}.pak/launch.sh"
    if [ -f "$pak_emu" ]; then
        echo "$pak_emu"
        return
    fi

    return 1
}

show_message() {
    message="$1"
    seconds="$2"

    if [ -z "$seconds" ]; then
        seconds="forever"
    fi

    killall sdl2imgshow
    echo "$message"
    if [ "$seconds" = "forever" ]; then
        "$progdir/bin/sdl2imgshow" \
            -i "$progdir/res/background.png" \
            -f "$progdir/res/fonts/BPreplayBold.otf" \
            -s 27 \
            -c "220,220,220" \
            -q \
            -t "$message" >/dev/null 2>&1 &
    else
        "$progdir/bin/sdl2imgshow" \
            -i "$progdir/res/background.png" \
            -f "$progdir/res/fonts/BPreplayBold.otf" \
            -s 27 \
            -c "220,220,220" \
            -q \
            -t "$message" >/dev/null 2>&1
        sleep "$seconds"
    fi
}

main() {
    trap "killall sdl2imgshow" EXIT INT TERM HUP QUIT

    show_message "Finding a random game..."
    sleep 1

    FILE=$(find_random_file "$SDCARD_PATH/Roms")
    if [ -z "$FILE" ]; then
        show_message "Could not find any games." 2
        exit 1
    fi

    EMU_FOLDER=$(get_emu_folder "$FILE")
    EMU_NAME=$(get_emu_name "$EMU_FOLDER")
    EMU_PATH=$(get_emu_path "$EMU_NAME")
    if [ -z "$EMU_PATH" ]; then
        show_message "Could not find an emulator for this game." 2
        exit 1
    fi

    killall sdl2imgshow
    exec "$EMU_PATH" "$FILE"
}

mkdir -p "$progdir/log"
if [ -f "$progdir/log/launch.log" ]; then
    mv "$progdir/log/launch.log" "$progdir/log/launch.log.old"
fi

main "$@" >"$progdir/log/launch.log" 2>&1
