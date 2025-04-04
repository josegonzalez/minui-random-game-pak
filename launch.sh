#!/bin/sh
PAK_DIR="$(dirname "$0")"
PAK_NAME="$(basename "$PAK_DIR")"
PAK_NAME="${PAK_NAME%.*}"
set -x

rm -f "$LOGS_PATH/$PAK_NAME.txt"
exec >>"$LOGS_PATH/$PAK_NAME.txt"
exec 2>&1

echo "$0" "$@"
cd "$PAK_DIR" || exit 1
mkdir -p "$USERDATA_PATH/$PAK_NAME"

architecture=arm
if uname -m | grep -q '64'; then
    architecture=arm64
fi

export HOME="$USERDATA_PATH/$PAK_NAME"
export LD_LIBRARY_PATH="$PAK_DIR/lib:$LD_LIBRARY_PATH"
export PATH="$PAK_DIR/bin/$architecture:$PAK_DIR/bin/$PLATFORM:$PAK_DIR/bin:$PATH"

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

add_game_to_recents() {
    FILEPATH="$1" GAME_ALIAS="$2"

    FILEPATH="${FILEPATH#"$SDCARD_PATH/"}"
    RECENTS="$SDCARD_PATH/.userdata/shared/.minui/recent.txt"
    if [ -f "$RECENTS" ]; then
        sed -i "#/$FILEPATH\t$GAME_ALIAS#d" "$RECENTS"
    fi

    rm -f "/tmp/recent.txt"
    touch "/tmp/recent.txt"
    printf "%s\t%s\n" "/$FILEPATH" "$GAME_ALIAS" >"/tmp/recent.txt"
    cat "$RECENTS" >>"/tmp/recent.txt"
    mv "/tmp/recent.txt" "$RECENTS"
}

get_rom_alias() {
    FILEPATH="$1"
    filename="$(basename "$FILEPATH")"
    filename="${filename%.*}"
    filename="$(echo "$filename" | sed 's/([^)]*)//g' | sed 's/\[[^]]*\]//g' | sed 's/[[:space:]]*$//')"
    echo "$filename"
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

    killall minui-presenter >/dev/null 2>&1 || true
    echo "$message" 1>&2
    if [ "$seconds" = "forever" ]; then
        minui-presenter --message "$message" --timeout -1 &
    else
        minui-presenter --message "$message" --timeout "$seconds"
    fi
}

cleanup() {
    rm -f /tmp/stay_awake
    killall minui-presenter >/dev/null 2>&1 || true
}

main() {
    echo "1" >/tmp/stay_awake
    trap "cleanup" EXIT INT TERM HUP QUIT

    if ! command -v minui-presenter >/dev/null 2>&1; then
        show_message "minui-presenter not found" 2
        return 1
    fi

    show_message "Finding a random game..."
    sleep 1

    FILE=$(find_random_file "$SDCARD_PATH/Roms")
    if [ -z "$FILE" ]; then
        show_message "Could not find any games." 2
        return 1
    fi

    EMU_FOLDER=$(get_emu_folder "$FILE")
    EMU_NAME=$(get_emu_name "$EMU_FOLDER")
    EMU_PATH=$(get_emu_path "$EMU_NAME")
    if [ -z "$EMU_PATH" ]; then
        show_message "Could not find an emulator for this game." 2
        return 1
    fi

    ROM_ALIAS=$(get_rom_alias "$FILE")
    show_message "$ROM_ALIAS"

    rm -f /tmp/stay_awake

    add_game_to_recents "$FILE" "$ROM_ALIAS"
    killall minui-presenter >/dev/null 2>&1 || true
    exec "$EMU_PATH" "$FILE"
}

main "$@"
