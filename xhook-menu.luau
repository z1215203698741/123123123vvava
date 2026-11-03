--[[
    Nerx UI · Xhook-style example menu
    --------------------------------------------------------------------------------
    A full menu example built entirely with the public Nerx UI library:
    AIMBOT (Legit / Rage), VISUALS (Players / World / Other / Render),
    MISC (Kreedz / Misc / Configs / Scripting / Console).

    The example mirrors the navigation and layout language of the current
    xhook.win CS 1.6 menu. It is a design showcase: no game logic is wired.

    Brand defaults to Nerx Beta / Bloxstrike. Set BRAND below to
    "xhook" / "Counter-Strike 1.6" if you want the exact reference branding.

    Run from an executor, or paste into a LocalScript after syncing
    NerxUI.luau as a ModuleScript. The library is loaded from GitHub if it is
    not available locally.
]]

local LIBRARY_URL = "https://raw.githubusercontent.com/z1215203698741/123123123vvava/main/NerxUI.luau"
local BRAND = {
    Title = "Nerx Beta",
    Subtitle = "Bloxstrike",
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function resolveLibrary()
    local module = ReplicatedStorage:FindFirstChild("NerxUI")
    if module and module:IsA("ModuleScript") then
        local ok, library = pcall(require, module)
        if ok and library then
            return library
        end
    end
    if getgenv and getgenv().NerxUI then
        return getgenv().NerxUI
    end
    for _, path in ipairs({ "NerxUI.luau", "../NerxUI.luau", "Nerx Beta Ui/NerxUI.luau" }) do
        if isfile and isfile(path) then
            local ok, library = pcall(function()
                return loadstring(readfile(path))()
            end)
            if ok and library then
                return library
            end
        end
    end
    local ok, library = pcall(function()
        return loadstring(game:HttpGet(LIBRARY_URL))()
    end)
    if ok and library then
        return library
    end
    error("[Nerx UI] Could not load NerxUI.luau. Keep it beside this example or set LIBRARY_URL.")
end

local Nerx = resolveLibrary()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local U = Nerx.U
local T = Nerx.Theme
local W = Nerx.Widgets
local F = Nerx.Fonts
local displayName = (LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name)) or "admin"

-- ---------------------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------------------

local function countBadge(parent, x, y, text)
    local width = U.measure(tostring(text), 9, F.Regular).X + 16
    local badge = U.frame(parent, {
        BackgroundColor3 = T.Field,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, 18),
    })
    U.corner(badge, 6)
    U.label(badge, {
        Text = tostring(text),
        TextSize = 9,
        TextColor3 = T.Muted,
        TextTransparency = 0.2,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromScale(1, 1),
    })
    return width
end

local function titleText(parent, text, count, status)
    local title = U.label(parent, {
        Text = text,
        Font = F.Bold,
        TextSize = 15,
        TextColor3 = T.Text,
        TextTransparency = 0.05,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(0, 28),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local width = U.measure(text, 15, F.Bold).X
    title.Size = UDim2.fromOffset(width + 2, 28)
    if count then
        countBadge(parent, width + 10, 5, count)
        width = width + 10 + U.measure(tostring(count), 9, F.Regular).X + 16
    end
    if status then
        local dot = U.frame(parent, {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = T.Faint,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(width + 12, 14),
            Size = UDim2.fromOffset(4, 4),
        })
        U.corner(dot, 2)
        U.label(parent, {
            Text = status,
            TextSize = 9.5,
            TextColor3 = T.Muted,
            TextTransparency = 0.35,
            Position = UDim2.fromOffset(width + 20, 0),
            Size = UDim2.fromOffset(160, 28),
        })
    end
    return title
end

local function surfaceCard(parent, x, y, width, height, options)
    options = options or {}
    local card = U.frame(parent, {
        BackgroundColor3 = options.Background or T.Surface,
        BackgroundTransparency = options.Transparency or 0,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        ClipsDescendants = options.Clip ~= false,
    })
    U.corner(card, options.Radius or 8)
    local stroke = U.stroke(card, options.StrokeColor or T.Stroke, options.StrokeTransparency or 0.55, 1)
    return card, stroke
end

local function toolbarButton(parent, text, rightOffset, y, width, height, callback, disabled)
    local api = W.Button(parent, text, callback, disabled)
    api.Root.AnchorPoint = Vector2.new(1, 0)
    api.Root.Position = UDim2.new(1, -rightOffset, 0, y)
    api.Root.Size = UDim2.fromOffset(width, height)
    return api
end

local function toolbarPrimary(parent, text, rightOffset, y, width, height, callback)
    local api = W.PrimaryButton(parent, text, width, height, callback)
    api.Root.AnchorPoint = Vector2.new(1, 0)
    api.Root.Position = UDim2.new(1, -rightOffset, 0, y)
    return api
end

local function filterField(parent, x, y, width, placeholder, height)
    local api = W.Input(parent, {
        Width = width,
        Height = height or 28,
        Placeholder = placeholder,
        Icon = "magnifying-glass",
    })
    api.Root.Position = UDim2.fromOffset(x, y)
    return api
end

local function token(parent, text, x, y, color, height)
    local h = height or 22
    local width = U.measure(text, 8.5, F.Bold).X + 16
    local frame = U.frame(parent, {
        BackgroundColor3 = T.Field,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, h),
    })
    U.corner(frame, 4)
    U.label(frame, {
        Text = text,
        Font = F.Bold,
        TextSize = 8.5,
        TextColor3 = color or T.Text,
        TextTransparency = 0.1,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromScale(1, 1),
    })
    return width
end

local function dividerLine(parent, x, y, width, transparency)
    U.frame(parent, {
        BackgroundColor3 = T.StrokeSoft,
        BackgroundTransparency = transparency or 0.45,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, 1),
    })
end

local function subsectionLabel(section, text)
    section:AddCustomRow(24, function(row)
        U.label(row, {
            Text = text,
            Font = F.Bold,
            TextSize = 9,
            TextColor3 = T.Muted,
            TextTransparency = 0.35,
            Position = UDim2.fromOffset(section.Inset or 12, 0),
            Size = UDim2.fromOffset(220, 24),
        })
    end)
end

