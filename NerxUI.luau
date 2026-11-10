--[[
	Nerx UI Library · v1.3.0
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
Nerx.Version = "1.3.0"

local Theme = {
	Window = Color3.fromRGB(14, 14, 15),
	Main = Color3.fromRGB(21, 21, 22),
	Sidebar = Color3.fromRGB(14, 14, 15),
	Surface = Color3.fromRGB(27, 27, 28),
	SurfaceRaised = Color3.fromRGB(34, 34, 36),
	SurfaceHover = Color3.fromRGB(44, 44, 47),
	Selected = Color3.fromRGB(50, 50, 53),
	ChipSelected = Color3.fromRGB(56, 56, 58),
	Field = Color3.fromRGB(34, 34, 36),
	FieldHover = Color3.fromRGB(44, 44, 47),
	FieldDeep = Color3.fromRGB(28, 28, 29),
	FieldDisabled = Color3.fromRGB(27, 27, 28),
	Stroke = Color3.fromRGB(48, 48, 52),
	StrokeSoft = Color3.fromRGB(35, 35, 38),
	Divider = Color3.fromRGB(30, 30, 33),
	Track = Color3.fromRGB(70, 70, 74),
	Text = Color3.fromRGB(238, 238, 242),
	Muted = Color3.fromRGB(150, 150, 158),
	Faint = Color3.fromRGB(96, 96, 104),
	Icon = Color3.fromRGB(218, 218, 226),
	Accent = Color3.fromRGB(235, 235, 240),
	AccentDeep = Color3.fromRGB(160, 160, 168),
	Button = Color3.fromRGB(34, 34, 36),
	ButtonHover = Color3.fromRGB(44, 44, 47),
	Primary = Color3.fromRGB(56, 56, 58),
	PrimaryHover = Color3.fromRGB(68, 68, 71),
	PrimaryStroke = Color3.fromRGB(94, 94, 98),
	ToggleOff = Color3.fromRGB(34, 34, 36),
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
local IconFontFilled
do
	local path = "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
	local ok, font = pcall(function()
		return Font.new(path, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	end)
	if ok then
		IconFont = font
	end
	local filledOk, filled = pcall(function()
		return Font.new(path, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	end)
	if filledOk then
		IconFontFilled = filled
	end
end
Nerx.IconFont = IconFont
Nerx.IconFontFilled = IconFontFilled or IconFont

Nerx.Icons = {
	Aim = "crosshairs",
	Visuals = "eye",
	Misc = "gear",
	Kreedz = "person-jumping",
	Configs = "floppy-disk",
	Console = "rectangle-list",
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
Nerx.Components = {}
Nerx.ComponentsById = {}
Nerx.ComponentCounter = 0
Nerx.LayoutState = {}
Nerx.Connections = {}
Nerx.Queries = {}
Nerx.AccentListeners = {}
Nerx.Windows = {}
Nerx.Popup = nil
Nerx.PopupOverlay = nil
Nerx.PopupHost = nil
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
	Fast = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Default = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	VerySlow = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Page = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	PageOut = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	Popup = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

local U = {}
Nerx.U = U
U.Tween = TWEEN

-- ---------------------------------------------------------------------------------------
-- Generic construction helpers
-- ---------------------------------------------------------------------------------------

function U.new(class, props, parent)
	local object = Instance.new(class)
	if class == "ScrollingFrame" then
		object.ClipsDescendants = true
	end
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

function U.canvas(parent, props)
    return U.new("CanvasGroup", props, parent)
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
	if merged.TextWrapped ~= true and merged.TextTruncate == nil then
		merged.TextTruncate = Enum.TextTruncate.AtEnd
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
		-- BuilderIcons glyphs are single characters; wrapping can push them
		-- outside a tight holder and make small selector icons look blank.
		TextWrapped = false,
	}
	-- Roblox does not expose every BuilderIcons weight in every client
	-- build. The bold/filled face is the one that reliably contains the
	-- glyphs, so it is the default; Filled = false opts into the regular
	-- face only when a caller knows it exists.
	local filled = not (props and props.Filled == false)
	if filled and IconFontFilled then
		defaults.FontFace = IconFontFilled
	elseif IconFont then
		defaults.FontFace = IconFont
	else
		defaults.Font = Fonts.Bold
	end
	if props then
		for key, value in pairs(props) do
			if key ~= "Filled" then
				defaults[key] = value
			end
		end
	end
	return U.new("TextLabel", defaults, parent)
end

function U.stroke(parent, color, transparency, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.Stroke
	stroke.Transparency = transparency == nil and 0.4 or transparency
	stroke.Thickness = thickness or 1
	-- Miter joins produce spikes on small rounded controls at fractional UI
	-- scales; rounded joins keep every pill/card edge smooth.
	pcall(function()
		stroke.LineJoinMode = Enum.LineJoinMode.Round
	end)
	pcall(function()
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end)
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

function U.list(parent, padding, horizontal, vertical, direction)
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, padding or 0)
	layout.FillDirection = direction or Enum.FillDirection.Vertical
	layout.HorizontalAlignment = horizontal or Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = vertical or Enum.VerticalAlignment.Top
	layout.Parent = parent
	return layout
end

function U.hlist(parent, padding, horizontal, vertical)
	return U.list(parent, padding, horizontal, vertical, Enum.FillDirection.Horizontal)
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

-- Press feedback runs on a damped spring instead of a fixed tween, so buttons
-- keep their velocity when re-pressed mid-return (same model as the web jelly).
local pressSprings = {}
local pressLoop

local function stepPressSprings()
	if pressLoop then
		return
	end
	pressLoop = RunService.Heartbeat:Connect(function(dt)
		local active = false
		for scaleObject, body in pairs(pressSprings) do
			if not scaleObject.Parent then
				pressSprings[scaleObject] = nil
			else
				local remaining = math.min(dt, 0.05)
				local steps = math.max(1, math.ceil(remaining / (1 / 180)))
				local h = remaining / steps
				for _ = 1, steps do
					body.velocity += ((body.target - body.value) * body.stiffness - body.velocity * body.damping) * h
					body.value += body.velocity * h
				end
				scaleObject.Scale = body.value
				if math.abs(body.velocity) < 0.0015 and math.abs(body.target - body.value) < 0.0004 then
					body.value = body.target
					body.velocity = 0
					scaleObject.Scale = body.value
					pressSprings[scaleObject] = nil
				else
					active = true
				end
			end
		end
		if not active and next(pressSprings) == nil then
			pressLoop:Disconnect()
			pressLoop = nil
		end
	end)
end

function U.pressFx(input, target, pressScale)
	if not input or not target or target.ClassName == "ScreenGui" then
		return
	end
	local press = target:FindFirstChild("NerxPressScale")
	if not press or press.ClassName ~= "UIScale" then
		press = Instance.new("UIScale")
		press.Name = "NerxPressScale"
		press.Scale = 1
		press.Parent = target
	end
	local defaultDepth = pressScale or 0.975
	local function pressDepth()
		local frosted = rawget(Nerx, "Frosted")
		if not pressScale and frosted and frosted.Enabled then
			return frosted.Params.Press
		end
		return defaultDepth
	end
	local function pressTo(depth)
		local frosted = rawget(Nerx, "Frosted")
		local damping = 24
		if frosted and frosted.Enabled then
			damping = frosted.Params.Spring
		end
		local body = pressSprings[press]
		if not body then
			body = { value = press.Scale, velocity = 0, target = press.Scale, stiffness = 520, damping = damping }
			pressSprings[press] = body
		end
		body.stiffness = 520
		body.damping = damping
		body.target = depth
		stepPressSprings()
	end
	U.connect(input.InputBegan, function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch then
			pressTo(pressDepth())
		end
	end)
	U.connect(input.InputEnded, function()
		pressTo(1)
	end)
	U.connect(input.MouseLeave, function()
		pressTo(1)
	end)
	return press
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

function U.parentScale(object)
	local scale = 1
	local node = object and object.Parent
	while node do
		for _, child in ipairs(node:GetChildren()) do
			if child.ClassName == "UIScale" then
				scale = scale * (tonumber(child.Scale) or 1)
			end
		end
		if node.ClassName == "UIScale" then
			scale = scale * (tonumber(node.Scale) or 1)
		end
		node = node.Parent
	end
	return math.max(0.01, scale)
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

function U.setGroupTransparency(object, value)
    if not object then
        return
    end
    pcall(function()
        object.GroupTransparency = value
    end)
end

function U.tween(object, info, props)
    local ok, tween = pcall(function()
        return TweenService:Create(object, info or TWEEN.Default, props)
    end)
    if not ok or not tween then
        for key, value in pairs(props or {}) do
            pcall(function()
                object[key] = value
            end)
        end
        return nil
    end
    local played = pcall(function()
        tween:Play()
    end)
    return played and tween or nil
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
	-- Thick stacked UIStrokes looked like a solid black ring around small
	-- popups on bright scenes. Use Roblox's blurred UIShadow when available
	-- and fall back to one faint 1 px outline on older clients.
	local ok, shadow = pcall(function()
		return Instance.new("UIShadow")
	end)
	if ok and shadow then
		local soft = strength == "soft"
		local configured = pcall(function()
			shadow.Name = "NerxShadow"
			shadow.BlurRadius = UDim.new(0, soft and 10 or 6)
			shadow.Color = Theme.Black
			shadow.Offset = UDim2.fromOffset(0, soft and 3 or 2)
			shadow.Spread = UDim2.fromOffset(0, 0)
			shadow.Transparency = soft and 0.62 or 0.68
			shadow.Inset = false
			shadow.Mode = Enum.ApplyShadowMode.Shape
			shadow.ShowBehindParent = true
		end)
		if configured then
			shadow.Parent = parent
		else
			pcall(function()
				shadow:Destroy()
			end)
			shadow = nil
		end
	end
	if shadow then
		return shadow
	end
	local stroke = U.stroke(parent, Theme.Black, 0.8, 1)
	stroke.Name = "NerxShadowFallback"
	return stroke
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
	local frame = U.canvas(nil, {
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
			U.setGroupTransparency(root, 1)
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

function Nerx:ClosePopup(instant)
	local popup = Nerx.Popup
	if not popup then
		return
	end
	Nerx.Popup = nil
	for _, key in ipairs({ "Escape", "Outside" }) do
		if popup[key] then
			pcall(function()
				popup[key]:Disconnect()
			end)
			popup[key] = nil
		end
	end

	local card = popup.Card
	local overlay = popup.Overlay
	if instant or not card or not card.Parent then
		if card then
			card:Destroy()
		end
		if overlay then
			overlay:Destroy()
		end
		return
	end

	local position = card.Position
	U.tween(card, TWEEN.Fast, {
		GroupTransparency = 1,
		Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 4),
	})
	task.delay(0.11, function()
		if card and card.Parent then
			card:Destroy()
		end
		if overlay and overlay.Parent then
			overlay:Destroy()
		end
	end)
end

function U.popup(anchor, width, height, builder, alignRight, placement)
	Nerx:ClosePopup(true)

	-- Popups live inside the window's scaled layer. Parenting them to the raw
	-- ScreenGui was the reason dropdowns and the colour picker appeared huge
	-- and detached from their controls when the menu was downscaled.
	local host = Nerx.PopupHost
	if host and not host.Parent then
		host = nil
	end
	local parent = host or screenGui
	local scale = 1
	local originX, originY = 0, 0
	local boundsX, boundsY = U.viewport().X, U.viewport().Y

	if host then
		scale = math.max(0.01, Nerx.Scale or 1)
		local hostPosition = host.AbsolutePosition
		originX, originY = hostPosition.X, hostPosition.Y
		local hostSize = host.AbsoluteSize
		if hostSize.X > 0 and hostSize.Y > 0 then
			boundsX = hostSize.X / scale
			boundsY = hostSize.Y / scale
		end
	end

	local overlay = U.frame(parent, {
		Name = "NerxPopupOverlay",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Active = false,
		ZIndex = 901,
	})

	local card = U.canvas(parent, {
		Name = "NerxPopup",
		BackgroundColor3 = Theme.SurfaceRaised,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, height),
		ZIndex = 902,
		Active = true,
		ClipsDescendants = false,
	})
	U.corner(card, 8)
	U.stroke(card, Theme.Stroke, 0.45, 1)
	U.shadow(card)

	local absolute = anchor.AbsolutePosition
	local size = anchor.AbsoluteSize
	local anchorX = (absolute.X - originX) / scale
	local anchorY = (absolute.Y - originY) / scale
	local anchorWidth = size.X / scale
	local anchorHeight = size.Y / scale

	-- Defensive fallback for executors where AbsolutePosition can be stale or
	-- zero while the GUI is inside a scaled/scrolling container. In that case
	-- anchor the popup to the pointer instead of dropping it in the middle.
	if host then
		local hostSize = host.AbsoluteSize
		local valid = absolute.X >= originX - 2
			and absolute.Y >= originY - 2
			and absolute.X <= originX + hostSize.X + 2
			and absolute.Y <= originY + hostSize.Y + 2
		if not valid then
			local mouse = UserInputService:GetMouseLocation()
			anchorX = (mouse.X - originX) / scale - width * 0.5
			anchorY = (mouse.Y - originY) / scale
			anchorWidth = 0
			anchorHeight = 0
		end
	end

	local x = anchorX
	if alignRight then
		x = anchorX + anchorWidth - width
	end
	if x + width > boundsX - 8 then
		x = anchorX + anchorWidth - width
	end
	if x + width > boundsX - 8 then
		x = boundsX - width - 8
	end
	if x < 8 then
		x = 8
	end

	local below = anchorY + anchorHeight + 6
	local above = anchorY - height - 6
	local y = below
	if placement == "right" then
		x = anchorX + anchorWidth + 6
		if x + width > boundsX - 8 then
			x = anchorX - width - 6
		end
		if x < 8 then
			x = math.max(8, boundsX - width - 8)
		end
		y = anchorY + (anchorHeight - height) * 0.5
		if y + height > boundsY - 8 then
			y = math.max(8, boundsY - height - 8)
		end
	else
		if below + height > boundsY - 8 then
			y = above
		end
		if y < 8 then
			y = math.max(8, boundsY - height - 8)
		end
	end

	card.Position = UDim2.fromOffset(x, y - 4)
	U.setGroupTransparency(card, 1)
	card.Size = UDim2.fromOffset(width, height - 4)
	U.tween(card, TWEEN.Popup, {
		GroupTransparency = 0,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, height),
	})

	builder(card)

	for _, object in ipairs(card:GetDescendants()) do
		if object:IsA("GuiObject") then
			object.ZIndex = math.max(tonumber(object.ZIndex) or 1, card.ZIndex + 1)
		end
	end

	local function dismiss()
		Nerx:ClosePopup()
	end

	-- Close when clicking outside the card, but let the click reach the control
	-- below so switching dropdowns or closing a picker feels like one action.
	local outside
	outside = U.connect(UserInputService.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not card.Parent then
			return
		end
		local position = input.Position
		local cardPosition = card.AbsolutePosition
		local cardSize = card.AbsoluteSize
		if position.X < cardPosition.X or position.Y < cardPosition.Y
			or position.X > cardPosition.X + cardSize.X
			or position.Y > cardPosition.Y + cardSize.Y then
			dismiss()
		end
	end)

	local escape
	escape = U.connect(UserInputService.InputBegan, function(input)
		if input.KeyCode == Enum.KeyCode.Escape then
			dismiss()
		end
	end)

	Nerx.Popup = { Card = card, Overlay = overlay, Escape = escape, Outside = outside }
	Nerx.PopupOverlay = overlay
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

	U.popup(anchor, 220, 200, function(card)
		U.padding(card, 12, 12, 12, 12)

		-- Popup-local connections must be disconnected when the picker closes.
		-- Previously the global InputChanged listeners stayed alive and could keep
		-- recolouring the swatch (including snapping it to black) after closing.
		local transient = {}
		local function bind(signal, handler)
			local connection = signal:Connect(handler)
			table.insert(transient, connection)
			return connection
		end
		local function cleanup()
			for _, connection in ipairs(transient) do
				pcall(function()
					connection:Disconnect()
				end)
			end
			table.clear(transient)
		end
		pcall(function()
			card.Destroying:Connect(cleanup)
		end)

		local lastEmit = 0
		local function emit(force)
			local now = os.clock()
			if (not force and now - lastEmit < 0.03) or not card.Parent then
				return
			end
			lastEmit = now
			silent = true
			callback(Color3.fromHSV(h, s, v), alpha)
			silent = false
		end

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
			bind(frame.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					holding = true
					onInput(input)
				end
			end)
			bind(UserInputService.InputChanged, function(input)
				if not frame.Parent then
					holding = false
					return
				end
				if holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					onInput(input)
				end
			end)
			bind(UserInputService.InputEnded, function(input)
				if holding and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					holding = false
					emit(true)
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

		bind(hexBox.FocusLost, function()
			local parsed = U.fromHex(hexBox.Text)
			if parsed then
				h, s, v = U.rgbToHsv(parsed)
				applyHsv(true)
			else
				refreshLabels()
			end
		end)

		for index, box in ipairs(rgbBoxes) do
			bind(box.FocusLost, function()
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

	local toggleInput = U.inputButton(root, function()
		if not api.Disabled then
			api:SetValue(not value)
		end
	end)
	U.pressFx(toggleInput, root, 0.94)
	U.connect(toggleInput.MouseEnter, function()
		if not api.Disabled then
			U.tween(root, TWEEN.Fast, { BackgroundTransparency = 0.08 })
		end
	end)
	U.connect(toggleInput.MouseLeave, function()
		U.tween(root, TWEEN.Fast, { BackgroundTransparency = 0 })
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
		Size = UDim2.fromOffset(16, 16),
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
	U.pressFx(input, root, 0.9)
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
	local scale = math.max(0.01, Nerx.Scale or 1)
	local width = math.max(140, field.AbsoluteSize.X / scale)
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
	U.padding(root, 0, 6, 0, 6)
	local label = U.label(root, {
		Text = text or "Button",
		TextSize = 10.5,
		TextColor3 = api.Disabled and Theme.Faint or Theme.Text,
		TextTransparency = api.Disabled and 0.55 or 0.05,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
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
	U.pressFx(input, root, 0.97)
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
		BackgroundColor3 = Theme.Button,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width or 84, height or 28),
	})
	U.corner(root, 6)
	U.stroke(root, Theme.Stroke, 0.45, 1)
	U.padding(root, 0, 7, 0, 7)
	local fitSize = 11
	local innerWidth = math.max(1, (width or 84) - 14)
	local measuredWidth = U.measure(text or "Button", fitSize, Fonts.Regular).X
	if measuredWidth > innerWidth then
		fitSize = math.max(7, fitSize * innerWidth / measuredWidth)
	end
	local label = U.label(root, {
		Text = text or "Button",
		TextSize = fitSize,
		TextColor3 = Theme.Text,
		TextTransparency = 0.05,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.fromScale(1, 1),
	})
	local input = U.inputButton(root, callback or function() end)
	U.pressFx(input, root, 0.97)
	U.connect(input.MouseEnter, function()
		U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.ButtonHover })
	end)
	U.connect(input.MouseLeave, function()
		U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.Button })
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
	local iconSize = options.IconSize or 12
	local iconGap = options.IconGap or 6
	local paddingX = options.PaddingX or 10
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
			content = content + iconSize + iconGap
		end
		if hasDot then
			content = content + dotSize + 6
		end
		width = math.max(height + 6, paddingX * 2 + content)
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
	local cursor = paddingX

	if hasIcon then
		iconLabel = U.icon(root, item.Icon, iconSize, Theme.Muted, {
			Position = UDim2.fromOffset(cursor, 0),
			Size = UDim2.fromOffset(iconSize, height),
			TextTransparency = 0.45,
			Filled = options.IconFilled ~= false,
		})
		cursor = cursor + iconSize + iconGap
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
			Position = UDim2.new(1, -paddingX, 0.5, 0),
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
		U.tween(root, TWEEN.Fast, {
			BackgroundColor3 = selected and Theme.ChipSelected or Theme.Window,
			BackgroundTransparency = selected and 0 or 0.25,
		})
		U.tween(stroke, TWEEN.Fast, {
			Transparency = selected and 0.3 or 0.55,
			Color = selected and Theme.Accent or Theme.StrokeSoft,
		})

		if textLabel then
			U.tween(textLabel, TWEEN.Fast, {
				TextColor3 = selected and Theme.Text or Theme.Muted,
				TextTransparency = selected and 0.02 or 0.35,
			})
		end
		if iconLabel then
			U.tween(iconLabel, TWEEN.Fast, {
				TextColor3 = selected and Theme.Text or Theme.Muted,
				TextTransparency = selected and 0.1 or 0.5,
			})
		end
		if dot then
			dot.BackgroundColor3 = api.Color
			U.tween(dot, TWEEN.Fast, {
				BackgroundTransparency = selected and 0 or 0.4,
			})
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

	U.pressFx(input, root, 0.96)
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

	local fieldInput = U.inputButton(field, function()
		openDropdown(field, options, function(selected)
			select(selected)
		end, config.Disabled)
	end)
	U.pressFx(fieldInput, field, 0.98)
	U.connect(fieldInput.MouseEnter, function()
		if not config.Disabled then
			U.tween(field, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
		end
	end)
	U.connect(fieldInput.MouseLeave, function()
		if not config.Disabled then
			U.tween(field, TWEEN.Fast, { BackgroundColor3 = Theme.Field })
		end
	end)
	return api
end

local function segmentedWidget(parent, config)
	config = config or {}
	local items = config.Items or {}
	local width = config.Width or 0
	local height = config.Height or 24
	local container = config.Container ~= false
	local selectedColor = config.Primary and Theme.Primary or Theme.ChipSelected
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
	local value = config.Selected or (items[1] and (items[1].Name or items[1])) or nil
	local count = math.max(1, #items)
	local segmentWidth = width / count
	local api = { Root = root, Value = value, Width = width }

	local function fitLabel(button)
		local labelSize = config.TextSize or 10
		local labelSpace = math.max(1, segmentWidth - 6)
		local measured = U.measure(button.Name, labelSize, Fonts.Regular).X
		if measured > labelSpace then
			labelSize = math.max(7, labelSize * labelSpace / measured)
		end
		button.Label.TextSize = labelSize
	end

	local function render(animate)
		local info = TWEEN.Fast
		for _, button in ipairs(buttons) do
			local active = button.Name == value
			U.tween(button.Root, info, {
				BackgroundColor3 = active and selectedColor or Theme.White,
				BackgroundTransparency = active and 0 or 1,
			})
			U.tween(button.Label, info, {
				TextColor3 = active and selectedText or Theme.Muted,
				TextTransparency = active and 0.05 or 0.35,
			})
		end
	end

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
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.fromScale(1, 1),
		})
		local entry = { Root = button, Label = label, Name = name }
		buttons[index] = entry
		fitLabel(entry)
		local input = U.inputButton(button, function()
			if item.Disabled then
				return
			end
			if value == name then
				return
			end
			value = name
			api.Value = name
			render(true)
			if config.Callback then
				config.Callback(name)
			end
		end)
		U.pressFx(input, button, 0.97)
		U.connect(input.MouseEnter, function()
			if value ~= name then
				U.tween(button, TWEEN.Fast, {
					BackgroundColor3 = Theme.FieldHover,
					BackgroundTransparency = 0.55,
				})
				U.tween(label, TWEEN.Fast, { TextTransparency = 0.12 })
			end
		end)
		U.connect(input.MouseLeave, function()
			if value ~= name then
				U.tween(button, TWEEN.Fast, {
					BackgroundColor3 = Theme.White,
					BackgroundTransparency = 1,
				})
				U.tween(label, TWEEN.Fast, { TextTransparency = 0.35 })
			end
		end)
	end

	function api:GetValue()
		return value
	end

	function api:SetValue(name, silent)
		value = name
		api.Value = name
		render(true)
		if not silent and config.Callback then
			config.Callback(name)
		end
	end

	function api:SetWidth(newWidth)
		width = math.max(1, tonumber(newWidth) or width)
		api.Width = width
		segmentWidth = width / count
		root.Size = UDim2.fromOffset(width, height)
		for index, button in ipairs(buttons) do
			button.Root.Position = UDim2.fromOffset((index - 1) * segmentWidth, 0)
			button.Root.Size = UDim2.fromOffset(segmentWidth, height)
			fitLabel(button)
		end
	end

	render(false)
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
	-- Hover feedback lives on the root, not an overlay ImageButton, so the
	-- TextBox below keeps receiving focus and keyboard input.
	U.connect(root.MouseEnter, function()
		U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
		U.tween(stroke, TWEEN.Fast, { Transparency = 0.45 })
	end)
	U.connect(root.MouseLeave, function()
		if not box:IsFocused() then
			U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.Field })
			U.tween(stroke, TWEEN.Fast, { Transparency = 0.7 })
		end
	end)
	U.connect(box.Focused, function()
		U.tween(stroke, TWEEN.Fast, { Transparency = 0.25 })
		U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
	end)
	U.connect(box.FocusLost, function()
		U.tween(stroke, TWEEN.Fast, { Transparency = 0.7 })
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
		U.hlist(controls, 6, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
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
		Position = UDim2.fromOffset(flat and 10 or 0, 0),
		Size = UDim2.new(1, flat and -20 or 0, 0, 15),
	})
	local labelText = string.upper(name)
	local label = U.label(labelRow, {
		Text = labelText,
		Font = Fonts.Bold,
		TextSize = 10,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.5,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(0, 15),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local labelWidth = U.measure(labelText, 10, Fonts.Bold).X
	label.Size = UDim2.fromOffset(labelWidth + 2, 15)
	U.frame(labelRow, {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Position = UDim2.new(0, labelWidth + 10, 0.5, 0),
		Size = UDim2.new(1, -(labelWidth + 10), 0, 1),
	})
	local actions = U.frame(labelRow, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(0, 19),
		AutomaticSize = Enum.AutomaticSize.X,
	})
	U.hlist(actions, 4, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

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
		Inset = flat and 10 or 12,
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
			Kind = "toggle",
			Flag = toggleConfig.Flag,
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
			AnchorPoint = Vector2.new(0, 0.5),
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
			-- Keep the 10 px knob fully inside the rail at both ends instead of
			-- letting half of it stick out past the value pill.
			U.tween(knob, TWEEN.Fast, {
				Position = UDim2.new(scale, 5 * (1 - 2 * scale), 0.5, 0),
			})
			valueBox.Text = formatValue()
		end

		local function layout()
			-- AbsoluteSize includes the ancestor UIScale chain. Divide by
			-- that local scale (not a global window scale) so the rail and
			-- knob stay inside the value pill at 75-150% sizes.
			local uiScale = U.parentScale(row)
			local width = row.AbsoluteSize.X / uiScale
			if width <= 0 then
				return
			end
			local reserve = inset + 62 -- 10 px gutter + 52 px value pill
			local measured = U.measure(sliderConfig.Name or "", 12.5, Fonts.Regular).X
			local maxLeft = math.max(78, width - reserve - 56)
			local left = math.clamp(math.floor(measured + inset + 20), 78, maxLeft)
			label.Size = UDim2.new(0, math.max(24, left - inset - 10), 1, 0)
			track.Position = UDim2.new(0, left, 0.5, 0)
			track.Size = UDim2.new(0, math.max(40, width - left - reserve), 0, 18)
		end
		local api = attachOptions({
			Root = row,
			Default = sliderConfig.Default,
			Name = sliderConfig.Name,
			Kind = "slider",
			Flag = sliderConfig.Flag,
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
			Kind = "dropdown",
			Flag = dropdownConfig.Flag,
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

		local fieldInput = U.inputButton(field, function()
			local currentOptions = options
			openDropdown(field, currentOptions, function(selected)
				select(selected)
			end, api.Disabled)
		end)
		U.connect(fieldInput.MouseEnter, function()
			if not api.Disabled then
				U.tween(field, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
			end
		end)
		U.connect(fieldInput.MouseLeave, function()
			if not api.Disabled then
				U.tween(field, TWEEN.Fast, { BackgroundColor3 = Theme.Field })
			end
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
			Kind = "keybind",
			Flag = keyConfig.Flag,
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
			Kind = "input",
			Flag = inputConfig.Flag,
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
		action = action or {}
		if not section.HeaderActionGroup then
			section.HeaderActionGroup = { Items = {}, Selected = nil }
		end
		local textWidth = U.measure(action.Name or "", 9, Fonts.Regular).X
		local extra = action.Dot and 10 or 0
		local root = U.frame(section.Actions, {
			BackgroundColor3 = Theme.Field,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset((action.Icon and 26 or 22) + textWidth + extra, 18),
		})
		U.corner(root, 9)
		if action.Icon then
			U.icon(root, action.Icon, 9, Theme.Muted, {
				Position = UDim2.fromOffset(7, 0),
				Size = UDim2.fromOffset(10, 18),
				TextTransparency = 0.35,
			})
		end
		local label = U.label(root, {
			Text = action.Name or "",
			TextSize = 9,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.35,
			Position = UDim2.fromOffset(action.Icon and 18 or 8, 0),
			Size = UDim2.fromOffset(textWidth + 2, 18),
		})
		local dot
		if action.Dot then
			dot = U.frame(root, {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = action.Dot == true and Theme.Green or action.Dot,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -7, 0.5, 0),
				Size = UDim2.fromOffset(4, 4),
			})
			U.corner(dot, 2)
		end

		local entry = {
			Root = root,
			Label = label,
			Dot = dot,
			Name = action.Name,
			Selected = false,
		}

		function entry:SetSelected(value, silent)
			self.Selected = value == true
			if self.Selected then
				U.tween(root, TWEEN.Fast, { BackgroundTransparency = 0.1 })
				U.tween(label, TWEEN.Fast, { TextColor3 = Theme.Text, TextTransparency = 0.05 })
				if dot then
					U.tween(dot, TWEEN.Fast, { BackgroundTransparency = 0 })
				end
			else
				U.tween(root, TWEEN.Fast, { BackgroundTransparency = 1 })
				U.tween(label, TWEEN.Fast, { TextColor3 = Theme.Muted, TextTransparency = 0.35 })
				if dot then
					U.tween(dot, TWEEN.Fast, { BackgroundTransparency = 0.1 })
				end
			end
		end

		local function selectEntry()
			section.HeaderActionGroup.Selected = entry
			for _, item in ipairs(section.HeaderActionGroup.Items) do
				item:SetSelected(item == entry, true)
			end
		end

		U.inputButton(root, function()
			selectEntry()
			if action.Callback then
				action.Callback(entry)
			end
		end)

		root.LayoutOrder = #section.HeaderActionGroup.Items + 1
		table.insert(section.HeaderActionGroup.Items, entry)
		if action.Selected == true or (action.Selected ~= false and section.HeaderActionGroup.Selected == nil) then
			selectEntry()
		else
			entry:SetSelected(false, true)
		end
		return root
	end

	function section:SetHeaderAction(name)
		local group = section.HeaderActionGroup
		if not group then
			return nil
		end
		for _, item in ipairs(group.Items) do
			if string.lower(item.Name or "") == string.lower(name or "") then
				group.Selected = item
				for _, other in ipairs(group.Items) do
					other:SetSelected(other == item, true)
				end
				return item
			end
		end
		return nil
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
		RightWidth = config.RightWidth or 322,
		SectionStyle = config.SectionStyle or "card",
		Custom = false,
		Filter = "",
		Path = tostring(tab and tab.Name or "Tab") .. "/" .. tostring(config.Name or "Page"),
		ComponentCounter = 0,
	}

	local root = U.canvas(host, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		GroupTransparency = 0,
		Visible = false,
		ZIndex = 1,
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
		Position = UDim2.new(1, -20, 0, 17),
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
	})
	U.hlist(headerControls, 10, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
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
		ClipsDescendants = true,
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
		Position = UDim2.new(1, -336, 0, 56),
		Size = UDim2.fromOffset(322, 1),
		Visible = false,
	})
	page.RightHost = rightHost

	local rightScroll = U.new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
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
		Position = UDim2.new(1, -348, 0, 56),
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
		self.ComponentCounter = (self.ComponentCounter or 0) + 1
		Nerx.ComponentCounter = Nerx.ComponentCounter + 1
		local identifier = tostring(self.Path or self.Title or "Page")
			.. "@" .. tostring(self.ComponentCounter)
		component.Id = identifier
		component.Path = identifier
		component.Kind = component.Kind or "control"
		if component.Name == nil or component.Name == "" then
			component.Name = component.Kind
		end
		Nerx.Components[#Nerx.Components + 1] = component
		Nerx.ComponentsById[identifier] = component
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

			rightHost.Position = UDim2.new(1, -(14 + rightWidth), 0, top)
			rightHost.Size = UDim2.new(0, rightWidth, 1, -(top + bottom))
			rightHost.Visible = true

			divider.Position = UDim2.new(1, -(14 + rightWidth + 12), 0, 0)
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
				IconSize = 15,
				IconGap = 7,
				PaddingX = 12,
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
				chip.Item.Selected = isMatch
				chip:SetSelected(isMatch, true)
				if isMatch then
					api.Value = value
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
		-- Keep the page actions on the selector row so the header reads as one line
		-- (title above, filter chips + actions below).
		headerControls.Position = UDim2.new(1, -20, 0, 52)
		self:Relayout()
		return api
	end

	function page:SetHeaderButton(buttonConfig)
		buttonConfig = buttonConfig or {}
		local text = buttonConfig.Text or "Action"
		local iconName = buttonConfig.Icon or "three-bars-horizontal-narrowing"
		local textWidth = U.measure(text, 11, Fonts.Regular).X
		local width = 12 + 14 + 8 + textWidth + 12
		local root = U.frame(headerControls, {
			BackgroundColor3 = Theme.FieldDeep,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(width, 26),
		})
		U.corner(root, 13)
		U.stroke(root, Theme.Stroke, 0.45, 1)
		root.LayoutOrder = 0
		U.icon(root, iconName, 13, Theme.Muted, {
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.fromOffset(14, 26),
			TextTransparency = 0.3,
		})
		U.label(root, {
			Text = text,
			TextSize = 11,
			TextColor3 = Theme.Text,
			TextTransparency = 0.1,
			Position = UDim2.fromOffset(34, 0),
			Size = UDim2.fromOffset(textWidth + 2, 26),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		local input = U.inputButton(root, buttonConfig.Callback or function() end)
		U.connect(input.MouseEnter, function()
			U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.Field })
		end)
		U.connect(input.MouseLeave, function()
			U.tween(root, TWEEN.Fast, { BackgroundColor3 = Theme.FieldDeep })
		end)
		self.HeaderButton = root
		return root
	end

	function page:SetHeaderSwitch(switchConfig)
		local textWidth = U.measure(switchConfig.Text or "", 11, Fonts.Regular).X
		local root = U.frame(headerControls, {
			BackgroundColor3 = Theme.FieldDeep,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(12 + 32 + 8 + textWidth + 12, 26),
		})
		U.corner(root, 13)
		U.stroke(root, Theme.Stroke, 0.45, 1)
		root.LayoutOrder = 1

		local toggle = toggleWidget(root, switchConfig.Default, function(value)
			if switchConfig.Callback then
				switchConfig.Callback(value)
			end
		end)
		toggle.Root.AnchorPoint = Vector2.new(0, 0.5)
		toggle.Root.Position = UDim2.new(0, 12, 0.5, 0)

		local label = U.label(root, {
			Text = switchConfig.Text or "",
			TextSize = 11,
			TextColor3 = Theme.Text,
			TextTransparency = 0.1,
			Position = UDim2.fromOffset(12 + 32 + 8, 0),
			Size = UDim2.fromOffset(textWidth + 2, 26),
		})

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
			BackgroundColor3 = Theme.FieldDeep,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(20, 20),
		})
		U.corner(root, 10)
		root.LayoutOrder = 2
		local iconLabel = U.icon(root, icon or "gear", 16, Theme.Muted, {
			TextTransparency = 0.35,
			Size = UDim2.fromScale(1, 1),
			Filled = true,
		})
		local input = U.inputButton(root, callback or function() end)
		U.connect(input.MouseEnter, function()
			U.tween(root, TWEEN.Fast, { BackgroundTransparency = 0.8 })
			U.tween(iconLabel, TWEEN.Fast, { TextTransparency = 0.05 })
		end)
		U.connect(input.MouseLeave, function()
			U.tween(root, TWEEN.Fast, { BackgroundTransparency = 1 })
			U.tween(iconLabel, TWEEN.Fast, { TextTransparency = 0.35 })
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
		local active = value == true
		if active then
			root.Visible = true
			root.ZIndex = 3
			root.Position = UDim2.fromOffset(0, 0)
			U.setGroupTransparency(root, 0)
			self:Relayout()
		else
			self.AnimationToken = {}
			root.Visible = false
			root.Position = UDim2.fromOffset(0, 0)
			U.setGroupTransparency(root, 0)
		end
		if self.Preview and self.Preview.OnShow then
			self.Preview.OnShow(active)
		end
	end

	function page:AnimateIn()
		local token = {}
		self.AnimationToken = token
		root.Visible = true
		root.ZIndex = 3
		U.setGroupTransparency(root, 1)
		root.Position = UDim2.fromOffset(12, 0)
		U.tween(root, TWEEN.Page, {
			GroupTransparency = 0,
			Position = UDim2.fromOffset(0, 0),
		})
		self:Relayout()
	end

	function page:AnimateOut()
		if not root.Visible then
			return
		end
		local token = {}
		self.AnimationToken = token
		root.ZIndex = 2
		U.tween(root, TWEEN.PageOut, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(-10, 0),
		})
		task.delay(0.18, function()
			if self.AnimationToken == token and root.Parent then
				root.Visible = false
				root.Position = UDim2.fromOffset(0, 0)
				U.setGroupTransparency(root, 0)
			end
		end)
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
		OnAccountClick = config.OnAccountClick,
		OnRenew = config.OnRenew,
		AccountExpiry = config.AccountExpiry or "Subscription active",
	}
	window.Signal = nil
	local root = U.canvas(screenGui, {
		Name = "NerxWindow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Main,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		Size = size,
		ClipsDescendants = true,
		Visible = true,
	})
	U.corner(root, 12)
	U.stroke(root, Theme.Stroke, 0.55, 1)
	window.Root = root
	window.Content = root
	window.Library = Nerx

	window.BaseSize = size
	window.MenuScale = 100
	window.MenuScaleFactor = 1
	window.WindowScale = 100
	window.WindowScaleFactor = 1
	window.ThreeDEnabled = false
	window.ThreeD = nil
	window.ThreeDDistance = 18
	window.ThreeDScale = 0.82
	window.ThreeDTilt = 6
	window.ThreeDStartedAt = 0

	local uiScale = U.new("UIScale", {
		Scale = 1,
	}, root)
	window.UIScale = uiScale

	local function updateScale()
		local viewport = U.viewport()
		local raw = math.min(1, (viewport.X - 16) / size.X.Offset, (viewport.Y - 16) / size.Y.Offset)
		local fit = math.max(0.55, raw)
		local menuScale = window.MenuScaleFactor or 1
		local windowScale = window.WindowScaleFactor or 1
		local threeDScale = window.ThreeDEnabled and (window.ThreeDScale or 0.82) or 1
		-- Window and menu scale are visual multipliers. The logical root keeps its
		-- designed size, which keeps fixed-offset cards from overlapping when the
		-- user selects 75% or smaller.
		uiScale.Scale = fit * menuScale * windowScale * threeDScale
		root.Size = size
		Nerx.Scale = uiScale.Scale
	end
	window.UpdateScale = updateScale

	function window:SetMenuScale(value)
		local percent = 100
		if type(value) == "number" then
			percent = value
		elseif type(value) == "string" and string.lower(value) ~= "auto" then
			percent = tonumber(string.match(value, "%d+")) or 100
		end
		self.MenuScale = percent
		self.MenuScaleFactor = math.clamp(percent / 100, 0.4, 3)
		updateScale()
	end

	function window:SetWindowScale(value)
		local percent = 100
		if type(value) == "number" then
			percent = value
		elseif type(value) == "string" and string.lower(value) ~= "auto" then
			percent = tonumber(string.match(value, "%d+")) or 100
		end
		self.WindowScale = percent
		self.WindowScaleFactor = math.clamp(percent / 100, 0.4, 2.5)
		updateScale()
	end

	-- The Roblox Neverlose library renders its window through a SurfaceGui part
	-- in front of the camera (Window:Set3DRender). This is the same technique:
	-- the part exactly fills the viewport, so layout pixels map 1:1 to the screen
	-- while the menu lives inside the 3D scene.
	function window:Set3DRender(enabled)
		enabled = enabled == true
		if enabled == (self.ThreeDEnabled == true) then
			return true
		end

		if enabled then
			local camera = workspace.CurrentCamera
			if not camera then
				return false
			end

			local created = nil
			local createOk, createErr = pcall(function()
				local part = Instance.new("Part")
				part.Name = "Nerx3DMenu"
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.Transparency = 1
				part.Size = Vector3.new(1, 1, 0.01)
				part.Parent = workspace

				local surface = Instance.new("SurfaceGui")
				surface.Name = "Nerx3DSurface"
				surface.Adornee = part
				surface.Face = Enum.NormalId.Front
				surface.AlwaysOnTop = true
				surface.LightInfluence = 0
				surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
				surface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				surface.CanvasSize = Vector2.new(800, 600)
				surface.PixelsPerStud = 40
				-- A SurfaceGui parented to its adornee part is the canonical,
				-- reliably-rendering form. Some executors skip SurfaceGuis nested
				-- inside a protected ScreenGui/CoreGui container.
				surface.Parent = part

				created = { Part = part, SurfaceGui = surface }
			end)

			if not createOk or not created then
				if created then
					pcall(function()
						created.SurfaceGui:Destroy()
					end)
					pcall(function()
						created.Part:Destroy()
					end)
				end
				warn("[NerxUI] 3D create failed: " .. tostring(createErr))
				return false
			end

			self.ThreeD = created
			self.ThreeDStartedAt = os.clock()

			local function refresh()
				local state = self.ThreeD
				local currentCamera = workspace.CurrentCamera
				if not state or not currentCamera or not state.Part.Parent then
					return
				end
				local viewport = currentCamera.ViewportSize
				if viewport.X < 2 or viewport.Y < 2 then
					return
				end
				local fov = math.clamp(tonumber(currentCamera.FieldOfView) or 70, 1, 120)
				local distance = math.max(4, tonumber(self.ThreeDDistance) or 18)
				local height = 2 * distance * math.tan(math.rad(fov * 0.5))
				local width = height * (viewport.X / viewport.Y)
				state.Part.Size = Vector3.new(width, height, 0.01)
				local viewportKey = tostring(math.floor(viewport.X)) .. "x" .. tostring(math.floor(viewport.Y))
				if self.ThreeDViewportKey ~= viewportKey then
					self.ThreeDViewportKey = viewportKey
					state.SurfaceGui.CanvasSize = Vector2.new(math.floor(viewport.X), math.floor(viewport.Y))
				end
				local progress = math.clamp((os.clock() - (self.ThreeDStartedAt or 0)) / 0.28, 0, 1)
				local tilt = math.rad((tonumber(self.ThreeDTilt) or 6) * progress)
				local position = currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * distance
				local facing = CFrame.lookAt(position, currentCamera.CFrame.Position)
				state.Part.CFrame = facing * CFrame.Angles(math.rad(-1.5) * progress, tilt, 0)
			end

			local ok, err = pcall(function()
				self.Root.Parent = created.SurfaceGui
				self.ThreeDRefresh = refresh
				refresh()
				if self.ThreeDConnection then
					pcall(function()
						self.ThreeDConnection:Disconnect()
					end)
					self.ThreeDConnection = nil
				end
				self.ThreeDConnection = RunService.RenderStepped:Connect(function()
					if self.ThreeDEnabled then
						refresh()
					end
				end)
				self.ThreeDEnabled = true
				Nerx.ThreeDEnabled = true
				self.UpdateScale()
			end)

			if not ok then
				self.ThreeDEnabled = false
				Nerx.ThreeDEnabled = false
				self.ThreeDRefresh = nil
				self.ThreeDStartedAt = 0
				self.ThreeDViewportKey = nil
				if self.ThreeDConnection then
					pcall(function()
						self.ThreeDConnection:Disconnect()
					end)
					self.ThreeDConnection = nil
				end
				self.ThreeD = nil
				pcall(function()
					self.Root.Parent = screenGui
				end)
				pcall(function()
					created.SurfaceGui:Destroy()
				end)
				pcall(function()
					created.Part:Destroy()
				end)
				pcall(function()
					self.UpdateScale()
				end)
				warn("[NerxUI] 3D setup failed: " .. tostring(err))
				return false
			end

			return true
		end

		self.ThreeDEnabled = false
		Nerx.ThreeDEnabled = false
		if self.ThreeDConnection then
			pcall(function()
				self.ThreeDConnection:Disconnect()
			end)
			self.ThreeDConnection = nil
		end
		self.ThreeDRefresh = nil
		self.ThreeDStartedAt = 0

		local state = self.ThreeD
		self.ThreeD = nil
		self.ThreeDViewportKey = nil
		-- Reparent before destroying the SurfaceGui, otherwise the window dies with it.
		self.Root.Parent = screenGui
		if state then
			pcall(function()
				if state.SurfaceGui then
					state.SurfaceGui:Destroy()
				end
			end)
			pcall(function()
				if state.Part then
					state.Part:Destroy()
				end
			end)
		end
		self.UpdateScale()
		return true
	end

	function window:Get3DRender()
		return self.ThreeDEnabled == true
	end

	Nerx.Set3DRender = function(_, enabled)
		if enabled == nil and type(_) == "boolean" then
			enabled = _
		end
		return window:Set3DRender(enabled)
	end

	Nerx.Get3DRender = function()
		return window:Get3DRender()
	end

	updateScale()
	local camera = workspace.CurrentCamera
	if camera then
		U.connect(camera:GetPropertyChangedSignal("ViewportSize"), updateScale)
	end

	-- Scaled popup layer: dropdowns, option menus and the colour picker inherit
	-- the window's UIScale instead of rendering oversized on the raw screen.
	local popupHost = U.frame(root, {
		Name = "PopupLayer",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 900,
	})
	window.PopupHost = popupHost
	Nerx.PopupHost = popupHost

	local sidebar = U.frame(root, {
		Name = "Sidebar",
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = 0,
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
		Size = UDim2.new(1, 0, 0, 52),
		Active = true,
	})
	window.Brand = brand

	local logoBox = U.frame(brand, {
		BackgroundColor3 = Theme.SurfaceRaised,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 9),
		Size = UDim2.fromOffset(34, 34),
		ClipsDescendants = true,
	})
	U.corner(logoBox, 8)
	local logoStroke = U.stroke(logoBox, Theme.Stroke, 0.4, 1)

local function drawRibbonBrand()
		-- Brand mark: the gradient N from the supplied identity tile. The
		-- light plate keeps the slate-to-lime gradient readable in dark menus.
		local BRAND_TILE = Color3.fromRGB(246, 248, 250)
		local BRAND_SLATE = Color3.fromRGB(43, 57, 62)
		local BRAND_DEEP = Color3.fromRGB(64, 93, 55)
		local BRAND_GREEN = Color3.fromRGB(105, 160, 54)
		local BRAND_LIME = Color3.fromRGB(158, 214, 52)
		logoBox.BackgroundColor3 = BRAND_TILE
		logoBox.BackgroundTransparency = 0
		logoStroke.Color = Color3.fromRGB(16, 20, 22)
		logoStroke.Transparency = 0.82

		-- Pure-UI brand mark: three thick ribbons with overlapping rounded
		-- joins. No image asset or EditableImage is required, so it renders even
		-- when the executor blocks local assets.
		local mark = U.frame(logoBox, {
			Name = "NerxBrandMark",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(34, 34),
			ClipsDescendants = false,
		})

		local leftSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, BRAND_SLATE),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(58, 82, 55)),
			ColorSequenceKeypoint.new(1, BRAND_GREEN),
		})
		local diagonalSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, BRAND_SLATE),
			ColorSequenceKeypoint.new(0.3, BRAND_DEEP),
			ColorSequenceKeypoint.new(0.64, BRAND_GREEN),
			ColorSequenceKeypoint.new(1, BRAND_LIME),
		})
		local rightSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, BRAND_LIME),
			ColorSequenceKeypoint.new(0.45, BRAND_GREEN),
			ColorSequenceKeypoint.new(1, BRAND_LIME),
		})

		local leftBar = U.frame(mark, {
			Name = "BrandLeft",
			BackgroundColor3 = BRAND_SLATE,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(3, 6),
			Size = UDim2.fromOffset(7, 21),
			ZIndex = 2,
		})
		U.corner(leftBar, 3.5)
		local leftGradient = U.new("UIGradient", {
			Color = leftSequence,
			Rotation = 90,
			Offset = Vector2.new(0, 0),
		}, leftBar)

		local diagonal = U.frame(mark, {
			Name = "BrandDiagonal",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = BRAND_GREEN,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(17, 16.5),
			Rotation = -42,
			Size = UDim2.fromOffset(7.5, 28),
			ZIndex = 3,
		})
		U.corner(diagonal, 3.75)
		local diagonalGradient = U.new("UIGradient", {
			Color = diagonalSequence,
			Rotation = 90,
			Offset = Vector2.new(0, 0),
		}, diagonal)

		local rightBar = U.frame(mark, {
			Name = "BrandRight",
			BackgroundColor3 = BRAND_LIME,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(24, 6),
			Size = UDim2.fromOffset(7, 21),
			ZIndex = 4,
		})
		U.corner(rightBar, 3.5)
		local rightGradient = U.new("UIGradient", {
			Color = rightSequence,
			Rotation = 90,
			Offset = Vector2.new(0, 0),
		}, rightBar)

		local logoGradients = {
			{ Gradient = leftGradient, Delay = 0.0 },
			{ Gradient = diagonalGradient, Delay = 0.65 },
			{ Gradient = rightGradient, Delay = 1.3 },
		}
		local logoClock = 0
		U.connect(RunService.Heartbeat, function(delta)
			if not logoBox.Parent then
				return
			end
			logoClock = logoClock + (tonumber(delta) or 0.016)
			for _, entry in ipairs(logoGradients) do
				local phase = math.sin(logoClock * 1.7 - entry.Delay)
				entry.Gradient.Offset = Vector2.new(0, phase * 0.45)
			end
		end)
