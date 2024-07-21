#!/usr/bin/env bash

## Elden Ring Mod/launch manager

# Script variables
STEAM_DIR="$HOME/.steam"
ELDEN_RING_DIR="$HOME/.steam/steam/steamapps/common/ELDEN RING/Game"
MOD_ENGINE_DIR="$HOME/Documents/Games/Elden Ring/ModEngine"
SAVE_DIR="$HOME/.steam/steam/steamapps/compatdata/1245620/pfx/drive_c/users/steamuser/AppData/Roaming/EldenRing/76561198018665989"
BACKUP_DIR="$HOME/.steam/steam/steamapps/compatdata/1245620/pfx/drive_c/users/steamuser/AppData/Roaming/EldenRing/SaveBackups"

# Backup all save files
BACKUP_SAVE_FILES() {
    # Ensure BACKUP_DIR exists
    mkdir -p "$BACKUP_DIR"

    # Create a new directory with the current date and time
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"
    mkdir -p "$BACKUP_PATH"

    # Copy everything from SAVE_DIR to the new backup directory
    cp -r "$SAVE_DIR"/* "$BACKUP_PATH/"

    # Remove backups older than the most recent 20
    BACKUP_COUNT=$(ls -1q "$BACKUP_DIR" | wc -l)
    if [ "$BACKUP_COUNT" -gt 10 ]; then
        ls -1t "$BACKUP_DIR" | tail -n +11 | xargs -I{} rm -rf "$BACKUP_DIR/{}"
    fi
}

# Change to Elden Ring directory
cd "$ELDEN_RING_DIR" || exit

# Tool variables
UNZIP=$(which unzip)
CURL=$(which curl)
SHA256SUM=$(which sha256sum)
ZENITY=${STEAM_ZENITY:-zenity}

# Required tools
declare -A required_tools=(
  [zenity]="zenity"
  [unzip]="unzip"
  [curl]="curl"
  [sha256sum]="sha256sum"
)

# Check for required tools
for tool in "${!required_tools[@]}"; do
  if ! command -v "${required_tools[$tool]}" &> /dev/null; then
    echo "${required_tools[$tool]} not found. Please install ${required_tools[$tool]}."
    exit 1
  fi
done

#Menu options
WITHOUT_MODS="Play without mods"
SEAMLESS_COOP="Seamless Co-op"
MOD_ENGINE="Mod Engine"

LOAD_VANILLA_SAVE() {
    if [ -f "${SAVE_DIR}/ER0000.sl2" ] && [ -f "${SAVE_DIR}/ER0000.sl2.vanilla" ]; then
        mv "${SAVE_DIR}/ER0000.sl2" "${SAVE_DIR}/ER0000.sl2.modded"
        mv "${SAVE_DIR}/ER0000.sl2.bak" "${SAVE_DIR}/ER0000.sl2.bak.modded"
        mv "${SAVE_DIR}/ER0000.sl2.vanilla" "${SAVE_DIR}/ER0000.sl2"
        mv "${SAVE_DIR}/ER0000.sl2.bak.vanilla" "${SAVE_DIR}/ER0000.sl2.bak"
    fi
}

LOAD_MODDED_SAVE() {
    if [ -f "${SAVE_DIR}/ER0000.sl2" ] && [ -f "${SAVE_DIR}/ER0000.sl2.modded" ]; then
        mv "${SAVE_DIR}/ER0000.sl2" "${SAVE_DIR}/ER0000.sl2.vanilla"
        mv "${SAVE_DIR}/ER0000.sl2.bak" "${SAVE_DIR}/ER0000.sl2.bak.vanilla"
        mv "${SAVE_DIR}/ER0000.sl2.modded" "${SAVE_DIR}/ER0000.sl2"
        mv "${SAVE_DIR}/ER0000.sl2.bak.modded" "${SAVE_DIR}/ER0000.sl2.bak"
    fi
}

# Uses the Steam Runtime for Zenity if it's available making it look better
# From: https://github.com/Cloudef
# Project: https://github.com/Cloudef/elden-proton
if [[ -d "${STEAM_RUNTIME:-}" ]]; then
	OLD_LIBRARY_PATH="$LD_LIBRARY_PATH"
	export LD_LIBRARY_PATH=
	if [[ ! "${STEAM_ZENITY:-}" ]] || [[ "${STEAM_ZENITY:-}" == zenity ]]; then
		if [[ "${SYSTEM_PATH:-}" ]]; then
			ZENITY="${SYSTEM_ZENITY:-$(PATH="$SYSTEM_PATH" which zenity)}"
		else
			ZENITY="${SYSTEM_ZENITY:-/usr/bin/zenity}"
		fi
	fi
fi

# Zenity menu
CHOICE=$($ZENITY --list --title="Elden Ring Mod Manager" --text="Select the mod you want to use" --column="Mod" "$WITHOUT_MODS" "$SEAMLESS_COOP" "$MOD_ENGINE"  --width=400 --height=300)

# Check if the user selected a mod
if [ -n "$CHOICE" ]; then
  case $CHOICE in
    "$WITHOUT_MODS")
      echo "Launching Elden Ring without mods"
      BACKUP_SAVE_FILES
      LOAD_VANILLA_SAVE
      [ -f dinput8.dll ] && mv dinput8.dll dinput8.dll.disabled
      WINEDLLOVERRIDES="dinput8.dll=b" "$@"
      exit $?
      ;;
    "$SEAMLESS_COOP")
      echo "Launching Elden Ring with Seamless Co-op"
      BACKUP_SAVE_FILES
      [ -f dinput8.dll ] && mv dinput8.dll dinput8.dll.disabled
      python er-patcher --all --rate 144  --executable ersc_launcher.exe -- "$@"
      exit $?
      ;;
    "$MOD_ENGINE")
      echo "Launching Elden Ring with Mod Engine"
      [ -f dinput8.dll.disabled ] && mv dinput8.dll.disabled dinput8.dll
      BACKUP_SAVE_FILES
      LOAD_MODDED_SAVE
      python er-patcher --all --rate 144  -- env WINEDLLOVERRIDES="dinput8.dll=n,b" MODENGINE_CONFIG="$MOD_ENGINE_DIR/config_eldenring.toml" "$@"
      exit $?
      ;;
esac
fi

# If the user didn't select a mod, exit the script
if [ -z "$CHOICE" ]; then
  exit 0
fi