-- Four metric cells used by Render and Recorder.
local function metricGrid(section, items)
    section:AddCustomRow(58, function(row)
        local inset = section.Inset or 12
        local gap = 6
        local width = 406
        local cellWidth = (width - gap * (#items - 1)) / #items
        for index, item in ipairs(items) do
            local cell = U.frame(row, {
                BackgroundColor3 = T.Field,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(inset + (index - 1) * (cellWidth + gap), 6),
                Size = UDim2.fromOffset(cellWidth, 44),
            })
            U.corner(cell, 5)
            U.label(cell, {
                Text = item.Label,
                Font = F.Bold,
                TextSize = 7.5,
                TextColor3 = T.Muted,
                TextTransparency = 0.45,
                Position = UDim2.fromOffset(8, 5),
                Size = UDim2.fromOffset(cellWidth - 16, 12),
            })
            U.label(cell, {
                Text = item.Value,
                Font = F.Bold,
                TextSize = 12,
                TextColor3 = T.Text,
                TextTransparency = 0.1,
                Position = UDim2.fromOffset(8, 17),
                Size = UDim2.fromOffset(cellWidth - 16, 16),
            })
            if item.Sub then
                U.label(cell, {
                    Text = item.Sub,
                    TextSize = 7.5,
                    TextColor3 = T.Faint,
                    TextTransparency = 0.25,
                    Position = UDim2.fromOffset(8, 32),
                    Size = UDim2.fromOffset(cellWidth - 16, 11),
                })
            end
        end
    end)
end

-- One labelled row of chips, as used by Visuals › Other › POST FX.
local function chipGroup(section, label, items, height)
    section:AddCustomRow(height or 62, function(row)
        local inset = section.Inset or 12
        local x = inset
        local y = 5
        U.label(row, {
            Text = label,
            Font = F.Bold,
            TextSize = 8,
            TextColor3 = T.Muted,
            TextTransparency = 0.45,
            Position = UDim2.fromOffset(inset, y + 6),
            Size = UDim2.fromOffset(46, 14),
        })
        x = inset + 50
        for _, item in ipairs(items) do
            local chip, width = W.Chip(row, item, {
                Height = 22,
                TextSize = 10,
            })
            if x + width > (section.Card.AbsoluteSize.X or 430) - inset then
                x = inset + 50
                y = y + 28
            end
            chip.Root.Position = UDim2.fromOffset(x, y)
            x = x + width + 4
        end
    end)
end

local function notify(title, content, icon, color)
    Nerx:Notify({
        Title = title,
        Content = content,
        Icon = icon or "circle-i",
        Color = color or T.Muted,
    })
end

-- ---------------------------------------------------------------------------------------
-- Window
-- ---------------------------------------------------------------------------------------

local window = Nerx:CreateWindow({
    Title = BRAND.Title,
    Subtitle = BRAND.Subtitle,
    Size = UDim2.fromOffset(1024, 700),
    Mode = "newgen",
    Modes = { "newgen", "legit", "rage" },
    Keybind = "Insert",
    AccountTag = "In match · awp_roo",
    OnSave = function()
        notify("Configuration", "Saved example settings", "circle-check", T.Green)
    end,
    OnModeChange = function(mode)
        notify("Mode", "Switched to " .. tostring(mode), "two-arrows-loop-clockwise", mode == "rage" and T.Red or T.Amber)
    end,
})

-- ---------------------------------------------------------------------------------------
-- AIMBOT · Legit
-- ---------------------------------------------------------------------------------------

local aimGroup = window:AddGroup("AIMBOT")
do
local legitTab = aimGroup:AddTab({ Name = "Legit", Icon = "crosshairs" })
local legitPage = legitTab:GetPage()
legitPage:SetTitle("Legit")
legitPage:SetSectionStyle("flat")
legitPage:SetHint("Click toggles · right-click values for colour and style")
legitPage:AddSelector({
    Selected = "Rifles",
    Items = { { Name = "Pistols" }, { Name = "SMG" }, { Name = "Rifles" }, { Name = "Shotgun" }, { Name = "Sniper" } },
    Callback = function(value)
        notify("Legit", "Weapon class: " .. tostring(value), "crosshairs", T.Muted)
    end,
})

local legitMain = legitPage:AddSection({ Name = "MAIN" })
legitMain:AddToggle({ Name = "Enabled", Default = true, Flag = "legit_enabled" })
subsectionLabel(legitMain, "AIMBOT")
legitMain:AddToggle({ Name = "Enabled", Default = true, Flag = "legit_aimbot" })
legitMain:AddDropdown({
    Name = "Activation",
    Options = { "Always on", "On key" },
    Default = "Always on",
    Width = 138,
})
legitMain:AddDropdown({
    Name = "Hitboxes",
    Options = { "Head, Neck, Chest", "Head only", "Head, Neck" },
    Default = "Head, Neck, Chest",
    Width = 138,
})
legitMain:AddSlider({ Name = "Field of view", Default = 20, Min = 1, Max = 180, Rounding = 0, Type = "°" })
legitMain:AddSlider({ Name = "Smoothing", Default = 35, Min = 0, Max = 100, Rounding = 0, Type = "%" })
legitMain:AddSlider({ Name = "Reaction time", Default = 100, Min = 0, Max = 500, Rounding = 0, Type = " ms" })
legitMain:AddSlider({ Name = "Target switch delay", Default = 200, Min = 0, Max = 500, Rounding = 0, Type = " ms" })
legitMain:AddSlider({ Name = "First bullet delay", Default = 0, Min = 0, Max = 500, Rounding = 0, Type = " ms" })
legitMain:AddDropdown({
    Name = "Recoil control",
    Options = { "None", "Predicted", "Pattern" },
    Default = "None",
    Width = 138,
})
legitMain:AddToggle({ Name = "Quick scope", Default = false })

local trigger = legitPage:AddSection({ Name = "TRIGGERBOT", Column = "right" })
trigger:AddToggle({ Name = "Enabled", Default = true })
trigger:AddToggle({ Name = "Enabled for weapon", Default = true })
trigger:AddDropdown({
    Name = "Hitboxes",
    Options = { "Head, Neck, Chest", "Head only", "Head, Neck" },
    Default = "Head, Neck, Chest",
    Width = 128,
})
trigger:AddSlider({ Name = "Hit chance", Default = 100, Min = 0, Max = 100, Rounding = 0, Type = "%" })
trigger:AddKeybind({ Name = "Seed", Default = "R" })
trigger:AddToggle({ Name = "Accuracy boost", Default = true })
trigger:AddDropdown({
    Name = "Min damage",
    Options = { "Off", "50", "70", "90" },
    Default = "Off",
    Width = 128,
})
trigger:AddDropdown({
    Name = "Reaction time",
    Options = { "Instant", "Humanized" },
    Default = "Instant",
    Width = 128,
})
trigger:AddSlider({ Name = "Burst time", Default = 80, Min = 0, Max = 300, Rounding = 0, Type = " ms" })

local legitOther = legitPage:AddSection({ Name = "OTHER", Column = "right" })
legitOther:AddToggle({ Name = "Visualize FOV", Default = true })
legitOther:AddDropdown({
    Name = "Standalone recoil control",
    Options = { "None", "Predicted", "Pattern" },
    Default = "None",
    Width = 128,
})

end

-- ---------------------------------------------------------------------------------------
-- AIMBOT · Rage
-- ---------------------------------------------------------------------------------------

local rageTab = aimGroup:AddTab({ Name = "Rage", Icon = "crosshairs" })
local rageMain = rageTab:AddSubTab({ Name = "Main", Title = "Rage", Icon = "crosshairs" })
do
rageMain:SetSectionStyle("flat")
rageMain:SetHint("Rage settings are visual examples · no game logic is wired")

local general = rageMain:AddSection({ Name = "GENERAL" })
general:AddToggle({ Name = "Enabled", Default = true, Flag = "rage_enabled" })
general:AddDropdown({
    Name = "Aim type",
    Options = { "Perfect silent (Safe)", "Perfect silent", "Silent" },
    Default = "Perfect silent (Safe)",
    Width = 148,
})
general:AddSlider({ Name = "Field of view", Default = 180, Min = 1, Max = 360, Rounding = 0, Type = "u" })
general:AddDropdown({
    Name = "Automatic scope",
    Options = { "None", "Always", "On shot" },
    Default = "None",
    Width = 148,
})

local accuracy = rageMain:AddSection({ Name = "ACCURACY" })
accuracy:AddToggle({ Name = "Remove spread", Default = true })
accuracy:AddDropdown({ Name = "Pitch resolver", Options = { "None", "Up", "Down" }, Default = "None", Width = 148 })
accuracy:AddDropdown({ Name = "Yaw resolver", Options = { "None", "Left", "Right" }, Default = "None", Width = 148 })
accuracy:AddDropdown({ Name = "Remove recoil", Options = { "None", "Predicted", "Perfect" }, Default = "Predicted", Width = 148 })
accuracy:AddSlider({ Name = "Delay shot", Default = 0, Min = 0, Max = 300, Rounding = 0, Type = " ms" })
accuracy:AddToggle({ Name = "Reaim detector bypass", Default = false })

local antiAim = rageMain:AddSection({ Name = "ANTI-AIM", Column = "right" })
antiAim:AddHeaderAction({ Name = "Stand", Dot = T.Green })
antiAim:AddHeaderAction({ Name = "Move", Dot = T.Muted })
antiAim:AddToggle({ Name = "Enabled", Default = true })
antiAim:AddDropdown({ Name = "Pitch", Options = { "None", "Up", "Down", "Fake" }, Default = "None", Width = 128 })
antiAim:AddDropdown({ Name = "Yaw", Options = { "Backwards", "Left", "Right", "Jitter" }, Default = "Backwards", Width = 128 })
antiAim:AddDropdown({ Name = "Desync", Options = { "Off", "Custom", "Random" }, Default = "Custom", Width = 128 })
antiAim:AddDropdown({ Name = "Side", Options = { "Right", "Left", "000" }, Default = "Right", Width = 128 })

local fakelag = rageMain:AddSection({ Name = "FAKELAG", Column = "right" })
fakelag:AddToggle({ Name = "Enabled", Default = true })
fakelag:AddDropdown({
    Name = "Type",
    Options = { "Break lag compensation", "Continuous", "Random" },
    Default = "Break lag compensation",
    Width = 128,
})
fakelag:AddDropdown({ Name = "Triggers", Options = { "In move, In air", "Always", "On shot" }, Default = "In move, In air", Width = 128 })
fakelag:AddSlider({ Name = "Choke limit", Default = 22, Min = 1, Max = 32, Rounding = 0, Type = " cmd" })

local rageWeapon = rageTab:AddSubTab({ Name = "Weapon", Title = "Rage", Icon = "gear" })
rageWeapon:SetSectionStyle("flat")
local weaponMain = rageWeapon:AddSection({ Name = "WEAPON" })
rageWeapon:AddSelector({
    Selected = "AK-47",
    Items = { { Name = "AK-47" }, { Name = "M4A1" }, { Name = "AWP" }, { Name = "Deagle" } },
})
weaponMain:AddToggle({ Name = "Enabled", Default = true })
weaponMain:AddDropdown({ Name = "Aim type", Options = { "Perfect silent", "Silent", "Assist" }, Default = "Perfect silent", Width = 148 })
weaponMain:AddSlider({ Name = "Field of view", Default = 180, Min = 1, Max = 360, Rounding = 0, Type = "u" })
weaponMain:AddSlider({ Name = "Delay shot", Default = 0, Min = 0, Max = 300, Rounding = 0, Type = " ms" })
local weaponAccuracy = rageWeapon:AddSection({ Name = "ACCURACY", Column = "right" })
weaponAccuracy:AddToggle({ Name = "Remove spread", Default = true })
weaponAccuracy:AddDropdown({ Name = "Pitch resolver", Options = { "None", "Up", "Down" }, Default = "None", Width = 148 })
weaponAccuracy:AddDropdown({ Name = "Yaw resolver", Options = { "None", "Left", "Right" }, Default = "None", Width = 148 })
weaponAccuracy:AddToggle({ Name = "Reaim detector bypass", Default = false })

end

-- ---------------------------------------------------------------------------------------
-- VISUALS · Players
-- ---------------------------------------------------------------------------------------

local visualsGroup = window:AddGroup("VISUALS")
local visualsTab = visualsGroup:AddTab({ Name = "Visuals", Icon = "eye" })
local playersPage = visualsTab:AddSubTab({ Name = "Players", Title = "Visuals", Icon = "person" })
playersPage:SetSectionStyle("flat")
playersPage:SetHint("Click toggles · right-click for colour and style · drag them on the preview")
playersPage:AddSelector({
    Selected = "Enemies",
    Items = {
        { Name = "Enemies", Icon = "person", Color = T.Green, ShowDot = true, Selected = true },
        { Name = "Local", Icon = "person", Color = T.Muted },
        { Name = "Teammates", Icon = "person", Color = T.Cyan },
    },
    Callback = function(value)
        notify("Selection", tostring(value) .. " list", "person", T.Green)
    end,
})
playersPage:SetHeaderSwitch({ Text = "ESP", Default = true })
playersPage:SetHeaderIcon("paint-brush", function()
    notify("Material Creator", "Material editor placeholder", "paint-brush", T.Violet)
end)

do
local enemies = playersPage:AddSection({ Name = "ENEMIES" })
enemies:AddDropdown({
    Name = "Offscreen arrow",
    Options = { "Enabled", "Disabled" },
    Default = "Enabled",
    ShowOption = true,
    Swatch = T.Red,
    Width = 128,
})
enemies:AddDropdown({
    Name = "Sounds",
    Options = { "Enabled", "Disabled" },
    Default = "Disabled",
    Width = 128,
})

local chams = playersPage:AddSection({ Name = "CHAMS" })
chams:AddDropdown({ Name = "Player", Options = { "Neon", "Halftone", "Off" }, Default = "Neon", ShowOption = true, Swatch = T.Violet, Width = 128 })
chams:AddDropdown({ Name = "Behind walls", Options = { "Neon", "Halftone", "Off" }, Default = "Neon", ShowOption = true, Swatch = T.Black, Width = 128 })
chams:AddDropdown({ Name = "On shot", Options = { "Glow", "Default", "Off" }, Default = "Glow", Width = 128 })
chams:AddDropdown({ Name = "History", Options = { "Glow", "Default", "Off" }, Default = "Glow", Width = 128 })
chams:AddDropdown({ Name = "Ragdolls", Options = { "Cel Glossy", "Default", "Off" }, Default = "Cel Glossy", Width = 128 })

local elements = playersPage:AddSection({ Name = "ELEMENTS" })
elements:AddHeaderAction({ Name = "Main", Dot = T.Green })
elements:AddHeaderAction({ Name = "Actions", Dot = T.Muted })
elements:AddHeaderAction({ Name = "Flags", Dot = T.Muted })
elements:AddHeaderAction({ Name = "Aimbot", Dot = T.Muted })
elements:AddChips({
    Items = {
        { Name = "Bounding box", Color = T.Red },
        { Name = "Name", Color = T.Cyan, Selected = true },
        { Name = "Distance", Color = T.Muted, Selected = true },
        { Name = "Health bar", Color = T.Green, Selected = true },
        { Name = "Armor bar", Color = T.Cyan },
        { Name = "Money", Color = T.Amber },
        { Name = "Weapon text", Color = T.Muted },
        { Name = "Weapon icon", Color = T.Cyan },
        { Name = "Skeleton", Color = T.Muted },
        { Name = "Skeleton backtrack", Color = T.Muted },
    },
    Callback = function(name, state)
        -- Hook player element rendering here.
    end,
})

playersPage:AddPreview({
    Name = "target",
    Tags = {
        { Text = "Reloading", Color = T.Text },
        { Text = "Visible", Color = T.Green },
        { Text = "C4", Color = T.Red },
        { Text = "100 m", Color = T.Muted },
    },
    PlaceholderIcon = "square-dashed-person-standing",
    PlaceholderText = "character preview",
    OnReset = function()
        notify("Preview", "Layout reset", "arrow-spin-counter-clockwise-15", T.Muted)
    end,
    Chips = {
        {
            Label = "LABEL",
            Items = {
                { Name = "Icon", Color = T.Violet, Selected = true },
                { Name = "Name", Color = T.Violet, Selected = true },
                { Name = "Timer", Color = T.Violet, Selected = true },
                { Name = "Distance", Color = T.Muted },
            },
        },
        {
            Label = "EXTRAS",
            Items = {
                { Name = "Timer bar", Color = T.Violet, Selected = true },
                { Name = "Progress bar", Color = T.Violet },
                { Name = "Damage", Color = T.Muted },
                { Name = "Off-screen arrow", Color = T.Muted },
                { Name = "Snapline", Color = T.Violet },
                { Name = "Ground ring", Color = T.Muted },
            },
        },
    },
})

end

-- ---------------------------------------------------------------------------------------
-- VISUALS · World
-- ---------------------------------------------------------------------------------------

do
local worldPage = visualsTab:AddSubTab({ Name = "World", Title = "Visuals", Icon = "globe-detailed" })
worldPage:SetSectionStyle("flat")
worldPage:SetHint("Bomb styling and world ESP · preview is layout-only")
worldPage:AddSelector({
    Selected = "Bomb",
    Items = { { Name = "Bomb", Icon = "gift-box" }, { Name = "Weapons", Icon = "crosshairs" }, { Name = "Grenades", Icon = "circle-play" } },
    Callback = function(value)
        notify("World filter", tostring(value), "globe-detailed", T.Cyan)
    end,
})
worldPage:SetHeaderSwitch({ Text = "World ESP", Default = true })

local bomb = worldPage:AddSection({ Name = "BOMB" })
bomb:AddToggle({ Name = "Enabled", Default = true })
bomb:AddSlider({
    Name = "Max distance",
    Default = 250,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Type = " m",
    Format = function(value)
        if value >= 1000 then
            return "global"
        end
        return tostring(value) .. " m"
    end,
})
bomb:AddDropdown({
    Name = "Offscreen arrow",
    Options = { "Enabled", "Disabled" },
    Default = "Disabled",
    ShowOption = true,
    Swatch = T.Violet,
    Width = 128,
})
bomb:AddToggle({ Name = "Bomb indicator", Default = true })
bomb:AddToggle({ Name = "Defuse indicator", Default = true })
bomb:AddToggle({ Name = "Bomb defused", Default = true })

local worldChams = worldPage:AddSection({ Name = "CHAMS" })
worldChams:AddDropdown({ Name = "Model", Options = { "Off", "Fresnel" }, Default = "Off", ShowOption = true, Swatch = T.Violet, Width = 128, Disabled = true })
worldChams:AddDropdown({ Name = "Behind walls", Options = { "Off", "Fresnel" }, Default = "Fresnel", ShowOption = true, Swatch = T.Violet, Width = 128 })

local worldGlow = worldPage:AddSection({ Name = "GLOW" })
worldGlow:AddToggle({ Name = "Glow", Default = true, ShowOption = true, Swatch = T.Violet })
worldGlow:AddToggle({ Name = "Glow behind walls", Default = false, Disabled = true, Swatch = T.Violet })

worldPage:AddPreview({
    Name = "Bomb A",
    Tags = {
        { Text = "31.4G", Color = T.Muted },
        { Text = "37 hp", Color = T.Text },
    },
    PlaceholderIcon = "gift-box",
    PlaceholderText = "object preview",
    Chips = {
        {
            Label = "LABEL",
            Items = {
                { Name = "Icon", Color = T.Violet, Selected = true },
                { Name = "Name", Color = T.Violet, Selected = true },
                { Name = "Timer", Color = T.Violet, Selected = true },
                { Name = "Distance", Color = T.Muted },
            },
        },
        {
            Label = "EXTRAS",
            Items = {
                { Name = "Timer bar", Color = T.Violet, Selected = true },
                { Name = "Defuse", Color = T.Violet, Selected = true },
                { Name = "Blast damage", Color = T.Violet, Selected = true },
                { Name = "Off-screen arrow", Color = T.Muted },
                { Name = "Snapline", Color = T.Violet, Selected = true },
            },
        },
    },
})

end

-- ---------------------------------------------------------------------------------------
-- VISUALS · Other
-- ---------------------------------------------------------------------------------------

do
local otherPage = visualsTab:AddSubTab({ Name = "Other", Title = "Visuals", Icon = "square-dashed-person-standing" })
otherPage:SetSectionStyle("flat")
otherPage:SetHint("Click chips to toggle · right-click chips to cycle their colour")

local view = otherPage:AddSection({ Name = "VIEW" })
view:AddHeaderAction({ Name = "Camera", Dot = T.Green })
view:AddHeaderAction({ Name = "Viewmodel", Dot = T.Muted })
view:AddSlider({ Name = "Render FOV", Default = 90, Min = 60, Max = 120, Rounding = 0 })
view:AddToggle({ Name = "Thirdperson", Default = false, ShowOption = true })
view:AddToggle({ Name = "First person legs", Default = true })
view:AddToggle({ Name = "Aspect ratio", Default = false, ShowOption = true })
view:AddDropdown({ Name = "Visual Recoil", Options = { "No Recoil", "Default" }, Default = "No Recoil", Width = 138 })
view:AddDropdown({
    Name = "Removals",
    Options = { "Screen fade, Motion blur", "Screen fade", "None" },
    Default = "Screen fade, Motion blur",
    ShowOption = true,
    Width = 138,
})

local hud = otherPage:AddSection({ Name = "HUD", Column = "right" })
hud:AddHeaderAction({ Name = "Reticle", Dot = T.Muted })
hud:AddHeaderAction({ Name = "Screen", Dot = T.Muted })
hud:AddToggle({
    Name = "Crosshair",
    Default = true,
    ShowOption = true,
    Swatch = T.Violet,
    ColorCallback = function(color)
        notify("Crosshair", "Colour updated", "paint-brush", color)
    end,
})
hud:AddToggle({
    Name = "Scope",
    Default = true,
    ShowOption = true,
    Swatch = T.Violet,
})
hud:AddDropdown({
    Name = "Hitmarker",
    Options = { "2D, 3D", "2D", "3D" },
    Default = "2D, 3D",
    ShowOption = true,
    Width = 128,
})

local postFx = otherPage:AddSection({ Name = "POST FX" })
postFx:AddHeaderAction({ Name = "3 on", Dot = T.Green })
chipGroup(postFx, "IMAGE", {
    { Name = "FXAA", Color = T.Muted, Selected = true },
    { Name = "Bloom", Color = T.Muted },
    { Name = "Colour grade", Color = T.Muted, Selected = true },
    { Name = "Auto exposure", Color = T.Muted },
    { Name = "Outline edges", Color = T.Red, Selected = true },
})
chipGroup(postFx, "LIGHT", {
    { Name = "Ambient occlusion", Color = T.Muted },
    { Name = "God rays", Color = T.Muted },
    { Name = "Reflections", Color = T.Muted },
    { Name = "Player shadows", Color = T.Muted },
    { Name = "Depth fog", Color = T.Muted },
})
chipGroup(postFx, "LENS", {
    { Name = "Motion blur", Color = T.Muted },
    { Name = "Depth of field", Color = T.Muted, Selected = true },
    { Name = "Kill effects", Color = T.Violet, Selected = true },
    { Name = "Debug log", Color = T.Muted },
})

local miscellaneous = otherPage:AddSection({ Name = "MISCELLANEOUS", Column = "right" })
miscellaneous:AddHeaderAction({ Name = "World", Dot = T.Green })
miscellaneous:AddHeaderAction({ Name = "Display", Dot = T.Muted })
miscellaneous:AddInfo({ Name = "Ambience", Value = "Global · 1 on" })
miscellaneous:AddToggle({ Name = "Skybox", Default = true })
miscellaneous:AddDropdown({ Name = "World colour", Options = { "Off", "Tint", "Custom" }, Default = "Off", ShowOption = true, Swatch = T.Violet, Width = 128 })
miscellaneous:AddDropdown({ Name = "Smoke", Options = { "Off", "Default", "Custom" }, Default = "Off", Width = 128 })
miscellaneous:AddDropdown({ Name = "Bullets", Options = { "Off", "Tracers", "Custom" }, Default = "Off", ShowOption = true, Width = 128 })

end

-- ---------------------------------------------------------------------------------------
-- VISUALS · Render
-- ---------------------------------------------------------------------------------------

do
local renderPage = visualsTab:AddSubTab({ Name = "Render", Title = "Visuals", Icon = "paint-bucket" })
renderPage:SetSectionStyle("flat")
renderPage:SetHint("World renderer · post effects · atmosphere")
renderPage:AddSelector({
    Selected = "World",
    Items = {
        { Name = "World", Icon = "globe-detailed", Color = T.Green, ShowDot = true, Selected = true },
        { Name = "Lighting", Icon = "circle-play", Color = T.Muted, ShowDot = true },
        { Name = "Shadows", Icon = "eye", Color = T.Muted, ShowDot = true },
        { Name = "Bake & GI", Icon = "grid", Color = T.Muted, ShowDot = true },
        { Name = "Surface", Icon = "square-dashed-person-standing", Color = T.Muted, ShowDot = true },
        { Name = "Scene", Icon = "chart-line", Color = T.Muted, ShowDot = true },
    },
    Callback = function(value)
        notify("Renderer", tostring(value) .. " settings", "paint-bucket", T.Muted)
    end,
})
renderPage:SetHeaderSwitch({ Text = "World renderer", Default = true })

local worldRenderer = renderPage:AddSection({ Name = "WORLD RENDERER" })
worldRenderer:AddHeaderAction({ Name = "Active", Dot = T.Green })
metricGrid(worldRenderer, {
    { Label = "TRIANGLES", Value = "21.5k" },
    { Label = "BATCHES", Value = "2.1k" },
    { Label = "CPU / FRAME", Value = "0.08 ms" },
    { Label = "PATH", Value = "Shader +..." },
})
worldRenderer:AddToggle({ Name = "Textured", Default = true })
worldRenderer:AddToggle({ Name = "Lightmaps", Default = true })
worldRenderer:AddSlider({ Name = "Light gain", Default = 1, Min = 0, Max = 2, Rounding = 2 })
worldRenderer:AddSlider({ Name = "Ambient", Default = 0, Min = 0, Max = 2, Rounding = 2 })
worldRenderer:AddSlider({ Name = "Lightmap fix", Default = 29, Min = 0, Max = 100, Rounding = 0 })

local shading = renderPage:AddSection({ Name = "SHADING & TINT" })
shading:AddDropdown({ Name = "Shade mode", Options = { "Normal", "Flat", "Textured" }, Default = "Normal", Width = 138 })
shading:AddToggle({ Name = "Colour tint", Default = true, Swatch = T.White })
shading:AddCustomRow(34, function(row)
    local inset = shading.Inset or 12
    U.label(row, {
        Text = "Tint colour",
        TextSize = 12.5,
        TextColor3 = T.Text,
        TextTransparency = 0.03,
        Position = UDim2.fromOffset(inset, 0),
        Size = UDim2.new(1, -inset * 2, 1, 0),
    })
    local swatch = W.Swatch(row, Color3.fromRGB(228, 228, 235), function(color)
        notify("Tint", "Colour updated", "paint-brush", color)
    end)
    swatch.Root.AnchorPoint = Vector2.new(1, 0.5)
    swatch.Root.Position = UDim2.new(1, -inset, 0.5, 0)
    swatch.Root.Size = UDim2.fromOffset(18, 18)
end)

local culling = renderPage:AddSection({ Name = "CULLING & PERFORMANCE", Column = "right" })
culling:AddToggle({ Name = "Frustum culling", Default = true })
culling:AddToggle({ Name = "PVS culling (perf)", Default = false })
culling:AddSlider({
    Name = "Render distance",
    Default = 0,
    Min = 0,
    Max = 4000,
    Rounding = 0,
    Type = " m",
    Format = function(value)
        if value <= 0 then
            return "unlimited"
        end
        return tostring(value) .. " m"
    end,
})
culling:AddToggle({ Name = "Performance log", Default = false })

local decals = renderPage:AddSection({ Name = "DECALS & DYNAMIC LIGHTS", Column = "right" })
decals:AddToggle({ Name = "World decals", Default = true })
decals:AddToggle({ Name = "Decal crash guard (fallback)", Default = true })
decals:AddToggle({ Name = "Dynamic lights", Default = true })
decals:AddSlider({ Name = "Dynamic light strength", Default = 1, Min = 0, Max = 2, Rounding = 2 })

end

-- ---------------------------------------------------------------------------------------
-- MISC · Kreedz
-- ---------------------------------------------------------------------------------------

local miscGroup = window:AddGroup("MISC")
local kreedzTab = miscGroup:AddTab({ Name = "Kreedz", Icon = "chart-line" })
local movementPage = kreedzTab:AddSubTab({ Name = "Movement", Title = "Kreedz", Icon = "chart-line" })
movementPage:SetSectionStyle("flat")
movementPage:SetHint("Movement toolkit · values are visual examples")

do
local movement = movementPage:AddSection({ Name = "MOVEMENT" })
movement:AddToggle({ Name = "Bunny Hop", Default = true })
movement:AddToggle({ Name = "Strafe Hack", Default = false })
movement:AddToggle({ Name = "Strafe Helper", Default = true })
movement:AddToggle({ Name = "Ground Strafe", Default = false })
movement:AddDropdown({ Name = "Auto strafe", Options = { "Off", "Legit", "Fast" }, Default = "Legit", Width = 138 })

local tricks = movementPage:AddSection({ Name = "TRICKS", Column = "right" })
tricks:AddToggle({ Name = "Edge Bug", Default = false })
tricks:AddToggle({ Name = "Jump Bug", Default = false })
tricks:AddToggle({ Name = "Edge Jump", Default = false })
tricks:AddToggle({ Name = "Jump Stats", Default = true })
tricks:AddToggle({ Name = "Fast Run", Default = false })
tricks:AddToggle({ Name = "Slow Walk", Default = true })
tricks:AddToggle({ Name = "Air Stuck", Default = false })
end


-- MISC · Main

local miscTab = miscGroup:AddTab({ Name = "Misc", Icon = "gear" })
local miscMain = miscTab:AddSubTab({ Name = "Main", Title = "Misc", Icon = "gear" })
miscMain:SetSectionStyle("flat")
miscMain:SetHint("Automation, utilities and server-side quality-of-life settings")

do
local generalMisc = miscMain:AddSection({ Name = "GENERAL" })
generalMisc:AddToggle({ Name = "Knifebot", Default = false })
generalMisc:AddToggle({ Name = "Fakelatency", Default = false })
generalMisc:AddToggle({ Name = "Speedhack", Default = false })
generalMisc:AddToggle({ Name = "Fakewalk", Default = false })
generalMisc:AddToggle({ Name = "Frame skipper", Default = false })
generalMisc:AddToggle({ Name = "Chat spam", Default = false })
generalMisc:AddToggle({ Name = "Namestealer", Default = false })
generalMisc:AddToggle({ Name = "Name scroller", Default = false })
generalMisc:AddToggle({ Name = "Event log", Default = true })
generalMisc:AddToggle({ Name = "Freecam", Default = false })
generalMisc:AddToggle({ Name = "Freelook", Default = false })
generalMisc:AddDropdown({ Name = "Server models", Options = { "Don't allow server models", "Allow", "Custom" }, Default = "Don't allow server models", Width = 158 })

local automation = miscMain:AddSection({ Name = "AUTOMATION", Column = "right" })
automation:AddToggle({ Name = "Automatic reload", Default = false })
automation:AddToggle({ Name = "Automatic pistol", Default = false })
automation:AddToggle({ Name = "Blockbot", Default = false })
automation:AddToggle({ Name = "SteamID spoofer", Default = false })
automation:AddToggle({ Name = "Ticket spoofer", Default = false })
automation:AddToggle({ Name = "Consistency bypass", Default = false })
automation:AddToggle({ Name = "Remove interpolation", Default = false })
automation:AddToggle({ Name = "Remove extrapolation", Default = false })
automation:AddToggle({ Name = "Hitsound", Default = true })
automation:AddToggle({ Name = "Killsound", Default = false })
automation:AddToggle({ Name = "Particle limiter", Default = false })
automation:AddToggle({ Name = "Custom weapon calibration", Default = false })
end


-- MISC · Server

do
local serverPage = miscTab:AddSubTab({ Name = "Server", Title = "Server", Icon = "globe-detailed" })
serverPage:SetSectionStyle("flat")
serverPage:SetHint("Connection and session preferences")

local serverSettings = serverPage:AddSection({ Name = "SERVER" })
serverSettings:AddDropdown({ Name = "Region", Options = { "Auto", "EU", "NA", "Asia" }, Default = "Auto", Width = 148 })
serverSettings:AddDropdown({ Name = "Mode", Options = { "Match", "Kreedz", "Deathmatch" }, Default = "Match", Width = 148 })
serverSettings:AddToggle({ Name = "Auto reconnect", Default = true })
serverSettings:AddButton({
    Name = "Rejoin server",
    Icon = "arrow-spin-clockwise",
    Callback = function()
        notify("Server", "Rejoin is a design placeholder", "arrow-spin-clockwise", T.Muted)
    end,
})

local session = serverPage:AddSection({ Name = "SESSION", Column = "right" })
session:AddInfo({ Name = "Build", Value = "Nerx " .. tostring(Nerx.Version) })
session:AddInfo({ Name = "Keybind", Value = "Insert" })
session:AddInfo({ Name = "Renderer", Value = "2D interface" })
session:AddDescription("The interface scales with the viewport. Drag it by the top bar or the brand block.")

end

-- ---------------------------------------------------------------------------------------
-- MISC · Kreedz › Movement Recorder
-- ---------------------------------------------------------------------------------------

do
local recorderPage = kreedzTab:AddSubTab({ Name = "Movement Recorder", Title = "Recorder", Icon = "chart-line" })
local rec = recorderPage:SetCustomMode()

titleText(rec, "Recorder", 3, "idle")
local recFilter = filterField(rec, 210, 0, 168, "Filter runs...")
local recSort = W.Segmented(rec, {
    Width = 150,
    Height = 28,
    Items = { "Name", "Longest" },
    Selected = "Name",
})
recSort.Root.Position = UDim2.fromOffset(390, 0)
toolbarButton(rec, "Settings", 138, 0, 76, 28, function()
    notify("Recorder", "Recorder settings placeholder", "gear", T.Muted)
end)
toolbarPrimary(rec, "Record", 0, 0, 82, 28, function()
    notify("Recorder", "Recording is not wired in this example", "circle-play", T.Red)
end)

local selectedRun = "default"
local runTitle
local runSub
local runStats = {}

local runs = {
    { Name = "default", Time = "0:05.0", Frames = "1,159 frames", Fps = "234 fps", Selected = true },
    { Name = "ebtest", Time = "0:03.7", Frames = "1,021 frames", Fps = "276 fps" },
    { Name = "Jumping", Time = "0:14.1", Frames = "5,812 frames", Fps = "412 fps" },
}

local runCards = {}
for index, run in ipairs(runs) do
    local y = 44 + (index - 1) * 64
    local card, stroke = surfaceCard(rec, 0, y, 214, 56, {
        Radius = 6,
        Background = run.Selected and T.SurfaceHover or T.Surface,
        StrokeColor = run.Selected and T.Accent or T.Stroke,
        StrokeTransparency = run.Selected and 0.25 or 0.6,
    })
    U.label(card, {
        Text = run.Name,
        Font = F.Bold,
        TextSize = 11,
        TextColor3 = T.Text,
        TextTransparency = 0.05,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.fromOffset(120, 16),
    })
    U.label(card, {
        Text = run.Time .. "  ·  " .. run.Frames,
        TextSize = 8.5,
        TextColor3 = T.Muted,
        TextTransparency = 0.35,
        Position = UDim2.fromOffset(14, 29),
        Size = UDim2.fromOffset(160, 14),
    })
    local badgeWidth = token(card, "aa 100", 158, 8, T.Muted, 18)
    local entry = { Run = run, Card = card, Stroke = stroke }
    runCards[index] = entry
    U.inputButton(card, function()
        selectedRun = run.Name
        for _, other in ipairs(runCards) do
            other.Stroke.Color = other.Run.Name == selectedRun and T.Accent or T.Stroke
            other.Stroke.Transparency = other.Run.Name == selectedRun and 0.25 or 0.6
            other.Card.BackgroundColor3 = other.Run.Name == selectedRun and T.SurfaceHover or T.Surface
        end
        if runTitle then
            runTitle.Text = run.Name
            runSub.Text = "saved · " .. run.Fps .. " · " .. run.Frames
        end
    end)
end

U.onAccent(function(color)
    for _, entry in ipairs(runCards) do
        if entry.Run.Name == selectedRun then
            entry.Stroke.Color = color
        end
    end
end)

runTitle = U.label(rec, {
    Text = "default",
    Font = F.Bold,
    TextSize = 13,
    TextColor3 = T.Text,
    TextTransparency = 0.05,
    Position = UDim2.fromOffset(230, 44),
    Size = UDim2.fromOffset(150, 20),
})
runSub = U.label(rec, {
    Text = "saved · 234 fps · 1,159 frames",
    TextSize = 9,
    TextColor3 = T.Muted,
    TextTransparency = 0.35,
    Position = UDim2.fromOffset(230, 64),
    Size = UDim2.fromOffset(250, 14),
})

local recTrim = toolbarButton(rec, "Trim", 316, 44, 46, 24, function()
    notify("Recorder", "Trim editor placeholder", "chart-line", T.Muted)
end)
local recOrbit = toolbarButton(rec, "Orbit", 264, 44, 46, 24, function() end)
local recTop = toolbarButton(rec, "Top", 212, 44, 46, 24, function() end)
local recPov = toolbarButton(rec, "POV", 160, 44, 46, 24, function() end)
local recLoad = toolbarPrimary(rec, "Load", 40, 43, 56, 26, function()
    notify("Recorder", "Loaded " .. selectedRun, "circle-check", T.Green)
end)

local preview = U.frame(rec, {
    BackgroundColor3 = Color3.fromRGB(7, 7, 9),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(230, 92),
    Size = UDim2.fromOffset(554, 292),
    ClipsDescendants = true,
})
U.corner(preview, 7)
U.stroke(preview, T.Stroke, 0.6, 1)
for index = 1, 12 do
    U.frame(preview, {
        BackgroundColor3 = Color3.fromRGB(22, 22, 26),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.new(index / 13, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
    })
end
for index = 1, 7 do
    U.frame(preview, {
        BackgroundColor3 = Color3.fromRGB(22, 22, 26),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, index / 8, 0),
        Size = UDim2.new(1, 0, 0, 1),
    })
end
local blocks = {
    { 24, 150, 88, 38 }, { 124, 50, 46, 66 }, { 200, 166, 74, 34 },
    { 336, 42, 58, 44 }, { 430, 74, 46, 52 }, { 478, 196, 52, 38 },
    { 308, 224, 96, 36 }, { 402, 156, 32, 48 },
}
for _, block in ipairs(blocks) do
    local piece = U.frame(preview, {
        BackgroundColor3 = Color3.fromRGB(32, 32, 37),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(block[1], block[2]),
        Size = UDim2.fromOffset(block[3], block[4]),
    })
    U.corner(piece, 2)
    U.stroke(piece, Color3.fromRGB(58, 58, 66), 0.55, 1)
end
local pathPoints = {
    { 106, 222 }, { 172, 196 }, { 216, 214 }, { 282, 150 },
    { 334, 186 }, { 398, 160 }, { 452, 108 }, { 510, 140 },
}
for _, point in ipairs(pathPoints) do
    local dot = U.frame(preview, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.Green,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(point[1], point[2]),
        Size = UDim2.fromOffset(4, 4),
    })
    U.corner(dot, 2)
end
local pathColors = { T.Green, T.Amber, T.Violet }
for index = 1, 3 do
    U.frame(preview, {
        BackgroundColor3 = pathColors[index],
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(106, 196 + index * 12),
        Size = UDim2.fromOffset(390, 1),
    })
end
U.label(preview, {
    Text = "0:00.00",
    TextSize = 9,
    TextColor3 = T.Text,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(10, 266),
    Size = UDim2.fromOffset(54, 16),
})

local playRow = U.frame(rec, {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(230, 392),
    Size = UDim2.fromOffset(554, 24),
})
U.icon(playRow, "circle-play", 12, T.Text, {
    Position = UDim2.fromOffset(0, 5),
    Size = UDim2.fromOffset(14, 18),
})
U.label(playRow, {
    Text = "0:00.00 / 0:04.96",
    Font = F.Mono,
    TextSize = 9,
    TextColor3 = T.Muted,
    TextTransparency = 0.2,
    Position = UDim2.fromOffset(22, 4),
    Size = UDim2.fromOffset(140, 18),
})
U.frame(playRow, {
    BackgroundColor3 = T.Field,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(170, 11),
    Size = UDim2.fromOffset(384, 2),
})
U.frame(playRow, {
    BackgroundColor3 = T.Green,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(170, 11),
    Size = UDim2.fromOffset(116, 2),
})

local recStats = {
    { "TIME", "0:04.96" }, { "FRAMES", "1,159" }, { "DISTANCE", "1,706 u" },
    { "TOP SPEED", "435 u/s" }, { "JUMPS", "1" }, { "AIR ACCEL", "100" },
}
for index, item in ipairs(recStats) do
    local x = 230 + (index - 1) * 93
    U.label(rec, {
        Text = item[1],
        Font = F.Bold,
        TextSize = 7.5,
        TextColor3 = T.Muted,
        TextTransparency = 0.4,
        Position = UDim2.fromOffset(x, 424),
        Size = UDim2.fromOffset(88, 12),
    })
    U.label(rec, {
        Text = item[2],
        Font = F.Bold,
        TextSize = 11,
        TextColor3 = T.Text,
        TextTransparency = 0.05,
        Position = UDim2.fromOffset(x, 439),
        Size = UDim2.fromOffset(88, 16),
    })
end
dividerLine(rec, 230, 466, 554, 0.55)

local nextRun = W.Input(rec, {
    Width = 300,
    Height = 26,
    Placeholder = "Next run name (blank...)",
})
nextRun.Root.Position = UDim2.fromOffset(0, 548)
local recSave = W.Button(rec, "Save", function()
    notify("Recorder", "Run metadata saved (design placeholder)", "circle-check", T.Green)
end)
recSave.Root.Position = UDim2.fromOffset(310, 548)
recSave.Root.Size = UDim2.fromOffset(64, 26)

end

-- ---------------------------------------------------------------------------------------
-- MISC · Skin Changer
-- ---------------------------------------------------------------------------------------

do
local skinPage = miscTab:AddSubTab({ Name = "Skin Changer", Title = "Skin changer", Icon = "gift-box" })
local skin = skinPage:SetCustomMode()

titleText(skin, "Skin changer", 4, "applied")
local skinSearch = filterField(skin, 230, 0, 210, "Search weapons & skins...")
local skinTabs = W.Segmented(skin, {
    Width = 130,
    Height = 28,
    Items = { "All", "Applied" },
    Selected = "All",
})
skinTabs.Root.Position = UDim2.fromOffset(456, 0)
toolbarButton(skin, "Reset all", 0, 0, 82, 28, function()
    notify("Skin changer", "All skins reset (design placeholder)", "arrow-spin-clockwise", T.Muted)
end)

local selectedWeapon = "AK-47"
local selectedSkin = "aknostrock"
local weaponTitle
local weaponSub

local function loadoutHeader(y, label, count)
    U.label(skin, {
        Text = label,
        Font = F.Bold,
        TextSize = 8.5,
        TextColor3 = T.Muted,
        TextTransparency = 0.35,
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.fromOffset(70, 16),
    })
    U.icon(skin, "chevron-large-down", 8, T.Muted, {
        Position = UDim2.fromOffset(68, y - 1),
        Size = UDim2.fromOffset(10, 16),
        TextTransparency = 0.5,
    })
    U.label(skin, {
        Text = count,
        TextSize = 8.5,
        TextColor3 = T.Faint,
        TextTransparency = 0.3,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(0, 244, 0, y),
        Size = UDim2.fromOffset(44, 16),
        TextXAlignment = Enum.TextXAlignment.Right,
    })
end

local function loadoutRow(y, name, sub, selected)
    local row = U.frame(skin, {
        BackgroundColor3 = selected and T.SurfaceHover or T.White,
        BackgroundTransparency = selected and 0 or 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.fromOffset(246, 28),
    })
    U.corner(row, 4)
    if selected then
        U.stroke(row, T.Accent, 0.35, 1)
    end
    U.icon(row, "crosshairs", 10, selected and T.Text or T.Muted, {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.fromOffset(12, 28),
        TextTransparency = selected and 0.1 or 0.45,
    })
    U.label(row, {
        Text = name,
        TextSize = 10,
        TextColor3 = T.Text,
        TextTransparency = selected and 0.03 or 0.2,
        Position = UDim2.fromOffset(28, sub and 2 or 0),
        Size = UDim2.fromOffset(190, sub and 13 or 28),
    })
    if sub then
        U.label(row, {
            Text = sub,
            TextSize = 8,
            TextColor3 = T.Muted,
            TextTransparency = 0.4,
            Position = UDim2.fromOffset(28, 14),
            Size = UDim2.fromOffset(190, 12),
        })
    end
    if selected then
        U.frame(row, {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = T.Text,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(5, 5),
        })
    end
    U.inputButton(row, function()
        selectedWeapon = name
        if weaponTitle then
            weaponTitle.Text = name
            weaponSub.Text = sub or "1 skin available"
        end
        notify("Skin changer", "Selected " .. name, "crosshairs", T.Muted)
    end)
end

local leftY = 44
U.label(skin, {
    Text = "LOADOUT",
    Font = F.Bold,
    TextSize = 8.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.4,
    Position = UDim2.fromOffset(0, leftY),
    Size = UDim2.fromOffset(80, 14),
})
U.label(skin, {
    Text = "right-click = default",
    TextSize = 8,
    TextColor3 = T.Faint,
    TextTransparency = 0.4,
    Position = UDim2.fromOffset(80, leftY),
    Size = UDim2.fromOffset(160, 14),
})
leftY = leftY + 24
loadoutHeader(leftY, "PLAYER", "1 / 2")
leftY = leftY + 20
loadoutRow(leftY, "Player model", "emogign", true)
leftY = leftY + 30
loadoutRow(leftY, "Viewmodel hands", "2 hands models available")
leftY = leftY + 32
loadoutHeader(leftY, "PISTOLS", "1 / 6")
leftY = leftY + 20
loadoutRow(leftY, "Glock-18", "1 skin available")
leftY = leftY + 30
loadoutRow(leftY, "USP-S", "no skins in folder")
leftY = leftY + 32
loadoutHeader(leftY, "SMGS", "6")
leftY = leftY + 20
loadoutRow(leftY, "MP5", "no skins in folder")
leftY = leftY + 32
loadoutHeader(leftY, "RIFLES", "1 / 6")
leftY = leftY + 20
loadoutRow(leftY, "M4A1", "1 skin available")
leftY = leftY + 30
loadoutRow(leftY, "Galil", "no skins in folder")
leftY = leftY + 30
loadoutRow(leftY, "FAMAS", "no skins in folder")
leftY = leftY + 30
loadoutRow(leftY, "AUG", "no skins in folder")
leftY = leftY + 30
loadoutRow(leftY, "AK-47", "aknostrock", true)
leftY = leftY + 30
loadoutRow(leftY, "SG 552", "no skins in folder")

local rightX = 270
local rightW = 514
U.label(skin, {
    Text = "RIFLES",
    Font = F.Bold,
    TextSize = 8.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.4,
    Position = UDim2.fromOffset(rightX, 48),
    Size = UDim2.fromOffset(80, 14),
})
weaponTitle = U.label(skin, {
    Text = "AK-47",
    Font = F.Bold,
    TextSize = 15,
    TextColor3 = T.Text,
    TextTransparency = 0.03,
    Position = UDim2.fromOffset(rightX, 62),
    Size = UDim2.fromOffset(160, 18),
})
weaponSub = U.label(skin, {
    Text = "Skin · aknostrock",
    TextSize = 9,
    TextColor3 = T.Muted,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(rightX, 81),
    Size = UDim2.fromOffset(200, 14),
})
U.label(skin, {
    Text = "World",
    TextSize = 9,
    TextColor3 = T.Muted,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(rightX + 250, 68),
    Size = UDim2.fromOffset(38, 16),
})
U.label(skin, {
    Text = "In hands",
    TextSize = 9,
    TextColor3 = T.Muted,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(rightX + 310, 68),
    Size = UDim2.fromOffset(48, 16),
})
toolbarButton(skin, "Open folder", 0, 58, 72, 24, function()
    notify("Skins", "Folder browser placeholder", "file-box", T.Muted)
end)

local gunPreview = U.frame(skin, {
    BackgroundColor3 = Color3.fromRGB(10, 10, 12),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(rightX, 104),
    Size = UDim2.fromOffset(rightW, 238),
    ClipsDescendants = true,
})
U.corner(gunPreview, 7)
U.stroke(gunPreview, T.Stroke, 0.55, 1)
U.frame(gunPreview, {
    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, 0, 1, 0),
})
local gunY = 106
U.frame(gunPreview, {
    BackgroundColor3 = Color3.fromRGB(92, 92, 102),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(90, gunY),
    Size = UDim2.fromOffset(330, 22),
})
U.frame(gunPreview, {
    BackgroundColor3 = Color3.fromRGB(64, 64, 74),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(130, gunY + 22),
    Size = UDim2.fromOffset(44, 58),
})
U.frame(gunPreview, {
    BackgroundColor3 = Color3.fromRGB(44, 44, 52),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(84, gunY + 14),
    Size = UDim2.fromOffset(58, 14),
})
U.frame(gunPreview, {
    BackgroundColor3 = Color3.fromRGB(112, 112, 124),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(420, gunY + 7),
    Size = UDim2.fromOffset(110, 6),
})
U.frame(gunPreview, {
    BackgroundColor3 = T.Violet,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(280, gunY + 4),
    Size = UDim2.fromOffset(70, 4),
})
U.label(gunPreview, {
    Text = "drag: rotate · right-drag: pan · wheel: zoom · middle: reset",
    TextSize = 8,
    TextColor3 = T.Faint,
    TextTransparency = 0.3,
    TextXAlignment = Enum.TextXAlignment.Center,
    Position = UDim2.new(0, 0, 1, -22),
    Size = UDim2.new(1, 0, 0, 14),
})