end

	if config.Logo then
		local image = U.new("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = config.Logo,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
		}, logoBox)
		U.corner(image, 8)
	elseif config.BrandMask then
		local BRAND_TILE = Color3.fromRGB(246, 248, 250)
		logoBox.BackgroundColor3 = BRAND_TILE
		logoBox.BackgroundTransparency = 0
		logoStroke.Color = Color3.fromRGB(16, 20, 22)
		logoStroke.Transparency = 0.82
		local maskAsset = tostring(config.BrandMask)
		if maskAsset ~= "" and not maskAsset:find("://") then
			maskAsset = "rbxassetid://" .. maskAsset
		end
		-- Roblox-hosted white N mask. One diagonal UIGradient colours the
		-- exact brand silhouette and sweeps back and forth.
		local image = U.new("ImageLabel", {
			Name = "NerxBrandMark",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = maskAsset,
			ImageColor3 = Color3.new(1, 1, 1),
			Position = UDim2.fromOffset(4, 6),
			Size = UDim2.fromOffset(26, 22),
			ScaleType = Enum.ScaleType.Fit,
		}, logoBox)
		local maskSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(43, 57, 62)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(64, 93, 55)),
			ColorSequenceKeypoint.new(0.64, Color3.fromRGB(105, 160, 54)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 214, 52)),
		})
		local maskGradient = U.new("UIGradient", {
			Color = maskSequence,
			Rotation = 42,
			Offset = Vector2.new(0, 0),
		}, image)
		local maskClock = 0
		U.connect(RunService.Heartbeat, function(delta)
			if not logoBox.Parent then
				return
			end
			maskClock = maskClock + (tonumber(delta) or 0.016)
			maskGradient.Offset = Vector2.new(math.sin(maskClock * 1.7) * 0.55, 0)
		end)
		-- If the Roblox image never loads on this client, keep a visible mark
		-- instead of leaving the tile blank.
		task.delay(3, function()
			if not image.Parent then
				return
			end
			if image.IsLoaded == false then
				pcall(function()
					maskGradient:Destroy()
				end)
				image:Destroy()
				drawRibbonBrand()
			end
		end)
	else
		drawRibbonBrand()
	end

	local brandTitle = U.label(brand, {
		Text = window.Title,
		Font = Fonts.Bold,
		TextSize = 14,
		TextColor3 = Theme.Text,
		Position = UDim2.fromOffset(58, 8),
		Size = UDim2.fromOffset(130, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local brandSub = U.label(brand, {
		Text = window.Subtitle,
		Font = Fonts.Regular,
		TextSize = 8.5,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.45,
		Position = UDim2.fromOffset(58, 26),
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
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -16, 0, 46),
		Active = true,
	})
	U.corner(account, 8)
	U.stroke(account, Theme.Stroke, 0.65, 1)
	window.Account = account

	local avatar = U.frame(account, {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		ClipsDescendants = true,
	})
	U.corner(avatar, 15)
	window.AccountAvatar = avatar
	local avatarIcon = U.icon(avatar, "person-standing", 15, Theme.Muted, {
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
		TextSize = 11,
		TextColor3 = Theme.Text,
		Position = UDim2.fromOffset(46, 8),
		Size = UDim2.new(1, -76, 0, 16),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	window.AccountTag = U.label(account, {
		Text = config.AccountTag or "Attached",
		TextSize = 8.5,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.45,
		Position = UDim2.fromOffset(46, 24),
		Size = UDim2.new(1, -76, 0, 12),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	window.AccountAvatarImage = avatarImage
	window.AccountAvatarIcon = avatarIcon
	local accountChevron = U.icon(account, "chevron-large-right", 11, Theme.Muted, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -9, 0.5, 0),
		Size = UDim2.fromOffset(10, 10),
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
		if window.OnAccountClick then
			local ok, result = pcall(window.OnAccountClick, window, account)
			if not ok then
				warn("[NerxUI] OnAccountClick failed: " .. tostring(result))
			end
		else
			window:OpenQuickMenu(account)
		end
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

	-- Full-width rule: the brand column and the page header share the same
	-- baseline, so the vertical sidebar divider and this line meet cleanly.
	U.frame(root, {
		Name = "TopDivider",
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
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

	local SAVE_WIDTH = 61
	local MODE_SAVE_HEIGHT = 30
	local SAVE_GROUP_RIGHT = 292

	local function measureModeWidth(mode)
		local width = U.measure(tostring(mode or ""), 11, Fonts.Regular).X
		return math.clamp(width + 60, 84, 132)
	end

	local modeWidth = measureModeWidth(window.Mode)
	local modeSaveGroup = U.frame(topBar, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.FieldDeep,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -SAVE_GROUP_RIGHT, 0.5, 0),
		Size = UDim2.fromOffset(modeWidth + SAVE_WIDTH, MODE_SAVE_HEIGHT),
		-- The Save block is intentionally square; clipping it to this rounded
		-- group is what gives the merged pill a clean right edge.
		ClipsDescendants = true,
		ZIndex = 4,
	})
	U.corner(modeSaveGroup, 7)
	U.stroke(modeSaveGroup, Theme.Muted, 0.55, 1)

	local modeChip = U.frame(modeSaveGroup, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(modeWidth, MODE_SAVE_HEIGHT),
		ZIndex = 5,
	})
	local modeDot = U.frame(modeChip, {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Amber,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(6, 6),
	})
	U.corner(modeDot, 3)
	local modeLabel = U.label(modeChip, {
		Text = window.Mode,
		TextSize = 11,
		TextColor3 = Theme.Text,
		TextTransparency = 0.15,
		Position = UDim2.fromOffset(22, 0),
		Size = UDim2.new(1, -40, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local modeChevron = U.icon(modeChip, "chevron-large-down", 10, Theme.Muted, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(11, 11),
		TextTransparency = 0.4,
	})

	local saveButton = U.frame(modeSaveGroup, {
		BackgroundColor3 = Theme.Primary,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(modeWidth, 0),
		Size = UDim2.fromOffset(SAVE_WIDTH, MODE_SAVE_HEIGHT),
		ZIndex = 5,
	})
	-- Round the right side into the group outline; the narrow connector
	-- squares the left side so the mode and Save areas share one straight seam.
	U.corner(saveButton, 7)
	local saveConnector = U.frame(saveButton, {
		BackgroundColor3 = Theme.Primary,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(7, MODE_SAVE_HEIGHT),
		ZIndex = 5,
	})

	local saveLabel = U.label(saveButton, {
		Text = "Save",
		TextSize = 11.5,
		TextColor3 = Theme.Text,
		TextTransparency = 0.02,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 6,
	})
	window.ModeChip = modeChip
	window.ModeLabel = modeLabel
	window.ModeDot = modeDot
	window.ModeSaveGroup = modeSaveGroup
	window.SaveButton = saveButton
	window.SaveLabel = saveLabel

	local search = U.frame(topBar, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.FieldDeep,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -54, 0.5, 0),
		Size = UDim2.fromOffset(226, 30),
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
		TextSize = 11,
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
		Size = UDim2.fromOffset(49, 20),
	})
	U.hlist(keyHints, 3, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	local ctrlHint = U.label(keyHints, {
		Text = "Ctrl",
		Font = Fonts.Regular,
		TextSize = 9,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(28, 20),
	})
	U.corner(ctrlHint, 4)
	U.stroke(ctrlHint, Theme.Stroke, 0.4, 1)
	local fHint = U.label(keyHints, {
		Text = "F",
		Font = Fonts.Regular,
		TextSize = 9,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(18, 20),
	})
	U.corner(fHint, 4)
	U.stroke(fHint, Theme.Stroke, 0.4, 1)

	local shieldButton = U.frame(topBar, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Theme.FieldDeep,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		ZIndex = 4,
	})
	U.corner(shieldButton, 7)
	local shieldStroke = U.stroke(shieldButton, Theme.Stroke, 0.7, 1)
	local shieldIcon = U.icon(shieldButton, "shield-check", 14, Theme.Muted, {
		TextTransparency = 0.3,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 5,
		Filled = true,
	})
	local shieldInput = U.inputButton(shieldButton, function()
		window:OpenQuickMenu(shieldButton)
	end)
	U.connect(shieldInput.MouseEnter, function()
		U.tween(shieldButton, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
		U.tween(shieldIcon, TWEEN.Fast, { TextTransparency = 0.05 })
	end)
	U.connect(shieldInput.MouseLeave, function()
		U.tween(shieldButton, TWEEN.Fast, { BackgroundColor3 = Theme.FieldDeep })
		U.tween(shieldIcon, TWEEN.Fast, { TextTransparency = 0.3 })
	end)
	window.ShieldButton = shieldButton

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
			U.tween(search, TWEEN.Fast, { BackgroundColor3 = Theme.FieldDeep })
			searchIcon.TextTransparency = 0.3
		end
	end)
	U.connect(searchBox.Focused, function()
		U.tween(search, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
		searchStroke.Transparency = 0.5
		searchIcon.TextTransparency = 0.05
	end)
	U.connect(searchBox.FocusLost, function(enterPressed)
		U.tween(search, TWEEN.Fast, { BackgroundColor3 = Theme.FieldDeep })
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
		U.tween(saveConnector, TWEEN.Fast, { BackgroundColor3 = Theme.PrimaryHover })
	end)
	U.connect(saveInput.MouseLeave, function()
		U.tween(saveButton, TWEEN.Fast, { BackgroundColor3 = Theme.Primary })
		U.tween(saveConnector, TWEEN.Fast, { BackgroundColor3 = Theme.Primary })
	end)

	local modeInput = U.inputButton(modeChip, function()
		openDropdown(modeChip, window.Modes, function(selected)
			window:SetMode(selected)
		end)
	end)
	U.connect(modeInput.MouseEnter, function()
		U.tween(modeSaveGroup, TWEEN.Fast, { BackgroundColor3 = Theme.FieldHover })
	end)
	U.connect(modeInput.MouseLeave, function()
		U.tween(modeSaveGroup, TWEEN.Fast, { BackgroundColor3 = Theme.FieldDeep })
	end)

	-- ---------------------------------------------------------------------------------
	-- Window API
	-- ---------------------------------------------------------------------------------

	function window:RenderTab(tab)
		local selected = self.SelectedTab == tab
		if selected then
			U.tween(tab.Button, TWEEN.Default, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Selected })
			tab.Stroke.Transparency = 0.85
			if tab.Indicator then
				U.tween(tab.Indicator, TWEEN.Fast, { BackgroundTransparency = 0 })
			end
			U.tween(tab.Icon, TWEEN.Default, { TextColor3 = Theme.Text, TextTransparency = 0.05 })
			U.tween(tab.Label, TWEEN.Default, { TextColor3 = Theme.Text, TextTransparency = 0.05 })
		else
			U.tween(tab.Button, TWEEN.Default, { BackgroundTransparency = 1 })
			tab.Stroke.Transparency = 1
			if tab.Indicator then
				tab.Indicator.BackgroundTransparency = 1
			end
			U.tween(tab.Icon, TWEEN.Default, { TextColor3 = Theme.Text, TextTransparency = 0.3 })
			U.tween(tab.Label, TWEEN.Default, { TextColor3 = Theme.Text, TextTransparency = 0.32 })
		end

		local sub = tab.SubContainer
		local open = selected and tab.HasSubtabs
		local targetHeight = tab.SubHeight or 0
		if open then
			local token = {}
			tab.SubToken = token
			if not sub.Visible then
				sub.Visible = true
				sub.Size = UDim2.new(1, 0, 0, 0)
				U.setGroupTransparency(sub, 1)
			end
			if math.abs(sub.Size.Y.Offset - targetHeight) > 0.5 or sub.GroupTransparency > 0.01 then
				U.tween(sub, TWEEN.Page, {
					Size = UDim2.new(1, 0, 0, targetHeight),
					GroupTransparency = 0,
				})
			end
		elseif sub.Visible then
			local token = {}
			tab.SubToken = token
			U.tween(sub, TWEEN.PageOut, {
				Size = UDim2.new(1, 0, 0, 0),
				GroupTransparency = 1,
			})
			task.delay(0.18, function()
				if tab.SubToken == token and sub.Parent and not (self.SelectedTab == tab and tab.HasSubtabs) then
					sub.Visible = false
					U.setGroupTransparency(sub, 0)
				end
			end)
		end
	end

	function window:RenderSubTabs(tab)
		for _, sub in ipairs(tab.SubTabs) do
			local selected = tab.CurrentPage == sub.Page
			U.tween(sub.Label, TWEEN.Default, {
				TextColor3 = Theme.Text,
				TextTransparency = selected and 0.03 or 0.42,
			})
			U.tween(sub.Tick, TWEEN.Fast, {
				BackgroundTransparency = selected and 0 or 1,
			})
			if sub.Connector then
				U.tween(sub.Connector, TWEEN.Fast, {
					BackgroundColor3 = selected and Theme.Text or Theme.Divider,
					BackgroundTransparency = selected and 0 or 0.15,
				})
			end
		end
	end

	function window:SelectTab(tab, targetPage)
		if not tab then
			return
		end
		Nerx:ClosePopup(true)
		self.SelectedTab = tab
		for _, other in ipairs(self.Tabs) do
			self:RenderTab(other)
			for _, otherPage in ipairs(other.Pages) do
				otherPage:SetActive(false)
			end
		end

		local page
		if tab.HasSubtabs then
			page = targetPage or tab.CurrentPage
			if not page or page == tab.DefaultPage then
				page = tab.SubTabs[1] and tab.SubTabs[1].Page or tab.DefaultPage
			end
		else
			page = tab.DefaultPage
		end
		tab:SetPage(page, true)
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
		local width = measureModeWidth(mode)
		U.tween(modeChip, TWEEN.Fast, { Size = UDim2.fromOffset(width, MODE_SAVE_HEIGHT) })
		U.tween(saveButton, TWEEN.Fast, { Position = UDim2.fromOffset(width, 0) })
		U.tween(modeSaveGroup, TWEEN.Fast, { Size = UDim2.fromOffset(width + SAVE_WIDTH, MODE_SAVE_HEIGHT) })
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
		if accountConfig.Expiry then
			window.AccountExpiry = accountConfig.Expiry
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
			Nerx:ClosePopup(true)
			self.Visible = true
			root.Visible = true
			U.setGroupTransparency(root, 1)
			U.tween(root, TWEEN.Slow, { GroupTransparency = 0 })
		else
			self.Visible = false
			Nerx:ClosePopup(true)
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

		-- Active marker on the left edge of the parent pill (reference "I" bar).
		local tabIndicator = U.frame(button, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.Text,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 1, 0.5, 0),
			Size = UDim2.fromOffset(3, 18),
			ZIndex = 3,
		})
		U.corner(tabIndicator, 2)
		tab.Indicator = tabIndicator
		tab.SubHeight = 0

		tab.Icon = U.icon(button, tab.Icon, 17, Theme.Muted, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.fromOffset(24, 24),
			TextTransparency = 0.4,
			Filled = true,
		})
		tab.Label = U.label(button, {
			Text = tab.Name,
			TextSize = 12,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.45,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 44, 0.5, 0),
			Size = UDim2.new(1, -54, 1, 0),
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
		local subContainer = U.canvas(sidebarScroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			GroupTransparency = 0,
			Size = UDim2.new(1, 0, 0, 0),
			ClipsDescendants = true,
			Visible = false,
		})
		subContainer.LayoutOrder = self.SidebarOrder
		tab.SubContainer = subContainer

		local treeLine = U.frame(subContainer, {
			BackgroundColor3 = Theme.Divider,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(17, 4),
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
				Position = UDim2.fromOffset(33, (index - 1) * 25),
				Size = UDim2.new(1, -33, 0, 25),
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
			-- Tree branch: horizontal connector plus the tall white active bar
			-- (reference "I-" marker) sitting on the vertical guide line.
			local connector = U.frame(subButton, {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Theme.Divider,
				BackgroundTransparency = 0.15,
				BorderSizePixel = 0,
				Position = UDim2.new(0, -16, 0.5, 0),
				Size = UDim2.fromOffset(9, 1),
				ZIndex = 1,
			})
			local tick = U.frame(subButton, {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Theme.Text,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, -16, 0.5, 0),
				Size = UDim2.fromOffset(2, 16),
				ZIndex = 2,
			})
			U.corner(tick, 1)

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
			sub.Connector = connector
			sub.Page = page

			local input = U.inputButton(subButton, function()
				if self.Window.SelectedTab == self then
					self:SetPage(page)
				else
					self.Window:SelectTab(self, page)
				end
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
			self.SubHeight = index * 25 + 4
			self.DefaultPage:SetActive(false)
			treeLine.Size = UDim2.new(0, 1, 0, math.max(0, index * 25 - 8))
			if self.Window.SelectedTab == self then
				subContainer.Visible = true
				U.tween(subContainer, TWEEN.Page, {
					Size = UDim2.new(1, 0, 0, self.SubHeight),
					GroupTransparency = 0,
				})
			else
				subContainer.Size = UDim2.new(1, 0, 0, 0)
			end

			if self.Window.SelectedTab == self and (self.CurrentPage == self.DefaultPage or self.CurrentPage == nil) then
				self:SetPage(page)
			else
				page:SetActive(false)
			end
			self.Window:RenderSubTabs(self)
			return page
		end

		function tab:SetPage(page, forceAnimate)
			if not page then
				return
			end
			Nerx:ClosePopup(true)
			local previous = self.CurrentPage
			local animate = forceAnimate == true or (previous ~= nil and previous ~= page)

			for _, other in ipairs(self.Pages) do
				if other ~= page and other ~= previous then
					other:SetActive(false)
				end
			end

			self.CurrentPage = page
			self.Window.CurrentPage = page
			page:SetActive(true)
			if animate then
				page:AnimateIn()
				if previous and previous ~= page then
					previous:AnimateOut()
				end
			end
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

	U.setGroupTransparency(root, config.StartHidden and 1 or 0)
	root.Visible = not config.StartHidden
	window.Visible = not config.StartHidden

	if not config.StartHidden then
		U.setGroupTransparency(root, 1)
		U.tween(root, TWEEN.Slow, { GroupTransparency = 0 })
	end

	table.insert(Nerx.Windows, window)
	if Nerx.Frosted and Nerx.Frosted.Enabled then
		task.defer(function()
			pcall(function()
				Nerx.Frosted:Apply()
			end)
		end)
	end
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
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
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
		Position = UDim2.new(0, 0, 0, 7),
		Size = UDim2.new(1, 0, 0, 26),
	})
	preview.Name = name

	local tags = U.frame(card, {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -10, 0, 40),
		Size = UDim2.fromOffset(140, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 5,
	})
	U.list(tags, 2, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top)
	preview.TagsRoot = tags

	local stage = U.frame(card, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 36),
		Size = UDim2.new(1, -16, 1, -52),
	})
	preview.Stage = stage

	-- Ground ellipse and height guide mirror the reference boards without adding model content.
	local guide = U.frame(stage, {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Theme.Muted,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.new(0.1, 0, 0.08, 0),
		Size = UDim2.new(0, 1, 0.64, 0),
	})
	preview.Guide = guide
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
		Position = UDim2.new(0.5, 0, 1, -28),
		Size = UDim2.fromOffset(212, 34),
	})
	preview.Ground = ground
	U.corner(ground, 16)
	U.stroke(ground, Theme.Muted, 0.45, 1)

	local placeholder = U.frame(stage, {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 1, -36),
		Size = UDim2.new(0.68, 0, 0.9, 0),
	})
	U.corner(placeholder, 10)
	local placeholderStroke = U.stroke(placeholder, Theme.Stroke, 0.25, 1)
	local placeholderIcon = U.icon(placeholder, config.PlaceholderIcon or "square-dashed-person-standing", 72, Theme.Muted, {
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

	function preview:AddViewport(viewportConfig)
		viewportConfig = viewportConfig or {}
		if preview.Viewport then
			return preview.Viewport, preview.World, preview.Camera
		end

		local viewport = U.new("ViewportFrame", {
			Name = "PreviewViewport",
			BackgroundColor3 = viewportConfig.BackgroundColor3 or Theme.Window,
			BackgroundTransparency = viewportConfig.BackgroundTransparency or 0,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromScale(1, 1),
			Ambient = viewportConfig.Ambient or Color3.fromRGB(178, 184, 194),
			LightColor = viewportConfig.LightColor or Color3.fromRGB(236, 241, 250),
			LightDirection = viewportConfig.LightDirection or Vector3.new(-0.45, -0.8, -0.4),
			ZIndex = 1,
		}, stage)

		local world = U.new("WorldModel", { Name = "PreviewWorld" }, viewport)
		local camera = U.new("Camera", {
			Name = "PreviewCamera",
			FieldOfView = viewportConfig.FieldOfView or 50,
		}, viewport)
		viewport.CurrentCamera = camera

		preview.Viewport = viewport
		preview.World = world
		preview.Camera = camera
		if preview.Placeholder then
			preview.Placeholder.Visible = false
		end
		if preview.Image then
			preview.Image.Visible = false
		end
		if preview.Guide then
			preview.Guide.Visible = false
		end
		if preview.Ground then
			preview.Ground.Visible = false
		end
		return viewport, world, camera
	end

	function preview:SetViewportVisible(value)
		if preview.Viewport then
			preview.Viewport.Visible = value ~= false
		end
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
				Size = UDim2.new(1, 0, 0, 15),
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
				stage.Size = UDim2.new(1, -16, 1, -(36 + chipTotal + 16))
			else
				preview.ChipContainer.Visible = false
				stage.Size = UDim2.new(1, -16, 1, -52)
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
-- Persistence, themes, configuration and binds
-- ---------------------------------------------------------------------------------------

do
	local WHITE = Color3.new(1, 1, 1)
	local BLACK = Color3.new(0, 0, 0)

	local function blend(a, b, t)
		t = math.clamp(t or 0, 0, 1)
		return Color3.new(
			a.R * (1 - t) + b.R * t,
			a.G * (1 - t) + b.G * t,
			a.B * (1 - t) + b.B * t
		)
	end

	local function luminance(color)
		return color.R * 0.2126 + color.G * 0.7152 + color.B * 0.0722
	end

	local function encodeColor(color)
		return { R = color.R, G = color.G, B = color.B }
	end

	local function decodeColor(value)
		if type(value) ~= "table" then
			return nil
		end
		return Color3.new(
			tonumber(value.R or value[1]) or 0,
			tonumber(value.G or value[2]) or 0,
			tonumber(value.B or value[3]) or 0
		)
	end

	local function colorKey(color)
		if typeof(color) ~= "Color3" then
			return nil
		end
		return string.format("%.4f,%.4f,%.4f", color.R, color.G, color.B)
	end

	local function encodeValue(value)
		if value == nil then
			return { __nil = true }
		end
		local kind = typeof(value)
		if kind == "Color3" then
			return { __color = encodeColor(value) }
		end
		if type(value) == "boolean" or type(value) == "number" or type(value) == "string" then
			return value
		end
		return tostring(value)
	end

	local function decodeValue(value)
		if type(value) == "table" then
			if value.__nil then
				return nil
			end
			if value.__color then
				return decodeColor(value.__color)
			end
		end
		return value
	end

	local function encodePalette(palette)
		local encoded = {}
		for key, value in pairs(palette or {}) do
			if typeof(value) == "Color3" then
				encoded[key] = encodeColor(value)
			end
		end
		return encoded
	end

	local function decodePalette(encoded)
		local palette = {}
		for key, value in pairs(encoded or {}) do
			local color = decodeColor(value)
			if color then
				palette[key] = color
			end
		end
		return palette
	end

	Nerx._Internal = {
		blend = blend,
		luminance = luminance,
		encodeColor = encodeColor,
		decodeColor = decodeColor,
		colorKey = colorKey,
		encodeValue = encodeValue,
		decodeValue = decodeValue,
		encodePalette = encodePalette,
		decodePalette = decodePalette,
		WHITE = WHITE,
		BLACK = BLACK,
	}

	-- Executor-backed JSON storage with an in-memory fallback.
	local fileWrite = type(writefile) == "function" and writefile or nil
	local fileRead = type(readfile) == "function" and readfile or nil
	local fileExists = type(isfile) == "function" and isfile or nil
	local folderExists = type(isfolder) == "function" and isfolder or nil
	local folderMake = type(makefolder) == "function" and makefolder or nil
	local fileDelete = type(delfile) == "function" and delfile or nil
	local clipboardWrite = type(setclipboard) == "function" and setclipboard or nil
	if not clipboardWrite and type(toclipboard) == "function" then
		clipboardWrite = toclipboard
	end

	local memoryFiles = {}
	local Storage = {
		Directory = "Nerx",
		Available = fileWrite ~= nil,
		Memory = memoryFiles,
	}

	function Storage:Path(name)
		return self.Directory .. "/" .. tostring(name)
	end

	function Storage:Ensure()
		if folderMake then
			pcall(folderMake, self.Directory)
		end
	end

	function Storage:Exists(name)
		local path = self:Path(name)
		if fileExists then
			local ok, exists = pcall(fileExists, path)
			if ok and exists then
				return true
			end
		end
		return memoryFiles[path] ~= nil
	end

	function Storage:Read(name)
		local path = self:Path(name)
		if fileRead then
			local ok, body = pcall(fileRead, path)
			if ok and type(body) == "string" then
				return body
			end
		end
		return memoryFiles[path]
	end

	function Storage:Write(name, body)
		local path = self:Path(name)
		self:Ensure()
		if fileWrite then
			local ok, result = pcall(fileWrite, path, body)
			if ok then
				memoryFiles[path] = body
				return true
			end
			return false, result
		end
		memoryFiles[path] = body
		return true
	end

	function Storage:Delete(name)
		local path = self:Path(name)
		pcall(function()
			if fileDelete then
				fileDelete(path)
			end
		end)
		memoryFiles[path] = nil
	end

	function Storage:Copy(text)
		if clipboardWrite then
			local ok = pcall(clipboardWrite, tostring(text))
			if ok then
				return true
			end
		end
		return false
	end

	function Storage:ReadJSON(name)
		local raw = self:Read(name)
		if type(raw) ~= "string" or raw == "" then
			return nil
		end
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(raw)
		end)
		if ok and type(decoded) == "table" then
			return decoded
		end
		return nil
	end

	function Storage:WriteJSON(name, data)
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode(data)
		end)
		if not ok or type(encoded) ~= "string" then
			return false
		end
		return self:Write(name, encoded)
	end

	function Storage:Encode(data)
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode(data)
		end)
		if ok then
			return encoded
		end
		return nil
	end

	function Storage:Decode(text)
		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(text)
		end)
		if ok then
			return decoded
		end
		return nil
	end

	function Storage:CopyPath(name)
		local path = self:Path(name or "")
		return self:Copy(path), path
	end

	Nerx.Storage = Storage

	-- -----------------------------------------------------------------------------------
	-- Themes
	-- -----------------------------------------------------------------------------------

	local presets = {
		{ Name = "Dark", Base = Color3.fromRGB(14, 14, 15), Panel = Color3.fromRGB(34, 34, 36), Accent = Color3.fromRGB(235, 235, 240) },
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

	local function buildPalette(definition)
		local base = definition.Base or Theme.Window
		local panel = definition.Panel or blend(base, WHITE, 0.08)
		local accent = definition.Accent or Theme.Accent
		local dark = luminance(base) < 0.48
		local palette = {}
		if dark then
			palette.Window = base
			palette.Sidebar = base
			palette.Main = blend(base, WHITE, 0.03)
			palette.Surface = blend(base, panel, 0.65)
			palette.SurfaceRaised = panel
			palette.SurfaceHover = blend(panel, WHITE, 0.07)
			palette.Selected = blend(panel, WHITE, 0.1)
			palette.ChipSelected = blend(panel, WHITE, 0.14)
			palette.Field = panel
			palette.FieldHover = palette.SurfaceHover
			palette.FieldDeep = blend(base, panel, 0.45)
			palette.FieldDisabled = blend(base, panel, 0.5)
			palette.Stroke = blend(panel, WHITE, 0.12)
			palette.StrokeSoft = blend(panel, WHITE, 0.04)
			palette.Divider = blend(base, WHITE, 0.07)
			palette.Track = blend(panel, WHITE, 0.2)
			palette.Button = panel
			palette.ButtonHover = palette.SurfaceHover
			palette.Primary = palette.ChipSelected
			palette.PrimaryHover = blend(panel, WHITE, 0.18)
			palette.PrimaryStroke = palette.Stroke
			palette.ToggleOff = panel
			palette.ToggleOffKnob = WHITE
			palette.ToggleDisabledTrack = blend(panel, WHITE, 0.35)
			palette.ToggleDisabledKnob = blend(panel, WHITE, 0.15)
			palette.Text = WHITE
			palette.Muted = blend(WHITE, base, 0.4)
			palette.Faint = blend(WHITE, base, 0.66)
			palette.Icon = palette.Text
			palette.Accent = accent
			palette.AccentDeep = blend(accent, WHITE, 0.35)
		else
			palette.Window = base
			palette.Sidebar = base
			palette.Main = base
			palette.Surface = panel
			palette.SurfaceRaised = blend(panel, BLACK, 0.02)
			palette.SurfaceHover = blend(panel, BLACK, 0.05)
			palette.Selected = blend(base, accent, 0.18)
			palette.ChipSelected = blend(base, accent, 0.24)
			palette.Field = blend(base, BLACK, 0.05)
			palette.FieldHover = blend(base, BLACK, 0.09)
			palette.FieldDeep = blend(base, BLACK, 0.02)
			palette.FieldDisabled = blend(base, BLACK, 0.04)
			palette.Stroke = blend(base, BLACK, 0.2)
			palette.StrokeSoft = blend(base, BLACK, 0.12)
			palette.Divider = blend(base, BLACK, 0.1)
			palette.Track = blend(base, BLACK, 0.22)
			palette.Button = palette.Field
			palette.ButtonHover = palette.FieldHover
			palette.Primary = palette.Button
			palette.PrimaryHover = palette.ButtonHover
			palette.PrimaryStroke = palette.Stroke
			palette.ToggleOff = blend(base, BLACK, 0.08)
			palette.ToggleOffKnob = blend(BLACK, base, 0.10)
			palette.ToggleDisabledTrack = blend(base, BLACK, 0.2)
			palette.ToggleDisabledKnob = blend(base, BLACK, 0.35)
			palette.Text = blend(BLACK, base, 0.1)
			palette.Muted = blend(BLACK, base, 0.45)
			palette.Faint = blend(BLACK, base, 0.62)
			palette.Icon = palette.Text
			palette.Accent = accent
			palette.AccentDeep = blend(accent, BLACK, 0.2)
		end
		return palette
	end

	local paletteOrder = {
		"Window", "Sidebar", "Main", "Surface", "SurfaceRaised", "SurfaceHover",
		"Selected", "ChipSelected", "Field", "FieldHover", "FieldDeep", "FieldDisabled",
		"Stroke", "StrokeSoft", "Divider", "Track", "Button", "ButtonHover",
		"Primary", "PrimaryHover", "PrimaryStroke", "ToggleOff", "ToggleOffKnob",
		"ToggleDisabledTrack", "ToggleDisabledKnob", "Text", "Muted", "Faint",
		"Icon", "Accent", "AccentDeep",
	}

	local function recolorGui(oldPalette, newPalette)
		local mapping = {}
		for _, key in ipairs(paletteOrder) do
			local oldColor = oldPalette[key]
			local newColor = newPalette[key]
			local oldKey = colorKey(oldColor)
			if oldKey and typeof(newColor) == "Color3" and mapping[oldKey] == nil then
				mapping[oldKey] = newColor
			end
		end
		if next(mapping) == nil then
			return
		end

		local colorProperties = {
			"BackgroundColor3", "TextColor3", "PlaceholderColor3", "ImageColor3",
			"ScrollBarImageColor3",
		}
		local function recolorObject(object)
			if object:IsA("GuiObject") then
				for _, property in ipairs(colorProperties) do
					local ok, current = pcall(function()
						return object[property]
					end)
					if ok and current then
						local replacement = mapping[colorKey(current)]
						if replacement then
							pcall(function()
								object[property] = replacement
							end)
						end
					end
				end
			elseif object:IsA("UIStroke") then
				local ok, current = pcall(function()
					return object.Color
				end)
				if ok and current then
					local replacement = mapping[colorKey(current)]
					if replacement then
						pcall(function()
							object.Color = replacement
						end)
					end
				end
			end
		end

		local roots = { screenGui }
		for _, currentWindow in ipairs(Nerx.Windows) do
			local windowRoot = currentWindow.Root
			if windowRoot and windowRoot.Parent then
				local underScreen = false
				pcall(function()
					underScreen = windowRoot:IsDescendantOf(screenGui)
				end)
				if not underScreen then
					roots[#roots + 1] = windowRoot
				end
			end
		end
		for _, root in ipairs(roots) do
			recolorObject(root)
			for _, object in ipairs(root:GetDescendants()) do
				recolorObject(object)
			end
		end
	end

	Nerx._Internal.buildPalette = buildPalette
	Nerx._Internal.recolorGui = recolorGui

	-- Palette remapping only follows colours that exist in the old palette, so
	-- chrome built from shared tones (account card, avatar well, sidebar) is
	-- re-applied by role after every theme switch.
	local function refreshChrome()
		for _, win in ipairs(Nerx.Windows) do
			if win.Account then
				win.Account.BackgroundColor3 = Theme.Surface
				local stroke = win.Account:FindFirstChildOfClass("UIStroke")
				if stroke then
					stroke.Color = Theme.Stroke
					stroke.Transparency = 0.65
				end
			end
			if win.AccountAvatar then
				win.AccountAvatar.BackgroundColor3 = Theme.Field
			end
			if win.AccountAvatarIcon then
				win.AccountAvatarIcon.TextColor3 = Theme.Muted
			end
			if win.AccountName then
				win.AccountName.TextColor3 = Theme.Text
			end
			if win.AccountTag then
				win.AccountTag.TextColor3 = Theme.Muted
			end
			if win.AccountChevron then
				win.AccountChevron.TextColor3 = Theme.Muted
			end
			if win.Sidebar then
				win.Sidebar.BackgroundColor3 = Theme.Sidebar
			end
		end
	end
	Nerx._Internal.refreshChrome = refreshChrome

	local themesStore = {
		version = 1,
		active = nil,
		custom = {},
	}

	local function saveThemesStore()
		Nerx.Storage:WriteJSON("themes.json", themesStore)
	end

	local function loadThemesStore()
		local raw = Nerx.Storage:ReadJSON("themes.json")
		if type(raw) ~= "table" then
			return
		end
		if type(raw.custom) == "table" then
			themesStore.custom = raw.custom
		end
		themesStore.active = raw.active
	end
	loadThemesStore()

	local themeListeners = {}

	local Themes = {
		Presets = presets,
		ActiveName = themesStore.active and themesStore.active.name or "Dark",
		OnChanged = themeListeners,
	}

	function Themes:CapturePalette()
		local palette = {}
		for key, value in pairs(Theme) do
			if typeof(value) == "Color3" then
				palette[key] = value
			end
		end
		return palette
	end

	function Themes:Signature()
		local data = self:SerializeActive()
		return Nerx.Storage:Encode(data) or tostring(self.ActiveName)
	end

	function Themes:SerializeActive()
		return {
			name = self.ActiveName,
			palette = encodePalette(self:CapturePalette()),
		}
	end

	function Themes:ApplyPalette(palette, name, options)
		options = options or {}
		if type(palette) ~= "table" then
			return false
		end
		local oldPalette = {}
		for key, value in pairs(Theme) do
			oldPalette[key] = value
		end
		for key, value in pairs(palette) do
			if typeof(value) == "Color3" then
				Theme[key] = value
			end
		end
		recolorGui(oldPalette, palette)
		refreshChrome()
		for _, callback in ipairs(Nerx.AccentListeners) do
			task.spawn(pcall, callback, Theme.Accent)
		end
		self.ActiveName = name or "Custom"
		if not options.noPersist then
			themesStore.active = {
				name = self.ActiveName,
				palette = encodePalette(self:CapturePalette()),
			}
			saveThemesStore()
		end
		for _, callback in ipairs(themeListeners) do
			task.spawn(pcall, callback, self.ActiveName)
		end
		return true
	end

	function Themes:ApplyPreset(name, options)
		name = tostring(name or "")
		for _, definition in ipairs(presets) do
			if definition.Name == name then
				return self:ApplyPalette(buildPalette(definition), name, options)
			end
		end
		local custom = themesStore.custom[name]
		if type(custom) == "table" and custom.palette then
			return self:ApplyPalette(decodePalette(custom.palette), name, options)
		end
		return false
	end

	function Themes:BuildPalette(definition)
		return buildPalette(definition)
	end

	function Themes:ApplyColors(base, panel, accent, name, options)
		return self:ApplyPalette(buildPalette({
			Base = base,
			Panel = panel,
			Accent = accent,
		}), name or "Custom", options)
	end

	function Themes:ApplySerialized(data, options)
		if type(data) ~= "table" then
			return false
		end
		local name = data.name or data.Name
		if data.palette then
			local palette = decodePalette(data.palette)
			if next(palette) then
				return self:ApplyPalette(palette, name, options)
			end
		end
		if name then
			return self:ApplyPreset(name, options)
		end
		return false
	end

	function Themes:SaveCustom(name)
		name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if name == "" then
			return false, "empty name"
		end
		local palette = encodePalette(self:CapturePalette())
		themesStore.custom[name] = {
			name = name,
			savedAt = os.time(),
			palette = palette,
		}
		themesStore.active = { name = name, palette = palette }
		self.ActiveName = name
		saveThemesStore()
		for _, callback in ipairs(themeListeners) do
			task.spawn(pcall, callback, name)
		end
		return true
	end

	function Themes:DeleteCustom(name)
		if not themesStore.custom[name] then
			return false
		end
		themesStore.custom[name] = nil
		if themesStore.active and themesStore.active.name == name then
			themesStore.active = nil
		end
		saveThemesStore()
		for _, callback in ipairs(themeListeners) do
			task.spawn(pcall, callback, self.ActiveName)
		end
		return true
	end

	function Themes:RenameCustom(oldName, newName)
		newName = tostring(newName or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if newName == "" or not themesStore.custom[oldName] or themesStore.custom[newName] then
			return false
		end
		local record = themesStore.custom[oldName]
		themesStore.custom[oldName] = nil
		record.name = newName
		themesStore.custom[newName] = record
		if themesStore.active and themesStore.active.name == oldName then
			themesStore.active.name = newName
		end
		if self.ActiveName == oldName then
			self.ActiveName = newName
		end
		saveThemesStore()
		for _, callback in ipairs(themeListeners) do
			task.spawn(pcall, callback, newName)
		end
		return true
	end

	function Themes:ListCustom(filterText)
		local filterLower = string.lower(tostring(filterText or ""))
		local list = {}
		for name, record in pairs(themesStore.custom) do
			if filterLower == "" or string.find(string.lower(name), filterLower, 1, true) then
				list[#list + 1] = record
			end
		end
		table.sort(list, function(a, b)
			return string.lower(a.name or "") < string.lower(b.name or "")
		end)
		return list
	end

	function Themes:GetCustom(name)
		return themesStore.custom[name]
	end

	function Themes:Export(name)
		name = name or self.ActiveName
		local custom = themesStore.custom[name]
		if custom then
			return Nerx.Storage:Encode(custom)
		end
		for _, definition in ipairs(presets) do
			if definition.Name == name then
				return Nerx.Storage:Encode({
					name = definition.Name,
					base = encodeColor(definition.Base),
					panel = encodeColor(definition.Panel),
					accent = encodeColor(definition.Accent),
					palette = encodePalette(buildPalette(definition)),
				})
			end
		end
		return Nerx.Storage:Encode(self:SerializeActive())
	end

	function Themes:Import(text, nameOverride)
		local decoded = Nerx.Storage:Decode(text)
		if type(decoded) ~= "table" then
			return false, "invalid JSON"
		end
		if type(decoded.custom) == "table" then
			for name, record in pairs(decoded.custom) do
				if type(record) == "table" and record.palette then
					record.name = name
					themesStore.custom[name] = record
				end
			end
			saveThemesStore()
			return true
		end
		local name = tostring(nameOverride or decoded.name or "Imported")
		local palette = decoded.palette
		if not palette and decoded.base and decoded.panel and decoded.accent then
			local built = buildPalette({
				Base = decodeColor(decoded.base),
				Panel = decodeColor(decoded.panel),
				Accent = decodeColor(decoded.accent),
			})
			palette = encodePalette(built)
		end
		if not palette then
			return false, "missing palette"
		end
		themesStore.custom[name] = {
			name = name,
			savedAt = os.time(),
			palette = palette,
		}
		saveThemesStore()
		return true
	end

	function Themes:LoadActive()
		if themesStore.active then
			return self:ApplySerialized(themesStore.active, { noPersist = true })
		end
		return false
	end

	Nerx.Themes = Themes
end

do
	local Internal = Nerx._Internal
	local encodeValue = Internal.encodeValue
	local decodeValue = Internal.decodeValue

	local BIND_FILE = "binds.json"
	local binds = {}
	local actions = {}
	local activeStates = {}
	local listeners = {}
	local bindCounter = 0
	local overlayEnabled = true

	local overlayRoot
	local overlayEntries = {}
	local overlayHeaderCard
	local overlayHeaderLabel
	local overlayHeaderIconHolder
	local overlayHeaderDots
	local overlayHeaderDotsIcon
	local overlayPanelWidth = 0
	local overlaySettingsAnchor
	local overlayShown = false
	local overlayToken = 0
	local overlayDragActive = false
	local overlayDragStart
	local overlayStartPosition
	local overlayIconImage
	local overlayIconFallback
	local hotkeyAssetLoaded = nil
	local hotkeyAssetProbeStarted = false
	local overlayUIScale
	local overlayScale = 100
	local hotkeyStyle = "values"
	local overlayRightAligned = false
	local hotkeyDynamicTitle = false
	local lastTriggeredName = nil
	local hotkeySettingsRoot
	local hotkeySettingsOpen = false
	local hotkeySettingsIgnoreClick = false
	local hotkeySettingsToken = 0
	local hotkeyDotsButton
	local hotkeySettingsStyleValue
	local hotkeySettingsScale
	local hotkeySettingsScaleValue
	local hotkeySettingsScaleTrack
	local hotkeySettingsScaleFill
	local hotkeySettingsScaleKnob
	local hotkeySettingsScaleDragging = false
	local hotkeySettingsSwitches = {}
	local hotkeySettingsOutsideConnection
	local hotkeySettingsDragChangedConnection
	local hotkeySettingsDragEndedConnection
	local hotkeyStyleMenuRoot
	local hotkeyStyleMenuOpen = false
	local hotkeyStyleMenuScale
	local hotkeyStyleMenuToken = 0
	local hotkeyStyleMenuOptions = {}
	local toggleHotkeyStyleMenu
	local positionHotkeyStyleMenu
	local closeHotkeyStyleMenu
	local positionHotkeySettings
	local closeHotkeySettings
	local toggleHotkeySettings

	local HOTKEY_ICON = "rbxassetid://121978468376124"
	local HOTKEY_ACCENT = Color3.fromRGB(96, 139, 255)
	-- OpenZen uses translucent black surfaces; over a blue scene they become
	-- the slate-blue pills shown in the reference screenshots.
	local HOTKEY_CARD = Color3.fromRGB(0, 0, 0)
	local HOTKEY_KEY_CARD = Color3.fromRGB(0, 0, 0)
	local HOTKEY_NAME_CARD = Color3.fromRGB(0, 0, 0)
	local HOTKEY_TEXT = Color3.fromRGB(255, 255, 255)
	local HOTKEY_MUTED = Color3.fromRGB(232, 235, 242)

	-- The HUD is a floating overlay, so it follows the menu's luminance: dark
	-- translucent cards on dark themes, light cards with dark text on light ones.
	local function applyHotkeyTheme()
		local main = Theme.Main
		local dark = (main.R * 0.2126 + main.G * 0.7152 + main.B * 0.0722) < 0.45
		if dark then
			HOTKEY_CARD = Color3.fromRGB(0, 0, 0)
			HOTKEY_KEY_CARD = Color3.fromRGB(0, 0, 0)
			HOTKEY_NAME_CARD = Color3.fromRGB(0, 0, 0)
			HOTKEY_TEXT = Color3.fromRGB(255, 255, 255)
			HOTKEY_MUTED = Color3.fromRGB(232, 235, 242)
		else
			HOTKEY_CARD = Theme.SurfaceRaised
			HOTKEY_KEY_CARD = Theme.SurfaceRaised
			HOTKEY_NAME_CARD = Theme.SurfaceRaised
			HOTKEY_TEXT = Theme.Text
			HOTKEY_MUTED = Theme.Muted
		end
	end
	applyHotkeyTheme()

	do
		local saved = Nerx.LayoutState and Nerx.LayoutState.hotkeysPanel
		if type(saved) == "table" then
			overlayScale = math.clamp(tonumber(saved.Scale) or 100, 75, 150)
			local savedStyle = saved.Style
			if savedStyle == "keys" or savedStyle == "values" or savedStyle == "switches" then
				hotkeyStyle = savedStyle
			elseif savedStyle == "default" then
				hotkeyStyle = "switches"
			end
			overlayRightAligned = saved.RightAligned == true
			hotkeyDynamicTitle = saved.DynamicTitle == true
		end
	end

	local function notifyChanged()
		for _, callback in ipairs(listeners) do
			task.spawn(pcall, callback)
		end
	end

	local function applyOverlayPosition()
		if not overlayRoot or not overlayRoot.Parent then
			return
		end
		overlayRoot.AnchorPoint = overlayRightAligned and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
		local saved = Nerx.LayoutState and Nerx.LayoutState.hotkeysPanel
		if type(saved) == "table" and saved.XScale ~= nil then
			overlayRoot.Position = UDim2.new(
				tonumber(saved.XScale) or 0,
				tonumber(saved.XOffset) or 16,
				tonumber(saved.YScale) or 0.5,
				tonumber(saved.YOffset) or 0
			)
		elseif overlayRightAligned then
			overlayRoot.Position = UDim2.new(1, -16, 0.5, 0)
		else
			overlayRoot.Position = UDim2.new(0, 16, 0.5, 0)
		end
	end

	local function saveOverlayPosition()
		if not overlayRoot then
			return
		end
		Nerx.LayoutState = Nerx.LayoutState or {}
		local state = Nerx.LayoutState.hotkeysPanel
		if type(state) ~= "table" then
			state = {}
		end
		local position = overlayRoot.Position
		state.XScale = position.X.Scale
		state.XOffset = position.X.Offset
		state.YScale = position.Y.Scale
		state.YOffset = position.Y.Offset
		state.Style = hotkeyStyle
		state.RightAligned = overlayRightAligned
		state.DynamicTitle = hotkeyDynamicTitle
		state.Scale = overlayScale
		Nerx.LayoutState.hotkeysPanel = state
	end

	local function refreshHotkeyIconState()
		if not overlayIconImage or not overlayIconImage.Parent then
			return
		end
		local loaded = hotkeyAssetLoaded == true
		overlayIconImage.Visible = loaded
		if overlayIconFallback and overlayIconFallback.Parent then
			overlayIconFallback.Visible = not loaded
		end
	end

	local function probeHotkeyAsset()
		if hotkeyAssetLoaded ~= nil or hotkeyAssetProbeStarted then
			return
		end
		hotkeyAssetProbeStarted = true
		task.spawn(function()
			local loaded = false
			local probe = Instance.new("ImageLabel")
			probe.Name = "NerxHotkeyIconProbe"
			probe.BackgroundTransparency = 1
			probe.Visible = false
			probe.Size = UDim2.fromOffset(15, 15)
			probe.Image = HOTKEY_ICON
			probe.Parent = screenGui
			pcall(function()
				local provider = game:GetService("ContentProvider")
				provider:PreloadAsync({ probe })
				loaded = probe.IsLoaded == true
			end)
			probe:Destroy()
			hotkeyAssetLoaded = loaded
			hotkeyAssetProbeStarted = false
			refreshHotkeyIconState()
		end)
	end
	local function ensureOverlayRoot()
		if overlayRoot and overlayRoot.Parent then
			return
		end
		overlayRoot = U.canvas(screenGui, {
			Name = "NerxBindOverlay",
			AnchorPoint = overlayRightAligned and Vector2.new(1, 0.5) or Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Position = overlayRightAligned and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 16, 0.5, 0),
			Size = UDim2.fromOffset(0, 0),
			GroupTransparency = 0,
			Visible = false,
			ZIndex = 800,
		})
		overlayUIScale = U.new("UIScale", {
			Scale = overlayScale / 100,
		}, overlayRoot)
		overlayShown = false
		overlayToken = 0
		overlayDragActive = false
		applyOverlayPosition()

		U.connect(UserInputService.InputChanged, function(input)
			if not overlayDragActive or not overlayRoot or not overlayRoot.Parent then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement
				and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local delta = input.Position - overlayDragStart
			overlayRoot.Position = UDim2.new(
				overlayStartPosition.X.Scale,
				overlayStartPosition.X.Offset + delta.X,
				overlayStartPosition.Y.Scale,
				overlayStartPosition.Y.Offset + delta.Y
			)
		end)
		U.connect(UserInputService.InputEnded, function(input)
			if not overlayDragActive then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				overlayDragActive = false
				saveOverlayPosition()
				if hotkeySettingsOpen and positionHotkeySettings then
					positionHotkeySettings()
				end
			end
		end)
	end

	local HOTKEY_ROW_HEIGHT = 22
	local HOTKEY_ROW_GAP = 3
	local HOTKEY_HEADER_HEIGHT = 24
	local HOTKEY_DOTS_SIZE = 16
	local HOTKEY_HEADER_TEXT_SIZE = 13
	local HOTKEY_NAME_TEXT_SIZE = 11
	local HOTKEY_KEY_TEXT_SIZE = 10
	local HOTKEY_CARD_TRANSPARENCY = 0.25
	local HOTKEY_KEY_TRANSPARENCY = 0.65
	local HOTKEY_NAME_TRANSPARENCY = 0.65
	local HOTKEY_ROW_STAGGER = 0.035
	local HOTKEY_IN = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local HOTKEY_OUT = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
	local HOTKEY_SIZE = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local HOTKEY_ROW_MOVE = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	local renderHotkeyScale

	local function hotkeyPill(parent, width, height, background, transparency)
		local card = U.frame(parent, {
			BackgroundColor3 = background or HOTKEY_CARD,
			BackgroundTransparency = transparency or HOTKEY_CARD_TRANSPARENCY,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(width, height),
			ZIndex = 2,
		})
		U.corner(card, 5)
		return card
	end

	local function hotkeyText(parent, text, size, width, height, transparency)
		return U.label(parent, {
			Text = text,
			Font = Fonts.Bold,
			TextSize = size,
			TextColor3 = HOTKEY_TEXT,
			TextTransparency = transparency or 0.05,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0.78,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Size = UDim2.fromOffset(width, height),
			ZIndex = 4,
		})
	end

	-- Returns the component flavour, its live state and the value the bind sets.
	local function bindVisualState(bind)
		local kind = "action"
		local on = activeStates[bind.Id] == true
		local value = nil
		for _, target in ipairs(bind.Actions or {}) do
			if target.Type == "Component" then
				local component = Nerx.ComponentsById[target.Target]
				if component then
					if component.Kind == "toggle" then
						kind = "toggle"
						if component.GetValue then
							local ok, current = pcall(component.GetValue, component)
							if ok then
								on = current == true
							end
						end
						break
					elseif component.Kind == "slider" then
						kind = "slider"
						value = target.Value
						break
					elseif component.Kind == "dropdown" then
						kind = "dropdown"
						value = target.Value
						break
					end
				end
			end
		end
		return kind, on, value
	end

	-- `default` renders the button/switch style from the reference; `keys`
	-- always renders the bound key text so every row visibly changes.
	local function keyDisplayFor(bind, style)
		local kind, on, value = bindVisualState(bind)
		if style == "keys" then
			return "text", tostring(bind.Key or ""), nil, false
		elseif style == "switches" then
			return "icon", nil, on and "toggle-right" or "toggle-left", on
		end
		if kind == "toggle" then
			return "text", on and "ON" or "OFF", nil, on
		elseif kind == "slider" then
			return "text", tostring(value == nil and "-" or value), nil, false
		elseif kind == "dropdown" then
			return "text", tostring(value == nil and "-" or value), nil, false
		end
		return "text", tostring(bind.Key or ""), nil, false
	end

	local function syncHotkeySettings()
		local saved = Nerx.LayoutState and Nerx.LayoutState.hotkeysPanel
		if type(saved) ~= "table" then
			return
		end
		overlayScale = math.clamp(tonumber(saved.Scale) or 100, 75, 150)
		local savedStyle = saved.Style
			if savedStyle == "keys" or savedStyle == "values" or savedStyle == "switches" then
				hotkeyStyle = savedStyle
			elseif savedStyle == "default" then
				hotkeyStyle = "switches"
			end
		overlayRightAligned = saved.RightAligned == true
		hotkeyDynamicTitle = saved.DynamicTitle == true
		if overlayUIScale then
			overlayUIScale.Scale = overlayScale / 100
		end
	end

	local function createOverlayEntry(data)
		local startX = data.X + (overlayRightAligned and 20 or -20)
		local row = U.canvas(overlayRoot, {
			Name = "NerxHotkeyRow",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(startX, data.Y),
			Size = UDim2.fromOffset(data.RowWidth, 0),
			ClipsDescendants = true,
			GroupTransparency = 1,
			ZIndex = 1,
		})
		local keyCard = hotkeyPill(row, data.KeyBoxWidth, HOTKEY_ROW_HEIGHT, HOTKEY_KEY_CARD, HOTKEY_KEY_TRANSPARENCY)
		keyCard.Position = UDim2.fromOffset(data.KeyX, 0)
		local keyLabel = hotkeyText(keyCard, "", HOTKEY_KEY_TEXT_SIZE, data.KeyBoxWidth - 6, HOTKEY_ROW_HEIGHT, 0.12)
		keyLabel.Position = UDim2.fromOffset(3, 0)
		keyLabel.TextXAlignment = Enum.TextXAlignment.Center
		keyLabel.TextTruncate = Enum.TextTruncate.AtEnd
		keyLabel.Visible = false
		local keyIcon = U.icon(keyCard, data.KeyIcon or "toggle-left", 13, HOTKEY_TEXT, {
			Position = UDim2.fromOffset(math.floor((data.KeyBoxWidth - 13) * 0.5), math.floor((HOTKEY_ROW_HEIGHT - 13) * 0.5)),
			Size = UDim2.fromOffset(13, 13),
			TextTransparency = data.KeyTransparency or 0.02,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0.78,
			ZIndex = 4,
		})
		keyIcon.Visible = data.KeyKind == "icon"
		local nameCard = hotkeyPill(row, data.NameBoxWidth, HOTKEY_ROW_HEIGHT, HOTKEY_NAME_CARD, HOTKEY_NAME_TRANSPARENCY)
		nameCard.Position = UDim2.fromOffset(data.NameX, 0)
		local nameLabel = hotkeyText(nameCard, data.NameText, HOTKEY_NAME_TEXT_SIZE, data.NameBoxWidth - 10, HOTKEY_ROW_HEIGHT, 0.02)
		nameLabel.Position = UDim2.fromOffset(5, 0)
		nameLabel.TextXAlignment = overlayRightAligned and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		return {
			Id = data.Id,
			Frame = row,
			KeyCard = keyCard,
			KeyLabel = keyLabel,
			KeyIcon = keyIcon,
			NameCard = nameCard,
			NameLabel = nameLabel,
			KeyKind = data.KeyKind,
			KeyIconText = data.KeyIcon,
			TumblerOn = data.TumblerOn,
			Token = 0,
			Removing = false,
			Data = data,
		}
	end

	local function applyOverlayEntry(entry, data, animate, skipPosition, skipSize)
		local row = entry.Frame
		local keyCard = entry.KeyCard
		local keyLabel = entry.KeyLabel
		local keyIcon = entry.KeyIcon
		local nameCard = entry.NameCard
		local nameLabel = entry.NameLabel

		if data.KeyKind == "icon" then
			keyLabel.Visible = false
			keyIcon.Visible = true
			local changed = entry.KeyKind ~= "icon" or entry.KeyIconText ~= data.KeyIcon
			local toggled = entry.KeyKind == "icon" and entry.TumblerOn ~= data.TumblerOn
			keyIcon.Text = data.KeyIcon
			keyIcon.Position = UDim2.fromOffset(math.floor((data.KeyBoxWidth - 13) * 0.5), math.floor((HOTKEY_ROW_HEIGHT - 13) * 0.5))
			keyIcon.Size = UDim2.fromOffset(13, 13)
			if changed or toggled then
				keyIcon.TextTransparency = changed and 1 or 0.85
				U.tween(keyIcon, TWEEN.Popup, { TextTransparency = data.KeyTransparency or 0.02 })
			else
				U.tween(keyIcon, TWEEN.Fast, { TextTransparency = data.KeyTransparency or 0.02 })
			end
		else
			keyIcon.Visible = false
			keyLabel.Visible = true
			local keyText = tostring(data.KeyText or "")
			keyLabel.Text = keyText
			keyLabel.Position = UDim2.fromOffset(3, 0)
			keyLabel.Size = UDim2.fromOffset(math.max(4, data.KeyBoxWidth - 6), HOTKEY_ROW_HEIGHT)
			local maxKeyTextWidth = math.max(4, data.KeyBoxWidth - 6)
			local measuredKey = U.measure(keyText, HOTKEY_KEY_TEXT_SIZE, Fonts.Bold).X
			keyLabel.TextSize = measuredKey > maxKeyTextWidth
				and math.max(7, HOTKEY_KEY_TEXT_SIZE * maxKeyTextWidth / measuredKey)
				or HOTKEY_KEY_TEXT_SIZE
			if entry.KeyKind ~= "text" then
				keyLabel.TextTransparency = 1
				U.tween(keyLabel, TWEEN.Popup, { TextTransparency = data.KeyTransparency or 0.12 })
			else
				U.tween(keyLabel, TWEEN.Fast, { TextTransparency = data.KeyTransparency or 0.12 })
			end
		end

		local props = {}
		if not skipSize then
			props.Size = UDim2.fromOffset(data.RowWidth, HOTKEY_ROW_HEIGHT)
		end
		if not skipPosition then
			props.Position = UDim2.fromOffset(data.X, data.Y)
		end
		if props.Size or props.Position then
			U.tween(row, props.Position and HOTKEY_ROW_MOVE or HOTKEY_SIZE, props)
		end
		U.tween(keyCard, HOTKEY_SIZE, {
			Size = UDim2.fromOffset(data.KeyBoxWidth, HOTKEY_ROW_HEIGHT),
			Position = UDim2.fromOffset(data.KeyX, 0),
		})
		U.tween(nameCard, HOTKEY_SIZE, {
			Size = UDim2.fromOffset(data.NameBoxWidth, HOTKEY_ROW_HEIGHT),
			Position = UDim2.fromOffset(data.NameX, 0),
		})
		nameLabel.Text = data.NameText
		nameLabel.Position = UDim2.fromOffset(5, 0)
		nameLabel.Size = UDim2.fromOffset(math.max(8, data.NameBoxWidth - 10), HOTKEY_ROW_HEIGHT)
		nameLabel.TextXAlignment = overlayRightAligned and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
		entry.KeyKind = data.KeyKind
		entry.KeyIconText = data.KeyIcon
		entry.TumblerOn = data.TumblerOn
		entry.Data = data
	end

	local function removeOverlayEntry(entry)
		if entry.Removing then
			return
		end
		entry.Removing = true
		entry.Token = entry.Token + 1
		local token = entry.Token
		local slide = overlayRightAligned and 40 or -40
		local position = entry.Frame.Position
		U.tween(entry.Frame, HOTKEY_OUT, {
			GroupTransparency = 1,
			Size = UDim2.fromOffset(entry.Frame.Size.X.Offset, 0),
			Position = UDim2.new(position.X.Scale, position.X.Offset + slide, position.Y.Scale, position.Y.Offset),
		})
		task.delay(0.22, function()
			if entry.Frame and entry.Frame.Parent and entry.Token == token and entry.Removing then
				entry.Frame:Destroy()
				if overlayEntries[entry.Id] == entry then
					overlayEntries[entry.Id] = nil
				end
			end
		end)
	end

	local function updateOverlayHeader(panelWidth, headerText, iconX, titleX, titleWidth, dotsX, animate)
		if not overlayHeaderCard or not overlayHeaderCard.Parent then
			return
		end
		local headerLabel = overlayHeaderLabel
		local headerIcon = overlayHeaderIconHolder
		local dots = overlayHeaderDots
		if headerLabel.Text ~= headerText then
			headerLabel.Text = headerText
			headerLabel.TextTransparency = 1
			U.tween(headerLabel, TWEEN.Popup, { TextTransparency = 0.02 })
		else
			U.tween(headerLabel, TWEEN.Fast, { TextTransparency = 0.02 })
		end
		local info = HOTKEY_SIZE
		U.tween(overlayHeaderCard, info, { Size = UDim2.fromOffset(panelWidth, HOTKEY_HEADER_HEIGHT) })
		U.tween(headerIcon, info, { Position = UDim2.fromOffset(iconX, math.floor((HOTKEY_HEADER_HEIGHT - 15) * 0.5)) })
		U.tween(headerLabel, info, {
			Position = UDim2.fromOffset(titleX, 0),
			Size = UDim2.fromOffset(titleWidth, HOTKEY_HEADER_HEIGHT),
		})
		headerLabel.TextXAlignment = overlayRightAligned and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
		U.tween(dots, info, { Position = UDim2.fromOffset(dotsX, math.floor((HOTKEY_HEADER_HEIGHT - HOTKEY_DOTS_SIZE) * 0.5)) })
		if hotkeySettingsOpen and positionHotkeySettings then
			task.defer(positionHotkeySettings)
		end
	end

	local function createOverlayHeader(panelWidth, headerText, iconX, titleX, titleWidth, dotsX)
		local headerCard = hotkeyPill(overlayRoot, panelWidth, HOTKEY_HEADER_HEIGHT)
		headerCard.Position = UDim2.fromOffset(overlayRightAligned and 14 or -14, 0)
		U.tween(headerCard, TWEEN.Popup, { Position = UDim2.fromOffset(0, 0) })
		overlayHeaderCard = headerCard
		overlayIconImage = nil
		overlayIconFallback = nil
		hotkeyDotsButton = nil

		local iconHolder = U.frame(headerCard, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(iconX, math.floor((HOTKEY_HEADER_HEIGHT - 15) * 0.5)),
			Size = UDim2.fromOffset(15, 15),
			ZIndex = 4,
		})
		overlayHeaderIconHolder = iconHolder
		overlayIconFallback = U.icon(iconHolder, "rectangle-list", 13, HOTKEY_TEXT, {
			Size = UDim2.fromScale(1, 1),
			TextTransparency = hotkeyAssetLoaded == true and 1 or 0,
			ZIndex = 4,
		})
		overlayIconImage = U.new("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Image = HOTKEY_ICON,
			ImageColor3 = HOTKEY_TEXT,
			Visible = hotkeyAssetLoaded == true,
			ZIndex = 5,
		}, iconHolder)
		if hotkeyAssetLoaded == nil then
			probeHotkeyAsset()
		end

		local headerLabel = hotkeyText(headerCard, headerText, HOTKEY_HEADER_TEXT_SIZE, titleWidth, HOTKEY_HEADER_HEIGHT, 0.02)
		headerLabel.Position = UDim2.fromOffset(titleX, 0)
		headerLabel.TextXAlignment = overlayRightAligned and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
		headerLabel.TextTruncate = Enum.TextTruncate.AtEnd
		overlayHeaderLabel = headerLabel

		-- The drag hitbox is created before the dots so the dots' ImageButton
		-- stays on top and remains clickable.
		local dragInput = U.inputButton(headerCard)
		dragInput.ZIndex = 3
		U.connect(dragInput.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					overlayDragActive = true
					overlayDragStart = input.Position
					overlayStartPosition = overlayRoot.Position
			end
		end)

		local dots = U.frame(headerCard, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(dotsX, math.floor((HOTKEY_HEADER_HEIGHT - HOTKEY_DOTS_SIZE) * 0.5)),
			Size = UDim2.fromOffset(HOTKEY_DOTS_SIZE, HOTKEY_DOTS_SIZE),
			ZIndex = 6,
		})
		overlayHeaderDots = dots
		hotkeyDotsButton = dots
		local dotsIcon = U.icon(dots, "three-dots-horizontal", 12, HOTKEY_MUTED, {
			Size = UDim2.fromScale(1, 1),
			TextTransparency = hotkeySettingsOpen and 0.02 or 0.25,
			ZIndex = 6,
		})
		overlayHeaderDotsIcon = dotsIcon
		local dotsInput = U.inputButton(dots, function()
			if toggleHotkeySettings then
				toggleHotkeySettings(dots)
			end
		end)
		dotsInput.ZIndex = 10
		U.pressFx(dotsInput, dots, 0.9)
		U.connect(dotsInput.MouseEnter, function()
			U.tween(dotsIcon, TWEEN.Fast, { TextTransparency = 0.02 })
		end)
		U.connect(dotsInput.MouseLeave, function()
			U.tween(dotsIcon, TWEEN.Fast, { TextTransparency = hotkeySettingsOpen and 0.02 or 0.25 })
		end)
	end

	-- Mirrors Margele/OpenZen KeyBindsHud. Key boxes share one column width;
	-- each name pill is sized to its own text, producing the reference
	-- staircase. Rows are reconciled by bind id so active/inactive rows glide
	-- in and out instead of rebuilding the whole stack.
	local function buildOverlay()
		ensureOverlayRoot()
		syncHotkeySettings()

		local visibleBinds = {}
		if overlayEnabled then
			for _, bind in ipairs(binds) do
				if bind.Enabled ~= false
					and bind.Trigger ~= "Condition"
					and bind.Key
					and bind.Key ~= "" then
					local mode = bind.Overlay or "Always"
					if mode == "Always" or (mode == "While Active" and activeStates[bind.Id]) then
						visibleBinds[#visibleBinds + 1] = bind
					end
				end
			end
		end

		if #visibleBinds == 0 then
			if hotkeySettingsOpen and closeHotkeySettings and overlaySettingsAnchor == hotkeyDotsButton then
				closeHotkeySettings()
			end
			if overlayShown then
				overlayShown = false
				overlayToken = overlayToken + 1
				local token = overlayToken
				U.tween(overlayRoot, HOTKEY_OUT, { GroupTransparency = 1 })
				task.delay(0.18, function()
					if token == overlayToken and not overlayShown then
						if overlayRoot and overlayRoot.Parent then
							overlayRoot.Visible = false
						end
						for _, entry in pairs(overlayEntries) do
							if entry.Frame then
								entry.Frame:Destroy()
							end
						end
						table.clear(overlayEntries)
						if overlayHeaderCard then
							overlayHeaderCard:Destroy()
							overlayHeaderCard = nil
							-- Children are destroyed with the header.
							overlayHeaderLabel = nil
							overlayHeaderIconHolder = nil
							overlayHeaderDots = nil
							overlayHeaderDotsIcon = nil
							hotkeyDotsButton = nil
							overlayIconImage = nil
							overlayIconFallback = nil
						end
					end
				end)
			end
			return
		end

		local headerText = "Hotkeys"
		if hotkeyDynamicTitle and lastTriggeredName and lastTriggeredName ~= "" then
			headerText = "Hotkeys · " .. tostring(lastTriggeredName)
		end

		local rowData = {}
		for order, bind in ipairs(visibleBinds) do
			local keyKind, keyText, keyIcon, tumblerOn = keyDisplayFor(bind, hotkeyStyle)
			local nameText = tostring(bind.Name or "Bind")
			local nameWidth = U.measure(nameText, HOTKEY_NAME_TEXT_SIZE, Fonts.Bold).X
			rowData[#rowData + 1] = {
				Id = bind.Id,
				Order = order,
				NameText = nameText,
				KeyKind = keyKind,
				KeyText = keyText,
				KeyIcon = keyIcon,
				KeyTransparency = keyKind == "icon" and (tumblerOn and 0.02 or 0.4) or 0.12,
				TumblerOn = tumblerOn,
				NameWidth = math.clamp(nameWidth, 0, 220),
			}
		end

		table.sort(rowData, function(a, b)
			if math.abs(a.NameWidth - b.NameWidth) > 0.01 then
				return a.NameWidth > b.NameWidth
			end
			return a.Order < b.Order
		end)

		local keyBoxWidth = HOTKEY_ROW_HEIGHT
		local maxRowWidth = 0
		for _, data in ipairs(rowData) do
			data.NameBoxWidth = math.max(36, data.NameWidth + 10)
			data.RowWidth = keyBoxWidth + HOTKEY_ROW_GAP + data.NameBoxWidth
			maxRowWidth = math.max(maxRowWidth, data.RowWidth)
		end

		local measuredTitle = U.measure(headerText, HOTKEY_HEADER_TEXT_SIZE, Fonts.Bold).X
		local titleTextWidth = math.clamp(measuredTitle, 24, 210)
		local panelWidth = math.max(maxRowWidth, 10 + 15 + 5 + titleTextWidth + 6 + HOTKEY_DOTS_SIZE + 10)
		local totalHeight = HOTKEY_HEADER_HEIGHT + #visibleBinds * (HOTKEY_ROW_HEIGHT + HOTKEY_ROW_GAP)

		local iconX
		local titleX
		local dotsX
		if overlayRightAligned then
			iconX = panelWidth - 10 - 15
			titleX = iconX - 5 - titleTextWidth
			dotsX = titleX - 6 - HOTKEY_DOTS_SIZE
		else
			iconX = 10
			titleX = 10 + 15 + 5
			dotsX = titleX + titleTextWidth + 6
		end

		if not overlayHeaderCard or not overlayHeaderCard.Parent then
			createOverlayHeader(panelWidth, headerText, iconX, titleX, titleTextWidth, dotsX)
		else
			updateOverlayHeader(panelWidth, headerText, iconX, titleX, titleTextWidth, dotsX)
		end

		local desired = {}
		for index, data in ipairs(rowData) do
			data.KeyBoxWidth = keyBoxWidth
			data.Y = HOTKEY_HEADER_HEIGHT + HOTKEY_ROW_GAP + (index - 1) * (HOTKEY_ROW_HEIGHT + HOTKEY_ROW_GAP)
			data.X = overlayRightAligned and (panelWidth - data.RowWidth) or 0
			data.KeyX = overlayRightAligned and (data.RowWidth - keyBoxWidth) or 0
			data.NameX = overlayRightAligned
				and (data.KeyX - HOTKEY_ROW_GAP - data.NameBoxWidth)
				or (keyBoxWidth + HOTKEY_ROW_GAP)
			desired[data.Id] = data
		end

		for id, entry in pairs(overlayEntries) do
			if not desired[id] and not entry.Removing then
				removeOverlayEntry(entry)
			end
		end

		local entering = 0
		for _, data in ipairs(rowData) do
			local entry = overlayEntries[data.Id]
			if entry and not entry.Removing then
				entry.Token = entry.Token + 1
				U.tween(entry.Frame, HOTKEY_IN, { GroupTransparency = 0 })
				applyOverlayEntry(entry, data, true, false, false)
			else
				if entry and entry.Frame then
					entry.Frame:Destroy()
				end
				entry = createOverlayEntry(data)
				overlayEntries[data.Id] = entry
				applyOverlayEntry(entry, data, false, true, true)
				entry.Token = entry.Token + 1
				local token = entry.Token
				local delay = math.min(0.3, entering * HOTKEY_ROW_STAGGER)
				entering = entering + 1
				task.delay(delay, function()
					if entry.Frame and entry.Frame.Parent and entry.Token == token and not entry.Removing then
						U.tween(entry.Frame, HOTKEY_IN, {
							GroupTransparency = 0,
							Size = UDim2.fromOffset(data.RowWidth, HOTKEY_ROW_HEIGHT),
							Position = UDim2.fromOffset(data.X, data.Y),
						})
					end
				end)
			end
		end

		overlayPanelWidth = panelWidth
		U.tween(overlayRoot, HOTKEY_SIZE, { Size = UDim2.fromOffset(panelWidth, totalHeight) })
		applyOverlayPosition()

		if not overlayShown then
			overlayShown = true
			overlayToken = overlayToken + 1
			overlayRoot.Visible = true
			U.setGroupTransparency(overlayRoot, 1)
			U.tween(overlayRoot, HOTKEY_IN, { GroupTransparency = 0 })
		else
			overlayToken = overlayToken + 1
			overlayRoot.Visible = true
			if (overlayRoot.GroupTransparency or 0) > 0 then
				U.tween(overlayRoot, HOTKEY_IN, { GroupTransparency = 0 })
			end
		end

		if hotkeySettingsOpen and positionHotkeySettings then
			task.defer(positionHotkeySettings)
		end
	end

	local function normalizeHotkeyStyle(value)
		if value == "keys" or value == "values" or value == "switches" then
			return value
		elseif value == "default" then
			return "switches"
		end
		return "values"
	end

	local function hotkeyStyleText(style)
		if style == "keys" then
			return "Keys"
		elseif style == "switches" then
			return "Switches"
		end
		return "Values"
	end

	local function setHotkeyStyle(value)
		hotkeyStyle = normalizeHotkeyStyle(value)
		saveOverlayPosition()
		buildOverlay()
		if hotkeySettingsStyleValue then
			hotkeySettingsStyleValue.Text = hotkeyStyleText(hotkeyStyle)
		end
		if hotkeySettingsOpen and positionHotkeySettings then
			task.defer(positionHotkeySettings)
		end
	end

	local function setHotkeyRightAligned(value)
		overlayRightAligned = value == true
		if overlayRoot then
			local previous = overlayRoot.Position
			if overlayRightAligned then
				overlayRoot.AnchorPoint = Vector2.new(1, 0.5)
				overlayRoot.Position = UDim2.new(1, -16, previous.Y.Scale, previous.Y.Offset)
			else
				overlayRoot.AnchorPoint = Vector2.new(0, 0.5)
				overlayRoot.Position = UDim2.new(0, 16, previous.Y.Scale, previous.Y.Offset)
			end
		end
		saveOverlayPosition()
		buildOverlay()
		if hotkeySettingsOpen and positionHotkeySettings then
			task.defer(positionHotkeySettings)
		end
	end

	local function setHotkeyDynamicTitle(value)
		hotkeyDynamicTitle = value == true
		saveOverlayPosition()
		buildOverlay()
		if hotkeySettingsOpen and positionHotkeySettings then
			task.defer(positionHotkeySettings)
		end
	end

	renderHotkeyScale = function()
		if hotkeySettingsScaleValue then
			hotkeySettingsScaleValue.Text = tostring(math.floor(overlayScale)) .. "%"
		end
		if hotkeySettingsScaleFill and hotkeySettingsScaleKnob then
			local ratio = math.clamp((overlayScale - 75) / 75, 0, 1)
			hotkeySettingsScaleFill.Size = UDim2.new(ratio, 0, 1, 0)
			hotkeySettingsScaleKnob.Position = UDim2.new(ratio, 5 * (1 - 2 * ratio), 0.5, 0)
		end
	end

	local function setHotkeyScale(value)
		overlayScale = math.clamp(tonumber(value) or 100, 75, 150)
		if overlayUIScale then
			overlayUIScale.Scale = overlayScale / 100
		end
		saveOverlayPosition()
		renderHotkeyScale()
		if hotkeySettingsOpen and positionHotkeySettings then
			task.defer(positionHotkeySettings)
		end
	end

	local SETTINGS_WIDTH = 212
	local SETTINGS_HEIGHT = 138

	local function ensureHotkeySettings()
		if hotkeySettingsRoot and hotkeySettingsRoot.Parent then
			return
		end
		hotkeySettingsRoot = U.canvas(screenGui, {
			Name = "NerxHotkeySettings",
			BackgroundColor3 = Theme.SurfaceRaised,
			BackgroundTransparency = 0.02,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(SETTINGS_WIDTH, SETTINGS_HEIGHT),
			Visible = false,
			ZIndex = 1000,
			GroupTransparency = 0,
		})
		-- Corners, stroke and shadow belong to the popup CanvasGroup itself, the
		-- same construction as U.popup / the built-in row three-dot menu.
		U.corner(hotkeySettingsRoot, 8)
		U.stroke(hotkeySettingsRoot, Theme.Stroke, 0.45, 1)
		U.shadow(hotkeySettingsRoot, "soft")
		hotkeySettingsScale = U.new("UIScale", {
			Scale = 1,
		}, hotkeySettingsRoot)

		local function menuRow(y, height)
			local row = U.frame(hotkeySettingsRoot, {
				BackgroundColor3 = Theme.White,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(5, y),
				Size = UDim2.new(1, -10, 0, height),
				ZIndex = 1003,
			})
			U.corner(row, 5)
			return row
		end

		local function rowHover(input, row, labels, chevron)
			U.connect(input.MouseEnter, function()
				U.tween(row, TWEEN.Fast, { BackgroundTransparency = 0.94 })
				for _, label in ipairs(labels) do
					U.tween(label, TWEEN.Fast, { TextTransparency = 0 })
				end
				if chevron then
					U.tween(chevron, TWEEN.Fast, { TextTransparency = 0.1 })
				end
			end)
			U.connect(input.MouseLeave, function()
				U.tween(row, TWEEN.Fast, { BackgroundTransparency = 1 })
				for _, label in ipairs(labels) do
					U.tween(label, TWEEN.Fast, { TextTransparency = 0.2 })
				end
				if chevron then
					U.tween(chevron, TWEEN.Fast, { TextTransparency = 0.4 })
				end
			end)
		end

		local styleRow = menuRow(5, 28)
		local styleLabel = hotkeyText(styleRow, "Display Style", 11, 90, 28, 0.2)
		styleLabel.Position = UDim2.fromOffset(9, 0)
		styleLabel.TextColor3 = Theme.Muted
		hotkeySettingsStyleValue = hotkeyText(styleRow, hotkeyStyleText(hotkeyStyle), 10.5, 72, 28, 0.2)
		hotkeySettingsStyleValue.Position = UDim2.new(1, -20, 0, 0)
		hotkeySettingsStyleValue.Size = UDim2.fromOffset(72, 28)
		hotkeySettingsStyleValue.TextColor3 = Theme.Muted
		hotkeySettingsStyleValue.TextXAlignment = Enum.TextXAlignment.Right
		local styleChevron = U.icon(styleRow, "chevron-large-right", 9, Theme.Muted, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(10, 10),
			TextTransparency = 0.4,
			ZIndex = 1004,
		})
		local styleInput = U.inputButton(styleRow, function()
			if toggleHotkeyStyleMenu then
				toggleHotkeyStyleMenu()
			end
		end)
		styleInput.ZIndex = 1005
		rowHover(styleInput, styleRow, { styleLabel, hotkeySettingsStyleValue }, styleChevron)

		local sizeRow = menuRow(33, 44)
		local sizeLabel = hotkeyText(sizeRow, "Size", 11, 90, 20, 0.2)
		sizeLabel.Position = UDim2.fromOffset(9, 0)
		sizeLabel.TextColor3 = Theme.Muted
		hotkeySettingsScaleValue = hotkeyText(sizeRow, "100%", 10, 60, 20, 0.2)
		hotkeySettingsScaleValue.Position = UDim2.new(1, -9, 0, 0)
		hotkeySettingsScaleValue.Size = UDim2.fromOffset(60, 20)
		hotkeySettingsScaleValue.TextColor3 = Theme.Muted
		hotkeySettingsScaleValue.TextXAlignment = Enum.TextXAlignment.Right

		local rail = U.frame(sizeRow, {
			BackgroundColor3 = Theme.Track,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(9, 27),
			Size = UDim2.new(1, -18, 0, 3),
			ZIndex = 1003,
		})
		U.corner(rail, 2)
		hotkeySettingsScaleFill = U.frame(rail, {
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			ZIndex = 1004,
		})
		U.corner(hotkeySettingsScaleFill, 2)
		hotkeySettingsScaleKnob = U.frame(rail, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(10, 10),
			ZIndex = 1005,
		})
		U.corner(hotkeySettingsScaleKnob, 5)
		local scaleTrack = U.frame(sizeRow, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(9, 17),
			Size = UDim2.new(1, -18, 0, 20),
			ZIndex = 1006,
		})
		hotkeySettingsScaleTrack = scaleTrack
		local scaleInput = U.inputButton(scaleTrack, nil)
		local function updateScaleFromInput(input)
			local position = scaleTrack.AbsolutePosition
			local size = scaleTrack.AbsoluteSize
			if size.X <= 0 then
				return
			end
			local ratio = math.clamp((input.Position.X - position.X) / size.X, 0, 1)
			setHotkeyScale(75 + ratio * 75)
		end
		U.connect(scaleInput.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				hotkeySettingsScaleDragging = true
				updateScaleFromInput(input)
			end
		end)
		hotkeySettingsDragChangedConnection = U.connect(UserInputService.InputChanged, function(input)
			if not hotkeySettingsScaleDragging then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then
				updateScaleFromInput(input)
			end
		end)
		hotkeySettingsDragEndedConnection = U.connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					hotkeySettingsScaleDragging = false
			end
		end)

		local function makeSwitchRow(y, key, labelText, getValue, setValue)
			local row = menuRow(y, 28)
			local label = hotkeyText(row, labelText, 11, 150, 28, 0.2)
			label.Position = UDim2.fromOffset(9, 0)
			label.TextColor3 = Theme.Muted
			local track = U.frame(row, {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme.ToggleOff,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -9, 0.5, 0),
				Size = UDim2.fromOffset(30, 16),
				ZIndex = 1004,
			})
			U.corner(track, 8)
			local knob = U.frame(track, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Theme.ToggleOffKnob,
				BorderSizePixel = 0,
				Position = UDim2.new(0.28, 0, 0.5, 0),
				Size = UDim2.fromOffset(12, 12),
				ZIndex = 1005,
			})
			U.corner(knob, 6)
			local current = getValue() == true
			local function setVisual(value, animated)
				current = value == true
				local info = animated and TWEEN.Default or TWEEN.Fast
				U.tween(track, info, { BackgroundColor3 = current and Theme.Accent or Theme.ToggleOff })
				U.tween(knob, info, {
					Position = UDim2.new(current and 0.72 or 0.28, 0, 0.5, 0),
					BackgroundColor3 = current and Theme.Window or Theme.ToggleOffKnob,
				})
			end
			setVisual(current, false)
			hotkeySettingsSwitches[key] = { Set = setVisual, Get = getValue }
			local input = U.inputButton(row, function()
				setVisual(not current, true)
				setValue(current)
			end)
			rowHover(input, row, { label })
		end

		makeSwitchRow(77, "RightAligned", "Right Align", function()
			return overlayRightAligned
		end, function(value)
			setHotkeyRightAligned(value)
		end)
		makeSwitchRow(105, "DynamicTitle", "Dynamic Title", function()
			return hotkeyDynamicTitle
		end, function(value)
			setHotkeyDynamicTitle(value)
		end)

		hotkeySettingsOutsideConnection = U.connect(UserInputService.InputBegan, function(input)
			if not hotkeySettingsOpen or hotkeySettingsIgnoreClick or not hotkeySettingsRoot then
				return
			end
			if input.KeyCode == Enum.KeyCode.Escape then
				closeHotkeySettings()
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local position = input.Position
			local absolute = hotkeySettingsRoot.AbsolutePosition
			local size = hotkeySettingsRoot.AbsoluteSize
			if position.X >= absolute.X and position.X <= absolute.X + size.X
				and position.Y >= absolute.Y and position.Y <= absolute.Y + size.Y then
				return
			end
			if hotkeyStyleMenuOpen and hotkeyStyleMenuRoot and hotkeyStyleMenuRoot.Parent then
				local menuAbsolute = hotkeyStyleMenuRoot.AbsolutePosition
				local menuSize = hotkeyStyleMenuRoot.AbsoluteSize
				if position.X >= menuAbsolute.X and position.X <= menuAbsolute.X + menuSize.X
					and position.Y >= menuAbsolute.Y and position.Y <= menuAbsolute.Y + menuSize.Y then
					return
				end
			end
			if overlaySettingsAnchor and overlaySettingsAnchor.Parent then
				local anchorAbsolute = overlaySettingsAnchor.AbsolutePosition
				local anchorSize = overlaySettingsAnchor.AbsoluteSize
				if position.X >= anchorAbsolute.X - 4 and position.X <= anchorAbsolute.X + anchorSize.X + 4
					and position.Y >= anchorAbsolute.Y - 4 and position.Y <= anchorAbsolute.Y + anchorSize.Y + 4 then
					return
				end
			end
			closeHotkeySettings()
		end)
	end

	positionHotkeySettings = function()
		if not hotkeySettingsRoot or not hotkeySettingsOpen then
			return
		end
		local viewport = U.viewport()
		local anchor = overlaySettingsAnchor
		if not (anchor and anchor.Parent) then
			anchor = hotkeyDotsButton
		end
		if not (anchor and anchor.Parent) then
			anchor = overlayRoot
		end
		if not anchor then
			return
		end
		local cardWidth = hotkeySettingsRoot.Size.X.Offset
		local cardHeight = hotkeySettingsRoot.Size.Y.Offset
		local absolute = anchor.AbsolutePosition
		local size = anchor.AbsoluteSize
		local x = absolute.X + size.X + 8
		if x + cardWidth > viewport.X - 8 then
			if anchor == hotkeyDotsButton and overlayRoot then
				x = overlayRoot.AbsolutePosition.X - cardWidth - 8
			else
				x = absolute.X - cardWidth - 8
			end
		end
		x = math.clamp(x, 8, math.max(8, viewport.X - cardWidth - 8))
		local y = absolute.Y
		if y + cardHeight > viewport.Y - 8 then
			y = viewport.Y - cardHeight - 8
		end
		y = math.clamp(y, 8, math.max(8, viewport.Y - cardHeight - 8))
		hotkeySettingsRoot.Position = UDim2.fromOffset(x, y)
		if hotkeyStyleMenuOpen and positionHotkeyStyleMenu then
			positionHotkeyStyleMenu()
		end
	end

	closeHotkeySettings = function()
		if not hotkeySettingsRoot or not hotkeySettingsOpen then
			return
		end
		hotkeySettingsOpen = false
		if closeHotkeyStyleMenu then
			closeHotkeyStyleMenu(true)
		end
		if overlayHeaderDotsIcon and overlayHeaderDotsIcon.Parent then
			U.tween(overlayHeaderDotsIcon, TWEEN.Fast, { TextTransparency = 0.25 })
		end
		hotkeySettingsToken = hotkeySettingsToken + 1
		local token = hotkeySettingsToken
		local position = hotkeySettingsRoot.Position
		U.tween(hotkeySettingsRoot, TWEEN.Fast, {
			GroupTransparency = 1,
			Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 4),
		})
		if hotkeySettingsScale then
			U.tween(hotkeySettingsScale, TWEEN.Fast, { Scale = 0.94 })
		end
		task.delay(0.16, function()
			if token == hotkeySettingsToken and not hotkeySettingsOpen and hotkeySettingsRoot then
				hotkeySettingsRoot.Visible = false
				hotkeySettingsRoot:Destroy()
				hotkeySettingsRoot = nil
				hotkeySettingsScale = nil
				hotkeySettingsStyleValue = nil
				hotkeySettingsScaleValue = nil
				hotkeySettingsScaleTrack = nil
				hotkeySettingsScaleFill = nil
				hotkeySettingsScaleKnob = nil
				hotkeySettingsScaleDragging = false
				table.clear(hotkeySettingsSwitches)
				for _, connection in ipairs({
					hotkeySettingsOutsideConnection,
					hotkeySettingsDragChangedConnection,
					hotkeySettingsDragEndedConnection,
				}) do
					if connection and connection.Disconnect then
						pcall(function()
							connection:Disconnect()
						end)
					end
				end
				hotkeySettingsOutsideConnection = nil
				hotkeySettingsDragChangedConnection = nil
				hotkeySettingsDragEndedConnection = nil
			end
		end)
	end

	toggleHotkeySettings = function(anchor)
		anchor = anchor or hotkeyDotsButton or overlayRoot
		if hotkeySettingsOpen then
			if anchor and anchor ~= overlaySettingsAnchor then
				overlaySettingsAnchor = anchor
				if closeHotkeyStyleMenu then
					closeHotkeyStyleMenu(true)
				end
				positionHotkeySettings()
				return
			end
			if closeHotkeySettings then
				closeHotkeySettings()
			end
			return
		end
		overlaySettingsAnchor = anchor
		if closeHotkeyStyleMenu then
			closeHotkeyStyleMenu(true)
		end
		ensureHotkeySettings()
		if not hotkeySettingsRoot then
			return
		end
		hotkeySettingsOpen = true
		hotkeySettingsIgnoreClick = true
		hotkeySettingsToken = hotkeySettingsToken + 1
		if overlayHeaderDotsIcon and overlayHeaderDotsIcon.Parent then
			U.tween(overlayHeaderDotsIcon, TWEEN.Fast, { TextTransparency = 0.02 })
		end
		if hotkeySettingsStyleValue then
			hotkeySettingsStyleValue.Text = hotkeyStyleText(hotkeyStyle)
		end
		renderHotkeyScale()
		for _, entry in pairs(hotkeySettingsSwitches) do
			if entry.Get and entry.Set then
				entry.Set(entry.Get(), false)
			end
		end
		positionHotkeySettings()
		hotkeySettingsRoot.Visible = true
		local target = hotkeySettingsRoot.Position
		hotkeySettingsRoot.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset + 4)
		U.setGroupTransparency(hotkeySettingsRoot, 1)
		if hotkeySettingsScale then
			hotkeySettingsScale.Scale = 0.94
			U.tween(hotkeySettingsScale, TWEEN.Popup, { Scale = 1 })
		end
		U.tween(hotkeySettingsRoot, TWEEN.Popup, {
			GroupTransparency = 0,
			Position = target,
		})
		task.delay(0.12, function()
			hotkeySettingsIgnoreClick = false
		end)
	end

	local function ensureHotkeyStyleMenu()
		if hotkeyStyleMenuRoot and hotkeyStyleMenuRoot.Parent then
			return
		end
		hotkeyStyleMenuRoot = U.canvas(screenGui, {
			Name = "NerxHotkeyStyleMenu",
			BackgroundColor3 = Theme.SurfaceRaised,
			BackgroundTransparency = 0.02,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(96, 94),
			Visible = false,
			ZIndex = 1110,
			GroupTransparency = 0,
		})
		U.corner(hotkeyStyleMenuRoot, 8)
		U.stroke(hotkeyStyleMenuRoot, Theme.Stroke, 0.45, 1)
		U.shadow(hotkeyStyleMenuRoot, "soft")
		hotkeyStyleMenuScale = U.new("UIScale", { Scale = 1 }, hotkeyStyleMenuRoot)
		hotkeyStyleMenuOptions = {}
		local options = {
			{ Id = "values", Text = "Values" },
			{ Id = "keys", Text = "Keys" },
			{ Id = "switches", Text = "Switches" },
		}
		for index, option in ipairs(options) do
			local row = U.frame(hotkeyStyleMenuRoot, {
				BackgroundColor3 = Theme.White,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(5, 5 + (index - 1) * 28),
				Size = UDim2.new(1, -10, 0, 28),
				ZIndex = 1112,
			})
			U.corner(row, 5)
			local label = U.label(row, {
				Text = option.Text,
				TextSize = 10.5,
				TextColor3 = Theme.Muted,
				TextTransparency = 0.2,
				Position = UDim2.fromOffset(9, 0),
				Size = UDim2.new(1, -34, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 1113,
			})
			local check = U.icon(row, "circle-check", 11, Theme.Accent, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(12, 12),
				TextTransparency = 0.05,
				ZIndex = 1114,
			})
			local input = U.inputButton(row, function()
				setHotkeyStyle(option.Id)
				if closeHotkeyStyleMenu then
					closeHotkeyStyleMenu()
				end
			end)
			input.ZIndex = 1115
			U.connect(input.MouseEnter, function()
				U.tween(row, TWEEN.Fast, { BackgroundTransparency = 0.94 })
				U.tween(label, TWEEN.Fast, { TextTransparency = 0 })
			end)
			U.connect(input.MouseLeave, function()
				U.tween(row, TWEEN.Fast, { BackgroundTransparency = 1 })
				U.tween(label, TWEEN.Fast, { TextTransparency = 0.2 })
			end)
			hotkeyStyleMenuOptions[#hotkeyStyleMenuOptions + 1] = {
				Id = option.Id,
				Row = row,
				Label = label,
				Check = check,
			}
		end
	end

	local function updateHotkeyStyleMenuSelection()
		for _, option in ipairs(hotkeyStyleMenuOptions) do
			if option.Check then
				option.Check.Visible = option.Id == hotkeyStyle
			end
		end
	end

	positionHotkeyStyleMenu = function()
		if not hotkeyStyleMenuRoot or not hotkeySettingsRoot or not hotkeyStyleMenuOpen then
			return
		end
		local viewport = U.viewport()
		local mainAbsolute = hotkeySettingsRoot.AbsolutePosition
		local mainSize = hotkeySettingsRoot.AbsoluteSize
		local menuWidth = hotkeyStyleMenuRoot.Size.X.Offset
		local menuHeight = hotkeyStyleMenuRoot.Size.Y.Offset
		local x = mainAbsolute.X + mainSize.X + 6
		if x + menuWidth > viewport.X - 8 then
			x = mainAbsolute.X - menuWidth - 6
		end
		x = math.clamp(x, 8, math.max(8, viewport.X - menuWidth - 8))
		local y = mainAbsolute.Y + 5
		if y + menuHeight > viewport.Y - 8 then
			y = viewport.Y - menuHeight - 8
		end
		y = math.clamp(y, 8, math.max(8, viewport.Y - menuHeight - 8))
		hotkeyStyleMenuRoot.Position = UDim2.fromOffset(x, y)
	end

	closeHotkeyStyleMenu = function(instant)
		if not hotkeyStyleMenuRoot or not hotkeyStyleMenuOpen then
			return
		end
		hotkeyStyleMenuOpen = false
		hotkeyStyleMenuToken = hotkeyStyleMenuToken + 1
		local token = hotkeyStyleMenuToken
		if instant then
			hotkeyStyleMenuRoot:Destroy()
			hotkeyStyleMenuRoot = nil
			hotkeyStyleMenuScale = nil
			hotkeyStyleMenuOptions = {}
			return
		end
		local position = hotkeyStyleMenuRoot.Position
		U.tween(hotkeyStyleMenuRoot, TWEEN.Fast, {
			GroupTransparency = 1,
			Position = UDim2.new(position.X.Scale, position.X.Offset + 6, position.Y.Scale, position.Y.Offset),
		})
		if hotkeyStyleMenuScale then
			U.tween(hotkeyStyleMenuScale, TWEEN.Fast, { Scale = 0.94 })
		end
		task.delay(0.16, function()
			if token == hotkeyStyleMenuToken and not hotkeyStyleMenuOpen and hotkeyStyleMenuRoot then
				hotkeyStyleMenuRoot:Destroy()
				hotkeyStyleMenuRoot = nil
				hotkeyStyleMenuScale = nil
				hotkeyStyleMenuOptions = {}
			end
		end)
	end

	toggleHotkeyStyleMenu = function()
		if hotkeyStyleMenuOpen then
			if closeHotkeyStyleMenu then
				closeHotkeyStyleMenu()
			end
			return
		end
		ensureHotkeyStyleMenu()
		if not hotkeyStyleMenuRoot or not hotkeySettingsRoot then
			return
		end
		hotkeyStyleMenuOpen = true
		updateHotkeyStyleMenuSelection()
		positionHotkeyStyleMenu()
		hotkeyStyleMenuRoot.Visible = true
		local target = hotkeyStyleMenuRoot.Position
		hotkeyStyleMenuRoot.Position = UDim2.new(target.X.Scale, target.X.Offset + 6, target.Y.Scale, target.Y.Offset)
		U.setGroupTransparency(hotkeyStyleMenuRoot, 1)
		if hotkeyStyleMenuScale then
			hotkeyStyleMenuScale.Scale = 0.94
			U.tween(hotkeyStyleMenuScale, TWEEN.Popup, { Scale = 1 })
		end
		U.tween(hotkeyStyleMenuRoot, TWEEN.Popup, {
			GroupTransparency = 0,
			Position = target,
		})
	end

	local function resolveTarget(target)
		if type(target) ~= "table" then
			return nil, nil
		end
		if target.Type == "Component" then
			return Nerx.ComponentsById[target.Target], "component"
		end
		if target.Type == "Flag" then
			return Nerx.Flags[target.Target], "flag"
		end
		return nil, nil
	end

	local function fireAction(target, phase, bind)
		if type(target) ~= "table" or target.Type ~= "Action" then
			return
		end
		local action = actions[target.Target]
		if not action then
			return
		end
		local callback = phase == "press" and action.Press or action.Release
		if callback then
			task.spawn(pcall, callback, bind)
		end
	end

	local function applyBindActions(bind, pressed)
		if pressed then
			bind.__previous = {}
			for index, target in ipairs(bind.Actions or {}) do
				if target.Type == "Action" then
					fireAction(target, "press", bind)
				else
					local api = resolveTarget(target)
					if api and api.GetValue and api.SetValue then
						local ok, previous = pcall(api.GetValue, api)
						bind.__previous[index] = ok and previous or nil
						pcall(api.SetValue, api, decodeValue(target.Value), true)
					end
				end
			end
		else
			local previous = bind.__previous or {}
			for index = #(bind.Actions or {}), 1, -1 do
				local target = bind.Actions[index]
				if target.Type == "Action" then
					fireAction(target, "release", bind)
				else
					local api = resolveTarget(target)
					if api and api.SetValue then
						pcall(api.SetValue, api, previous[index], true)
					end
				end
			end
			bind.__previous = nil
		end
	end

	local function isParentActive(bind)
		local parentId = bind.ParentId
		if not parentId or parentId == "" then
			return true
		end
		return activeStates[parentId] == true
	end

	local activateBind
	local deactivateBind

	local function refreshChildren(bind, visited)
		for _, child in ipairs(binds) do
			if child.ParentId == bind.Id and child.Trigger == "Condition" and child.Enabled ~= false then
				if activeStates[bind.Id] then
					activateBind(child, visited)
				else
					deactivateBind(child, visited)
				end
			end
		end
	end

	activateBind = function(bind, visited)
		if not bind or activeStates[bind.Id] then
			return
		end
		visited = visited or {}
		if visited[bind.Id] then
			return
		end
		visited[bind.Id] = true
		activeStates[bind.Id] = true
		lastTriggeredName = tostring(bind.Name or "Bind")
		applyBindActions(bind, true)
		refreshChildren(bind, visited)
		buildOverlay()
		notifyChanged()
	end

	deactivateBind = function(bind, visited)
		if not bind or not activeStates[bind.Id] then
			return
		end
		visited = visited or {}
		if visited[bind.Id] then
			return
		end
		visited[bind.Id] = true
		activeStates[bind.Id] = nil
		applyBindActions(bind, false)
		refreshChildren(bind, visited)
		buildOverlay()
		notifyChanged()
	end

	local function pulseBind(bind)
		if not bind then
			return
		end
		activateBind(bind)
		local token = {}
		bind.__pulse = token
		task.delay(0.14, function()
			if bind.__pulse == token then
				bind.__pulse = nil
				deactivateBind(bind)
			end
		end)
	end

	local function inputName(input)
		if not input then
			return nil
		end
		local key = input.KeyCode
		local inputType = input.UserInputType
		if inputType == Enum.UserInputType.MouseButton1
			or inputType == Enum.UserInputType.MouseButton2
			or inputType == Enum.UserInputType.MouseButton3 then
			key = inputType
		end
		if not key or key == Enum.KeyCode.Unknown then
			return nil
		end
		local ok, name = pcall(U.keyName, key)
		return ok and name or nil
	end

	local function keyIsCaptured()
		if Nerx.CapturingKeybind then
			return true
		end
		if UserInputService.GetFocusedTextBox then
			local ok, box = pcall(function()
				return UserInputService:GetFocusedTextBox()
			end)
			if ok and box then
				return true
			end
		end
		return false
	end

	U.connect(UserInputService.InputBegan, function(input, gameProcessedEvent)
		if input.UserInputType ~= Enum.UserInputType.Keyboard
			and input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.MouseButton2
			and input.UserInputType ~= Enum.UserInputType.MouseButton3 then
			return
		end
		if gameProcessedEvent or keyIsCaptured() then
			return
		end
		local key = inputName(input)
		if not key then
			return
		end

		for _, bind in ipairs(binds) do
			if bind.Enabled ~= false
				and bind.Trigger == "Key"
				and bind.Key == key
				and isParentActive(bind) then
				local mode = bind.Mode or "Toggle"
				if mode == "Hold" then
					if not activeStates[bind.Id] then
						bind.__heldKey = key
						activateBind(bind)
					end
				elseif mode == "Double Click" then
					local now = os.clock()
					if bind.__lastClick and now - bind.__lastClick <= 0.42 then
						bind.__lastClick = nil
						pulseBind(bind)
					else
						bind.__lastClick = now
					end
				else
					if activeStates[bind.Id] then
						deactivateBind(bind)
					else
						activateBind(bind)
					end
				end
			end
		end
	end)

	U.connect(UserInputService.InputEnded, function(input)
		local key = inputName(input)
		if not key then
			return
		end
		for _, bind in ipairs(binds) do
			if bind.Mode == "Hold" and bind.__heldKey == key then
				bind.__heldKey = nil
				deactivateBind(bind)
			end
		end
	end)

	local function serializeBind(bind)
		local encodedActions = {}
		for index, target in ipairs(bind.Actions or {}) do
			encodedActions[index] = {
				Type = target.Type,
				Target = target.Target,
				Value = encodeValue(target.Value),
			}
		end
		return {
			Id = bind.Id,
			Name = bind.Name,
			Key = bind.Key,
			Mode = bind.Mode,
			Trigger = bind.Trigger,
			ParentId = bind.ParentId,
			Overlay = bind.Overlay,
			Enabled = bind.Enabled ~= false,
			Actions = encodedActions,
		}
	end

	local function decodeBind(data)
		if type(data) ~= "table" then
			return nil
		end
		local bind = {
			Id = data.Id or data.id,
			Name = data.Name or data.name or "Bind",
			Key = data.Key or data.key or "F4",
			Mode = data.Mode or data.mode or "Toggle",
			Trigger = data.Trigger or data.trigger or "Key",
			ParentId = data.ParentId or data.parentId,
			Overlay = data.Overlay or data.overlay or "While Active",
			Enabled = data.Enabled ~= false,
			Actions = {},
		}
		for _, target in ipairs(data.Actions or data.actions or {}) do
			bind.Actions[#bind.Actions + 1] = {
				Type = target.Type or target.type or "Component",
				Target = target.Target or target.target,
				Value = decodeValue(target.Value or target.value),
			}
		end
		return bind
	end

	local function saveBinds()
		local data = { version = 1, binds = {} }
		for index, bind in ipairs(binds) do
			data.binds[index] = serializeBind(bind)
		end
		Nerx.Storage:WriteJSON(BIND_FILE, data)
	end

	local function loadBinds()
		local data = Nerx.Storage:ReadJSON(BIND_FILE)
		if type(data) ~= "table" then
			return
		end
		local source = type(data.binds) == "table" and data.binds or data
		for index, entry in ipairs(source) do
			local bind = decodeBind(entry)
			if bind then
				if not bind.Id or bind.Id == "" then
					bind.Id = "bind" .. tostring(index)
				end
				bindCounter = math.max(bindCounter, index)
				binds[#binds + 1] = bind
			end
		end
	end

	local BindManager = {
		Binds = binds,
		Actions = actions,
		OnChanged = listeners,
	}

	function BindManager:InputName(input)
		return inputName(input)
	end

	function BindManager:RegisterAction(name, onPress, onRelease)
		if not name or name == "" then
			return
		end
		actions[name] = {
			Name = name,
			Press = onPress,
			Release = onRelease,
		}
		notifyChanged()
	end

	function BindManager:GetActions()
		local list = {}
		for name in pairs(actions) do
			list[#list + 1] = name
		end
		table.sort(list)
		return list
	end

	function BindManager:GetTargets()
		local targets = {}
		for _, name in ipairs(self:GetActions()) do
			targets[#targets + 1] = {
				Type = "Action",
				Target = name,
				Label = "Action · " .. name,
				Value = true,
			}
		end
		for _, component in ipairs(Nerx.Components) do
			if component.Id and component.SetValue then
				local path = tostring(component.Path or "")
				local name = tostring(component.Name or "Setting")
				if component.Kind == "toggle" then
					targets[#targets + 1] = {
						Type = "Component",
						Target = component.Id,
						Label = "Toggle · " .. name,
						Detail = path,
						Value = true,
					}
				elseif component.Kind == "dropdown" then
					for _, option in ipairs(component.Options or {}) do
						targets[#targets + 1] = {
							Type = "Component",
							Target = component.Id,
							Label = "Dropdown · " .. name .. " → " .. tostring(option),
							Detail = path,
							Value = option,
						}
					end
				elseif component.Kind == "slider" then
					targets[#targets + 1] = {
						Type = "Component",
						Target = component.Id,
						Label = "Slider · " .. name .. " = " .. tostring(component.Default or 0),
						Detail = path,
						Value = component.Default,
					}
				end
			end
		end
		return targets
	end

	function BindManager:List(filterText)
		local filterLower = string.lower(tostring(filterText or ""))
		local list = {}
		for _, bind in ipairs(binds) do
			if filterLower == "" or string.find(string.lower(tostring(bind.Name or "")), filterLower, 1, true) then
				list[#list + 1] = bind
			end
		end
		return list
	end

	function BindManager:Get(id)
		for _, bind in ipairs(binds) do
			if bind.Id == id then
				return bind
			end
		end
		return nil
	end

	function BindManager:Add(data)
		bindCounter = bindCounter + 1
		local bind = decodeBind(data or {})
		bind.Id = tostring((data and (data.Id or data.id)) or ("bind" .. tostring(bindCounter)))
		bindCounter = math.max(bindCounter, tonumber(string.match(bind.Id, "%d+")) or bindCounter)
		bind.Name = bind.Name or ("Bind " .. tostring(bindCounter))
		binds[#binds + 1] = bind
		saveBinds()
		buildOverlay()
		notifyChanged()
		return bind
	end

	function BindManager:Update(id, patch)
		local bind = self:Get(id)
		if not bind then
			return nil
		end
		for key, value in pairs(patch or {}) do
			if key ~= "Actions" and key ~= "Id" and key:sub(1, 2) ~= "__" then
				bind[key] = value
			end
		end
		if patch and patch.Actions then
			bind.Actions = {}
			for index, target in ipairs(patch.Actions) do
				bind.Actions[index] = {
					Type = target.Type,
					Target = target.Target,
					Value = target.Value,
				}
			end
		end
		if bind.Enabled == false and activeStates[bind.Id] then
			deactivateBind(bind)
		end
		saveBinds()
		buildOverlay()
		notifyChanged()
		return bind
	end

	function BindManager:Remove(id)
		for index, bind in ipairs(binds) do
			if bind.Id == id then
				if activeStates[id] then
					deactivateBind(bind)
				end
				table.remove(binds, index)
				for _, child in ipairs(binds) do
					if child.ParentId == id then
						child.ParentId = nil
					end
				end
				saveBinds()
				buildOverlay()
				notifyChanged()
				return true
			end
		end
		return false
	end

	function BindManager:IsActive(id)
		return activeStates[id] == true
	end

	function BindManager:SetOverlayEnabled(value)
		overlayEnabled = value == true
		buildOverlay()
		notifyChanged()
	end

	function BindManager:RefreshOverlay()
		buildOverlay()
	end

	function BindManager:IsOverlayEnabled()
		return overlayEnabled
	end

	function BindManager:SetHotkeyStyle(value)
		setHotkeyStyle(value)
	end

	function BindManager:SetHotkeyRightAligned(value)
		setHotkeyRightAligned(value == true)
	end

	function BindManager:SetHotkeyDynamicTitle(value)
		setHotkeyDynamicTitle(value == true)
	end

	function BindManager:SetHotkeyScale(value)
		setHotkeyScale(value)
	end

	function BindManager:GetHotkeySettings()
		return {
			Style = hotkeyStyle,
			RightAligned = overlayRightAligned,
			DynamicTitle = hotkeyDynamicTitle,
			Scale = overlayScale,
		}
	end

	function BindManager:OpenHotkeySettings(anchor)
		if not hotkeySettingsOpen then
			toggleHotkeySettings(anchor)
		elseif anchor and anchor ~= overlaySettingsAnchor then
			overlaySettingsAnchor = anchor
			positionHotkeySettings()
		end
	end

	function BindManager:ToggleHotkeySettings(anchor)
		toggleHotkeySettings(anchor)
	end

	function BindManager:CloseHotkeySettings()
		if closeHotkeySettings then
			closeHotkeySettings()
		end
	end

	function BindManager:IsHotkeySettingsOpen()
		return hotkeySettingsOpen
	end

	function BindManager:Serialize()
		local serialized = {}
		for index, bind in ipairs(binds) do
			serialized[index] = serializeBind(bind)
		end
		return serialized
	end

	function BindManager:Deserialize(data, options)
		options = options or {}
		for _, bind in ipairs(binds) do
			if activeStates[bind.Id] then
				deactivateBind(bind)
			end
		end
		table.clear(binds)
		table.clear(activeStates)
		local source = type(data) == "table" and (data.binds or data) or {}
		for index, entry in ipairs(source) do
			local bind = decodeBind(entry)
			if bind then
				if not bind.Id or bind.Id == "" then
					bind.Id = "bind" .. tostring(index)
				end
				bindCounter = math.max(bindCounter, tonumber(string.match(tostring(bind.Id), "%d+")) or 0)
				binds[#binds + 1] = bind
			end
		end
		if options.persist ~= false then
			saveBinds()
		end
		buildOverlay()
		notifyChanged()
	end

	function BindManager:Save()
		saveBinds()
	end

	function BindManager:DeactivateAll()
		for _, bind in ipairs(binds) do
			if activeStates[bind.Id] then
				deactivateBind(bind)
			end
		end
	end

	loadBinds()
	buildOverlay()
	Nerx.BindManager = BindManager
	Nerx.HotkeyIcon = HOTKEY_ICON
	Nerx.HotkeyAccent = HOTKEY_ACCENT

	-- Rebuild the floating HUD with the new palette after a theme switch.
	table.insert(Nerx.Themes.OnChanged, function()
		applyHotkeyTheme()
		pcall(function()
			BindManager:RefreshOverlay()
		end)
	end)
end

-- ---------------------------------------------------------------------------------------
-- Frosted glass / 毛玻璃
-- A real glass material is not available for ScreenGuis, so the mode combines a
-- scene BlurEffect, translucent menu surfaces, a diagonal sheen, a chromatic rim
-- and spring press feedback. Every value is adjustable at runtime.
-- ---------------------------------------------------------------------------------------

do
	local Lighting = game:GetService("Lighting")

	local Frosted = {
		Enabled = false,
		Params = {
			Blur = 14,
			Opacity = 0.30,
			Dispersion = 0.45,
			Outline = 0.55,
			Sheen = 0.40,
			Press = 0.965,
			Spring = 24,
			Radius = 12,
			Thickness = 1,
		},
		OnChanged = {},
	}
	Nerx.Frosted = Frosted

	local state = {
		surfaces = {},
		layers = {},
		blur = nil,
	}

	local function ensureBlur()
		local blur = Lighting:FindFirstChild("NerxFrostedBlur")
		if not (blur and blur:IsA("BlurEffect")) then
			blur = Instance.new("BlurEffect")
			blur.Name = "NerxFrostedBlur"
			blur.Size = 0
			blur.Parent = Lighting
		end
		state.blur = blur
		return blur
	end

	local function restoreSurfaces()
		for _, store in pairs(state.surfaces) do
			for object, original in pairs(store) do
				if object.Parent then
					object.BackgroundTransparency = original
				end
			end
		end
		state.surfaces = {}
	end

	local function applySurfaces()
		for _, win in ipairs(Nerx.Windows) do
			local root = win.Root
			if root and root.Parent then
				local store = state.surfaces[root]
				if not store then
					store = {}
					state.surfaces[root] = store
				end
				for _, object in ipairs(root:GetDescendants()) do
					if object:IsA("GuiObject") and not object:GetAttribute("NerxFrostLayer") then
						local ok, transparency = pcall(function()
							return object.BackgroundTransparency
						end)
						if ok and transparency and transparency < 0.99 then
							if store[object] == nil then
								store[object] = transparency
							end
							object.BackgroundTransparency = math.clamp(store[object] + Frosted.Params.Opacity, 0, 0.94)
						end
					end
				end
			end
		end
	end

	local function buildLayers(win)
		local root = win.Root
		if not root or not root.Parent then
			return nil
		end
		local layer = state.layers[root]
		if layer and layer.sheen.Parent then
			return layer
		end

		local sheen = Instance.new("Frame")
		sheen.Name = "NerxFrostSheen"
		sheen.BackgroundColor3 = Color3.new(1, 1, 1)
		sheen.BackgroundTransparency = 0
		sheen.BorderSizePixel = 0
		sheen.Size = UDim2.fromScale(1, 1)
		sheen.ZIndex = 240
		sheen.Active = false
		sheen:SetAttribute("NerxFrostLayer", true)
		U.corner(sheen, Frosted.Params.Radius)
		local gradient = Instance.new("UIGradient")
		gradient.Rotation = 18
		gradient.Parent = sheen
		sheen.Parent = root

		local rim = Instance.new("Frame")
		rim.Name = "NerxFrostRim"
		rim.BackgroundTransparency = 1
		rim.BorderSizePixel = 0
		rim.Size = UDim2.fromScale(1, 1)
		rim.ZIndex = 241
		rim.Active = false
		rim:SetAttribute("NerxFrostLayer", true)
		U.corner(rim, Frosted.Params.Radius)
		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		local strokeGradient = Instance.new("UIGradient")
		strokeGradient.Rotation = 35
		strokeGradient.Parent = stroke
		stroke.Parent = rim
		rim.Parent = root

		layer = { sheen = sheen, gradient = gradient, rim = rim, stroke = stroke, strokeGradient = strokeGradient }
		state.layers[root] = layer
		return layer
	end

	local function paintLayers()
		local params = Frosted.Params
		for _, win in ipairs(Nerx.Windows) do
			local layer = buildLayers(win)
			if layer then
				U.corner(layer.sheen, params.Radius)
				U.corner(layer.rim, params.Radius)

				-- Diagonal sheen: a quiet highlight across the upper-left face.
				layer.gradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1 - params.Sheen * 0.16),
					NumberSequenceKeypoint.new(0.42, 0.93),
					NumberSequenceKeypoint.new(1, 1),
				})

				-- Chromatic rim: red and blue split by the dispersion amount.
				local split = math.clamp(params.Dispersion, 0, 1)
				local function tint(color, amount)
					return Color3.new(
						color.R + (1 - color.R) * (1 - amount),
						color.G + (1 - color.G) * (1 - amount),
						color.B + (1 - color.B) * (1 - amount)
					)
				end
				layer.strokeGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, tint(Color3.fromRGB(255, 96, 96), split)),
					ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, tint(Color3.fromRGB(96, 150, 255), split)),
				})
				layer.stroke.Thickness = params.Thickness
				layer.stroke.Transparency = math.clamp(0.62 - params.Outline * 0.42, 0, 1)
			end
		end
	end

	function Frosted:Apply(partial)
		if type(partial) == "table" then
			for key, value in pairs(partial) do
				if self.Params[key] ~= nil and (typeof(value) == "number" or typeof(value) == "boolean") then
					self.Params[key] = value
				end
			end
		end
		if not self.Enabled then
			return
		end
		local blur = ensureBlur()
		blur.Size = self.Params.Blur
		blur.Enabled = self.Params.Blur > 0.5
		applySurfaces()
		paintLayers()
		for _, callback in ipairs(self.OnChanged) do
			task.spawn(pcall, callback, self.Params)
		end
	end

	function Frosted:SetEnabled(enabled)
		enabled = enabled == true
		if self.Enabled == enabled then
			if enabled then
				self:Apply()
			end
			return
		end
		self.Enabled = enabled
		if enabled then
			self:Apply()
		else
			if state.blur then
				state.blur.Size = 0
				state.blur.Enabled = false
			end
			restoreSurfaces()
			for _, layer in pairs(state.layers) do
				if layer.sheen then
					layer.sheen:Destroy()
				end
				if layer.rim then
					layer.rim:Destroy()
				end
			end
			state.layers = {}
			for _, callback in ipairs(self.OnChanged) do
				task.spawn(pcall, callback, self.Params)
			end
		end
	end

	function Frosted:Toggle()
		self:SetEnabled(not self.Enabled)
	end

	function Frosted:GetParams()
		local copy = {}
		for key, value in pairs(self.Params) do
			copy[key] = value
		end
		return copy
	end
