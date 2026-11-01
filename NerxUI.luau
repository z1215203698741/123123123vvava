--[[
	Nerx UI Library · v1.0.2
	A component-first, Neverlose-inspired Roblox interface library.

	Single-file ModuleScript / loadstring library. It returns the Nerx table and
	does not build a demo menu.

		local Nerx = loadstring(readfile("NerxUI.luau"))()
		local window = Nerx:CreateWindow({
			Title = "Nerx Beta",
			Subtitle = "Bloxstrike",
		})

	Design language is inspired by the Neverlose Lua interface.
	Icon glyphs use Roblox's BuilderIcons font.
	Optional Neverlose marks: github.com/tickcount/.p2c-icons (MIT), see assets/.

	License: MIT. See LICENSE and THIRD_PARTY_NOTICES.md.
]]

local cloneref = cloneref or function(object) return object end

local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	error("[NerxUI] NerxUI is a client-side UI library. Require it from a LocalScript or executor.")
end

local parentGui
do
	if gethui then
		local ok, value = pcall(gethui)
		if ok then
			parentGui = value
		end
	end
	if not parentGui and get_hidden_gui then
		local ok, value = pcall(get_hidden_gui)
		if ok then
			parentGui = value
		end
	end
	if not parentGui then
		local ok, value = pcall(function()
			return game:GetService("CoreGui")
		end)
		if ok then
			parentGui = value
		end
	end
	if not parentGui then
		parentGui = LocalPlayer:WaitForChild("PlayerGui")
	end
end

local function protect(gui)
	local fn = protect_gui or protectgui or (syn and syn.protect_gui)
	if fn then
		pcall(fn, gui)
	end
end

local Nerx = {}
Nerx.Version = "1.0.2"

local Theme = {
	Window = Color3.fromRGB(14, 14, 15),
	Sidebar = Color3.fromRGB(14, 14, 15),
	Surface = Color3.fromRGB(20, 20, 21),
	SurfaceRaised = Color3.fromRGB(28, 28, 30),
	SurfaceHover = Color3.fromRGB(34, 34, 37),
	Selected = Color3.fromRGB(58, 58, 62),
	Field = Color3.fromRGB(26, 26, 28),
	FieldHover = Color3.fromRGB(38, 38, 41),
	FieldDisabled = Color3.fromRGB(22, 22, 24),
	Stroke = Color3.fromRGB(48, 48, 52),
	StrokeSoft = Color3.fromRGB(35, 35, 38),
	Divider = Color3.fromRGB(28, 28, 31),
	Track = Color3.fromRGB(70, 70, 74),
	Text = Color3.fromRGB(238, 238, 242),
	Muted = Color3.fromRGB(150, 150, 158),
	Faint = Color3.fromRGB(96, 96, 104),
	Icon = Color3.fromRGB(218, 218, 226),
	Accent = Color3.fromRGB(235, 235, 240),
	AccentDeep = Color3.fromRGB(160, 160, 168),
	Button = Color3.fromRGB(74, 74, 78),
	ButtonHover = Color3.fromRGB(90, 90, 94),
	Primary = Color3.fromRGB(132, 132, 135),
	PrimaryHover = Color3.fromRGB(148, 148, 152),
	PrimaryStroke = Color3.fromRGB(168, 168, 173),
	ToggleOff = Color3.fromRGB(26, 26, 28),
	ToggleOffKnob = Color3.fromRGB(232, 232, 238),
	ToggleDisabledTrack = Color3.fromRGB(108, 108, 112),
	ToggleDisabledKnob = Color3.fromRGB(84, 84, 88),
	Green = Color3.fromRGB(112, 230, 152),
	Red = Color3.fromRGB(255, 98, 98),
	Amber = Color3.fromRGB(255, 179, 71),
	Cyan = Color3.fromRGB(105, 205, 255),
	Pink = Color3.fromRGB(255, 128, 196),
	Violet = Color3.fromRGB(160, 132, 255),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
}
Nerx.Theme = Theme

local Fonts = {
	Regular = Enum.Font.GothamMedium,
	Bold = Enum.Font.GothamBold,
	Body = Enum.Font.Gotham,
	Mono = Enum.Font.Code,
}
Nerx.Fonts = Fonts

-- Neverlose itself draws its interface glyphs from Roblox's BuilderIcons font.
local IconFont
do
	local ok, font = pcall(function()
		return Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	end)
	if ok then
		IconFont = font
	end
end
Nerx.IconFont = IconFont

Nerx.Icons = {
	Aim = "crosshairs",
	Visuals = "eye",
	Misc = "gear",
	Configs = "file-box",
	Binds = "key-caps-lock",
	Themes = "paint-bucket",
	Search = "magnifying-glass",
	ChevronDown = "chevron-large-down",
	ChevronUp = "chevron-large-up",
	ChevronRight = "chevron-large-right",
	Dots = "three-dots-horizontal",
	Plus = "plus-small",
	Gear = "gear",
	Save = "floppy-disk",
	Reset = "arrow-spin-counter-clockwise-15",
	Grid = "grid",
	Pulse = "chart-line",
	Eye = "eye",
	Person = "person-standing",
	Globe = "globe-detailed",
	Map = "location-pin-map",
	Book = "book-closed",
	Lock = "lock-closed",
	Shield = "shield-check",
	Cube = "3d-cube-arrow-left",
	Star = "star",
	Check = "circle-check",
	X = "circle-x",
}

Nerx.Flags = {}
Nerx.Connections = {}
Nerx.Queries = {}
Nerx.AccentListeners = {}
Nerx.Windows = {}
Nerx.Popup = nil
Nerx.PopupOverlay = nil
Nerx.Indicators = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Nerx_" .. tostring(math.random(100000, 999999))
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 40

local attached = pcall(function()
	screenGui.Parent = parentGui
end)
if not attached or not screenGui.Parent then
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

Nerx.ScreenGui = screenGui
protect(screenGui)

Nerx.Scale = 1

local TWEEN = {
	Fast = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Default = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Slow = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	VerySlow = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

local U = {}
Nerx.U = U
U.Tween = TWEEN

-- ---------------------------------------------------------------------------------------
-- Generic construction helpers
-- ---------------------------------------------------------------------------------------

function U.new(class, props, parent)
	local object = Instance.new(class)
	if props then
		for key, value in pairs(props) do
			object[key] = value
		end
	end
	if parent then
		object.Parent = parent
	end
	return object
end

function U.frame(parent, props)
	return U.new("Frame", props, parent)
end

function U.label(parent, props)
	local defaults = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Fonts.Regular,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	local merged = {}
	for key, value in pairs(defaults) do
		merged[key] = value
	end
	if props then
		for key, value in pairs(props) do
			merged[key] = value
		end
	end
	return U.new("TextLabel", merged, parent)
end

function U.icon(parent, name, size, color, props)
	local defaults = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = name or "",
		TextColor3 = color or Theme.Icon,
		TextSize = size or 14,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = true,
	}
	if IconFont then
		defaults.FontFace = IconFont
	else
		defaults.Font = Fonts.Bold
	end
	if props then
		for key, value in pairs(props) do
			defaults[key] = value
		end
	end
	return U.new("TextLabel", defaults, parent)
end

function U.stroke(parent, color, transparency, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.Stroke
	stroke.Transparency = transparency == nil and 0.4 or transparency
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

function U.corner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

function U.padding(parent, top, right, bottom, left)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.Parent = parent
	return padding
end

function U.list(parent, padding, horizontal, vertical)
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, padding or 0)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = horizontal or Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = vertical or Enum.VerticalAlignment.Top
	layout.Parent = parent
	return layout
end

function U.inputButton(parent, callback)
	local button = Instance.new("ImageButton")
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.ImageTransparency = 1
	button.Size = UDim2.fromScale(1, 1)
	button.ZIndex = (parent.ZIndex or 1) + 1
	button.AutoButtonColor = false
	button.Image = ""
	button.Parent = parent
	if callback then
		U.connect(button.MouseButton1Click, callback)
	end
	return button
end

function U.measure(text, size, font)
	if not text or text == "" then
		return Vector2.new(0, size or 12)
	end
	local ok, value = pcall(function()
		return TextService:GetTextSize(text, size or 12, font or Fonts.Regular, Vector2.new(math.huge, math.huge))
	end)
	if ok and value then
		return value
	end
	return Vector2.new(#text * (size or 12) * 0.56, size or 12)
end

function U.measureWrap(text, size, font, width)
	if not text or text == "" then
		return Vector2.new(0, size or 12)
	end
	local ok, value = pcall(function()
		return TextService:GetTextSize(text, size or 12, font or Fonts.Regular, Vector2.new(width, math.huge))
	end)
	if ok and value then
		return value
	end
	return Vector2.new(width, (size or 12) * 2)
end

function U.round(value, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(value * mult + 0.5) / mult
end

function U.viewport()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1280, 720)
end

function U.tween(object, info, props)
	local tween = TweenService:Create(object, info or TWEEN.Default, props)
	tween:Play()
	return tween
end

function U.connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(Nerx.Connections, connection)
	return connection
end

function U.onAccent(callback)
	table.insert(Nerx.AccentListeners, callback)
	return callback
end

function U.shadow(parent, strength)
	local layers = { 3, 5, 8, 11 }
	for index, thickness in ipairs(layers) do
		local stroke = U.stroke(parent, Theme.Black, 1, thickness)
		stroke.Transparency = 0.66 + index * 0.075
		if strength == "soft" then
			stroke.Transparency = stroke.Transparency + 0.12
		end
	end
end

function U.drag(inputFrame, moveFrame, speed)
	local dragging = false
	local dragStart = nil
	local startPos = nil
	local tween = TweenInfo.new(speed or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	U.connect(inputFrame.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = moveFrame.Position
		end
	end)

	U.connect(inputFrame.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	U.connect(UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - dragStart
		U.tween(moveFrame, tween, {
			Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),
		})
	end)
end

-- ---------------------------------------------------------------------------------------
-- Color helpers
-- ---------------------------------------------------------------------------------------

function U.hex(color)
	local r = math.floor(math.clamp(color.R * 255, 0, 255) + 0.5)
	local g = math.floor(math.clamp(color.G * 255, 0, 255) + 0.5)
	local b = math.floor(math.clamp(color.B * 255, 0, 255) + 0.5)
	return string.format("#%02X%02X%02X", r, g, b)
end

function U.fromHex(text)
	local value = tostring(text or ""):gsub("#", "")
	if #value == 3 then
		value = value:sub(1, 1):rep(2) .. value:sub(2, 2):rep(2) .. value:sub(3, 3):rep(2)
	end
	if #value ~= 6 then
		return nil
	end
	local r = tonumber(value:sub(1, 2), 16)
	local g = tonumber(value:sub(3, 4), 16)
	local b = tonumber(value:sub(5, 6), 16)
	if not r or not g or not b then
		return nil
	end
	return Color3.fromRGB(r, g, b)
end

function U.rgbToHsv(color)
	local r, g, b = color.R, color.G, color.B
	local maxV = math.max(r, g, b)
	local minV = math.min(r, g, b)
	local delta = maxV - minV
	local h, s, v

	if delta == 0 then
		h = 0
	elseif maxV == r then
		h = ((g - b) / delta) % 6
	elseif maxV == g then
		h = ((b - r) / delta) + 2
	else
		h = ((r - g) / delta) + 4
	end

	h = h / 6
	if maxV == 0 then
		s = 0
	else
		s = delta / maxV
	end
	v = maxV
	return h, s, v
end

-- ---------------------------------------------------------------------------------------
-- Key codes
-- ---------------------------------------------------------------------------------------

U.KeyNames = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
	[Enum.KeyCode.Escape] = "ESC",
	[Enum.KeyCode.Insert] = "INS",
	[Enum.KeyCode.Delete] = "DEL",
	[Enum.KeyCode.KeypadEnter] = "ENTER",
	[Enum.KeyCode.Return] = "ENTER",
}

U.MouseKeys = {
    MB1 = Enum.UserInputType.MouseButton1,
    MB2 = Enum.UserInputType.MouseButton2,
    MB3 = Enum.UserInputType.MouseButton3,
    MouseButton1 = Enum.UserInputType.MouseButton1,
    MouseButton2 = Enum.UserInputType.MouseButton2,
    MouseButton3 = Enum.UserInputType.MouseButton3,
}

function U.keyName(keycode)
	if not keycode then
		return nil
	end
	if type(keycode) == "string" then
		return keycode
	end
	return U.KeyNames[keycode] or keycode.Name
end

function U.parseKey(value)
	if value == nil then
		return nil
	end
	if type(value) == "string" then
        local mouseKey = U.MouseKeys[value]
        if mouseKey then
            return mouseKey
        end
		local ok, key = pcall(function()
			return Enum.KeyCode[value]
		end)
		if ok then
			return key
		end
		return nil
	end
	return value
end

-- ---------------------------------------------------------------------------------------
-- Flow layout (wrapping chip rows)
-- ---------------------------------------------------------------------------------------

function U.flow(parent, gapX, gapY)
	local state = {
		Items = {},
		GapX = gapX or 6,
		GapY = gapY or 6,
		Height = 0,
		LastWidth = -1,
		Parent = parent,
	}

	local function layout(force)
		local width = parent.AbsoluteSize.X
		if width <= 0 then
			return
		end
		if not force and width == state.LastWidth then
			return
		end
		state.LastWidth = width

		local x, y, rowHeight = 0, 0, 0
		for _, item in ipairs(state.Items) do
			if x > 0 and x + item.Width > width then
				x = 0
				y = y + rowHeight + state.GapY
				rowHeight = 0
			end
			item.Frame.Position = UDim2.fromOffset(x, y)
			item.Frame.Size = UDim2.fromOffset(item.Width, item.Height)
			x = x + item.Width + state.GapX
			if item.Height > rowHeight then
				rowHeight = item.Height
			end
		end

		if #state.Items == 0 then
			state.Height = 0
		else
			state.Height = y + rowHeight
		end
		parent.Size = UDim2.new(parent.Size.X.Scale, parent.Size.X.Offset, 0, state.Height)
		if state.OnLayout then
			state.OnLayout(state.Height)
		end
	end

	function state:Add(frame, width, height)
		frame.AnchorPoint = Vector2.new(0, 0)
		table.insert(self.Items, { Frame = frame, Width = width, Height = height or 24 })
		layout(true)
		return frame
	end

	function state:Relayout()
		layout(true)
	end

	function state:Clear()
		for _, item in ipairs(self.Items) do
			item.Frame:Destroy()
		end
		self.Items = {}
		self:Relayout()
	end

	U.connect(parent:GetPropertyChangedSignal("AbsoluteSize"), function()
		layout(false)
	end)

	-- Layout once more after the surrounding page has finished laying itself out.
	task.defer(function()
		layout(true)
	end)

	return state
end

-- ---------------------------------------------------------------------------------------
-- Tooltip
-- ---------------------------------------------------------------------------------------

local tooltip = nil
do
	local frame = U.frame(nil, {
		Name = "NerxTooltip",
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(236, 46),
		Visible = false,
		ZIndex = 950,
		ClipsDescendants = true,
	})
	frame.Parent = screenGui
	U.corner(frame, 8)
	U.stroke(frame, Theme.Stroke, 0.55, 1)
	U.padding(frame, 9, 10, 9, 10)

	local title = U.label(frame, {
		Name = "Title",
		Font = Fonts.Bold,
		TextSize = 11,
		TextColor3 = Theme.Text,
		TextTransparency = 0.05,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 13),
		ZIndex = 951,
	})
	local body = U.label(frame, {
		Name = "Body",
		Font = Fonts.Regular,
		TextSize = 10,
		TextColor3 = Theme.Muted,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(0, 16),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 951,
	})
	local innerWidth = 236 - 20
	tooltip = { Root = frame, Title = title, Body = body, InnerWidth = innerWidth }
end

