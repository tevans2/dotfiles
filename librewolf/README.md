# LibreWolf setup (macOS)

Notes on how this browser is configured, where each piece lives, and what broke along the way.
Written 2026-10-18. Most of the real config files live **outside** this repo (see "Where things live").

## Overview

- Browser: LibreWolf (`/Applications/LibreWolf.app`, bundle ID `net.librewolf.librewolf`).
- Active profile: `~/Library/Application Support/LibreWolf/Profiles/v4zbxg5n.default-release`
  (the one `installs.ini` marks as the install default).
- Layout: no native tab bar. Tabs live in the **Hopper** sidebar (spaces = containers). The address bar auto-hides.
- Keyboard-driven with **Vimium C**, helped by **Karabiner-Elements** remaps.
- Look: dark, square corners, orange accent. Palette: `#0f0f0f` bg, `#f4decd` text, `#ef934d` accent.

## Where things live

| What | Live path | In this repo |
| --- | --- | --- |
| UI CSS | `<profile>/chrome/userChrome.css`, `userContent.css` | `profile/chrome/` (symlinked by `link-profile.sh`) |
| Profile prefs | `<profile>/user.js` | `profile/user.js` (symlinked by `link-profile.sh`) |
| LibreWolf overrides | `~/.librewolf/librewolf.overrides.cfg` | `.librewolf/` (stowed: `~/.librewolf` -> this repo) |
| Hopper (launcher + sidebar) | `about:addons` (installed from its `.xpi`) | its own repo: `~/Developer/projects/hopper` |
| Theme | `caelus-theme@local` | `theme/caelus-theme.xpi` (repacked, install by hand) |
| LeechBlock NG options | extension storage | `~/dotfiles/leechblock/LeechBlockOptions.txt` (import by hand) |
| Karabiner rules | `~/dotfiles/karabiner/karabiner.json` (copy at `~/.config/karabiner/karabiner.json`) | Yes |
| Vimium C config | `~/dotfiles/vimiumc/` (JSON export + README) | Yes |
| Bitwarden link to desktop app | `~/Library/Application Support/Mozilla/NativeMessagingHosts/com.8bit.bitwarden.json` | No (written by Bitwarden) |

### Installing on a machine

```sh
cd ~/dotfiles && stow librewolf      # links ~/.librewolf (overrides file)
./librewolf/link-profile.sh          # links user.js + chrome/*.css into the install-default profile
```

`link-profile.sh` reads the profile folder from `profiles.ini` (its name is random per machine), moves any real
files aside as `*.pre-dotfiles`, and is safe to re-run. `.stow-local-ignore` keeps everything except `.librewolf/`
out of `stow`. Edit the files here; the browser picks them up on restart.

`~/.config/karabiner` is a **copy**, not a symlink. After editing the dotfiles copy, copy it over.

## Look and feel

Source of the styling: `https://git.symlinx.net/daccfiles/tree/.config/browser_stuff`
(`userChrome.css`, `userContent.css`, `ffc-theme.xpi`).

- `user.js` sets `toolkit.legacyUserProfileCustomizations.stylesheets = true` so CSS loads.
- `userChrome.css`:
  - hides the native tab bar (`#TabsToolbar`) and the sidebar header
  - square corners everywhere
  - hides the "place your bookmarks here" text on the empty bookmarks toolbar
  - **auto-hides the nav bar**: it collapses and reappears on hover over a ~10px strip at the top, or when the
    address bar is focused (`Cmd+L`). To undo, delete the "auto-hide nav bar" block.
- `userContent.css`: dark colours for `about:` pages.
- Theme: the original `.xpi` was unsigned and rejected as "corrupt". Fixed by adding an add-on ID
  (`caelus-theme@local`) to its manifest, repacking it, and setting `xpinstall.signatures.required = false`
  in `user.js`.

## Overrides file (`~/.librewolf/librewolf.overrides.cfg`)

LibreWolf's own `librewolf.cfg` runs **after** `user.js`, so `user.js` loses against its `pref()` calls.
The overrides file is the supported place to change LibreWolf defaults. On macOS the docs say it goes in
`~/.librewolf/`. (Putting it in the profile folder or `Application Support/LibreWolf/` did nothing.)

`defaultPref()` sets a default the user can still change. `pref()` forces the value.

Current contents:

```
defaultPref("librewolf.webgl.prompt", false);       // WebGL on, no per-site prompt
defaultPref("browser.startup.page", 3);             // restore previous windows and tabs
pref("privacy.fingerprintingProtection", false);    // see "Gotchas": does not actually stick
defaultPref("media.eme.enabled", true);             // DRM master switch
defaultPref("media.gmp-provider.enabled", true);
defaultPref("media.gmp-gmpopenh264.enabled", true);
defaultPref("media.webrtc.hw.h264.enabled", true);
```

Deliberately **not** added: `media.gmp-manager.url = "data:text/plain,"` from a LibreWolf DRM guide. It blocks
plugin update checks, so Widevine would stop updating.

## Tabs: Hopper sidebar

Sidebery was retired in favour of Hopper's sidebar (see the Hopper section at the end).

- Spaces (Work, Uni, General...) are **containers**; each space is one container, and the sidebar shows one at a
  time. Create the containers in `about:preferences#containers`.
- Browser-level shortcuts, including Hopper's, are in `about:addons` > gear > *Manage Extension Shortcuts*.
- Hopper's `Ctrl+J/K/H/L` (tab/space navigation) need Vimium C's `<c-j>`/`<c-k>` mappings removed; that is done in
  `vimiumc/vimium_c-*.json`.

## Vimium C and Karabiner