local skinsY = 354
U.label(skin, {
    Text = "SKINS FOR AK-47 · 1 in folder",
    Font = F.Bold,
    TextSize = 8.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.4,
    Position = UDim2.fromOffset(rightX, skinsY),
    Size = UDim2.fromOffset(220, 14),
})
U.label(skin, {
    Text = "click to apply · Left / Right step through",
    TextSize = 8,
    TextColor3 = T.Faint,
    TextTransparency = 0.35,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(0, rightX + rightW, 0, skinsY),
    Size = UDim2.fromOffset(220, 14),
    TextXAlignment = Enum.TextXAlignment.Right,
})

local skinCards = {}
local function skinCard(x, name, selected, dashed)
    local card = U.frame(skin, {
        BackgroundColor3 = selected and T.SurfaceHover or T.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, skinsY + 20),
        Size = UDim2.fromOffset(150, 82),
    })
    U.corner(card, 6)
    local stroke = U.stroke(card, selected and T.Accent or T.Stroke, selected and 0.25 or 0.6, 1)
    if dashed then
        U.label(card, {
            Text = "+",
            TextSize = 20,
            TextColor3 = T.Muted,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            Position = UDim2.fromOffset(0, 6),
            Size = UDim2.new(1, 0, 0, 60),
        })
        U.label(card, {
            Text = "Add a skin",
            TextSize = 9,
            TextColor3 = T.Muted,
            TextTransparency = 0.35,
            TextXAlignment = Enum.TextXAlignment.Center,
            Position = UDim2.new(0, 0, 1, -18),
            Size = UDim2.new(1, 0, 0, 14),
        })
    else
        U.frame(card, {
            BackgroundColor3 = Color3.fromRGB(34, 34, 39),
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(8, 8),
            Size = UDim2.fromOffset(134, 50),
        })
        U.corner(card, 4)
        U.frame(card, {
            BackgroundColor3 = Color3.fromRGB(92, 92, 102),
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(26, 30),
            Size = UDim2.fromOffset(96, 8),
        })
        U.label(card, {
            Text = name,
            TextSize = 9,
            TextColor3 = T.Text,
            TextTransparency = 0.2,
            Position = UDim2.fromOffset(8, 63),
            Size = UDim2.fromOffset(134, 13),
        })
    end
    U.inputButton(card, function()
        if dashed then
            notify("Skins", "Drop a folder with a .mdl", "file-box", T.Muted)
        else
            selectedSkin = name
            for _, other in ipairs(skinCards) do
                other.Stroke.Color = other.Name == selectedSkin and T.Accent or T.Stroke
                other.Stroke.Transparency = other.Name == selectedSkin and 0.25 or 0.6
                other.Card.BackgroundColor3 = other.Name == selectedSkin and T.SurfaceHover or T.Surface
            end
            weaponSub.Text = "Skin · " .. name
        end
    end)
    skinCards[#skinCards + 1] = { Name = name, Card = card, Stroke = stroke }
end
skinCard(rightX, "default", false)
skinCard(rightX + 158, "aknostrock", true)
skinCard(rightX + 316, "add", false, true)

local soundToggle = W.Toggle(skin, true, function(value)
    notify("Skins", "Use the skin's own sounds: " .. tostring(value), "circle-i", T.Muted)
end)
soundToggle.Root.Position = UDim2.fromOffset(rightX, 488)
U.label(skin, {
    Text = "Use the skin's own sounds",
    TextSize = 9.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(rightX + 40, 488),
    Size = UDim2.fromOffset(220, 18),
})
U.label(skin, {
    Text = "models\\ak47\\aknostrock\\v_ak47.mdl",
    Font = F.Mono,
    TextSize = 8.5,
    TextColor3 = T.Faint,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(rightX, 516),
    Size = UDim2.fromOffset(rightW, 14),
})
end

-- ---------------------------------------------------------------------------------------
-- MISC · Player List
-- ---------------------------------------------------------------------------------------

do
local playerPage = miscTab:AddSubTab({ Name = "Player List", Title = "Player List", Icon = "person" })
local playerCanvas = playerPage:SetCustomMode()

local playerSearch = filterField(playerCanvas, 0, 0, 214, "Search players...")
local playerTabs = W.Segmented(playerCanvas, {
    Width = 190,
    Height = 28,
    Items = { "ALL", "CT", "T", "SPEC" },
    Selected = "ALL",
})
playerTabs.Root.Position = UDim2.fromOffset(224, 0)
local playerOptions = W.Button(playerCanvas, "OPTIONS", function()
    notify("Player list", "Column options are layout-only", "three-sliders-horizontal", T.Muted)
end)
playerOptions.Root.Position = UDim2.fromOffset(424, 0)
playerOptions.Root.Size = UDim2.fromOffset(92, 28)

local function playerCounter(x, color, value)
    local group = U.frame(playerCanvas, {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -x, 0, 0),
        Size = UDim2.fromOffset(34, 28),
    })
    local dot = U.frame(group, {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(6, 6),
    })
    U.corner(dot, 3)
    U.label(group, {
        Text = tostring(value),
        TextSize = 9.5,
        TextColor3 = T.Muted,
        TextTransparency = 0.2,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.fromOffset(20, 28),
    })