function U.tooltip(target, titleText, content)
	if not titleText and not content then
		return
	end
	local token = 0
	U.connect(target.MouseEnter, function()
		token = token + 1
		local mine = token
		task.delay(0.22, function()
			if mine ~= token then
				return
			end
			local root = tooltip.Root
			local heading = tooltip.Title
			local body = tooltip.Body

			heading.Text = titleText or ""
			body.Text = content or ""

			local titleHeight = 0
			if titleText and titleText ~= "" then
				titleHeight = 14
			end
			local bodyHeight = 0
			if content and content ~= "" then
				local measured = U.measureWrap(content, 10, Fonts.Regular, tooltip.InnerWidth)
				bodyHeight = measured.Y
			end
			body.Position = UDim2.fromOffset(0, titleHeight)
			body.Size = UDim2.new(1, 0, 0, bodyHeight)
			root.Size = UDim2.fromOffset(236, math.max(28, titleHeight + bodyHeight + 18))

			local mouse = UserInputService:GetMouseLocation()
			local viewport = U.viewport()
			local x = math.clamp(mouse.X + 14, 8, viewport.X - 244)
			local y = math.clamp(mouse.Y + 18, 8, viewport.Y - root.AbsoluteSize.Y - 8)
			root.Position = UDim2.fromOffset(x, y)
			root.Visible = true
			root.GroupTransparency = 1
			U.tween(root, TWEEN.Fast, { GroupTransparency = 0 })
		end)
	end)

	U.connect(target.MouseLeave, function()
		token = token + 1
		tooltip.Root.Visible = false
	end)
end

-- ---------------------------------------------------------------------------------------
-- Popups (dropdown lists, option menus, colour pickers, account menu)
-- ---------------------------------------------------------------------------------------

function Nerx:ClosePopup()
	if Nerx.Popup then
		local popup = Nerx.Popup
		Nerx.Popup = nil
		popup.Card:Destroy()
		popup.Overlay:Destroy()
		if popup.Escape then
			popup.Escape:Disconnect()
		end
	end
end

function U.popup(anchor, width, height, builder, alignRight)
	Nerx:ClosePopup()

	local overlay = U.frame(nil, {
		Name = "NerxPopupOverlay",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Active = true,
		ZIndex = 870,
	})
	overlay.Parent = screenGui

	local card = U.frame(nil, {
		Name = "NerxPopup",
		BackgroundColor3 = Theme.SurfaceRaised,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, height),
		ZIndex = 880,
		ClipsDescendants = false,
	})
	card.Parent = screenGui
	U.corner(card, 8)
	U.stroke(card, Theme.Stroke, 0.45, 1)
	U.shadow(card)

	local viewport = U.viewport()
	local absolute = anchor.AbsolutePosition
	local size = anchor.AbsoluteSize

	local x = absolute.X
	if alignRight then
		x = absolute.X + size.X - width
	end
	if x + width > viewport.X - 8 then
		x = absolute.X + size.X - width
	end
	if x < 8 then
		x = 8
	end

	local below = absolute.Y + size.Y + 6
	local above = absolute.Y - height - 6
	local y = below
	if below + height > viewport.Y - 8 then
		y = math.max(6, above)
	end

	card.Position = UDim2.fromOffset(x, y)
	card.GroupTransparency = 1
	card.Size = UDim2.fromOffset(width, height - 4)
	U.tween(card, TWEEN.Fast, { GroupTransparency = 0, Size = UDim2.fromOffset(width, height) })

	builder(card)

	-- Popup content is parented outside the window, so lift it above the card's own ZIndex.
	for _, object in ipairs(card:GetDescendants()) do
		if object:IsA("GuiObject") then
			object.ZIndex = math.max(tonumber(object.ZIndex) or 1, card.ZIndex + 1)
		end
	end

	local function dismiss()
		Nerx:ClosePopup()
	end

	U.connect(overlay.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dismiss()
		end
	end)

	local escape
	escape = U.connect(UserInputService.InputBegan, function(input)
		if input.KeyCode == Enum.KeyCode.Escape then
			dismiss()
		end
	end)

	Nerx.Popup = { Card = card, Overlay = overlay, Escape = escape }
	return card
end

-- ---------------------------------------------------------------------------------------
-- Accent colour
-- ---------------------------------------------------------------------------------------

function Nerx:SetAccent(color)
	Theme.Accent = color
	for _, callback in ipairs(Nerx.AccentListeners) do
		pcall(callback, color)
	end
end

function Nerx:GetAccent()
	return Theme.Accent
end

-- ---------------------------------------------------------------------------------------
-- Optional assets (Neverlose marks from github.com/tickcount/.p2c-icons, MIT)
-- ---------------------------------------------------------------------------------------

Nerx.Assets = {
	Neverlose = "https://raw.githubusercontent.com/tickcount/.p2c-icons/main/neverlose2.png",
	NeverloseAlt = "https://raw.githubusercontent.com/tickcount/.p2c-icons/main/neverlose.png",
}

function Nerx:LoadAsset(url, fileName)
	if not (writefile and getcustomasset and isfolder and makefolder) then
		return nil
	end
	local folder = "NerxAssets"
	local ok = pcall(function()
		if not isfolder(folder) then
			makefolder(folder)
		end
		local path = folder .. "/" .. fileName
		if not isfile(path) then
			local body = game:HttpGet(url)
			writefile(path, body)
		end
		return getcustomasset(path)
	end)
	if ok then
		local path = folder .. "/" .. fileName
		local success, value = pcall(getcustomasset, path)
		if success then
			return value
		end
	end
	return nil
end

function Nerx:GetNeverloseLogo()
	if Nerx._NeverloseLogo == nil then
		Nerx._NeverloseLogo = self:LoadAsset(self.Assets.Neverlose, "neverlose.png") or false
	end
	return Nerx._NeverloseLogo or nil
end


-- ---------------------------------------------------------------------------------------
-- Colour picker popup
-- ---------------------------------------------------------------------------------------

local function colorCubeSequence()
	local stops = {}
	for index = 0, 6 do
		local hue = index / 6
		table.insert(stops, ColorSequenceKeypoint.new(math.min(1, hue), Color3.fromHSV(hue, 1, 1)))
	end
	return ColorSequence.new(stops)
end

function U.colorPicker(anchor, initial, callback)
	local color = initial or Theme.Accent
	local h, s, v = U.rgbToHsv(color)
	local alpha = 1
	local silent = false

	local cubeSize = Vector2.new(196, 104)
	local hueWidth = 196
	local alphaWidth = 196
	local function emit()
		silent = true
		callback(Color3.fromHSV(h, s, v), alpha)
		silent = false
	end

	U.popup(anchor, 220, 200, function(card)
		U.padding(card, 12, 12, 12, 12)

		local cube = U.frame(card, {
			BackgroundColor3 = Color3.fromHSV(h, 1, 1),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(cubeSize.X, cubeSize.Y),
			Position = UDim2.fromOffset(0, 0),
			ClipsDescendants = true,
			Active = true,
		})
		U.corner(cube, 5)
		U.stroke(cube, Theme.Stroke, 0.55, 1)

		local saturationLayer = U.frame(cube, {
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		})
		local saturationGradient = Instance.new("UIGradient")
		saturationGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		saturationGradient.Parent = saturationLayer

		local valueLayer = U.frame(cube, {
			BackgroundColor3 = Theme.Black,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		})
		local valueGradient = Instance.new("UIGradient")
		valueGradient.Rotation = 90
		valueGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		})
		valueGradient.Parent = valueLayer

		local cubeMarker = U.frame(cube, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(9, 9),
			ZIndex = 4,
		})
		U.corner(cubeMarker, 9)
		U.stroke(cubeMarker, Theme.White, 0, 1.5)

		local hueBar = U.frame(card, {
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 116),
			Size = UDim2.fromOffset(hueWidth, 10),
			Active = true,
		})
		U.corner(hueBar, 5)
		local hueGradient = Instance.new("UIGradient")
		hueGradient.Color = colorCubeSequence()
		hueGradient.Parent = hueBar
		local hueMarker = U.frame(hueBar, {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(4, 14),
			Position = UDim2.new(0, 0, 0, -2),
			ZIndex = 4,
		})
		U.corner(hueMarker, 4)
		U.stroke(hueMarker, Theme.Black, 0.55, 1)

		local alphaBar = U.frame(card, {
			BackgroundColor3 = Color3.fromHSV(h, s, v),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 132),
			Size = UDim2.fromOffset(alphaWidth, 10),
			Active = true,
		})
		U.corner(alphaBar, 5)
		U.stroke(alphaBar, Theme.Stroke, 0.6, 1)
		local alphaGradient = Instance.new("UIGradient")
		alphaGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		})
		alphaGradient.Parent = alphaBar
		local alphaMarker = U.frame(alphaBar, {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(4, 14),
			Position = UDim2.new(1, 0, 0, -2),
			ZIndex = 4,
		})
		U.corner(alphaMarker, 4)
		U.stroke(alphaMarker, Theme.Black, 0.55, 1)

		local hexBox = U.new("TextBox", {
			BackgroundColor3 = Theme.Field,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Font = Fonts.Mono,
			Text = U.hex(color),
			TextColor3 = Theme.Text,
			TextSize = 9.5,
			TextXAlignment = Enum.TextXAlignment.Center,
			ClearTextOnFocus = false,
			Position = UDim2.fromOffset(0, 154),
			Size = UDim2.fromOffset(78, 22),
			ZIndex = 3,
		}, card)
		U.corner(hexBox, 5)
		U.stroke(hexBox, Theme.Stroke, 0.5, 1)

		local rgbBoxes = {}
		local channels = { "R", "G", "B" }
		for index = 1, 3 do
			local box = U.new("TextBox", {
				BackgroundColor3 = Theme.Field,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Font = Fonts.Mono,
				Text = tostring(math.floor(color[channels[index]] * 255 + 0.5)),
				TextColor3 = Theme.Text,
				TextSize = 9.5,
				TextXAlignment = Enum.TextXAlignment.Center,
				ClearTextOnFocus = false,
				Position = UDim2.fromOffset(82 + (index - 1) * 38, 154),
				Size = UDim2.fromOffset(34, 22),
				ZIndex = 3,
			}, card)
			U.corner(box, 5)
			U.stroke(box, Theme.Stroke, 0.5, 1)
			rgbBoxes[index] = box
		end

		local function refreshLabels()
			local current = Color3.fromHSV(h, s, v)
			cube.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			alphaBar.BackgroundColor3 = current
			cubeMarker.Position = UDim2.new(s, 0, 1 - v, 0)
			hueMarker.Position = UDim2.new(h, 0, 0, -2)
			alphaMarker.Position = UDim2.new(alpha, 0, 0, -2)
			alphaGradient.Rotation = 0
			if not silent then
				hexBox.Text = U.hex(current)
			end
			if not hexBox:IsFocused() then
				hexBox.Text = U.hex(current)
			end
			rgbBoxes[1].Text = tostring(math.floor(current.R * 255 + 0.5))
			rgbBoxes[2].Text = tostring(math.floor(current.G * 255 + 0.5))
			rgbBoxes[3].Text = tostring(math.floor(current.B * 255 + 0.5))
		end

		local hueBase = h
		local function applyHsv(shouldEmit)
			hueBase = h
			refreshLabels()
			if shouldEmit then
				emit()
			end
		end

		local function bindArea(frame, onInput)
			local holding = false
			U.connect(frame.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					holding = true
					onInput(input)
				end
			end)
			U.connect(frame.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					holding = false
				end
			end)
			U.connect(UserInputService.InputChanged, function(input)
				if holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					onInput(input)
				end
			end)
		end

		bindArea(cube, function(input)
			local position = cube.AbsolutePosition
			local size = cube.AbsoluteSize
			local nx = math.clamp((input.Position.X - position.X) / size.X, 0, 1)
			local ny = math.clamp((input.Position.Y - position.Y) / size.Y, 0, 1)
			s = nx
			v = 1 - ny
			applyHsv(true)
		end)

		bindArea(hueBar, function(input)
			local position = hueBar.AbsolutePosition
			local size = hueBar.AbsoluteSize
			h = math.clamp((input.Position.X - position.X) / size.X, 0, 1)
			applyHsv(true)
		end)

		bindArea(alphaBar, function(input)
			local position = alphaBar.AbsolutePosition
			local size = alphaBar.AbsoluteSize
			alpha = math.clamp((input.Position.X - position.X) / size.X, 0, 1)
			applyHsv(true)
		end)

		U.connect(hexBox.FocusLost, function()
			local parsed = U.fromHex(hexBox.Text)
			if parsed then
				h, s, v = U.rgbToHsv(parsed)
				applyHsv(true)
			else
				refreshLabels()
			end
		end)

		for index, box in ipairs(rgbBoxes) do
			U.connect(box.FocusLost, function()
				local value = tonumber(box.Text)
				if value then
					local channelsCopy = { color.R, color.G, color.B }
					local current = Color3.fromHSV(h, s, v)
					channelsCopy = { current.R, current.G, current.B }
					channelsCopy[index] = math.clamp(value, 0, 255) / 255
					local parsed = Color3.fromRGB(channelsCopy[1] * 255, channelsCopy[2] * 255, channelsCopy[3] * 255)
					h, s, v = U.rgbToHsv(parsed)
					applyHsv(true)
				else
					refreshLabels()
				end
			end)
		end

		refreshLabels()
	end)
end


-- ---------------------------------------------------------------------------------------
-- Shared widgets
-- ---------------------------------------------------------------------------------------

local function toggleWidget(parent, defaultValue, callback, disabled)
	local root = U.frame(parent, {
		BackgroundColor3 = Theme.ToggleOff,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(32, 18),
	})
	U.corner(root, 9)
	local border = U.stroke(root, Theme.Stroke, 0.55, 1)

	local knob = U.frame(root, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.ToggleOffKnob,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(0.3, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
	})
	U.corner(knob, 8)

	local value = defaultValue == true
	local api = { Root = root, Value = value, Disabled = disabled == true }

	local function render(animate)
		local info = animate and TWEEN.Default or TWEEN.Fast
		if api.Disabled then
			if value then
				U.tween(root, info, { BackgroundColor3 = Theme.ToggleDisabledTrack })
				U.tween(knob, info, { BackgroundColor3 = Theme.ToggleDisabledKnob, BackgroundTransparency = 0, Position = UDim2.new(0.7, 0, 0.5, 0) })
			else
				U.tween(root, info, { BackgroundColor3 = Theme.ToggleOff })
				U.tween(knob, info, { BackgroundColor3 = Theme.ToggleOffKnob, BackgroundTransparency = 0.55, Position = UDim2.new(0.3, 0, 0.5, 0) })
			end
			border.Transparency = 0.7
		elseif value then
			U.tween(root, info, { BackgroundColor3 = Theme.Accent })
			U.tween(knob, info, { BackgroundColor3 = Theme.Window, BackgroundTransparency = 0, Position = UDim2.new(0.7, 0, 0.5, 0) })
			border.Transparency = 0.65
		else
			U.tween(root, info, { BackgroundColor3 = Theme.ToggleOff })
			U.tween(knob, info, { BackgroundColor3 = Theme.ToggleOffKnob, BackgroundTransparency = 0, Position = UDim2.new(0.3, 0, 0.5, 0) })
			border.Transparency = 0.55
		end
	end

	function api:GetValue()
		return value
	end

	function api:SetValue(newValue, silent)
		value = newValue == true
		api.Value = value
		render(true)
		if not silent and callback then
			callback(value)
		end
	end

	U.inputButton(root, function()
		if not api.Disabled then
			api:SetValue(not value)
		end
	end)

	U.onAccent(function(color)
		if value and not api.Disabled then
			U.tween(root, TWEEN.Fast, { BackgroundColor3 = color })
		end
	end)

	render(false)
	return api
end

local function swatchWidget(parent, color, callback)
	local api = { Color = color or Theme.Accent }
	local root = U.frame(parent, {
		BackgroundColor3 = api.Color,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(14, 14),
	})
	U.corner(root, 3)
	local stroke = U.stroke(root, Theme.White, 0.35, 1)

	api.Root = root
	function api:SetColor(newColor, silent)
		api.Color = newColor
		root.BackgroundColor3 = newColor
		if not silent and callback then
			callback(newColor)
		end
	end

	local input = U.inputButton(root, function()
		U.colorPicker(root, api.Color, function(picked)
			api:SetColor(picked)
		end)
	end)
	U.connect(input.MouseEnter, function()
		stroke.Transparency = 0.12
	end)
	U.connect(input.MouseLeave, function()
		stroke.Transparency = 0.35
	end)
	return api
end

local function attachOptions(api)
	api.Options = {}
	function api:AddOption(name, callback)
		table.insert(api.Options, { Name = name, Callback = callback })
		return api
	end
	return api
end

local function menuItemsFor(component, config)
	local items = {
		{
			Name = "Reset",
			Callback = function()
				component:SetValue(config.Default)
			end,
		},
		{
			Name = "Copy value",
			Callback = function()
				if setclipboard then
					pcall(setclipboard, tostring(component:GetValue()))
				end
			end,
		},
	}
	if component.Options then
		for _, item in ipairs(component.Options) do
			table.insert(items, item)
		end
	end
	return items
