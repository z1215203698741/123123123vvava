# Nerx UI

A component-first, Neverlose-inspired Roblox interface **library**.

Nerx UI is a single-file Luau module built for reusable menu construction: grouped sidebar navigation, breadcrumb top bar, flat/card page layouts, segmented controls, chips, colour pickers, bind editors, preview stages, notifications and indicators. The **core library** does not ship a demo menu, hard-coded game pages, config persistence or a 3D renderer — you compose those with the public API. Ready-made showcase menus live separately in [`examples/`](examples/README.md).

- Single file: `NerxUI.luau`
- Version `1.0.1` — see [`CHANGELOG.md`](CHANGELOG.md)
- Rojo-ready
- Executor-friendly (`loadstring` / `readfile`)
- Custom pages, widgets and preview stages
- Built-in BuilderIcons icon set
- MIT licensed

---

## Installation

### Rojo

The repository includes `default.project.json`, which maps:

```
ReplicatedStorage/NerxUI  ←  NerxUI.luau
```

```bash
rojo build -o NerxUI.rbxlx
```

Then:

```lua
local Nerx = require(game:GetService("ReplicatedStorage").NerxUI)
```

If you prefer manual setup, create a `ModuleScript` in `ReplicatedStorage`, paste `NerxUI.luau` into it, and require that module.

### Executor / raw GitHub

The current repository raw URL:

```lua
local Nerx = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/z1215203698741/2312421fafw/main/NerxUI.luau")
)()
```

If you fork the repository, replace the account and repository path with your own.

### Local file

```lua
local Nerx = loadstring(readfile("NerxUI.luau"))()
```

The library returns the `Nerx` table. It intentionally does not write to `getgenv`; keep the returned value yourself.

---

## Quick start

```lua
local Nerx = loadstring(readfile("NerxUI.luau"))()
local Theme = Nerx.Theme

local window = Nerx:CreateWindow({
    Title = "Nerx Beta",
    Subtitle = "Bloxstrike",
    Size = UDim2.fromOffset(1024, 700),
    Mode = "legit",
    Modes = { "legit", "rage", "hw" },
    Keybind = "Insert",
    AccountTag = "Attached",
})

local features = window:AddGroup("FEATURES")

-- A tab without sub-pages
local aim = features:AddTab({ Name = "Aim", Icon = "crosshairs" })
local page = aim:GetPage()
page:SetSectionStyle("flat")   -- flat = no card background around rows
page:SetHint("Click toggles · right-click for colour and style")

aim:SetHeaderSwitch({ Text = "Aimbot", Default = true })
aim:SetHeaderIcon("gear", function()
    local page = aim:GetPage()
    window:OpenQuickMenu(page.HeaderIcon)
end)

local general = aim:AddSection({ Name = "GENERAL" })
general:AddToggle({
    Name = "Enabled",
    Default = true,
    Flag = "aim_enabled",
    Callback = function(value)
        print("aim enabled:", value)
    end,
})
general:AddDropdown({
    Name = "Aim type",
    Options = { "Perfect silent", "Smooth", "Assist" },
    Default = "Perfect silent",
    Width = 138,
})
general:AddSlider({
    Name = "Field of view",
    Default = 180,
    Min = 1,
    Max = 360,
    Type = "u",
})
general:AddKeybind({ Name = "Aim key", Default = "E" })

local preview = aim:AddPreview({
    Name = "target",
    Tags = {
        { Text = "Visible", Color = Theme.Green },
        { Text = "Distance 42 m", Color = Theme.Text },
    },
    PlaceholderIcon = "crosshairs",
    PlaceholderText = "target preview",
})
```

## Examples

- [`examples/basic.luau`](examples/basic.luau) — minimal window and component starter.
- [`examples/xhook-menu.luau`](examples/xhook-menu.luau) — full Xhook-style menu with
  Legit / Rage / Visuals / Kreedz / Recorder / Skin Changer / Player List /
  Configs / Bind Manager / Themes / Scripts / Editor / Console layouts.

See [`examples/README.md`](examples/README.md) for the navigation map, run
instructions and design-only notes. Examples are not loaded by the library.

## UI hierarchy

```
Nerx
└─ Window
   ├─ Group ("FEATURES", "CONFIG", ...)
   │  └─ Tab ("Aim", "Visuals", ...)
   │     ├─ Default Page
   │     └─ Sub Pages ("Players", "World", ...)
   │        ├─ Header (title, subtitle, chips, switch, gear)
   │        ├─ Sections (left column)
   │        ├─ Right column (sections or preview)
   │        └─ Hint
   ├─ Top bar (breadcrumb, mode, Save, search)
   ├─ Sidebar (brand, groups, tabs, account)
   └─ Notifications / Indicators
```

---

## Window API