end
playerCounter(96, T.Cyan, 0)
playerCounter(56, T.Red, 0)
playerCounter(16, T.Text, 1)

local splitY = 44
dividerLine(playerCanvas, 0, splitY, 784, 0.5)

local leftTable = U.frame(playerCanvas, {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, splitY + 14),
    Size = UDim2.fromOffset(466, 536),
})
local rightTable = U.frame(playerCanvas, {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(482, splitY + 14),
    Size = UDim2.fromOffset(302, 536),
})

local function tableHeader(parent, text, width)
    U.frame(parent, {
        BackgroundColor3 = T.Text,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 2),
        Size = UDim2.fromOffset(2, 10),
    })
    U.label(parent, {
        Text = text,
        Font = F.Bold,
        TextSize = 9.5,
        TextColor3 = T.Text,
        TextTransparency = 0.25,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.fromOffset(width - 8, 14),
    })
    dividerLine(parent, 0, 16, width, 0.55)
end
tableHeader(leftTable, "PLAYERS", 466)
tableHeader(rightTable, "PLAYER", 302)

U.label(leftTable, {
    Text = "COUNTER-TERRORISTS",
    Font = F.Bold,
    TextSize = 8.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.4,
    Position = UDim2.fromOffset(0, 28),
    Size = UDim2.fromOffset(240, 14),
})
U.label(leftTable, {
    Text = "1 / 1 alive",
    TextSize = 8.5,
    TextColor3 = T.Faint,
    TextTransparency = 0.35,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 28),
    Size = UDim2.fromOffset(80, 14),
    TextXAlignment = Enum.TextXAlignment.Right,
})