end

local function openMenu(anchor, items)
	local height = 10 + #items * 28
	U.popup(anchor, 158, height, function(card)
		U.padding(card, 5, 5, 5, 5)
		local list = U.frame(card, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, #items * 28),
		})
		U.list(list, 0)

		for _, item in ipairs(items) do
			local row = U.frame(list, {
				BackgroundColor3 = Theme.White,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 28),
			})
			U.corner(row, 5)

			local label = U.label(row, {
				Text = item.Name,
				TextSize = 11,
				TextColor3 = Theme.Muted,
				TextTransparency = 0.2,
				Position = UDim2.fromOffset(9, 0),
				Size = UDim2.new(1, -18, 1, 0),
			})

			local input = U.inputButton(row, function()
				Nerx:ClosePopup()
				if item.Callback then
					item.Callback()
				end
			end)
			U.connect(input.MouseEnter, function()
				U.tween(row, TWEEN.Fast, { BackgroundTransparency = 0.94 })
				U.tween(label, TWEEN.Fast, { TextTransparency = 0 })
			end)
			U.connect(input.MouseLeave, function()
				U.tween(row, TWEEN.Fast, { BackgroundTransparency = 1 })
				U.tween(label, TWEEN.Fast, { TextTransparency = 0.2 })
			end)
		end
	end)
end

local function optionDots(parent, component, config)
	local root = U.frame(parent, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(18, 20),
	})
	local icon = U.icon(root, "three-dots-horizontal", 15, Theme.Muted, {
		TextTransparency = 0.45,
		Size = UDim2.fromScale(1, 1),
	})
	local input = U.inputButton(root, function()
		openMenu(root, menuItemsFor(component, config))
	end)
	U.connect(input.MouseEnter, function()
		U.tween(icon, TWEEN.Fast, { TextTransparency = 0.1 })
	end)
	U.connect(input.MouseLeave, function()
		U.tween(icon, TWEEN.Fast, { TextTransparency = 0.45 })
	end)
	return root
end

local function dropdownField(parent, width, disabled)
	local field = U.frame(parent, {
		BackgroundColor3 = disabled and Theme.FieldDisabled or Theme.Field,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width or 132, 24),
	})
	U.corner(field, 5)

	local label = U.label(field, {
		Text = "",
		TextSize = 11,
		TextColor3 = disabled and Theme.Faint or Theme.Text,
		TextTransparency = disabled and 0.55 or 0.12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.new(1, -30, 1, 0),
	})
	local chevron = U.icon(field, "chevron-large-down", 10, Theme.Muted, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		TextTransparency = disabled and 0.65 or 0.4,
	})
	return field, label, chevron
end

local function openDropdown(field, options, onSelect, disabled)
	if disabled then
		return
	end
	local height = 10 + #options * 28
	local width = math.max(140, field.AbsoluteSize.X)
	U.popup(field, width, height, function(card)
		U.padding(card, 5, 5, 5, 5)
		local list = U.frame(card, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, #options * 28),
		})
		U.list(list, 0)

		for _, option in ipairs(options) do
			local row = U.frame(list, {
				BackgroundColor3 = Theme.White,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 28),
			})
			U.corner(row, 5)
			local label = U.label(row, {
				Text = tostring(option),
				TextSize = 11,
				TextColor3 = Theme.Text,
				TextTransparency = 0.15,
				Position = UDim2.fromOffset(9, 0),
				Size = UDim2.new(1, -34, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			local input = U.inputButton(row, function()
				Nerx:ClosePopup()
				onSelect(option)
			end)
			U.connect(input.MouseEnter, function()
				U.tween(row, TWEEN.Fast, { BackgroundTransparency = 0.94 })
			end)
			U.connect(input.MouseLeave, function()
				U.tween(row, TWEEN.Fast, { BackgroundTransparency = 1 })
			end)
		end
	end)
end

local function smallButton(parent, text, callback, disabled)
	local api = { Disabled = disabled == true }
	local root = U.frame(parent, {
		BackgroundColor3 = api.Disabled and Theme.FieldDisabled or Theme.Button,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(74, 24),
	})
	U.corner(root, 5)
	local label = U.label(root, {
		Text = text or "Button",
		TextSize = 10.5,
		TextColor3 = api.Disabled and Theme.Faint or Theme.Text,
		TextTransparency = api.Disabled and 0.55 or 0.05,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})

	api.Root = root
	function api:SetText(value)
		label.Text = value
	end
	function api:SetDisabled(value)
		api.Disabled = value
		root.BackgroundColor3 = value and Theme.FieldDisabled or Theme.Button
		label.TextColor3 = value and Theme.Faint or Theme.Text
		label.TextTransparency = value and 0.55 or 0.05
	end

	local input = U.inputButton(root, function()
		if not api.Disabled and callback then
			callback()
		end
	end)
	U.connect(input.MouseEnter, function()
		if not api.Disabled then
			U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.ButtonHover })
		end
	end)
	U.connect(input.MouseLeave, function()
		U.tween(root, TWEEN.Fast, { BackgroundColor3 = api.Disabled and Theme.FieldDisabled or Theme.Button })
	end)
	return api
end

local function primaryButton(parent, text, width, height, callback)
	local root = U.frame(parent, {
		BackgroundColor3 = Theme.Primary,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width or 84, height or 28),
	})
	U.corner(root, 6)
	U.stroke(root, Theme.PrimaryStroke, 0.35, 1)
	local label = U.label(root, {
		Text = text or "Button",
		TextSize = 11,
		TextColor3 = Theme.Text,
		TextTransparency = 0.05,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	local input = U.inputButton(root, callback or function() end)
	U.connect(input.MouseEnter, function()
		U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.PrimaryHover })
	end)
	U.connect(input.MouseLeave, function()
		U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.Primary })
	end)
	return { Root = root, Label = label }
end

-- ---------------------------------------------------------------------------------------
-- Chips
-- ---------------------------------------------------------------------------------------

U.ChipPalette = {
	Theme.Accent,
	Theme.Green,
	Theme.Red,
	Theme.Amber,
	Theme.Cyan,
	Theme.Pink,
	Theme.White,
}

local function normalizeChip(item)
	if type(item) == "string" then
		return { Name = item }
	end
	return item
end

local function createChip(parent, rawItem, options)
	local item = normalizeChip(rawItem)
	options = options or {}
	local height = options.Height or 24
	local textSize = options.TextSize or 11
	local dotSize = 6
	local iconSize = 12
	local hasIcon = item.Icon and true or false
	local hasDot = item.ShowDot == true or (item.ShowDot ~= false and item.Color ~= nil)
	local dotSide = options.DotSide or "left"
	local textWidth = U.measure(item.Name or "", textSize, Fonts.Regular).X
	local iconOnly = (item.Name == nil or item.Name == "") and hasIcon
	local width

	if iconOnly then
		width = height + 6
	else
		local content = textWidth
		if hasIcon then
			content = content + iconSize + 6
		end
		if hasDot then
			content = content + dotSize + 6
		end
		width = math.max(height + 6, 20 + content)
	end

	local root = U.frame(parent, {
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, height),
	})
	U.corner(root, math.floor(height / 2))
	local stroke = U.stroke(root, Theme.Stroke, 0.5, 1)

	local iconLabel = nil
	local dot = nil
	local textLabel = nil
	local cursor = 10

	if hasIcon then
		iconLabel = U.icon(root, item.Icon, iconSize, Theme.Muted, {
			Position = UDim2.fromOffset(cursor, 0),
			Size = UDim2.fromOffset(iconSize, height),
			TextTransparency = 0.45,
		})
		cursor = cursor + iconSize + 6
	end

	if hasDot and dotSide == "left" then
		dot = U.frame(root, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = item.Color or Theme.Accent,
			BorderSizePixel = 0,
			Position = UDim2.new(0, cursor, 0.5, 0),
			Size = UDim2.fromOffset(dotSize, dotSize),
		})
		U.corner(dot, 3)
		cursor = cursor + dotSize + 6
	end

	if item.Name and item.Name ~= "" then
		textLabel = U.label(root, {
			Text = item.Name,
			TextSize = textSize,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.35,
			Position = UDim2.fromOffset(cursor, 0),
			Size = UDim2.fromOffset(textWidth + 2, height),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
	end

	if hasDot and dotSide == "right" then
		dot = U.frame(root, {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = item.Color or Theme.Green,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(dotSize, dotSize),
		})
		U.corner(dot, 3)
	end

	local api = {
		Root = root,
		Item = item,
		Selected = item.Selected == true,
		Color = item.Color or Theme.Green,
	}

	local function render()
		local selected = api.Selected
		root.BackgroundColor3 = selected and Theme.FieldHover or Theme.Field
		root.BackgroundTransparency = selected and 0 or 0.2
		stroke.Transparency = selected and 0.3 or 0.55
		stroke.Color = selected and Theme.Accent or Theme.StrokeSoft

		if textLabel then
			textLabel.TextColor3 = selected and Theme.Text or Theme.Muted
			textLabel.TextTransparency = selected and 0.02 or 0.35
		end
		if iconLabel then
			iconLabel.TextColor3 = selected and Theme.Text or Theme.Muted
			iconLabel.TextTransparency = selected and 0.1 or 0.5
		end
		if dot then
			dot.BackgroundColor3 = api.Color
			dot.BackgroundTransparency = selected and 0 or 0.4
		end
	end

	function api:SetSelected(value, silent)
		api.Selected = value == true
		api.Item.Selected = api.Selected
		render()
		if not silent and options.OnSelect then
			options.OnSelect(api)
		end
	end

	function api:SetColor(color)
		api.Color = color
		api.Item.Color = color
		render()
	end

	api.Render = render
	api.Width = width
	api.Height = height
	render()

	U.onAccent(function(color)
		if api.Selected then
			stroke.Color = color
		end
	end)

	local input = U.inputButton(root, function()
		if options.Radio then
			if options.OnSelect then
				options.OnSelect(api)
			end
		else
			api:SetSelected(not api.Selected)
		end
	end)

	U.connect(input.MouseEnter, function()
		U.tween(root, TWEEN.Fast, { BackgroundTransparency = api.Selected and 0 or 0.02 })
	end)
	U.connect(input.MouseLeave, function()
		render()
	end)

	if hasDot and options.OnColor then
		U.connect(input.InputBegan, function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
				api.ColorIndex = (api.ColorIndex or 0) + 1
				if api.ColorIndex > #U.ChipPalette then
					api.ColorIndex = 1
				end
				api:SetColor(U.ChipPalette[api.ColorIndex])
				options.OnColor(api)
			end
		end)
	end

	return api, width, height
end

-- ---------------------------------------------------------------------------------------
-- Reusable widgets for custom pages
-- ---------------------------------------------------------------------------------------

local function dropdownWidget(parent, config)
	config = config or {}
	local options = config.Options or { "Enabled", "Disabled" }
	local value = config.Default or options[1]
	local field, fieldLabel = dropdownField(parent, config.Width or 130, config.Disabled)
	fieldLabel.Text = tostring(value)

	local api = { Root = field, Options = config.Options or {}, Value = value }

	local function select(option, silent)
		value = option
		api.Value = option
		fieldLabel.Text = tostring(option)
		if not silent and config.Callback then
			config.Callback(option)
		end
	end

	function api:GetValue()
		return value
	end

	function api:SetValue(option, silent)
		select(option, silent)
	end

	U.inputButton(field, function()
		openDropdown(field, options, function(selected)
			select(selected)
		end, config.Disabled)
	end)
	return api
end

local function segmentedWidget(parent, config)
	config = config or {}
	local items = config.Items or {}
	local width = config.Width or 0
	local height = config.Height or 24
	local container = config.Container ~= false
	local selectedColor = config.Primary and Theme.Primary or Theme.Selected
	local selectedText = config.Primary and Theme.Window or Theme.Text

	local root = U.frame(parent, {
		BackgroundColor3 = container and Theme.Field or Theme.White,
		BackgroundTransparency = container and 0 or 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, height),
	})
	U.corner(root, 6)
	if container then
		U.stroke(root, Theme.Stroke, 0.7, 1)
	end

	local buttons = {}
	local value = config.Selected or (items[1] and (items[1].Name or items[1]) ) or nil
	local api = { Root = root, Value = value }

	local function render()
		for _, button in ipairs(buttons) do
			local active = button.Name == value
			button.Root.BackgroundColor3 = active and selectedColor or Theme.White
			button.Root.BackgroundTransparency = active and 0 or 1
			button.Label.TextColor3 = active and selectedText or Theme.Muted
			button.Label.TextTransparency = active and 0.05 or 0.35
		end
	end

	local count = math.max(1, #items)
	local segmentWidth = width / count
	for index, rawItem in ipairs(items) do
		local item = type(rawItem) == "string" and { Name = rawItem } or rawItem
		local name = item.Name or tostring(item)
		local button = U.frame(root, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset((index - 1) * segmentWidth, 0),
			Size = UDim2.fromOffset(segmentWidth, height),
		})
		U.corner(button, 5)
		local label = U.label(button, {
			Text = name,
			TextSize = config.TextSize or 10,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.35,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
		})
		buttons[index] = { Root = button, Label = label, Name = name }
		U.inputButton(button, function()
			if item.Disabled then
				return
			end
			if value == name then
				return
			end
			value = name
			api.Value = name
			render()
			if config.Callback then
				config.Callback(name)
			end
		end)
	end

	function api:GetValue()
		return value
	end

	function api:SetValue(name, silent)
		value = name
		api.Value = name
		render()
		if not silent and config.Callback then
			config.Callback(name)
		end
	end

	render()
	return api
end

local function inputWidget(parent, config)
	config = config or {}
	local root = U.frame(parent, {
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(config.Width or 200, config.Height or 28),
	})
	U.corner(root, 6)
	local stroke = U.stroke(root, Theme.Stroke, 0.7, 1)
	local iconOffset = 0
	if config.Icon then
		U.icon(root, config.Icon, 12, Theme.Muted, {
			Position = UDim2.fromOffset(9, 0),
			Size = UDim2.fromOffset(14, config.Height or 28),
			TextTransparency = 0.3,
		})
		iconOffset = 18
	end
	local box = U.new("TextBox", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Fonts.Regular,
		Text = config.Text or "",
		PlaceholderText = config.Placeholder or "",
		PlaceholderColor3 = Theme.Faint,
		TextColor3 = Theme.Text,
		TextSize = config.TextSize or 10.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Position = UDim2.fromOffset(10 + iconOffset, 0),
		Size = UDim2.new(1, -(20 + iconOffset), 1, 0),
	}, root)

	local api = { Root = root, Box = box }
	function api:GetValue()
		return box.Text
	end
	function api:SetValue(value, silent)
		box.Text = tostring(value or "")
		if not silent and config.Callback then
			config.Callback(box.Text)
		end
	end
	U.connect(box.Focused, function()
		stroke.Transparency = 0.25
		U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
	end)
	U.connect(box.FocusLost, function()
		stroke.Transparency = 0.7
		U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.Field })
		if config.Callback then
			config.Callback(box.Text)
		end
	end)
	return api
end

Nerx.Widgets = {
	Toggle = toggleWidget,
	Swatch = swatchWidget,
	Button = smallButton,
	PrimaryButton = primaryButton,
	Dropdown = dropdownWidget,
	Segmented = segmentedWidget,
	Input = inputWidget,
	Chip = createChip,
	Tooltip = U.tooltip,
	Field = dropdownField,
	OpenDropdown = openDropdown,
}

-- ---------------------------------------------------------------------------------------
-- Section
-- ---------------------------------------------------------------------------------------