```lua
local window = Nerx:CreateWindow(Config)
```

| Key | Type | Default | Notes |
|---|---|---|---|
| `Title` | string | `"Nerx Beta"` | Brand title |
| `Subtitle` | string | `"Bloxstrike"` | Brand subtitle |
| `Size` | UDim2 | `1024×700` | Offset size recommended |
| `Logo` | string? | drawn N mark | Asset ID / custom asset image |
| `Mode` | string | `"legit"` | Current mode name |
| `Modes` | string[] | `{"legit","rage","hw"}` | Mode selector options |
| `Keybind` | string/Enum/false | `"Insert"` | Show/hide key |
| `AccountName` | string? | local display name | Bottom sidebar account |
| `AccountTag` | string? | `"Attached"` | Account status line |
| `StartHidden` | boolean | `false` | Start faded out |
| `Position` | UDim2? | centre | Initial window position |
| `OnSave` | function? | — | Top-bar Save callback |
| `OnModeChange` | function? | — | Receives selected mode |

Methods:

```lua
window:AddGroup(name)             -- returns group with :AddTab
window:AddTab(tabConfig)          -- adds to the current group
window:SetMode(mode, silent?)     -- update chip / dot colour
window:GetMode()                  -- current mode
window:Save()                     -- OnSave + toast
window:SetAccount({ Name = "...", Tag = "..." })
window:UpdateBrand(title, subtitle)
window:Toggle(visible?)           -- show/hide UI
window:Show()
window:Hide()
window:SelectTabByName(name)
window:OpenQuickMenu(anchorFrame)
window:SetSearch(query)
window:UpdateBreadcrumb()
```

### Groups and tabs

```lua
local features = window:AddGroup("FEATURES")
local tab = features:AddTab({
    Name = "Visuals",
    Icon = "eye",
})

local page = tab:AddSubTab({ Name = "Players" })
```

- `Tab:AddSection`, `AddSelector`, `AddPreview`, `AddBlock`, `SetHint`, `SetHeaderSwitch`, `SetHeaderIcon` proxy to the **current page**.
- Use `tab:GetPage()` to access the full Page API.
- A tab without sub-pages uses its default page directly.

Tab methods:

```lua
tab:AddSubTab({ Name, Title?, Subtitle?, RightWidth? })
tab:SetPage(page)
tab:GetPage()
tab:AddSection(...)
tab:AddSelector(...)
tab:AddPreview(...)
tab:AddBlock(...)
tab:SetHint(text)
tab:SetHeaderSwitch({ Text = "ESP", Default = true, Callback = fn })
tab:SetHeaderIcon("gear", callback)
```

---

## Page API

```lua
page:SetTitle("Visuals")
page:SetSubtitle("2 on de_mirage, 3 in all.")
page:SetHint("Click toggles · right-click for colour and style")

page:SetSectionStyle("flat")       -- "flat" | "card"
page:SetLeftWidth(620)             -- fixed single-column width
page:SetRightWidth(330)            -- right rail width
page:SetCustomMode()               -- returns a custom Canvas frame
```

### Header chips

```lua
page:AddSelector({
    Selected = "Enemies",
    Items = {
        { Name = "Enemies", Icon = "person", Color = Theme.Green, ShowDot = true },
        { Name = "Teammates", Icon = "person", Color = Theme.Green, ShowDot = true },
    },
    Callback = function(value, item) end,
})
```

Items support `Name`, `Icon`, `Value`, `Color`, `ShowDot`, `Selected`, and icon-only mode.

### Sections

```lua
local section = page:AddSection({
    Name = "CHAMS",
    Column = "left",   -- "left" | "right"
    Card = true,       -- false for a borderless block
    Flat = false,      -- true to override page style
})
```

```lua
local helper = page:AddSection({ Name = "HELPER", Column = "right" })
local record = page:AddSection({ Name = "RECORD", Column = "right", Card = false })
```

### Custom canvas

```lua
local canvas = page:SetCustomMode()
-- canvas is a regular Frame; build your own toolbar, cards, tables, etc.
local toolbar = Nerx.U.frame(canvas, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 28),
})
```

The custom canvas is inset **20 px** and is **784 × 612** inside the default 1024×700 window. It is useful for full-page layouts such as config grids, bind editors, theme galleries and player tables.

---

## Section components

All components return a handle. `Config.Flag` registers the handle in `Nerx.Flags`.

```lua
section:AddToggle({
    Name = "Glow",
    Default = true,
    Flag = "glow",
    Disabled = false,
    ShowOption = false,          -- adds a three-dot menu
    Swatch = Color3.fromRGB(160, 90, 255),
    Callback = function(value) end,
    ColorCallback = function(color) end,
    ToolTip = "Optional tooltip text",
})
```