end

do
	local Internal = Nerx._Internal
	local encodeValue = Internal.encodeValue
	local decodeValue = Internal.decodeValue
	local encodeColor = Internal.encodeColor
	local decodeColor = Internal.decodeColor
	local colorKey = Internal.colorKey

	local CONFIG_FILE = "configs.json"
	local configStore = {
		version = 1,
		active = nil,
		configs = {},
	}
	local listeners = {}

	local function loadStore()
		local raw = Nerx.Storage:ReadJSON(CONFIG_FILE)
		if type(raw) ~= "table" then
			return
		end
		if type(raw.configs) == "table" then
			configStore.configs = raw.configs
		end
		configStore.active = raw.active
	end

	local function saveStore()
		Nerx.Storage:WriteJSON(CONFIG_FILE, configStore)
	end

	local function notifyConfigChanged()
		for _, callback in ipairs(listeners) do
			task.spawn(function()
				pcall(callback)
			end)
		end
	end

	local function trimName(name)
		return tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	end

	local function countValues(data)
		local count = 0
		for _ in pairs(data and data.components or {}) do
			count = count + 1
		end
		return count
	end

	local function snapshotSize(data)
		local encoded = Nerx.Storage:Encode(data)
		return encoded and #encoded or 0
	end

	loadStore()

	local function copyTable(value)
		if type(value) ~= "table" then
			return value
		end
		local copy = {}
		for key, item in pairs(value) do
			copy[key] = copyTable(item)
		end
		return copy
	end

	function Nerx:CaptureConfig()
		local components = {}
		for _, component in ipairs(Nerx.Components) do
			if component.Id and component.GetValue then
				local ok, value = pcall(component.GetValue, component)
				local entry = {
					Kind = component.Kind,
					Name = component.Name,
					Flag = component.Flag,
				}
				if ok then
					entry.Value = encodeValue(value)
				end
				if component.Swatch and component.Swatch.Color then
					entry.Swatch = encodeColor(component.Swatch.Color)
				end
				components[component.Id] = entry
			end
		end

		local flags = {}
		for flag, api in pairs(Nerx.Flags) do
			if api and api.GetValue then
				local ok, value = pcall(api.GetValue, api)
				if ok then
					flags[flag] = encodeValue(value)
				end
			end
		end

		local window = Nerx.Windows[1]
		local mode = window and window.Mode or nil
		local layout = {
			windowPosition = nil,
			custom = copyTable(Nerx.LayoutState or {}),
		}
		if window and window.Root then
			local position = window.Root.Position
			layout.windowPosition = {
				XScale = position.X.Scale,
				XOffset = position.X.Offset,
				YScale = position.Y.Scale,
				YOffset = position.Y.Offset,
			}
		end

		return {
			version = 1,
			capturedAt = os.time(),
			mode = mode,
			components = components,
			flags = flags,
			binds = Nerx.BindManager and Nerx.BindManager:Serialize() or {},
			theme = Nerx.Themes and Nerx.Themes:SerializeActive() or nil,
			layout = layout,
		}
	end

	function Nerx:ApplyConfig(config, options)
		options = options or {}
		if type(config) ~= "table" then
			return false
		end

		if config.flags then
			for flag, value in pairs(config.flags) do
				local api = Nerx.Flags[flag]
				if api and api.SetValue then
					pcall(api.SetValue, api, decodeValue(value), true)
				end
			end
		end

		if config.components then
			for identifier, entry in pairs(config.components) do
				local component = Nerx.ComponentsById[identifier]
				if component then
					if component.SetValue and entry.Value ~= nil then
						pcall(component.SetValue, component, decodeValue(entry.Value), true)
					end
					if entry.Swatch and component.Swatch and component.Swatch.SetColor then
						local color = decodeColor(entry.Swatch)
						if color then
							pcall(component.Swatch.SetColor, component.Swatch, color, true)
						end
					end
				end
			end
		end

		if config.binds and Nerx.BindManager then
			Nerx.BindManager:Deserialize(config.binds, { persist = true })
		end

		if config.theme and Nerx.Themes then
			Nerx.Themes:ApplySerialized(config.theme, { noPersist = false })
		end

		if config.mode then
			for _, window in ipairs(Nerx.Windows) do
				if window.SetMode then
					pcall(window.SetMode, window, config.mode, true)
				end
			end
		end

		local window = Nerx.Windows[1]
		local position = config.layout and config.layout.windowPosition
		if window and window.Root and type(position) == "table" then
			pcall(function()
				window.Root.Position = UDim2.new(
					tonumber(position.XScale) or 0.5,
					tonumber(position.XOffset) or 0,
					tonumber(position.YScale) or 0.5,
					tonumber(position.YOffset) or 0
				)
			end)
		end
		if config.layout and type(config.layout.custom) == "table" then
			Nerx.LayoutState = copyTable(config.layout.custom)
		end
		if Nerx.BindManager and Nerx.BindManager.RefreshOverlay then
			pcall(Nerx.BindManager.RefreshOverlay, Nerx.BindManager)
		end

		if not options.noCallbacks then
			for _, window in ipairs(Nerx.Windows) do
				if window.RenderTab and window.SelectedTab then
					pcall(window.RenderTab, window, window.SelectedTab)
				end
			end
		end
		return true
	end

	local function valuesEqual(a, b)
		if typeof(a) == "Color3" and typeof(b) == "Color3" then
			return colorKey(a) == colorKey(b)
		end
		return a == b
	end

	local function deepEqual(a, b)
		if a == b then
			return true
		end
		if type(a) ~= "table" or type(b) ~= "table" then
			return false
		end
		for key, value in pairs(a) do
			if not deepEqual(value, b[key]) then
				return false
			end
		end
		for key in pairs(b) do
			if a[key] == nil then
				return false
			end
		end
		return true
	end

	function Nerx:CountChanged(config)
		if type(config) ~= "table" then
			return 0
		end
		local changed = 0

		for identifier, entry in pairs(config.components or {}) do
			local component = Nerx.ComponentsById[identifier]
			if component and component.GetValue then
				local ok, current = pcall(component.GetValue, component)
				if ok and not valuesEqual(current, decodeValue(entry.Value)) then
					changed = changed + 1
				end
				if entry.Swatch and component.Swatch and component.Swatch.Color then
					local expected = decodeColor(entry.Swatch)
					if expected and colorKey(component.Swatch.Color) ~= colorKey(expected) then
						changed = changed + 1
					end
				end
			end
		end

		local window = Nerx.Windows[1]
		if window and config.mode and window.Mode ~= config.mode then
			changed = changed + 1
		end
		if config.binds and Nerx.BindManager then
			if not deepEqual(Nerx.BindManager:Serialize(), config.binds) then
				changed = changed + 1
			end
		end
		if config.theme and Nerx.Themes then
			if not deepEqual(Nerx.Themes:SerializeActive(), config.theme) then
				changed = changed + 1
			end
		end
		local position = config.layout and config.layout.windowPosition
		if window and window.Root and type(position) == "table" then
			local current = window.Root.Position
			if current.X.Scale ~= (tonumber(position.XScale) or 0.5)
				or current.X.Offset ~= (tonumber(position.XOffset) or 0)
				or current.Y.Scale ~= (tonumber(position.YScale) or 0.5)
				or current.Y.Offset ~= (tonumber(position.YOffset) or 0) then
				changed = changed + 1
			end
		end
		local savedLayout = config.layout and config.layout.custom
		if type(savedLayout) == "table" and not deepEqual(Nerx.LayoutState or {}, savedLayout) then
			changed = changed + 1
		end
		return changed
	end

	local Configs = {
		OnChanged = listeners,
		ActiveName = configStore.active,
	}

	function Configs:Refresh()
		configStore = { version = 1, active = nil, configs = {} }
		loadStore()
		self.ActiveName = configStore.active
		notifyConfigChanged()
	end

	function Configs:List(filterText, sortMode)
		local filterLower = string.lower(tostring(filterText or ""))
		local list = {}
		for name, record in pairs(configStore.configs) do
			if filterLower == "" or string.find(string.lower(name), filterLower, 1, true) then
				list[#list + 1] = record
			end
		end
		table.sort(list, function(a, b)
			if sortMode == "Recent" then
				return (a.savedAt or 0) > (b.savedAt or 0)
			end
			return string.lower(a.name or a.Name or "") < string.lower(b.name or b.Name or "")
		end)
		return list
	end

	function Configs:Get(name)
		return configStore.configs[name]
	end

	function Configs:SaveAs(name)
		name = trimName(name)
		if name == "" then
			return false, "empty name"
		end
		if configStore.configs[name] then
			return false, "exists"
		end
		self:Save(name)
		return true
	end

	function Configs:Save(name)
		name = trimName(name or self.ActiveName or "Default")
		if name == "" then
			return false, "empty name"
		end
		local existing = configStore.configs[name]
		local snapshot = Nerx:CaptureConfig()
		local record = {
			name = name,
			Name = name,
			createdAt = existing and existing.createdAt or os.time(),
			savedAt = os.time(),
			values = countValues(snapshot),
			size = snapshotSize(snapshot),
			data = snapshot,
		}
		configStore.configs[name] = record
		configStore.active = name
		self.ActiveName = name
		saveStore()
		notifyConfigChanged()
		return true
	end

	function Configs:SaveActive()
		return self:Save(self.ActiveName or "Default")
	end

	function Configs:Load(name)
		local record = configStore.configs[name]
		if not record then
			return false, "missing"
		end
		local ok = Nerx:ApplyConfig(record.data)
		if not ok then
			return false, "invalid config"
		end
		configStore.active = name
		self.ActiveName = name
		saveStore()
		notifyConfigChanged()
		return true
	end

	function Configs:LoadActive()
		if not configStore.active then
			return false
		end
		return self:Load(configStore.active)
	end

	function Configs:Delete(name)
		if not configStore.configs[name] then
			return false
		end
		configStore.configs[name] = nil
		if configStore.active == name then
			configStore.active = nil
			self.ActiveName = nil
		end
		saveStore()
		notifyConfigChanged()
		return true
	end

	function Configs:Rename(oldName, newName)
		newName = trimName(newName)
		if newName == "" or not configStore.configs[oldName] or configStore.configs[newName] then
			return false
		end
		local record = configStore.configs[oldName]
		configStore.configs[oldName] = nil
		record.name = newName
		record.Name = newName
		configStore.configs[newName] = record
		if configStore.active == oldName then
			configStore.active = newName
			self.ActiveName = newName
		end
		saveStore()
		notifyConfigChanged()
		return true
	end

	function Configs:Duplicate(oldName, newName)
		newName = trimName(newName)
		local record = configStore.configs[oldName]
		if not record or newName == "" or configStore.configs[newName] then
			return false
		end
		local copy = Nerx.Storage:Decode(Nerx.Storage:Encode(record.data)) or record.data
		configStore.configs[newName] = {
			name = newName,
			Name = newName,
			createdAt = os.time(),
			savedAt = os.time(),
			values = record.values,
			size = record.size,
			data = copy,
		}
		saveStore()
		notifyConfigChanged()
		return true
	end

	function Configs:CountChanged(name)
		local record = name and configStore.configs[name] or configStore.configs[configStore.active]
		if not record then
			return 0
		end
		return Nerx:CountChanged(record.data)
	end

	function Configs:Export(name)
		local record = name and configStore.configs[name] or configStore.configs[configStore.active]
		if not record then
			return nil
		end
		return Nerx.Storage:Encode({
			name = record.name,
			savedAt = record.savedAt,
			data = record.data,
		})
	end

	function Configs:Import(text, nameOverride)
		local decoded = Nerx.Storage:Decode(text)
		if type(decoded) ~= "table" then
			return false, "invalid JSON"
		end
		local payload = decoded
		local name = trimName(nameOverride or payload.name or payload.Name or "Imported")
		if name == "" then
			name = "Imported"
		end
		if configStore.configs[name] then
			local suffix = 2
			while configStore.configs[name .. " " .. tostring(suffix)] do
				suffix = suffix + 1
			end
			name = name .. " " .. tostring(suffix)
		end
		local snapshot = payload.data or payload
		if type(snapshot) ~= "table"
			or (not snapshot.components and not snapshot.flags and not snapshot.theme and not snapshot.binds) then
			return false, "not a Nerx config"
		end
		configStore.configs[name] = {
			name = name,
			Name = name,
			createdAt = os.time(),
			savedAt = os.time(),
			values = countValues(snapshot),
			size = snapshotSize(snapshot),
			data = snapshot,
		}
		saveStore()
		notifyConfigChanged()
		return true, name
	end

	function Configs:EnsureDefault()
		if next(configStore.configs) == nil then
			self:Save("Default")
		end
	end

	Nerx.Configs = Configs
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
		if child:IsA("GuiObject") and child:GetAttribute("NerxNotify") then
			cards = cards + 1
		end
	end
	if cards >= 4 then
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("GuiObject") and child:GetAttribute("NerxNotify") then
				child:Destroy()
				break
			end
		end
	end

	notifyOrder = notifyOrder + 1
	local card = U.canvas(container, {
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

	U.setGroupTransparency(card, 1)
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
	local pill = U.canvas(indicatorRoot, {
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
			U.setGroupTransparency(self.Root, 1)
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

	if self.Frosted then
		pcall(function()
			self.Frosted:SetEnabled(false)
		end)
	end

	self:ClosePopup()
	for _, connection in ipairs(self.Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	self.Connections = {}
	table.clear(self.Flags)

	for _, currentWindow in ipairs(self.Windows) do
		if currentWindow.ThreeDConnection then
			pcall(function()
				currentWindow.ThreeDConnection:Disconnect()
			end)
			currentWindow.ThreeDConnection = nil
		end
		local threeD = currentWindow.ThreeD
		currentWindow.ThreeD = nil
		if threeD then
			pcall(function()
				if threeD.SurfaceGui then
					threeD.SurfaceGui:Destroy()
				end
			end)
			pcall(function()
				if threeD.Part then
					threeD.Part:Destroy()
				end
			end)
		end
	end

	pcall(function()
		screenGui:Destroy()
	end)
	table.clear(self.Windows)
end

return Nerx