local function addRow(section, config, options)
	options = options or {}
	local inset = section.Inset or 12
	local row = U.frame(section.Card, {
		BackgroundColor3 = Theme.White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, options.Height or 34),
		ClipsDescendants = false,
	})
	row.LayoutOrder = section.RowCount + 1

	section.RowCount = section.RowCount + 1

	if section.RowCount > 1 then
		U.frame(row, {
			BackgroundColor3 = Theme.StrokeSoft,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(inset, 0),
			Size = UDim2.new(1, -inset * 2, 0, 1),
		})
	end

	local label
	if options.NoLabel ~= true then
		local reserve = options.Reserve or 60
		label = U.label(row, {
			Text = config.Name or "",
			Font = Fonts.Regular,
			TextSize = options.TextSize or 12.5,
			TextColor3 = Theme.Text,
			TextTransparency = options.Disabled and 0.55 or 0.03,
			Position = UDim2.fromOffset(inset, 0),
			Size = UDim2.new(1, -(reserve + inset), 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
		})
	end

	local controls
	if options.NoControls ~= true then
		controls = U.frame(row, {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -inset, 0.5, 0),
			Size = UDim2.fromOffset(0, 24),
			AutomaticSize = Enum.AutomaticSize.X,
		})
		U.list(controls, 6, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	end

	section.Rows[#section.Rows + 1] = {
		Root = row,
		Name = config.Name or "",
	}
	table.insert(Nerx.Queries, {
		Root = row,
		Name = config.Name or "",
		Section = section,
	})

	if config.ToolTip and row then
		U.tooltip(row, config.Name or "", config.ToolTip)
	end

	local hover = U.inputButton(row, nil)
	-- Keep the hover catcher below the row's controls.
	hover.ZIndex = 0
	U.connect(hover.MouseEnter, function()
		U.tween(row, TWEEN.Fast, { BackgroundTransparency = 0.965 })
	end)
	U.connect(hover.MouseLeave, function()
		U.tween(row, TWEEN.Fast, { BackgroundTransparency = 1 })
	end)

	return row, controls, label
end

local controlCounters = setmetatable({}, { __mode = "k" })

local function addControl(controls, object)
	local count = (controlCounters[controls] or 0) + 1
	controlCounters[controls] = count
	object.LayoutOrder = count
	return object
end

local function createSection(page, config)
	config = config or {}
	local name = config.Name or "SECTION"
	local column = string.lower(config.Column or "left")
	local host = column == "right" and page.RightScroll or page.LeftScroll
	local flat
	if config.Flat == nil then
		flat = page.SectionStyle == "flat"
	else
		flat = config.Flat == true
	end
	local useCard = config.Card ~= false and not flat

	if column == "right" then
		page:ShowRightSections()
	end

	local root = U.frame(host, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	root.LayoutOrder = page.BlockIndex + 1000
	page.BlockIndex = page.BlockIndex + 1

	local labelRow = U.frame(root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 15),
	})
	local label = U.label(labelRow, {
		Text = string.upper(name),
		Font = Fonts.Bold,
		TextSize = 10,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.5,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(0.62, 0, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local actions = U.frame(labelRow, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(0, 19),
		AutomaticSize = Enum.AutomaticSize.X,
	})
	U.list(actions, 4, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

	local card = U.frame(root, {
		BackgroundColor3 = useCard and Theme.Surface or Theme.White,
		BackgroundTransparency = useCard and 0.01 or 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = useCard,
	})
	U.corner(card, 8)
	local cardStroke = U.stroke(card, Theme.Stroke, useCard and 0.55 or 1, 1)
	U.padding(card, useCard and 2 or 0, 0, useCard and 2 or 0, 0)
	U.list(card, 0)

	local section = {
		Root = root,
		Card = card,
		Label = label,
		LabelRow = labelRow,
		Actions = actions,
		Page = page,
		Name = name,
		Rows = {},
		RowCount = 0,
		Options = {},
		Flat = flat,
		Inset = flat and 0 or 12,
	}

	function section:AddOption(optionName, callback)
		table.insert(section.Options, { Name = optionName, Callback = callback })
		return section
	end

	function section:AddToggle(toggleConfig)
		toggleConfig = toggleConfig or {}
		local reserve = 60
		if toggleConfig.ShowOption then
			reserve = reserve + 24
		end
		if toggleConfig.Swatch or toggleConfig.Color then
			reserve = reserve + 20
		end

		local row, controls = addRow(section, toggleConfig, {
			Reserve = reserve,
			Disabled = toggleConfig.Disabled,
		})

		local api = attachOptions({
			Root = row,
			Default = toggleConfig.Default,
			Name = toggleConfig.Name,
		})

		if toggleConfig.ShowOption then
			addControl(controls, optionDots(controls, api, toggleConfig))
		end
		if toggleConfig.Swatch or toggleConfig.Color then
			api.Swatch = swatchWidget(controls, toggleConfig.Swatch or toggleConfig.Color, function(color)
				if toggleConfig.ColorCallback then
					toggleConfig.ColorCallback(color)
				end
			end)
			if toggleConfig.Disabled then
				api.Swatch.Root.BackgroundTransparency = 0.45
			end
			addControl(controls, api.Swatch.Root)
		end

		local toggle = toggleWidget(controls, toggleConfig.Default, function(value)
			if toggleConfig.Callback then
				toggleConfig.Callback(value)
			end
		end, toggleConfig.Disabled)
		api.Toggle = toggle
		api.ToggleRoot = addControl(controls, toggle.Root)

		function api:GetValue()
			return api.Toggle:GetValue()
		end

		function api:SetValue(value, silent)
			api.Toggle:SetValue(value, silent)
		end

		if toggleConfig.Flag then
			Nerx.Flags[toggleConfig.Flag] = api
		end
		page:RegisterComponent(api)
		return api
	end

	function section:AddSlider(sliderConfig)
		sliderConfig = sliderConfig or {}
		local minValue = sliderConfig.Min or 0
		local maxValue = sliderConfig.Max or 100
		local rounding = sliderConfig.Rounding or 0
		local decimals = math.max(0, rounding)

		local row = addRow(section, sliderConfig, {
			Height = 34,
			NoLabel = true,
			NoControls = true,
		})
		local inset = section.Inset or 12

		local label = U.label(row, {
			Text = sliderConfig.Name or "",
			TextSize = 12.5,
			TextColor3 = Theme.Text,
			TextTransparency = 0.03,
			Position = UDim2.fromOffset(inset, 0),
			Size = UDim2.new(1, -230, 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local track = U.frame(row, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 170, 0.5, 0),
			Size = UDim2.fromOffset(140, 18),
		})

		local rail = U.frame(track, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.Track,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0, 3),
		})
		U.corner(rail, 2)

		local fill = U.frame(rail, {
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
		})
		U.corner(fill, 2)

		local knob = U.frame(track, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(10, 10),
			ZIndex = 3,
		})
		U.corner(knob, 5)

		local valuePill = U.frame(row, {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Theme.Field,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -inset, 0.5, 0),
			Size = UDim2.fromOffset(52, 24),
		})
		U.corner(valuePill, 5)
		U.stroke(valuePill, Theme.Stroke, 0.5, 1)
		local valueBox = U.new("TextBox", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Fonts.Regular,
			Text = "",
			TextColor3 = Theme.Text,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ClearTextOnFocus = false,
			Size = UDim2.fromScale(1, 1),
		}, valuePill)

		local value = math.clamp(sliderConfig.Default or minValue, minValue, maxValue)
		value = U.round(value, decimals)

		local function formatValue()
			if sliderConfig.Nums and sliderConfig.Nums[value] then
				return tostring(sliderConfig.Nums[value])
			end
			if sliderConfig.Format then
				return sliderConfig.Format(value)
			end
			return tostring(value) .. tostring(sliderConfig.Type or "")
		end

		local function ratio()
			if maxValue == minValue then
				return 0
			end
			return math.clamp((value - minValue) / (maxValue - minValue), 0, 1)
		end

		local function render()
			local scale = ratio()
			U.tween(fill, TWEEN.Fast, { Size = UDim2.new(scale, 0, 1, 0) })
			U.tween(knob, TWEEN.Fast, { Position = UDim2.new(scale, 0, 0.5, 0) })
			valueBox.Text = formatValue()
		end

		local function layout()
			local width = row.AbsoluteSize.X
			if width <= 0 then
				return
			end
			local left = math.clamp(math.floor(width * 0.48), 118, 210)
			label.Size = UDim2.new(0, left - inset - 14, 1, 0)
			track.Position = UDim2.new(0, left, 0.5, 0)
			track.Size = UDim2.new(0, math.max(56, width - left - inset - 62), 0, 18)
		end

		local api = attachOptions({
			Root = row,
			Default = sliderConfig.Default,
			Name = sliderConfig.Name,
		})

		function api:GetValue()
			return value
		end

		function api:SetValue(newValue, silent)
			value = U.round(math.clamp(tonumber(newValue) or value, minValue, maxValue), decimals)
			render()
			if not silent and sliderConfig.Callback then
				sliderConfig.Callback(value)
			end
		end

		local function updateFromInput(input)
			local position = track.AbsolutePosition
			local size = track.AbsoluteSize
			if size.X <= 0 then
				return
			end
			local scale = math.clamp((input.Position.X - position.X) / size.X, 0, 1)
			local raw = minValue + (maxValue - minValue) * scale
			api:SetValue(U.round(raw, decimals))
		end

		local holding = false
		local button = U.inputButton(track, nil)
		U.connect(button.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				holding = true
				updateFromInput(input)
			end
		end)
		U.connect(button.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				holding = false
			end
		end)
		U.connect(UserInputService.InputChanged, function(input)
			if holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromInput(input)
			end
		end)
		U.connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				holding = false
			end
		end)

		U.onAccent(function(color)
			fill.BackgroundColor3 = color
		end)
		U.connect(valueBox.FocusLost, function()
			local parsed = tonumber(valueBox.Text:gsub("[^%d%.%-]", ""))
			if parsed then
				api:SetValue(parsed)
			else
				render()
			end
		end)

		U.connect(row:GetPropertyChangedSignal("AbsoluteSize"), layout)
		layout()
		render()

		if sliderConfig.Flag then
			Nerx.Flags[sliderConfig.Flag] = api
		end
		page:RegisterComponent(api)
		return api
	end

	function section:AddDropdown(dropdownConfig)
		dropdownConfig = dropdownConfig or {}
		local options = dropdownConfig.Options or { "Enabled", "Disabled" }
		local reserve = 160
		if dropdownConfig.ShowOption then
			reserve = reserve + 24
		end
		if dropdownConfig.Swatch or dropdownConfig.Color then
			reserve = reserve + 20
		end

		local row, controls = addRow(section, dropdownConfig, {
			Reserve = reserve,
			Disabled = dropdownConfig.Disabled,
		})
		local api = attachOptions({
			Root = row,
			Default = dropdownConfig.Default or options[1],
			Name = dropdownConfig.Name,
			Disabled = dropdownConfig.Disabled == true,
			Value = dropdownConfig.Default or options[1],
		})

		if dropdownConfig.ShowOption then
			addControl(controls, optionDots(controls, api, dropdownConfig))
		end
		if dropdownConfig.Swatch or dropdownConfig.Color then
			api.Swatch = swatchWidget(controls, dropdownConfig.Swatch or dropdownConfig.Color, function(color)
				if dropdownConfig.ColorCallback then
					dropdownConfig.ColorCallback(color)
				end
			end)
			if api.Disabled then
				api.Swatch.Root.BackgroundTransparency = 0.45
			end
			addControl(controls, api.Swatch.Root)
		end

		local field, fieldLabel = dropdownField(controls, dropdownConfig.Width or 132, api.Disabled)
		fieldLabel.Text = tostring(api.Value)
		api.Field = addControl(controls, field)
		api.Label = fieldLabel

		local function select(option, silent)
			api.Value = option
			fieldLabel.Text = tostring(option)
			if not silent and dropdownConfig.Callback then
				dropdownConfig.Callback(option)
			end
		end

		function api:GetValue()
			return api.Value
		end

		function api:SetValue(option, silent)
			select(option, silent)
		end

		U.inputButton(field, function()
			local currentOptions = options
			openDropdown(field, currentOptions, function(selected)
				select(selected)
			end, api.Disabled)
		end)

		if dropdownConfig.Flag then
			Nerx.Flags[dropdownConfig.Flag] = api
		end
		page:RegisterComponent(api)
		return api
	end

	function section:AddKeybind(keyConfig)
		keyConfig = keyConfig or {}
		local row, controls = addRow(section, keyConfig, { Reserve = 124 })

		local key = U.parseKey(keyConfig.Default)
		local capturing = false
		local captureConnection = nil

		local field = U.frame(controls, {
			BackgroundColor3 = Theme.Field,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(108, 24),
		})
		U.corner(field, 5)
		local text = U.label(field, {
			Text = key and U.keyName(key) or "click to set",
			TextSize = key and 10 or 9.5,
			TextColor3 = key and Theme.Text or Theme.Faint,
			TextTransparency = key and 0.15 or 0.55,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
		})
		addControl(controls, field)

		local api = attachOptions({
			Root = row,
			Default = keyConfig.Default,
			Name = keyConfig.Name,
			Key = key,
		})

		local function refresh()
			if key then
				text.Text = U.keyName(key)
				text.TextSize = 10
				text.TextColor3 = Theme.Text
				text.TextTransparency = 0.15
			else
				text.Text = "click to set"
				text.TextSize = 9.5
				text.TextColor3 = Theme.Faint
				text.TextTransparency = 0.55
			end
		end

		local function stopCapture()
			capturing = false
			Nerx.CapturingKeybind = false
			if Nerx.ActiveKeybindCapture == stopCapture then
				Nerx.ActiveKeybindCapture = nil
			end
			if captureConnection then
				captureConnection:Disconnect()
				captureConnection = nil
			end
		end

		function api:GetValue()
			return key and U.keyName(key) or nil
		end

		function api:SetValue(value, silent)
			key = U.parseKey(value)
			api.Key = key
			if key then
				api.Value = U.keyName(key)
			else
				api.Value = nil
			end
			refresh()
			if not silent and keyConfig.Callback then
				keyConfig.Callback(api.Value, key)
			end
		end

		U.inputButton(field, function()
			if capturing then
				stopCapture()
				refresh()
				return
			end
			if Nerx.ActiveKeybindCapture then
				pcall(Nerx.ActiveKeybindCapture)
			end
			capturing = true
			Nerx.CapturingKeybind = true
			Nerx.ActiveKeybindCapture = stopCapture
			text.Text = "..."
			text.TextColor3 = Theme.Accent
			text.TextTransparency = 0
			text.TextSize = 10

			task.defer(function()
				if not capturing then
					return
				end
				captureConnection = U.connect(UserInputService.InputBegan, function(input)
					local key = input.KeyCode
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						key = Enum.UserInputType.MouseButton1
					elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
						key = Enum.UserInputType.MouseButton2
					elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
						key = Enum.UserInputType.MouseButton3
					end
					if key == Enum.KeyCode.Unknown then
						return
					end
					stopCapture()
					if key == Enum.KeyCode.Escape then
						api:SetValue(nil)
						return
					end
					api:SetValue(key)
				end)
			end)
		end)

		if keyConfig.Flag then
			Nerx.Flags[keyConfig.Flag] = api
		end
		page:RegisterComponent(api)
		return api
	end

	function section:AddInput(inputConfig)
		inputConfig = inputConfig or {}
		local row, controls = addRow(section, inputConfig, { Reserve = 160 })

		local field = U.frame(controls, {
			BackgroundColor3 = Theme.Field,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(142, 24),
		})
		U.corner(field, 5)
		local box = U.new("TextBox", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Fonts.Regular,
			Text = inputConfig.Default or "",
			PlaceholderText = inputConfig.Placeholder or "click to set",
			PlaceholderColor3 = Theme.Faint,
			TextColor3 = Theme.Text,
			TextSize = 10.5,
			TextTransparency = 0,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -16, 1, 0),
		}, field)
		addControl(controls, field)

		local api = attachOptions({
			Root = row,
			Field = field,
			Box = box,
			Default = inputConfig.Default,
			Name = inputConfig.Name,
			Value = inputConfig.Default or "",
		})

		function api:GetValue()
			return box.Text
		end

		function api:SetValue(value, silent)
			box.Text = tostring(value or "")
			api.Value = box.Text
			if not silent and inputConfig.Callback then
				inputConfig.Callback(api.Value)
			end
		end

		U.connect(box.FocusLost, function(enterPressed)
			api.Value = box.Text
			if inputConfig.Callback then
				inputConfig.Callback(box.Text)
			end
			U.tween(field, TWEEN.Fast, { BackgroundColor3 = Theme.Field })
		end)
		U.connect(box.Focused, function()
			U.tween(field, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
		end)

		if inputConfig.Flag then
			Nerx.Flags[inputConfig.Flag] = api
		end
		page:RegisterComponent(api)
		return api
	end

	function section:AddAction(actionConfig)
		actionConfig = actionConfig or {}
		local row, controls = addRow(section, actionConfig, { Reserve = 100 })
		local button = smallButton(controls, actionConfig.Button or "Action", actionConfig.Callback, actionConfig.Disabled)
		addControl(controls, button.Root)

		local api = {
			Root = row,
			Button = button,
			Name = actionConfig.Name,
		}
		return api
	end

	function section:AddButton(buttonConfig)
		buttonConfig = buttonConfig or {}
		local row, _, label = addRow(section, buttonConfig, {
			Height = buttonConfig.Height or 34,
			NoControls = true,
			Reserve = 0,
		})
		if label then
			label.TextTransparency = 0.2
			label.Position = UDim2.fromOffset(buttonConfig.Icon and (section.Inset or 12) + 23 or (section.Inset or 12), 0)
			label.Size = UDim2.new(1, -((section.Inset or 12) * 2 + 33), 1, 0)
		end
		if buttonConfig.Icon then
			U.icon(row, buttonConfig.Icon, 14, Theme.Icon, {
				Position = UDim2.fromOffset(section.Inset or 12, 0),
				Size = UDim2.fromOffset(16, buttonConfig.Height or 34),
				TextTransparency = 0.3,
			})
		end
		U.inputButton(row, function()
			if buttonConfig.Callback then
				buttonConfig.Callback()
			end
		end)
		return { Root = row }
	end

	function section:AddLabel(text, height)
		local row = addRow(section, { Name = "" }, {
			Height = height or 30,
			NoControls = true,
			NoLabel = true,
		})
		local label = U.label(row, {
			Text = text or "",
			TextSize = 11,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.25,
			Position = UDim2.fromOffset(section.Inset or 12, 0),
			Size = UDim2.new(1, -(section.Inset or 12) * 2, 1, 0),
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Center,
		})
		return { Root = row, Label = label }
	end

	function section:AddDescription(text)
		local row = addRow(section, { Name = "" }, {
			Height = 42,
			NoControls = true,
			NoLabel = true,
		})
		local label = U.label(row, {
			Text = text or "",
			TextSize = 10.5,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.25,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			Position = UDim2.fromOffset(section.Inset or 12, 6),
			Size = UDim2.new(1, -(section.Inset or 12) * 2, 0, 30),
		})
		return { Root = row, Label = label }
	end

	function section:AddInfo(infoConfig)
		infoConfig = infoConfig or {}
		local inset = section.Inset or 12
		local row, controls = addRow(section, infoConfig, {
			NoControls = true,
			Reserve = 100,
		})
		local labelOffset = inset
		if infoConfig.Icon then
			U.icon(row, infoConfig.Icon, 13, Theme.Muted, {
				Position = UDim2.fromOffset(inset, 0),
				Size = UDim2.fromOffset(16, 34),
				TextTransparency = 0.35,
			})
			labelOffset = inset + 22
		end
		local valueLabel = U.label(row, {
			Text = tostring(infoConfig.Value or ""),
			TextSize = 10.5,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.35,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -inset, 0.5, 0),
			Size = UDim2.fromOffset(0, 18),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		local api = { Root = row, ValueLabel = valueLabel, Label = row:FindFirstChildWhichIsA("TextLabel") }
		if infoConfig.Icon and api.Label then
			api.Label.Position = UDim2.fromOffset(labelOffset, 0)
			api.Label.Size = UDim2.new(1, -(labelOffset + 100), 1, 0)
		end
		function api:SetValue(value)
			valueLabel.Text = tostring(value)
		end
		return api
	end

	function section:AddCustomRow(height, builder)
		local row = addRow(section, { Name = "" }, {
			Height = height or 34,
			NoControls = true,
			NoLabel = true,
		})
		if builder then
			builder(row)
		end
		return row
	end

	function section:AddChips(chipsConfig)
		chipsConfig = chipsConfig or {}
		local items = chipsConfig.Items or {}
		local multi = chipsConfig.Multi ~= false
		local paletteColors = chipsConfig.Palette or U.ChipPalette

		local row = addRow(section, { Name = chipsConfig.Name or "" }, {
			Height = 40,
			NoControls = true,
			NoLabel = true,
		})
		local holder = U.frame(row, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(section.Inset or 12, 10),
			Size = UDim2.new(1, -(section.Inset or 12) * 2, 0, 0),
		})
		local flow = U.flow(holder, 6, 6)
		flow.OnLayout = function(height)
			local targetHeight = height + 20
			if math.abs(row.Size.Y.Offset - targetHeight) > 0.5 then
				row.Size = UDim2.new(1, 0, 0, targetHeight)
			end
		end

		local api = { Root = row, Items = {}, Flow = flow }
		local selectedSet = {}
		if chipsConfig.Selected then
			for _, name in ipairs(chipsConfig.Selected) do
				selectedSet[name] = true
			end
		end

		local chips = {}
		api.Chips = chips

		local function refresh()
			for _, chip in ipairs(chips) do
				chip:SetSelected(chip.Item.Selected == true, true)
			end
		end

		function api:SetSelected(name, value, silent)
			for _, chip in ipairs(chips) do
				if chip.Item.Name == name then
					chip:SetSelected(value, silent)
					break
				end
			end
		end

		function api:GetSelected()
			local result = {}
			for _, chip in ipairs(chips) do
				if chip.Selected then
					table.insert(result, chip.Item.Name)
				end
			end
			return result
		end

		for _, rawItem in ipairs(items) do
			local normalized = normalizeChip(rawItem)
			local initialSelected = normalized.Selected == true or selectedSet[normalized.Name] == true
			normalized.Selected = initialSelected
			if normalized.Color == nil then
				normalized.Color = Theme.Accent
			end

			local chip = createChip(holder, normalized, {
				Radio = false,
				DotSide = chipsConfig.DotSide or "left",
				OnColor = function(changed)
					if chipsConfig.ColorCallback then
						chipsConfig.ColorCallback(changed.Item.Name, changed.Color)
					end
				end,
				OnSelect = function(changed)
					if not multi then
						for _, other in ipairs(chips) do
							if other ~= changed then
								other.Item.Selected = false
								other:SetSelected(false, true)
							end
						end
					end
					refresh()
					if chipsConfig.Callback then
						chipsConfig.Callback(changed.Item.Name, changed.Selected, changed.Color)
					end
				end,
			})
			-- Normalise defaults so chips created with missing colours still cycle correctly.
			if chip.Color == nil then
				chip:SetColor(paletteColors[1])
			end
			table.insert(chips, chip)
			flow:Add(chip.Root, chip.Width, chip.Height)
		end

		return api
	end

	function section:AddHeaderAction(action)
		local textWidth = U.measure(action.Name or "", 9, Fonts.Regular).X
		local extra = action.Dot and 10 or 0
		local root = U.frame(section.Actions, {
			BackgroundColor3 = Theme.Field,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset((action.Icon and 26 or 16) + textWidth + extra, 18),
		})
		U.corner(root, 9)
		if action.Icon then
			U.icon(root, action.Icon, 9, Theme.Muted, {
				Position = UDim2.fromOffset(7, 0),
				Size = UDim2.fromOffset(10, 18),
				TextTransparency = 0.35,
			})
		end
		U.label(root, {
			Text = action.Name or "",
			TextSize = 9,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.35,
			Position = UDim2.fromOffset(action.Icon and 18 or 8, 0),
			Size = UDim2.fromOffset(textWidth + 2, 18),
		})
		if action.Dot then
			local dot = U.frame(root, {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = action.Dot == true and Theme.Green or action.Dot,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -7, 0.5, 0),
				Size = UDim2.fromOffset(4, 4),
			})
			U.corner(dot, 2)
		end
		if action.Callback then
			U.inputButton(root, action.Callback)
		end
		return root
	end

	function section:ApplyFilter(query)
		local lower = string.lower(query or "")
		local sectionMatch = lower ~= "" and string.find(string.lower(section.Name), lower, 1, true) ~= nil
		local anyVisible = false

		for _, rowInfo in ipairs(section.Rows) do
			local rowMatch = lower == "" or (rowInfo.Name ~= "" and string.find(string.lower(rowInfo.Name), lower, 1, true) ~= nil)
			if sectionMatch and rowInfo.Name ~= "" then
				rowMatch = true
			end
			rowInfo.Root.Visible = rowMatch
			if rowMatch and rowInfo.Name ~= "" then
				anyVisible = true
			end
		end

		section.Root.Visible = lower == "" or sectionMatch or anyVisible
	end

	page.Sections[#page.Sections + 1] = section
	return section
end


-- ---------------------------------------------------------------------------------------
-- Page
-- ---------------------------------------------------------------------------------------

local function richEscape(text)
	text = tostring(text or "")
	text = text:gsub("&", "&amp;")
	text = text:gsub("<", "&lt;")
	text = text:gsub(">", "&gt;")
	return text
end

local function createPage(window, host, tab, config)
	config = config or {}
	local page = {
		Window = window,
		Tab = tab,
		Name = config.Name or "Page",
		Title = config.Title or tab.Name,
		Subtitle = config.Subtitle,
		Sections = {},
		Components = {},
		BlockIndex = 0,
		HasRight = false,
		HasChips = false,
		RightWidth = config.RightWidth or 330,
		SectionStyle = config.SectionStyle or "card",
		Custom = false,
		Filter = "",
	}

	local root = U.frame(host, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
	})
	page.Root = root

	local title = U.label(root, {
		Text = page.Title,
		Font = Fonts.Bold,
		TextSize = 15,
		TextColor3 = Theme.Text,
		TextTransparency = 0.05,
		Position = UDim2.fromOffset(20, 18),
		Size = UDim2.fromOffset(0, 24),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	page.TitleLabel = title

	local subtitle = U.label(root, {
		Text = page.Subtitle or "",
		TextSize = 11,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.35,
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.fromOffset(0, 20),
		Visible = page.Subtitle ~= nil and page.Subtitle ~= "",
	})
	page.SubtitleLabel = subtitle

	local headerControls = U.frame(root, {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -20, 0, 18),
		Size = UDim2.fromOffset(0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
	})
	U.list(headerControls, 12, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	page.HeaderControls = headerControls

	local chipBar = U.frame(root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(20, 52),
		Size = UDim2.new(1, -40, 0, 26),
		Visible = false,
	})
	page.ChipBar = chipBar
	local chipHolder = U.frame(chipBar, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
	page.ChipFlow = U.flow(chipHolder, 6, 6)

	local leftScroll = U.new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(20, 56),
		Size = UDim2.new(1, -40, 1, -74),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Stroke,
		ScrollBarImageTransparency = 0.35,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
	}, root)
	page.LeftScroll = leftScroll
	U.list(leftScroll, 14, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)

	local rightHost = U.frame(root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -350, 0, 56),
		Size = UDim2.fromOffset(330, 1),
		Visible = false,
	})
	page.RightHost = rightHost

	local rightScroll = U.new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Stroke,
		ScrollBarImageTransparency = 0.35,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
	}, rightHost)
	page.RightScroll = rightScroll
	U.list(rightScroll, 14, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

	local previewHost = U.frame(rightHost, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
	})
	page.PreviewHost = previewHost

	local divider = U.frame(root, {
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -362, 0, 56),
		Size = UDim2.fromOffset(1, 1),
		Visible = false,
	})
	page.Divider = divider

	local hint = U.label(root, {
		Text = "",
		TextSize = 10,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.45,
		Position = UDim2.new(0, 20, 1, -30),
		Size = UDim2.new(1, -40, 0, 14),
		Visible = false,
	})
	page.HintLabel = hint

	function page:RegisterComponent(component)
		self.Components[#self.Components + 1] = component
		return component
	end

	function page:SetTitle(text)
		self.Title = text
		title.Text = text
		local width = U.measure(text, 15, Fonts.Bold).X
		title.Size = UDim2.fromOffset(width + 2, 24)
		subtitle.Position = UDim2.fromOffset(20 + width + 10, 20)
	end

	function page:SetSectionStyle(style)
		self.SectionStyle = style == "flat" and "flat" or "card"
	end

	function page:SetCustomMode()
		self.Custom = true
		title.Visible = false
		subtitle.Visible = false
		headerControls.Visible = false
		chipBar.Visible = false
		leftScroll.Visible = false
		rightHost.Visible = false
		divider.Visible = false
		hint.Visible = false
		self.HasRight = false
		self.HasChips = false

		local canvas = U.frame(root, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(20, 18),
			Size = UDim2.new(1, -40, 1, -36),
		})
		self.Canvas = canvas
		return canvas
	end

	function page:SetLeftWidth(width)
		self.LeftWidth = width
		self:Relayout()
	end

	function page:SetSubtitle(text)
		self.Subtitle = text
		subtitle.Text = text or ""
		subtitle.Visible = text ~= nil and text ~= ""
	end

	function page:SetHint(text)
		hint.Text = text or ""
		hint.Visible = text ~= nil and text ~= ""
		self:Relayout()
	end

	function page:UseRight()
		self.HasRight = true
		rightHost.Visible = true
		divider.Visible = true
		self:Relayout()
	end

	function page:ShowRightSections()
		self:UseRight()
		rightScroll.Visible = true
		previewHost.Visible = false
	end

	function page:Relayout()
		if self.Custom then
			return
		end
		local top = 18 + 24 + (self.HasChips and 36 or 0) + 14
		local bottom = 32 + (hint.Visible and 16 or 0)
		local rightWidth = self.RightWidth

		if self.HasRight then
			leftScroll.Position = UDim2.fromOffset(20, top)
			leftScroll.Size = UDim2.new(1, -(40 + 24 + rightWidth), 1, -(top + bottom))

			rightHost.Position = UDim2.new(1, -(20 + rightWidth), 0, top)
			rightHost.Size = UDim2.new(0, rightWidth, 1, -(top + bottom))
			rightHost.Visible = true

			divider.Position = UDim2.new(1, -(20 + rightWidth + 12), 0, 0)
			divider.Size = UDim2.new(0, 1, 1, 0)
			divider.Visible = true
		else
			leftScroll.Position = UDim2.fromOffset(20, top)
			if self.LeftWidth then
				leftScroll.Size = UDim2.new(0, self.LeftWidth, 1, -(top + bottom))
			else
				leftScroll.Size = UDim2.new(1, -40, 1, -(top + bottom))
			end
			rightHost.Visible = false
			divider.Visible = false
		end

		hint.Position = UDim2.new(0, 20, 1, -44)
	end

	function page:SetRightWidth(width)
		self.RightWidth = width
		self:Relayout()
	end

	function page:AddSelector(selectorConfig)
		selectorConfig = selectorConfig or {}
		local items = selectorConfig.Items or {}
		local api = { Root = chipBar, Chips = {}, Value = nil }
		local chips = api.Chips
		local selected = selectorConfig.Selected or selectorConfig.Default

		local function valueOf(item)
			return item.Value or item.Name or item.Icon
		end

		local function renderOthers(except)
			for _, chip in ipairs(chips) do
				if chip ~= except then
					chip.Item.Selected = false
					chip:SetSelected(false, true)
				end
			end
		end

		for index, rawItem in ipairs(items) do
			local item = normalizeChip(rawItem)
			item.Selected = (index == 1 and selected == nil and selectorConfig.SelectFirst ~= false) or item.Selected == true or (selected ~= nil and valueOf(item) == selected)
			local chip = createChip(chipHolder, item, {
				Height = 26,
				TextSize = 11.5,
				Radio = true,
				DotSide = "right",
				OnSelect = function(selectedChip)
					if api.Value == valueOf(selectedChip.Item) then
						return
					end
					renderOthers(selectedChip)
					selectedChip.Item.Selected = true
					selectedChip:SetSelected(true, true)
					api.Value = valueOf(selectedChip.Item)
					if selectorConfig.Callback then
						selectorConfig.Callback(api.Value, selectedChip.Item)
					end
				end,
			})
			if item.Selected then
				api.Value = valueOf(item)
			end
			chip:SetSelected(item.Selected == true, true)
			table.insert(chips, chip)
			self.ChipFlow:Add(chip.Root, chip.Width, chip.Height)
		end

		function api:SetValue(value, silent)
			for _, chip in ipairs(chips) do
				local isMatch = valueOf(chip.Item) == value
				chip.Item.Selected = match
				chip:SetSelected(isMatch, true)
				if isMatch then
					self.Value = value
				end
			end
			if not silent and selectorConfig.Callback then
				selectorConfig.Callback(value)
			end
		end

		function api:GetValue()
			return api.Value
		end

		self.Selector = api
		self.HasChips = true
		chipBar.Visible = true
		self:Relayout()
		return api
	end

	function page:SetHeaderSwitch(switchConfig)
		local textWidth = U.measure(switchConfig.Text or "", 11, Fonts.Regular).X
		local root = U.frame(headerControls, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(textWidth + 38, 22),
		})
		root.LayoutOrder = 1

		local label = U.label(root, {
			Text = switchConfig.Text or "",
			TextSize = 11,
			TextColor3 = Theme.Text,
			TextTransparency = 0.2,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(textWidth + 2, 22),
		})
		local toggle = toggleWidget(root, switchConfig.Default, function(value)
			if switchConfig.Callback then
				switchConfig.Callback(value)
			end
		end)
		toggle.Root.AnchorPoint = Vector2.new(1, 0.5)
		toggle.Root.Position = UDim2.new(1, 0, 0.5, 0)

		local api = {
			Root = root,
			Label = label,
			Toggle = toggle,
		}
		function api:GetValue()
			return toggle:GetValue()
		end
		function api:SetValue(value, silent)
			toggle:SetValue(value, silent)
		end
		self.HeaderSwitch = api
		return api
	end

	function page:SetHeaderIcon(icon, callback)
		local root = U.frame(headerControls, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(22, 22),
		})
		root.LayoutOrder = 2
		local iconLabel = U.icon(root, icon or "gear", 15, Theme.Muted, {
			TextTransparency = 0.45,
			Size = UDim2.fromScale(1, 1),
		})
		local input = U.inputButton(root, callback or function() end)
		U.connect(input.MouseEnter, function()
			U.tween(iconLabel, TWEEN.Fast, { TextTransparency = 0.05 })
		end)
		U.connect(input.MouseLeave, function()
			U.tween(iconLabel, TWEEN.Fast, { TextTransparency = 0.45 })
		end)
		self.HeaderIcon = root
		return root
	end

	function page:AddSection(sectionConfig)
		return createSection(self, sectionConfig)
	end

	function page:AddBlock(blockConfig)
		blockConfig = blockConfig or {}
		local width = blockConfig.Width
		local height = blockConfig.Height or 240
		local root = U.frame(self.LeftScroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = width and UDim2.fromOffset(width, height + 18) or UDim2.new(1, 0, 0, height + 18),
		})
		root.LayoutOrder = self.BlockIndex + 1000
		self.BlockIndex = self.BlockIndex + 1

		local label = U.label(root, {
			Text = string.upper(blockConfig.Name or "VIEW"),
			Font = Fonts.Bold,
			TextSize = 9.5,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.5,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 15),
		})

		local card = U.frame(root, {
			BackgroundColor3 = Theme.Surface,
			BackgroundTransparency = 0.01,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 18),
			Size = UDim2.new(1, 0, 0, height),
			ClipsDescendants = true,
		})
		U.corner(card, 8)
		U.stroke(card, Theme.Stroke, 0.55, 1)

		local content = U.frame(card, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(blockConfig.Padding or 0, blockConfig.Padding or 0),
			Size = UDim2.new(1, -(blockConfig.Padding or 0) * 2, 1, -(blockConfig.Padding or 0) * 2),
		})
		return content, card, root, label
	end

	function page:AddPreview(previewConfig)
		self:UseRight()
		rightScroll.Visible = false
		previewHost.Visible = true
		local preview = U.preview(self, previewConfig or {})
		self.Preview = preview
		return preview
	end

	function page:ApplyFilter(query)
		self.Filter = query or ""
		for _, section in ipairs(self.Sections) do
			section:ApplyFilter(self.Filter)
		end
	end

	function page:SetActive(value)
		root.Visible = value == true
		if value then
			self:Relayout()
		end
	end

	page:SetTitle(page.Title)
	if page.Subtitle then
		page:SetSubtitle(page.Subtitle)
	end
	return page
