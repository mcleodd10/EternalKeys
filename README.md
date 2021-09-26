# EternalKeys
Grenade and dash Autohotkey macros for Doom Eternal

This script allows you to double-tap the movement keys to dash in any direction, and optionally to dash continuously while holding the movement key after triggering the shortcut.

It also allows you to set a separate hotkey for frag and ice grenades, thus eliminating the need for the equipment switch key, which never made sense since there's only the two nades to swap between anyways. The correct grenade will fire regardless of which one is active.

This relies on the imagesearch function of AutoHotkey to check the state of the grenade icon on your hud. Reference images are included for all themes at 100% opacity and 1080p resolution. You'll likely need to clip new ones for other resolutions, for best results, take a small clip, and black out as much as possible leaving only the pixels that will remain unchanged (parts of the icon are transparent in-game) like shown in the examples. If you get one that works well for you, consider doing a pull request to add them to the refimages dir.

For the default config, Middle mouse & left control will fire a frag, while Xbutton1 (mouse4) & H will fire an ice grenade.