local playerRow = U.frame(leftTable, {
    BackgroundColor3 = T.White,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 48),
    Size = UDim2.fromOffset(466, 38),
})
U.corner(playerRow, 5)

local avatarFrame = U.frame(playerRow, {
    BackgroundColor3 = T.Field,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(2, 5),
    Size = UDim2.fromOffset(28, 28),
    ClipsDescendants = true,
})
U.corner(avatarFrame, 14)
local avatarIcon = U.icon(avatarFrame, "person", 13, T.Muted, {
    TextTransparency = 0.35,
    Size = UDim2.fromScale(1, 1),
})
local avatarImage = U.new("ImageLabel", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Image = "",
    ScaleType = Enum.ScaleType.Crop,
    Size = UDim2.fromScale(1, 1),
}, avatarFrame)
U.corner(avatarImage, 14)
task.spawn(function()
    if not LocalPlayer then
        return
    end
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok and image then
        avatarImage.Image = image
        avatarIcon.Visible = false
    end
end)

U.label(playerRow, {
    Text = displayName,
    Font = F.Bold,
    TextSize = 11.5,
    TextColor3 = T.Text,
    TextTransparency = 0.05,
    Position = UDim2.fromOffset(38, 6),
    Size = UDim2.fromOffset(150, 14),
})
U.label(playerRow, {
    Text = "YOU",
    Font = F.Bold,
    TextSize = 7.5,
    TextColor3 = T.Green,
    TextTransparency = 0.2,
    Position = UDim2.fromOffset(40 + U.measure(displayName, 11.5, F.Bold).X + 6, 7),
    Size = UDim2.fromOffset(30, 12),
})
U.label(playerRow, {
    Text = "0 / 0",
    TextSize = 9.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.35,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -68, 0, 8),
    Size = UDim2.fromOffset(40, 14),
    TextXAlignment = Enum.TextXAlignment.Right,
})
local pingDot = U.frame(playerRow, {
    AnchorPoint = Vector2.new(1, 0),
    BackgroundColor3 = T.Green,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -46, 0, 12),
    Size = UDim2.fromOffset(5, 5),
})
U.corner(pingDot, 3)
U.label(playerRow, {
    Text = "0 ms",
    TextSize = 9.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.35,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -2, 0, 8),
    Size = UDim2.fromOffset(36, 14),
    TextXAlignment = Enum.TextXAlignment.Right,
})
U.inputButton(playerRow, function()
    notify("Player list", displayName .. " selected", "person", T.Green)
end)

U.label(leftTable, {
    Text = "SPECTATORS",
    TextSize = 9,
    TextColor3 = T.Muted,
    TextTransparency = 0.4,
    Position = UDim2.fromOffset(0, 104),
    Size = UDim2.fromOffset(200, 14),
})
U.label(leftTable, {
    Text = "1",
    TextSize = 9,
    TextColor3 = T.Muted,
    TextTransparency = 0.4,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 104),
    Size = UDim2.fromOffset(30, 14),
    TextXAlignment = Enum.TextXAlignment.Right,
})
dividerLine(leftTable, 0, 126, 466, 0.55)
U.label(leftTable, {
    Text = "Select a player on the left. Player details appear here.",
    TextSize = 9.5,
    TextColor3 = T.Faint,
    TextTransparency = 0.35,
    TextXAlignment = Enum.TextXAlignment.Center,
    Position = UDim2.fromOffset(0, 410),
    Size = UDim2.fromOffset(466, 16),
})

-- Right detail card
local detailName = U.label(rightTable, {
    Text = "PLAYER #1",
    Font = F.Bold,
    TextSize = 11,
    TextColor3 = T.Text,
    TextTransparency = 0.1,
    Position = UDim2.fromOffset(0, 28),
    Size = UDim2.fromOffset(180, 16),
})
U.label(rightTable, {
    Text = "YOU",
    Font = F.Bold,
    TextSize = 7.5,
    TextColor3 = T.Green,
    TextTransparency = 0.2,
    Position = UDim2.fromOffset(190, 30),
    Size = UDim2.fromOffset(28, 12),
})
U.label(rightTable, {
    Text = "P_USP",
    TextSize = 9,
    TextColor3 = T.Muted,
    TextTransparency = 0.35,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 30),
    Size = UDim2.fromOffset(60, 14),
    TextXAlignment = Enum.TextXAlignment.Right,
})

local detailActions = { "Copy name", "Copy SID", "Copy SID64", "Open profile" }
for index, text in ipairs(detailActions) do
    local x = (index - 1) * 74
    local button = W.Button(rightTable, text, function()
        notify("Player list", text .. " (design placeholder)", "person", T.Muted)
    end)
    button.Root.Position = UDim2.fromOffset(x, 54)
    button.Root.Size = UDim2.fromOffset(70, 22)
end

local function detailLabel(y, text, value, x, width)
    U.label(rightTable, {
        Text = text,
        Font = F.Bold,
        TextSize = 7.5,
        TextColor3 = T.Muted,
        TextTransparency = 0.4,
        Position = UDim2.fromOffset(x or 0, y),
        Size = UDim2.fromOffset(width or 80, 12),
    })
    U.label(rightTable, {
        Text = value,
        TextSize = 10,
        TextColor3 = T.Text,
        TextTransparency = 0.15,
        Position = UDim2.fromOffset(x or 0, y + 14),
        Size = UDim2.fromOffset(width or 80, 16),
    })
end
detailLabel(98, "HEALTH", "100", 0, 78)
detailLabel(98, "ARMOR", "None", 100, 78)
detailLabel(98, "MONEY", "$800", 200, 80)
detailLabel(150, "KILLS / DEATHS", "0 / 0", 0, 120)
detailLabel(150, "PING", "0", 140, 60)
detailLabel(150, "STATUS", "ALIVE", 210, 80)
dividerLine(rightTable, 0, 194, 302, 0.55)

local networkRows = {
    { "STEAMID", "STEAM_0:1:00000000" },
    { "SID64", "76561198000000000" },
    { "USERINFO", "bottomcolor = 6" },
    { "USERINFO", "cl_dlmax = 512" },
    { "USERINFO", "rate = 30000" },
    { "USERINFO", "model = urban" },
}
for index, row in ipairs(networkRows) do
    local y = 208 + (index - 1) * 30
    U.label(rightTable, {
        Text = row[1],
        Font = F.Bold,
        TextSize = 7.5,
        TextColor3 = T.Muted,
        TextTransparency = 0.4,
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.fromOffset(70, 12),
    })
    U.label(rightTable, {
        Text = row[2],
        Font = F.Mono,
        TextSize = 8.5,
        TextColor3 = T.Text,
        TextTransparency = 0.2,
        Position = UDim2.fromOffset(0, y + 13),
        Size = UDim2.fromOffset(302, 14),
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end
U.label(rightTable, {
    Text = "NETWORK",
    Font = F.Bold,
    TextSize = 8.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.4,
    Position = UDim2.fromOffset(0, 194),
    Size = UDim2.fromOffset(90, 14),
})

end

-- ---------------------------------------------------------------------------------------
-- CONFIGS · Settings
-- ---------------------------------------------------------------------------------------

local configsTab = miscGroup:AddTab({ Name = "Configs", Icon = "file-box" })
local configsSettings = configsTab:AddSubTab({ Name = "Settings", Title = "Configs", Icon = "file-box" })
do
local configs = configsSettings:SetCustomMode()

titleText(configs, "Configs", 14)
local configFilter = filterField(configs, 100, 0, 154, "Filter configs...")
local configSort = W.Segmented(configs, {
    Width = 116,
    Height = 28,
    Items = { "Name", "Recent" },
    Selected = "Name",
})
configSort.Root.Position = UDim2.fromOffset(264, 0)
toolbarButton(configs, "Open folder", 238, 0, 84, 28, function()
    notify("Configs", "Folder browser placeholder", "file-box", T.Muted)
end)
toolbarButton(configs, "Import", 146, 0, 58, 28, function()
    notify("Configs", "Import config placeholder", "file-box", T.Muted)
end)
toolbarPrimary(configs, "+ New", 0, 0, 72, 28, function()
    notify("Configs", "New config slot", "plus-small", T.Accent)
end)

local banner = U.frame(configs, {
    BackgroundColor3 = Color3.fromRGB(34, 29, 19),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 44),
    Size = UDim2.new(1, 0, 0, 34),
})
U.corner(banner, 6)
U.stroke(banner, Color3.fromRGB(96, 76, 38), 0.4, 1)
local bannerDot = U.frame(banner, {
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = T.Amber,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 12, 0.5, 0),
    Size = UDim2.fromOffset(6, 6),
})
U.corner(bannerDot, 3)
U.label(banner, {
    Text = 'Unsaved changes in "newnew"',
    TextSize = 10,
    TextColor3 = T.Text,
    TextTransparency = 0.15,
    Position = UDim2.fromOffset(26, 0),
    Size = UDim2.fromOffset(210, 34),
})
U.label(banner, {
    Text = "12 values changed",
    TextSize = 9.5,
    TextColor3 = T.Amber,
    TextTransparency = 0.2,
    Position = UDim2.fromOffset(212, 0),
    Size = UDim2.fromOffset(120, 34),
})
toolbarButton(banner, "Revert", 88, 5, 68, 24, function()
    notify("Configs", "Changes reverted", "arrow-spin-counter-clockwise-15", T.Muted)
end)
toolbarPrimary(banner, "Save", 12, 4, 68, 26, function()
    window:Save()
end)