end

-- ---------------------------------------------------------------------------------------
-- Window
-- ---------------------------------------------------------------------------------------

function Nerx:CreateWindow(config)
	config = config or {}
	local size = config.Size or UDim2.fromOffset(1024, 700)
	local window = {
		Title = config.Title or "Nerx Beta",
		Subtitle = config.Subtitle or "Bloxstrike",
		Logo = config.Logo,
		Size = size,
		Tabs = {},
		Groups = {},
		SidebarOrder = 0,
		Visible = false,
		Mode = config.Mode or "legit",
		Modes = config.Modes or { "legit", "rage", "hw" },
		Keybind = config.Keybind ~= nil and config.Keybind or "Insert",
		KeybindCode = U.parseKey(config.Keybind == false and nil or (config.Keybind or "Insert")),
		SearchQuery = "",
		OnSave = config.OnSave,
		OnModeChange = config.OnModeChange,
	}
	window.Signal = nil
	local root = U.frame(screenGui, {
		Name = "NerxWindow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Window,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		Size = size,
		ClipsDescendants = false,
		Visible = true,
	})
	U.corner(root, 12)
	U.stroke(root, Theme.Stroke, 0.55, 1)
	U.shadow(root)
	window.Root = root
	window.Content = root

	local uiScale = U.new("UIScale", {
		Scale = 1,
	}, root)
	window.UIScale = uiScale

	local function updateScale()
		local viewport = U.viewport()
		local raw = math.min(1, (viewport.X - 16) / size.X.Offset, (viewport.Y - 16) / size.Y.Offset)
		uiScale.Scale = math.max(0.55, raw)
		Nerx.Scale = uiScale.Scale
	end
	updateScale()
	local camera = workspace.CurrentCamera
	if camera then
		U.connect(camera:GetPropertyChangedSignal("ViewportSize"), updateScale)
	end

	local sidebar = U.frame(root, {
		Name = "Sidebar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 200, 1, 0),
	})
	window.Sidebar = sidebar

	local sidebarDivider = U.frame(root, {
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(200, 0),
		Size = UDim2.new(0, 1, 1, 0),
		ZIndex = 2,
	})

	local brand = U.frame(sidebar, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 62),
		Active = true,
	})
	window.Brand = brand

	local logoBox = U.frame(brand, {
		BackgroundColor3 = Theme.SurfaceRaised,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 14),
		Size = UDim2.fromOffset(34, 34),
	})
	U.corner(logoBox, 8)
	U.stroke(logoBox, Theme.Stroke, 0.4, 1)

	if config.Logo then
		local image = U.new("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = config.Logo,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
		}, logoBox)
		U.corner(image, 8)
	else
		-- Abstract white N mark, matching the reference brand tile.
		local leftBar = U.frame(logoBox, {
			BackgroundColor3 = Theme.Text,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, 7),
			Size = UDim2.fromOffset(3, 20),
		})
		U.corner(leftBar, 1)
		local rightBar = U.frame(logoBox, {
			BackgroundColor3 = Theme.Text,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(21, 7),
			Size = UDim2.fromOffset(3, 20),
		})
		U.corner(rightBar, 1)
		local slash = U.frame(logoBox, {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Theme.Text,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(17, 6),
			Rotation = 22,
			Size = UDim2.fromOffset(3, 23),
		})
		U.corner(slash, 1)
		U.frame(logoBox, {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -6, 1, -6),
			Size = UDim2.fromOffset(5, 5),
		})
		local logoDot = logoBox:FindFirstChildWhichIsA("Frame")
		for _, child in ipairs(logoBox:GetChildren()) do
			if child:IsA("Frame") and child.Size.X.Offset == 5 and child.Size.Y.Offset == 5 then
				logoDot = child
			end
		end
		U.corner(logoDot, 3)
		U.onAccent(function(color)
			logoDot.BackgroundColor3 = color
		end)
	end

	local brandTitle = U.label(brand, {
		Text = window.Title,
		Font = Fonts.Bold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		Position = UDim2.fromOffset(58, 13),
		Size = UDim2.fromOffset(130, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local brandSub = U.label(brand, {
		Text = window.Subtitle,
		Font = Fonts.Regular,
		TextSize = 8.5,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.45,
		Position = UDim2.fromOffset(58, 31),
		Size = UDim2.fromOffset(130, 13),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	window.BrandTitle = brandTitle
	window.BrandSub = brandSub

	local sidebarScroll = U.new("ScrollingFrame", {
		Name = "Navigation",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 62),
		Size = UDim2.new(1, -20, 1, -62 - 66),
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
	}, sidebar)
	U.list(sidebarScroll, 4, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
	window.SidebarScroll = sidebarScroll

	local account = U.frame(sidebar, {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 66),
		Active = true,
	})
	window.Account = account

	U.frame(account, {
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -28, 0, 1),
	})

	local avatar = U.frame(account, {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.fromOffset(32, 32),
		ClipsDescendants = true,
	})
	U.corner(avatar, 16)
	local avatarIcon = U.icon(avatar, "person", 15, Theme.Muted, {
		TextTransparency = 0.35,
		Size = UDim2.fromScale(1, 1),
	})
	local avatarImage = U.new("ImageLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "",
		ScaleType = Enum.ScaleType.Crop,
		Size = UDim2.fromScale(1, 1),
	}, avatar)
	U.corner(avatarImage, 16)

	window.AccountName = U.label(account, {
		Text = config.AccountName or LocalPlayer.DisplayName or LocalPlayer.Name,
		TextSize = 11.5,
		TextColor3 = Theme.Text,
		Position = UDim2.fromOffset(54, 14),
		Size = UDim2.fromOffset(110, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	window.AccountTag = U.label(account, {
		Text = config.AccountTag or "Attached",
		TextSize = 9.5,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.45,
		Position = UDim2.fromOffset(54, 32),
		Size = UDim2.fromOffset(110, 14),
	})
	local accountChevron = U.icon(account, "chevron-large-up", 13, Theme.Muted, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		TextTransparency = 0.45,
	})
	window.AccountChevron = accountChevron

	task.spawn(function()
		local ok, image = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		if ok and image then
			avatarImage.Image = image
			avatarIcon.Visible = false
		end
	end)

	local accountInputMenu = U.inputButton(account, function()
		window:OpenQuickMenu(account)
	end)
	local main = U.frame(root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(200, 0),
		Size = UDim2.new(1, -200, 1, 0),
		ClipsDescendants = true,
	})
	window.Main = main

	local topBar = U.frame(main, {
		Name = "TopBar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 52),
		ZIndex = 3,
	})
	window.TopBar = topBar

	U.frame(topBar, {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
	})

	local dragFrame = U.frame(topBar, {
		Name = "DragArea",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Active = true,
		ZIndex = 3,
	})
	U.drag(dragFrame, root, 0.14)
	U.drag(brand, root, 0.14)

	local breadcrumb = U.label(topBar, {
		Text = "",
		RichText = true,
		Font = Fonts.Regular,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -410, 1, 0),
		ZIndex = 4,
	})
	window.Breadcrumb = breadcrumb

	local modeChip = U.frame(topBar, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -318, 0.5, 0),
		Size = UDim2.fromOffset(84, 28),
		ZIndex = 4,
	})
	U.corner(modeChip, 6)
	U.stroke(modeChip, Theme.Stroke, 0.6, 1)
	local modeDot = U.frame(modeChip, {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Amber,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(5, 5),
	})
	U.corner(modeDot, 3)
	local modeLabel = U.label(modeChip, {
		Text = window.Mode,
		TextSize = 11,
		TextColor3 = Theme.Text,
		TextTransparency = 0.15,
		Position = UDim2.fromOffset(21, 0),
		Size = UDim2.new(1, -40, 1, 0),
	})
	local modeChevron = U.icon(modeChip, "chevron-large-down", 10, Theme.Muted, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(11, 11),
		TextTransparency = 0.4,
	})
	window.ModeChip = modeChip
	window.ModeLabel = modeLabel
	window.ModeDot = modeDot

	local saveButton = U.frame(topBar, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.Primary,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -236, 0.5, 0),
		Size = UDim2.fromOffset(74, 30),
		ZIndex = 4,
	})
	U.corner(saveButton, 6)
	U.stroke(saveButton, Theme.PrimaryStroke, 0.35, 1)
	local saveLabel = U.label(saveButton, {
		Text = "Save",
		TextSize = 11.5,
		TextColor3 = Theme.Text,
		TextTransparency = 0.02,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	window.SaveButton = saveButton
	window.SaveLabel = saveLabel

	local search = U.frame(topBar, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -18, 0.5, 0),
		Size = UDim2.fromOffset(210, 30),
		ZIndex = 4,
	})
	U.corner(search, 8)
	local searchStroke = U.stroke(search, Theme.Stroke, 1, 1)
	local searchIcon = U.icon(search, "magnifying-glass", 13, Theme.Muted, {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.fromOffset(14, 30),
		TextTransparency = 0.3,
	})
	local searchBox = U.new("TextBox", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Fonts.Regular,
		Text = "",
		PlaceholderText = "Search features",
		PlaceholderColor3 = Theme.Faint,
		TextColor3 = Theme.Text,
		TextSize = 10.5,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(30, 0),
		Size = UDim2.new(1, -84, 1, 0),
		ZIndex = 5,
	}, search)
	window.SearchBox = searchBox
	window.Search = search

	local keyHints = U.frame(search, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.fromOffset(47, 18),
	})
	U.list(keyHints, 3, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	local ctrlHint = U.label(keyHints, {
		Text = "Ctrl",
		Font = Fonts.Regular,
		TextSize = 8,
		TextColor3 = Theme.Faint,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(26, 18),
	})
	U.corner(ctrlHint, 4)
	U.stroke(ctrlHint, Theme.Stroke, 0.4, 1)
	local fHint = U.label(keyHints, {
		Text = "F",
		Font = Fonts.Regular,
		TextSize = 8,
		TextColor3 = Theme.Faint,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(18, 18),
	})
	U.corner(fHint, 4)
	U.stroke(fHint, Theme.Stroke, 0.4, 1)

	local pageHost = U.frame(main, {
		Name = "Pages",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(1, 0, 1, -52),
		ClipsDescendants = true,
	})
	window.PageHost = pageHost

	U.connect(search.MouseEnter, function()
		if not searchBox:IsFocused() then
			U.tween(search, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
			searchIcon.TextTransparency = 0.1
		end
	end)
	U.connect(search.MouseLeave, function()
		if not searchBox:IsFocused() then
			U.tween(search, TWEEN.Fast, { BackgroundColor3 = Theme.Field })
			searchIcon.TextTransparency = 0.3
		end
	end)
	U.connect(searchBox.Focused, function()
		U.tween(search, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
		searchStroke.Transparency = 0.5
		searchIcon.TextTransparency = 0.05
	end)
	U.connect(searchBox.FocusLost, function(enterPressed)
		U.tween(search, TWEEN.Fast, { BackgroundColor3 = Theme.Field })
		searchStroke.Transparency = 1
		searchIcon.TextTransparency = 0.3
	end)
	U.connect(searchBox:GetPropertyChangedSignal("Text"), function()
		window:SetSearch(searchBox.Text)
	end)

	local saveInput = U.inputButton(saveButton, function()
		window:Save()
	end)
	U.connect(saveInput.MouseEnter, function()
		U.tween(saveButton, TWEEN.Fast, { BackgroundColor3 = Theme.PrimaryHover })
	end)
	U.connect(saveInput.MouseLeave, function()
		U.tween(saveButton, TWEEN.Fast, { BackgroundColor3 = Theme.Primary })
	end)

	local modeInput = U.inputButton(modeChip, function()
		openDropdown(modeChip, window.Modes, function(selected)
			window:SetMode(selected)
		end)
	end)
	U.connect(modeInput.MouseEnter, function()
		U.tween(modeChip, TWEEN.Fast, { BackgroundTransparency = 0 })
	end)
	U.connect(modeInput.MouseLeave, function()
		U.tween(modeChip, TWEEN.Fast, { BackgroundTransparency = 0.05 })
	end)

	-- ---------------------------------------------------------------------------------
	-- Window API
	-- ---------------------------------------------------------------------------------

	function window:RenderTab(tab)
		local selected = self.SelectedTab == tab
		if selected then
			U.tween(tab.Button, TWEEN.Default, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Selected })
			tab.Stroke.Transparency = 0.85
			U.tween(tab.Icon, TWEEN.Default, { TextColor3 = Theme.Text, TextTransparency = 0.05 })
			U.tween(tab.Label, TWEEN.Default, { TextColor3 = Theme.Text, TextTransparency = 0.05 })
		else
			U.tween(tab.Button, TWEEN.Default, { BackgroundTransparency = 1 })
			tab.Stroke.Transparency = 1
			U.tween(tab.Icon, TWEEN.Default, { TextColor3 = Theme.Muted, TextTransparency = 0.4 })
			U.tween(tab.Label, TWEEN.Default, { TextColor3 = Theme.Muted, TextTransparency = 0.45 })
		end
		tab.SubContainer.Visible = selected and tab.HasSubtabs
	end

	function window:RenderSubTabs(tab)
		for _, sub in ipairs(tab.SubTabs) do
			local selected = tab.CurrentPage == sub.Page
			U.tween(sub.Label, TWEEN.Default, {
				TextColor3 = selected and Theme.Text or Theme.Muted,
				TextTransparency = selected and 0.05 or 0.5,
			})
			sub.Tick.Visible = selected
		end
	end

	function window:SelectTab(tab)
		if not tab then
			return
		end
		self.SelectedTab = tab
		for _, other in ipairs(self.Tabs) do
			self:RenderTab(other)
			for _, otherPage in ipairs(other.Pages) do
				otherPage:SetActive(false)
			end
		end

		local page
		if tab.HasSubtabs then
			page = tab.CurrentPage
			if not page or page == tab.DefaultPage then
				page = tab.SubTabs[1] and tab.SubTabs[1].Page or tab.DefaultPage
			end
		else
			page = tab.DefaultPage
		end
		tab:SetPage(page)
		self:RenderSearch()
		self:UpdateBreadcrumb()
	end

	function window:SelectTabByName(name)
		local lower = string.lower(name or "")
		for _, tab in ipairs(self.Tabs) do
			if string.lower(tab.Name) == lower then
				self:SelectTab(tab)
				return tab
			end
		end
		return nil
	end

	function window:GetTabByName(name)
		local lower = string.lower(name or "")
		for _, tab in ipairs(self.Tabs) do
			if string.lower(tab.Name) == lower then
				return tab
			end
		end
		return nil
	end

	function window:UpdateBreadcrumb()
		local tab = self.SelectedTab
		if not tab then
			breadcrumb.Text = ""
			return
		end
		local page = self.CurrentPage
		if page and page ~= tab.DefaultPage then
			breadcrumb.Text = '<font color="#7E7E88">' .. richEscape(tab.Name) .. '</font>   <font color="#4A4A54">›</font>   <font color="#DCDCE2">' .. richEscape(page.Name) .. "</font>"
		else
			breadcrumb.Text = '<font color="#DCDCE2">' .. richEscape(page and page.Name or tab.Name) .. "</font>"
		end
	end

	function window:SetSearch(text)
		self.SearchQuery = text or ""
		self:RenderSearch()
	end

	function window:RenderSearch()
		local page = self.CurrentPage
		if page then
			page:ApplyFilter(self.SearchQuery)
		end
	end

	function window:SetMode(mode, silent)
		self.Mode = mode
		modeLabel.Text = tostring(mode)
		if string.lower(tostring(mode)) == "rage" then
			modeDot.BackgroundColor3 = Theme.Red
		elseif string.lower(tostring(mode)) == "hw" then
			modeDot.BackgroundColor3 = Theme.Cyan
		else
			modeDot.BackgroundColor3 = Theme.Amber
		end
		if not silent and self.OnModeChange then
			self.OnModeChange(mode)
		end
	end

	function window:GetMode()
		return self.Mode
	end

	function window:Save()
		if self.OnSave then
			pcall(self.OnSave)
		end
		saveLabel.Text = "Saved"
		U.tween(saveLabel, TWEEN.Fast, { TextTransparency = 0 })
		task.delay(1.2, function()
			if saveLabel and saveLabel.Parent then
				saveLabel.Text = "Save"
			end
		end)
		Nerx:Notify({
			Title = "Configuration",
			Content = "Saved successfully",
			Icon = "circle-check",
			Color = Theme.Green,
		})
	end

	function window:SetAccount(accountConfig)
		accountConfig = accountConfig or {}
		if accountConfig.Name then
			window.AccountName.Text = accountConfig.Name
		end
		if accountConfig.Tag then
			window.AccountTag.Text = accountConfig.Tag
		end
	end

	function window:UpdateBrand(titleText, subtitleText)
		if titleText then
			window.Title = titleText
			brandTitle.Text = titleText
		end
		if subtitleText then
			window.Subtitle = subtitleText
			brandSub.Text = subtitleText
		end
	end

	function window:Toggle(show)
		local target
		if show == nil then
			target = not self.Visible
		else
			target = show == true
		end

		if target then
			Nerx:ClosePopup()
			self.Visible = true
			root.Visible = true
			root.GroupTransparency = 1
			U.tween(root, TWEEN.Slow, { GroupTransparency = 0 })
		else
			self.Visible = false
			Nerx:ClosePopup()
			U.tween(root, TWEEN.Default, { GroupTransparency = 1 })
			task.delay(0.2, function()
				if not self.Visible then
					root.Visible = false
				end
			end)
		end
	end

	function window:Show()
		self:Toggle(true)
	end

	function window:Hide()
		self:Toggle(false)
	end

	function window:OpenQuickMenu(anchor)
		local items = {}
		for _, name in ipairs({ "Configs", "Binds", "Themes" }) do
			if self:FindTab(name) then
				table.insert(items, {
					Name = name,
					Callback = function()
						window:SelectTabByName(name)
					end,
				})
			end
		end
		table.insert(items, {
			Name = "Unload UI",
			Callback = function()
				Nerx:Unload()
			end,
		})
		if #items == 0 then
			table.insert(items, {
				Name = "Unload UI",
				Callback = function()
					Nerx:Unload()
				end,
			})
		end
		openMenu(anchor, items)
	end

	function window:FindTab(name)
		local lower = string.lower(name or "")
		for _, tab in ipairs(self.Tabs) do
			if string.lower(tab.Name) == lower then
				return tab
			end
		end
		return nil
	end

	function window:AddGroup(groupName)
		groupName = groupName or "FEATURES"
		self.SidebarOrder = self.SidebarOrder + 1
		local labelRow = U.frame(sidebarScroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 22),
		})
		labelRow.LayoutOrder = self.SidebarOrder

		local label = U.label(labelRow, {
			Text = string.upper(groupName),
			Font = Fonts.Bold,
			TextSize = 9,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.55,
			Position = UDim2.fromOffset(4, 0),
			Size = UDim2.fromOffset(0, 22),
		})
		local labelWidth = U.measure(string.upper(groupName), 9, Fonts.Bold).X
		label.Size = UDim2.fromOffset(labelWidth + 2, 22)
		U.frame(labelRow, {
			BackgroundColor3 = Theme.Divider,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(labelWidth + 10, 0),
			Size = UDim2.new(1, -(labelWidth + 14), 0, 1),
			AnchorPoint = Vector2.new(0, 0.5),
		})
		local line = labelRow:FindFirstChildWhichIsA("Frame")
		line.Position = UDim2.new(0, labelWidth + 10, 0.5, 0)

		local group = {
			Name = groupName,
			Tabs = {},
			Window = self,
		}
		function group:AddTab(tabConfig)
			return self.Window:_CreateTab(self, tabConfig)
		end
		self.Groups[#self.Groups + 1] = group
		self.CurrentGroup = group
		return group
	end

	function window:AddTab(tabConfig)
		if not self.CurrentGroup then
			self:AddGroup("FEATURES")
		end
		return self:_CreateTab(self.CurrentGroup, tabConfig)
	end

	function window:_CreateTab(group, tabConfig)
		tabConfig = tabConfig or {}
		local tab = {
			Name = tabConfig.Name or "Tab",
			Icon = tabConfig.Icon or "circle-i",
			Window = self,
			Group = group,
			SubTabs = {},
			Pages = {},
			HasSubtabs = false,
			CurrentPage = nil,
			}

		self.SidebarOrder = self.SidebarOrder + 1
		local order = self.SidebarOrder

		local button = U.frame(sidebarScroll, {
			BackgroundColor3 = Theme.Selected,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
		})
		button.LayoutOrder = order
		U.corner(button, 7)
		tab.Button = button

		local tabStroke = U.stroke(button, Theme.Stroke, 1, 1)
		tab.Stroke = tabStroke

		tab.Icon = U.icon(button, tab.Icon, 15, Theme.Muted, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.fromOffset(20, 20),
			TextTransparency = 0.4,
		})
		tab.Label = U.label(button, {
			Text = tab.Name,
			TextSize = 12,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.45,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 36, 0.5, 0),
			Size = UDim2.new(1, -46, 1, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local buttonInput = U.inputButton(button, function()
			self:SelectTab(tab)
		end)
		U.connect(buttonInput.MouseEnter, function()
			if self.SelectedTab ~= tab then
				U.tween(button, TWEEN.Fast, { BackgroundTransparency = 0.55 })
			end
		end)
		U.connect(buttonInput.MouseLeave, function()
			if self.SelectedTab ~= tab then
				U.tween(button, TWEEN.Fast, { BackgroundTransparency = 1 })
			end
		end)

		self.SidebarOrder = self.SidebarOrder + 1
		local subContainer = U.frame(sidebarScroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = false,
		})
		subContainer.LayoutOrder = self.SidebarOrder
		tab.SubContainer = subContainer

		local treeLine = U.frame(subContainer, {
			BackgroundColor3 = Theme.Divider,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(30, 4),
			Size = UDim2.new(0, 1, 0, 0),
		})
		tab.TreeLine = treeLine

		local defaultPage = createPage(self, pageHost, tab, {
			Name = tab.Name,
			Title = tab.Name,
		})
		tab.DefaultPage = defaultPage
		tab.Pages[1] = defaultPage
		tab.CurrentPage = defaultPage

		function tab:AddSubTab(subConfig)
			subConfig = subConfig or {}
			local index = #self.SubTabs + 1
			local sub = {
				Name = subConfig.Name or "Page",
				Icon = subConfig.Icon,
				Index = index,
			}

			local subButton = U.frame(subContainer, {
				BackgroundColor3 = Theme.White,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(40, (index - 1) * 25),
				Size = UDim2.new(1, -40, 0, 25),
			})
			U.corner(subButton, 5)
		local label = U.label(subButton, {
				Text = sub.Name,
				TextSize = 11.5,
				TextColor3 = Theme.Muted,
				TextTransparency = 0.5,
				Position = UDim2.fromOffset(8, 0),
				Size = UDim2.new(1, -14, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			local tick = U.frame(subButton, {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0,
				Position = UDim2.new(0, -10, 0.5, 0),
				Size = UDim2.fromOffset(2, 12),
				Visible = false,
			})
			U.corner(tick, 1)
			U.onAccent(function(color)
				tick.BackgroundColor3 = color
			end)

			local page = createPage(self.Window, pageHost, self, {
				Name = sub.Name,
				Title = subConfig.Title or self.Name,
				Subtitle = subConfig.Subtitle,
				RightWidth = subConfig.RightWidth,
			})
			sub.Name = sub.Name
			sub.Button = subButton
			sub.Label = label
			sub.Tick = tick
			sub.Page = page

			local input = U.inputButton(subButton, function()
				self:SetPage(page)
				self.Window:SelectTab(self)
			end)
			U.connect(input.MouseEnter, function()
				if self.CurrentPage ~= page then
					U.tween(subButton, TWEEN.Fast, { BackgroundTransparency = 0.97 })
				end
			end)
			U.connect(input.MouseLeave, function()
				U.tween(subButton, TWEEN.Fast, { BackgroundTransparency = 1 })
			end)

			self.SubTabs[index] = sub
			self.Pages[#self.Pages + 1] = page
			self.HasSubtabs = true
			self.DefaultPage:SetActive(false)
			subContainer.Visible = self.Window.SelectedTab == self
			subContainer.Size = UDim2.new(1, 0, 0, index * 25 + 4)
			treeLine.Size = UDim2.new(0, 1, 0, math.max(0, index * 25 - 8))

			if self.Window.SelectedTab == self and (self.CurrentPage == self.DefaultPage or self.CurrentPage == nil) then
				self:SetPage(page)
			else
				page:SetActive(false)
			end
			self.Window:RenderSubTabs(self)
			return page
		end

		function tab:SetPage(page)
			if not page then
				return
			end
			for _, other in ipairs(self.Pages) do
				if other ~= page then
					other:SetActive(false)
				end
			end
			page:SetActive(true)
			self.CurrentPage = page
			self.Window.CurrentPage = page
			self.Window:RenderSubTabs(self)
			self.Window:RenderSearch()
			self.Window:UpdateBreadcrumb()
			return page
		end

		function tab:AddSection(sectionConfig)
			return self:GetPage():AddSection(sectionConfig)
		end

		function tab:AddSelector(selectorConfig)
			return self:GetPage():AddSelector(selectorConfig)
		end

		function tab:AddPreview(previewConfig)
			return self:GetPage():AddPreview(previewConfig)
		end

		function tab:AddBlock(blockConfig)
			return self:GetPage():AddBlock(blockConfig)
		end

		function tab:SetHint(text)
			return self:GetPage():SetHint(text)
		end

		function tab:SetHeaderSwitch(switchConfig)
			return self:GetPage():SetHeaderSwitch(switchConfig)
		end

		function tab:SetHeaderIcon(icon, callback)
			return self:GetPage():SetHeaderIcon(icon, callback)
		end

		function tab:GetPage()
			if self.HasSubtabs and self.CurrentPage then
				return self.CurrentPage
			end
			return self.DefaultPage
		end

		group.Tabs[#group.Tabs + 1] = tab
		self.Tabs[#self.Tabs + 1] = tab
		self.CurrentGroup = group

		if not self.SelectedTab then
			self.SelectedTab = tab
			self:SelectTab(tab)
		else
			self:RenderTab(tab)
		end

		return tab
	end

	-- Account menu uses the same quick menu as the top-right gear.
	window:SetMode(window.Mode, true)
	window:UpdateBreadcrumb()

	-- Keybind visibility toggle.
	if window.KeybindCode then
		U.connect(UserInputService.InputBegan, function(input)
			if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode == window.KeybindCode then
				if not Nerx.CapturingKeybind then
					window:Toggle()
				end
			end
		end)
	end

	-- Ctrl+F focuses the feature search.
	U.connect(UserInputService.InputBegan, function(input)
		if input.KeyCode == Enum.KeyCode.F and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
			searchBox:CaptureFocus()
		end
		if input.KeyCode == Enum.KeyCode.Escape and searchBox:IsFocused() then
			searchBox.Text = ""
			window:SetSearch("")
			searchBox:ReleaseFocus()
		end
	end)
	U.connect(searchBox.FocusLost, function(enterPressed)
		if searchBox.Text == "" then
			window:SetSearch("")
		end
	end)

	U.connect(account.MouseEnter, function()
		U.tween(accountChevron, TWEEN.Fast, { TextTransparency = 0.05 })
	end)
	U.connect(account.MouseLeave, function()
		U.tween(accountChevron, TWEEN.Fast, { TextTransparency = 0.45 })
	end)

	root.GroupTransparency = config.StartHidden and 1 or 0
	root.Visible = not config.StartHidden
	window.Visible = not config.StartHidden

	if not config.StartHidden then
		root.GroupTransparency = 1
		U.tween(root, TWEEN.Slow, { GroupTransparency = 0 })
	end

	table.insert(Nerx.Windows, window)
	return window
end


-- ---------------------------------------------------------------------------------------
-- Preview stage (layout only; model / item content is intentionally left empty)
-- ---------------------------------------------------------------------------------------

function U.preview(page, config)
	config = config or {}
	local preview = {
		Page = page,
		ChipRows = {},
		Tags = {},
		Tool = 1,
		ActiveTool = 1,
	}

	local root = U.frame(page.PreviewHost, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.new(1, 0, 1, -14),
	})
	preview.Root = root

	U.label(root, {
		Text = "PREVIEW",
		Font = Fonts.Bold,
		TextSize = 10,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.45,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 15),
	})

	local card = U.frame(root, {
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.01,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 1, -18),
		ClipsDescendants = true,
	})
	U.corner(card, 8)
	U.stroke(card, Theme.Stroke, 0.55, 1)
	preview.Card = card

	-- Toolbar: three preview modes + reset layout.
	local toolbar = U.frame(card, {
		BackgroundColor3 = Theme.Window,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.fromOffset(78, 26),
	})
	U.corner(toolbar, 7)
	U.stroke(toolbar, Theme.Stroke, 0.5, 1)

	local toolButtons = {}
	local toolIcons = {}
	local tools = {
		{ Icon = "grid", Name = "Layout" },
		{ Icon = "chart-line", Name = "Telemetry" },
		{ Icon = "eye", Name = "Visibility" },
	}
	local selectedButton = nil
	local selectedIndex = 1

	local function renderTools()
		for index, button in ipairs(toolButtons) do
			local icon = toolIcons[index]
			if index == selectedIndex then
				button.BackgroundTransparency = 0
				icon.TextTransparency = 0.05
				icon.TextColor3 = Theme.Text
			else
				button.BackgroundTransparency = 1
				icon.TextTransparency = 0.4
				icon.TextColor3 = Theme.Muted
			end
		end
	end

	for index, tool in ipairs(tools) do
		local button = U.frame(toolbar, {
			BackgroundColor3 = Theme.SurfaceHover,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset((index - 1) * 26, 0),
			Size = UDim2.fromOffset(26, 26),
		})
		U.corner(button, 6)
		local icon = U.icon(button, tool.Icon, 13, Theme.Muted, {
			TextTransparency = 0.4,
			Size = UDim2.fromScale(1, 1),
		})
		toolIcons[index] = icon
		toolButtons[index] = button

		local input = U.inputButton(button, function()
			preview.Tool = index
			selectedIndex = index
			renderTools()
			if config.OnTool then
				config.OnTool(index, tool.Name)
			end
		end)
		U.connect(input.MouseEnter, function()
			if selectedIndex ~= index then
				U.tween(icon, TWEEN.Fast, { TextTransparency = 0.1 })
			end
		end)
		U.connect(input.MouseLeave, function()
			if selectedIndex ~= index then
				U.tween(icon, TWEEN.Fast, { TextTransparency = 0.4 })
			end
		end)
	end
	renderTools()

	local resetButton = U.frame(card, {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -8, 0, 8),
		Size = UDim2.fromOffset(102, 24),
	})
	U.corner(resetButton, 6)
	local resetIcon = U.icon(resetButton, "arrow-spin-counter-clockwise-15", 11, Theme.Muted, {
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.fromOffset(12, 24),
		TextTransparency = 0.4,
	})
	local resetLabel = U.label(resetButton, {
		Text = config.ResetText or "Reset layout",
		TextSize = 10,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.4,
		Position = UDim2.fromOffset(25, 0),
		Size = UDim2.new(1, -30, 1, 0),
	})
	local resetInput = U.inputButton(resetButton, function()
		if config.OnReset then
			config.OnReset()
		end
	end)
	U.connect(resetInput.MouseEnter, function()
		U.tween(resetButton, TWEEN.Fast, { BackgroundTransparency = 0.8 })
		U.tween(resetLabel, TWEEN.Fast, { TextTransparency = 0.15 })
	end)
	U.connect(resetInput.MouseLeave, function()
		U.tween(resetButton, TWEEN.Fast, { BackgroundTransparency = 1 })
		U.tween(resetLabel, TWEEN.Fast, { TextTransparency = 0.4 })
	end)
	preview.ResetButton = resetButton

	local name = U.label(card, {
		Text = config.Name or "",
		Font = Fonts.Bold,
		TextSize = 12.5,
		TextColor3 = Theme.Text,
		TextTransparency = 0.05,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.new(0, 0, 0, 42),
		Size = UDim2.new(1, 0, 0, 16),
	})
	preview.Name = name

	local tags = U.frame(card, {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0, 62),
		Size = UDim2.fromOffset(140, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 5,
	})
	U.list(tags, 3, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top)
	preview.TagsRoot = tags

	local stage = U.frame(card, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 86),
		Size = UDim2.new(1, -16, 1, -102),
	})
	preview.Stage = stage

	-- Ground ellipse and height guide mirror the reference boards without adding model content.
	local guide = U.frame(stage, {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Muted,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.new(0.22, 0, 0.16, 0),
		Size = UDim2.new(0, 1, 0.58, 0),
	})
	U.frame(guide, {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Muted,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.fromOffset(7, 1),
	})
	U.frame(guide, {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.Muted,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.fromOffset(7, 1),
	})

	local ground = U.frame(stage, {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.Window,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 1, -22),
		Size = UDim2.fromOffset(180, 32),
	})
	U.corner(ground, 16)
	U.stroke(ground, Theme.Muted, 0.45, 1)

	local placeholder = U.frame(stage, {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 1, -30),
		Size = UDim2.fromOffset(122, 196),
	})
	U.corner(placeholder, 10)
	local placeholderStroke = U.stroke(placeholder, Theme.Stroke, 0.25, 1)
	local placeholderIcon = U.icon(placeholder, config.PlaceholderIcon or "square-dashed-person-standing", 52, Theme.Muted, {
		TextTransparency = 0.3,
		Size = UDim2.new(1, 0, 1, -18),
	})
	local placeholderLabel = U.label(placeholder, {
		Text = config.PlaceholderText or "3D preview",
		Font = Fonts.Bold,
		TextSize = 8.5,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.55,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.new(0, 0, 1, -16),
		Size = UDim2.new(1, 0, 0, 14),
	})
	preview.Placeholder = placeholder

	if config.Image then
		local image = U.new("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = config.Image,
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -34),
			Size = UDim2.fromOffset(170, 240),
		}, stage)
		placeholder.Visible = false
		ground.Position = UDim2.new(0.5, 0, 1, -30)
		preview.Image = image
	end

	function preview:SetName(text)
		name.Text = text or ""
	end

	function preview:SetTags(list)
		for _, child in ipairs(tags:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
		preview.Tags = {}
		for index, tag in ipairs(list or {}) do
			local label = U.label(tags, {
				Text = tag.Text or "",
				Font = Fonts.Bold,
				TextSize = tag.Size or 11,
				TextColor3 = tag.Color or Theme.Text,
				TextTransparency = 0.05,
				TextXAlignment = Enum.TextXAlignment.Right,
				Size = UDim2.new(1, 0, 0, 16),
				ZIndex = 6,
			})
			label.LayoutOrder = index
			table.insert(preview.Tags, label)
		end
	end

	function preview:SetTool(index)
		if not toolButtons[index] then
			return
		end
		selectedIndex = index
		preview.Tool = index
		renderTools()
	end

	function preview:SetPlaceholder(icon, text)
		if icon then
			placeholderIcon.Text = icon
		end
		if text then
			placeholderLabel.Text = text
		end
	end

	function preview:Layout()
		local chipTotal = 0
		local cursor = 0
		for index, row in ipairs(preview.ChipRows) do
			row.Row.Position = UDim2.fromOffset(0, cursor)
			chipTotal = chipTotal + row.Height + (index > 1 and 6 or 0)
			cursor = cursor + row.Height + 6
		end
		if preview.ChipContainer then
			if #preview.ChipRows > 0 then
				preview.ChipContainer.Size = UDim2.new(1, -16, 0, chipTotal)
				preview.ChipContainer.Position = UDim2.new(0, 8, 1, -(chipTotal + 8))
				preview.ChipContainer.Visible = true
				stage.Size = UDim2.new(1, -16, 1, -(86 + chipTotal + 16))
			else
				preview.ChipContainer.Visible = false
				stage.Size = UDim2.new(1, -16, 1, -102)
			end
		end
	end

	function preview:AddChipGroup(groupConfig)
		groupConfig = groupConfig or {}
		if not preview.ChipContainer then
			preview.ChipContainer = U.frame(card, {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 1, -8),
				Size = UDim2.new(1, -16, 0, 0),
			})
		end

		local index = #preview.ChipRows + 1
		local row = U.frame(preview.ChipContainer, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 22),
		})
		row.LayoutOrder = index

		U.label(row, {
			Text = string.upper(groupConfig.Label or "LABEL"),
			Font = Fonts.Bold,
			TextSize = 8.5,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.5,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(52, 22),
		})

		local holder = U.frame(row, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(56, 0),
			Size = UDim2.new(1, -56, 0, 22),
		})
		local flow = U.flow(holder, 6, 5)

		local chips = {}
		local multi = groupConfig.Multi ~= false
		local selectedSet = {}
		for _, name in ipairs(groupConfig.Selected or {}) do
			selectedSet[name] = true
		end

		local entry = nil
		flow.OnLayout = function(height)
			local newHeight = math.max(22, height)
			row.Size = UDim2.new(1, 0, 0, newHeight)
			if entry then
				entry.Height = newHeight
			end
			preview:Layout()
		end

		local function refresh()
			for _, chip in ipairs(chips) do
				chip:SetSelected(chip.Item.Selected == true, true)
			end
		end

		for _, rawItem in ipairs(groupConfig.Items or {}) do
			local item = normalizeChip(rawItem)
			item.Selected = item.Selected == true or selectedSet[item.Name] == true
			if item.Color == nil then
				item.Color = Theme.Accent
			end
			local chip = createChip(holder, item, {
				Height = 22,
				TextSize = 10,
				DotSide = "left",
				OnSelect = function(changed)
					if not multi then
						for _, other in ipairs(chips) do
							if other ~= changed then
								other.Item.Selected = false
								other:SetSelected(false, true)
							end
						end
					end
					refresh()
					if groupConfig.Callback then
						groupConfig.Callback(changed.Item.Name, changed.Selected, changed.Color)
					end
				end,
				OnColor = function(changed)
					if groupConfig.ColorCallback then
						groupConfig.ColorCallback(changed.Item.Name, changed.Color)
					end
				end,
			})
			chip:SetSelected(item.Selected == true, true)
			table.insert(chips, chip)
			flow:Add(chip.Root, chip.Width, chip.Height)
		end

		entry = { Row = row, Flow = flow, Chips = chips, Label = groupConfig.Label, Height = 22 }
		preview.ChipRows[index] = entry
		flow:Relayout()
		preview:Layout()
		return entry
	end

	preview:SetTags(config.Tags or {})
	if config.Chips then
		-- Chip groups are declared in the demo so the page can attach callbacks.
		for _, group in ipairs(config.Chips) do
			preview:AddChipGroup(group)
		end
	end

	return preview
