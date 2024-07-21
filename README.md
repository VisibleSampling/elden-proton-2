# elden-proton

While much of the original code has been removed in this version, I did not feel comfortable removing the original author's name from the project. I have left the original `README.md` below for reference.

This fork is a rewrite of the original script to be more user-friendly but did not match my requirements. It has been rewritten by me to better suit my needs.

A large portion of the original functionality no longer exists. This script will no longer download, update, or install mods for you. It will only attempt to launch the mods I have installed and configured how I want them. If you want to use this script, you will need to modify it to suit your needs.

## Current features:
1. Provides 3 options for launching Elden Ring:
    - Vanilla
    - Seamless Coop
    - Modded
2. Uses [er-patcher](https://github.com/gurrgur/er-patcher) when launching the game with either Seamless Coop or Modded options.
3. Switches between saves for Vanilla and Modded options.
4. Automatically backs up all saves before launching the game, keeping the last 10 backups.

## If you want to replicate this exactly, you will need to:
1. Install all mods into the game directory:
    - Seamless Coop
    - er-patcher
    - ModManager
2. Install and configure ModEngine2 inside of `$HOME/Documents/Games/Elden Ring/ModEngine`.
3. Ensure that there are 2 saves in the game directory, one for Vanilla and one for Modded. The script will automatically switch between the two when launching the game. The saves should be named `ER0000.sl2` and `ER0000.sl2.modded` respectively. This applies to both `.sl2` and `.sl2.bak` files.




---

Noob friendly Elden Ring mod loader for linux/proton/steam

![steam launch options](.github/images/launch-options.png)
![launcher ui](.github/images/ui.png)

## Usage

- Place the `elden-proton.bash` into your preferred location and mark it as executable (`chmod +x` from shell).
- Run the script once through terminal or through graphical file manager to output steam launch options.
- Set the provided launch options in steam for Elden Ring
- Launch Elden Ring from steam and customize settings to your liking

## Flatpak Steam

- Make sure that every necessary path (wherever you put `elden-proton.bash` or the folder containing your Modengine2 mods) is accessible from the flatpak
- CLI example: `flatpak override com.valvesoftware.Steam --filesystem="$HOME/dev/personal:ro"`
- Flatseal example: Put `"$HOME/dev/personal:ro"` under Filesystem->Other files for the Steam application
- Apart from that it should work out of the box

## Features

- Run Elden Ring modded or unmodded easily
- Zenity based GUI
- Automatically manages EldenModLoader and ModEngine2-proton
- Automatically manages and downloads popular DLL mods
- Easy access to DLL mod configuration files
- Run ModEngine2 compatible mods simply by choosing the mod directory

## Modengine2 mods

Many mods in NexusMods come with ModEngine2 bundled. Simply choose any folder that contains a `config_eldenring.toml` file and you are all set.

## Env variables

- `STEAM_PATH` control where steam is located
- `ER_PATH` control where `Elden Ring/Game` is located

## Start from scratch

In your `Elden Ring/Game` location, remove the `mods` and `EldenProton` folders.
Remove only the `EldenProton` folder if you want to reset state and re-download everything.
Note that all DLL mod settings will be reset.