local function configCover(parent, colorA, colorB)
    local cover = U.frame(parent, {
        BackgroundColor3 = colorA,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 92),
        ClipsDescendants = true,
    })
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    gradient.Rotation = 90
    gradient.Parent = cover
    U.frame(cover, {
        BackgroundColor3 = Color3.fromRGB(20, 20, 24),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(34, 68),
    })
    for index = 1, 4 do
        U.frame(cover, {
            BackgroundColor3 = Color3.fromRGB(38, 38, 44),
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(54, 16 + (index - 1) * 15),
            Size = UDim2.fromOffset(70 + index * 12, 5),
        })
    end
    U.frame(cover, {
        BackgroundColor3 = Color3.fromRGB(48, 48, 56),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(210, 44),
        Size = UDim2.fromOffset(70, 5),
    })
    U.frame(cover, {
        BackgroundColor3 = T.Green,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 14),
        Size = UDim2.fromOffset(12, 12),
    })
end

local configCards = {}
local activeConfig = "newnew"
local configData = {
    { Name = "Default", Saved = "Last saved 25 Jun 2026", Size = "120.3 KB", Values = "3,218 values", ColorA = Color3.fromRGB(24, 41, 58), ColorB = Color3.fromRGB(12, 16, 23), Status = "ACTIVE" },
    { Name = "newnew", Saved = "Last saved 20 Aug 2026", Size = "136.2 KB", Values = "3,540 values", ColorA = Color3.fromRGB(24, 46, 34), ColorB = Color3.fromRGB(12, 17, 15), Status = "UNSAVED" },
    { Name = "idk", Saved = "Last saved 6 Mar 2026", Size = "72.6 KB", Values = "2,066 values", ColorA = Color3.fromRGB(54, 45, 25), ColorB = Color3.fromRGB(18, 16, 12) },
    { Name = "legit", Saved = "Last saved yesterday", Size = "179.4 KB", Values = "4,645 values", ColorA = Color3.fromRGB(45, 31, 56), ColorB = Color3.fromRGB(16, 12, 20), Status = "ACTIVE" },
    { Name = "rage", Saved = "Last saved 3 days ago", Size = "141.8 KB", Values = "3,812 values", ColorA = Color3.fromRGB(59, 27, 27), ColorB = Color3.fromRGB(20, 12, 12) },
    { Name = "ebtest", Saved = "Last saved 8 days ago", Size = "98.2 KB", Values = "2,614 values", ColorA = Color3.fromRGB(25, 39, 47), ColorB = Color3.fromRGB(12, 16, 18) },
}

local function configCard(index, data)
    local column = (index - 1) % 2
    local rowIndex = math.floor((index - 1) / 2)
    local card, stroke = surfaceCard(configs, column * 394, 92 + rowIndex * 158, 382, 150, {
        Radius = 7,
        Background = T.Surface,
        Clip = true,
    })
    configCover(card, data.ColorA, data.ColorB)
    U.label(card, {
        Text = data.Name,
        Font = F.Bold,
        TextSize = 11,
        TextColor3 = T.Text,
        TextTransparency = 0.08,
        Position = UDim2.fromOffset(12, 100),
        Size = UDim2.fromOffset(200, 16),
    })
    U.label(card, {
        Text = data.Saved,
        TextSize = 8,
        TextColor3 = T.Muted,
        TextTransparency = 0.35,
        Position = UDim2.fromOffset(12, 118),
        Size = UDim2.fromOffset(220, 12),
    })
    U.label(card, {
        Text = data.Size .. "  ·  " .. data.Values,
        TextSize = 8,
        TextColor3 = T.Faint,
        TextTransparency = 0.25,
        Position = UDim2.fromOffset(12, 132),
        Size = UDim2.fromOffset(220, 12),
    })
    if data.Status then
        local statusWidth = U.measure(data.Status, 7.5, F.Bold).X + 14
        local status = U.frame(card, {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = data.Status == "UNSAVED" and Color3.fromRGB(46, 36, 18) or T.Field,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -10, 0, 10),
            Size = UDim2.fromOffset(statusWidth, 18),
        })
        U.corner(status, 4)
        U.label(status, {
            Text = data.Status,
            Font = F.Bold,
            TextSize = 7.5,
            TextColor3 = data.Status == "UNSAVED" and T.Amber or T.Green,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(1, 1),
            TextXAlignment = Enum.TextXAlignment.Center,
        })
    end
    local entry = { Name = data.Name, Card = card, Stroke = stroke }
    configCards[#configCards + 1] = entry
    function entry.Render(isActive)
        card.BackgroundColor3 = isActive and T.SurfaceHover or T.Surface
        stroke.Color = isActive and T.Accent or T.Stroke
        stroke.Transparency = isActive and 0.25 or 0.6
    end
    U.inputButton(card, function()
        activeConfig = data.Name
        for _, other in ipairs(configCards) do
            other.Render(other.Name == activeConfig)
        end
        notify("Configs", "Loaded " .. data.Name, "file-box", T.Green)
    end)
end

for index, data in ipairs(configData) do
    configCard(index, data)
end
for _, entry in ipairs(configCards) do
    entry.Render(entry.Name == activeConfig)
end
U.onAccent(function()
    for _, entry in ipairs(configCards) do
        entry.Render(entry.Name == activeConfig)
    end
end)

end

-- ---------------------------------------------------------------------------------------
-- CONFIGS · Bind Manager
-- ---------------------------------------------------------------------------------------

do
local bindPage = configsTab:AddSubTab({ Name = "Bind Manager", Title = "Binds", Icon = "key-caps-lock" })
local bindCanvas = bindPage:SetCustomMode()

titleText(bindCanvas, "Binds", 10, "1 live")
local bindFilter = filterField(bindCanvas, 200, 0, 178, "Filter binds...")
local overlayLabel = U.label(bindCanvas, {
    Text = "Overlay",
    TextSize = 10,
    TextColor3 = T.Muted,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(398, 0),
    Size = UDim2.fromOffset(50, 28),
})
local overlayToggle = W.Toggle(bindCanvas, true, function() end)
overlayToggle.Root.Position = UDim2.fromOffset(450, 5)
toolbarPrimary(bindCanvas, "+ New bind", 0, 0, 92, 28, function()
    notify("Binds", "New bind slot", "plus-small", T.Accent)
end)

local bindTitle
local bindCards = {}
local activeBind = "Bhop"
local bindData = {
    { Name = "Bhop", Key = "SPACE", Detail = "hold · 1 setting" },
    { Name = "Thirdperson", Key = "V", Detail = "toggle · 1 setting" },
    { Name = "Ground Strafe", Key = "ALT", Detail = "hold · 1 setting" },
    { Name = "Strafe Hack", Key = "MOUSE5", Detail = "hold · 1 setting" },
    { Name = "Slow Walk", Key = "SHIFT", Detail = "hold · 1 setting" },
    { Name = "Air Stuck", Key = "X", Detail = "toggle · 1 setting" },
}

local function bindCard(index, data)
    local column = (index - 1) % 2
    local rowIndex = math.floor((index - 1) / 2)
    local card, stroke = surfaceCard(bindCanvas, column * 168, 48 + rowIndex * 64, 158, 56, {
        Radius = 6,
        Background = T.Surface,
    })
    U.frame(card, {
        BackgroundColor3 = T.Field,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(20, 20),
    })
    U.icon(card, "three-sliders-horizontal", 10, T.Muted, {
        Position = UDim2.fromOffset(13, 13),
        Size = UDim2.fromOffset(10, 10),
        TextTransparency = 0.4,
    })
    U.label(card, {
        Text = data.Name,
        Font = F.Bold,
        TextSize = 10,
        TextColor3 = T.Text,
        TextTransparency = 0.08,
        Position = UDim2.fromOffset(34, 6),
        Size = UDim2.fromOffset(86, 14),
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    U.label(card, {
        Text = data.Detail,
        TextSize = 7.5,
        TextColor3 = T.Muted,
        TextTransparency = 0.4,
        Position = UDim2.fromOffset(34, 24),
        Size = UDim2.fromOffset(86, 12),
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local keyWidth = U.measure(data.Key, 7.5, F.Bold).X + 12
    local key = U.frame(card, {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = T.Field,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0, 8),
        Size = UDim2.fromOffset(keyWidth, 16),
    })
    U.corner(key, 4)
    U.label(key, {
        Text = data.Key,
        Font = F.Bold,
        TextSize = 7.5,
        TextColor3 = T.Text,
        TextTransparency = 0.2,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromScale(1, 1),
    })
    local entry = { Name = data.Name, Card = card, Stroke = stroke }
    bindCards[#bindCards + 1] = entry
    function entry.Render(isActive)
        card.BackgroundColor3 = isActive and T.SurfaceHover or T.Surface
        stroke.Color = isActive and T.Accent or T.Stroke
        stroke.Transparency = isActive and 0.25 or 0.6
    end
    U.inputButton(card, function()
        activeBind = data.Name
        for _, other in ipairs(bindCards) do
            other.Render(other.Name == activeBind)
        end
        if bindTitle then
            bindTitle.Text = data.Name
        end
    end)
end

for index, data in ipairs(bindData) do
    bindCard(index, data)
end
for _, entry in ipairs(bindCards) do
    entry.Render(entry.Name == activeBind)
end
U.onAccent(function()
    for _, entry in ipairs(bindCards) do
        entry.Render(entry.Name == activeBind)
    end
end)

local newBind = W.Button(bindCanvas, "+ Bind", function() end)
newBind.Root.Position = UDim2.fromOffset(0, 552)
newBind.Root.Size = UDim2.fromOffset(118, 28)
local nestedBind = W.Button(bindCanvas, "+ Nested", function() end)
nestedBind.Root.Position = UDim2.fromOffset(128, 552)
nestedBind.Root.Size = UDim2.fromOffset(118, 28)

local editor = surfaceCard(bindCanvas, 352, 48, 432, 532, { Clip = true })[1]
bindTitle = U.label(editor, {
    Text = "Bhop",
    Font = F.Bold,
    TextSize = 13,
    TextColor3 = T.Text,
    TextTransparency = 0.05,
    Position = UDim2.fromOffset(16, 12),
    Size = UDim2.fromOffset(140, 20),
})
local editorToggle = W.Toggle(editor, true, function() end)
editorToggle.Root.Position = UDim2.fromOffset(104, 14)
local idleChip = U.frame(editor, {
    AnchorPoint = Vector2.new(1, 0),
    BackgroundColor3 = T.Field,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -14, 0, 12),
    Size = UDim2.fromOffset(52, 20),
})
U.corner(idleChip, 4)
U.label(idleChip, {
    Text = "idle",
    TextSize = 9,
    TextColor3 = T.Muted,
    TextTransparency = 0.3,
    TextXAlignment = Enum.TextXAlignment.Center,
    Size = UDim2.fromScale(1, 1),
})

local sentenceY = 38
U.label(editor, {
    Text = "When holding",
    TextSize = 9.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(16, sentenceY),
    Size = UDim2.fromOffset(80, 22),
})
token(editor, "SPACE", 96, sentenceY, T.Text, 22)
U.label(editor, {
    Text = "→ set",
    TextSize = 9.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(158, sentenceY),
    Size = UDim2.fromOffset(34, 22),
})
token(editor, "Bhop", 192, sentenceY, T.Text, 22)
U.label(editor, {
    Text = "to",
    TextSize = 9.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(236, sentenceY),
    Size = UDim2.fromOffset(18, 22),
})
token(editor, "on", 254, sentenceY, T.Accent, 22)
dividerLine(editor, 16, 66, 400, 0.4)

local function bindStep(y, title, description)
    local dot = U.frame(editor, {
        BackgroundColor3 = T.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, y),
        Size = UDim2.fromOffset(10, 10),
    })
    U.corner(dot, 5)
    U.label(editor, {
        Text = title,
        Font = F.Bold,
        TextSize = 9,
        TextColor3 = T.Muted,
        TextTransparency = 0.2,
        Position = UDim2.fromOffset(32, y - 2),
        Size = UDim2.fromOffset(60, 14),
    })
    U.label(editor, {
        Text = description,
        TextSize = 8.5,
        TextColor3 = T.Faint,
        TextTransparency = 0.3,
        Position = UDim2.fromOffset(88, y - 2),
        Size = UDim2.fromOffset(300, 14),
    })
    return y + 24
end

local whenY = bindStep(82, "WHEN", "what turns this bind on")
U.label(editor, {
    Text = "Trigger",
    TextSize = 10,
    TextColor3 = T.Muted,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(32, whenY),
    Size = UDim2.fromOffset(60, 22),
})
local triggerMode = W.Segmented(editor, {
    Width = 150,
    Height = 22,
    Items = { "Key", "Condition" },
    Selected = "Key",
})
triggerMode.Root.Position = UDim2.fromOffset(104, whenY)
U.label(editor, {
    Text = "Key",
    TextSize = 10,
    TextColor3 = T.Muted,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(32, whenY + 30),
    Size = UDim2.fromOffset(60, 22),
})
token(editor, "SPACE", 104, whenY + 30, T.Text, 22)
U.label(editor, {
    Text = "Mode",
    TextSize = 10,
    TextColor3 = T.Muted,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(32, whenY + 60),
    Size = UDim2.fromOffset(60, 22),
})
local bindMode = W.Segmented(editor, {
    Width = 250,
    Height = 22,
    Items = { "Hold", "Toggle", "Double Click" },
    Selected = "Hold",
})
bindMode.Root.Position = UDim2.fromOffset(104, whenY + 60)

local whileY = bindStep(206, "WHILE", "the gate: a parent bind, and how the overlay lists it")
U.label(editor, {
    Text = "Parent",
    TextSize = 10,
    TextColor3 = T.Muted,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(32, whileY),
    Size = UDim2.fromOffset(60, 22),
})
local parentBind = W.Dropdown(editor, {
    Options = { "None (root)", "Bhop", "Nested" },
    Default = "None (root)",
    Width = 150,
})
parentBind.Root.Position = UDim2.fromOffset(104, whileY)
U.label(editor, {
    Text = "Overlay",
    TextSize = 10,
    TextColor3 = T.Muted,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(32, whileY + 30),
    Size = UDim2.fromOffset(60, 22),
})
local overlayMode = W.Segmented(editor, {
    Width = 250,
    Height = 22,
    Items = { "Always", "While Active", "Hidden" },
    Selected = "Always",
})
overlayMode.Root.Position = UDim2.fromOffset(104, whileY + 30)

local thenY = bindStep(324, "THEN", "1 setting overridden while it fires")
local settingRow = U.frame(editor, {
    BackgroundColor3 = T.Field,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(32, thenY),
    Size = UDim2.new(1, -48, 0, 28),
})
U.corner(settingRow, 5)
U.frame(settingRow, {
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = T.Muted,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 10, 0.5, 0),
    Size = UDim2.fromOffset(4, 4),
})
U.corner(editor, 5)
U.label(settingRow, {
    Text = "bhop  >  Enabled",
    TextSize = 9.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.2,
    Position = UDim2.fromOffset(20, 0),
    Size = UDim2.new(1, -50, 1, 0),
})
U.label(editor, {
    Text = "Set to",
    TextSize = 10,
    TextColor3 = T.Muted,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(32, thenY + 38),
    Size = UDim2.fromOffset(60, 22),
})
local setToggle = W.Toggle(editor, true, function() end)
setToggle.Root.AnchorPoint = Vector2.new(1, 0)
setToggle.Root.Position = UDim2.new(1, -16, 0, thenY + 36)
local addSetting = W.Button(editor, "+ Add setting", function() end)
addSetting.Root.Position = UDim2.fromOffset(32, thenY + 72)
addSetting.Root.Size = UDim2.fromOffset(120, 26)
U.label(editor, {
    Text = "or right-click any setting in the menu",
    TextSize = 8.5,
    TextColor3 = T.Faint,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(160, thenY + 74),
    Size = UDim2.fromOffset(250, 22),
})

end

-- ---------------------------------------------------------------------------------------
-- CONFIGS · Themes
-- ---------------------------------------------------------------------------------------

do
local themesPage = configsTab:AddSubTab({ Name = "Themes", Title = "Themes", Icon = "paint-bucket" })
local themes = themesPage:SetCustomMode()

titleText(themes, "Themes", 106)
local themeFilter = filterField(themes, 100, 0, 148, "Filter themes...")
local themeSort = W.Segmented(themes, {
    Width = 112,
    Height = 28,
    Items = { "Name", "Recent" },
    Selected = "Name",
})
themeSort.Root.Position = UDim2.fromOffset(258, 0)
toolbarButton(themes, "Open folder", 258, 0, 84, 28, function() end)
toolbarButton(themes, "Import", 194, 0, 58, 28, function() end)
toolbarButton(themes, "Export", 130, 0, 58, 28, function() end)
toolbarPrimary(themes, "+ Save as", 0, 0, 92, 28, function()
    notify("Themes", "Theme slot saved", "paint-bucket", T.Accent)
end)

U.label(themes, {
    Text = "PRESETS",
    Font = F.Bold,
    TextSize = 9.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.4,
    Position = UDim2.fromOffset(0, 48),
    Size = UDim2.fromOffset(100, 14),
})
U.label(themes, {
    Text = "Click a card to apply",
    TextSize = 8.5,
    TextColor3 = T.Faint,
    TextTransparency = 0.35,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 48),
    Size = UDim2.fromOffset(160, 14),
    TextXAlignment = Enum.TextXAlignment.Right,
})

local themePresets = {
    { Name = "Dark", Base = Color3.fromRGB(14, 14, 15), Panel = Color3.fromRGB(34, 34, 37), Accent = Color3.fromRGB(235, 235, 240) },
    { Name = "Light", Base = Color3.fromRGB(229, 229, 232), Panel = Color3.fromRGB(245, 245, 247), Accent = Color3.fromRGB(38, 38, 42) },
    { Name = "Purple", Base = Color3.fromRGB(17, 14, 26), Panel = Color3.fromRGB(43, 33, 66), Accent = Color3.fromRGB(158, 123, 255) },
    { Name = "Blue", Base = Color3.fromRGB(12, 18, 30), Panel = Color3.fromRGB(28, 43, 70), Accent = Color3.fromRGB(79, 140, 255) },
    { Name = "Green", Base = Color3.fromRGB(11, 22, 18), Panel = Color3.fromRGB(26, 50, 40), Accent = Color3.fromRGB(59, 217, 140) },
    { Name = "Red", Base = Color3.fromRGB(24, 13, 13), Panel = Color3.fromRGB(58, 27, 27), Accent = Color3.fromRGB(255, 92, 92) },
    { Name = "Cyan", Base = Color3.fromRGB(10, 21, 24), Panel = Color3.fromRGB(23, 48, 55), Accent = Color3.fromRGB(69, 214, 232) },
    { Name = "Orange", Base = Color3.fromRGB(24, 16, 11), Panel = Color3.fromRGB(58, 38, 24), Accent = Color3.fromRGB(255, 159, 67) },
    { Name = "Pink", Base = Color3.fromRGB(24, 13, 19), Panel = Color3.fromRGB(58, 27, 42), Accent = Color3.fromRGB(255, 92, 200) },
    { Name = "Amber", Base = Color3.fromRGB(24, 19, 10), Panel = Color3.fromRGB(58, 44, 22), Accent = Color3.fromRGB(255, 198, 92) },
    { Name = "Steel", Base = Color3.fromRGB(16, 21, 26), Panel = Color3.fromRGB(36, 48, 58), Accent = Color3.fromRGB(175, 195, 214) },
    { Name = "Glass", Base = Color3.fromRGB(20, 24, 28), Panel = Color3.fromRGB(46, 55, 63), Accent = Color3.fromRGB(199, 214, 232) },
}

local function miniPreview(parent, preset)
    local preview = U.frame(parent, {
        BackgroundColor3 = preset.Base,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 74),
        ClipsDescendants = true,
    })
    U.frame(preview, {
        BackgroundColor3 = preset.Panel,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 8),
    })
    U.frame(preview, {
        BackgroundColor3 = preset.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 3),
        Size = UDim2.fromOffset(12, 2),
    })
    U.frame(preview, {
        BackgroundColor3 = preset.Panel,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(6, 14),
        Size = UDim2.fromOffset(30, 54),
    })
    for index = 1, 4 do
        U.frame(preview, {
            BackgroundColor3 = preset.Panel,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(44, 18 + (index - 1) * 12),
            Size = UDim2.fromOffset(54, 4),
        })
    end
    U.frame(preview, {
        BackgroundColor3 = preset.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(44, 56),
        Size = UDim2.fromOffset(26, 4),
    })