end

-- ---------------------------------------------------------------------------------------
-- Notifications
-- ---------------------------------------------------------------------------------------

local notifyRoot = nil
local notifyOrder = 0
Nerx.ActiveNotifications = {}

local function ensureNotifyRoot()
	if notifyRoot and notifyRoot.Parent then
		return notifyRoot
	end
	notifyRoot = U.frame(screenGui, {
		Name = "NerxNotifications",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(260, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 900,
	})
	U.list(notifyRoot, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top)
	return notifyRoot
end

function Nerx:Notify(config)
	config = config or {}
	if self._Unloaded then
		return
	end

	local container = ensureNotifyRoot()
	local cards = 0
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Frame") and child:GetAttribute("NerxNotify") then
			cards = cards + 1
		end
	end
	if cards >= 4 then
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Frame") and child:GetAttribute("NerxNotify") then
				child:Destroy()
				break
			end
		end
	end

	notifyOrder = notifyOrder + 1
	local card = U.frame(container, {
		BackgroundColor3 = Theme.SurfaceRaised,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 52),
		ZIndex = 901,
		ClipsDescendants = true,
	})
	card:SetAttribute("NerxNotify", true)
	card.LayoutOrder = notifyOrder
	U.corner(card, 8)
	U.stroke(card, Theme.Stroke, 0.55, 1)

	local accent = U.frame(card, {
		BackgroundColor3 = config.Color or Theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 14),
		Size = UDim2.fromOffset(2, 24),
		ZIndex = 902,
	})
	U.corner(accent, 1)

	local iconBox = U.frame(card, {
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 11),
		Size = UDim2.fromOffset(30, 30),
		ZIndex = 902,
	})
	U.corner(iconBox, 7)
	U.icon(iconBox, config.Icon or "circle-check", 15, config.Color or Theme.Accent, {
		TextTransparency = 0.1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 903,
	})

	U.label(card, {
		Text = config.Title or "Notification",
		Font = Fonts.Bold,
		TextSize = 11.5,
		TextColor3 = Theme.Text,
		TextTransparency = 0.05,
		Position = UDim2.fromOffset(52, 10),
		Size = UDim2.new(1, -64, 0, 16),
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 903,
	})
	U.label(card, {
		Text = config.Content or "",
		TextSize = 10,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.3,
		Position = UDim2.fromOffset(52, 26),
		Size = UDim2.new(1, -64, 0, 14),
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 903,
	})

	card.GroupTransparency = 1
	card.Size = UDim2.new(1, 0, 0, 44)
	U.tween(card, TWEEN.Default, { GroupTransparency = 0, Size = UDim2.new(1, 0, 0, 52) })

	local duration = config.Duration or 4
	task.delay(duration, function()
		if not card.Parent then
			return
		end
		U.tween(card, TWEEN.Default, { GroupTransparency = 1 })
		task.delay(0.2, function()
			if card and card.Parent then
				card:Destroy()
			end
		end)
	end)
	return card