```lua
section:AddSlider({
    Name = "FOV",
    Default = 180,
    Min = 1,
    Max = 360,
    Rounding = 0,
    Type = "u",
    Format = function(value) return tostring(value) .. "u" end,
    Nums = { [90] = "default" },
    Flag = "fov",
    Callback = function(value) end,
})
```

```lua
section:AddDropdown({
    Name = "Player",
    Options = { "Off", "Halftone" },
    Default = "Halftone",
    Width = 128,
    Disabled = false,
    ShowOption = true,
    Swatch = Color3.fromRGB(160, 90, 255),
    Callback = function(option) end,
})
```

```lua
section:AddKeybind({
    Name = "Throw key",
    Default = "V",
    Flag = "throw_key",
    Callback = function(name, keyCode) end,
})
```

```lua
section:AddInput({
    Name = "Config name",
    Default = "default",
    Placeholder = "type here",
    Callback = function(text) end,
})
```

```lua
section:AddAction({
    Name = "This map's lineups (2)",
    Button = "Upload",
    Disabled = false,
    Callback = function() end,
})

section:AddButton({
    Name = "Rejoin server",
    Icon = "arrow-spin-clockwise",
    Height = 34,
    Callback = function() end,
})
```

```lua
section:AddInfo({
    Name = "Connector",
    Value = "full, jump",
    Icon = "arrow-curl-to-right", -- optional
})

section:AddLabel("Static note", 30)
section:AddDescription("Wrapped description")
section:AddCustomRow(44, function(row)
    -- row is a Frame; place custom controls inside
end)
```

### Chips

```lua
section:AddChips({
    Multi = true,
    Items = {
        { Name = "Bounding box", Color = Theme.Red },
        { Name = "Name", Color = Theme.Cyan, Selected = true },
        { Name = "Distance", Color = Theme.Muted },
    },
    Callback = function(name, selected, color) end,
    ColorCallback = function(name, color) end,
})

section:AddHeaderAction({ Name = "Main", Dot = Theme.Green })
section:AddHeaderAction({ Name = "Flags", Icon = "plus-small" })
```

- Chips flow/wrap automatically.
- Right-click cycles chip colours.
- Header actions support `Name`, `Icon`, `Dot`, `Callback`.

Component handles expose:

```lua
component:GetValue()
component:SetValue(value)
component:AddOption("Reset", callback) -- extra three-dot menu item
```

Common fields: `Root`, `Options`, `Default`, `Name`. Toggle handles also expose `Swatch`, `Toggle`, `ToggleRoot`; dropdown handles expose `Field`, `Swatch`.

---

## Preview

```lua
local preview = page:AddPreview({
    Name = "xhook",
    Tags = {
        { Text = "Reloading", Color = Theme.Text },
        { Text = "Visible", Color = Theme.Green },
        { Text = "C4", Color = Theme.Red },
    },
    PlaceholderIcon = "square-dashed-person-standing",
    PlaceholderText = "character preview",
    Image = nil, -- optional replacement image
    ResetText = "Reset layout",
    OnReset = function() end,
    OnTool = function(index, name) end,
    Chips = {
        {
            Label = "LABEL",
            Items = {
                { Name = "Icon", Color = Theme.Violet, Selected = true },
                { Name = "Name", Color = Theme.Violet, Selected = true },
                { Name = "Timer", Color = Theme.Violet, Selected = true },
                { Name = "Distance", Color = Theme.Muted },
            },
        },
        {
            Label = "EXTRAS",
            Items = {
                { Name = "Timer bar", Color = Theme.Violet, Selected = true },
                { Name = "Defuse", Color = Theme.Violet, Selected = true },
            },
        },
    },
})
```

`Preview` methods:

```lua
preview:SetName("xhook")
preview:SetTags({ ... })
preview:SetTool(1)
preview:SetPlaceholder(icon, text)
preview:AddChipGroup({ Label = "EXTRAS", Items = { ... } })
preview:Layout()
```

The preview is a **stage layout** only. It draws the card, toolbar, tags, annotations, guide line, ground ellipse and chip rows. It does **not** create a 3D model. To add real rendering, parent your `ViewportFrame` or world model into:

```lua
preview.Stage   -- stage frame
preview.Card    -- full preview card
```

---

## Widgets

Widgets are the same primitives used inside sections, exposed for full custom pages.