end

local themeCards = {}
local activeTheme = "Dark"
local function drawThemeCard(index, preset)
    local column = (index - 1) % 4
    local rowIndex = math.floor((index - 1) / 4)
    local card, stroke = surfaceCard(themes, column * 195, 70 + rowIndex * 138, 187, 128, {
        Radius = 7,
        Background = T.Surface,
        Clip = true,
    })
    miniPreview(card, preset)
    U.label(card, {
        Text = preset.Name,
        TextSize = 10,
        TextColor3 = T.Text,
        TextTransparency = 0.15,
        Position = UDim2.fromOffset(10, 106),
        Size = UDim2.fromOffset(120, 14),
    })
    U.frame(card, {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = preset.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -12, 0, 112),
        Size = UDim2.fromOffset(8, 8),
    })
    local entry = { Name = preset.Name, Card = card, Stroke = stroke, Preset = preset }
    themeCards[#themeCards + 1] = entry
    function entry.Render(isActive)
        card.BackgroundColor3 = isActive and T.SurfaceHover or T.Surface
        stroke.Color = isActive and preset.Accent or T.Stroke
        stroke.Transparency = isActive and 0.2 or 0.6
    end
    U.inputButton(card, function()
        activeTheme = preset.Name
        Nerx:SetAccent(preset.Accent)
        for _, other in ipairs(themeCards) do
            other.Render(other.Name == activeTheme)
        end
        notify("Themes", preset.Name .. " accent applied", "paint-bucket", preset.Accent)
    end)
end

for index, preset in ipairs(themePresets) do
    drawThemeCard(index, preset)
end
for _, entry in ipairs(themeCards) do
    entry.Render(entry.Name == activeTheme)
end
U.onAccent(function()
    for _, entry in ipairs(themeCards) do
        entry.Render(entry.Name == activeTheme)
    end
end)

U.label(themes, {
    Text = "MY THEMES",
    Font = F.Bold,
    TextSize = 9.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.4,
    Position = UDim2.fromOffset(0, 498),
    Size = UDim2.fromOffset(100, 14),
})
U.label(themes, {
    Text = "Double-click applies · right-click for more",
    TextSize = 8.5,
    TextColor3 = T.Faint,
    TextTransparency = 0.35,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 498),
    Size = UDim2.fromOffset(240, 14),
    TextXAlignment = Enum.TextXAlignment.Right,
})

end

-- ---------------------------------------------------------------------------------------
-- SCRIPTING · Scripts
-- ---------------------------------------------------------------------------------------

local scriptingTab = miscGroup:AddTab({ Name = "Scripting", Icon = "gear" })
local scriptsPage = scriptingTab:AddSubTab({ Name = "Scripts", Title = "Scripts", Icon = "file-box" })
do
local scriptsCanvas = scriptsPage:SetCustomMode()

titleText(scriptsCanvas, "Scripts", 28, "nothing running")
local scriptFilter = filterField(scriptsCanvas, 220, 0, 160, "Filter scripts...")
local scriptSort = W.Segmented(scriptsCanvas, {
    Width = 210,
    Height = 28,
    Items = { "Name", "Status", "Recent" },
    Selected = "Name",
})
scriptSort.Root.Position = UDim2.fromOffset(400, 0)
toolbarButton(scriptsCanvas, "Reload all", 76, 0, 78, 28, function()
    notify("Scripts", "Reloaded all scripts", "arrow-spin-clockwise", T.Green)
end)
toolbarPrimary(scriptsCanvas, "+ New", 0, 0, 64, 28, function()
    notify("Scripts", "New script placeholder", "plus-small", T.Accent)
end)

local scriptData = {
    { Name = "Clicker", Status = "Off", Size = "17.5 KB", Edited = "edited 81d ago", Enabled = false },
    { Name = "LOBOTOMY", Status = "Off", Size = "149.6 KB", Edited = "edited 81d ago", Enabled = false },
    { Name = "Shadering", Status = "Off", Size = "7.6 KB", Edited = "edited 77d ago", Enabled = false },
    { Name = "Strafe helper", Status = "Off", Size = "6.8 KB", Edited = "edited 81d ago", Enabled = false },
    { Name = "atmosphere", Status = "Off", Size = "16.2 KB", Edited = "edited 77d ago", Enabled = false },
    { Name = "chat_spam", Status = "Off", Size = "10.6 KB", Edited = "edited 38d ago", Enabled = false },
}

local scriptCards = {}
local function scriptCard(index, data)
    local column = (index - 1) % 2
    local rowIndex = math.floor((index - 1) / 2)
    local card, stroke = surfaceCard(scriptsCanvas, column * 392, 66 + rowIndex * 140, 382, 132, {
        Radius = 7,
        Background = T.Surface,
    })
    U.label(card, {
        Text = data.Name,
        Font = F.Bold,
        TextSize = 12,
        TextColor3 = T.Text,
        TextTransparency = 0.1,
        Position = UDim2.fromOffset(14, 14),
        Size = UDim2.fromOffset(220, 18),
    })
    local statusLabel
    local toggle = W.Toggle(card, data.Enabled, function(value)
        data.Enabled = value
        U.tween(card, U.Tween.Fast, { BackgroundColor3 = value and T.SurfaceHover or T.Surface })
        if statusLabel then
            statusLabel.Text = value and "On" or "Off"
            statusLabel.TextColor3 = value and T.Green or T.Muted
        end
        notify("Scripts", data.Name .. (value and " enabled" or " disabled"), "file-box", value and T.Green or T.Muted)
    end)
    toggle.Root.AnchorPoint = Vector2.new(1, 0)
    toggle.Root.Position = UDim2.new(1, -14, 0, 14)
    statusLabel = U.label(card, {
        Text = data.Enabled and "On" or data.Status,
        TextSize = 9,
        TextColor3 = data.Enabled and T.Green or T.Muted,
        TextTransparency = 0.3,
        Position = UDim2.fromOffset(14, 40),
        Size = UDim2.fromOffset(80, 14),
    })
    U.label(card, {
        Text = data.Size,
        TextSize = 8,
        TextColor3 = T.Muted,
        TextTransparency = 0.35,
        Position = UDim2.fromOffset(14, 94),
        Size = UDim2.fromOffset(70, 14),
    })
    U.label(card, {
        Text = data.Edited,
        TextSize = 8,
        TextColor3 = T.Faint,
        TextTransparency = 0.3,
        Position = UDim2.fromOffset(88, 94),
        Size = UDim2.fromOffset(110, 14),
    })
    local badge = U.frame(card, {
        BackgroundColor3 = T.Field,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 70),
        Size = UDim2.fromOffset(66, 18),
    })
    U.corner(badge, 4)
    U.label(badge, {
        Text = "script",
        Font = F.Bold,
        TextSize = 7.5,
        TextColor3 = T.Muted,
        TextTransparency = 0.25,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromScale(1, 1),
    })
    local entry = { Name = data.Name, Card = card, Stroke = stroke }
    scriptCards[#scriptCards + 1] = entry
    U.inputButton(card, function()
        for _, other in ipairs(scriptCards) do
            other.Stroke.Color = other.Name == data.Name and T.Accent or T.Stroke
            other.Stroke.Transparency = other.Name == data.Name and 0.25 or 0.6
        end
        notify("Scripts", "Selected " .. data.Name, "file-box", T.Muted)
    end)
end
for index, data in ipairs(scriptData) do
    scriptCard(index, data)
end
U.onAccent(function()
    for _, entry in ipairs(scriptCards) do
        entry.Stroke.Color = entry.Name == scriptData[1].Name and T.Accent or T.Stroke
    end
end)

for index = 1, 6 do
    U.frame(scriptsCanvas, {
        BackgroundColor3 = index == 1 and T.Text or T.Field,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(344 + (index - 1) * 14, 494),
        Size = UDim2.fromOffset(index == 1 and 14 or 6, 4),
    })
end

U.label(scriptsCanvas, {
    Text = "28 loaded   ·   49 KB heap   ·   0 tasks   ·   0 tabs added by scripts",
    Font = F.Mono,
    TextSize = 8.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.35,
    Position = UDim2.fromOffset(0, 568),
    Size = UDim2.fromOffset(520, 16),
})
U.label(scriptsCanvas, {
    Text = "sandbox off   ·   Raw memory access: ON",
    Font = F.Mono,
    TextSize = 8.5,
    TextColor3 = T.Faint,
    TextTransparency = 0.25,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 568),
    Size = UDim2.fromOffset(360, 16),
    TextXAlignment = Enum.TextXAlignment.Right,
})

end