end

-- ---------------------------------------------------------------------------------------
-- Indicators (Neverlose-style feature chips)
-- ---------------------------------------------------------------------------------------

local indicatorRoot = nil
local indicatorItems = {}
Nerx.IndicatorColor = {
	Red = Theme.Red,
	Green = Theme.Green,
	White = Theme.Text,
	Accent = Theme.Accent,
}

function Nerx:CreateIndicator(config)
	config = config or {}
	if not indicatorRoot or not indicatorRoot.Parent then
		indicatorRoot = U.frame(screenGui, {
			Name = "NerxIndicators",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 14, 0.5, 0),
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			ZIndex = 920,
		})
		U.list(indicatorRoot, 6, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
	end

	local color = config.Color
	if type(color) == "string" then
		color = Nerx.IndicatorColor[color] or Theme.Accent
	end
	color = color or Theme.Accent

	local textWidth = U.measure(config.Name or "Indicator", 10.5, Fonts.Bold).X
	local pill = U.frame(indicatorRoot, {
		BackgroundColor3 = Theme.Window,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(math.max(84, textWidth + 46), 26),
		Visible = false,
		ZIndex = 921,
	})
	U.corner(pill, 13)
	U.stroke(pill, Theme.Stroke, 0.6, 1)

	local accent = U.frame(pill, {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 9, 0.5, 0),
		Size = UDim2.fromOffset(2, 14),
		ZIndex = 922,
	})
	U.corner(accent, 1)
	local icon = U.icon(pill, config.Icon or "crosshairs", 13, color, {
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.fromOffset(15, 26),
		TextTransparency = 0.15,
		ZIndex = 922,
	})
	local label = U.label(pill, {
		Text = config.Name or "Indicator",
		Font = Fonts.Bold,
		TextSize = 10.5,
		TextColor3 = Theme.Text,
		TextTransparency = 0.1,
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -40, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 922,
	})

	local item = {
		Root = pill,
		Label = label,
		Icon = icon,
		Accent = accent,
		Color = color,
		Active = false,
	}
	table.insert(indicatorItems, item)

	function item:SetActive(value)
		value = value == true
		if value == self.Active then
			return
		end
		self.Active = value
		if value then
			self.Root.Visible = true
			self.Root.GroupTransparency = 1
			U.tween(self.Root, TWEEN.Default, { GroupTransparency = 0 })
		else
			U.tween(self.Root, TWEEN.Default, { GroupTransparency = 1 })
			task.delay(0.2, function()
				if not self.Active and self.Root.Parent then
					self.Root.Visible = false
				end
			end)
		end
	end

	function item:SetText(text)
		self.Label.Text = text
		self.Root.Size = UDim2.fromOffset(math.max(84, U.measure(text, 10.5, Fonts.Bold).X + 46), 26)
	end

	function item:SetColor(newColor)
		if type(newColor) == "string" then
			newColor = Nerx.IndicatorColor[newColor] or Theme.Accent
		end
		self.Color = newColor
		self.Accent.BackgroundColor3 = newColor
		self.Icon.TextColor3 = newColor
	end

	function item:Destroy()
		self.Root:Destroy()
		for index, value in ipairs(indicatorItems) do
			if value == self then
				table.remove(indicatorItems, index)
				break
			end
		end
	end

	if config.Active then
		item:SetActive(true)
	end
	return item
end

-- ---------------------------------------------------------------------------------------
-- Unload
-- ---------------------------------------------------------------------------------------

function Nerx:Unload()
	if self._Unloaded then
		return
	end
	self._Unloaded = true

	if self.ActiveKeybindCapture then
		pcall(self.ActiveKeybindCapture)
		self.ActiveKeybindCapture = nil
	end
	self.CapturingKeybind = false

	self:ClosePopup()
	for _, connection in ipairs(self.Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	self.Connections = {}
	table.clear(self.Flags)

	pcall(function()
		screenGui:Destroy()
	end)
	table.clear(self.Windows)
end

return Nerx


