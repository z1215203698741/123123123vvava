--[[
    Nerx UI · basic example
    A minimal window with one group, one tab, standard sections and a preview.

    Run this from an executor, or paste it into a LocalScript after syncing
    NerxUI.luau as a ModuleScript.
]]

local LIBRARY_URL = "https://raw.githubusercontent.com/z1215203698741/123123123vvava/main/NerxUI.luau"

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
local W = Nerx.Widgets
local T = Nerx.Theme

local window = Nerx:CreateWindow({
    Title = "Nerx Beta",
    Subtitle = "Bloxstrike",
    Size = UDim2.fromOffset(1024, 700),
    Mode = "legit",
    Modes = { "legit", "rage" },
    Keybind = "Insert",
    AccountTag = "Example",
    OnSave = function()
        Nerx:Notify({
            Title = "Configuration",
            Content = "Saved example settings",
            Icon = "circle-check",
            Color = T.Green,
        })
    end,
})

local features = window:AddGroup("FEATURES")
local tab = features:AddTab({ Name = "Example", Icon = "grid" })
local page = tab:GetPage()

page:SetTitle("Example")
page:SetSubtitle("A small page built with the public library API.")
page:SetHint("Click toggles · right-click options · drag values on sliders")
page:SetSectionStyle("flat")

page:AddSelector({
    Selected = "Main",
    Items = {
        { Name = "Main", Icon = "grid", Color = T.Green, ShowDot = true },
        { Name = "Visuals", Icon = "eye", Color = T.Muted },
    },
    Callback = function(value)
        Nerx:Notify({ Title = "Selector", Content = "Selected " .. tostring(value), Icon = "circle-i", Color = T.Muted })
    end,
})

local general = page:AddSection({ Name = "GENERAL" })
general:AddToggle({
    Name = "Enabled",
    Default = true,
    Flag = "example_enabled",
    ShowOption = true,
    Swatch = T.Green,
    Callback = function(value)
        print("Enabled:", value)
    end,
})
general:AddSlider({
    Name = "Distance",
    Default = 120,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Type = " m",
    Flag = "example_distance",
})
general:AddKeybind({
    Name = "Activation",
    Default = "E",
    Flag = "example_key",
})
general:AddDropdown({
    Name = "Mode",
    Options = { "Smooth", "Instant", "Assist" },
    Default = "Smooth",
    Width = 138,
})

local elements = page:AddSection({ Name = "ELEMENTS" })
elements:AddChips({
    Items = {
        { Name = "Name", Color = T.Cyan, Selected = true },
        { Name = "Distance", Color = T.Muted, Selected = true },
        { Name = "Health", Color = T.Green },
        { Name = "Armor", Color = T.Cyan },
    },
})
elements:AddToggle({ Name = "Through walls", Default = false })

page:AddPreview({
    Name = "example",
    Tags = {
        { Text = "Visible", Color = T.Green },
        { Text = "42 m", Color = T.Text },
    },
    PlaceholderIcon = "square-dashed-person-standing",
    PlaceholderText = "attach a ViewportFrame here",
})

-- Optional custom widgets are available too:
local custom = page:AddSection({ Name = "CUSTOM", Column = "right" })
custom:AddCustomRow(34, function(row)
    local label = Nerx.U.label(row, {
        Text = "Widgets.Button",
        TextSize = 11.5,
        TextColor3 = T.Text,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.fromOffset(180, 34),
    })
    local button = W.Button(row, "Notify", function()
        Nerx:Notify({ Title = "Widget", Content = "Hello from a custom row", Icon = "circle-check", Color = T.Green })
    end)
    button.Root.AnchorPoint = Vector2.new(1, 0.5)
    button.Root.Position = UDim2.new(1, -12, 0.5, 0)
    button.Root.Size = UDim2.fromOffset(72, 24)
end)

return window
