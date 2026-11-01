# Examples

Two standalone examples for **Nerx UI**. Both load `NerxUI.luau` from
GitHub if it is not already available as a local file or ModuleScript.

## `basic.luau`

A minimal window: one group, one tab, a selector, a few standard components,
chips, a preview stage and a custom `Widgets.Button` row.

Use this as the starting point for your own menu.

## `xhook-menu.luau`

A complete Xhook-style design showcase built with the public library API.
It mirrors the current xhook.win CS 1.6 navigation:

```
AIMBOT
  Legit
  Rage
    Main
    Weapon
VISUALS
  Visuals
    Players
    World
    Other
    Render
MISC
  Kreedz
    Movement
    Movement Recorder
  Misc
    Main
    Skin Changer
    Player List
    Server
  Configs
    Settings
    Bind Manager
    Themes
  Scripting
    Scripts
    Editor
  Console
```

Implemented page highlights:

- **Legit** — weapon-class selector, main aimbot rows, triggerbot, auxiliary aim settings.
- **Rage** — general/accuracy/anti-aim/fakelag sections and a per-weapon page.
- **Players** — selector, ESP/chams/elements, live preview chips.
- **World** — bomb ESP, chams/glow and a preview.
- **Other** — view/HUD sections, Post FX chip groups, world switches.
- **Render** — world-renderer metrics, lighting, culling and decals.
- **Kreedz** — movement/tricks rows and a full movement-recorder layout
  (run list, timeline, stats, trim/orbit/POV controls).
- **Misc** — automation and utilities; **Skin Changer** loadout/skin browser;
  **Player List** search and player detail; **Server** preferences.
- **Configs** — config cards and warning banner; bind manager with
  WHEN / WHILE / THEN editor; theme preset gallery with live accent switching.
- **Scripting** — script grid and a three-column editor
  (explorer, code pane, API reference).
- **Console** — level filter, log list and command bar.

### Design-only parts

The example is a UI demonstration. It intentionally does **not** include
game logic, persistence, a 3D renderer, a Lua parser or a real HTTP client.
The recorder preview, skin weapon view, and editor code are layout
placeholders. Attach your own `ViewportFrame`, text editor or backend where
marked.

### Run it

**Executor / raw file**

1. Upload `NerxUI.luau` to the repository root.
2. Upload `examples/xhook-menu.luau`.
3. Execute the example. It loads the library from:

```lua
https://raw.githubusercontent.com/z1215203698741/123123123vvava/main/NerxUI.luau
```

If you fork the repository, update `LIBRARY_URL` at the top of the example.

**Rojo / Studio**

1. Sync `NerxUI.luau` to `ReplicatedStorage.NerxUI`.
2. Place `examples/xhook-menu.luau` in a `LocalScript` (or run it from an
   executor).
3. The resolver finds `ReplicatedStorage.NerxUI` and requires it.

**Local executor**

Keep `NerxUI.luau` next to the example (or one directory above). The resolver
checks `NerxUI.luau` and `../NerxUI.luau` before falling back to GitHub.

### Branding

The example uses:

```lua
local BRAND = {
    Title = "Nerx Beta",
    Subtitle = "Bloxstrike",
}
```

Set it to:

```lua
local BRAND = {
    Title = "xhook",
    Subtitle = "Counter-Strike 1.6",
}
```

for exact reference branding.

### Notes

- The library must be the latest `NerxUI.luau`; the example uses the fixed
  `Widgets.Toggle` no-callback path and `U.Tween`.
- The example returns the created window, so you can keep a reference and
  script against it.
- All values are visual placeholders. `Nerx.Flags` is populated only for the
  components that define `Flag`.