-- ---------------------------------------------------------------------------------------
-- SCRIPTING · Editor
-- ---------------------------------------------------------------------------------------

do
local editorPage = scriptingTab:AddSubTab({ Name = "Editor", Title = "Editor", Icon = "gear" })
local editorCanvas = editorPage:SetCustomMode()

-- File tab bar
local fileTab = U.frame(editorCanvas, {
    BackgroundColor3 = T.Surface,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.fromOffset(164, 30),
})
U.corner(fileTab, 6)
U.label(fileTab, {
    Text = "Clicker.lua",
    Font = F.Bold,
    TextSize = 9.5,
    TextColor3 = T.Text,
    TextTransparency = 0.1,
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.fromOffset(110, 30),
})
U.icon(fileTab, "circle-x", 10, T.Muted, {
    Position = UDim2.fromOffset(142, 0),
    Size = UDim2.fromOffset(12, 30),
    TextTransparency = 0.4,
})
U.frame(editorCanvas, {
    BackgroundColor3 = T.Accent,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 30),
    Size = UDim2.fromOffset(164, 2),
})
toolbarButton(editorCanvas, "Save", 132, 0, 58, 26, function()
    notify("Editor", "Clicker.lua saved", "circle-check", T.Green)
end)
toolbarButton(editorCanvas, "Reload", 66, 0, 62, 26, function()
    notify("Editor", "Script reloaded", "arrow-spin-clockwise", T.Green)
end)
toolbarButton(editorCanvas, "Delete", 0, 0, 62, 26, function()
    notify("Editor", "Delete is a design placeholder", "circle-i", T.Muted)
end)

-- Explorer
local explorer = U.frame(editorCanvas, {
    BackgroundColor3 = T.Surface,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 40),
    Size = UDim2.fromOffset(196, 520),
})
U.corner(explorer, 7)
U.frame(explorer, {
    BackgroundColor3 = T.Text,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 8),
    Size = UDim2.fromOffset(2, 12),
})
U.label(explorer, {
    Text = "EXPLORER",
    Font = F.Bold,
    TextSize = 8.5,
    TextColor3 = T.Text,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(10, 6),
    Size = UDim2.fromOffset(100, 16),
})
U.label(explorer, {
    Text = "28 files",
    TextSize = 8,
    TextColor3 = T.Faint,
    TextTransparency = 0.4,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 6),
    Size = UDim2.fromOffset(60, 16),
    TextXAlignment = Enum.TextXAlignment.Right,
})
local explorerFilter = filterField(explorer, 8, 28, 180, "Filter scripts...", 24)
local editorScripts = {
    { "Clicker", true }, { "LOBOTOMY", false }, { "Shadering", false }, { "Strafe helper", false },
    { "atmosphere", false }, { "chat_spam", false }, { "clarity", false }, { "cortex", false },
}
for index, entry in ipairs(editorScripts) do
    local y = 60 + (index - 1) * 30
    local row = U.frame(explorer, {
        BackgroundColor3 = index == 1 and T.SurfaceHover or T.White,
        BackgroundTransparency = index == 1 and 0 or 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, y),
        Size = UDim2.fromOffset(180, 28),
    })
    U.corner(row, 4)
    if index == 1 then
        U.stroke(row, T.Accent, 0.4, 1)
    end
    U.icon(row, "file-box", 10, index == 1 and T.Text or T.Muted, {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.fromOffset(11, 28),
        TextTransparency = index == 1 and 0.1 or 0.45,
    })
    U.label(row, {
        Text = entry[1],
        TextSize = 9.5,
        TextColor3 = T.Text,
        TextTransparency = index == 1 and 0.03 or 0.25,
        Position = UDim2.fromOffset(25, 0),
        Size = UDim2.fromOffset(105, 28),
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local toggle = W.Toggle(row, entry[2], nil)
    toggle.Root.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Root.Position = UDim2.new(1, -8, 0.5, 0)
    toggle.Root.Size = UDim2.fromOffset(24, 14)
    U.inputButton(row, function()
        notify("Editor", "Opened " .. entry[1] .. ".lua", "file-box", T.Muted)
    end)
end
local newScript = W.Button(explorer, "New", function() end)
newScript.Root.Position = UDim2.fromOffset(8, 460)
newScript.Root.Size = UDim2.fromOffset(78, 24)
local rescan = W.Button(explorer, "Rescan", function() end)
rescan.Root.Position = UDim2.fromOffset(94, 460)
rescan.Root.Size = UDim2.fromOffset(86, 24)
U.label(explorer, {
    Text = "28 loaded   ·   0 enabled",
    Font = F.Mono,
    TextSize = 8,
    TextColor3 = T.Faint,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(10, 498),
    Size = UDim2.fromOffset(170, 14),
})

-- Code panel
local codePanel = U.frame(editorCanvas, {
    BackgroundColor3 = Color3.fromRGB(9, 9, 11),
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(204, 40),
    Size = UDim2.fromOffset(344, 520),
    ClipsDescendants = true,
})
U.corner(codePanel, 7)
U.stroke(codePanel, T.Stroke, 0.55, 1)
U.label(codePanel, {
    Text = "Clicker.lua",
    TextSize = 8.5,
    TextColor3 = T.Muted,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(10, 6),
    Size = UDim2.fromOffset(120, 16),
})
dividerLine(codePanel, 0, 24, 344, 0.5)
local codeLines = {
    "local C = cc(18, 18, 22),",
    "bg2 = cc(24, 24, 30),",
    "panel = cc(28, 28, 35),",
    "panel_hi = cc(34, 34, 42),",
    "panel_hover = cc(40, 40, 50),",
    "border = cc(50, 50, 62),",
    "border_hi = cc(70, 70, 85),",
    "accent = cc(90, 130, 255),",
    "accent_hi = cc(110, 150, 255),",
    "accent_dim = cc(60, 90, 180),",
    "gold = cc(255, 210, 60),",
    "gold_dim = cc(180, 150, 40),",
    "green = cc(60, 220, 100),",
    "green_dim = cc(40, 150, 70),",
    "red = cc(220, 60, 70),",
    "white = cc(255, 255, 255),",
    "text = cc(210, 210, 220),",
    "text_dim = cc(130, 130, 145),",
    "text_dark = cc(80, 80, 95),",
    "black = cc(0, 0, 0),",
    "btn_idle = cc(35, 35, 45),",
    "btn_hover = cc(45, 45, 58),",
    "btn_press = cc(55, 55, 70),",
    "prestige = cc(200, 120, 255),",
    "prestige_hi = cc(220, 150, 255),",
}
for index, line in ipairs(codeLines) do
    local y = 34 + (index - 1) * 17
    U.label(codePanel, {
        Text = tostring(index),
        Font = F.Mono,
        TextSize = 8.5,
        TextColor3 = T.Faint,
        TextTransparency = 0.35,
        Position = UDim2.fromOffset(8, y),
        Size = UDim2.fromOffset(20, 16),
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    U.label(codePanel, {
        Text = line,
        Font = F.Mono,
        TextSize = 9,
        TextColor3 = index >= 8 and index <= 10 and T.Violet or T.Muted,
        TextTransparency = 0.15,
        Position = UDim2.fromOffset(34, y),
        Size = UDim2.fromOffset(300, 16),
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end
U.frame(codePanel, {
    BackgroundColor3 = T.Field,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -4, 0, 26),
    Size = UDim2.fromOffset(4, 330),
})
U.label(codePanel, {
    Text = "Ln 1, Col 1     saved     17.5 / 64 KB",
    Font = F.Mono,
    TextSize = 8,
    TextColor3 = T.Faint,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(10, 500),
    Size = UDim2.fromOffset(320, 14),
})

-- API panel
local apiPanel = U.frame(editorCanvas, {
    BackgroundColor3 = T.Surface,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(556, 40),
    Size = UDim2.fromOffset(228, 520),
})
U.corner(apiPanel, 7)
U.label(apiPanel, {
    Text = "API",
    Font = F.Bold,
    TextSize = 8.5,
    TextColor3 = T.Text,
    TextTransparency = 0.25,
    Position = UDim2.fromOffset(10, 6),
    Size = UDim2.fromOffset(60, 16),
})
U.label(apiPanel, {
    Text = "293 functions",
    TextSize = 8,
    TextColor3 = T.Faint,
    TextTransparency = 0.4,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 6),
    Size = UDim2.fromOffset(100, 16),
    TextXAlignment = Enum.TextXAlignment.Right,
})
local apiFilter = filterField(apiPanel, 8, 28, 212, "Search the API...", 24)
local apiEntries = {
    "Matrix3x4", "Matrix3x4.from_angles()", "Quaternion", "Quaternion.from_angles()",
    "G.Angle()", "G.Vector()", "G.assert()", "G.error()", "G.ipairs()",
    "G.next()", "G.pairs()", "G.pcall()", "G.print()", "G.rawequal()",
    "G.require()", "G.select()",
}
for index, entry in ipairs(apiEntries) do
    local y = 60 + (index - 1) * 24
    U.label(apiPanel, {
        Text = entry,
        Font = F.Mono,
        TextSize = 8.5,
        TextColor3 = index <= 4 and T.Text or T.Muted,
        TextTransparency = index <= 4 and 0.2 or 0.4,
        Position = UDim2.fromOffset(10, y),
        Size = UDim2.fromOffset(206, 20),
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end
U.label(apiPanel, {
    Text = "293 functions - click to insert",
    Font = F.Mono,
    TextSize = 8,
    TextColor3 = T.Faint,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(10, 468),
    Size = UDim2.fromOffset(206, 14),
})
U.label(apiPanel, {
    Text = "Raw memory access: ON",
    Font = F.Mono,
    TextSize = 8,
    TextColor3 = T.Green,
    TextTransparency = 0.2,
    Position = UDim2.fromOffset(10, 490),
    Size = UDim2.fromOffset(206, 14),
})

end

-- ---------------------------------------------------------------------------------------
-- MISC · Console
-- ---------------------------------------------------------------------------------------

do
local consoleTab = miscGroup:AddTab({ Name = "Console", Icon = "grid" })
local consolePage = consoleTab:GetPage()
local consoleCanvas = consolePage:SetCustomMode()

titleText(consoleCanvas, "Console", 0, "connected")
local consoleFilter = filterField(consoleCanvas, 220, 0, 160, "Filter output...")
local consoleLevels = W.Segmented(consoleCanvas, {
    Width = 230,
    Height = 28,
    Items = { "ALL", "INFO", "WARN", "ERROR" },
    Selected = "ALL",
})
consoleLevels.Root.Position = UDim2.fromOffset(400, 0)
toolbarButton(consoleCanvas, "Clear", 82, 0, 64, 28, function()
    notify("Console", "Output cleared", "circle-i", T.Muted)
end)
toolbarButton(consoleCanvas, "Pause", 0, 0, 72, 28, function()
    notify("Console", "Output paused", "circle-play", T.Muted)
end)

local consolePanel = U.frame(consoleCanvas, {
    BackgroundColor3 = T.Surface,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 44),
    Size = UDim2.fromOffset(784, 476),
    ClipsDescendants = true,
})
U.corner(consolePanel, 7)
local consoleLines = {
    { "23:41:02", "INFO", "Nerx UI " .. tostring(Nerx.Version) .. " loaded", T.Green },
    { "23:41:02", "INFO", "Registered 28 scripts", T.Muted },
    { "23:41:03", "INFO", "Renderer: 2D interface · DPI aware", T.Muted },
    { "23:41:03", "WARN", "Sandbox is off - scripts can access globals", T.Amber },
    { "23:41:04", "INFO", "Loaded config: newnew", T.Muted },
    { "23:41:04", "INFO", "Theme: Dark", T.Muted },
    { "23:41:05", "INFO", "Aim assist initialized", T.Muted },
    { "23:41:06", "ERROR", "Script 'cortex' failed: attempt to index nil", T.Red },
    { "23:41:06", "WARN", "Raw memory access is enabled", T.Amber },
    { "23:41:07", "INFO", "Waiting for match...", T.Muted },
}
for index, line in ipairs(consoleLines) do
    local y = 10 + (index - 1) * 34
    U.label(consolePanel, {
        Text = line[1],
        Font = F.Mono,
        TextSize = 8,
        TextColor3 = T.Faint,
        TextTransparency = 0.3,
        Position = UDim2.fromOffset(14, y + 4),
        Size = UDim2.fromOffset(60, 18),
    })
    local levelWidth = U.measure(line[2], 7.5, F.Bold).X + 14
    local level = U.frame(consolePanel, {
        BackgroundColor3 = T.Field,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(82, y),
        Size = UDim2.fromOffset(levelWidth, 20),
    })
    U.corner(level, 4)
    U.label(level, {
        Text = line[2],
        Font = F.Bold,
        TextSize = 7.5,
        TextColor3 = line[4],
        TextTransparency = 0.15,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromScale(1, 1),
    })
    U.label(consolePanel, {
        Text = line[3],
        TextSize = 10,
        TextColor3 = line[4],
        TextTransparency = 0.15,
        Position = UDim2.fromOffset(156, y + 2),
        Size = UDim2.fromOffset(610, 20),
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local consoleInput = W.Input(consoleCanvas, {
    Width = 650,
    Height = 28,
    Placeholder = "Enter a command...",
})
consoleInput.Root.Position = UDim2.fromOffset(0, 536)
local sendCommand = W.PrimaryButton(consoleCanvas, "Send", 72, 28, function()
    notify("Console", "Command placeholder", "grid", T.Muted)
end)
sendCommand.Root.Position = UDim2.fromOffset(660, 536)
sendCommand.Root.Size = UDim2.fromOffset(72, 28)
U.label(consoleCanvas, {
    Text = "Console · 0 errors · auto-scroll on",
    Font = F.Mono,
    TextSize = 8.5,
    TextColor3 = T.Faint,
    TextTransparency = 0.3,
    Position = UDim2.fromOffset(0, 576),
    Size = UDim2.fromOffset(784, 16),
})

end

-- ---------------------------------------------------------------------------------------
-- Initial page selection
-- ---------------------------------------------------------------------------------------

rageTab:SetPage(rageMain)
visualsTab:SetPage(playersPage)
kreedzTab:SetPage(movementPage)
miscTab:SetPage(miscMain)
configsTab:SetPage(configsSettings)
scriptingTab:SetPage(scriptsPage)

window:SelectTab(visualsTab)
visualsTab:SetPage(playersPage)

task.defer(function()
    Nerx:Notify({
        Title = "Nerx UI · example",
        Content = "Xhook-style menu loaded · press Insert to toggle",
        Icon = "circle-check",
        Color = T.Green,
        Duration = 5,
    })
end)

return window