```lua
local W = Nerx.Widgets

local toggle = W.Toggle(parent, true, function(value) end, false)
toggle.Root
toggle:GetValue()
toggle:SetValue(value)

local swatch = W.Swatch(parent, Color3.fromRGB(160, 90, 255), function(color) end)
swatch.Root
swatch:SetColor(color)

local button = W.Button(parent, "Import", function() end)
button.Root
button:SetText("Open")
button:SetDisabled(true)

local primary = W.PrimaryButton(parent, "+ New", 72, 28, function() end)
primary.Root

local dropdown = W.Dropdown(parent, {
    Options = { "None", "Enabled" },
    Default = "None",
    Width = 150,
    Callback = function(value) end,
})
dropdown:GetValue()
dropdown:SetValue("Enabled")

local segmented = W.Segmented(parent, {
    Width = 220,
    Height = 24,
    Items = { "Hold", "Toggle", "Double Click" },
    Selected = "Hold",
    Primary = false, -- true => light selected pill with dark text
    Callback = function(value) end,
})

local input = W.Input(parent, {
    Width = 180,
    Height = 28,
    Icon = "magnifying-glass",
    Placeholder = "Filter...",
    Callback = function(text) end,
})

local chip = W.Chip(parent, {
    Name = "Name",
    Color = Theme.Cyan,
    Selected = true,
})
```

---

## Theme, notifications, indicators

```lua
Nerx:SetAccent(Color3.fromRGB(235, 235, 240))
```

The token table is public:

```lua
Nerx.Theme.Window
Nerx.Theme.Surface
Nerx.Theme.Field
Nerx.Theme.Text
Nerx.Theme.Muted
Nerx.Theme.Accent
Nerx.Theme.Green
Nerx.Theme.Red
-- ...
```

`SetAccent` updates live components (toggle tracks, slider fill, chip borders, subtab ticks, logo dot, active cards built by your code if you register listeners via `Nerx.U.onAccent`). Base surfaces and typography are fixed at creation; change `Nerx.Theme` tokens **before** creating a window if you want a custom base palette.

```lua
local toast = Nerx:Notify({
    Title = "Configuration",
    Content = "Saved successfully",
    Icon = "circle-check",
    Color = Nerx.Theme.Green,
    Duration = 4,
})

local indicator = Nerx:CreateIndicator({
    Name = "Aim assist",
    Icon = "crosshairs",
    Color = Nerx.Theme.Red,
    Active = true,
})

indicator:SetActive(false)
indicator:SetText("Aim assist")
indicator:SetColor(Nerx.Theme.Cyan)
indicator:Destroy()
```

Other utility APIs:

```lua
Nerx.Version
Nerx.Icons
Nerx.Flags
Nerx.ScreenGui
Nerx.U              -- low-level helpers (frame/label/icon/tween/flow/popup...)
Nerx.Widgets
Nerx:GetNeverloseLogo()
Nerx:Unload()
```

`Nerx:Unload()` destroys the library ScreenGui and disconnects registered signals. After unloading, require/load the module again before creating another UI.

---

## Icons and assets

1. **Icons** come from Roblox's built-in **BuilderIcons** font (the same font family used by Neverlose).  
   Font path:
   ```
   rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json
   ```
2. Common glyphs:
   ```
   crosshairs, eye, gear, person, globe-detailed, location-pin-map,
   grid, chart-line, gift-box, file-box, key-caps-lock, paint-bucket,
   magnifying-glass, three-dots-horizontal, plus-small,
   chevron-large-*, square-dashed-person-standing
   ```
3. Optional Neverlose brand marks are from GitHub `tickcount/.p2c-icons` (MIT), stored in `assets/` with their license.  
   `Nerx:GetNeverloseLogo()` tries to fetch/cache them through `getcustomasset` when available; otherwise it returns `nil`.
4. The default brand mark is drawn in UI, so no image asset is required.

```lua
local window = Nerx:CreateWindow({
    Logo = Nerx:GetNeverloseLogo(), -- optional
})
```

---

## Compatibility and limits

- Designed for Roblox Luau. **Client-side only** — require it from a `LocalScript` or executor.
- Executor-only APIs (`gethui`, `get_hidden_gui`, `protect_gui`, `getcustomasset`) are optional; safe fallbacks are used, including a `PlayerGui` fallback when `CoreGui` cannot be used.
- Requiring the module prepares a protected `ScreenGui` container. Call `Nerx:CreateWindow` to display UI.
- The default size is **1024 × 700**; it scales down automatically on smaller viewports.
- No built-in config persistence, cloud sync, update checker, game logic or 3D renderer.
- The core library ships **no demo pages**; pages are built by the consumer with `AddTab` / `AddSection` / custom canvases. See `examples/` for complete menus.
- Theme switching in consumer UIs is normally implemented by calling `Nerx:SetAccent`; a full base-palette switch requires rebuilding the window after changing `Nerx.Theme` tokens.
- Preview stages are layout-only by default; supply `Image` or attach your own `ViewportFrame`.

---

## License

Code: **MIT** — see [`LICENSE`](LICENSE).  
Third-party assets and design credits: see [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

Nerx UI is an independent project. It is not affiliated with or endorsed by Neverlose.