LibreWolf runs **Vimium C** (not plain Vimium). Its config is `~/dotfiles/vimiumc/vimium_c-*.json`.
Plain Vimium uses different command names (e.g. `Vomnibar.activateTabSelection` instead of
`Vomnibar.activateTabs`), so don't import this file into it. Don't run both extensions at once.

Firefox handles `Cmd+T` and `Ctrl+Tab` before any extension sees them, so they're remapped in
Karabiner (LibreWolf only, bundle ID `net.librewolf.librewolf`):

| Press | Sent instead | Vimium C action |
| --- | --- | --- |
| `Ctrl+Tab` and `Shift+Ctrl+Tab` | `Ctrl+P` | tab search (omnibar) |
| `Cmd+T` | `Ctrl+T` | omnibar in a new tab |

Also: LibreWolf was added to the exclusion list of the existing "Left ctrl + hjkl to arrow keys" rule, otherwise
`Ctrl+J/K` became arrow keys and never reached the browser (they are now Hopper's tab-navigation shortcuts). Side effect: `Ctrl+H/L` are
no longer turned into arrows in LibreWolf.

Hopper has its own shortcuts that replace some of this (Cmd+T, Ctrl+Tab and tab navigation); its Karabiner rules
are in `~/Developer/projects/hopper/docs/karabiner.md`.

Limits: Vimium C does not run on `about:` pages, the new-tab page, addons.mozilla.org, or while focus is in the
sidebar or address bar. In those places the remapped keys do nothing.

## Bitwarden

- Extension plus the desktop app (`/Applications/Bitwarden.app`, not the Mac App Store build).
- Touch ID unlock goes through the desktop app via native messaging. It needs "Allow browser integration"
  and "Unlock with Touch ID" in the desktop app, and "Unlock with biometrics" in the extension.
- The desktop app only writes its Firefox link file if `~/Library/Application Support/Mozilla/NativeMessagingHosts/`
  already exists. That folder was created by hand, then "Allow browser integration" was toggled off and on.
- If biometrics greys out again: unlock the desktop app, restart LibreWolf, and if needed toggle
  "Allow browser integration" off and on.
- Passkeys stored in Bitwarden should work on other sites. Logging in to Bitwarden itself, or using Apple
  (Touch ID / iCloud Keychain) passkeys, does not appear to work in LibreWolf. Likely cause (not verified): the
  LibreWolf build lacks Apple's WebAuthn entitlement. Use master password, a hardware key, or another browser.

## Privacy defaults that affect daily use

- **Cookies and cache are cleared on every quit.** You are logged out each restart. To stay logged in, add
  sites in `about:preferences#privacy` > Cookies and Site Data > Manage Exceptions > Allow. The exceptions are
  stored in the profile, **not** in this repo. A suggested starting list:
  `google.com`, `github.com`, `linear.app`, `slack.com`, `nimblegroup.co.za`, `sun.ac.za`,
  `microsoftonline.com`, `microsoft.com`.
- Content blocking category is `strict` (set by LibreWolf with `pref()`).
- `privacy.resistFingerprinting` is `false` in this profile (turned off by hand while debugging WebGL).
  Consider resetting it to `true` in `about:config`.
- Search: the Firefox address bar can search open tabs with `% ` before your query.

## WebGL

LibreWolf gates WebGL behind its own per-site permission, controlled by `librewolf.webgl.prompt`
(documented at librewolf.net/docs/settings). Setting it to `false` turns WebGL on everywhere with no prompt.
`webgl.disabled`, `webgl.force-enabled`, and the RFP settings were red herrings. The failure showed as
"WebGL is currently disabled" in `about:support` even though the GPU was fine.

## Netflix and DRM

Needed, in order:
1. DRM enabled (`media.eme.enabled`, Widevine downloaded; "Play DRM-controlled content" in Settings).
2. **Enhanced Tracking Protection turned off for netflix.com** (shield icon). This was what finally fixed
   "Pardon the interruption" with a blank error code. Cause unproven (likely the fingerprinting protection
   that Strict mode forces on).
3. Not in a private window (DRM is unavailable there).
4. Work VPN (Tunnelblick) disconnected if Netflix reports titles as unavailable ("E100 / 1044" means the title
   isn't available to your region, plan or profile, not a browser fault).

Widevine in Firefox is the lowest security level, so Netflix may cap resolution at 720p.

## Gotchas and lessons

- `user.js` does not override LibreWolf's `pref()` settings. Use `librewolf.overrides.cfg`.
- `privacy.fingerprintingProtection` keeps coming back `true` because Strict mode re-enables it. The override
  for it in the overrides file does not stick. The reliable per-site fix is the shield toggle.
- Prefs in `about:config` marked as defaults set by `defaultPref()` are not highlighted as modified.
- Tridactyl was tried and removed (editor integration worked, but no real gain over Vimium C). Its native
  messenger, link file and rc were deleted.
- An Arc export exists conceptually (Arc's `StorableSidebar.json` holds spaces and pinned tabs) but no import
  into Firefox bookmarks has been done.

## Not backed up yet

- The cookie exception list (profile-only)

Moved into this repo on 2026-10-19: `user.js`, `userChrome.css`, `userContent.css`, the overrides file,
and the repacked theme. The pre-symlink originals are in the profile as `*.pre-dotfiles`.

## Hopper extension

Hopper, a custom keyboard-driven launcher (tab switcher, search, container-aware opening), lives in its own
repo: `~/Developer/projects/hopper`. Install notes, tests and the Karabiner rules (`docs/karabiner.md`) are there.
Only the Karabiner rules touch this setup; the extension is installed from its `.xpi` via `about:addons`.
