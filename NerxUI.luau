--[[
	Nerx UI Library · v1.7.1
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
Nerx.Version = "1.7.1"

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

-- Drop GUIs left behind by a previous injection. An old menu or hotkey HUD
-- lingering next to the new one ignores the new frost state, which makes the
-- sync switches look broken.
do
	local seen = {}
	local function purge(container)
		if not container or seen[container] then
			return
		end
		seen[container] = true
		local ok, children = pcall(function()
			return container:GetChildren()
		end)
		if not ok or type(children) ~= "table" then
			return
		end
		for _, child in ipairs(children) do
			if child:IsA("ScreenGui") and string.sub(child.Name, 1, 5) == "Nerx_" then
				pcall(function()
					child:Destroy()
				end)
			end
		end
	end
	purge(parentGui)
	pcall(function()
		purge(LocalPlayer:FindFirstChild("PlayerGui"))
	end)
end

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

-- Subtle control finish: a slightly transparent fill so the card shows
-- through, a 1px stroke whose upper-right half fades away (only the lower-left
-- rim stays lit) and an optional "[" top corner mark on the left border (reference UI).
function U.bevel(parent, options)
	options = options or {}
	local fill = options.Fill or 0
	if fill > 0 then
		parent.BackgroundTransparency = math.clamp(parent.BackgroundTransparency + fill, 0, 1)
	end

	if options.Rim ~= false then
		local stroke = parent:FindFirstChildOfClass("UIStroke")
		if stroke and not stroke:FindFirstChildOfClass("UIGradient") then
			local fade = Instance.new("UIGradient")
			fade.Rotation = 315
			fade.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0.45),
				NumberSequenceKeypoint.new(1, 1),
			})
			fade.Parent = stroke
		end
	end

	if options.Dot then
		-- Tiny "[" bottom corner (top arm cut away) tucked into the bottom-left
		-- of the control: a 3px horizontal tick at the bottom + a 3px vertical stem.
		local mark = U.frame(parent, {
			Name = "NerxBevelMark",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 3 - (options.PadLeft or 0), 1, (options.PadBottom or 0) - 6),
			Size = UDim2.fromOffset(3, 3),
			ZIndex = (parent.ZIndex or 1) + 2,
		})
		U.frame(mark, {
			Name = "NerxBevelMarkH",
			BackgroundColor3 = options.DotColor or Theme.Text,
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 2),
			Size = UDim2.fromOffset(3, 1),
			ZIndex = (parent.ZIndex or 1) + 3,
		})
		U.frame(mark, {
			Name = "NerxBevelMarkV",
			BackgroundColor3 = options.DotColor or Theme.Text,
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(1, 3),
			ZIndex = (parent.ZIndex or 1) + 3,
		})
		return mark
	end
end

function U.ripple(center, color, options)
	-- Shockwave used when the palette changes: a stack of concentric strokes
	-- expands from the clicked control and fades out. Layered thicknesses fake
	-- the bloom of the reference without image assets or extra render passes.
	options = options or {}
	local host = Nerx.PopupHost
	if not host then
		for _, win in ipairs(Nerx.Windows or {}) do
			if win.PopupHost then
				host = win.PopupHost
				break
			end
		end
	end
	if not host or not host.Parent then
		return nil
	end
	if center == nil then
		center = U.viewport() * 0.5
	elseif typeof(center) == "Instance" then
		center = center.AbsolutePosition + center.AbsoluteSize * 0.5
	end
	local scale = U.parentScale(host)
	local origin = host.AbsolutePosition
	local width = math.max(1, host.AbsoluteSize.X / scale)
	local height = math.max(1, host.AbsoluteSize.Y / scale)
	local radius = options.Radius or (math.sqrt(width * width + height * height) * 1.08)
	local duration = options.Duration or 0.62
	local tint = color or Theme.Accent
	local holder = U.frame(host, {
		Name = "NerxRipple",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset((center.X - origin.X) / scale, (center.Y - origin.Y) / scale),
		Size = UDim2.fromOffset(2, 2),
		ZIndex = options.ZIndex or 950,
	})
	local layers = {
		{ Thickness = 24, Transparency = 0.94 },
		{ Thickness = 14, Transparency = 0.88 },
		{ Thickness = 8, Transparency = 0.70 },
		{ Thickness = 3.5, Transparency = 0.34 },
		{ Thickness = 1.5, Transparency = 0.08 },
	}
	local finishAt = 0
	for index, layer in ipairs(layers) do
		local ring = U.frame(holder, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(2, 2),
			ZIndex = holder.ZIndex,
		})
		U.new("UICorner", { CornerRadius = UDim.new(1, 0) }, ring)
		local ringStroke = U.stroke(ring, tint, layer.Transparency, layer.Thickness)
		ringStroke.Name = "NerxRippleStroke"
		local span = duration - (index - 1) * 0.012
		U.tween(ring, TweenInfo.new(span, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(radius * 2, radius * 2),
		})
		U.tween(ringStroke, TweenInfo.new(duration * 0.98, Enum.EasingStyle.Linear), {
			Transparency = 1,
		})
		finishAt = math.max(finishAt, span)
	end
	task.delay(finishAt + 0.08, function()
		if holder.Parent then
			holder:Destroy()
		end
	end)
	return holder
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
	if Nerx.Frosted and card then
		pcall(function()
			Nerx.Frosted:Unregister(card)
		end)
	end
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

	-- Popups are separate roots, so frost them explicitly when the mode is on.
	if Nerx.Frosted and Nerx.Frosted.Enabled then
		Nerx.Frosted:Register(card, { Kind = "popup" })
	end

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
	local icon = U.icon(root, "three-dots-horizontal", 15, Theme.Accent, {
		TextTransparency = 0.15,
		TextStrokeColor3 = Theme.Window,
		TextStrokeTransparency = 0.55,
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
	U.stroke(field, Theme.Stroke, 0.55, 1)
	U.bevel(field, { Fill = 0.1, Dot = true })

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
	U.stroke(root, Theme.Stroke, 0.55, 1)
	U.bevel(root, { Fill = 0.1, Dot = true, PadLeft = 6 })
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
	U.bevel(root, { Fill = 0.1, Dot = true, PadLeft = 7 })
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
		BackgroundTransparency = options.Segment and 1 or 0.35,
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
		if options.Segment then
			-- Segment inside a shared track: only the active one draws a thumb.
			U.tween(root, TWEEN.Fast, {
				BackgroundColor3 = selected and Theme.SurfaceRaised or Theme.White,
				BackgroundTransparency = selected and 0.12 or 1,
			})
			U.tween(stroke, TWEEN.Fast, {
				Transparency = selected and 0.35 or 1,
				Color = selected and Theme.Accent or Theme.Stroke,
			})
		else
			-- Frost-safe: every chip keeps a translucent fill so it never merges
			-- into the white wash; the selected one only steps one tone higher.
			U.tween(root, TWEEN.Fast, {
				BackgroundColor3 = selected and Theme.ChipSelected or Theme.Field,
				BackgroundTransparency = selected and 0.10 or 0.45,
			})
			U.tween(stroke, TWEEN.Fast, {
				Transparency = selected and 0.35 or 0.60,
				Color = selected and Theme.Accent or Theme.Stroke,
			})
		end

		if textLabel then
			U.tween(textLabel, TWEEN.Fast, {
				TextColor3 = selected and Theme.Text or Theme.Muted,
				TextTransparency = selected and 0.02 or 0.20,
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
		BackgroundTransparency = container and 0.45 or 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, height),
	})
	U.corner(root, 8)
	if container then
		U.stroke(root, Theme.Stroke, 0.55, 1)
		-- 1px specular along the top of the track: the "3D" hint, no gradient.
		U.frame(root, {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.92,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, 1),
			Size = UDim2.new(1, -20, 0, 1),
			ZIndex = 0,
		})
	end

	local buttons = {}
	local value = config.Selected or (items[1] and (items[1].Name or items[1])) or nil
	local count = math.max(1, #items)
	local segmentWidth = width / count
	local api = { Root = root, Value = value, Width = width }

	local thumb
	if container then
		thumb = U.frame(root, {
			BackgroundColor3 = Theme.SurfaceRaised,
			BackgroundTransparency = 0.18,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.fromOffset(math.max(1, segmentWidth - 4), height - 4),
			Visible = false,
			ZIndex = 0,
		})
		U.corner(thumb, 6)
		U.stroke(thumb, Theme.Accent, 0.55, 1)
	end

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
		local info = animate and TWEEN.Default or TWEEN.Fast
		local activeX
		for index, button in ipairs(buttons) do
			if button.Name == value then
				activeX = (index - 1) * segmentWidth
				break
			end
		end
		if thumb then
			thumb.Visible = activeX ~= nil
			if activeX then
				U.tween(thumb, info, { Position = UDim2.fromOffset(activeX + 2, 2) })
			end
		end
		for _, button in ipairs(buttons) do
			local active = button.Name == value
			if not thumb then
				U.tween(button.Root, info, {
					BackgroundColor3 = active and Theme.ChipSelected or Theme.Field,
					BackgroundTransparency = active and 0.15 or 0.65,
				})
			end
			U.tween(button.Label, info, {
				TextColor3 = active and selectedText or Theme.Muted,
				TextTransparency = active and 0.02 or 0.22,
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
		if thumb then
			thumb.Size = UDim2.fromOffset(math.max(1, segmentWidth - 4), height - 4)
		end
		render(false)
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
	U.bevel(root, { Fill = 0.1, Dot = true })
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
	-- Room for the header action pills, which are taller than the label row.
	-- Without this the first section in the scroll gets its actions clipped flat.
	U.padding(root, 4, 0, 0, 0)
	root.LayoutOrder = page.BlockIndex + 1000
	page.BlockIndex = page.BlockIndex + 1

	local labelRow = U.frame(root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 0, 15),
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
		-- Neverlose-style depth: a half-transparent fill plus one flat hairline.
		-- No gradient rim, so switching palettes can never produce jagged edges.
		BackgroundTransparency = useCard and 0.5 or 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(useCard and 4 or 0, 20),
		Size = UDim2.new(1, useCard and -8 or 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = useCard,
	})
	U.corner(card, useCard and 10 or 8)
	local cardStroke = U.stroke(card, Theme.Stroke, useCard and 0.65 or 1, 1)
	if useCard then
		-- Raised glass plate: a fading 1 px reflection along the top edge. The
		-- fill stays half-transparent, so no drop shadow is drawn underneath it
		-- (a blurred shadow would show through the glass and muddy the card).
		local topLight = U.frame(root, {
			Name = "NerxCardTopLight",
			BackgroundColor3 = Theme.White,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(16, 21),
			Size = UDim2.new(1, -32, 0, 1),
			ZIndex = 2,
		})
		local lightFade = Instance.new("UIGradient")
		lightFade.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.68),
			NumberSequenceKeypoint.new(1, 1),
		})
		lightFade.Parent = topLight
	end
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
		U.stroke(field, Theme.Stroke, 0.55, 1)
		U.bevel(field, { Fill = 0.1, Dot = true })
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
		U.stroke(field, Theme.Stroke, 0.55, 1)
		U.bevel(field, { Fill = 0.1, Dot = true })
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
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset((action.Icon and 26 or 22) + textWidth + extra, 18),
		})
		U.corner(root, 9)
		local actionStroke = U.stroke(root, Theme.Stroke, 0.60, 1)
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
				U.tween(root, TWEEN.Fast, {
					BackgroundColor3 = Theme.SurfaceRaised,
					BackgroundTransparency = 0.15,
				})
				U.tween(label, TWEEN.Fast, { TextColor3 = Theme.Text, TextTransparency = 0.02 })
				U.tween(actionStroke, TWEEN.Fast, { Color = Theme.Accent, Transparency = 0.35 })
				if dot then
					U.tween(dot, TWEEN.Fast, { BackgroundTransparency = 0 })
				end
			else
				U.tween(root, TWEEN.Fast, {
					BackgroundColor3 = Theme.Field,
					BackgroundTransparency = 0.55,
				})
				U.tween(label, TWEEN.Fast, { TextColor3 = Theme.Muted, TextTransparency = 0.22 })
				U.tween(actionStroke, TWEEN.Fast, { Color = Theme.Stroke, Transparency = 0.60 })
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
		Size = UDim2.new(1, -40, 0, 30),
		Visible = false,
		ZIndex = 3,
	})
	page.ChipBar = chipBar
	local chipHolder = U.frame(chipBar, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 30),
		ZIndex = 3,
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
		local top = 18 + 24 + (self.HasChips and 40 or 0) + 14
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
				Segment = true,
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
		end

		-- One shared track behind the whole selector row (plan B): the active
		-- segment draws a raised thumb instead of every chip having its own pill.
		local gap = 6
		local trackWidth = 8
		for _, chip in ipairs(chips) do
			trackWidth = trackWidth + chip.Width + gap
		end
		trackWidth = math.max(60, trackWidth - gap)
		local track = U.frame(chipHolder, {
			BackgroundColor3 = Theme.Field,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(trackWidth, 30),
			ZIndex = 3,
		})
		U.corner(track, 15)
		U.stroke(track, Theme.Stroke, 0.55, 1)
		U.frame(track, {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.92,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(12, 1),
			Size = UDim2.new(1, -24, 0, 1),
			ZIndex = 3,
		})
		local cursor = 4
		for _, chip in ipairs(chips) do
			chip.Root.Parent = track
			chip.Root.Position = UDim2.fromOffset(cursor, 2)
			chip.Root.ZIndex = 4
			cursor = cursor + chip.Width + gap
		end
		self.ChipTrack = track

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
		headerControls.Position = UDim2.new(1, -20, 0, 54)
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
	U.corner(root, 14)
	U.stroke(root, Theme.Stroke, 0.7, 1)
	U.shadow(root, "soft")
	local windowLight = U.frame(root, {
		Name = "NerxWindowTopLight",
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(14, 1),
		Size = UDim2.new(1, -28, 0, 1),
		ZIndex = 6,
	})
	local windowLightFade = Instance.new("UIGradient")
	windowLightFade.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.62),
		NumberSequenceKeypoint.new(1, 1),
	})
	windowLightFade.Parent = windowLight
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
	U.bevel(saveButton, { Dot = true })
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
	local searchStroke = U.stroke(search, Theme.Stroke, 0.55, 1)
	U.bevel(search, { Fill = 0.08 })
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
	U.bevel(shieldButton, { Fill = 0.08 })
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
		searchStroke.Transparency = 0.25
		searchIcon.TextTransparency = 0.05
	end)
	U.connect(searchBox.FocusLost, function(enterPressed)
		U.tween(search, TWEEN.Fast, { BackgroundColor3 = Theme.FieldDeep })
		searchStroke.Transparency = 0.55
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
				Nerx.Frosted:Refresh()
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
			"ScrollBarImageColor3", "TextStrokeColor3",
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
	local overlayEnabled = false
	-- Optional: frost the floating Hotkeys HUD pills together with the menu.
	local frostHud = false

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
	local activeOrder = {}
	local headerTextToken = 0

	-- The dynamic title must follow what is *currently* active: once a bind is
	-- turned off it drops out of the stack, so the header reverts (and its width
	-- is re-measured) instead of sticking to the last-used name forever.
	local function refreshTriggeredName()
		lastTriggeredName = nil
		for index = #activeOrder, 1, -1 do
			local id = activeOrder[index]
			if activeStates[id] then
				for _, bind in ipairs(binds) do
					if bind.Id == id then
						lastTriggeredName = tostring(bind.Name or "Bind")
						break
					end
				end
				if lastTriggeredName then
					return
				end
			else
				table.remove(activeOrder, index)
			end
		end
	end

	local function trackActiveOrder(bind)
		if not bind then
			return
		end
		for index = #activeOrder, 1, -1 do
			if activeOrder[index] == bind.Id then
				table.remove(activeOrder, index)
			end
		end
		if activeStates[bind.Id] and bind.Trigger ~= "Condition" then
			activeOrder[#activeOrder + 1] = bind.Id
		end
		refreshTriggeredName()
	end
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
	local HOTKEY_ICON_FADE = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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
		if frostHud and Nerx.Frosted then
			Nerx.Frosted:Register(keyCard, { Kind = "card", Radius = 5, Opacity = 0.55, SheenScale = 2, Rim = false, Halo = false, Chroma = false })
		end
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
		-- Second icon stacked on the same spot: switching toggle-left/right
		-- cross-fades between the two instead of snapping the glyph.
		local keyIconAlt = U.icon(keyCard, data.KeyIcon or "toggle-left", 13, HOTKEY_TEXT, {
			Position = keyIcon.Position,
			Size = UDim2.fromOffset(13, 13),
			TextTransparency = 1,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeTransparency = 0.78,
			ZIndex = 4,
		})
		keyIconAlt.Visible = data.KeyKind == "icon"
		local nameCard = hotkeyPill(row, data.NameBoxWidth, HOTKEY_ROW_HEIGHT, HOTKEY_NAME_CARD, HOTKEY_NAME_TRANSPARENCY)
		nameCard.Position = UDim2.fromOffset(data.NameX, 0)
		if frostHud and Nerx.Frosted then
			Nerx.Frosted:Register(nameCard, { Kind = "card", Radius = 5, Opacity = 0.55, SheenScale = 2, Rim = false, Halo = false, Chroma = false })
		end
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
			KeyIconAlt = keyIconAlt,
			IconShown = "main",
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
		local keyIconAlt = entry.KeyIconAlt
		local nameCard = entry.NameCard
		local nameLabel = entry.NameLabel

		if data.KeyKind == "icon" then
			keyLabel.Visible = false
			keyIcon.Visible = true
			keyIconAlt.Visible = true
			local iconX = math.floor((data.KeyBoxWidth - 13) * 0.5)
			local iconY = math.floor((HOTKEY_ROW_HEIGHT - 13) * 0.5)
			local targetTransparency = data.KeyTransparency or 0.02
			for _, icon in ipairs({ keyIcon, keyIconAlt }) do
				icon.Position = UDim2.fromOffset(iconX, iconY)
				icon.Size = UDim2.fromOffset(13, 13)
				icon.TextColor3 = HOTKEY_TEXT
			end
			if entry.KeyKind ~= "icon" then
				-- Coming back from a text style: fade the icon in.
				keyIcon.Text = data.KeyIcon
				keyIcon.TextTransparency = 1
				keyIconAlt.TextTransparency = 1
				entry.IconShown = "main"
				U.tween(keyIcon, HOTKEY_ICON_FADE, { TextTransparency = targetTransparency })
			else
				local shown = entry.IconShown == "alt" and keyIconAlt or keyIcon
				local hidden = (shown == keyIcon) and keyIconAlt or keyIcon
				if shown.Text ~= data.KeyIcon then
					-- Cross-fade the old glyph out and the new ones in, which reads
					-- as the switch knob sliding instead of an instant icon swap.
					hidden.Text = data.KeyIcon
					hidden.TextColor3 = HOTKEY_TEXT
					hidden.TextTransparency = 1
					U.tween(shown, HOTKEY_ICON_FADE, { TextTransparency = 1 })
					U.tween(hidden, HOTKEY_ICON_FADE, { TextTransparency = targetTransparency })
					entry.IconShown = (hidden == keyIcon) and "main" or "alt"
				else
					U.tween(shown, TWEEN.Fast, { TextTransparency = targetTransparency })
					hidden.TextTransparency = 1
				end
			end
		else
			keyIcon.Visible = false
			keyIconAlt.Visible = false
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

		-- Re-apply the HUD palette so a theme switch never leaves old black
		-- pills behind on a light theme.
		keyCard.BackgroundColor3 = HOTKEY_KEY_CARD
		nameCard.BackgroundColor3 = HOTKEY_NAME_CARD
		keyLabel.TextColor3 = HOTKEY_TEXT
		keyIcon.TextColor3 = HOTKEY_TEXT
		if keyIconAlt then
			keyIconAlt.TextColor3 = HOTKEY_TEXT
		end
		nameLabel.TextColor3 = HOTKEY_TEXT

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
		if Nerx.Frosted then
			if entry.KeyCard then
				pcall(function()
					Nerx.Frosted:Unregister(entry.KeyCard)
				end)
			end
			if entry.NameCard then
				pcall(function()
					Nerx.Frosted:Unregister(entry.NameCard)
				end)
			end
		end
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
			-- Fade the old title out, swap the text and fade the new one in, so a
			-- bind turning off glides back to "Hotkeys" instead of popping.
			headerTextToken = headerTextToken + 1
			local textToken = headerTextToken
			U.tween(headerLabel, TWEEN.Fast, { TextTransparency = 1 })
			task.delay(0.09, function()
				if textToken ~= headerTextToken or not headerLabel.Parent then
					return
				end
				headerLabel.Text = headerText
				headerLabel.TextTransparency = 1
				U.tween(headerLabel, TWEEN.Popup, { TextTransparency = 0.02 })
			end)
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

		-- Keep the header in the active palette as well.
		overlayHeaderCard.BackgroundColor3 = HOTKEY_CARD
		headerLabel.TextColor3 = HOTKEY_TEXT
		if overlayIconFallback then
			overlayIconFallback.TextColor3 = HOTKEY_TEXT
		end
		if overlayIconImage then
			overlayIconImage.ImageColor3 = HOTKEY_TEXT
		end
		if overlayHeaderDotsIcon then
			overlayHeaderDotsIcon.TextColor3 = Theme.Accent
			overlayHeaderDotsIcon.TextStrokeColor3 = Theme.Window
		end

		if hotkeySettingsOpen and positionHotkeySettings then
			task.defer(positionHotkeySettings)
		end
	end

	local function createOverlayHeader(panelWidth, headerText, iconX, titleX, titleWidth, dotsX)
		local headerCard = hotkeyPill(overlayRoot, panelWidth, HOTKEY_HEADER_HEIGHT)
		headerCard.Position = UDim2.fromOffset(overlayRightAligned and 14 or -14, 0)
		U.tween(headerCard, TWEEN.Popup, { Position = UDim2.fromOffset(0, 0) })
		overlayHeaderCard = headerCard
		if frostHud and Nerx.Frosted then
			Nerx.Frosted:Register(headerCard, { Kind = "card", Radius = 5, Opacity = 0.55, SheenScale = 2, Rim = false, Halo = false, Chroma = false })
		end
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
		local dotsIcon = U.icon(dots, "three-dots-horizontal", 12, Theme.Accent, {
			Size = UDim2.fromScale(1, 1),
			TextTransparency = hotkeySettingsOpen and 0 or 0.15,
			TextStrokeColor3 = Theme.Window,
			TextStrokeTransparency = 0.55,
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
							if Nerx.Frosted then
								if entry.KeyCard then
									pcall(function()
										Nerx.Frosted:Unregister(entry.KeyCard)
									end)
								end
								if entry.NameCard then
									pcall(function()
										Nerx.Frosted:Unregister(entry.NameCard)
									end)
								end
							end
							if entry.Frame then
								entry.Frame:Destroy()
							end
						end
						table.clear(overlayEntries)
						if overlayHeaderCard then
							if Nerx.Frosted then
								pcall(function()
									Nerx.Frosted:Unregister(overlayHeaderCard)
								end)
							end
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
			U.tween(overlayHeaderDotsIcon, TWEEN.Fast, { TextTransparency = 0.15 })
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
			U.tween(overlayHeaderDotsIcon, TWEEN.Fast, { TextTransparency = 0 })
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
		trackActiveOrder(bind)
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
		trackActiveOrder(bind)
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

	-- Register / unregister the floating HUD pills with the frosted-glass mode.
	function BindManager:SetFrosted(enabled)
		enabled = enabled == true
		frostHud = enabled
		if not Nerx.Frosted then
			return
		end
		local function applyPill(pill)
			if not pill then
				return
			end
			if enabled then
				Nerx.Frosted:Register(pill, { Kind = "card", Radius = 5, Opacity = 0.55, SheenScale = 2, Rim = false, Halo = false, Chroma = false })
			else
				pcall(function()
					Nerx.Frosted:Unregister(pill)
				end)
			end
		end
		for _, entry in pairs(overlayEntries) do
			applyPill(entry.KeyCard)
			applyPill(entry.NameCard)
		end
		applyPill(overlayHeaderCard)
	end

	function BindManager:IsFrosted()
		return frostHud
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
	local GRAIN_TEXTURE = "rbxasset://textures/particles/smoke_main.dds"

	-- Ported from the web liquid-glass stack:
	--   1. blurred backdrop  -> scene BlurEffect + translucent surfaces
	--   2. tint              -> white wash on top of the glass
	--   3. specular / grain  -> tiled grain + diagonal sweep
	--   4. gradient border   -> inner hairline stroke with a soft gradient
	--   5. chromatic fringe  -> second, slightly larger red/blue stroke
	--   6. outer bloom       -> wide transparent stroke
	local DEFAULT_PARAMS = {
		Blur = 0,
		Opacity = 0.32,
		Tint = 0.25,
		Grain = 0.40,
		Sheen = 0.60,
		Sweep = 0.35,
		Dispersion = 0.35,
		Outline = 0.55,
		Thickness = 1.0,
		Radius = 12,
		Press = 0.965,
		Spring = 22,
	}

	local Frosted = {
		Enabled = false,
		Params = {},
		Presets = {
			Clear = { Blur = 0, Opacity = 0.20, Tint = 0.14, Grain = 0.20, Sheen = 0.35, Sweep = 0.18, Dispersion = 0.30, Outline = 0.50, Thickness = 1 },
			Frosted = { Blur = 0, Opacity = 0.32, Tint = 0.25, Grain = 0.40, Sheen = 0.60, Sweep = 0.35, Dispersion = 0.35, Outline = 0.55, Thickness = 1.0 },
			Heavy = { Blur = 12, Opacity = 0.45, Tint = 0.38, Grain = 0.65, Sheen = 0.85, Sweep = 0.55, Dispersion = 0.75, Outline = 0.95, Thickness = 2 },
		},
		OnChanged = {},
	}
	for key, value in pairs(DEFAULT_PARAMS) do
		Frosted.Params[key] = value
	end
	Nerx.Frosted = Frosted

	local targets = {}
	local surfaceStore = {}
	local layerStore = {}
	local blurEffect
	local sweepConnection
	local sweepClock = 0

	local function ensureBlur()
		local blur = Lighting:FindFirstChild("NerxFrostedBlur")
		if not (blur and blur:IsA("BlurEffect")) then
			blur = Instance.new("BlurEffect")
			blur.Name = "NerxFrostedBlur"
			blur.Size = 0
			blur.Enabled = false
			blur.Parent = Lighting
		end
		blurEffect = blur
		return blur
	end

	local function findTarget(root)
		for index, entry in ipairs(targets) do
			if entry.Root == root then
				return entry, index
			end
		end
		return nil
	end

	local function isExcluded(entry, object)
		local list = entry.Options and entry.Options.Exclude
		if not list then
			return false
		end
		for _, candidate in list do
			if candidate == object then
				return true
			end
		end
		return false
	end

	local function paintSurfaces(entry)
		local root = entry.Root
		if not root or not root.Parent then
			return
		end
		local options = entry.Options or {}
		local amount = Frosted.Params.Opacity * (options.Opacity or 1)
		local ceiling = options.MaxTransparency or 0.92
		local store = surfaceStore[root]
		if not store then
			store = {}
			surfaceStore[root] = store
		end
		-- Only the outer shell becomes translucent. Making every nested frame
		-- translucent was exposing inner preview blocks and card fills as
		-- washed-out rectangles with visible corners ("角料").
		local list = { root }
		if options.Kind == "window" then
			local rootSize = root.AbsoluteSize
			if rootSize.X > 0 and rootSize.Y > 0 then
				local rootArea = rootSize.X * rootSize.Y
				for _, child in ipairs(root:GetChildren()) do
					if child:IsA("GuiObject") then
						local size = child.AbsoluteSize
						if size.X * size.Y >= rootArea * 0.10 then
							local okChild, childTransparency = pcall(function()
								return child.BackgroundTransparency
							end)
							if okChild and childTransparency and childTransparency < 0.99 then
								list[#list + 1] = child
							end
						end
					end
				end
			end
		end
		for _, object in ipairs(list) do
			if object:IsA("GuiObject") and not object:GetAttribute("NerxFrostLayer") and not isExcluded(entry, object) then
				local ok, transparency = pcall(function()
					return object.BackgroundTransparency
				end)
				if ok and transparency and transparency < 0.99 then
					if store[object] == nil then
						store[object] = transparency
					end
					-- Blend toward transparent instead of adding, so panels that
					-- are already semi-transparent never go fully invisible.
					local base = store[object]
					object.BackgroundTransparency = math.clamp(base + amount * (1 - base), 0, ceiling)
				end
			end
		end
	end

	local function restoreSurfaces(root)
		local store = surfaceStore[root]
		if not store then
			return
		end
		for object, original in pairs(store) do
			if object.Parent then
				object.BackgroundTransparency = original
			end
		end
		surfaceStore[root] = nil
	end

	local function newLayer(root, name, className, z, radius)
		local frame = Instance.new(className)
		frame.Name = name
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1, 1)
		frame.ZIndex = z
		frame.Active = false
		frame:SetAttribute("NerxFrostLayer", true)
		U.corner(frame, radius)
		frame.Parent = root
		return frame
	end

	-- The Radius param must reshape the panel itself, not just the glass sheets.
	-- Matching both keeps the corners concentric, so no stray corner scraps can
	-- appear while still letting the radius be adjusted.
	local shapeStore = {}

	local function applyShape(root, radius)
		if not root or not root:IsA("GuiObject") then
			return
		end
		local corners = {}
		for _, child in ipairs(root:GetChildren()) do
			if child:IsA("UICorner") then
				corners[#corners + 1] = child
			end
		end
		local store = shapeStore[root]
		if not store then
			store = { Corners = {}, Created = nil }
			for _, corner in ipairs(corners) do
				store.Corners[corner] = corner.CornerRadius
			end
			shapeStore[root] = store
		end
		if #corners == 0 then
			local corner = Instance.new("UICorner")
			corner.Parent = root
			store.Created = corner
			corners[1] = corner
		end
		local value = UDim.new(0, math.max(0, radius))
		for _, corner in ipairs(corners) do
			corner.CornerRadius = value
		end
	end

	local function restoreShape(root)
		local store = shapeStore[root]
		if not store then
			return
		end
		for corner, value in pairs(store.Corners) do
			if corner.Parent then
				corner.CornerRadius = value
			end
		end
		if store.Created and store.Created.Parent then
			store.Created:Destroy()
		end
		shapeStore[root] = nil
	end

	-- Repainting must update the existing UICorner instead of stacking a new one;
	-- stacked corners keep an old radius alive and show as corner scraps.
	local function setCorner(object, radius)
		local corner = object:FindFirstChildOfClass("UICorner")
		if not corner then
			corner = Instance.new("UICorner")
			corner.Parent = object
		end
		corner.CornerRadius = UDim.new(0, math.max(0, radius))
	end

	-- Shared screen-space sweep: one wave travels left -> right across the whole
	-- screen and every frosted panel samples it at its own screen position, so
	-- the HUD, the menu and open popups all catch the same sweep in order.
	local SWEEP_PAD = 420
	local sweepX = -SWEEP_PAD

	local function applySweepOffset(root, layer)
		local position = root.AbsolutePosition
		local size = root.AbsoluteSize
		local localX = (sweepX - position.X) / math.max(1, size.X)
		layer.gradient.Offset = Vector2.new(localX - 0.5, 0)
	end

	local function buildLayer(entry)
		local root = entry.Root
		if not root or not root.Parent then
			return nil
		end
		local cached = layerStore[root]
		if cached and cached.sheen.Parent then
			return cached
		end
		local options = entry.Options or {}
		-- Layers must sit above the panel background but BELOW the menu content,
		-- otherwise the wash covers labels and controls. Content uses ZIndex
		-- 1..10, so every layer shares ZIndex 0 and stacks by creation order.
		local baseZ = options.Layer or 0
		local radius = options.Radius or Frosted.Params.Radius

		-- 1. Tint: a very light white wash, like rgba(255,255,255,.06).
		local tint = Instance.new("Frame")
		tint.Name = "NerxFrostTint"
		tint.BackgroundColor3 = Color3.new(1, 1, 1)
		tint.BackgroundTransparency = 0.94
		tint.BorderSizePixel = 0
		tint.Size = UDim2.fromScale(1, 1)
		tint.ZIndex = baseZ
		tint.Active = false
		tint:SetAttribute("NerxFrostLayer", true)
		setCorner(tint, radius)
		local tintGradient = Instance.new("UIGradient")
		tintGradient.Rotation = 90
		tintGradient.Parent = tint
		tint.Parent = root

		-- 2. Grain: tiled soft smoke sells the "frosted" surface.
		local grain = Instance.new("ImageLabel")
		grain.Name = "NerxFrostGrain"
		grain.BackgroundTransparency = 1
		grain.BorderSizePixel = 0
		grain.Size = UDim2.fromScale(1, 1)
		grain.ScaleType = Enum.ScaleType.Tile
		grain.TileSize = UDim2.fromOffset(120, 120)
		grain.Image = GRAIN_TEXTURE
		grain.ImageColor3 = Color3.new(1, 1, 1)
		grain.ImageTransparency = 0.9
		grain.ZIndex = baseZ
		grain.Active = false
		grain:SetAttribute("NerxFrostLayer", true)
		setCorner(grain, radius)
		grain.Parent = root

		-- 3. Sheen: one diagonal specular band. Its offset is driven in screen
		-- space, so every frosted surface shares the same travelling wave.
		local sheen = Instance.new("Frame")
		sheen.Name = "NerxFrostSheen"
		sheen.BackgroundColor3 = Color3.new(1, 1, 1)
		sheen.BackgroundTransparency = 0
		sheen.BorderSizePixel = 0
		sheen.Size = UDim2.fromScale(1, 1)
		sheen.ZIndex = baseZ
		sheen.Active = false
		sheen:SetAttribute("NerxFrostLayer", true)
		setCorner(sheen, radius)
		local gradient = Instance.new("UIGradient")
		gradient.Rotation = 20
		gradient.Parent = sheen
		sheen.Parent = root

		-- 4. Gradient hairline border, inset by one pixel.
		local rim = Instance.new("Frame")
		rim.Name = "NerxFrostRim"
		rim.BackgroundTransparency = 1
		rim.BorderSizePixel = 0
		rim.Position = UDim2.fromOffset(1, 1)
		rim.Size = UDim2.new(1, -2, 1, -2)
		rim.ZIndex = baseZ
		rim.Active = false
		rim:SetAttribute("NerxFrostLayer", true)
		setCorner(rim, math.max(0, radius - 1))
		local stroke = Instance.new("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Color = Color3.new(1, 1, 1)
		local strokeGradient = Instance.new("UIGradient")
		strokeGradient.Rotation = 90
		strokeGradient.Parent = stroke
		stroke.Parent = rim
		rim.Parent = root

		-- 5. Chromatic fringe: a slightly larger stroke split into R/B.
		local chroma = Instance.new("Frame")
		chroma.Name = "NerxFrostChroma"
		chroma.BackgroundTransparency = 1
		chroma.BorderSizePixel = 0
		chroma.Position = UDim2.fromOffset(-1, -1)
		chroma.Size = UDim2.new(1, 2, 1, 2)
		chroma.ZIndex = baseZ
		chroma.Active = false
		chroma:SetAttribute("NerxFrostLayer", true)
		setCorner(chroma, radius + 1)
		local chromaStroke = Instance.new("UIStroke")
		chromaStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		chromaStroke.LineJoinMode = Enum.LineJoinMode.Round
		chromaStroke.Color = Color3.new(1, 1, 1)
		chromaStroke.Transparency = 0.9
		local chromaGradient = Instance.new("UIGradient")
		chromaGradient.Rotation = 35
		chromaGradient.Parent = chromaStroke
		chromaStroke.Parent = chroma
		chroma.Parent = root

		-- 6. Outer bloom: wide, very transparent stroke.
		local halo = Instance.new("Frame")
		halo.Name = "NerxFrostHalo"
		halo.BackgroundTransparency = 1
		halo.BorderSizePixel = 0
		halo.Size = UDim2.fromScale(1, 1)
		halo.ZIndex = baseZ
		halo.Active = false
		halo:SetAttribute("NerxFrostLayer", true)
		setCorner(halo, radius)
		local haloStroke = Instance.new("UIStroke")
		haloStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		-- UIStroke defaults to black; without this the "bloom" rendered as a dark
		-- square band hugging every rounded card (very visible on the HUD).
		haloStroke.Color = Color3.new(1, 1, 1)
		haloStroke.Thickness = 5
		haloStroke.Transparency = 0.9
		haloStroke.Parent = halo
		halo.Parent = root

		local layer = {
			tint = tint,
			tintGradient = tintGradient,
			grain = grain,
			sheen = sheen,
			gradient = gradient,
			rim = rim,
			stroke = stroke,
			strokeGradient = strokeGradient,
			chroma = chroma,
			chromaStroke = chromaStroke,
			chromaGradient = chromaGradient,
			halo = halo,
			haloStroke = haloStroke,
		}
		layerStore[root] = layer
		return layer
	end

	local function paintLayer(entry)
		local layer = buildLayer(entry)
		if not layer then
			return
		end
		local options = entry.Options or {}
		local params = Frosted.Params
		local radius = options.Radius or params.Radius
		-- Reshape the panel so its corners stay concentric with the glass.
		applyShape(entry.Root, radius)
		local sheenAmount = options.Sheen == false and 0 or params.Sheen * (options.SheenScale or 1)
		local split = math.clamp(params.Dispersion * (options.DispersionScale or 1), 0, 1)

		setCorner(layer.tint, radius)
		setCorner(layer.grain, radius)
		setCorner(layer.sheen, radius)
		setCorner(layer.rim, math.max(0, radius - 1))
		setCorner(layer.chroma, radius + 1)
		setCorner(layer.halo, radius)

		-- BackgroundTransparency stays 0: the UIGradient below drives the actual
		-- alpha per row (Roblox multiplies both, so a non-zero base would hide it).
		layer.tint.BackgroundTransparency = 0
		layer.tintGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
		layer.tintGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, math.clamp(1 - params.Tint * 0.90, 0, 1)),
			NumberSequenceKeypoint.new(0.40, math.clamp(1 - params.Tint * 0.45, 0, 1)),
			NumberSequenceKeypoint.new(1, math.clamp(1 - params.Tint * 0.15, 0, 1)),
		})
		layer.grain.ImageTransparency = math.clamp(1 - params.Grain * 0.55, 0, 1)
		layer.grain.Visible = params.Grain > 0.01

		-- A single soft band in the middle of the gradient; the screen-space
		-- offset below moves it as one shared wave across every frosted surface.
		local sheenSequence = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.35, 1),
			NumberSequenceKeypoint.new(0.43, 1 - sheenAmount * 0.07),
			NumberSequenceKeypoint.new(0.5, 1 - sheenAmount * 0.22),
			NumberSequenceKeypoint.new(0.57, 1 - sheenAmount * 0.07),
			NumberSequenceKeypoint.new(0.65, 1),
			NumberSequenceKeypoint.new(1, 1),
		})
		layer.gradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
		layer.gradient.Transparency = sheenSequence
		local sheenVisible = sheenAmount > 0.01 and options.Sheen ~= false
		layer.sheen.Visible = sheenVisible
		applySweepOffset(entry.Root, layer)

		-- Hairline: bright at the top, fading toward the bottom.
		layer.strokeGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
		layer.strokeGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, math.clamp(1 - params.Outline * 0.95, 0, 1)),
			NumberSequenceKeypoint.new(0.5, math.clamp(1 - params.Outline * 0.40, 0, 1)),
			NumberSequenceKeypoint.new(1, math.clamp(1 - params.Outline * 0.65, 0, 1)),
		})
		layer.stroke.Thickness = math.max(1, options.Thickness or params.Thickness - 0.5)
		layer.rim.Visible = options.Rim ~= false and params.Outline > 0.01

		local function fringe(color, amount)
			return Color3.new(
				color.R + (1 - color.R) * (1 - amount),
				color.G + (1 - color.G) * (1 - amount),
				color.B + (1 - color.B) * (1 - amount)
			)
		end
		layer.chromaGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, fringe(Color3.fromRGB(255, 90, 90), split)),
			ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, fringe(Color3.fromRGB(90, 150, 255), split)),
		})
		layer.chromaStroke.Thickness = math.max(1, (options.Thickness or params.Thickness))
		layer.chromaStroke.Transparency = math.clamp(1 - split * 0.55, 0, 1)
		layer.chroma.Visible = options.Chroma ~= false and split > 0.02 and options.Rim ~= false

		layer.haloStroke.Thickness = math.max(3, (options.Thickness or params.Thickness) * 4)
		layer.haloStroke.Transparency = math.clamp(0.98 - params.Outline * 0.22, 0, 1)
		layer.halo.Visible = options.Halo ~= false and options.Rim ~= false and params.Outline > 0.05
	end

	local function destroyLayer(root)
		local layer = layerStore[root]
		if not layer then
			return
		end
		for _, name in ipairs({ "tint", "grain", "sheen", "rim", "chroma", "halo" }) do
			if layer[name] then
				layer[name]:Destroy()
			end
		end
		layerStore[root] = nil
	end

	local function startSweep()
		if sweepConnection then
			return
		end
		sweepConnection = RunService.RenderStepped:Connect(function(dt)
			if not Frosted.Enabled then
				sweepConnection:Disconnect()
				sweepConnection = nil
				return
			end
			-- One global wave: it starts left of the screen and ends right of it,
			-- so the sweep enters the left HUD first and travels into the menu.
			sweepClock = (sweepClock + dt * (0.05 + Frosted.Params.Sweep * 0.35)) % 1
			local viewport = U.viewport()
			sweepX = -SWEEP_PAD + sweepClock * (viewport.X + SWEEP_PAD * 2)
			for root, layer in pairs(layerStore) do
				if layer.sheen.Parent then
					applySweepOffset(root, layer)
				end
			end
		end)
	end

	local function notifyChanged()
		for _, callback in ipairs(Frosted.OnChanged) do
			task.spawn(pcall, callback, Frosted.Params, Frosted.Enabled)
		end
	end

	function Frosted:Register(root, options)
		if not root then
			return nil
		end
		if findTarget(root) then
			return nil
		end
		local entry = { Root = root, Options = options or {} }
		table.insert(targets, entry)
		if self.Enabled then
			paintSurfaces(entry)
			paintLayer(entry)
		end
		return entry
	end

	function Frosted:Unregister(root)
		local entry, index = findTarget(root)
		if not entry then
			return false
		end
		restoreSurfaces(root)
		restoreShape(root)
		destroyLayer(root)
		table.remove(targets, index)
		return true
	end

	function Frosted:RegisterWindow(window)
		if window and window.Root then
			return self:Register(window.Root, { Kind = "window" })
		end
		return nil
	end

	function Frosted:SetParams(partial)
		if type(partial) ~= "table" then
			return self.Params
		end
		local opacityChanged = false
		for key, value in pairs(partial) do
			if typeof(value) == "number" then
				if key == "Opacity" and value ~= self.Params.Opacity then
					opacityChanged = true
				end
				self.Params[key] = value
			elseif self.Params[key] ~= nil and typeof(value) == typeof(self.Params[key]) then
				self.Params[key] = value
			end
		end
		self:Refresh(not opacityChanged)
		return self.Params
	end

	function Frosted:Apply(partial)
		return self:SetParams(partial)
	end

	function Frosted:GetParams()
		local copy = {}
		for key, value in pairs(self.Params) do
			copy[key] = value
		end
		return copy
	end

	function Frosted:Reset()
		for key, value in pairs(DEFAULT_PARAMS) do
			self.Params[key] = value
		end
		self:Refresh()
	end

	function Frosted:ApplyPreset(name)
		local preset = self.Presets[name]
		if type(preset) ~= "table" then
			return false
		end
		for key, value in pairs(preset) do
			self.Params[key] = value
		end
		self:Refresh()
		return true
	end

	function Frosted:Refresh(skipSurfaces)
		local blur = ensureBlur()
		blur.Size = self.Enabled and self.Params.Blur or 0
		blur.Enabled = self.Enabled and self.Params.Blur > 0.5
		if not self.Enabled then
			return
		end
		for _, win in ipairs(Nerx.Windows) do
			if win.Root and not findTarget(win.Root) then
				table.insert(targets, { Root = win.Root, Options = { Kind = "window" } })
			end
		end
		for _, entry in ipairs(targets) do
			if entry.Root and entry.Root.Parent then
				if not skipSurfaces then
					paintSurfaces(entry)
				end
				paintLayer(entry)
			end
		end
		startSweep()
		notifyChanged()
	end

	function Frosted:SetEnabled(enabled)
		enabled = enabled == true
		if self.Enabled == enabled then
			if enabled then
				self:Refresh()
			end
			return
		end
		self.Enabled = enabled
		if enabled then
			self:Refresh()
		else
			if sweepConnection then
				sweepConnection:Disconnect()
				sweepConnection = nil
			end
			if blurEffect then
				blurEffect.Size = 0
				blurEffect.Enabled = false
			end
			for _, entry in ipairs(targets) do
				restoreSurfaces(entry.Root)
				restoreShape(entry.Root)
				destroyLayer(entry.Root)
			end
			notifyChanged()
		end
	end

	function Frosted:IsEnabled()
		return self.Enabled
	end

	function Frosted:Toggle()
		self:SetEnabled(not self.Enabled)
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

-- ---------------------------------------------------------------------------------------
-- Background themes: URL image, crop (pan + zoom), colours, save into My Themes
-- ---------------------------------------------------------------------------------------
local Background = {}
Nerx.Background = Background

local BG_FILE = "theme-backgrounds.json"
local bgStore = Nerx.Storage:ReadJSON(BG_FILE)
if type(bgStore) ~= "table" then
	bgStore = {}
end
if type(bgStore.customs) ~= "table" then
	bgStore.customs = {}
end
local function saveBgStore()
	pcall(function()
		Nerx.Storage:WriteJSON(BG_FILE, bgStore)
	end)
end

local function bgNotify(text, color)
	pcall(function()
		Nerx:Notify({
			Title = "Themes",
			Content = tostring(text),
			Icon = "paint-bucket",
			Color = color or Theme.Green,
			Duration = 3,
		})
	end)
end

local bgAssetCache = {}
local function parseImageSize(body)
	if body:sub(1, 8) == "\137PNG\r\n\26\n" then
		local function u32(pos)
			local a, b, c, d = body:byte(pos, pos + 3)
			if not a then
				return nil
			end
			return ((a * 256 + b) * 256 + c) * 256 + d
		end
		return u32(17), u32(21)
	end
	if body:sub(1, 3) == "\255\216\255" then
		local index = 3
		while index < #body - 8 do
			if body:byte(index) ~= 255 then
				index = index + 1
			else
				local marker = body:byte(index + 1)
				if marker == 0xD8 or marker == 0xD9 or (marker >= 0xD0 and marker <= 0xD7) then
					index = index + 2
				elseif marker == 0xDA then
					break
				else
					local length = body:byte(index + 2) * 256 + body:byte(index + 3)
					if marker >= 0xC0 and marker <= 0xCF and marker ~= 0xC4 and marker ~= 0xC8 and marker ~= 0xCC then
						local h = body:byte(index + 5) * 256 + body:byte(index + 6)
						local w = body:byte(index + 7) * 256 + body:byte(index + 8)
						return w, h
					end
					index = index + 2 + length
				end
			end
		end
	end
	return nil, nil
end

local function downloadAsset(url)
	local requestFn = (syn and syn.request) or (http and http.request) or http_request
		or (fluxus and fluxus.request) or request
	local body
	if type(requestFn) == "function" then
		local ok, response = pcall(requestFn, { Url = url, Method = "GET" })
		if ok and type(response) == "table" and (response.StatusCode == 200 or response.Success == true) then
			body = response.Body
		end
	end
	if type(body) ~= "string" or #body < 4 then
		local ok, result = pcall(function()
			return game:HttpGet(url)
		end)
		if ok and type(result) == "string" then
			body = result
		end
	end
	if type(body) ~= "string" or #body < 4 then
		return nil
	end
	local ext
	if body:sub(1, 8) == "\137PNG\r\n\26\n" then
		ext = "png"
	elseif body:sub(1, 3) == "\255\216\255" then
		ext = "jpg"
	else
		return nil
	end
	local imgW, imgH = parseImageSize(body)
	local hash = 5381
	for index = 1, #url do
		hash = (hash * 33 + url:byte(index)) % 2147483647
	end
	local fileName = "nerx_bg_" .. tostring(math.floor(hash)) .. "." .. ext
	local env = type(getgenv) == "function" and getgenv() or _G
	local custom = env and (env.getcustomasset or env.getsynasset)
	if type(custom) ~= "function" then
		return nil
	end
	if type(isfile) == "function" and type(writefile) == "function" then
		local exists = false
		pcall(function()
			exists = isfile(fileName)
		end)
		if not exists then
			local ok = pcall(writefile, fileName, body)
			if not ok then
				return nil
			end
		end
		local ok, path = pcall(custom, fileName)
		if ok and type(path) == "string" and path ~= "" then
			return path, imgW, imgH
		end
		if type(getworkspace) == "function" then
			local wsOk, folder = pcall(getworkspace)
			if wsOk and type(folder) == "string" then
				local ok2, path2 = pcall(custom, folder .. "/" .. fileName)
				if ok2 and type(path2) == "string" and path2 ~= "" then
					return path2, imgW, imgH
				end
			end
		end
	end
	local ok3, direct = pcall(custom, url)
	if ok3 and type(direct) == "string" and direct ~= "" then
		return direct, imgW, imgH
	end
	return nil
end

local function resolveInfo(value)
	value = tostring(value or "")
	if value == "" then
		return nil
	end
	if value:match("^rbxassetid://") or value:match("^rbxasset://")
		or value:match("^http://www.roblox.com/asset") or value:match("^https://www.roblox.com/asset") then
		return { asset = value }
	end
	local cached = bgAssetCache[value]
	if cached ~= nil then
		return cached or nil
	end
	if value:match("^https?://") then
		local asset, imgW, imgH = downloadAsset(value)
		local info = asset and { asset = asset, w = imgW, h = imgH } or false
		bgAssetCache[value] = info
		return info or nil
	end
	return { asset = value }
end

local function layoutImage(label, cw, ch, state)
	local fit = state.fit or "cover"
	local zoom = math.clamp(tonumber(state.zoom) or 1, 1, 3)
	local ox = math.clamp(tonumber(state.ox) or 0, -1, 1)
	local oy = math.clamp(tonumber(state.oy) or 0, -1, 1)
	local w = tonumber(state.w)
	local h = tonumber(state.h)
	if fit == "tile" then
		label.ScaleType = Enum.ScaleType.Tile
		label.Size = UDim2.fromScale(1, 1)
		label.Position = UDim2.fromScale(0.5, 0.5)
		label.ImageRectSize = Vector2.new(0, 0)
		label.ImageRectOffset = Vector2.new(0, 0)
		return 0, 0
	end
	if w and h and w > 0 and h > 0 then
		local base
		if fit == "contain" then
			base = math.min(cw / w, ch / h)
		else
			base = math.max(cw / w, ch / h)
		end
		local scale = base * zoom
		local lw, lh = w * scale, h * scale
		local rx = math.max(0, (lw - cw) * 0.5)
		local ry = math.max(0, (lh - ch) * 0.5)
		label.ScaleType = Enum.ScaleType.Stretch
		label.Size = UDim2.fromOffset(lw, lh)
		label.Position = UDim2.new(0.5, ox * rx, 0.5, oy * ry)
		if fit == "mirror" then
			label.ImageRectSize = Vector2.new(-w, h)
			label.ImageRectOffset = Vector2.new(w, 0)
		else
			label.ImageRectSize = Vector2.new(0, 0)
			label.ImageRectOffset = Vector2.new(0, 0)
		end
		return rx, ry
	end
	if fit == "contain" then
		label.ScaleType = Enum.ScaleType.Fit
		label.Size = UDim2.fromScale(1, 1)
		label.Position = UDim2.fromScale(0.5, 0.5)
		return 0, 0
	end
	label.ScaleType = Enum.ScaleType.Crop
	label.Size = UDim2.fromScale(zoom, zoom)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.ImageRectSize = Vector2.new(0, 0)
	label.ImageRectOffset = Vector2.new(0, 0)
	return 0, 0
end

local layerHost, layerImage, layerTint, layerDim, layerWindow
function Background:Attach(window)
	if not window or not window.Root then
		return
	end
	if layerHost and layerHost.Parent and layerWindow == window then
		return
	end
	if layerHost then
		pcall(function()
			layerHost:Destroy()
		end)
	end
	layerWindow = window
	layerHost = U.frame(window.Root, {
		Name = "NerxMenuBackground",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0,
		ClipsDescendants = true,
		Visible = false,
	})
	layerImage = U.new("ImageLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Image = "",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 0,
	}, layerHost)
	layerTint = U.frame(layerHost, {
		BackgroundColor3 = Theme.Main,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0,
	})
	layerDim = U.frame(layerHost, {
		BackgroundColor3 = Theme.Black,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0,
	})
	Background:ApplyActive()
end

local function applyRecord(record)
	if not layerHost or not layerHost.Parent then
		return
	end
	record = record or {}
	local info = record.url ~= nil and record.url ~= "" and resolveInfo(record.url) or nil
	local asset = info and info.asset or nil
	local hasImage = type(asset) == "string" and asset ~= ""
	layerHost.Visible = hasImage
	layerImage.Image = hasImage and asset or ""
	layerImage.ImageTransparency = hasImage and math.clamp((record.soft or 0) / 100 * 0.55, 0, 0.55) or 1
	if hasImage then
		local cw, ch = 1024, 700
		if layerWindow and layerWindow.Root then
			cw = math.max(1, layerWindow.Root.Size.X.Offset)
			ch = math.max(1, layerWindow.Root.Size.Y.Offset)
		end
		layoutImage(layerImage, cw, ch, {
			fit = record.fit,
			zoom = record.zoom,
			ox = record.ox,
			oy = record.oy,
			w = record.w or (info and info.w),
			h = record.h or (info and info.h),
		})
	end
	layerTint.BackgroundColor3 = record.base or Theme.Main
	layerTint.BackgroundTransparency = 1 - math.clamp((record.tint or 55) / 100, 0, 0.92)
	layerDim.BackgroundTransparency = 1 - math.clamp((record.dim or 42) / 100, 0, 0.9)
end

function Background:Apply(record)
	applyRecord(record)
end

function Background:ApplyActive()
	local name = bgStore.active
	if type(name) == "string" and bgStore.customs[name] then
		applyRecord(bgStore.customs[name])
	else
		applyRecord(nil)
	end
end

function Background:GetCustom(name)
	return bgStore.customs[name]
end

function Background:GetAsset(url)
	local info = resolveInfo(url)
	return info and info.asset or nil
end

function Background:Layout(label, cw, ch, record)
	record = record or {}
	if (not record.w or not record.h) and record.url and record.url ~= "" then
		local info = resolveInfo(record.url)
		if info then
			record = {
				fit = record.fit,
				zoom = record.zoom,
				ox = record.ox,
				oy = record.oy,
				w = info.w,
				h = info.h,
			}
		end
	end
	return layoutImage(label, cw, ch, record)
end

function Background:ApplyForTheme(name)
	local record = type(name) == "string" and bgStore.customs[name] or nil
	if record then
		bgStore.active = name
		applyRecord(record)
	else
		bgStore.active = nil
		applyRecord(nil)
	end
	saveBgStore()
end

function Background:RenameCustom(oldName, newName)
	if bgStore.customs[oldName] then
		bgStore.customs[newName] = bgStore.customs[oldName]
		bgStore.customs[oldName] = nil
		if bgStore.active == oldName then
			bgStore.active = newName
		end
		saveBgStore()
	end
end

function Background:DeleteCustom(name)
	if bgStore.customs[name] then
		bgStore.customs[name] = nil
		if bgStore.active == name then
			bgStore.active = nil
			applyRecord(nil)
		end
		saveBgStore()
	end
end

local function applyPalette(record)
	local base = record.base or Theme.Main
	local accent = record.accent or Theme.Accent
	local panel = base:Lerp(Theme.White, 0.08)
	local palette = Nerx.Themes:BuildPalette({
		Base = base,
		Panel = panel,
		Accent = accent,
	})
	local text = record.text or Theme.Text
	palette.Text = text
	palette.Muted = text:Lerp(base, 0.38)
	palette.Faint = text:Lerp(base, 0.6)
	Nerx.Themes:ApplyPalette(palette, "Custom", { noPersist = true })
end

local function nextBackgroundName()
	local base = Nerx.Locale:Pick("我的背景", "My Background")
	if not bgStore.customs[base] then
		return base
	end
	local index = 2
	while bgStore.customs[base .. " " .. index] do
		index = index + 1
	end
	return base .. " " .. index
end

local function shortenUrl(value)
	value = tostring(value or "")
	if #value <= 42 then
		return value
	end
	return value:sub(1, 26) .. "..." .. value:sub(-12)
end

local bgState = {
	url = "",
	fit = "cover",
	zoom = 1.15,
	ox = 0,
	oy = 0,
	base = Theme.Main,
	accent = Theme.Accent,
	text = Theme.Text,
	dim = 42,
	tint = 55,
	soft = 0,
}
local fitValueToLabel = { cover = "填充", contain = "适应", mirror = "镜像", tile = "平铺" }
local fitLabelToValue = { ["填充"] = "cover", ["适应"] = "contain", ["镜像"] = "mirror", ["平铺"] = "tile" }

local wizard = { built = false, open = false, step = 1, pickerOpen = false, window = nil }
local bgOverlay, bgPanel, bgPanelScale, bgSteps, bgPills, bgClose
local bgBack, bgNext
local bgPreview, bgPreviewImage, bgPreviewHint
local bgUrlInput, bgApplyAction, bgFitSeg
local bgColorSetters = {}
local bgSliders = {}
local bgSummary = {}
local bgNameInput, bgSaveConfig, bgConfigLabel
local cropOverlay, cropCard, cropStage, cropImage, cropMini, cropMiniImage, cropZoom, cropZoomLabel
local cropApply, cropCancel, cropReset, cropFitSeg
local cropBackup

local function cropBounds(zoom)
	return math.max(0, (zoom - 1) * 0.5)
end

local cropRanges = { x = 0, y = 0 }
local function renderCropViews()
	if cropImage and cropStage then
		cropRanges.x, cropRanges.y = layoutImage(cropImage, 432, 243, bgState)
	end
	if bgPreviewImage then
		layoutImage(bgPreviewImage, 236, 132, bgState)
	end
	if cropMiniImage and cropMini then
		layoutImage(cropMiniImage, 200, 118, bgState)
	end
	if cropZoom and cropZoomLabel then
		cropZoomLabel.Text = string.format("%.2fx", bgState.zoom)
	end
end

local function setPreviewAsset()
	local info = bgState.url ~= "" and resolveInfo(bgState.url) or nil
	local asset = info and info.asset or nil
	if info then
		bgState.w = info.w or bgState.w
		bgState.h = info.h or bgState.h
	end
	local hasImage = type(asset) == "string" and asset ~= ""
	if bgPreviewImage then
		bgPreviewImage.Image = hasImage and asset or ""
		bgPreviewImage.ImageTransparency = hasImage and 0 or 1
	end
	if bgPreviewHint then
		bgPreviewHint.Visible = not hasImage
	end
	if cropImage then
		cropImage.Image = hasImage and asset or ""
		cropImage.ImageTransparency = hasImage and 0 or 1
	end
	if cropMiniImage then
		cropMiniImage.Image = hasImage and asset or ""
		cropMiniImage.ImageTransparency = hasImage and 0 or 1
	end
	renderCropViews()
end

local function setStep(index, instant)
	index = math.clamp(index, 1, 3)
	if wizard.step == index and not instant then
		return
	end
	for i = 1, 3 do
		local step = bgSteps and bgSteps[i]
		if step then
			if i == index then
				step.Visible = true
				if instant then
					step.GroupTransparency = 0
					step.Position = UDim2.fromOffset(0, 0)
				else
					step.GroupTransparency = 1
					step.Position = UDim2.fromOffset(16, 0)
					U.tween(step, TWEEN.Fast, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) })
				end
			elseif step.Visible then
				if instant then
					step.Visible = false
					step.GroupTransparency = 1
					step.Position = UDim2.fromOffset(0, 0)
				else
					U.tween(step, TWEEN.Fast, { GroupTransparency = 1, Position = UDim2.fromOffset(-16, 0) })
					task.delay(0.15, function()
						if wizard.step ~= i then
							step.Visible = false
							step.GroupTransparency = 1
							step.Position = UDim2.fromOffset(0, 0)
						end
					end)
				end
			end
		end
		local pill = bgPills and bgPills[i]
		if pill then
			local active = i == index
			pill.Frame.BackgroundColor3 = active and Theme.Accent or Theme.Field
			pill.Frame.BackgroundTransparency = active and 0.88 or 0
			pill.Stroke.Color = active and Theme.Accent or Theme.Stroke
			pill.Stroke.Transparency = active and 0.55 or 0.65
			pill.Label.TextColor3 = active and Theme.Text or Theme.Muted
		end
	end
	wizard.step = index
	if bgBack then
		bgBack:SetDisabled(index == 1)
	end
	if bgNext then
		bgNext.Label.Text = index == 3 and Nerx.Locale:Pick("保存并应用", "Save & apply")
				or Nerx.Locale:Pick("下一步", "Next")
	end
	if index == 3 then
		local fitText = fitValueToLabel[bgState.fit] or Nerx.Locale:Pick("填充", "Fill")
		if bgSummary.url then
			bgSummary.url.Text = bgState.url ~= "" and bgState.url or Nerx.Locale:Pick("未设置", "Not set")
			bgSummary.fit.Text = fitText
			bgSummary.base.Text = U.hex(bgState.base)
			bgSummary.accent.Text = U.hex(bgState.accent)
			bgSummary.fx.Text = tostring(bgState.dim) .. "% / " .. tostring(bgState.soft) .. "%"
		end
	end
end

local function closeCrop()
	if cropOverlay then
		cropOverlay.Visible = false
	end
end

local function openCrop()
	if not cropOverlay then
		return
	end
	cropBackup = { zoom = bgState.zoom, ox = bgState.ox, oy = bgState.oy, fit = bgState.fit }
	if cropFitSeg then
		cropFitSeg:SetValue(fitValueToLabel[bgState.fit] or "填充", true)
	end
	cropOverlay.Visible = true
	setPreviewAsset()
end

local function cancelCrop()
	if cropBackup then
		bgState.zoom = cropBackup.zoom
		bgState.ox = cropBackup.ox
		bgState.oy = cropBackup.oy
		bgState.fit = cropBackup.fit or bgState.fit
		cropBackup = nil
	end
	closeCrop()
	setPreviewAsset()
end

local function openWizard(window)
	Background:Attach(window)
	if not bgOverlay or not bgPanel then
		return
	end
	local source = bgStore.active and bgStore.customs[bgStore.active] or {}
	bgState.url = tostring(source.url or "")
	bgState.fit = source.fit or "cover"
	bgState.zoom = math.clamp(tonumber(source.zoom) or 1.15, 1, 3)
	bgState.ox = tonumber(source.ox) or 0
	bgState.oy = tonumber(source.oy) or 0
	bgState.base = source.base or Theme.Main
	bgState.accent = source.accent or Theme.Accent
	bgState.text = source.text or Theme.Text
	bgState.dim = tonumber(source.dim) or 42
	bgState.tint = tonumber(source.tint) or 55
	bgState.soft = tonumber(source.soft) or 0
	bgState.w = tonumber(source.w)
	bgState.h = tonumber(source.h)
	if bgUrlInput then
		bgUrlInput:SetValue(shortenUrl(bgState.url), true)
	end
	if bgFitSeg then
		bgFitSeg:SetValue(fitValueToLabel[bgState.fit] or "填充", true)
	end
	for _, setter in pairs(bgColorSetters) do
		setter()
	end
	for key, setter in pairs(bgSliders) do
		setter(bgState[key])
	end
	if bgNameInput then
		bgNameInput:SetValue(nextBackgroundName(), true)
	end
	if bgSaveConfig then
		bgSaveConfig:SetValue(true, true)
	end
	if bgConfigLabel then
		local activeName = tostring(Nerx.Configs.ActiveName or "Default")
		bgConfigLabel.Text = Nerx.Locale:Pick("同时保存到当前配置（" .. activeName .. "）", "Also save to the active config (" .. activeName .. ")")
	end
	setPreviewAsset()
	setStep(1, true)
	bgOverlay.Visible = true
	bgOverlay.BackgroundTransparency = 1
	bgPanel.GroupTransparency = 1
	bgPanelScale.Scale = 0.94
	U.tween(bgOverlay, TWEEN.Fast, { BackgroundTransparency = 0.55 })
	U.tween(bgPanel, TWEEN.Page, { GroupTransparency = 0 })
	U.tween(bgPanelScale, TWEEN.Page, { Scale = 1 })
	wizard.open = true
end

local function closeWizard()
	if not bgOverlay then
		return
	end
	closeCrop()
	U.tween(bgOverlay, TWEEN.Fast, { BackgroundTransparency = 1 })
	U.tween(bgPanel, TWEEN.Fast, { GroupTransparency = 1 })
	U.tween(bgPanelScale, TWEEN.Fast, { Scale = 0.94 })
	task.delay(0.16, function()
		bgOverlay.Visible = false
	end)
	wizard.open = false
end

function Background:Close()
	closeWizard()
end

local function buildWizard(window)
	if wizard.built or not window or not window.Root then
		return
	end
	wizard.built = true
	wizard.window = window
	bgOverlay = U.frame(window.Root, {
		Name = "NerxBackgroundWizard",
		BackgroundColor3 = Theme.Black,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 900,
		Visible = false,
	})
	local blocker = U.inputButton(bgOverlay, function()
		if wizard.pickerOpen then
			return
		end
		closeWizard()
	end)
	blocker.ZIndex = 900
	bgPanel = U.canvas(bgOverlay, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(548, 392),
		BackgroundColor3 = Theme.SurfaceRaised,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 901,
		GroupTransparency = 1,
		Active = true,
	})
	U.corner(bgPanel, 12)
	U.stroke(bgPanel, Theme.Stroke, 0.45, 1)
	bgPanelScale = U.new("UIScale", { Scale = 0.94 }, bgPanel)
	U.label(bgPanel, {
		Text = "自定义背景图",
		Font = Fonts.Bold,
		TextSize = 13,
		TextColor3 = Theme.Text,
		Position = UDim2.fromOffset(16, 13),
		Size = UDim2.fromOffset(220, 18),
	})
	U.label(bgPanel, {
		Text = "URL 图片 · 三步完成",
		TextSize = 8.5,
		TextColor3 = Theme.Faint,
		Position = UDim2.fromOffset(120, 16),
		Size = UDim2.fromOffset(200, 14),
	})
	bgClose = Nerx.Widgets.Button(bgPanel, "×", function()
		closeWizard()
	end)
	bgClose.Root.AnchorPoint = Vector2.new(1, 0)
	bgClose.Root.Position = UDim2.new(1, -12, 0, 10)
	bgClose.Root.Size = UDim2.fromOffset(26, 26)

	bgPills = {}
	for index = 1, 3 do
		local names = { "01 · 图片", "02 · 调色", "03 · 保存" }
		local pill = U.frame(bgPanel, {
			BackgroundColor3 = Theme.Field,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(16 + (index - 1) * 172, 42),
			Size = UDim2.fromOffset(164, 24),
		})
		U.corner(pill, 5)
		local stroke = U.stroke(pill, Theme.Stroke, 0.65, 1)
		local label = U.label(pill, {
			Text = names[index],
			TextSize = 9.5,
			TextColor3 = Theme.Muted,
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		bgPills[index] = { Frame = pill, Stroke = stroke, Label = label }
	end

	local body = U.frame(bgPanel, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 76),
		Size = UDim2.new(1, -32, 0, 266),
		ClipsDescendants = true,
	})
	bgSteps = {}
	for index = 1, 3 do
		bgSteps[index] = U.canvas(body, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			GroupTransparency = index == 1 and 0 or 1,
			Visible = index == 1,
		})
	end

	-- step 1
	local thumb = U.frame(bgSteps[1], {
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(236, 132),
		ClipsDescendants = true,
	})
	U.corner(thumb, 8)
	U.stroke(thumb, Theme.Stroke, 0.55, 1)
	bgPreviewImage = U.new("ImageLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Image = "",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Crop,
	}, thumb)
	bgPreviewHint = U.label(thumb, {
		Text = "IMAGE PREVIEW",
		TextSize = 9,
		TextColor3 = Theme.Faint,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	local cropButton = Nerx.Widgets.Button(bgSteps[1], "裁剪图片", function()
		openCrop()
	end)
	cropButton.Root.Position = UDim2.fromOffset(248, 0)
	cropButton.Root.Size = UDim2.fromOffset(92, 28)
	U.label(bgSteps[1], {
		Text = "拖动 / 缩放选择要显示的区域",
		TextSize = 8.5,
		TextColor3 = Theme.Faint,
		Position = UDim2.fromOffset(248, 36),
		Size = UDim2.fromOffset(240, 28),
		TextWrapped = true,
	})
	U.label(bgSteps[1], {
		Text = "图片链接",
		TextSize = 9.5,
		TextColor3 = Theme.Muted,
		Position = UDim2.fromOffset(0, 144),
		Size = UDim2.fromOffset(160, 14),
	})
	bgUrlInput = Nerx.Widgets.Input(bgSteps[1], {
		Width = 360,
		Height = 30,
		Placeholder = "粘贴图床直链（PNG/JPG），留空恢复纯色",
	})
	bgUrlInput.Root.Position = UDim2.fromOffset(0, 162)
	bgUrlInput.Root.ClipsDescendants = true
	bgUrlInput.Box.ClipsDescendants = true
	pcall(function()
		bgUrlInput.Box.TextTruncate = Enum.TextTruncate.AtEnd
	end)
	U.connect(bgUrlInput.Box.Focused, function()
		bgUrlInput:SetValue(bgState.url, true)
	end)
	local applyButton = Nerx.Widgets.Button(bgSteps[1], "应用", function()
		if bgApplyAction then
			bgApplyAction()
		end
	end)
	applyButton.Root.Position = UDim2.fromOffset(368, 162)
	applyButton.Root.Size = UDim2.fromOffset(80, 30)
	bgApplyAction = function()
		setPreviewAsset()
	end
	U.label(bgSteps[1], {
		Text = "填充方式",
		TextSize = 9.5,
		TextColor3 = Theme.Muted,
		Position = UDim2.fromOffset(0, 204),
		Size = UDim2.fromOffset(70, 14),
	})
	bgFitSeg = Nerx.Widgets.Segmented(bgSteps[1], {
		Width = 280,
		Height = 26,
		Items = { "填充", "适应", "镜像", "平铺" },
		Selected = "填充",
		Callback = function(value)
			bgState.fit = fitLabelToValue[value] or "cover"
			if cropFitSeg then
				cropFitSeg:SetValue(value, true)
			end
			renderCropViews()
		end,
	})
	bgFitSeg.Root.Position = UDim2.fromOffset(72, 198)
	U.connect(bgUrlInput.Box.FocusLost, function()
		bgState.url = tostring(bgUrlInput.Box.Text or "")
		bgUrlInput:SetValue(shortenUrl(bgState.url), true)
		setPreviewAsset()
	end)

	-- step 2
	local function colorRow(y, label, key)
		U.label(bgSteps[2], {
			Text = label,
			TextSize = 9.5,
			TextColor3 = Theme.Muted,
			Position = UDim2.fromOffset(0, y + 3),
			Size = UDim2.fromOffset(180, 16),
		})
		local hex = U.label(bgSteps[2], {
			Text = U.hex(bgState[key]),
			TextSize = 9,
			TextColor3 = Theme.Faint,
			Position = UDim2.fromOffset(400, y + 3),
			Size = UDim2.fromOffset(64, 16),
		})
		local swatch = U.frame(bgSteps[2], {
			BackgroundColor3 = bgState[key],
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(470, y),
			Size = UDim2.fromOffset(28, 20),
		})
		U.corner(swatch, 5)
		U.stroke(swatch, Theme.White, 0.82, 1)
		U.inputButton(swatch, function()
			local previousHost = Nerx.PopupHost
			Nerx.PopupHost = bgPanel
			U.colorPicker(swatch, bgState[key], function(color)
				bgState[key] = color
				swatch.BackgroundColor3 = color
				hex.Text = U.hex(color)
			end)
			Nerx.PopupHost = previousHost
			local popup = bgPanel and bgPanel:FindFirstChild("NerxPopup")
			if popup then
				wizard.pickerOpen = true
				popup.Destroying:Connect(function()
					wizard.pickerOpen = false
				end)
			end
		end)
		bgColorSetters[key] = function()
			swatch.BackgroundColor3 = bgState[key]
			hex.Text = U.hex(bgState[key])
		end
	end
	colorRow(0, "菜单底色", "base")
	colorRow(32, "强调色", "accent")
	colorRow(64, "文字颜色", "text")
	U.frame(bgSteps[2], {
		BackgroundColor3 = Theme.Stroke,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.new(1, 0, 0, 1),
	})

	local function addSlider(y, label, key, min, max)
		local row = U.frame(bgSteps[2], {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.new(1, 0, 0, 30),
		})
		U.label(row, {
			Text = label,
			TextSize = 9.5,
			TextColor3 = Theme.Muted,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(140, 14),
		})
		local valueLabel = U.label(row, {
			Text = tostring(bgState[key]) .. "%",
			TextSize = 9.5,
			TextColor3 = Theme.Text,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromOffset(48, 14),
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		local track = U.frame(row, {
			BackgroundColor3 = Theme.Field,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 21),
			Size = UDim2.new(1, 0, 0, 3),
		})
		U.corner(track, 2)
		local alpha = math.clamp((bgState[key] - min) / math.max(max - min, 0.0001), 0, 1)
		local fill = U.frame(track, {
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new(alpha, 0, 1, 0),
		})
		U.corner(fill, 2)
		local knob = U.frame(row, {
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(alpha, 0, 0, 22.5),
			Size = UDim2.fromOffset(9, 9),
		})
		U.corner(knob, 5)
		local dragging = false
		local function setFromX(px)
			local origin = track.AbsolutePosition.X
			local width = math.max(track.AbsoluteSize.X, 1)
			local a = math.clamp((px - origin) / width, 0, 1)
			local v = math.clamp(math.floor(min + (max - min) * a + 0.5), min, max)
			fill.Size = UDim2.new(a, 0, 1, 0)
			knob.Position = UDim2.new(a, 0, 0, 22.5)
			valueLabel.Text = tostring(v) .. "%"
			bgState[key] = v
		end
		local hit = U.inputButton(row, nil)
		hit.Size = UDim2.new(1, 0, 0, 30)
		U.connect(hit.InputBegan, function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				setFromX(inputObject.Position.X)
			end
		end)
		U.connect(UserInputService.InputEnded, function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		U.connect(UserInputService.InputChanged, function(inputObject)
			if not dragging then
				return
			end
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement
				or inputObject.UserInputType == Enum.UserInputType.Touch then
				setFromX(inputObject.Position.X)
			end
		end)
		bgSliders[key] = function(v)
			local a = math.clamp((v - min) / math.max(max - min, 0.0001), 0, 1)
			fill.Size = UDim2.new(a, 0, 1, 0)
			knob.Position = UDim2.new(a, 0, 0, 22.5)
			valueLabel.Text = tostring(v) .. "%"
		end
	end
	addSlider(108, "背景暗度", "dim", 0, 90)
	addSlider(142, "底色浓度", "tint", 0, 90)
	addSlider(176, "背景柔化", "soft", 0, 90)
	U.label(bgSteps[2], {
		Text = "暗度越高文字越清晰；Roblox 无法对 UI 背景做真模糊，柔化会降低图片不透明度。",
		TextSize = 8,
		TextColor3 = Theme.Faint,
		Position = UDim2.fromOffset(0, 216),
		Size = UDim2.new(1, 0, 0, 14),
	})

	-- step 3
	bgSummary = {}
	local rows = {
		{ key = "url", label = "背景图片" },
		{ key = "fit", label = "填充方式" },
		{ key = "base", label = "菜单底色" },
		{ key = "accent", label = "强调色" },
		{ key = "fx", label = "暗度 / 柔化" },
	}
	for index, row in ipairs(rows) do
		local y = (index - 1) * 22
		U.label(bgSteps[3], {
			Text = row.label,
			TextSize = 9.5,
			TextColor3 = Theme.Muted,
			Position = UDim2.fromOffset(0, y + 3),
			Size = UDim2.fromOffset(120, 16),
		})
		bgSummary[row.key] = U.label(bgSteps[3], {
			Text = "",
			TextSize = 9.5,
			TextColor3 = Theme.Text,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, y + 3),
			Size = UDim2.fromOffset(330, 16),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
	end
	U.label(bgSteps[3], {
		Text = "保存到「我的主题」",
		TextSize = 9.5,
		TextColor3 = Theme.Muted,
		Position = UDim2.fromOffset(0, 118),
		Size = UDim2.fromOffset(160, 14),
	})
	bgNameInput = Nerx.Widgets.Input(bgSteps[3], {
		Width = 260,
		Height = 30,
		Text = Nerx.Locale:Pick("我的背景", "My Background"),
		Placeholder = Nerx.Locale:Pick("给这套背景起个名字", "Name this background"),
	})
	bgNameInput.Root.Position = UDim2.fromOffset(0, 136)
	bgNameInput.Root.ClipsDescendants = true
	bgNameInput.Box.ClipsDescendants = true
	bgSaveConfig = Nerx.Widgets.Toggle(bgSteps[3], true, nil, false)
	bgSaveConfig.Root.Position = UDim2.fromOffset(0, 176)
	bgConfigLabel = U.label(bgSteps[3], {
		Text = "同时保存到当前配置",
		TextSize = 9.5,
		TextColor3 = Theme.Muted,
		Position = UDim2.fromOffset(40, 176),
		Size = UDim2.fromOffset(340, 20),
	})

	local function commit()
		local name = tostring(bgNameInput.Box.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if name == "" then
			bgNotify(Nerx.Locale:Pick("请先填写主题名称", "Enter a theme name first"), Theme.Amber)
			return
		end
		local record = {
			url = bgState.url,
			fit = bgState.fit,
			zoom = bgState.zoom,
			ox = bgState.ox,
			oy = bgState.oy,
			base = bgState.base,
			accent = bgState.accent,
			text = bgState.text,
			dim = bgState.dim,
			tint = bgState.tint,
			soft = bgState.soft,
			w = bgState.w,
			h = bgState.h,
			config = bgSaveConfig:GetValue() and (Nerx.Configs.ActiveName or "Default") or nil,
			savedAt = os.time(),
		}
		bgStore.customs[name] = record
		bgStore.active = name
		saveBgStore()
		applyPalette(record)
		applyRecord(record)
		Nerx.Themes:SaveCustom(name)
		if bgSaveConfig:GetValue() then
			pcall(function()
				Nerx.Configs:SaveActive()
			end)
		end
		closeWizard()
		bgNotify(Nerx.Locale:Pick("已保存「" .. name .. "」到我的主题", "Saved \"" .. name .. "\" to My Themes"), Theme.Green)
	end

	bgBack = Nerx.Widgets.Button(bgPanel, "上一步", function()
		setStep(wizard.step - 1)
	end)
	bgBack.Root.Position = UDim2.fromOffset(16, 350)
	bgBack.Root.Size = UDim2.fromOffset(250, 32)
	bgNext = Nerx.Widgets.PrimaryButton(bgPanel, "下一步", 250, 32, function()
		if wizard.step < 3 then
			if wizard.step == 1 then
				setPreviewAsset()
			end
			setStep(wizard.step + 1)
		else
			commit()
		end
	end)
	bgNext.Root.Position = UDim2.fromOffset(282, 350)
	bgBack:SetDisabled(true)

	-- crop modal
	cropOverlay = U.frame(bgOverlay, {
		Name = "NerxBackgroundCrop",
		BackgroundColor3 = Theme.Black,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 910,
		Visible = false,
	})
	U.inputButton(cropOverlay, function() end).ZIndex = 910
	cropCard = U.canvas(cropOverlay, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(680, 372),
		BackgroundColor3 = Theme.SurfaceRaised,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 911,
	})
	U.corner(cropCard, 12)
	U.stroke(cropCard, Theme.Stroke, 0.45, 1)
	U.label(cropCard, {
		Text = "裁剪图片",
		Font = Fonts.Bold,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Position = UDim2.fromOffset(16, 12),
		Size = UDim2.fromOffset(200, 18),
	})
	U.label(cropCard, {
		Text = "16:9 · 菜单背景",
		TextSize = 8.5,
		TextColor3 = Theme.Faint,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -46, 0, 15),
		Size = UDim2.fromOffset(140, 14),
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	local cropCloseButton = Nerx.Widgets.Button(cropCard, "×", function()
		cancelCrop()
	end)
	cropCloseButton.Root.AnchorPoint = Vector2.new(1, 0)
	cropCloseButton.Root.Position = UDim2.new(1, -12, 0, 8)
	cropCloseButton.Root.Size = UDim2.fromOffset(26, 26)

	cropStage = U.frame(cropCard, {
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 44),
		Size = UDim2.fromOffset(432, 243),
		ClipsDescendants = true,
		Active = true,
	})
	U.corner(cropStage, 8)
	U.stroke(cropStage, Theme.Stroke, 0.5, 1)
	cropImage = U.new("ImageLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Image = "",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Crop,
	}, cropStage)
	local cropHint = U.label(cropStage, {
		Text = "拖动图片 · 滑条缩放",
		TextSize = 8.5,
		TextColor3 = Theme.White,
		BackgroundColor3 = Theme.Black,
		BackgroundTransparency = 0.4,
		Position = UDim2.fromOffset(8, 220),
		Size = UDim2.fromOffset(126, 16),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	U.corner(cropHint, 4)
	local cropDragging = false
	local dragStart, dragBaseX, dragBaseY
	cropStage.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch then
			cropDragging = true
			dragStart = inputObject.Position
			dragBaseX = bgState.ox
			dragBaseY = bgState.oy
		end
	end)
	U.connect(UserInputService.InputChanged, function(inputObject)
		if not cropDragging or not dragStart then
			return
		end
		if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement
			and inputObject.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local uiScale = 1
		if U.parentScale then
			uiScale = U.parentScale(cropStage) or 1
		end
		local dx = (inputObject.Position.X - dragStart.X) / math.max(uiScale, 0.01)
		local dy = (inputObject.Position.Y - dragStart.Y) / math.max(uiScale, 0.01)
		if cropRanges.x > 0 then
			bgState.ox = math.clamp(dragBaseX + dx / cropRanges.x, -1, 1)
		end
		if cropRanges.y > 0 then
			bgState.oy = math.clamp(dragBaseY + dy / cropRanges.y, -1, 1)
		end
		renderCropViews()
	end)
	U.connect(UserInputService.InputEnded, function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch then
			cropDragging = false
			dragStart = nil
		end
	end)
	cropZoom = U.frame(cropCard, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 296),
		Size = UDim2.fromOffset(432, 28),
	})
	U.label(cropZoom, {
		Text = "缩放",
		TextSize = 9.5,
		TextColor3 = Theme.Muted,
		Position = UDim2.fromOffset(0, 7),
		Size = UDim2.fromOffset(40, 14),
	})
	local zoomTrack = U.frame(cropZoom, {
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(46, 12),
		Size = UDim2.new(1, -100, 0, 3),
	})
	U.corner(zoomTrack, 2)
	local zoomFill = U.frame(zoomTrack, {
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new((bgState.zoom - 1) / 2, 0, 1, 0),
	})
	U.corner(zoomFill, 2)
	local zoomKnob = U.frame(cropZoom, {
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 46 + ((bgState.zoom - 1) / 2) * 332, 0, 13.5),
		Size = UDim2.fromOffset(9, 9),
	})
	U.corner(zoomKnob, 5)
	cropZoomLabel = U.label(cropZoom, {
		Text = "1.15x",
		TextSize = 9.5,
		TextColor3 = Theme.Text,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 7),
		Size = UDim2.fromOffset(48, 14),
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	local zooming = false
	local function setZoomFromX(px)
		local origin = zoomTrack.AbsolutePosition.X
		local width = math.max(zoomTrack.AbsoluteSize.X, 1)
		local a = math.clamp((px - origin) / width, 0, 1)
		bgState.zoom = 1 + a * 2
		zoomFill.Size = UDim2.new(a, 0, 1, 0)
		zoomKnob.Position = UDim2.new(0, 46 + a * 332, 0, 13.5)
		renderCropViews()
	end
	local zoomHit = U.inputButton(zoomTrack.Parent, nil)
	zoomHit.Position = UDim2.fromOffset(40, 0)
	zoomHit.Size = UDim2.fromOffset(342, 28)
	U.connect(zoomHit.InputBegan, function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch then
			zooming = true
			setZoomFromX(inputObject.Position.X)
		end
	end)
	U.connect(UserInputService.InputEnded, function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch then
			zooming = false
		end
	end)
	U.connect(UserInputService.InputChanged, function(inputObject)
		if not zooming then
			return
		end
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement
			or inputObject.UserInputType == Enum.UserInputType.Touch then
			setZoomFromX(inputObject.Position.X)
		end
	end)
	local cropSide = U.frame(cropCard, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(464, 44),
		Size = UDim2.fromOffset(200, 280),
	})
	U.label(cropSide, {
		Text = "菜单预览",
		TextSize = 9,
		TextColor3 = Theme.Muted,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(120, 14),
	})
	cropMini = U.frame(cropSide, {
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.fromOffset(200, 118),
		ClipsDescendants = true,
	})
	U.corner(cropMini, 7)
	U.stroke(cropMini, Theme.Stroke, 0.5, 1)
	cropMiniImage = U.new("ImageLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Image = "",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Crop,
	}, cropMini)
	local miniSide = U.frame(cropMini, {
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(5, 5),
		Size = UDim2.fromOffset(62, 108),
	})
	U.corner(miniSide, 4)
	local miniCard = U.frame(cropMini, {
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.28,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(72, 5),
		Size = UDim2.fromOffset(122, 62),
	})
	U.corner(miniCard, 4)
	local miniCard2 = U.frame(cropMini, {
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.32,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(72, 73),
		Size = UDim2.fromOffset(122, 40),
	})
	U.corner(miniCard2, 4)
	cropApply = Nerx.Widgets.PrimaryButton(cropCard, "应用裁剪", 180, 30, function()
		cropBackup = nil
		closeCrop()
		setPreviewAsset()
	end)
	cropApply.Root.Position = UDim2.fromOffset(464, 256)
	cropCancel = Nerx.Widgets.Button(cropCard, "取消", function()
		cancelCrop()
	end)
	cropCancel.Root.Position = UDim2.fromOffset(464, 294)
	cropCancel.Root.Size = UDim2.fromOffset(180, 28)
	cropReset = Nerx.Widgets.Button(cropCard, "重置", function()
		bgState.zoom = 1.15
		bgState.ox = 0
		bgState.oy = 0
		zoomFill.Size = UDim2.new((bgState.zoom - 1) / 2, 0, 1, 0)
		zoomKnob.Position = UDim2.new(0, 46 + ((bgState.zoom - 1) / 2) * 332, 0, 13.5)
		renderCropViews()
	end)
	cropReset.Root.Position = UDim2.fromOffset(16, 330)
	cropReset.Root.Size = UDim2.fromOffset(92, 26)
	cropFitSeg = Nerx.Widgets.Segmented(cropCard, {
		Width = 280,
		Height = 26,
		Items = { "填充", "适应", "镜像", "平铺" },
		Selected = fitValueToLabel[bgState.fit] or "填充",
		Callback = function(value)
			bgState.fit = fitLabelToValue[value] or "cover"
			if bgFitSeg then
				bgFitSeg:SetValue(value, true)
			end
			renderCropViews()
		end,
	})
	cropFitSeg.Root.Position = UDim2.fromOffset(120, 330)

end

-- build per window on first open
function Background:Open(window)
	window = window or (Nerx.Windows and Nerx.Windows[1])
	if not window then
		return
	end
	Background:Attach(window)
	buildWizard(window)
	openWizard(window)
end


-- ---------------------------------------------------------------------------------------
-- UIKit: shared building blocks for menus built on top of NerxUI
-- ---------------------------------------------------------------------------------------
Nerx.UIKit = {}
local UIKit = Nerx.UIKit

function UIKit.CountBadge(parent, x, y, text)
	local width = U.measure(tostring(text), 9, Fonts.Regular).X + 16
	local badge = U.frame(parent, {
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, 18),
	})
	U.corner(badge, 6)
	U.label(badge, {
		Text = tostring(text),
		TextSize = 9,
		TextColor3 = Theme.Muted,
		TextTransparency = 0.2,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	return width
end

function UIKit.TitleText(parent, text, count, status)
	local title = U.label(parent, {
		Text = text,
		Font = Fonts.Bold,
		TextSize = 15,
		TextColor3 = Theme.Text,
		TextTransparency = 0.05,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(0, 28),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local width = U.measure(text, 15, Fonts.Bold).X
	title.Size = UDim2.fromOffset(width + 2, 28)
	if count then
		UIKit.CountBadge(parent, width + 10, 5, count)
		width = width + 10 + U.measure(tostring(count), 9, Fonts.Regular).X + 16
	end
	if status then
		local dot = U.frame(parent, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Theme.Faint,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(width + 12, 14),
			Size = UDim2.fromOffset(4, 4),
		})
		U.corner(dot, 2)
		U.label(parent, {
			Text = status,
			TextSize = 9.5,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.35,
			Position = UDim2.fromOffset(width + 20, 0),
			Size = UDim2.fromOffset(160, 28),
		})
	end
	return title
end

function UIKit.SurfaceCard(parent, x, y, width, height, options)
	options = options or {}
	local radius = options.Radius or 8
	local card = U.frame(parent, {
		BackgroundColor3 = options.Background or Theme.Surface,
		BackgroundTransparency = options.Transparency or 0,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, height),
		ClipsDescendants = options.Clip == true,
	})
	U.corner(card, radius)
	local strokeParent = card
	if options.InsetStroke then
		-- 1px inset outline: the border sits inside the rounded card instead of
		-- riding the outer edge, so it can never overhang the corners.
		strokeParent = U.frame(card, {
			Name = "NerxCardOutline",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(1, 1),
			Size = UDim2.new(1, -2, 1, -2),
			ZIndex = (card.ZIndex or 1) + 1,
		})
		U.corner(strokeParent, math.max(1, radius - 1))
	end
	local stroke = U.stroke(strokeParent, options.StrokeColor or Theme.Stroke, options.StrokeTransparency or 0.55, 1)
	return card, stroke
end

function UIKit.ToolbarButton(parent, text, rightOffset, y, width, height, callback, disabled)
	local api = Nerx.Widgets.Button(parent, text, callback, disabled)
	api.Root.AnchorPoint = Vector2.new(1, 0)
	api.Root.Position = UDim2.new(1, -rightOffset, 0, y)
	api.Root.Size = UDim2.fromOffset(width, height)
	return api
end

function UIKit.ToolbarPrimary(parent, text, rightOffset, y, width, height, callback)
	local api = Nerx.Widgets.PrimaryButton(parent, text, width, height, callback)
	api.Root.AnchorPoint = Vector2.new(1, 0)
	api.Root.Position = UDim2.new(1, -rightOffset, 0, y)
	return api
end

function UIKit.FilterField(parent, x, y, width, placeholder, height)
	local api = Nerx.Widgets.Input(parent, {
		Width = width,
		Height = height or 28,
		Placeholder = placeholder,
		Icon = "magnifying-glass",
	})
	api.Root.Position = UDim2.fromOffset(x, y)
	return api
end

function UIKit.Token(parent, text, x, y, color, height)
	local h = height or 22
	local width = U.measure(text, 8.5, Fonts.Bold).X + 16
	local frame = U.frame(parent, {
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, h),
	})
	U.corner(frame, 4)
	U.label(frame, {
		Text = text,
		Font = Fonts.Bold,
		TextSize = 8.5,
		TextColor3 = color or Theme.Text,
		TextTransparency = 0.1,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	return width
end

function UIKit.Divider(parent, x, y, width, transparency)
	U.frame(parent, {
		BackgroundColor3 = Theme.StrokeSoft,
		BackgroundTransparency = transparency or 0.45,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(width, 1),
	})
end

function UIKit.Subsection(section, text)
	section:AddCustomRow(24, function(row)
		U.label(row, {
			Text = text,
			Font = Fonts.Bold,
			TextSize = 9,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.35,
			Position = UDim2.fromOffset(section.Inset or 12, 0),
			Size = UDim2.fromOffset(220, 24),
		})
	end)
end

function UIKit.MetricGrid(section, items)
	section:AddCustomRow(58, function(row)
		local inset = section.Inset or 12
		local gap = 6
		local width = 406
		local cellWidth = (width - gap * (#items - 1)) / #items
		for index, item in ipairs(items) do
			local cell = U.frame(row, {
				BackgroundColor3 = Theme.Field,
				BackgroundTransparency = 0.3,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(inset + (index - 1) * (cellWidth + gap), 6),
				Size = UDim2.fromOffset(cellWidth, 44),
			})
			U.corner(cell, 5)
			U.label(cell, {
				Text = item.Label,
				Font = Fonts.Bold,
				TextSize = 7.5,
				TextColor3 = Theme.Muted,
				TextTransparency = 0.45,
				Position = UDim2.fromOffset(8, 5),
				Size = UDim2.fromOffset(cellWidth - 16, 12),
			})
			U.label(cell, {
				Text = item.Value,
				Font = Fonts.Bold,
				TextSize = 12,
				TextColor3 = Theme.Text,
				TextTransparency = 0.1,
				Position = UDim2.fromOffset(8, 17),
				Size = UDim2.fromOffset(cellWidth - 16, 16),
			})
			if item.Sub then
				U.label(cell, {
					Text = item.Sub,
					TextSize = 7.5,
					TextColor3 = Theme.Faint,
					TextTransparency = 0.25,
					Position = UDim2.fromOffset(8, 32),
					Size = UDim2.fromOffset(cellWidth - 16, 11),
				})
			end
		end
	end)
end

function UIKit.ChipGroup(section, label, items, height)
	section:AddCustomRow(height or 62, function(row)
		local inset = section.Inset or 12
		local x = inset
		local y = 5
		U.label(row, {
			Text = label,
			Font = Fonts.Bold,
			TextSize = 8,
			TextColor3 = Theme.Muted,
			TextTransparency = 0.45,
			Position = UDim2.fromOffset(inset, y + 6),
			Size = UDim2.fromOffset(46, 14),
		})
		x = inset + 50
		for _, item in ipairs(items) do
			local chip, width = Nerx.Widgets.Chip(row, item, {
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

function UIKit.Notify(title, content, icon, color)
	Nerx:Notify({
		Title = title,
		Content = content,
		Icon = icon or "circle-i",
		Color = color or Theme.Muted,
	})
end

-- Interactive helpers shared by config, bind and theme pages.
local UIHelpers = {}
UIKit.UIHelpers = UIHelpers

function UIHelpers.InputPrompt(anchor, config)
	config = config or {}
	local submitted = false
	local box
	local function submit()
		if submitted then
			return
		end
		local text = tostring(box and box.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if text == "" then
			return
		end
		submitted = true
		Nerx:ClosePopup(true)
		if config.OnSubmit then
			config.OnSubmit(text)
		end
	end

	U.popup(anchor, 278, 124, function(card)
		if config.Attribute then
			pcall(function()
				card:SetAttribute(config.Attribute, true)
			end)
		end
		U.padding(card, 12, 12, 12, 12)
		U.label(card, {
			Text = config.Title or "Name",
			Font = Fonts.Bold,
			TextSize = 11,
			TextColor3 = Theme.Text,
			TextTransparency = 0.05,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 16),
		})
		local field = U.frame(card, {
			BackgroundColor3 = Theme.Field,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 28),
		})
		U.corner(field, 5)
		local stroke = U.stroke(field, Theme.Stroke, 0.55, 1)
		box = U.new("TextBox", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Fonts.Regular,
			Text = config.Initial or "",
			PlaceholderText = config.Placeholder or "Type a name...",
			PlaceholderColor3 = Theme.Faint,
			TextColor3 = Theme.Text,
			TextSize = 11,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(9, 0),
			Size = UDim2.new(1, -18, 1, 0),
		}, field)
		U.connect(box.Focused, function()
			U.tween(field, U.Tween.Fast, { BackgroundColor3 = Theme.FieldHover })
			stroke.Transparency = 0.3
		end)
		U.connect(box.FocusLost, function(enterPressed)
			U.tween(field, U.Tween.Fast, { BackgroundColor3 = Theme.Field })
			stroke.Transparency = 0.55
			if enterPressed then
				submit()
			end
		end)

		local cancel = Nerx.Widgets.Button(card, "Cancel", function()
			submitted = true
			Nerx:ClosePopup(true)
		end)
		cancel.Root.Position = UDim2.new(1, -150, 1, -26)
		cancel.Root.Size = UDim2.fromOffset(66, 26)
		local create = Nerx.Widgets.PrimaryButton(card, config.Submit or "Create", 76, 26, submit)
		create.Root.Position = UDim2.new(1, -76, 1, -26)
		task.defer(function()
			pcall(function()
				box:CaptureFocus()
			end)
		end)
	end)
end

function UIHelpers.ImportPrompt(anchor, config)
	config = config or {}
	local box
	U.popup(anchor, 320, 292, function(card)
		U.padding(card, 12, 12, 12, 12)
		U.label(card, {
			Text = config.Title or "Import JSON",
			Font = Fonts.Bold,
			TextSize = 11,
			TextColor3 = Theme.Text,
			TextTransparency = 0.05,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 16),
		})
		local field = U.frame(card, {
			BackgroundColor3 = Theme.FieldDeep,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 190),
		})
		U.corner(field, 5)
		local stroke = U.stroke(field, Theme.Stroke, 0.55, 1)
		box = U.new("TextBox", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Fonts.Mono,
			Text = "",
			PlaceholderText = config.Placeholder or "Paste exported JSON here...",
			PlaceholderColor3 = Theme.Faint,
			TextColor3 = Theme.Text,
			TextSize = 9.5,
			MultiLine = true,
			TextWrapped = true,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Position = UDim2.fromOffset(9, 8),
			Size = UDim2.new(1, -18, 1, -16),
		}, field)
		U.connect(box.Focused, function()
			stroke.Transparency = 0.3
		end)
		U.connect(box.FocusLost, function()
			stroke.Transparency = 0.55
		end)

		local cancel = Nerx.Widgets.Button(card, "Cancel", function()
			Nerx:ClosePopup(true)
		end)
		cancel.Root.Position = UDim2.new(1, -150, 1, -26)
		cancel.Root.Size = UDim2.fromOffset(66, 26)
		local submit = Nerx.Widgets.PrimaryButton(card, config.Submit or "Import", 76, 26, function()
			local text = tostring(box.Text or "")
			if text == "" then
				return
			end
			Nerx:ClosePopup(true)
			if config.OnSubmit then
				config.OnSubmit(text)
			end
		end)
		submit.Root.Position = UDim2.new(1, -76, 1, -26)
		task.defer(function()
			pcall(function()
				box:CaptureFocus()
			end)
		end)
	end)
end

function UIHelpers.ContextMenu(anchor, items)
	items = items or {}
	local height = 10 + #items * 28
	U.popup(anchor, 178, height, function(card)
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
			U.label(row, {
				Text = item.Text or "Action",
				TextSize = 10.5,
				TextColor3 = item.Color or Theme.Text,
				TextTransparency = 0.15,
				Position = UDim2.fromOffset(9, 0),
				Size = UDim2.new(1, -18, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			local input = U.inputButton(row, function()
				Nerx:ClosePopup(true)
				if item.Callback then
					item.Callback()
				end
			end)
			U.connect(input.MouseEnter, function()
				U.tween(row, U.Tween.Fast, { BackgroundTransparency = 0.94 })
			end)
			U.connect(input.MouseLeave, function()
				U.tween(row, U.Tween.Fast, { BackgroundTransparency = 1 })
			end)
		end
	end)
end

function UIHelpers.Picker(anchor, config)
	config = config or {}
	local items = config.Items or {}
	local query = ""
	local renderList
	U.popup(anchor, 326, 332, function(card)
		U.padding(card, 9, 9, 9, 9)
		U.label(card, {
			Text = config.Title or "Select",
			Font = Fonts.Bold,
			TextSize = 11,
			TextColor3 = Theme.Text,
			TextTransparency = 0.05,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 16),
		})
		local search = U.frame(card, {
			BackgroundColor3 = Theme.FieldDeep,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 23),
			Size = UDim2.new(1, 0, 0, 26),
		})
		U.corner(search, 5)
		U.stroke(search, Theme.Stroke, 0.6, 1)
		local box = U.new("TextBox", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Fonts.Regular,
			Text = "",
			PlaceholderText = config.Placeholder or "Filter...",
			PlaceholderColor3 = Theme.Faint,
			TextColor3 = Theme.Text,
			TextSize = 10,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(9, 0),
			Size = UDim2.new(1, -18, 1, 0),
		}, search)

		local scroll = U.new("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 56),
			Size = UDim2.new(1, 0, 1, -56),
			CanvasSize = UDim2.fromOffset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Faint,
			ScrollBarImageTransparency = 0.35,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ElasticBehavior = Enum.ElasticBehavior.Never,
		}, card)
		U.list(scroll, 2)
		local rows = {}

		renderList = function()
			for _, row in ipairs(rows) do
				if row and row.Parent then
					row:Destroy()
				end
			end
			table.clear(rows)
			local count = 0
			for _, item in ipairs(items) do
				local labelText = tostring(item.Label or item.Name or "")
				local detailText = tostring(item.Detail or "")
				if query == ""
					or string.find(string.lower(labelText), query, 1, true)
					or string.find(string.lower(detailText), query, 1, true) then
					count = count + 1
					local row = U.frame(scroll, {
						BackgroundColor3 = Theme.White,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, detailText ~= "" and 34 or 28),
					})
					U.corner(row, 5)
					U.label(row, {
						Text = labelText,
						TextSize = 10,
						TextColor3 = item.Selected and Theme.Text or Theme.Muted,
						TextTransparency = item.Selected and 0.05 or 0.2,
						Position = UDim2.fromOffset(9, detailText ~= "" and 3 or 0),
						Size = UDim2.new(1, -26, 0, detailText ~= "" and 14 or 28),
						TextTruncate = Enum.TextTruncate.AtEnd,
					})
					if detailText ~= "" then
						U.label(row, {
							Text = detailText,
							TextSize = 7.5,
							TextColor3 = Theme.Faint,
							TextTransparency = 0.25,
							Position = UDim2.fromOffset(9, 17),
							Size = UDim2.new(1, -26, 0, 12),
							TextTruncate = Enum.TextTruncate.AtEnd,
						})
					end
					if item.Selected then
						U.icon(row, "circle-check", 10, Theme.Accent, {
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -9, 0.5, 0),
							Size = UDim2.fromOffset(14, 14),
							TextTransparency = 0.1,
						})
					end
					local input = U.inputButton(row, function()
						Nerx:ClosePopup(true)
						if config.OnSelect then
							config.OnSelect(item)
						end
					end)
					U.connect(input.MouseEnter, function()
						U.tween(row, U.Tween.Fast, { BackgroundTransparency = 0.94 })
					end)
					U.connect(input.MouseLeave, function()
						U.tween(row, U.Tween.Fast, { BackgroundTransparency = 1 })
					end)
					rows[#rows + 1] = row
				end
			end
			if count == 0 then
				local empty = U.label(scroll, {
					Text = config.EmptyText or "Nothing matches",
					TextSize = 9.5,
					TextColor3 = Theme.Faint,
					TextTransparency = 0.3,
					Position = UDim2.fromOffset(9, 8),
					Size = UDim2.new(1, -18, 0, 18),
				})
				rows[#rows + 1] = empty
			end
		end

		U.connect(box:GetPropertyChangedSignal("Text"), function()
			query = string.lower(tostring(box.Text or ""))
			renderList()
		end)
		renderList()
		task.defer(function()
			pcall(function()
				box:CaptureFocus()
			end)
		end)
	end)
end

function UIHelpers.CopyPath(fileName)
	local path = Nerx.Storage:Path(fileName)
	local copied = Nerx.Storage:Copy(path)
	UIKit.Notify("Storage", (copied and "Path copied: " or "") .. path, "floppy-disk", copied and Theme.Green or Theme.Amber)
	return path, copied
end

function UIHelpers.FormatAgo(timestamp)
	if not timestamp then
		return "never"
	end
	local delta = math.max(0, os.time() - timestamp)
	if delta < 60 then
		return "just now"
	elseif delta < 3600 then
		return math.floor(delta / 60) .. "m ago"
	elseif delta < 86400 then
		return math.floor(delta / 3600) .. "h ago"
	end
	return math.floor(delta / 86400) .. "d ago"
end

function UIHelpers.FormatSize(bytes)
	bytes = tonumber(bytes) or 0
	if bytes >= 1024 * 1024 then
		return string.format("%.1f MB", bytes / (1024 * 1024))
	end
	return string.format("%.1f KB", math.max(1, bytes) / 1024)
end

function UIHelpers.ConfigTint(name)
	local hash = 0
	local text = tostring(name or "")
	for index = 1, #text do
		hash = (hash * 31 + string.byte(text, index)) % 2147483647
	end
	local hue = (hash % 360) / 360
	return Color3.fromHSV(hue, 0.38, 0.24), Color3.fromHSV(hue, 0.3, 0.08)
end


-- ---------------------------------------------------------------------------------------
-- Locale: menu-wide runtime translation for text objects
-- ---------------------------------------------------------------------------------------
Nerx.Locale = {}
local Locale = Nerx.Locale

Locale.Language = "zh"
Locale.Enabled = false
Locale.Exact = {}
Locale.Words = {}
Locale.Skip = nil
Locale.Pairs = {}
Locale.ZhToEn = {}
Locale.EnToZh = {}

local localeOriginal = setmetatable({}, { __mode = "k" })
local localeWatched = setmetatable({}, { __mode = "k" })
local localeRoots = {}
local localeHooked = {}
local localeApplying = false

local function localeIsTextObject(object)
	local className = object.ClassName
	return className == "TextLabel" or className == "TextButton" or className == "TextBox"
end

function Locale:LooksChinese(text)
	for index = 1, #text do
		if string.byte(text, index) >= 128 then
			return true
		end
	end
	return false
end

function Locale:SetDictionary(exact, words)
	self.Exact = exact or {}
	self.Words = words or {}
end

-- 内置双语词条：库自己的 UI（背景向导、毛玻璃参数等）中英互切。
function Locale:RegisterPairs(pairs)
	for _, pair in ipairs(pairs or {}) do
		local zh, en = pair[1], pair[2]
		if type(zh) == "string" and type(en) == "string" then
			self.ZhToEn[zh] = en
			self.EnToZh[en] = zh
		end
	end
end

function Locale:SetSkip(predicate)
	self.Skip = predicate
end

function Locale:ShouldSkip(object)
	return self.Skip ~= nil and self.Skip(object) == true
end

-- 运行时拼接文案用：根据当前语言返回中/英版本。
function Locale:Pick(zh, en)
	if self.Language ~= "zh" and type(en) == "string" then
		return en
	end
	return zh
end

function Locale:Translate(text)
	if type(text) ~= "string" or text == "" then
		return text
	end
	if self.Language ~= "zh" then
		return self.ZhToEn[text] or text
	end
	local exact = self.Exact[text] or self.EnToZh[text]
	if exact then
		return exact
	end
	local dynamicTitle = string.match(text, "^Hotkeys · (.*)$")
	if dynamicTitle then
		local prefix = self.Exact["Hotkeys"] or "Hotkeys"
		local name = self.Exact[dynamicTitle] or self.EnToZh[dynamicTitle] or dynamicTitle
		return prefix .. " · " .. name
	end
	if string.find(text, "<") then
		return (text:gsub(">(%a[%w%s%-]-)<", function(name)
			local trimmed = string.match(name, "^%s*(.-)%s*$") or name
			return ">" .. (self.Exact[trimmed] or self.EnToZh[trimmed] or trimmed) .. "<"
		end))
	end
	if string.find(text, "[%d%[%]{}<>#%$\\/]") then
		return text
	end
	if string.find(text, "-") then
		return text
	end
	local parts = {}
	for word in string.gmatch(text, "%a[%a]*") do
		local translated = self.Words[word] or self.Words[string.lower(word)]
		if not translated then
			return text
		end
		parts[#parts + 1] = translated
	end
	if #parts == 0 then
		return text
	end
	return table.concat(parts)
end

function Locale:SetText(object, text)
	localeApplying = true
	object.Text = text
	localeApplying = false
end

local function localeEnsureStore(object)
	local store = localeOriginal[object]
	if not store then
		store = {}
		localeOriginal[object] = store
	end
	return store
end

local function localeLocalize(object)
	if not object or not object.Parent or Locale:ShouldSkip(object) then
		return
	end
	local store = localeEnsureStore(object)
	if object.ClassName == "TextBox" then
		local current = object.PlaceholderText
		if type(current) ~= "string" or current == "" then
			return
		end
		local original = store.Placeholder
		if original == nil or (store.PlaceholderOut ~= nil and current ~= store.PlaceholderOut) then
			original = current
			store.Placeholder = current
		end
		local mapped = Locale:Translate(original)
		if mapped ~= current then
			localeApplying = true
			object.PlaceholderText = mapped
			localeApplying = false
		end
		store.PlaceholderOut = mapped
		return
	end

	local current = object.Text
	if type(current) ~= "string" or current == "" then
		return
	end
	local original = store.Text
	if original == nil or (store.Out ~= nil and current ~= store.Out) then
		original = current
		store.Text = current
	end
	local mapped = Locale:Translate(original)
	if mapped ~= current then
		localeApplying = true
		object.Text = mapped
		localeApplying = false
	end
	store.Out = mapped
end

local function localeWatch(object)
	if localeWatched[object] then
		return
	end
	localeWatched[object] = true
	local store = localeEnsureStore(object)
	if object.ClassName == "TextBox" then
		U.connect(object:GetPropertyChangedSignal("PlaceholderText"), function()
			if localeApplying or Locale:ShouldSkip(object) then
				return
			end
			local current = object.PlaceholderText
			if store.PlaceholderOut ~= nil and current == store.PlaceholderOut then
				return
			end
			store.Placeholder = current
			local mapped = Locale:Translate(current)
			if mapped ~= current then
				localeApplying = true
				object.PlaceholderText = mapped
				localeApplying = false
			end
			store.PlaceholderOut = mapped
		end)
		return
	end
	U.connect(object:GetPropertyChangedSignal("Text"), function()
		if localeApplying or Locale:ShouldSkip(object) then
			return
		end
		local current = object.Text
		if store.Out ~= nil and current == store.Out then
			return
		end
		store.Text = current
		local mapped = Locale:Translate(current)
		if mapped ~= current then
			localeApplying = true
			object.Text = mapped
			localeApplying = false
		end
		store.Out = mapped
	end)
end

function Locale:Attach(root)
	if not root then
		return
	end
	for _, existing in ipairs(localeRoots) do
		if existing == root then
			return
		end
	end
	localeRoots[#localeRoots + 1] = root
	if not localeHooked[root] then
		localeHooked[root] = true
		U.connect(root.DescendantAdded, function(object)
			task.defer(function()
				if not object or not object.Parent or not localeIsTextObject(object) then
					return
				end
				localeWatch(object)
				localeLocalize(object)
			end)
		end)
	end
end

function Locale:Refresh()
	for _, root in ipairs(localeRoots) do
		if root.Parent then
			local objects = { root }
			for _, object in ipairs(root:GetDescendants()) do
				objects[#objects + 1] = object
			end
			for _, object in ipairs(objects) do
				if localeIsTextObject(object) then
					localeWatch(object)
					localeLocalize(object)
				end
			end
		end
	end
end

function Locale:SetEnabled(enabled)
	self.Enabled = enabled == true
	self.Language = self.Enabled and "zh" or "en"
	self:Refresh()
end

function Locale:SetLanguage(language)
	self.Language = language == "en" and "en" or "zh"
	self.Enabled = self.Language == "zh"
	self:Refresh()
end

-- 库自带界面的中英词条（示例的 SetDictionary 只负责英文→中文的菜单文本）。
Locale:RegisterPairs({
	{ "我的背景", "My Background" },
	{ "填充方式", "Fill mode" },
	{ "填充", "Fill" },
	{ "适应", "Fit" },
	{ "镜像", "Mirror" },
	{ "平铺", "Tile" },
	{ "保存并应用", "Save & apply" },
	{ "下一步", "Next" },
	{ "上一步", "Back" },
	{ "未设置", "Not set" },
	{ "同时保存到当前配置", "Also save to active config" },
	{ "背景图片", "Background image" },
	{ "菜单底色", "Menu base color" },
	{ "强调色", "Accent color" },
	{ "文字颜色", "Text color" },
	{ "暗度 / 柔化", "Dim / Soften" },
	{ "背景暗度", "Background dim" },
	{ "底色浓度", "Base tint" },
	{ "背景柔化", "Background softening" },
	{ "暗度越高文字越清晰；Roblox 无法对 UI 背景做真模糊，柔化会降低图片不透明度。",
		"Higher dim = clearer text. Softening lowers image opacity." },
	{ "保存到「我的主题」", "Save to My Themes" },
	{ "给这套背景起个名字", "Name this background" },
	{ "请先填写主题名称", "Enter a theme name first" },
	{ "URL 图片 · 三步完成", "URL image · three steps" },
	{ "01 · 图片", "01 · Image" },
	{ "02 · 调色", "02 · Colors" },
	{ "03 · 保存", "03 · Save" },
	{ "拖动 / 缩放选择要显示的区域", "Drag / zoom to frame the visible area" },
	{ "图片链接", "Image link" },
	{ "粘贴图床直链（PNG/JPG），留空恢复纯色", "Paste a direct image URL (PNG/JPG). Leave empty to restore the solid color." },
	{ "应用", "Apply" },
	{ "裁剪图片", "Crop image" },
	{ "16:9 · 菜单背景", "16:9 · Menu background" },
	{ "拖动图片 · 滑条缩放", "Drag the image · zoom with the slider" },
	{ "缩放", "Zoom" },
	{ "菜单预览", "Menu preview" },
	{ "应用裁剪", "Apply crop" },
	{ "取消", "Cancel" },
	{ "重置", "Reset" },
	{ "创建", "Create" },
	{ "选择", "Select" },
	{ "操作", "Action" },
	{ "没有匹配项", "Nothing matches" },
	{ "输入名称...", "Type a name..." },
	{ "筛选...", "Filter..." },
	{ "在此粘贴导出的 JSON...", "Paste exported JSON here..." },
	{ "自定义背景图", "Background" },
	{ "毛玻璃模式", "Frosted mode" },
	{ "同步到 Hotkeys", "Sync to Hotkeys" },
	{ "同步到头像 HUD", "Sync to avatar HUD" },
	{ "毛玻璃参数", "Frosted parameters" },
	{ "拖动实时生效", "Live preview" },
	{ "画面模糊(全局)", "Scene blur (global)" },
	{ "玻璃浓度", "Glass density" },
	{ "玻璃色调", "Glass tint" },
	{ "颗粒质感", "Grain" },
	{ "高光强度", "Sheen strength" },
	{ "扫光速度", "Sweep speed" },
	{ "色散强度", "Dispersion" },
	{ "轮廓亮度", "Outline brightness" },
	{ "描边厚度", "Border thickness" },
	{ "圆角", "Corner radius" },
	{ "按压深度", "Press depth" },
	{ "回弹阻力", "Spring" },
	{ "恢复默认", "Reset to default" },
})



-- ---------------------------------------------------------------------------------------
-- ThemePage: reusable Themes page (cards, preview, palette editor)
-- ---------------------------------------------------------------------------------------
Nerx.ThemePage = {}
local ThemePage = Nerx.ThemePage

function ThemePage.Build(themesPage, config)
	config = config or {}
	local window = config.Window or (Nerx.Windows and Nerx.Windows[1])
	local themes = themesPage:SetCustomMode()
	local T = Theme
	local F = Fonts
	local W = Nerx.Widgets
	local UIHelpers = UIKit.UIHelpers
	local notify = UIKit.Notify
	local titleText = UIKit.TitleText
	local surfaceCard = UIKit.SurfaceCard
	local toolbarButton = UIKit.ToolbarButton
	local toolbarPrimary = UIKit.ToolbarPrimary
	local filterField = UIKit.FilterField

	local renderThemes

	local customColors = {
		Base = T.Sidebar,
		Panel = T.SurfaceRaised,
		Text = T.Text,
		Accent = T.Accent,
	}

	local themesTitle = titleText(themes, "Themes")

	-- 毛玻璃入口：紧贴标题右侧的三点（需 NerxUI 1.3.2+ 的 Nerx.Frosted）
	local Frosted = Nerx.Frosted
	if not Frosted then
		warn("[Nerx UI] 当前库缺少 Nerx.Frosted，请更新到 1.3.2；毛玻璃入口已跳过")
	end

	local frostDots, frostDotsInput
	if Frosted then
		frostDots = U.icon(themes, "three-dots-horizontal", 14, T.Accent, {
			Position = UDim2.fromOffset(themesTitle.Size.X.Offset + 5, 7),
			Size = UDim2.fromOffset(16, 14),
			TextTransparency = 0.15,
			TextStrokeColor3 = T.Window,
			TextStrokeTransparency = 0.55,
		})
		frostDotsInput = U.inputButton(themes, nil)
		frostDotsInput.Position = UDim2.fromOffset(themesTitle.Size.X.Offset, 0)
		frostDotsInput.Size = UDim2.fromOffset(28, 28)
	end

	-- ---------------------------------------------------------------------------------------
	-- 自定义背景图入口（背景层 / 向导 / 裁剪 / 保存都在库内 Nerx.Background）
	-- ---------------------------------------------------------------------------------------
	if Nerx.Background then
		Nerx.Background:Attach(window)
	end
	local bgButton = W.Button(themes, "自定义背景图", function()
		if Nerx.Background then
			Nerx.Background:Open(window)
		end
	end)
	bgButton.Root.Position = UDim2.fromOffset(themesTitle.Size.X.Offset + 34, 0)
	bgButton.Root.Size = UDim2.fromOffset(92, 28)

	local FROST_FILE = "frosted.json"
	local frostSyncHotkeys = false
	local frostSyncAvatar = false

	local function frostSave()
		Nerx.Storage:WriteJSON(FROST_FILE, {
			Enabled = Frosted.Enabled,
			Params = Frosted:GetParams(),
			SyncHotkeys = frostSyncHotkeys,
			SyncAvatar = frostSyncAvatar,
		})
	end

	local frostSaveToken = 0
	local function frostQueueSave()
		frostSaveToken = frostSaveToken + 1
		local token = frostSaveToken
		task.delay(0.35, function()
			if token == frostSaveToken then
				frostSave()
			end
		end)
	end

	local function frostApply(partial)
		Frosted:Apply(partial)
		frostQueueSave()
	end

	local function frostSetEnabled(enabled)
		Frosted:SetEnabled(enabled)
		frostSave()
	end

	-- 毛玻璃同步：Hotkeys 浮层 / 左下角头像卡
	local frostSyncWarned = false

	local function frostSetSyncHotkeys(value)
		frostSyncHotkeys = value == true
		local manager = Nerx.BindManager
		if manager then
			if manager.SetFrosted then
				if frostSyncHotkeys and manager.SetOverlayEnabled and manager.IsOverlayEnabled
					and not manager:IsOverlayEnabled() then
					manager:SetOverlayEnabled(true)
				end
				manager:SetFrosted(frostSyncHotkeys)
				if manager.RefreshOverlay then
					manager:RefreshOverlay()
				end
			elseif frostSyncHotkeys and not frostSyncWarned then
				frostSyncWarned = true
				warn("[Nerx UI] 当前 NerxUI.luau 缺少 BindManager:SetFrosted，Hotkeys 毛玻璃同步不可用；请重新复制最新的 NerxUI.luau")
			end
		end
		if Frosted then
			Frosted:Refresh()
		end
		frostSave()
	end

	local function frostSetSyncAvatar(value)
		frostSyncAvatar = value == true
		if Frosted and window and window.Account then
			if frostSyncAvatar then
				Frosted:Register(window.Account, { Kind = "card", SheenScale = 1.5, Halo = false, Chroma = false })
			else
				pcall(function()
					Frosted:Unregister(window.Account)
				end)
			end
			Frosted:Refresh()
		end
		frostSave()
	end

	-- 9 行参数滑块：轨道 + 填充 + 圆钮，拖动时实时应用
	local function frostSlider(parent, y, label, key, min, max, step, format)
		local params = Frosted.Params
		local value = tonumber(params[key]) or min
		local row = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, y),
			Size = UDim2.new(1, -20, 0, 32),
		})
		U.label(row, {
			Text = label,
			TextSize = 10,
			TextColor3 = T.Text,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(96, 16),
		})
		local valueLabel = U.label(row, {
			Text = format and format(value) or tostring(value),
			TextSize = 9.5,
			TextColor3 = T.Muted,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromOffset(58, 16),
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		local track = U.frame(row, {
			BackgroundColor3 = T.Field,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 22),
			Size = UDim2.new(1, 0, 0, 3),
		})
		U.corner(track, 2)
		local fill = U.frame(track, {
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new((value - min) / math.max(max - min, 0.0001), 0, 1, 0),
		})
		U.corner(fill, 2)
		local knob = U.frame(row, {
			BackgroundColor3 = T.Accent,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			Position = UDim2.new((value - min) / math.max(max - min, 0.0001), 0, 0, 23),
			Size = UDim2.fromOffset(9, 9),
		})
		U.corner(knob, 5)

		local dragging = false
		local function setFromX(x)
			local origin = track.AbsolutePosition.X
			local width = math.max(track.AbsoluteSize.X, 1)
			local alpha = math.clamp((x - origin) / width, 0, 1)
			local raw = min + (max - min) * alpha
			if step and step > 0 then
				raw = math.floor(raw / step + 0.5) * step
			end
			raw = math.clamp(raw, min, max)
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0, 23)
			valueLabel.Text = format and format(raw) or tostring(raw)
			frostApply({ [key] = raw })
		end

		local input = U.inputButton(row, nil)
		input.Size = UDim2.new(1, 0, 0, 32)
		U.connect(input.InputBegan, function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				setFromX(inputObject.Position.X)
			end
		end)
		U.connect(UserInputService.InputEnded, function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		U.connect(UserInputService.InputChanged, function(inputObject)
			if not dragging then
				return
			end
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement
				or inputObject.UserInputType == Enum.UserInputType.Touch then
				setFromX(inputObject.Position.X)
			end
		end)
	end

	local frostParamsOpen = false
	local openFrostPanel

	-- 单张卡片同时容纳「毛玻璃模式」和参数列：模式行固定 208 宽在左，
	-- 参数列出现在开关右侧（x=220），不会覆盖模式行。
	openFrostPanel = function(showParams)
		frostParamsOpen = showParams == true

		local width = frostParamsOpen and 432 or 208
		local height = frostParamsOpen and 466 or 52

		U.popup(frostDotsInput, width, height, function(card)
			local mainCol = U.frame(card, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(208, height),
			})

			U.label(mainCol, {
				Text = "毛玻璃模式",
				TextSize = 11.5,
				TextColor3 = T.Text,
				Position = UDim2.fromOffset(12, 17),
				Size = UDim2.fromOffset(110, 18),
			})

			local toggle = W.Toggle(mainCol, Frosted.Enabled, function(value)
				frostSetEnabled(value)
			end, false)
			toggle.Root.AnchorPoint = Vector2.new(1, 0)
			toggle.Root.Position = UDim2.new(1, -12, 0, 16)

			-- 参数入口：紧贴开关左侧的三点，点击展开/收起右侧参数列
			local dots = U.icon(mainCol, "three-dots-horizontal", 13, T.Accent, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -52, 0, 18),
				Size = UDim2.fromOffset(16, 14),
				TextTransparency = frostParamsOpen and 0 or 0.15,
				TextStrokeColor3 = T.Window,
				TextStrokeTransparency = 0.55,
			})
			local dotsInput = U.inputButton(dots, function()
				openFrostPanel(not frostParamsOpen)
			end)
			dotsInput.Size = UDim2.fromScale(1, 1)

			if not frostParamsOpen then
				return
			end

			-- 模式行下方的分划线 + 同步设置
			U.frame(mainCol, {
				BackgroundColor3 = Theme.StrokeSoft,
				BackgroundTransparency = 0.45,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(12, 52),
				Size = UDim2.new(1, -24, 0, 1),
			})

			local syncY = 64
			local function syncRow(text, value, callback)
				U.label(mainCol, {
					Text = text,
					TextSize = 10.5,
					TextColor3 = T.Text,
					Position = UDim2.fromOffset(12, syncY + 3),
					Size = UDim2.fromOffset(126, 18),
				})
				local toggle = W.Toggle(mainCol, value, callback, false)
				toggle.Root.AnchorPoint = Vector2.new(1, 0)
				toggle.Root.Position = UDim2.new(1, -12, 0, syncY)
				syncY = syncY + 32
			end

			syncRow("同步到 Hotkeys", frostSyncHotkeys, function(value)
				frostSetSyncHotkeys(value)
			end)
			syncRow("同步到头像 HUD", frostSyncAvatar, function(value)
				frostSetSyncAvatar(value)
			end)

			U.frame(card, {
				BackgroundColor3 = Theme.StrokeSoft,
				BackgroundTransparency = 0.35,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(208, 10),
				Size = UDim2.new(0, 1, 1, -20),
			})

			local paramCol = U.frame(card, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(220, 0),
				Size = UDim2.fromOffset(212, height),
			})

			U.label(paramCol, {
				Text = "毛玻璃参数",
				Font = F.Bold,
				TextSize = 11,
				TextColor3 = T.Text,
				Position = UDim2.fromOffset(10, 10),
				Size = UDim2.fromOffset(160, 18),
			})
			U.label(paramCol, {
				Text = "拖动实时生效",
				TextSize = 8.5,
				TextColor3 = T.Faint,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -10, 0, 12),
				Size = UDim2.fromOffset(120, 14),
				TextXAlignment = Enum.TextXAlignment.Right,
			})

			local y = 34
			local function row(label, key, min, max, step, pattern)
				frostSlider(paramCol, y, label, key, min, max, step, function(v)
					return string.format(pattern, v)
				end)
				y = y + 32
			end

			row("画面模糊(全局)", "Blur", 0, 30, 1, "%d")
			row("玻璃浓度", "Opacity", 0, 0.9, 0.01, "%.2f")
			row("玻璃色调", "Tint", 0, 1, 0.01, "%.2f")
			row("颗粒质感", "Grain", 0, 1, 0.01, "%.2f")
			row("高光强度", "Sheen", 0, 1, 0.01, "%.2f")
			row("扫光速度", "Sweep", 0, 1, 0.01, "%.2f")
			row("色散强度", "Dispersion", 0, 1, 0.01, "%.2f")
			row("轮廓亮度", "Outline", 0, 1, 0.01, "%.2f")
			row("描边厚度", "Thickness", 0.5, 3, 0.5, "%.1f")
			row("圆角", "Radius", 0, 24, 1, "%d")
			row("按压深度", "Press", 0.9, 1, 0.005, "%.3f")
			row("回弹阻力", "Spring", 8, 40, 1, "%d")

			local reset = W.Button(paramCol, "恢复默认", function()
				Frosted:Reset()
				frostSave()
				openFrostPanel(true)
			end)
			reset.Root.AnchorPoint = Vector2.new(0.5, 0)
			reset.Root.Position = UDim2.new(0.5, 0, 0, 424)
			reset.Root.Size = UDim2.fromOffset(120, 28)
		end, false)
	end

	local function openFrostMenu()
		openFrostPanel(false)
	end

	local function openFrostParams()
		openFrostPanel(true)
	end

	if frostDotsInput then
		U.inputButton(frostDotsInput, function()
			openFrostMenu()
		end)

		do
			local saved = Nerx.Storage:ReadJSON(FROST_FILE)
			if type(saved) == "table" then
				if type(saved.Params) == "table" then
					-- Scene blur is opt-in per session: never restore it from disk,
					-- otherwise an old config keeps blurring the game on inject.
					saved.Params.Blur = 0
					Frosted:SetParams(saved.Params)
				end
				if saved.Enabled == true then
					Frosted:SetEnabled(true)
				end
				if saved.SyncHotkeys == true then
					frostSyncHotkeys = true
					if Nerx.BindManager then
						Nerx.BindManager:SetFrosted(true)
					end
				end
				if saved.SyncAvatar == true then
					frostSyncAvatar = true
					if window and window.Account then
						Frosted:Register(window.Account, { Kind = "card", SheenScale = 1.5, Halo = false, Chroma = false })
					end
				end
			end
		end
	end

	local themeFilter = filterField(themes, 196, 0, 118, "Filter themes...")
	local themeSort = W.Segmented(themes, {
		Width = 104,
		Height = 28,
		Items = { "Name", "Recent" },
		Selected = "Name",
		Callback = function()
			if renderThemes then
				renderThemes()
			end
		end,
	})
	themeSort.Root.Position = UDim2.fromOffset(322, 0)
	local openThemesButton = toolbarButton(themes, "Open folder", 258, 0, 84, 28, function()
		UIHelpers.CopyPath("themes.json")
	end)
	local importThemeButton
	importThemeButton = toolbarButton(themes, "Import", 194, 0, 58, 28, function()
		UIHelpers.ImportPrompt(importThemeButton.Root, {
			Title = "Import theme",
			Placeholder = "Paste an exported Nerx theme here...",
			Submit = "Import",
			OnSubmit = function(text)
				local ok, reason = Nerx.Themes:Import(text)
				if ok then
					notify("Themes", "Theme imported into My Themes", "paint-bucket", T.Green)
					renderThemes()
				else
					notify("Themes", "Theme import failed: " .. tostring(reason), "triangle-exclamation", T.Red)
				end
			end,
		})
	end)
	local exportThemeButton = toolbarButton(themes, "Export", 130, 0, 58, 28, function()
		local json = Nerx.Themes:Export()
		if not json then
			notify("Themes", "No active theme to export", "paint-bucket", T.Amber)
			return
		end
		local copied = Nerx.Storage:Copy(json)
		notify("Themes", "Exported \"" .. tostring(Nerx.Themes.ActiveName) .. "\"" .. (copied and " to clipboard" or ""), "paint-bucket", copied and T.Green or T.Amber)
	end)
	local saveThemeButton
	saveThemeButton = toolbarPrimary(themes, "+ Save as", 0, 0, 92, 28, function()
		UIHelpers.InputPrompt(saveThemeButton.Root, {
			Title = "Save current theme",
			Placeholder = "Theme name...",
			Submit = "Save",
			OnSubmit = function(name)
				local ok = Nerx.Themes:SaveCustom(name)
				if ok then
					notify("Themes", "Saved \"" .. name .. "\" to My Themes", "paint-bucket", T.Green)
				else
					notify("Themes", "Could not save that theme", "triangle-exclamation", T.Red)
				end
			end,
		})
	end)

	local themeScroll = U.new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 48),
		Size = UDim2.new(1, 0, 1, -48),
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.Faint,
		ScrollBarImageTransparency = 0.35,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
	}, themes)
	local themeContent = U.frame(themeScroll, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 300),
	})

	local themeCards = {}

	local THEME_CARD_W = 183
	local THEME_CARD_H = 132
	local THEME_CARD_STEP = 192
	local THEME_ROW_STEP = 142
	local THEME_CUSTOM_H = 112
	local THEME_CUSTOM_STEP = 124

	local function themeBaseIsLight(color)
		return ((color.R or 0) * 0.299 + (color.G or 0) * 0.587 + (color.B or 0) * 0.114) > 0.58
	end

	local function previewDot(parent, x, y, size, color, transparency, zIndex)
		local dot = U.frame(parent, {
			BackgroundColor3 = color,
			BackgroundTransparency = transparency or 0,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(size, size),
			ZIndex = zIndex or 2,
		})
		U.new("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)
		return dot
	end

	local function miniPreview(parent, preset, height)
		local h = height or 78
		local light = themeBaseIsLight(preset.Base)
		local ink = light and T.Black or T.White
		local preview = U.frame(parent, {
			BackgroundColor3 = preset.Base,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(7, 7),
			Size = UDim2.new(1, -14, 0, h),
			ClipsDescendants = true,
		})
		U.corner(preview, 5)
		U.stroke(preview, ink, light and 0.82 or 0.88, 1)
		-- Top chrome strip with the accent tick, like the reference previews.
		U.frame(preview, {
			BackgroundColor3 = preset.Panel,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 7),
		})
		local tick = U.frame(preview, {
			BackgroundColor3 = preset.Accent,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(6, 2),
			Size = UDim2.fromOffset(10, 2),
		})
		U.corner(tick, 1)
		local accentInk = themeBaseIsLight(preset.Accent) and T.Black or T.White
		-- Sidebar block.
		local side = U.frame(preview, {
			BackgroundColor3 = preset.Panel,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(5, 11),
			Size = UDim2.fromOffset(28, h - 16),
		})
		U.corner(side, 3)
		U.stroke(side, ink, 0.86, 1)
		previewDot(side, 4, 5, 3, preset.Accent, 0.1, 3)
		U.frame(side, {
			BackgroundColor3 = ink,
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(9, 5),
			Size = UDim2.fromOffset(11, 3),
		})
		-- Selected row pill in the sidebar.
		local pill = U.frame(side, {
			BackgroundColor3 = preset.Accent,
			BackgroundTransparency = 0.42,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(3, 13),
			Size = UDim2.fromOffset(22, 7),
		})
		U.corner(pill, 3)
		previewDot(pill, 2, 2, 3, accentInk, 0.05, 4)
		U.frame(pill, {
			BackgroundColor3 = accentInk,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(7, 2),
			Size = UDim2.fromOffset(9, 3),
		})
		for index = 1, (h >= 74 and 5 or 3) do
			local rowY = 25 + (index - 1) * 8
			previewDot(side, 4, rowY, 2, ink, 0.55, 3)
			U.frame(side, {
				BackgroundColor3 = ink,
				BackgroundTransparency = 0.72,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(9, rowY),
				Size = UDim2.fromOffset(index == 1 and 11 or 8, 2),
			})
		end
		-- Main column rows + accent slider.
		for index = 1, (h >= 74 and 4 or 3) do
			local rowY = 13 + (index - 1) * 12
			previewDot(preview, 39, rowY, 3, ink, 0.5, 2)
			U.frame(preview, {
				BackgroundColor3 = ink,
				BackgroundTransparency = 0.62,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(45, rowY),
				Size = UDim2.fromOffset(index == 1 and 60 or 52, 3),
			})
		end
		-- Right column keeps the preview from looking left-heavy.
		U.frame(preview, {
			BackgroundColor3 = ink,
			BackgroundTransparency = 0.88,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(112, 10),
			Size = UDim2.fromOffset(1, h - 22),
		})
		for index = 1, (h >= 74 and 4 or 3) do
			U.frame(preview, {
				BackgroundColor3 = ink,
				BackgroundTransparency = 0.7,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(119, 11 + (index - 1) * 9),
				Size = UDim2.fromOffset(38, 3),
			})
		end
		local previewToggle = U.frame(preview, {
			BackgroundColor3 = preset.Accent,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(119, h - 30),
			Size = UDim2.fromOffset(28, 9),
			ZIndex = 2,
		})
		U.corner(previewToggle, 5)
		previewDot(previewToggle, 19, 1.5, 6, accentInk, 0.05, 4)

		local trackW = 54
		local trackX = 39
		local trackY = h - 16
		U.frame(preview, {
			BackgroundColor3 = ink,
			BackgroundTransparency = 0.78,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(trackX, trackY),
			Size = UDim2.fromOffset(trackW, 3),
		})
		U.frame(preview, {
			BackgroundColor3 = preset.Accent,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(trackX, trackY),
			Size = UDim2.fromOffset(math.floor(trackW * 0.55), 3),
		})
		previewDot(preview, trackX + math.floor(trackW * 0.55) - 2, trackY - 2, 7, preset.Accent, 0, 4)
	end

	local function hexColor(color)
		return string.format(
			"#%02X%02X%02X",
			math.floor((color.R or 0) * 255),
			math.floor((color.G or 0) * 255),
			math.floor((color.B or 0) * 255)
		)
	end

	local function applyTheme(name)
		local ok = Nerx.Themes:ApplyPreset(name)
		if ok then
			customColors.Base = T.Sidebar
			customColors.Panel = T.SurfaceRaised
			customColors.Accent = T.Accent
			notify("Themes", "Applied \"" .. tostring(name) .. "\"", "paint-bucket", T.Accent)
			renderThemes()
		else
			notify("Themes", "Could not apply that theme", "triangle-exclamation", T.Red)
		end
	end

	local function accentGem(parent, x, y, size, color, glow)
		local gem = U.frame(parent, {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(size, size),
			ZIndex = 5,
		})
		U.new("UICorner", { CornerRadius = UDim.new(1, 0) }, gem)
		U.stroke(gem, T.White, 0.7, 1)
		local shine = U.frame(gem, {
			BackgroundColor3 = T.White,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(size * 0.18, size * 0.12),
			Size = UDim2.fromOffset(size * 0.44, size * 0.34),
			ZIndex = 6,
		})
		U.new("UICorner", { CornerRadius = UDim.new(1, 0) }, shine)
		if glow then
			local ok, shadow = pcall(function()
				return Instance.new("UIShadow")
			end)
			if ok and shadow then
				pcall(function()
					shadow.BlurRadius = UDim.new(0, 7)
					shadow.Color = color
					shadow.Offset = UDim2.new()
					shadow.Spread = UDim2.fromOffset(1, 1)
					shadow.Transparency = 0.5
					shadow.Inset = false
					shadow.Mode = Enum.ApplyShadowMode.Shape
					shadow.ShowBehindParent = true
				end)
				shadow.Parent = gem
			end
		end
		return gem
	end

	local function exportTheme(name)
		local json = Nerx.Themes:Export(name)
		if not json then
			notify("Themes", "Nothing to export", "paint-bucket", T.Amber)
			return
		end
		local copied = Nerx.Storage:Copy(json)
		notify("Themes", "Exported \"" .. tostring(name) .. "\"" .. (copied and " to clipboard" or ""), "paint-bucket", copied and T.Green or T.Amber)
	end

	local function drawThemeCard(parent, x, y, name, colors, kind, bgRecord)
		local isCustom = kind == "custom"
		local cardHeight = isCustom and THEME_CUSTOM_H or THEME_CARD_H
		local previewHeight = isCustom and 62 or 78
		local lightBase = themeBaseIsLight(colors.Base)
		local ink = lightBase and T.Black or T.White
		-- No ClipsDescendants here: every child is inset, and a clipped canvas
		-- would eat the blur of the card's own drop shadow.
		local card, stroke = surfaceCard(parent, x, y, THEME_CARD_W, cardHeight, {
			Radius = 9,
			Background = colors.Base,
			StrokeColor = ink,
			StrokeTransparency = lightBase and 0.6 or 0.84,
		})
		local cardShadow = U.shadow(card, "soft")
		if cardShadow and cardShadow.ClassName == "UIShadow" then
			cardShadow.BlurRadius = UDim.new(0, 16)
			cardShadow.Transparency = 0.58
			cardShadow.Offset = UDim2.fromOffset(0, 5)
		end
		-- Inner top reflection: the card reads as a raised glass tile instead of a
		-- flat rectangle, and it never becomes a gradient rim on the outer edge.
		local sheen = U.frame(card, {
			BackgroundColor3 = T.White,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, 1),
			Size = UDim2.new(1, -20, 0, 1),
			ZIndex = 6,
		})
		local sheenFade = Instance.new("UIGradient")
		sheenFade.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.72),
			NumberSequenceKeypoint.new(1, 1),
		})
		sheenFade.Parent = sheen
		if bgRecord and bgRecord.url and bgRecord.url ~= "" then
			local cover = U.frame(card, {
				BackgroundColor3 = colors.Base,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(7, 7),
				Size = UDim2.new(1, -14, 0, previewHeight),
				ClipsDescendants = true,
				ZIndex = 2,
			})
			U.corner(cover, 5)
			U.stroke(cover, ink, lightBase and 0.82 or 0.88, 1)
			local coverImage = U.new("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Image = (Nerx.Background and Nerx.Background:GetAsset(bgRecord.url)) or "",
				ImageTransparency = 0,
				ZIndex = 2,
			}, cover)
			if Nerx.Background and Nerx.Background.Layout then
				Nerx.Background:Layout(coverImage, THEME_CARD_W - 14, previewHeight, bgRecord)
			end
		else
			miniPreview(card, colors, previewHeight)
		end

		local labelY = isCustom and 72 or 97
		U.label(card, {
			Text = name,
			TextSize = 12,
			TextColor3 = ink,
			TextTransparency = lightBase and 0.3 or 0.26,
			Position = UDim2.fromOffset(11, labelY),
			Size = UDim2.fromOffset(THEME_CARD_W - 66, 18),
			ZIndex = 4,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		if isCustom then
			U.label(card, {
				Text = "custom",
				Font = F.Bold,
				TextSize = 7,
				TextColor3 = ink,
				TextTransparency = 0.55,
				Position = UDim2.fromOffset(11, 90),
				Size = UDim2.fromOffset(80, 9),
				ZIndex = 4,
			})
		end
		-- Reference detail: three palette gems (accent / white / black) at the
		-- bottom right, each with its own rim, instead of one hard 8x8 square.
		local dotY = isCustom and 78 or 103
		local dotSize = 6
		accentGem(card, THEME_CARD_W - 34, dotY, dotSize, colors.Accent, true)
		local whiteDot = U.frame(card, {
			BackgroundColor3 = T.White,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(THEME_CARD_W - 25, dotY),
			Size = UDim2.fromOffset(dotSize, dotSize),
			ZIndex = 5,
		})
		U.new("UICorner", { CornerRadius = UDim.new(1, 0) }, whiteDot)
		U.stroke(whiteDot, T.Black, 0.86, 1)
		local blackDot = U.frame(card, {
			BackgroundColor3 = T.Black,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(THEME_CARD_W - 16, dotY),
			Size = UDim2.fromOffset(dotSize, dotSize),
			ZIndex = 5,
		})
		U.new("UICorner", { CornerRadius = UDim.new(1, 0) }, blackDot)
		U.stroke(blackDot, T.White, 0.72, 1)

		local activeTag = U.label(card, {
			Text = "ACTIVE",
			Font = F.Bold,
			TextSize = 7,
			TextColor3 = colors.Accent,
			TextTransparency = 0.1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -9, 0, 9),
			Size = UDim2.fromOffset(60, 9),
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 5,
			Visible = false,
		})

		-- Selected halo + crisp accent outline live above the card so the rounded
		-- corners are never clipped by the preview.
		local haloOuter = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x - 4, y - 4),
			Size = UDim2.fromOffset(THEME_CARD_W + 8, cardHeight + 8),
			ZIndex = 27,
			Visible = false,
			Active = false,
		})
		U.corner(haloOuter, 13)
		U.stroke(haloOuter, colors.Accent, 0.8, 3.5)
		local halo = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x - 2, y - 2),
			Size = UDim2.fromOffset(THEME_CARD_W + 4, cardHeight + 4),
			ZIndex = 28,
			Visible = false,
			Active = false,
		})
		U.corner(halo, 11)
		U.stroke(halo, colors.Accent, 0.5, 2)
		local outline = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(THEME_CARD_W, cardHeight),
			ZIndex = 30,
			Active = false,
		})
		U.corner(outline, 9)
		local outlineStroke = U.stroke(outline, ink, 1, 1)

		local isActive = Nerx.Themes.ActiveName == name
		local entry = {
			Name = name,
			Card = card,
			Stroke = stroke,
			Accent = colors.Accent,
			X = x,
			Y = y,
			Width = THEME_CARD_W,
			Height = cardHeight,
			Outline = outline,
			Halo = halo,
			HaloOuter = haloOuter,
			Intro = false,
		}
		themeCards[#themeCards + 1] = entry
		function entry.Render(active)
			outline.Visible = true
			halo.Visible = active
			haloOuter.Visible = active
			activeTag.Visible = active
			stroke.Color = active and colors.Accent or ink
			stroke.Transparency = active and 0.35 or (lightBase and 0.6 or 0.84)
			outlineStroke.Color = colors.Accent
			outlineStroke.Transparency = active and 0.1 or 1
			outlineStroke.Thickness = active and 1.4 or 1
		end
		entry.Render(isActive)

		local function setHover(hovering)
			-- 入场动画期间卡片的 AnchorPoint 是 0.5/0.5，此时按最终坐标做 hover
			-- 位移会让卡片瞬间飞出去；直接忽略入场期间的 hover。
			if entry.Intro or not card.Parent then
				return
			end
			local lift = hovering and -1 or 0
			U.tween(card, U.Tween.Fast, { Position = UDim2.fromOffset(x, y + lift) })
			U.tween(outline, U.Tween.Fast, { Position = UDim2.fromOffset(x, y + lift) })
			U.tween(halo, U.Tween.Fast, { Position = UDim2.fromOffset(x - 2, y - 2 + lift) })
			U.tween(haloOuter, U.Tween.Fast, { Position = UDim2.fromOffset(x - 4, y - 4 + lift) })
			if not isActive then
				outlineStroke.Color = hovering and colors.Accent or ink
				outlineStroke.Transparency = hovering and 0.55 or 1
			end
			stroke.Transparency = (not hovering and not isActive) and (lightBase and 0.6 or 0.84)
				or (isActive and 0.35 or 0.5)
		end

		local input = U.inputButton(card, function()
			if entry.Intro then
				return
			end
			-- Theme switch rebuilds the grid, so let the press rebound play first.
			task.delay(0.14, function()
				applyTheme(name)
				if Nerx.Background then
					Nerx.Background:ApplyForTheme(name)
				end
			end)
		end)
		U.pressFx(input, card, 0.975)
		U.connect(input.MouseEnter, function()
			setHover(true)
		end)
		U.connect(input.MouseLeave, function()
			setHover(false)
		end)
		U.connect(input.InputBegan, function(inputObject)
			if entry.Intro or inputObject.UserInputType ~= Enum.UserInputType.MouseButton2 then
				return
			end
			local items = {
				{ Text = "Apply theme", Callback = function()
					applyTheme(name)
				end },
				{ Text = "Export to clipboard", Callback = function()
					exportTheme(name)
				end },
			}
			if kind == "custom" then
				items[#items + 1] = { Text = "Rename", Callback = function()
					UIHelpers.InputPrompt(card, {
						Title = "Rename theme",
						Initial = name,
						Submit = "Rename",
						OnSubmit = function(newName)
							local ok = Nerx.Themes:RenameCustom(name, newName)
							if ok and Nerx.Background then
								Nerx.Background:RenameCustom(name, newName)
								renderThemes()
							end
							notify("Themes", ok and ("Renamed to \"" .. newName .. "\"") or "Rename failed", "paint-bucket", ok and T.Green or T.Red)
						end,
					})
				end }
				items[#items + 1] = { Text = "Delete", Color = T.Red, Callback = function()
					local ok = Nerx.Themes:DeleteCustom(name)
					if Nerx.Background then
						Nerx.Background:DeleteCustom(name)
						renderThemes()
					end
					notify("Themes", ok and ("Deleted \"" .. name .. "\"") or "Delete failed", "trash-can", ok and T.Muted or T.Red)
				end }
			end
			UIHelpers.ContextMenu(card, items)
		end)
	end

	local function drawColorField(parent, x, label, color, onPick)
		U.label(parent, {
			Text = label,
			TextSize = 8.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.3,
			Position = UDim2.fromOffset(x, 34),
			Size = UDim2.fromOffset(80, 12),
		})
		local swatch = U.frame(parent, {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, 50),
			Size = UDim2.fromOffset(42, 24),
		})
		U.corner(swatch, 5)
		U.stroke(swatch, T.White, 0.75, 1)
		local hex = U.label(parent, {
			Text = hexColor(color),
			Font = F.Mono,
			TextSize = 8.5,
			TextColor3 = T.Text,
			TextTransparency = 0.25,
			Position = UDim2.fromOffset(x + 50, 50),
			Size = UDim2.fromOffset(120, 24),
		})
		U.inputButton(swatch, function()
			U.colorPicker(swatch, color, function(picked)
				color = picked
				swatch.BackgroundColor3 = picked
				hex.Text = hexColor(picked)
				onPick(picked)
			end)
		end)
	end

	local function drawPaletteEditor(parent, y)
		local card = U.frame(parent, {
			BackgroundColor3 = T.Surface,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.fromOffset(772, 196),
		})
		U.corner(card, 8)
		U.stroke(card, T.Stroke, 0.55, 1)
		U.label(card, {
			Text = "CUSTOM PALETTE",
			Font = F.Bold,
			TextSize = 9.5,
			TextColor3 = T.Text,
			TextTransparency = 0.1,
			Position = UDim2.fromOffset(14, 12),
			Size = UDim2.fromOffset(140, 16),
		})
		U.label(card, {
			Text = "Base = shell · Panel = cards and fields · Accent = highlights",
			TextSize = 8.5,
			TextColor3 = T.Faint,
			TextTransparency = 0.35,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 12),
			Size = UDim2.fromOffset(420, 16),
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		drawColorField(card, 14, "BASE", customColors.Base, function(color)
			customColors.Base = color
		end)
		drawColorField(card, 204, "PANEL", customColors.Panel, function(color)
			customColors.Panel = color
		end)
		drawColorField(card, 394, "TEXT", customColors.Text, function(color)
			customColors.Text = color
		end)
		drawColorField(card, 584, "ACCENT", customColors.Accent, function(color)
			customColors.Accent = color
		end)
		U.label(card, {
			Text = "Pick base, panel, text and accent. Derived shades keep borders readable.",
			TextSize = 8,
			TextColor3 = T.Faint,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(14, 92),
			Size = UDim2.new(1, -28, 0, 14),
		})

		local function applyCustomPalette(persist)
			local palette = Nerx.Themes:BuildPalette({
				Base = customColors.Base,
				Panel = customColors.Panel,
				Accent = customColors.Accent,
			})
			palette.Text = customColors.Text
			palette.Muted = customColors.Text:Lerp(customColors.Base, 0.38)
			palette.Faint = customColors.Text:Lerp(customColors.Base, 0.6)
			return Nerx.Themes:ApplyPalette(palette, "Custom", { noPersist = not persist })
		end

		local applyButton = W.PrimaryButton(card, "Apply colors", 104, 26, function()
			applyCustomPalette(true)
			notify("Themes", "Applied custom base, panel, text and accent", "paint-bucket", customColors.Accent)
			renderThemes()
		end)
		applyButton.Root.AnchorPoint = Vector2.new(1, 0)
		applyButton.Root.Position = UDim2.new(1, -126, 0, 152)
		local saveButton = W.Button(card, "Save as theme", function()
			UIHelpers.InputPrompt(card, {
				Title = "Save custom palette",
				Placeholder = "Theme name...",
				Submit = "Save",
				OnSubmit = function(name)
					applyCustomPalette(false)
					local ok = Nerx.Themes:SaveCustom(name)
					if ok then
						notify("Themes", "Saved \"" .. name .. "\" from the palette editor", "paint-bucket", T.Green)
						renderThemes()
					else
						notify("Themes", "Could not save that theme", "triangle-exclamation", T.Red)
					end
				end,
			})
		end)
		saveButton.Root.AnchorPoint = Vector2.new(1, 0)
		saveButton.Root.Position = UDim2.new(1, -14, 0, 152)
		saveButton.Root.Size = UDim2.fromOffset(100, 26)
	end

	renderThemes = function()
		for _, child in ipairs(themeContent:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		table.clear(themeCards)

		local query = string.lower(tostring(themeFilter.Box.Text or ""))
		local sortMode = themeSort.Value or "Name"
		local presets = {}
		for _, preset in ipairs(Nerx.Themes.Presets) do
			if query == "" or string.find(string.lower(preset.Name), query, 1, true) then
				presets[#presets + 1] = preset
			end
		end
		if sortMode == "Name" then
			table.sort(presets, function(a, b)
				return string.lower(a.Name) < string.lower(b.Name)
			end)
		end

		local custom = Nerx.Themes:ListCustom(query)
		if sortMode == "Recent" then
			table.sort(custom, function(a, b)
				return (a.savedAt or 0) > (b.savedAt or 0)
			end)
		end

		U.label(themeContent, {
			Text = "PRESETS",
			Font = F.Bold,
			TextSize = 9.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(100, 14),
		})
		U.label(themeContent, {
			Text = "Click a card to apply the full palette",
			TextSize = 8.5,
			TextColor3 = T.Faint,
			TextTransparency = 0.35,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromOffset(260, 14),
			TextXAlignment = Enum.TextXAlignment.Right,
		})

		local presetRows = math.max(1, math.ceil(#presets / 4))
		for index, preset in ipairs(presets) do
			local column = (index - 1) % 4
			local rowIndex = math.floor((index - 1) / 4)
			drawThemeCard(themeContent, 10 + column * THEME_CARD_STEP, 28 + rowIndex * THEME_ROW_STEP, preset.Name, {
				Base = preset.Base,
				Panel = preset.Panel,
				Accent = preset.Accent,
			}, "preset")
		end
		if #presets == 0 then
			U.label(themeContent, {
				Text = "No presets match this filter",
				TextSize = 9,
				TextColor3 = T.Faint,
				TextTransparency = 0.3,
				Position = UDim2.fromOffset(0, 36),
				Size = UDim2.fromOffset(300, 20),
			})
		end
		local presetEnd = 28 + presetRows * THEME_ROW_STEP - 10

		U.label(themeContent, {
			Text = "MY THEMES",
			Font = F.Bold,
			TextSize = 9.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(0, presetEnd + 12),
			Size = UDim2.fromOffset(100, 14),
		})
		U.label(themeContent, {
			Text = "Saved palettes · right-click for rename, export or delete",
			TextSize = 8.5,
			TextColor3 = T.Faint,
			TextTransparency = 0.35,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, presetEnd + 12),
			Size = UDim2.fromOffset(380, 14),
			TextXAlignment = Enum.TextXAlignment.Right,
		})

		local customStart = presetEnd + 32
		for index, record in ipairs(custom) do
			local palette = Nerx._Internal.decodePalette(record.palette)
			local column = (index - 1) % 4
			local rowIndex = math.floor((index - 1) / 4)
			local themeName = tostring(record.name or "Theme")
			local bgRecord = Nerx.Background and Nerx.Background:GetCustom(themeName) or nil
			drawThemeCard(themeContent, 10 + column * THEME_CARD_STEP, customStart + rowIndex * THEME_CUSTOM_STEP, themeName, {
				Base = bgRecord and bgRecord.base or palette.Window or T.Sidebar,
				Panel = palette.SurfaceRaised or T.SurfaceRaised,
				Accent = bgRecord and bgRecord.accent or palette.Accent or T.Accent,
			}, "custom", bgRecord)
		end
		local customRows = math.ceil(#custom / 4)
		if #custom == 0 then
			U.label(themeContent, {
				Text = "No custom themes yet · use + Save as or the palette editor below",
				TextSize = 9,
				TextColor3 = T.Faint,
				TextTransparency = 0.3,
				Position = UDim2.fromOffset(0, customStart + 4),
				Size = UDim2.fromOffset(500, 20),
			})
		end
		local customEnd = customStart + math.max(1, customRows) * THEME_CUSTOM_STEP

		drawPaletteEditor(themeContent, customEnd + 8)
		local height = customEnd + 8 + 196 + 12
		themeContent.Size = UDim2.new(1, 0, 0, height)
		themeScroll.CanvasSize = UDim2.fromOffset(0, height)

		for _, entry in ipairs(themeCards) do
			entry.Render(entry.Name == Nerx.Themes.ActiveName)
		end
	end

	U.connect(themeFilter.Box:GetPropertyChangedSignal("Text"), function()
		renderThemes()
	end)
	table.insert(Nerx.Themes.OnChanged, function()
		customColors.Base = T.Sidebar
		customColors.Panel = T.SurfaceRaised
		customColors.Text = T.Text
		customColors.Accent = T.Accent
		renderThemes()
	end)
	U.onAccent(function()
		renderThemes()
	end)
	renderThemes()

	-- ---------------------------------------------------------------------------------------
	-- 进入主题页的卡片入场动画：从左到右、从上到下逐个弹起再丝滑归位
	-- ---------------------------------------------------------------------------------------
	local themeIntroToken = {}
	local function resetThemeCard(entry)
		local card = entry.Card
		if card and card.Parent then
			card.AnchorPoint = Vector2.new(0, 0)
			card.Position = UDim2.fromOffset(entry.X, entry.Y)
			card.Visible = true
			local press = card:FindFirstChild("NerxPressScale")
			if press then
				press.Scale = 1
			end
		end
		if entry.Outline and entry.Outline.Parent then
			entry.Outline.Visible = false
			entry.Outline.Position = UDim2.fromOffset(entry.X, entry.Y)
		end
		if entry.Halo and entry.Halo.Parent then
			entry.Halo.Visible = false
			entry.Halo.Position = UDim2.fromOffset(entry.X - 2, entry.Y - 2)
		end
		if entry.HaloOuter and entry.HaloOuter.Parent then
			entry.HaloOuter.Visible = false
			entry.HaloOuter.Position = UDim2.fromOffset(entry.X - 4, entry.Y - 4)
		end
	end

	local function playThemeIntro()
		themeIntroToken = {}
		local token = themeIntroToken
		local total = #themeCards
		if total == 0 then
			return
		end
		-- 每次进场都从第一张卡开始，保证弹跳顺序与视频一致。
		themeScroll.CanvasPosition = Vector2.new(0, 0)
		for _, entry in ipairs(themeCards) do
			resetThemeCard(entry)
			entry.Intro = true
		end
		for index, entry in ipairs(themeCards) do
			local card = entry.Card
			if card and card.Parent then
				local centerX = entry.X + entry.Width * 0.5
				local centerY = entry.Y + entry.Height * 0.5
				local press = card:FindFirstChild("NerxPressScale")
				card.AnchorPoint = Vector2.new(0.5, 0.5)
				card.Position = UDim2.fromOffset(centerX, centerY + 24)
				card.Visible = false
				if press then
					press.Scale = 0.84
				end
				local delay = 0.03 + (index - 1) * 0.04
				task.delay(delay, function()
					if themeIntroToken ~= token or not card.Parent then
						return
					end
					card.Visible = true
					local spring = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
					U.tween(card, spring, {
						Position = UDim2.fromOffset(centerX, centerY),
					})
					if press then
						U.tween(press, spring, { Scale = 1 })
					end
					task.delay(0.45, function()
						if themeIntroToken ~= token or not card.Parent then
							return
						end
						card.AnchorPoint = Vector2.new(0, 0)
						card.Position = UDim2.fromOffset(entry.X, entry.Y)
						if press then
							press.Scale = 1
						end
						if entry.Outline and entry.Outline.Parent then
							entry.Outline.Position = UDim2.fromOffset(entry.X, entry.Y)
						end
						if entry.Halo and entry.Halo.Parent then
							entry.Halo.Position = UDim2.fromOffset(entry.X - 2, entry.Y - 2)
						end
						if entry.HaloOuter and entry.HaloOuter.Parent then
							entry.HaloOuter.Position = UDim2.fromOffset(entry.X - 4, entry.Y - 4)
						end
						entry.Intro = false
						entry.Render(entry.Name == Nerx.Themes.ActiveName)
					end)
				end)
			end
		end
	end

	local themePageAnimateIn = themesPage.AnimateIn
	if type(themePageAnimateIn) == "function" then
		themesPage.AnimateIn = function(self, ...)
			themePageAnimateIn(self, ...)
			playThemeIntro()
		end
	end
end



-- ---------------------------------------------------------------------------------------
-- ConfigPage: reusable Configs page (cards, banner, search/sort/import/export)
-- ---------------------------------------------------------------------------------------
Nerx.ConfigPage = {}
local ConfigPage = Nerx.ConfigPage

function ConfigPage.Build(page, config)
	config = config or {}
	local configs = page:SetCustomMode()
	local T = Theme
	local F = Fonts
	local W = Nerx.Widgets
	local UIHelpers = UIKit.UIHelpers
	local notify = UIKit.Notify
	local titleText = UIKit.TitleText
	local surfaceCard = UIKit.SurfaceCard
	local toolbarButton = UIKit.ToolbarButton
	local toolbarPrimary = UIKit.ToolbarPrimary
	local filterField = UIKit.FilterField

	local renderConfigList
	local refreshBanner

	local configsTitle = titleText(configs, "Configs")
	local configCountBadge = U.frame(configs, {
		BackgroundColor3 = T.Field,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(66, 5),
		Size = UDim2.fromOffset(24, 18),
	})
	U.corner(configCountBadge, 6)
	local configCountLabel = U.label(configCountBadge, {
		Text = "0",
		TextSize = 9,
		TextColor3 = T.Muted,
		TextTransparency = 0.2,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	local function setConfigCount(count)
		local text = tostring(count)
		configCountLabel.Text = text
		configCountBadge.Size = UDim2.fromOffset(U.measure(text, 9, F.Regular).X + 16, 18)
	end
	-- The title text is swapped by Locale when the menu language changes,
	-- so the badge follows the measured width instead of a fixed offset.
	local function layoutConfigCount()
		local titleWidth = U.measure(tostring(configsTitle.Text or ""), 15, F.Bold).X + 2
		configCountBadge.Position = UDim2.fromOffset(titleWidth + 8, 5)
	end
	layoutConfigCount()
	U.connect(configsTitle:GetPropertyChangedSignal("Text"), function()
		layoutConfigCount()
	end)
	local configFilter = filterField(configs, 100, 0, 154, "Filter configs...")
	local configSort = W.Segmented(configs, {
		Width = 116,
		Height = 28,
		Items = { "Name", "Recent" },
		Selected = "Name",
		Callback = function()
			if renderConfigList then
				renderConfigList()
			end
		end,
	})
	configSort.Root.Position = UDim2.fromOffset(262, 0)

	local openFolderButton = toolbarButton(configs, "Open folder", 238, 0, 84, 28, function()
		UIHelpers.CopyPath("configs.json")
	end)
	local importConfigButton
	importConfigButton = toolbarButton(configs, "Import", 146, 0, 58, 28, function()
		UIHelpers.ImportPrompt(importConfigButton.Root, {
			Title = "Import config",
			Placeholder = "Paste a Nerx config export here...",
			Submit = "Import",
			OnSubmit = function(text)
				local ok, name = Nerx.Configs:Import(text)
				if ok then
					notify("Configs", "Imported config \"" .. tostring(name) .. "\"", "file-box", T.Green)
					renderConfigList()
				else
					notify("Configs", "Import failed: " .. tostring(name), "triangle-exclamation", T.Red)
				end
			end,
		})
	end)
	local newConfigButton
	newConfigButton = toolbarPrimary(configs, "+ New", 0, 0, 72, 28, function()
		UIHelpers.InputPrompt(newConfigButton.Root, {
			Title = "New config",
			Placeholder = "Config name...",
			Submit = "Create",
			OnSubmit = function(name)
				local ok, reason = Nerx.Configs:SaveAs(name)
				if ok then
					notify("Configs", "Created \"" .. name .. "\" from current settings", "floppy-disk", T.Green)
				elseif reason == "exists" then
					notify("Configs", "A config with that name already exists", "triangle-exclamation", T.Amber)
				else
					notify("Configs", "Could not create config: " .. tostring(reason), "triangle-exclamation", T.Red)
				end
			end,
		})
	end)

	local banner = U.frame(configs, {
		BackgroundColor3 = Color3.fromRGB(34, 29, 19),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(1, 0, 0, 34),
	})
	U.corner(banner, 6)
	local bannerStroke = U.stroke(banner, Color3.fromRGB(96, 76, 38), 0.4, 1)
	local bannerDot = U.frame(banner, {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = T.Amber,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(6, 6),
	})
	U.corner(bannerDot, 3)
	local bannerTitle = U.label(banner, {
		Text = 'No active config',
		TextSize = 10,
		TextColor3 = T.Text,
		TextTransparency = 0.15,
		Position = UDim2.fromOffset(26, 0),
		Size = UDim2.fromOffset(196, 34),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local bannerChanged = U.label(banner, {
		Text = "Save to create one",
		TextSize = 9.5,
		TextColor3 = T.Amber,
		TextTransparency = 0.2,
		Position = UDim2.fromOffset(226, 0),
		Size = UDim2.fromOffset(150, 34),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local revertButton = toolbarButton(banner, "Revert", 88, 5, 68, 24, function()
		if not Nerx.Configs.ActiveName then
			notify("Configs", "Nothing to revert", "arrow-spin-counter-clockwise-15", T.Muted)
			return
		end
		local ok = Nerx.Configs:LoadActive()
		if ok then
			notify("Configs", "Reverted to \"" .. tostring(Nerx.Configs.ActiveName) .. "\"", "arrow-spin-counter-clockwise-15", T.Green)
		else
			notify("Configs", "Could not revert this config", "triangle-exclamation", T.Red)
		end
	end)
	local bannerSave = toolbarPrimary(banner, "Save", 12, 4, 68, 26, function()
		if Nerx.Configs.ActiveName then
			Nerx.Configs:SaveActive()
			notify("Configs", "Saved \"" .. tostring(Nerx.Configs.ActiveName) .. "\"", "circle-check", T.Green)
		else
			Nerx.Configs:Save("Default")
			notify("Configs", "Saved current settings to \"Default\"", "circle-check", T.Green)
		end
		refreshBanner()
	end)

	local configGrid = U.new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 92),
		Size = UDim2.new(1, 0, 1, -92),
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = T.Faint,
		ScrollBarImageTransparency = 0.35,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
	}, configs)
	local configLayout = Instance.new("UIGridLayout")
	configLayout.CellSize = UDim2.fromOffset(382, 150)
	configLayout.CellPadding = UDim2.fromOffset(8, 6)
	configLayout.FillDirectionMaxCells = 2
	configLayout.SortOrder = Enum.SortOrder.LayoutOrder
	configLayout.Parent = configGrid
	local configEmpty = U.label(configs, {
		Text = "No configs found",
		TextSize = 10,
		TextColor3 = T.Faint,
		TextTransparency = 0.25,
		Position = UDim2.fromOffset(0, 150),
		Size = UDim2.new(1, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Center,
		Visible = false,
	})

	local configCards = {}

	local function configCover(parent, colorA, colorB)
		local cover = U.frame(parent, {
			BackgroundColor3 = colorA,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 92),
			ClipsDescendants = true,
		})
		-- UICorner only rounds the card's own background; a full-bleed child
		-- keeps square corners and pokes out past the rounded outline. Round
		-- the cover too and square its bottom edge with a straight filler.
		U.corner(cover, 7)
		local coverFill = U.frame(parent, {
			BackgroundColor3 = colorB,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 85),
			Size = UDim2.new(1, 0, 0, 7),
		})
		local fillGradient = Instance.new("UIGradient")
		fillGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colorA:Lerp(colorB, 85 / 92)),
			ColorSequenceKeypoint.new(1, colorB),
		})
		fillGradient.Rotation = 90
		fillGradient.Parent = coverFill
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

	local function exportConfig(name)
		local json = Nerx.Configs:Export(name)
		if not json then
			notify("Configs", "Nothing to export", "file-box", T.Amber)
			return
		end
		local copied = Nerx.Storage:Copy(json)
		notify("Configs", "Exported \"" .. tostring(name) .. "\"" .. (copied and " to clipboard" or ""), "file-box", copied and T.Green or T.Amber)
	end

	local function drawConfigCard(index, record)
		local name = tostring(record.name or record.Name or "Config")
		local colorA, colorB = UIHelpers.ConfigTint(name)
		local card, stroke = surfaceCard(configGrid, 0, 0, 382, 150, {
			Radius = 7,
			Background = T.Surface,
			Clip = true,
			InsetStroke = true,
		})
		card.LayoutOrder = index
		configCover(card, colorA, colorB)
		U.label(card, {
			Text = name,
			Font = F.Bold,
			TextSize = 11,
			TextColor3 = T.Text,
			TextTransparency = 0.08,
			Position = UDim2.fromOffset(12, 98),
			Size = UDim2.fromOffset(230, 16),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		U.label(card, {
			Text = "Saved " .. UIHelpers.FormatAgo(record.savedAt),
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.35,
			Position = UDim2.fromOffset(12, 116),
			Size = UDim2.fromOffset(220, 12),
		})
		U.label(card, {
			Text = UIHelpers.FormatSize(record.size) .. "  ·  " .. tostring(record.values or 0) .. " values",
			TextSize = 8,
			TextColor3 = T.Faint,
			TextTransparency = 0.25,
			Position = UDim2.fromOffset(12, 130),
			Size = UDim2.fromOffset(220, 12),
		})

		local isActive = Nerx.Configs.ActiveName == name
		local changed = isActive and Nerx.Configs:CountChanged(name) or 0
		local statusText, statusColor, statusBackground
		if isActive then
			if changed > 0 then
				statusText = "UNSAVED"
				statusColor = T.Amber
				statusBackground = Color3.fromRGB(46, 36, 18)
			else
				statusText = "ACTIVE"
				statusColor = T.Green
				statusBackground = T.Field
			end
		else
			statusText = "SAVED"
			statusColor = T.Muted
			statusBackground = T.Field
		end
		local statusWidth = U.measure(statusText, 7.5, F.Bold).X + 14
		local status = U.frame(card, {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = statusBackground,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -10, 0, 10),
			Size = UDim2.fromOffset(statusWidth, 18),
		})
		U.corner(status, 4)
		U.label(status, {
			Text = statusText,
			Font = F.Bold,
			TextSize = 7.5,
			TextColor3 = statusColor,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
		})

		local entry = { Name = name, Card = card, Stroke = stroke }
		configCards[#configCards + 1] = entry
		function entry.Render(active)
			card.BackgroundColor3 = active and T.SurfaceHover or T.Surface
			stroke.Color = active and T.Accent or T.Stroke
			stroke.Transparency = active and 0.25 or 0.6
		end
		entry.Render(isActive)

		local input = U.inputButton(card, function()
			local ok = Nerx.Configs:Load(name)
			if ok then
				notify("Configs", "Loaded \"" .. name .. "\"", "file-box", T.Green)
			else
				notify("Configs", "Could not load \"" .. name .. "\"", "triangle-exclamation", T.Red)
			end
		end)
		U.connect(input.InputBegan, function(inputObject)
			if inputObject.UserInputType ~= Enum.UserInputType.MouseButton2 then
				return
			end
			UIHelpers.ContextMenu(card, {
				{ Text = "Load config", Callback = function()
					Nerx.Configs:Load(name)
				end },
				{ Text = "Save over this config", Callback = function()
					Nerx.Configs:Save(name)
					notify("Configs", "Saved \"" .. name .. "\"", "circle-check", T.Green)
				end },
				{ Text = "Rename", Callback = function()
					UIHelpers.InputPrompt(card, {
						Title = "Rename config",
						Initial = name,
						Submit = "Rename",
						OnSubmit = function(newName)
							local ok = Nerx.Configs:Rename(name, newName)
							notify("Configs", ok and ("Renamed to \"" .. newName .. "\"") or "Rename failed", "file-box", ok and T.Green or T.Red)
						end,
					})
				end },
				{ Text = "Duplicate", Callback = function()
					UIHelpers.InputPrompt(card, {
						Title = "Duplicate config",
						Initial = name .. " copy",
						Submit = "Duplicate",
						OnSubmit = function(newName)
							local ok = Nerx.Configs:Duplicate(name, newName)
							notify("Configs", ok and ("Duplicated as \"" .. newName .. "\"") or "Duplicate failed", "files", ok and T.Green or T.Red)
						end,
					})
				end },
				{ Text = "Export to clipboard", Callback = function()
					exportConfig(name)
				end },
				{ Text = "Delete", Color = T.Red, Callback = function()
					local ok = Nerx.Configs:Delete(name)
					notify("Configs", ok and ("Deleted \"" .. name .. "\"") or "Delete failed", "trash-can", ok and T.Muted or T.Red)
				end },
			})
		end)
	end

	function renderConfigList()
		for _, entry in ipairs(configCards) do
			if entry.Card and entry.Card.Parent then
				entry.Card:Destroy()
			end
		end
		table.clear(configCards)

		local filterText = tostring(configFilter.Box.Text or "")
		local sortMode = configSort.Value or "Name"
		local list = Nerx.Configs:List(filterText, sortMode)
		for index, record in ipairs(list) do
			drawConfigCard(index, record)
		end
		configEmpty.Visible = #list == 0
	setConfigCount(#Nerx.Configs:List())
	end

	refreshBanner = function()
		local activeName = Nerx.Configs.ActiveName
		if not activeName then
			bannerTitle.Text = "No active config"
			bannerChanged.Text = "Save to create one"
			bannerDot.BackgroundColor3 = T.Amber
			bannerChanged.TextColor3 = T.Amber
			return
		end
		local changed = Nerx.Configs:CountChanged(activeName)
		bannerTitle.Text = 'Config: "' .. tostring(activeName) .. '"'
		if changed > 0 then
			bannerChanged.Text = tostring(changed) .. (changed == 1 and " change pending" or " changes pending")
			bannerChanged.TextColor3 = T.Amber
			bannerDot.BackgroundColor3 = T.Amber
		else
			bannerChanged.Text = "All changes saved"
			bannerChanged.TextColor3 = T.Green
			bannerDot.BackgroundColor3 = T.Green
		end
	end

	U.connect(configFilter.Box:GetPropertyChangedSignal("Text"), function()
		renderConfigList()
	end)
	table.insert(Nerx.Configs.OnChanged, function()
		renderConfigList()
		refreshBanner()
	end)
	U.onAccent(function()
		renderConfigList()
	end)

	-- Configs page intro: same staggered back-out pop as the theme cards, but the
	-- grid owns the cell positions, so only scale + a short lift are animated.
	local configIntroToken = {}
	local function playConfigIntro()
		configIntroToken = {}
		local token = configIntroToken
		if #configCards == 0 then
			return
		end
		configGrid.CanvasPosition = Vector2.new(0, 0)
		for _, entry in ipairs(configCards) do
			local card = entry.Card
			if card and card.Parent then
				local introScale = card:FindFirstChild("NerxIntroScale")
				if not introScale then
					introScale = Instance.new("UIScale")
					introScale.Name = "NerxIntroScale"
					introScale.Parent = card
				end
				introScale.Scale = 0
			end
		end
		task.defer(function()
			RunService.Heartbeat:Wait()
			if configIntroToken ~= token then
				return
			end
			local cellW, cellH = 382, 150
			local padX, padY = 8, 6
			for index, entry in ipairs(configCards) do
				local card = entry.Card
				if card and card.Parent then
					local column = (index - 1) % 2
					local row = math.floor((index - 1) / 2)
					local baseX = column * (cellW + padX)
					local baseY = row * (cellH + padY)
					local centerX = baseX + cellW * 0.5
					local centerY = baseY + cellH * 0.5
					local introScale = card:FindFirstChild("NerxIntroScale")
					if not introScale then
						introScale = Instance.new("UIScale")
						introScale.Name = "NerxIntroScale"
						introScale.Parent = card
					end
					card.AnchorPoint = Vector2.new(0.5, 0.5)
					card.Position = UDim2.fromOffset(centerX, centerY + 22)
					local delay = 0.03 + (index - 1) * 0.04
					task.delay(delay, function()
						if configIntroToken ~= token or not card.Parent then
							return
						end
						introScale.Scale = 0.86
						local spring = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
						U.tween(card, spring, { Position = UDim2.fromOffset(centerX, centerY) })
						U.tween(introScale, spring, { Scale = 1 })
						task.delay(0.45, function()
							if configIntroToken ~= token or not card.Parent then
								return
							end
							card.AnchorPoint = Vector2.new(0, 0)
							card.Position = UDim2.fromOffset(baseX, baseY)
							introScale.Scale = 1
						end)
					end)
				end
			end
		end)
	end

	local configsAnimateIn = page.AnimateIn
	if type(configsAnimateIn) == "function" then
		page.AnimateIn = function(self, ...)
			configsAnimateIn(self, ...)
			playConfigIntro()
		end
	end

	renderConfigList()
	refreshBanner()
	local lastBannerRefresh = 0
	U.connect(RunService.Heartbeat, function()
		local now = os.clock()
		if now - lastBannerRefresh < 1 then
			return
		end
		lastBannerRefresh = now
		pcall(refreshBanner)
	end)
end

-- ---------------------------------------------------------------------------------------
-- Music: local library store, Sound playback, lyrics and the full Music tab
-- ---------------------------------------------------------------------------------------
Nerx.Music = {}
local Music = Nerx.Music
Music.ChartList = {
	{ netId = "19723756", name = "飙升榜", tag = "上升最快" },
	{ netId = "3779629", name = "新歌榜", tag = "每日新歌" },
	{ netId = "3778678", name = "热歌榜", tag = "全站热播" },
	{ netId = "2884035", name = "原创榜", tag = "原创音乐" },
	{ netId = "71385702", name = "ACG 榜", tag = "二次元" },
	{ netId = "991319590", name = "说唱榜", tag = "中文说唱" },
}
Music.Qualities = {
	{ key = "standard", name = "标准", br = 128000 },
	{ key = "hq", name = "HQ", br = 192000 },
	{ key = "lossless", name = "无损", br = 999000 },
	{ key = "hires", name = "Hi-Res", br = 1900000 },
}

local MUSIC_STORE_FILE = "music.json"
local MUSIC_ART_PALETTE = {
	{ "#ff5d8f", "#4c1029" },
	{ "#5ab0ff", "#10263d" },
	{ "#8d7bff", "#241a52" },
	{ "#41c9b0", "#0d3a35" },
	{ "#ffb45e", "#4a260d" },
	{ "#ff7a5e", "#4a1a12" },
	{ "#c46bff", "#34114f" },
	{ "#5ed0ff", "#0d3247" },
	{ "#6ee08c", "#0f3a22" },
	{ "#ff7d9c", "#451326" },
	{ "#f2c15b", "#473312" },
	{ "#69cdff", "#0d3247" },
}

local function musicTrim(text)
	return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function musicNormalizeSoundId(value)
	local text = tostring(value or ""):gsub("%s", "")
	text = text:gsub("^rbxassetid://", "")
	local extracted = string.match(text, "id=(%d+)")
	if extracted then
		text = extracted
	end
	if string.match(text, "^%d+$") then
		return text
	end
	return nil
end

local function musicParseHex(value, fallback)
	local hex = tostring(value or ""):gsub("#", "")
	if #hex == 6 then
		local r = tonumber(string.sub(hex, 1, 2), 16)
		local g = tonumber(string.sub(hex, 3, 4), 16)
		local b = tonumber(string.sub(hex, 5, 6), 16)
		if r and g and b then
			return Color3.fromRGB(r, g, b)
		end
	end
	return fallback or Theme.SurfaceRaised
end

local function musicLuminance(color)
	return 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
end

local function musicArtColors(seed)
	seed = tostring(seed or "")
	local hash = 0
	for index = 1, #seed do
		hash = (hash * 31 + string.byte(seed, index)) % 100000
	end
	local entry = MUSIC_ART_PALETTE[(hash % #MUSIC_ART_PALETTE) + 1]
	return entry[1], entry[2]
end

local function musicFormatTime(seconds)
	seconds = math.max(0, math.floor(tonumber(seconds) or 0))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function musicParseLrc(raw)
	local entries = {}
	for line in tostring(raw or ""):gmatch("[^\r\n]+") do
		local body = string.match(line, "^.*%](.*)$") or ""
		body = musicTrim(body)
		local mainText, translation = string.match(body, "^(.-)|(.*)$")
		mainText = musicTrim(mainText)
		translation = musicTrim(translation)
		if mainText ~= "" or translation ~= "" then
			for minutes, seconds, fraction in string.gmatch(line, "%[(%d+):(%d+)%.?(%d*)%]") do
				local time = (tonumber(minutes) or 0) * 60 + (tonumber(seconds) or 0)
				if fraction and fraction ~= "" then
					time = time + (tonumber("0." .. fraction) or 0)
				end
				entries[#entries + 1] = { Time = time, Text = mainText, Trans = translation }
			end
		end
	end
	table.sort(entries, function(a, b)
		return a.Time < b.Time
	end)
	return entries
end
function Music:_Utf8Length(text)
	local count = 0
	for _ in utf8.codes(tostring(text or "")) do
		count = count + 1
	end
	return count
end

function Music:_SplitWords(text, startTime, endTime)
	text = tostring(text or "")
	if text == "" then
		return {}
	end
	local tokens = {}
	if string.find(text, " ", 1, true) then
		for piece in string.gmatch(text, "%S+%s*") do
			tokens[#tokens + 1] = piece
		end
	else
		local chars = {}
		for _, code in utf8.codes(text) do
			chars[#chars + 1] = utf8.char(code)
		end
		local index = 1
		while index <= #chars do
			tokens[#tokens + 1] = chars[index] .. (chars[index + 1] or "")
			index = index + 2
		end
	end
	local total = 0
	for _, token in ipairs(tokens) do
		total = total + math.max(1, self:_Utf8Length(token))
	end
	local words = {}
	local cursor = 0
	local span = math.max(0.4, (endTime or startTime + 3) - startTime)
	for _, token in ipairs(tokens) do
		local weight = math.max(1, self:_Utf8Length(token)) / math.max(1, total)
		local wordStart = startTime + span * cursor
		cursor = cursor + weight
		words[#words + 1] = {
			Text = token,
			Start = wordStart,
			End = startTime + span * cursor,
		}
	end
	return words
end

function Music:_ParseYrc(raw, translatedRaw)
	local translations = musicParseLrc(translatedRaw)
	local entries = {}
	for line in tostring(raw or ""):gmatch("[^\r\n]+") do
		local startMs, durationMs, body = string.match(line, "^%[(%d+),(%d+),%d+%](.*)$")
		if startMs then
			local words = {}
			local textParts = {}
			for wordStart, wordDuration, wordText in string.gmatch(body, "%((%d+),(%d+),%d+%)([^%(]+)") do
				local weight = self:_Utf8Length(wordText)
				if weight > 0 then
					local s = (tonumber(wordStart) or 0) / 1000
					local d = (tonumber(wordDuration) or 0) / 1000
					words[#words + 1] = { Text = wordText, Start = s, End = s + d }
					textParts[#textParts + 1] = wordText
				end
			end
			if #words > 0 then
				local time = (tonumber(startMs) or 0) / 1000
				local duration = (tonumber(durationMs) or 0) / 1000
				local translation = nil
				for _, item in ipairs(translations) do
					if math.abs(item.Time - time) <= 0.6 then
						local text = item.Trans ~= "" and item.Trans or item.Text
						if text ~= "" then
							translation = text
							break
						end
					end
				end
				entries[#entries + 1] = {
					Time = time,
					EndTime = time + math.max(0.5, duration),
					Text = table.concat(textParts),
					Trans = translation or "",
					Words = words,
				}
			end
		end
	end
	table.sort(entries, function(a, b)
		return a.Time < b.Time
	end)
	return entries
end

function Music:ParseLyrics(track)
	if type(track) ~= "table" then
		return {}
	end
	if type(track.yrc) == "string" and track.yrc ~= "" then
		local entries = self:_ParseYrc(track.yrc, track.lyrics)
		if #entries > 0 then
			return entries
		end
	end
	local entries = musicParseLrc(track.lyrics)
	for index, entry in ipairs(entries) do
		local nextTime = entries[index + 1] and entries[index + 1].Time or (entry.Time + 4)
		local span = math.max(1.2, nextTime - entry.Time)
		entry.EndTime = entry.Time + span
		entry.Words = self:_SplitWords(entry.Text, entry.Time, entry.EndTime)
	end
	return entries
end

function Music:RichEscape(text)
	text = tostring(text or "")
	text = text:gsub("&", "&amp;")
	text = text:gsub("<", "&lt;")
	text = text:gsub(">", "&gt;")
	return text
end

-- ---------------------------------------------------------------------------------------
-- NetEase transport: direct music.163.com APIs + executor download/asset bridge
-- ---------------------------------------------------------------------------------------
local function musicEnv(name)
	local ok, value = pcall(function()
		if getgenv then
			return getgenv()[name]
		end
	end)
	if ok and value ~= nil then
		return value
	end
	ok, value = pcall(function()
		return _G[name]
	end)
	if ok then
		return value
	end
	return nil
end

local rawRequest = (type(request) == "function" and request)
	or (type(http_request) == "function" and http_request)
	or (type(httprequest) == "function" and httprequest)
	or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
	or (type(fluxus) == "table" and type(fluxus.request) == "function" and fluxus.request)
	or (type(http) == "table" and type(http.request) == "function" and http.request)
	or musicEnv("request")
	or musicEnv("http_request")
	or musicEnv("httprequest")
if type(rawRequest) ~= "function" then
	rawRequest = nil
end
local fnWrite = (type(writefile) == "function" and writefile) or musicEnv("writefile")
local fnRead = (type(readfile) == "function" and readfile) or musicEnv("readfile")
local fnIsFile = (type(isfile) == "function" and isfile) or musicEnv("isfile")
local fnMakeFolder = (type(makefolder) == "function" and makefolder) or musicEnv("makefolder")
local fnDelFile = (type(delfile) == "function" and delfile) or musicEnv("delfile")
local fnListFiles = (type(listfiles) == "function" and listfiles) or musicEnv("listfiles")
local fnAsset = (type(getcustomasset) == "function" and getcustomasset)
	or (type(getsynasset) == "function" and getsynasset)
	or musicEnv("getcustomasset")
	or musicEnv("getsynasset")
local fnWorkspace = (type(getworkspace) == "function" and getworkspace) or musicEnv("getworkspace")
local MUSIC_CACHE_DIR = "NerxMusicCache"

local function musicUrlEncode(value)
	return tostring(value or ""):gsub("([^%w%-_%.~])", function(char)
		return string.format("%%%02X", string.byte(char))
	end)
end

function Music:_Hash(text)
	local hash = 0
	text = tostring(text or "")
	for index = 1, #text do
		hash = (hash * 131 + string.byte(text, index)) % 2147483647
	end
	return hash
end

local function musicNcmHeaders(cookie)
	local headers = {
		["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
		["Referer"] = "https://music.163.com/",
		["Accept"] = "*/*",
	}
	local value = "appver=2.0.2; os=pc"
	if type(cookie) == "string" and cookie ~= "" then
		local c = cookie
		if not string.find(c, "=", 1, true) then
			c = "MUSIC_U=" .. c
		end
		value = c .. "; " .. value
	end
	headers["Cookie"] = value
	return headers
end

function Music:_CookieFromHeaders(headers)
	if type(headers) ~= "table" then
		return nil
	end
	for key, value in pairs(headers) do
		if type(key) == "string" and string.lower(key) == "set-cookie" then
			local text = type(value) == "table" and table.concat(value, "\n") or tostring(value)
			local token = string.match(text, "MUSIC_U=([^;%s]+)")
			if token and token ~= "" then
				return token
			end
		end
	end
	return nil
end

local function musicHttp(config, timeout)	config = config or {}
	timeout = timeout or 15
	if rawRequest then
		local done, ok, response = false, false, nil
		task.spawn(function()
			ok, response = pcall(rawRequest, config)
			done = true
		end)
		local started = os.clock()
		while not done and os.clock() - started < timeout do
			task.wait(0.05)
		end
		if not done then
			return { ok = false, error = "网易云请求超时" }
		end
		if not ok or type(response) ~= "table" then
			return { ok = false, error = "网易云请求失败" }
		end
		local body = response.Body or response.body
		local status = tonumber(response.StatusCode or response.Status or response.status)
		local headers = response.Headers or response.headers
		if type(body) ~= "string" or body == "" then
			return { ok = false, status = status, headers = headers, error = "网易云返回为空" }
		end
		return {
			ok = (status == nil or (status >= 200 and status < 300)),
			body = body,
			status = status,
			headers = headers,
		}
	end
	if string.upper(tostring(config.Method or "GET")) == "GET" then
		local ok, body = pcall(function()
			return game:HttpGet(config.Url, true)
		end)
		if ok and type(body) == "string" and body ~= "" then
			return { ok = true, body = body, status = 200, headers = {} }
		end
		return { ok = false, error = "执行器缺少 request，HttpGet 也无法访问网易云" }
	end
	return { ok = false, error = "执行器缺少 request，无法访问网易云" }
end

local function musicHttpFollow(config, timeout)
	local current = config
	for _ = 1, 4 do
		local response = musicHttp(current, timeout)
		if not response then
			return nil
		end
		local status = response.status
		if status and status >= 300 and status < 400 and type(response.headers) == "table" then
			local location
			for key, value in pairs(response.headers) do
				if type(key) == "string" and string.lower(key) == "location" then
					location = value
					break
				end
			end
			if type(location) == "string" and location ~= "" then
				if string.sub(location, 1, 1) == "/" then
					location = "https://music.163.com" .. location
				end
				local headers = {}
				for key, value in pairs(current.Headers or {}) do
					if string.lower(tostring(key)) ~= "cookie" then
						headers[key] = value
					end
				end
				current = { Url = location, Method = "GET", Headers = headers }
			else
				return response
			end
		else
			return response
		end
	end
	return nil
end

local function musicBuildApiUrl(path)
	local base, query = tostring(path or ""):match("^([^?]*)%??(.*)$")
	local function param(name)
		return (("&" .. tostring(query or "")):match("&" .. name .. "=([^&]*)"))
	end
	local id = param("id")
	if id and not string.match(id, "^%d+$") then
		return nil
	end
	if base == "/search" then
		local searchType = param("type") or "1"
		return "https://music.163.com/api/search/get/web?csrf_token=&type=" .. searchType
			.. "&offset=" .. (param("offset") or "0") .. "&total=true&s=" .. (param("keywords") or "")
			.. "&limit=" .. (param("limit") or "30")
	elseif base == "/cloudsearch" then
		-- The legacy /search payload has an empty album.picUrl, which is why
		-- search tracks showed generated gradient covers. cloudsearch/pc
		-- returns al.picUrl for every song.
		return "https://music.163.com/api/cloudsearch/pc?s=" .. (param("keywords") or "")
			.. "&type=" .. (param("type") or "1")
			.. "&offset=" .. (param("offset") or "0")
			.. "&limit=" .. (param("limit") or "30")
	elseif base == "/personalized" then
		return "https://music.163.com/api/personalized/playlist?limit=" .. (param("limit") or "12")
	elseif base == "/top/playlist" then
		return "https://music.163.com/api/playlist/list?cat=" .. (param("cat") or musicUrlEncode("全部"))
			.. "&order=" .. (param("order") or "hot")
			.. "&limit=" .. (param("limit") or "12")
			.. "&offset=" .. (param("offset") or "0")
	elseif base == "/playlist/detail" and id then
		return "https://music.163.com/api/v6/playlist/detail?id=" .. id .. "&s=8"
	elseif base == "/playlist/track/all" and id then
		return "https://music.163.com/api/playlist/track/all?id=" .. id
			.. "&limit=" .. (param("limit") or "200") .. "&offset=" .. (param("offset") or "0")
	elseif base == "/song/detail" then
		local ids = param("ids")
		if not ids then
			return nil
		end
		ids = ids:gsub("%%(%x%x)", function(hex)
			return string.char(tonumber(hex, 16))
		end)
		return "https://music.163.com/api/song/detail/?ids=" .. ids
	elseif base == "/lyric" and id then
		return "https://music.163.com/api/song/lyric?lv=-1&kv=-1&tv=-1&yv=1&ytv=1&id=" .. id
	elseif base == "/song/url" and id then
		return "https://music.163.com/api/song/enhance/player/url?ids=[" .. id .. "]&br="
			.. (param("br") or "999000")
	elseif base == "/artist/detail" and id then
		return "https://music.163.com/api/artist/detail?id=" .. id
	elseif base == "/artist/top" and id then
		return "https://music.163.com/api/artist/top/song?id=" .. id
	elseif base == "/artist/album" and id then
		return "https://music.163.com/api/artist/album?id=" .. id
			.. "&limit=" .. (param("limit") or "50") .. "&offset=" .. (param("offset") or "0")
	elseif base == "/album" and id then
		return "https://music.163.com/api/album/" .. id
	elseif base == "/cloud" then
		return "https://music.163.com/api/v1/cloud/get?limit=" .. (param("limit") or "200")
			.. "&offset=" .. (param("offset") or "0")
	elseif base == "/account" then
		return "https://music.163.com/api/nuser/account/get"
	elseif base == "/user/playlist" then
		local uid = param("uid")
		if not uid or not string.match(uid, "^%d+$") then
			return nil
		end
		return "https://music.163.com/api/user/playlist?uid=" .. uid
			.. "&limit=" .. (param("limit") or "50")
			.. "&offset=" .. (param("offset") or "0")
	end
	return nil
end

local function musicMergeLrc(raw, translated)
	local function parse(source)
		local lines = {}
		for line in tostring(source or ""):gmatch("[^\r\n]+") do
			local stamps = {}
			local rest = line
			while true do
				local minutes, seconds, tail = string.match(rest, "^%s*%[(%d+):(%d+[%.%d]*)%](.*)$")
				if not minutes then
					break
				end
				stamps[#stamps + 1] = (tonumber(minutes) or 0) * 60 + (tonumber(seconds) or 0)
				rest = tail
			end
			if #stamps > 0 then
				local text = musicTrim(rest)
				for _, time in ipairs(stamps) do
					lines[#lines + 1] = { Time = time, Text = text }
				end
			end
		end
		table.sort(lines, function(a, b)
			return a.Time < b.Time
		end)
		return lines
	end
	local main = parse(raw)
	if #main == 0 then
		return ""
	end
	local trans = parse(translated)
	local output = {}
	for _, entry in ipairs(main) do
		local best, distance = nil, nil
		for _, candidate in ipairs(trans) do
			local delta = math.abs(candidate.Time - entry.Time)
			if not distance or delta < distance then
				best, distance = candidate, delta
			end
		end
		local text = entry.Text
		if best and distance and distance <= 0.35 and best.Text ~= "" then
			text = text .. "|" .. best.Text
		end
		output[#output + 1] = string.format("[%02d:%05.2f]%s", math.floor(entry.Time / 60), entry.Time % 60, text)
	end
	return table.concat(output, "\n")
end

local function musicNormalizeData(decoded)
	local data = type(decoded) == "table" and decoded or {}
	data.version = 2

	local rawTracks = type(data.tracks) == "table" and data.tracks or {}
	local tracks = {}
	for key, value in pairs(rawTracks) do
		if type(value) == "table" then
			local id = tostring(value.id or key)
			local source = value.source == "netease" and "netease" or "local"
			local soundId = musicNormalizeSoundId(value.soundId) or tostring(value.soundId or ""):gsub("%s", "")
			local netId = nil
			if source == "netease" then
				netId = tostring(value.netId or id:gsub("^ne_", ""))
				if not netId:match("^%d+$") then
					source = "local"
					netId = nil
				end
			end
			local name = musicTrim(value.name)
			if name == "" then
				name = source == "netease" and "未知歌曲" or ("Sound " .. soundId)
			end
			local artist = musicTrim(value.artist)
			if artist == "" then
				artist = "未知歌手"
			end
			local album = musicTrim(value.album)
			if album == "" then
				album = source == "netease" and "网易云音乐" or "本地曲库"
			end
			local c1, c2 = musicArtColors(name .. artist .. tostring(netId or soundId))
			value.id = id
			value.source = source
			value.netId = netId
			value.soundId = soundId
			value.name = name
			value.artist = artist
			value.artistId = type(value.artistId) == "string" and value.artistId or nil
			value.album = album
			value.duration = tonumber(value.duration) or 0
			value.fee = tonumber(value.fee) or 0
			value.liked = value.liked == true
			value.lyrics = type(value.lyrics) == "string" and value.lyrics or ""
			value.yrc = type(value.yrc) == "string" and value.yrc or ""
			value.lyricsLoaded = value.lyricsLoaded == true
			value.coverUrl = type(value.coverUrl) == "string" and value.coverUrl or ""
			value.cachedPath = type(value.cachedPath) == "string" and value.cachedPath or nil
			value.cachedQuality = type(value.cachedQuality) == "string" and value.cachedQuality or nil
			value.color1 = type(value.color1) == "string" and value.color1 or c1
			value.color2 = type(value.color2) == "string" and value.color2 or c2
			value.addedAt = tonumber(value.addedAt) or 0
			tracks[id] = value
		end
	end
	data.tracks = tracks

	local order = {}
	local seenOrder = {}
	for _, id in ipairs(type(data.order) == "table" and data.order or {}) do
		id = tostring(id)
		if tracks[id] and not seenOrder[id] then
			seenOrder[id] = true
			order[#order + 1] = id
		end
	end
	for id in pairs(tracks) do
		if not seenOrder[id] then
			seenOrder[id] = true
			order[#order + 1] = id
		end
	end
	data.order = order

	local playlists = {}
	for index, value in ipairs(type(data.playlists) == "table" and data.playlists or {}) do
		if type(value) == "table" then
			local ids = {}
			local used = {}
			for _, trackId in ipairs(type(value.trackIds) == "table" and value.trackIds or {}) do
				trackId = tostring(trackId)
				if tracks[trackId] and not used[trackId] then
					used[trackId] = true
					ids[#ids + 1] = trackId
				end
			end
			local name = musicTrim(value.name)
			if name == "" then
				name = "歌单 " .. tostring(index)
			end
			local netId = tostring(value.netId or ""):match("^%d+$") and tostring(value.netId) or nil
			local kind = "custom"
			if value.kind == "netease" or netId then
				kind = "netease"
			elseif value.kind == "saved" then
				kind = "saved"
			end
			if kind == "netease" and netId == nil then
				local extracted = tostring(value.id or ""):match("^ne_pl_(%d+)$")
				netId = extracted
			end
			local c1, c2 = musicArtColors(name .. tostring(netId or ""))
			playlists[#playlists + 1] = {
				id = tostring(value.id or ("pl_" .. tostring(index))),
				name = name,
				kind = kind,
				netId = netId,
				creator = tostring(value.creator or ""),
				count = tonumber(value.count) or #ids,
				trackIds = ids,
				loading = false,
				loaded = value.loaded == true and #ids > 0,
				color1 = type(value.color1) == "string" and value.color1 or c1,
				color2 = type(value.color2) == "string" and value.color2 or c2,
				coverUrl = type(value.coverUrl) == "string" and value.coverUrl or "",
				created = tonumber(value.created) or 0,
			}
		end
	end
	for index = #playlists, 1, -1 do
		local playlist = playlists[index]
		if playlist.id == "pl_default" and #playlist.trackIds == 0 then
			table.remove(playlists, index)
		end
	end
	data.playlists = playlists

	local settings = type(data.settings) == "table" and data.settings or {}
	local hotkeys = type(settings.hotkeys) == "table" and settings.hotkeys or {}
	local function hotkey(name, fallback)
		local value = hotkeys[name]
		if type(value) == "string" and value ~= "" then
			return value
		end
		return fallback
	end
	local quality = tostring(settings.quality or "lossless")
	if quality ~= "standard" and quality ~= "hq" and quality ~= "lossless" and quality ~= "hires" then
		quality = "lossless"
	end
	local projection = tostring(settings.worldProjection or "follow")
	if projection ~= "follow" and projection ~= "wall" and projection ~= "orbit" then
		projection = "follow"
	end
	data.settings = {
		volume = math.clamp(tonumber(settings.volume) or 0.72, 0, 1),
		mode = (settings.mode == "order" or settings.mode == "one") and settings.mode or "all",
		shuffle = settings.shuffle == true,
		showTranslation = settings.showTranslation ~= false,
		cookie = type(settings.cookie) == "string" and settings.cookie or "",
		nickname = type(settings.nickname) == "string" and settings.nickname or "",
		uid = tostring(settings.uid or ""),
		quality = quality,
		wordHighlight = settings.wordHighlight ~= false,
		glow = settings.glow ~= false,
		lyricsFont = settings.lyricsFont == "pixel" and "pixel" or "smooth",
		fontSize = math.clamp(tonumber(settings.fontSize) or 31, 18, 48),
		lineGap = math.clamp(tonumber(settings.lineGap) or 22, 0, 64),
		offset = math.clamp(tonumber(settings.offset) or 0, -5, 5),
		immersive3d = settings.immersive3d ~= false,
		immersiveDim = math.clamp(tonumber(settings.immersiveDim) or 46, 0, 100),
		worldLyrics = settings.worldLyrics ~= false,
		worldProjection = projection,
		worldDistance = math.clamp(tonumber(settings.worldDistance) or 8, 3, 16),
		worldHeight = math.clamp(tonumber(settings.worldHeight) or 0, -2, 4),
		worldSize = math.clamp(tonumber(settings.worldSize) or 1, 0.6, 1.8),
		worldGlow = math.clamp(tonumber(settings.worldGlow) or 70, 0, 100),
		worldDim = settings.worldDim ~= false,
		worldWiggle = settings.worldWiggle ~= false,
		songCard = settings.songCard ~= false,
		songCardScale = math.clamp(tonumber(settings.songCardScale) or 1, 0.7, 1.4),
		songCardPaused = settings.songCardPaused ~= false,
		island = settings.island ~= false,
		islandNotify = settings.islandNotify ~= false,
		islandScale = math.clamp(tonumber(settings.islandScale) or 1, 0.8, 1.3),
		islandTime = math.clamp(tonumber(settings.islandTime) or 3.5, 1, 8),
		eqEnabled = settings.eqEnabled == true,
		eqLow = math.clamp(tonumber(settings.eqLow) or 0, -12, 12),
		eqMid = math.clamp(tonumber(settings.eqMid) or 0, -12, 12),
		eqHigh = math.clamp(tonumber(settings.eqHigh) or 0, -12, 12),
		speed = math.clamp(tonumber(settings.speed) or 1, 0.5, 2),
		pitch = math.clamp(tonumber(settings.pitch) or 0, -12, 12),
		motion = settings.motion ~= false,
		hotkeys = {
			open = hotkey("open", "M"),
			play = hotkey("play", ""),
			prev = hotkey("prev", ""),
			next = hotkey("next", ""),
			volUp = hotkey("volUp", ""),
			volDown = hotkey("volDown", ""),
			lyrics = hotkey("lyrics", ""),
		},
	}

	local recommended = {}
	for _, value in ipairs(type(data.recommended) == "table" and data.recommended or {}) do
		if type(value) == "table" then
			local netId = tostring(value.netId or value.id or "")
			if netId:match("^%d+$") then
				local name = musicTrim(value.name)
				if name ~= "" then
					local c1, c2 = musicArtColors(name .. netId)
					recommended[#recommended + 1] = {
						netId = netId,
						name = name,
						creator = tostring(value.creator or "网易云音乐"),
						count = tonumber(value.count) or tonumber(value.trackCount) or 0,
						playCount = tonumber(value.playCount) or 0,
						color1 = type(value.color1) == "string" and value.color1 or c1,
						color2 = type(value.color2) == "string" and value.color2 or c2,
						coverUrl = type(value.coverUrl) == "string" and value.coverUrl or "",
					}
				end
			end
		end
	end
	data.recommended = recommended

	local history = {}
	for _, id in ipairs(type(data.history) == "table" and data.history or {}) do
		id = tostring(id)
		if tracks[id] then
			history[#history + 1] = id
			if #history >= 50 then
				break
			end
		end
	end
	data.history = history
	return data
end

function Music:Init()
	if self.Data then
		return self
	end
	local data = musicNormalizeData(Nerx.Storage:ReadJSON(MUSIC_STORE_FILE))
	self.Data = data
	self.Tracks = data.tracks
	self.Playlists = data.playlists
	self.Settings = data.settings
	self.Order = data.order
	self.Recommended = data.recommended or {}
	self.MyPlaylists = {}
	self.Artists = {}
	self.CloudIds = {}
	self.Charts = {}
	self.CloudLoading = false
	self.CloudError = nil
	self.ChartsLoading = false
	self.Listeners = {}
	self.Queue = {}
	self.QueueIndex = 0
	self.CurrentId = nil
	self.Playing = false
	self.Loading = false
	self.DesiredPlaying = false
	self.NextId = nil
	self.LoadToken = 0
	self.Sound = nil
	self.SearchIds = {}
	self.SearchQuery = ""
	self.Searching = false
	self.SearchError = nil
	self.RecommendedLoading = false
	self.RecommendedError = nil
	self._ApiCache = {}
	self._NextRequestAt = 0
	self._CooldownUntil = 0
	self.LastApiError = nil
	self.CacheDir = MUSIC_CACHE_DIR

	local ok = pcall(function()
		local sound = Instance.new("Sound")
		sound.Name = "NerxMusicPlayer"
		sound.Volume = self.Settings.volume
		sound.Looped = false
		sound.Parent = game:GetService("SoundService")
		self.Sound = sound
	end)
	if not ok then
		self.Sound = nil
	end
	if self.Sound then
		U.connect(self.Sound.Ended, function()
			self:_HandleEnded()
		end)
	end
	return self
end

function Music:Save()
	if not self.Data then
		return
	end
	-- Search / playlist browsing creates many short-lived online tracks. Persist
	-- only the ones that are still referenced, so music.json does not grow forever.
	local keep = {}
	for id, track in pairs(self.Tracks) do
		if track.source ~= "netease" or track.liked then
			keep[id] = true
		end
	end
	for _, playlist in ipairs(self.Playlists or {}) do
		for _, id in ipairs(playlist.trackIds or {}) do
			keep[id] = true
		end
	end
	for _, id in ipairs(self.Data.history or {}) do
		keep[id] = true
	end
	if self.CurrentId then
		keep[self.CurrentId] = true
	end
	for _, id in ipairs(self.Queue or {}) do
		keep[id] = true
	end
	local tracks = {}
	for id, track in pairs(self.Tracks) do
		if keep[id] then
			tracks[id] = track
		end
	end
	local order = {}
	for _, id in ipairs(self.Order or {}) do
		if tracks[id] then
			order[#order + 1] = id
		end
	end
	self.Data.tracks = tracks
	self.Data.playlists = self.Playlists
	self.Data.settings = self.Settings
	self.Data.order = order
	self.Data.recommended = self.Recommended
	Nerx.Storage:WriteJSON(MUSIC_STORE_FILE, self.Data)
end

function Music:Subscribe(callback)
	self.Listeners = self.Listeners or {}
	table.insert(self.Listeners, callback)
	return callback
end

function Music:_Emit(kind, payload)
	for _, listener in ipairs(self.Listeners or {}) do
		pcall(listener, kind, payload)
	end
end

function Music:GetTrack(id)
	return self.Tracks[tostring(id or "")]
end

function Music:GetPlaylist(id)
	for _, playlist in ipairs(self.Playlists or {}) do
		if playlist.id == id then
			return playlist
		end
	end
	return nil
end

function Music:_ApiGet(path, ttl, force)
	local url = musicBuildApiUrl(path)
	if url == nil then
		self.LastApiError = "网易云接口地址无效"
		return nil
	end
	local now = os.clock()
	local cached = self._ApiCache[url]
	if cached and not force and now - cached.t < (ttl or 180) then
		return cached.data
	end
	if self._CooldownUntil and now < self._CooldownUntil then
		self.LastApiError = string.format("网易云请求冷却中，请 %.0f 秒后重试", self._CooldownUntil - now)
		return nil
	end
	if self._NextRequestAt and now < self._NextRequestAt then
		task.wait(self._NextRequestAt - now)
	end
	self._NextRequestAt = os.clock() + 0.35
	local response = musicHttp({
		Url = url,
		Method = "GET",
		Headers = musicNcmHeaders(self.Settings.cookie),
	}, 15)
	if not response or not response.body then
		self.LastApiError = response and response.error or "网易云无响应"
		return nil
	end
	local status = response.status
	if status and (status < 200 or status >= 300) then
		if status == 429 or status == 460 or status == 503 then
			self._CooldownUntil = os.clock() + 30
			self.LastApiError = "网易云请求过于频繁（HTTP " .. tostring(status) .. "），请稍后重试"
		else
			self.LastApiError = "网易云 HTTP " .. tostring(status)
		end
		return nil
	end
	local decoded = Nerx.Storage:Decode(response.body)
	if type(decoded) ~= "table" then
		self.LastApiError = "网易云返回内容不是有效 JSON"
		return nil
	end
	local code = tonumber(decoded.code)
	if code and code ~= 200 then
		self.LastApiError = "网易云接口错误 " .. tostring(code) .. "：" .. tostring(decoded.msg or decoded.message or "")
		return nil
	end
	self.LastApiError = nil
	self._ApiCache[url] = { t = os.clock(), data = decoded }
	return decoded
end

function Music:_RegisterNeteaseSongs(rawSongs, limit)
	local ids = {}
	if type(rawSongs) ~= "table" then
		return ids
	end
	for _, raw in ipairs(rawSongs) do
		if type(raw) == "table" then
			local netId = tostring(raw.id or "")
			if netId:match("^%d+$") then
				local id = "ne_" .. netId
				local existing = self.Tracks[id]
				local artistNames = {}
				local artistId = nil
				local artists = raw.artists or raw.ar
				if type(artists) == "table" then
					for _, artist in ipairs(artists) do
						if type(artist) == "table" and artist.name then
							artistNames[#artistNames + 1] = tostring(artist.name)
							if not artistId and artist.id then
								artistId = tostring(artist.id)
							end
						end
					end
				end
				local artist = table.concat(artistNames, " / ")
				if artist == "" then
					artist = musicTrim(raw.artist)
				end
				if artist == "" then
					artist = "未知歌手"
				end
				local album = raw.album or raw.al
				local albumName = type(album) == "table" and tostring(album.name or "") or ""
				if albumName == "" then
					albumName = "网易云音乐"
				end
				local duration = (tonumber(raw.duration or raw.dt) or 0) / 1000
				local picUrl = ""
				local albumTable = type(album) == "table" and album or nil
				if albumTable then
					picUrl = tostring(albumTable.picUrl or albumTable.pic_url or albumTable.blurPicUrl or "")
				end
				if picUrl == "" then
					picUrl = tostring(raw.picUrl or raw.pic_url or "")
				end
				local c1, c2 = musicArtColors(tostring(raw.name or "") .. artist .. netId)
				local track = {
					id = id,
					source = "netease",
					netId = netId,
					name = tostring(raw.name or "未知歌曲"),
					artist = artist,
					artistId = artistId or (existing and existing.artistId or nil),
					album = albumName,
					duration = duration > 0 and duration or (existing and existing.duration or 0),
					fee = tonumber(raw.fee) or (existing and existing.fee or 0),
					liked = existing and existing.liked or false,
					lyrics = existing and existing.lyrics or "",
					yrc = existing and existing.yrc or "",
					lyricsLoaded = existing and existing.lyricsLoaded or false,
					coverUrl = picUrl ~= "" and picUrl or (existing and existing.coverUrl or ""),
					cachedPath = existing and existing.cachedPath or nil,
					cachedQuality = existing and existing.cachedQuality or nil,
					color1 = existing and existing.color1 or c1,
					color2 = existing and existing.color2 or c2,
					addedAt = existing and existing.addedAt or os.time(),
				}
				self.Tracks[id] = track
				if not existing then
					table.insert(self.Order, 1, id)
				end
				ids[#ids + 1] = id
				if limit and #ids >= limit then
					break
				end
			end
		end
	end
	return ids
end

function Music:SearchNetease(keyword, callback)
	keyword = musicTrim(keyword)
	if keyword == "" then
		self.SearchIds = {}
		self.SearchQuery = ""
		self.Searching = false
		self.SearchError = nil
		self:_Emit("search")
		if callback then
			callback({}, nil)
		end
		return
	end
	self.SearchQuery = keyword
	self.Searching = true
	self.SearchError = nil
	self.SearchIds = {}
	self:_Emit("search")
	task.spawn(function()
		local data = self:_ApiGet("/cloudsearch?keywords=" .. musicUrlEncode(keyword) .. "&type=1&limit=30&offset=0", 120)
		if self.SearchQuery ~= keyword then
			return
		end
		local songs = data and data.result and data.result.songs
		local ids = self:_RegisterNeteaseSongs(songs, 30)
		self.Searching = false
		self.SearchIds = ids
		if not data then
			self.SearchError = self.LastApiError or "网易云请求失败"
		elseif #ids == 0 then
			self.SearchError = "网易云没有找到歌曲"
		end
		self:_Emit("search")
		if callback then
			callback(ids, self.SearchError)
		end
	end)
end

function Music:SearchArtists(keyword, callback)
	keyword = musicTrim(keyword)
	self.ArtistQuery = keyword
	self.ArtistResults = {}
	self.ArtistSearching = keyword ~= ""
	self:_Emit("search")
	if keyword == "" then
		if callback then
			callback({})
		end
		return
	end
	task.spawn(function()
		local data = self:_ApiGet("/search?keywords=" .. musicUrlEncode(keyword) .. "&type=100&limit=20&offset=0", 120)
		if self.ArtistQuery ~= keyword then
			return
		end
		local items = data and data.result and data.result.artists or {}
		local out = {}
		for _, item in ipairs(items) do
			local netId = tostring(item.id or "")
			if netId:match("^%d+$") then
				out[#out + 1] = {
					netId = netId,
					name = tostring(item.name or "未知歌手"),
					avatarUrl = tostring(item.picUrl or item.img1v1Url or ""),
					albumSize = tonumber(item.albumSize) or 0,
					musicSize = tonumber(item.musicSize) or 0,
					fans = tonumber(item.fansCount or item.fans) or 0,
				}
			end
		end
		self.ArtistResults = out
		self.ArtistSearching = false
		self:_Emit("search")
		if callback then
			callback(out)
		end
	end)
end

function Music:SearchPlaylists(keyword, callback)
	keyword = musicTrim(keyword)
	self.PlaylistQuery = keyword
	self.PlaylistResults = {}
	self.PlaylistSearching = keyword ~= ""
	self:_Emit("search")
	if keyword == "" then
		if callback then
			callback({})
		end
		return
	end
	task.spawn(function()
		local data = self:_ApiGet("/search?keywords=" .. musicUrlEncode(keyword) .. "&type=1000&limit=20&offset=0", 120)
		if self.PlaylistQuery ~= keyword then
			return
		end
		local items = data and data.result and data.result.playlists or {}
		local out = {}
		for _, item in ipairs(items) do
			local netId = tostring(item.id or "")
			if netId:match("^%d+$") then
				local creator = ""
				if type(item.creator) == "table" then
					creator = tostring(item.creator.nickname or item.creator.name or "")
				end
				out[#out + 1] = {
					netId = netId,
					name = tostring(item.name or "网易云歌单"),
					creator = creator ~= "" and creator or "网易云音乐",
					count = tonumber(item.trackCount or item.songCount) or 0,
					playCount = tonumber(item.playCount) or 0,
					coverUrl = tostring(item.coverImgUrl or item.picUrl or ""),
				}
			end
		end
		self.PlaylistResults = out
		self.PlaylistSearching = false
		self:_Emit("search")
		if callback then
			callback(out)
		end
	end)
end

function Music:LoadCharts(force, callback)
	if self.ChartsLoading and not force then
		return
	end
	self.ChartsLoading = true
	self:_Emit("charts")
	task.spawn(function()
		self.Charts = {}
		for _, chart in ipairs(self.ChartList) do
			local entry = {
				netId = chart.netId,
				name = chart.name,
				tag = chart.tag,
				creator = "网易云音乐",
				count = 0,
				playCount = 0,
				coverUrl = "",
				color1 = musicArtColors(chart.name .. chart.netId),
				color2 = select(2, musicArtColors(chart.name .. chart.netId)),
			}
			local data = self:_ApiGet("/playlist/detail?id=" .. chart.netId, 900, force)
			local raw = data and (data.playlist or (data.data and data.data.playlist))
			if raw then
				entry.name = musicTrim(raw.name) ~= "" and musicTrim(raw.name) or entry.name
				entry.creator = type(raw.creator) == "table" and tostring(raw.creator.nickname or raw.creator.name or "网易云音乐") or "网易云音乐"
				entry.count = tonumber(raw.trackCount or raw.track_count) or 0
				entry.playCount = tonumber(raw.playCount) or 0
				entry.coverUrl = tostring(raw.coverImgUrl or raw.picUrl or "")
			end
			self.Charts[#self.Charts + 1] = entry
			task.wait(0.32)
		end
		self.ChartsLoading = false
		self:_Emit("charts")
		if callback then
			callback(self.Charts)
		end
	end)
end

function Music:LoadCloud(callback)
	if musicTrim(self.Settings.cookie) == "" then
		self.CloudIds = {}
		self.CloudError = "登录网易云后可以读取云盘"
		self.CloudLoading = false
		self:_Emit("cloud")
		if callback then
			callback({}, self.CloudError)
		end
		return
	end
	if self.CloudLoading then
		return
	end
	self.CloudLoading = true
	self.CloudError = nil
	self:_Emit("cloud")
	task.spawn(function()
		local data = self:_ApiGet("/cloud?limit=200", 180, true)
		local items = data and (data.data or data.songs or data.cloudSongs) or {}
		local ids = {}
		local seen = {}
		if type(items) == "table" then
			for _, item in ipairs(items) do
				local song = type(item) == "table" and (item.simpleSong or item.song) or nil
				if type(song) == "table" then
					local newIds = self:_RegisterNeteaseSongs({ song }, 1)
					local id = newIds[1]
					if id and not seen[id] then
						seen[id] = true
						ids[#ids + 1] = id
					end
				elseif type(item) == "table" then
					local netId = tostring(item.songId or item.songid or "")
					local id = "ne_" .. netId
					if netId:match("^%d+$") and self.Tracks[id] and not seen[id] then
						seen[id] = true
						ids[#ids + 1] = id
					end
				end
			end
		end
		self.CloudIds = ids
		self.CloudLoading = false
		if #ids == 0 then
			self.CloudError = self.LastApiError or "云盘暂无歌曲（或该接口需要登录）"
		end
		self:_Emit("cloud")
		if callback then
			callback(ids, self.CloudError)
		end
	end)
end

function Music:GetArtist(netId)
	return self.Artists and self.Artists[tostring(netId or "")]
end

function Music:LoadArtist(netId, meta, force, callback)
	netId = tostring(netId or "")
	if not netId:match("^%d+$") then
		return nil
	end
	self.Artists = self.Artists or {}
	local cached = self.Artists[netId]
	if cached and cached.loaded and not force then
		if callback then
			callback(cached)
		end
		return cached
	end
	meta = meta or {}
	local artist = cached or {
		netId = netId,
		name = tostring(meta.name or "网易云歌手"),
		avatarUrl = tostring(meta.avatarUrl or meta.avatar or ""),
		songs = {},
		albums = {},
		loaded = false,
	}
	artist.loading = true
	artist.error = nil
	self.Artists[netId] = artist	self:_Emit("artist", artist)
	task.spawn(function()
		local detail = self:_ApiGet("/artist/detail?id=" .. netId, 300, force)
		local data = detail and (detail.data or detail)
		local info = data and data.artist
		if info then
			artist.name = tostring(info.name or artist.name)
			artist.avatarUrl = tostring(info.avatar or info.cover or info.picUrl or artist.avatarUrl)
			artist.briefDesc = tostring(info.briefDesc or info.description or "")
			artist.albumSize = tonumber(info.albumSize) or 0
			artist.musicSize = tonumber(info.musicSize) or 0
			artist.fans = tonumber(info.fansCount or info.fans) or 0
		end
		local top = self:_ApiGet("/artist/top?id=" .. netId, 300, force)
		local songs = top and top.songs or {}
		artist.songs = self:_RegisterNeteaseSongs(songs, 100)
		local albumData = self:_ApiGet("/artist/album?id=" .. netId .. "&limit=12&offset=0", 300, force)
		local albums = albumData and (albumData.hotAlbums or albumData.albums) or {}
		artist.albums = {}
		for _, album in ipairs(albums) do
			if type(album) == "table" then
				artist.albums[#artist.albums + 1] = {
					netId = tostring(album.id or ""),
					name = tostring(album.name or "专辑"),
					coverUrl = tostring(album.picUrl or album.blurPicUrl or ""),
					count = tonumber(album.size) or 0,
					publishTime = tonumber(album.publishTime) or 0,
				}
			end
		end
		artist.loading = false
		artist.loaded = #artist.songs > 0
		if not artist.loaded then
			artist.error = self.LastApiError or "歌手歌曲加载失败"
		end
		self:_Emit("artist", artist)
		if callback then
			callback(artist)
		end
	end)
	return artist
end

function Music:LoadRecommended(force, callback)
	if self.RecommendedLoading and not force then
		return
	end
	self.RecommendedLoading = true
	self.RecommendedError = nil
	self.RecommendedToken = (self.RecommendedToken or 0) + 1
	local token = self.RecommendedToken
	self:_Emit("recommended")
	task.spawn(function()
		local data = self:_ApiGet("/personalized?limit=12", 180, force)
		local items = data and (data.result or data.recommend or data.playlists)
		if type(items) ~= "table" or #items == 0 then
			data = self:_ApiGet("/top/playlist?limit=12&offset=0&order=hot&cat=" .. musicUrlEncode("全部"), 180, force)
			items = data and (data.playlists or data.result)
		end
		if token ~= self.RecommendedToken then
			return
		end
		local out = {}
		local seen = {}
		if type(items) == "table" then
			for _, item in ipairs(items) do
				if type(item) == "table" then
					local netId = tostring(item.id or "")
					if netId:match("^%d+$") and not seen[netId] then
						seen[netId] = true
						local name = musicTrim(item.name)
						if name == "" then
							name = "网易云歌单"
						end
						local creator = ""
						if type(item.creator) == "table" then
							creator = tostring(item.creator.nickname or item.creator.name or "")
						end
						if creator == "" then
							creator = "网易云音乐"
						end
						local count = tonumber(item.trackCount or item.track_count or item.songCount) or 0
						local playCount = tonumber(item.playCount or item.play_count) or 0
						local c1, c2 = musicArtColors(name .. netId)
						out[#out + 1] = {
							netId = netId,
							name = name,
							creator = creator,
							count = count,
							playCount = playCount,
							color1 = c1,
							color2 = c2,
							coverUrl = tostring(item.coverImgUrl or item.picUrl or item.coverUrl or ""),
						}
					end
				end
			end
		end
		self.RecommendedLoading = false
		if #out > 0 then
			self.Recommended = out
			self.RecommendedError = nil
			self:Save()
		else
			self.RecommendedError = self.LastApiError or "网易云推荐歌单获取失败"
		end
		self:_Emit("recommended")
		if callback then
			callback(self.Recommended, self.RecommendedError)
		end
	end)
end

function Music:OpenNeteasePlaylist(netId, meta, callback, force)
	netId = tostring(netId or "")
	if not netId:match("^%d+$") then
		return nil
	end
	local id = "ne_pl_" .. netId
	local playlist = self:GetPlaylist(id)
	if not playlist then
		meta = meta or {}
		local name = musicTrim(meta.name)
		if name == "" then
			name = "网易云歌单 " .. netId
		end
		local c1, c2 = musicArtColors(name .. netId)
		playlist = {
			id = id,
			name = name,
			kind = "netease",
			netId = netId,
			creator = tostring(meta.creator or "网易云音乐"),
			count = tonumber(meta.count) or 0,
			coverUrl = tostring(meta.coverUrl or ""),
			trackIds = {},
			loading = false,
			loaded = false,
			color1 = c1,
			color2 = c2,
			created = os.time(),
		}
		table.insert(self.Playlists, playlist)
	end
	if playlist.kind ~= "netease" then
		return playlist
	end
	if playlist.loading then
		return playlist
	end
	if playlist.loaded and not force and #playlist.trackIds > 0 then
		return playlist
	end
	playlist.loading = true
	playlist.loaded = false
	playlist.error = nil
	task.spawn(function()
		local detail = self:_ApiGet("/playlist/detail?id=" .. netId, 120, force)
		local raw = detail and (detail.playlist or (detail.data and detail.data.playlist))
		local rawSongs = raw and raw.tracks
		local ids = self:_RegisterNeteaseSongs(rawSongs, 200)
		local trackIds = raw and raw.trackIds
		local wanted = {}
		if type(trackIds) == "table" then
			for _, entry in ipairs(trackIds) do
				local songId = tostring(type(entry) == "table" and (entry.id or entry.songId) or entry or "")
				if songId:match("^%d+$") then
					wanted[#wanted + 1] = songId
				end
				if #wanted >= 200 then
					break
				end
			end
		end
		if #wanted > #ids then
			local known = {}
			for _, id2 in ipairs(ids) do
				known[id2] = true
			end
			for first = 1, #wanted, 100 do
				local batch = {}
				for index = first, math.min(first + 99, #wanted) do
					local songId = "ne_" .. wanted[index]
					if not known[songId] then
						batch[#batch + 1] = wanted[index]
					end
				end
				if #batch > 0 then
					local songsData = self:_ApiGet("/song/detail?ids=" .. musicUrlEncode("[" .. table.concat(batch, ",") .. "]"), 180, force)
					local songs = songsData and songsData.songs
					local more = self:_RegisterNeteaseSongs(songs, 200)
					for _, songId in ipairs(more) do
						if not known[songId] then
							known[songId] = true
							ids[#ids + 1] = songId
						end
					end
				end
				if #ids >= 200 then
					break
				end
			end
		end
		if raw then
			local name = musicTrim(raw.name)
			if name ~= "" then
				playlist.name = name
			end
			if type(raw.creator) == "table" then
				playlist.creator = tostring(raw.creator.nickname or raw.creator.name or playlist.creator)
			end
			playlist.count = tonumber(raw.trackCount or raw.track_count) or #ids
			playlist.color1, playlist.color2 = musicArtColors(playlist.name .. netId)
			playlist.coverUrl = tostring(raw.coverImgUrl or raw.picUrl or playlist.coverUrl or "")
		end
		local finalIds = {}
		local seenIds = {}
		for _, id in ipairs(ids) do
			if not seenIds[id] then
				seenIds[id] = true
				finalIds[#finalIds + 1] = id
			end
		end
		playlist.trackIds = finalIds
		playlist.loading = false
		playlist.loaded = #finalIds > 0
		if #finalIds == 0 then
			playlist.error = self.LastApiError or "网易云歌单没有返回歌曲"
		else
			playlist.error = nil
		end
		self:Save()
		self:_Emit("library", playlist)
		if callback then
			callback(playlist, #ids == 0 and (self.LastApiError or "网易云歌单没有返回歌曲") or nil)
		end
	end)
	return playlist
end

function Music:OpenNeteaseAlbum(netId, meta, callback, force)
	netId = tostring(netId or "")
	if not netId:match("^%d+$") then
		return nil
	end
	local id = "ne_al_" .. netId
	local playlist = self:GetPlaylist(id)
	if not playlist then
		meta = meta or {}
		local name = musicTrim(meta.name)
		if name == "" then
			name = "网易云专辑 " .. netId
		end
		playlist = {
			id = id,
			name = name,
			kind = "netease",
			netId = netId,
			albumId = netId,
			creator = tostring(meta.creator or "网易云音乐"),
			count = tonumber(meta.count) or 0,
			coverUrl = tostring(meta.coverUrl or ""),
			trackIds = {},
			loading = false,
			loaded = false,
			color1 = musicArtColors(name .. netId),
			color2 = select(2, musicArtColors(name .. netId)),
			created = os.time(),
		}
		table.insert(self.Playlists, playlist)
	end
	if playlist.loading then
		return playlist
	end
	if playlist.loaded and not force and #playlist.trackIds > 0 then
		return playlist
	end
	playlist.loading = true
	playlist.error = nil
	task.spawn(function()
		local data = self:_ApiGet("/album?id=" .. netId, 180, force)
		local album = data and (data.album or (data.data and data.data.album))
		local songs = data and (data.songs or (album and album.songs))
		local ids = self:_RegisterNeteaseSongs(songs, 100)
		if album then
			playlist.name = musicTrim(album.name) ~= "" and musicTrim(album.name) or playlist.name
			playlist.coverUrl = tostring(album.picUrl or album.blurPicUrl or playlist.coverUrl or "")
			playlist.count = tonumber(album.size) or #ids
			if type(album.artist) == "table" then
				playlist.creator = tostring(album.artist.name or playlist.creator)
			end
		end
		playlist.trackIds = ids
		playlist.loading = false
		playlist.loaded = #ids > 0
		if #ids == 0 then
			playlist.error = self.LastApiError or "专辑暂无歌曲"
		end
		self:Save()
		self:_Emit("library", playlist)
		if callback then
			callback(playlist, playlist.error)
		end
	end)
	return playlist
end

function Music:FetchNeteaseLyrics(trackId)
	local track = self.Tracks[tostring(trackId or "")]
	if not track or track.source ~= "netease" or track.netId == nil then
		return
	end
	if track.lyricsLoaded or track.lyricsLoading then
		return
	end
	track.lyricsLoading = true
	track.lyricsError = nil
	task.spawn(function()
		local data = self:_ApiGet("/lyric?id=" .. track.netId, 300)
		track.lyricsLoading = false
		if not data then
			track.lyricsError = self.LastApiError or "网易云歌词获取失败"
			self:_Emit("lyrics", track)
			return
		end
		local raw = data.lrc and data.lrc.lyric or ""
		local translated = data.tlyric and data.tlyric.lyric or ""
		track.lyrics = musicMergeLrc(raw, translated)
		track.yrc = data.yrc and tostring(data.yrc.lyric or "") or ""
		track.lyricsLoaded = true
		track.lyricsError = nil
		self:Save()
		self:_Emit("lyrics", track)
	end)
end

function Music:SetCookie(cookie)
	cookie = musicTrim(cookie)
	if cookie ~= "" and not string.find(cookie, "=", 1, true) then
		cookie = "MUSIC_U=" .. cookie
	end
	self.Settings.cookie = cookie
	self._ApiCache = {}
	self:Save()
	self:_Emit("settings")
end

function Music:VerifyCookie(callback)
	if musicTrim(self.Settings.cookie) == "" then
		self.Settings.nickname = ""
		self.Settings.uid = ""
		self.MyPlaylists = {}
		self:Save()
		self:_Emit("account")
		if callback then
			callback(false, "未设置 Cookie")
		end
		return
	end
	task.spawn(function()
		local data = self:_ApiGet("/account", 60, true)
		local profile = data and (data.profile or (data.data and data.data.profile))
		if not profile then
			self.Settings.nickname = ""
			self.Settings.uid = ""
			self.MyPlaylists = {}
			self:Save()
			self:_Emit("account")
			if callback then
				callback(false, self.LastApiError or "Cookie 无效或已过期")
			end
			return
		end
		self.Settings.nickname = tostring(profile.nickname or "")
		self.Settings.uid = tostring(profile.userId or profile.userid or "")
		self:Save()
		self:_Emit("account")
		self:LoadAccountPlaylists()
		if callback then
			callback(true, self.Settings.nickname)
		end
	end)
end

function Music:QrLoginStart(callback)
	task.spawn(function()
		local response = musicHttp({
			Url = "https://music.163.com/api/login/qrcode/unikey?type=1",
			Method = "POST",
			Headers = musicNcmHeaders(""),
			Body = "",
		}, 20)
		local data = response and response.body and Nerx.Storage:Decode(response.body) or nil
		local key = data and tostring(data.unikey or "") or ""
		if not string.match(key, "^[%w]+$") then
			if callback then
				callback(false, nil, nil, (data and (data.message or data.msg)) or (response and response.error) or "二维码创建失败")
			end
			return
		end
		local qrPath = self.CacheDir .. "/qr_" .. tostring(self:_Hash(key)) .. ".png"
		local asset = nil
		if self:_FileExists(qrPath) then
			asset = self:_Asset(qrPath)
		end
		if not asset then
			-- NetEase's /qrcode/<key> endpoint now returns 404, so render the
			-- login URL (same content the web client encodes) through a QR
			-- image service, with a second provider as fallback.
			local loginUrl = "https://music.163.com/login?codekey=" .. key
			local encoded = musicUrlEncode(loginUrl)
			local candidates = {
				"https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=" .. encoded,
				"https://quickchart.io/qr?size=300&text=" .. encoded,
			}
			for _, url in ipairs(candidates) do
				if self:_DownloadFile(url, qrPath, 20) then
					asset = self:_Asset(qrPath)
					if asset then
						break
					end
				end
			end
		end
		if callback then
			callback(true, key, asset, asset and nil or "二维码图片加载失败，可改用 Cookie 登录")
		end
	end)
end

function Music:QrLoginPoll(key, callback)
	key = tostring(key or "")
	if key == "" then
		if callback then
			callback("expired")
		end
		return
	end
	task.spawn(function()
		local response = musicHttp({
			Url = "https://music.163.com/api/login/qrcode/client/login?key=" .. musicUrlEncode(key) .. "&type=1",
			Method = "GET",
			Headers = musicNcmHeaders(""),
		}, 15)
		local data = response and response.body and Nerx.Storage:Decode(response.body) or nil
		local code = tonumber(data and data.code) or 801
		if code == 803 then
			local token = self:_CookieFromHeaders(response and response.headers)
			if not token and data then
				token = string.match(tostring(data.cookie or ""), "MUSIC_U=([^;%s]+)")
			end
			if token and token ~= "" then
				self:SetCookie("MUSIC_U=" .. token)
				self:VerifyCookie(function(ok, message)
					if callback then
						callback(ok and "success" or "failed", message)
					end
				end)
			elseif callback then
				callback("failed", "登录成功但没有拿到 MUSIC_U Cookie")
			end
			return
		end
		if callback then
			if code == 802 then
				callback("scanned")
			elseif code == 800 then
				callback("expired")
			else
				callback("waiting")
			end
		end
	end)
end

function Music:Logout()
	self.Settings.cookie = ""
	self.Settings.nickname = ""
	self.Settings.uid = ""
	self.MyPlaylists = {}
	self._ApiCache = {}
	self:Save()
	self:_Emit("account")
end

function Music:LoadAccountPlaylists(callback)
	local uid = tostring(self.Settings.uid or "")
	if not uid:match("^%d+$") then
		return
	end
	task.spawn(function()
		local data = self:_ApiGet("/user/playlist?uid=" .. uid .. "&limit=50&offset=0", 120)
		local items = data and data.playlist
		local out = {}
		local seen = {}
		if type(items) == "table" then
			for _, item in ipairs(items) do
				if type(item) == "table" then
					local netId = tostring(item.id or "")
					if netId:match("^%d+$") and not seen[netId] then
						seen[netId] = true
						local name = musicTrim(item.name)
						if name ~= "" then
							local c1, c2 = musicArtColors(name .. netId)
							out[#out + 1] = {
								netId = netId,
								name = name,
								creator = self.Settings.nickname ~= "" and self.Settings.nickname or "网易云音乐",
								count = tonumber(item.trackCount or item.track_count) or 0,
								playCount = tonumber(item.playCount or item.play_count) or 0,
								color1 = c1,
								color2 = c2,
								coverUrl = tostring(item.coverImgUrl or item.picUrl or ""),
							}
						end
					end
				end
			end
		end
		self.MyPlaylists = out
		self:_Emit("account")
		if callback then
			callback(out)
		end
	end)
end

function Music:CachePath(netId, quality)
	local suffix = ""
	if quality and quality ~= "lossless" then
		suffix = "_" .. tostring(quality)
	end
	return self.CacheDir .. "/" .. tostring(netId) .. suffix .. ".mp3"
end

function Music:_StreamUrl(netId, quality)
	local br = 999000
	for _, entry in ipairs(self.Qualities) do
		if entry.key == quality then
			br = entry.br
			break
		end
	end
	local data = self:_ApiGet("/song/url?id=" .. tostring(netId) .. "&br=" .. tostring(br), 60)
	local item = data and data.data and data.data[1]
	local url = item and item.url
	if type(url) == "string" and url ~= "" then
		return url
	end
	return "https://music.163.com/song/media/outer/url?id=" .. tostring(netId) .. ".mp3"
end

function Music:_FileExists(path)
	if not fnIsFile then
		return false
	end
	local ok, exists = pcall(fnIsFile, path)
	return ok and exists == true
end

function Music:_Asset(path)
	if type(fnAsset) ~= "function" then
		return nil, "执行器缺少 getcustomasset"
	end
	local candidates = { path }
	if type(fnWorkspace) == "function" then
		local ok, workspacePath = pcall(fnWorkspace)
		if ok and type(workspacePath) == "string" and workspacePath ~= "" then
			candidates[#candidates + 1] = workspacePath .. "/" .. path
		end
	end
	for _, candidate in ipairs(candidates) do
		local ok, asset = pcall(fnAsset, candidate)
		if ok and type(asset) == "string" and asset ~= "" then
			return asset
		end
	end
	return nil, "getcustomasset 失败"
end

function Music:_Download(url, path)
	if type(rawRequest) ~= "function" then
		return nil, "执行器缺少 request，无法下载网易云音频"
	end
	if type(fnWrite) ~= "function" then
		return nil, "执行器缺少 writefile，无法缓存网易云音频"
	end
	if type(fnMakeFolder) == "function" then
		pcall(fnMakeFolder, self.CacheDir)
	end
	local headers = musicNcmHeaders(self.Settings.cookie)
	headers["Accept"] = "*/*"
	local response = musicHttpFollow({ Url = url, Method = "GET", Headers = headers }, 45)
	if not response or not response.body then
		return nil, response and response.error or "网易云音频下载失败"
	end
	local body = response.body
	if #body < 1024 or string.sub(body, 1, 1) == "{" or string.sub(body, 1, 1) == "<" then
		return nil, "网易云返回的不是音频（可能是 VIP / 版权限制）"
	end
	local ok, err = pcall(fnWrite, path, body)
	if not ok then
		local alt = path:gsub("/", "\\")
		ok, err = pcall(fnWrite, alt, body)
		if ok then
			path = alt
		else
			return nil, "writefile 失败：" .. tostring(err)
		end
	end
	return path
end

function Music:_DownloadFile(url, path, timeout)
	if type(rawRequest) ~= "function" or type(fnWrite) ~= "function" then
		return nil
	end
	if type(fnMakeFolder) == "function" then
		pcall(fnMakeFolder, self.CacheDir)
	end
	local headers = musicNcmHeaders(self.Settings.cookie)
	headers["Accept"] = "image/avif,image/webp,image/apng,image/*,*/*;q=0.8"
	local response = musicHttpFollow({ Url = url, Method = "GET", Headers = headers }, timeout or 24)
	if not response or not response.body or #response.body < 64 then
		return nil
	end
	local first = string.sub(response.body, 1, 1)
	if first == "{" or first == "<" then
		return nil
	end
	local ok, err = pcall(fnWrite, path, response.body)
	if not ok then
		local alternate = path:gsub("/", "\\")
		ok, err = pcall(fnWrite, alternate, response.body)
		if ok then
			path = alternate
		else
			return nil
		end
	end
	return path
end

function Music:CoverUrl(url, size)
	url = tostring(url or "")
	if url == "" then
		return ""
	end
	-- NetEase sometimes returns http:// picture URLs; executors only download
	-- https reliably, which is why some covers silently stayed as gradients.
	url = string.gsub(url, "^http://", "https://")
	size = tonumber(size) or 300
	local param = "param=" .. tostring(math.floor(size)) .. "y" .. tostring(math.floor(size))
	if string.find(url, "?", 1, true) then
		return url .. "&" .. param
	end
	return url .. "?" .. param
end

-- Covers are downloaded once and shared between the rail, grids, player bar,
-- lyrics page and the world lyrics. The callback receives nil when the
-- executor cannot cache images; callers fall back to generated artwork.
function Music:Cover(url, callback, size)
	url = musicTrim(url)
	if url == "" then
		if callback then
			callback(nil)
		end
		return
	end
	self._CoverCache = self._CoverCache or {}
	local key = self:CoverUrl(url, size or 300)
	local cached = self._CoverCache[key]
	if cached ~= nil then
		if callback then
			callback(cached or nil)
		end
		return
	end
	if type(fnWrite) ~= "function" or type(fnAsset) ~= "function" then
		if callback then
			callback(nil)
		end
		return
	end
	task.spawn(function()
		local pathPart = string.match(key, "^[^?]+") or key
		local extension = string.match(pathPart, "%.([%a%d]+)$") or "jpg"
		extension = string.lower(extension)
		if extension ~= "jpg" and extension ~= "jpeg" and extension ~= "png" and extension ~= "webp" then
			extension = "jpg"
		end
		local path = self.CacheDir .. "/cover_" .. tostring(self:_Hash(key)) .. "." .. extension
		local asset = nil
		if self:_FileExists(path) then
			asset = self:_Asset(path)
		end
		if not asset then
			if self:_FileExists(path) and type(fnDelFile) == "function" then
				pcall(fnDelFile, path)
			end
			local ok = self:_DownloadFile(key, path, 24)
			if ok then
				asset = self:_Asset(path)
			end
		end
		self._CoverCache[key] = asset or false
		if callback then
			callback(asset)
		end
	end)
end

function Music:ClearCache()
	local removed = 0
	if type(fnListFiles) == "function" then
		local ok, files = pcall(fnListFiles, self.CacheDir)
		if ok and type(files) == "table" then
			for _, file in ipairs(files) do
				if type(file) == "string" then
					local lower = string.lower(file)
					local removable = string.sub(lower, -4) == ".mp3"
						or string.sub(lower, -4) == ".jpg"
						or string.sub(lower, -4) == ".png"
						or string.sub(lower, -5) == ".webp"
					if removable and type(fnDelFile) == "function" then
						local deleted = pcall(fnDelFile, file)
						if deleted then
							removed = removed + 1
						end
					end
				end
			end
		end
	end
	self:Save()
	self._CoverCache = {}
	self:_Emit("cache")
	return removed
end

function Music:OrderedIds()
	local ids = {}
	local seen = {}
	for _, id in ipairs(self.Order or {}) do
		if self.Tracks[id] and not seen[id] then
			seen[id] = true
			ids[#ids + 1] = id
		end
	end
	for id in pairs(self.Tracks) do
		if not seen[id] then
			ids[#ids + 1] = id
		end
	end
	return ids
end

function Music:LikedIds()
	local ids = {}
	for _, id in ipairs(self:OrderedIds()) do
		local track = self.Tracks[id]
		if track and track.liked then
			ids[#ids + 1] = id
		end
	end
	return ids
end

function Music:PlaylistIds(playlist)
	local ids = {}
	if not playlist then
		return ids
	end
	for _, id in ipairs(playlist.trackIds or {}) do
		if self.Tracks[id] then
			ids[#ids + 1] = id
		end
	end
	return ids
end

function Music:AddTrack(config)
	config = config or {}
	local soundId = musicNormalizeSoundId(config.SoundId or config.soundId)
	if not soundId then
		return nil
	end
	local name = musicTrim(config.Name or config.name)
	if name == "" then
		name = "Sound " .. soundId
	end
	local artist = musicTrim(config.Artist or config.artist)
	if artist == "" then
		artist = "未知歌手"
	end
	local id = "tr_" .. tostring(os.time()) .. "_" .. tostring(#self.Order + 1)
	while self.Tracks[id] do
		id = id .. "x"
	end
	local c1, c2 = musicArtColors(name .. soundId)
	local track = {
		id = id,
		soundId = soundId,
		name = name,
		artist = artist,
		album = musicTrim(config.Album) ~= "" and musicTrim(config.Album) or "本地曲库",
		duration = tonumber(config.Duration) or 210,
		liked = false,
		lyrics = "",
		color1 = c1,
		color2 = c2,
		addedAt = os.time(),
	}
	self.Tracks[id] = track
	table.insert(self.Order, 1, id)
	local playlistId = config.PlaylistId
	if not playlistId then
		local first = self.Playlists[1]
		playlistId = first and first.id or nil
	end
	if playlistId then
		self:AddToPlaylist(playlistId, id)
	end
	self:Save()
	self:_Emit("library", track)
	return track
end

function Music:AddPlaylist(name)
	name = musicTrim(name)
	if name == "" then
		return nil
	end
	local c1, c2 = musicArtColors(name .. tostring(os.time()))
	local playlist = {
		id = "pl_" .. tostring(os.time()) .. "_" .. tostring(math.random(100, 999)),
		name = name,
		kind = "custom",
		trackIds = {},
		color1 = c1,
		color2 = c2,
		created = os.time(),
	}
	while self:GetPlaylist(playlist.id) do
		playlist.id = playlist.id .. "x"
	end
	table.insert(self.Playlists, playlist)
	self:Save()
	self:_Emit("library", playlist)
	return playlist
end

function Music:RenamePlaylist(id, name)
	name = musicTrim(name)
	local playlist = self:GetPlaylist(id)
	if not playlist or name == "" then
		return false
	end
	playlist.name = name
	self:Save()
	self:_Emit("library", playlist)
	return true
end

function Music:DeletePlaylist(id)
	for index, playlist in ipairs(self.Playlists) do
		if playlist.id == id then
			table.remove(self.Playlists, index)
			self:Save()
			self:_Emit("library", nil)
			return true
		end
	end
	return false
end

function Music:AddToPlaylist(playlistId, trackId)
	local playlist = self:GetPlaylist(playlistId)
	if not playlist or not self.Tracks[trackId] then
		return false
	end
	for _, id in ipairs(playlist.trackIds) do
		if id == trackId then
			return false
		end
	end
	table.insert(playlist.trackIds, 1, trackId)
	self:Save()
	self:_Emit("library", playlist)
	return true
end

function Music:RemoveFromPlaylist(playlistId, trackId)
	local playlist = self:GetPlaylist(playlistId)
	if not playlist then
		return false
	end
	for index, id in ipairs(playlist.trackIds) do
		if id == trackId then
			table.remove(playlist.trackIds, index)
			self:Save()
			self:_Emit("library", playlist)
			return true
		end
	end
	return false
end

function Music:ToggleLike(id)
	local track = self.Tracks[id]
	if not track then
		return false, false
	end
	track.liked = not track.liked
	self:Save()
	self:_Emit("library", track)
	return true, track.liked
end

function Music:SetLyrics(id, raw)
	local track = self.Tracks[id]
	if not track then
		return false
	end
	track.lyrics = tostring(raw or "")
	track.yrc = ""
	self:Save()
	self:_Emit("library", track)
	return true
end

function Music:QueueNext(id)
	if self.Tracks[id] then
		self.NextId = id
		return true
	end
	return false
end

function Music:Play(id, queueIds)
	local track = self.Tracks[tostring(id or "")]
	if not track then
		return false
	end
	if queueIds then
		local queue = {}
		local seen = {}
		for _, value in ipairs(queueIds) do
			value = tostring(value)
			if self.Tracks[value] and not seen[value] then
				seen[value] = true
				queue[#queue + 1] = value
			end
		end
		self.Queue = queue
		self.QueueIndex = 0
		for index, value in ipairs(queue) do
			if value == track.id then
				self.QueueIndex = index
				break
			end
		end
	end
	if #self.Queue == 0 then
		local index = 0
		for position, value in ipairs(self:OrderedIds()) do
			self.Queue[#self.Queue + 1] = value
			if value == track.id then
				index = position
			end
		end
		self.QueueIndex = index
	end
	self.CurrentId = track.id
	self.DesiredPlaying = true
	self.NextId = nil
	self.Data.history = self.Data.history or {}
	for index = #self.Data.history, 1, -1 do
		if self.Data.history[index] == track.id then
			table.remove(self.Data.history, index)
		end
	end
	table.insert(self.Data.history, 1, track.id)
	while #self.Data.history > 50 do
		table.remove(self.Data.history)
	end
	self:_Load(track)
	self:_Emit("track", track)
	return true
end

function Music:_Load(track)
	local sound = self.Sound
	self.DesiredPlaying = true
	self.LoadToken = (self.LoadToken or 0) + 1
	local token = self.LoadToken
	if not sound then
		return
	end
	if track.source == "netease" and track.netId then
		pcall(function()
			sound:Stop()
		end)
		pcall(function()
			sound.TimePosition = 0
		end)
		self.Playing = true
		self.Loading = true
		self:_Emit("state")
		task.spawn(function()
			self:_LoadNetease(track, token)
		end)
		return
	end
	if tostring(track.soundId or "") == "" then
		self.Playing = false
		self.Loading = false
		pcall(function()
			sound:Stop()
		end)
		task.defer(function()
			self:_Emit("loadfail", { track = track, message = "这首歌曲没有可播放的音频 ID" })
		end)
		return
	end
	pcall(function()
		sound:Stop()
	end)
	pcall(function()
		sound.TimePosition = 0
	end)
	sound.SoundId = "rbxassetid://" .. tostring(track.soundId)
	sound.Volume = self.Settings.volume
	self:ApplySoundEffects()
	self.Playing = true
	self.Loading = true
	local played = pcall(function()
		sound:Play()
	end)
	if not played then
		self.Playing = false
	end
	self:_Emit("state")
	task.spawn(function()
		local waited = 0
		while waited < 8 and self.LoadToken == token do
			if sound.TimeLength > 0 then
				break
			end
			task.wait(0.1)
			waited = waited + 0.1
		end
		if self.LoadToken ~= token then
			return
		end
		self.Loading = false
		if sound.TimeLength > 0 then
			local duration = tonumber(sound.TimeLength) or 0
			if duration > 0 and math.abs((tonumber(track.duration) or 0) - duration) > 0.05 then
				track.duration = duration
				self:Save()
				self:_Emit("library", track)
			end
			self.Playing = sound.IsPlaying
		else
			self.Playing = false
			pcall(function()
				sound:Stop()
			end)
			self:_Emit("loadfail", { track = track, message = "音频加载失败，请检查 Roblox 音频 ID" })
		end
		self:_Emit("state")
	end)
end

function Music:_LoadNetease(track, token, qualityOverride)
	local sound = self.Sound
	if not sound then
		return
	end
	local netId = tostring(track.netId or "")
	local quality = qualityOverride or self.Settings.quality or "lossless"
	local path = self:CachePath(netId, quality)
	local asset = nil
	if self:_FileExists(path) and (track.cachedQuality == quality or (quality == "lossless" and track.cachedQuality == nil)) then
		asset = self:_Asset(path)
	end
	local lastError = nil
	if not asset then
		if self:_FileExists(path) and type(fnDelFile) == "function" then
			pcall(fnDelFile, path)
		end
		local url = self:_StreamUrl(netId, quality)
		local ok, err = self:_Download(url, path)
		if token ~= self.LoadToken then
			return
		end
		if not ok and quality ~= "standard" then
			-- Lossless / Hi-Res usually needs a valid account. Fall back to the
			-- public 128 kbps stream instead of failing the whole song.
			quality = "standard"
			path = self:CachePath(netId, quality)
			url = "https://music.163.com/song/media/outer/url?id=" .. netId .. ".mp3"
			ok, err = self:_Download(url, path)
			if token ~= self.LoadToken then
				return
			end
		end
		if ok then
			asset = self:_Asset(path)
			track.cachedQuality = quality
		else
			lastError = err
		end
	end
	if token ~= self.LoadToken then
		return
	end
	if not asset then
		self.Loading = false
		self.Playing = false
		self:_Emit("state")
		self:_Emit("loadfail", { track = track, message = tostring(lastError or "网易云音频下载失败") })
		return
	end
	track.cachedPath = path
	sound.SoundId = asset
	sound.Volume = self.Settings.volume
	self:ApplySoundEffects()
	pcall(function()
		sound.TimePosition = 0
	end)
	self.Loading = false
	if not self.DesiredPlaying then
		self.Playing = false
		self:_Emit("state")
		return
	end
	local played = pcall(function()
		sound:Play()
	end)
	if not played then
		self.Playing = false
		self:_Emit("state")
		self:_Emit("loadfail", { track = track, message = "网易云音频无法交给 Sound 播放" })
		return
	end
	self.Playing = true
	self:_Emit("state")
	task.spawn(function()
		local waited = 0
		while waited < 8 and self.LoadToken == token do
			if sound.TimeLength > 0 then
				break
			end
			task.wait(0.1)
			waited = waited + 0.1
		end
		if self.LoadToken ~= token then
			return
		end
		if sound.TimeLength > 0 then
			local duration = tonumber(sound.TimeLength) or 0
			if duration > 0 and math.abs((tonumber(track.duration) or 0) - duration) > 0.05 then
				track.duration = duration
				self:Save()
				self:_Emit("library", track)
			end
			self.Playing = sound.IsPlaying
		else
			self.Playing = false
			pcall(function()
				sound:Stop()
			end)
			if not qualityOverride and quality ~= "standard" then
				self:_Emit("fallback", { track = track, quality = quality })
				self:_LoadNetease(track, token, "standard")
				return
			end
			self:_Emit("loadfail", { track = track, message = "网易云音频加载失败（VIP / 版权或接口限制）" })
		end
		self:_Emit("state")
	end)
end

function Music:Toggle()
	if not self.CurrentId then
		local ids = self.Queue
		if #ids == 0 then
			ids = self:OrderedIds()
		end
		if #ids == 0 then
			return false
		end
		return self:Play(ids[1], ids)
	end
	local sound = self.Sound
	if not sound then
		return false
	end
	if self.Playing then
		pcall(function()
			sound:Pause()
		end)
		self.Playing = false
		self.DesiredPlaying = false
	else
		if sound.TimeLength <= 0 then
			local track = self.Tracks[self.CurrentId]
			if track then
				self:_Load(track)
				return true
			end
		end
		if sound.TimeLength > 0 and sound.TimePosition >= sound.TimeLength - 0.05 then
			pcall(function()
				sound.TimePosition = 0
			end)
		end
		local resumed = pcall(function()
			sound:Resume()
		end)
		if not resumed then
			pcall(function()
				sound:Play()
			end)
		end
		self.Playing = true
		self.DesiredPlaying = true
	end
	self:_Emit("state")
	return true
end

function Music:Seek(ratio)
	local sound = self.Sound
	local duration = self:GetDuration()
	if not sound or duration <= 0 then
		return
	end
	local speed = tonumber(self.Settings and self.Settings.speed) or 1
	local position = math.clamp(tonumber(ratio) or 0, 0, 1) * duration
	pcall(function()
		sound.TimePosition = math.min(position / math.max(0.5, speed), math.max(0, duration - 0.05))
	end)
end

function Music:GetDuration()
	local track = self.CurrentId and self.Tracks[self.CurrentId]
	local duration = track and tonumber(track.duration) or 0
	if self.Sound and self.Sound.TimeLength and self.Sound.TimeLength > 0 then
		duration = self.Sound.TimeLength
	end
	return math.max(0, duration or 0)
end

function Music:GetPosition()
	if self.Sound and self.Sound.TimeLength and self.Sound.TimeLength > 0 then
		local speed = tonumber(self.Settings and self.Settings.speed) or 1
		return math.clamp(self.Sound.TimePosition * math.max(0.5, speed), 0, self.Sound.TimeLength)
	end
	return 0
end

function Music:Next(manual)
	if self.NextId then
		local queued = self.NextId
		self.NextId = nil
		if self.Tracks[queued] then
			self:Play(queued, self.Queue)
			return
		end
	end
	local ids = self.Queue
	if #ids == 0 then
		ids = self:OrderedIds()
		self.Queue = ids
	end
	if #ids == 0 then
		return
	end
	local index = self.QueueIndex
	if self.Settings.shuffle and manual ~= false then
		if #ids == 1 then
			self:Play(ids[1], ids)
			return
		end
		local choice = index
		while choice == index do
			choice = math.random(1, #ids)
		end
		self:Play(ids[choice], ids)
		return
	end
	local nextIndex = index + 1
	if nextIndex > #ids then
		if self.Settings.mode == "order" and manual ~= true then
			local sound = self.Sound
			if sound then
				pcall(function()
					sound:Stop()
				end)
				pcall(function()
					sound.TimePosition = 0
				end)
			end
			self.Playing = false
			self:_Emit("state")
			return
		end
		nextIndex = 1
	end
	if nextIndex < 1 then
		nextIndex = #ids
	end
	self:Play(ids[nextIndex], ids)
end

function Music:Prev()
	local ids = self.Queue
	if #ids == 0 then
		ids = self:OrderedIds()
		self.Queue = ids
	end
	if #ids == 0 then
		return
	end
	local index = self.QueueIndex
	if self.Settings.shuffle and #ids > 1 then
		local choice = index
		while choice == index do
			choice = math.random(1, #ids)
		end
		self:Play(ids[choice], ids)
		return
	end
	index = index - 1
	if index < 1 then
		index = #ids
	end
	self:Play(ids[index], ids)
end

function Music:_HandleEnded()
	if not self.CurrentId then
		return
	end
	if self.Settings.mode == "one" then
		local sound = self.Sound
		if sound then
			pcall(function()
				sound.TimePosition = 0
			end)
			pcall(function()
				sound:Play()
			end)
		end
		self.Playing = true
		self:_Emit("state")
	else
		self:Next(false)
	end
end

function Music:SetMode(mode)
	if mode ~= "order" and mode ~= "all" and mode ~= "one" then
		return
	end
	self.Settings.mode = mode
	self:Save()
	self:_Emit("settings")
end

function Music:SetShuffle(value)
	self.Settings.shuffle = value == true
	self:Save()
	self:_Emit("settings")
end

function Music:SetTranslation(value)
	self.Settings.showTranslation = value ~= false
	self:Save()
	self:_Emit("settings")
end

function Music:ApplySoundEffects()
	local sound = self.Sound
	if not sound then
		return
	end
	local settings = self.Settings
	if not self._Equalizer then
		local ok, effect = pcall(function()
			return Instance.new("EqualizerSoundEffect")
		end)
		if ok and effect then
			effect.Name = "NerxMusicEQ"
			effect.Parent = sound
			self._Equalizer = effect
		end
	end
	if self._Equalizer then
		self._Equalizer.Enabled = settings.eqEnabled == true
		self._Equalizer.LowGain = settings.eqEnabled and settings.eqLow or 0
		self._Equalizer.MidGain = settings.eqEnabled and settings.eqMid or 0
		self._Equalizer.HighGain = settings.eqEnabled and settings.eqHigh or 0
	end
	if not self._Pitch then
		local ok, effect = pcall(function()
			return Instance.new("PitchShiftSoundEffect")
		end)
		if ok and effect then
			effect.Name = "NerxMusicPitch"
			effect.Parent = sound
			self._Pitch = effect
		end
	end
	if self._Pitch then
		local octave = 2 ^ ((tonumber(settings.pitch) or 0) / 12)
		self._Pitch.Octave = math.clamp(octave, 0.5, 2)
	end
	pcall(function()
		sound.PlaybackSpeed = math.clamp(tonumber(settings.speed) or 1, 0.5, 2)
	end)
end

function Music:SetVolume(value, silent)
	value = math.clamp(tonumber(value) or 0, 0, 1)
	self.Settings.volume = value
	if self.Sound then
		self.Sound.Volume = value
	end
	if not silent then
		self:Save()
		self:_Emit("settings")
	end
end

function Music:Export()
	local encoded = Nerx.Storage:Encode(self.Data)
	if not encoded then
		return false
	end
	return Nerx.Storage:Copy(encoded), encoded
end

function Music:Import(text)
	local decoded = Nerx.Storage:Decode(text)
	if type(decoded) ~= "table" then
		return false
	end
	local data = musicNormalizeData(decoded)
	self.Data = data
	self.Tracks = data.tracks
	self.Playlists = data.playlists
	self.Settings = data.settings
	self.Order = data.order
	if self.CurrentId and not self.Tracks[self.CurrentId] then
		self.CurrentId = nil
		self.Queue = {}
		self.QueueIndex = 0
		self.Playing = false
		if self.Sound then
			pcall(function()
				self.Sound:Stop()
			end)
		end
	end
	if self.Sound then
		self.Sound.Volume = self.Settings.volume
	end
	self:Save()
	self:_Emit("library", nil)
	self:_Emit("track", self.CurrentId and self.Tracks[self.CurrentId] or nil)
	return true
end

-- ---------------------------------------------------------------------------------------
-- MusicPage: rail library, playlist / home / settings views, player, lyrics, coverflow
-- ---------------------------------------------------------------------------------------
Nerx.MusicPage = {}
local MusicPage = Nerx.MusicPage

function MusicPage.Build(page, config)
	config = config or {}
	local M = Nerx.Music
	M:Init()

	local canvas = page:SetCustomMode()
	local T = Theme
	local F = Fonts
	local W = Nerx.Widgets
	local UIHelpers = UIKit.UIHelpers
	local notify = UIKit.Notify

	-- Song / artist / playlist names are user data. Keep the locale pass from
	-- translating music text word by word.
	if Nerx.Locale and type(Nerx.Locale.SetSkip) == "function" then
		local previousSkip = Nerx.Locale.Skip
		Nerx.Locale:SetSkip(function(object)
			local node = object
			while node do
				local ok, marked = pcall(function()
					return node:GetAttribute("NerxMusic")
				end)
				if ok and marked then
					return true
				end
				node = node.Parent
			end
			if previousSkip then
				return previousSkip(object)
			end
			return false
		end)
	end
	pcall(function()
		canvas:SetAttribute("NerxMusic", true)
	end)

	local window = config.Window or page.Window
	local windowWidth = 1024
	local windowHeight = 700
	if window and window.Size then
		windowWidth = window.Size.X.Offset > 0 and window.Size.X.Offset or 1024
		windowHeight = window.Size.Y.Offset > 0 and window.Size.Y.Offset or 700
	end

	-- AbsoluteSize includes the menu UIScale (e.g. 150%), while every offset in
	-- this page is in unscaled units. Using the raw value made the whole layout
	-- 1.5x too wide/tall: grids were clipped at the window edge and the player
	-- bar was pushed below the visible area. Divide by the local scale chain.
	local boxSize = canvas.AbsoluteSize / U.parentScale(canvas)
	local SHELL_W = boxSize.X > 200 and boxSize.X or math.max(560, windowWidth - 240)
	local SHELL_H = boxSize.Y > 160 and boxSize.Y or math.max(380, windowHeight - 88)
	local RAIL_W = math.clamp(SHELL_W * 0.215, 158, 200)
	local GAP = 8
	local PAD = 6
	local WORK_W = SHELL_W - RAIL_W - GAP - PAD * 2
	local PLAYER_H = math.clamp(SHELL_H * 0.112, 58, 72)
	local MAIN_H = SHELL_H - PLAYER_H
	local ROW_H = 36
	local ROW_COVER = 26
	local ALBUM_W = math.clamp(SHELL_W * 0.185, 84, 126)
	local overlayWidth = window and windowWidth or SHELL_W
	local overlayHeight = window and windowHeight or SHELL_H

	local function accentText()
		return musicLuminance(T.Accent) > 0.62 and T.Window or T.White
	end

	local function pageAccent(alpha)
		return T.Accent
	end

	local state = {
		view = { kind = "home" },
		lastView = { kind = "home" },
		query = "",
		searchTab = "songs",
		lyricsOpen = false,
		lyricsMode = "page",
		lyricsSystem = nil,
		lyricsEntries = nil,
		lyricsTrackId = nil,
		lyricToken = 0,
		cfOpen = false,
		cfIndex = 1,
		cfIds = {},
		settingsTab = "lyrics",
		loginOpen = false,
		loginTab = "qr",
		qrKey = nil,
		qrToken = 0,
		qrBusy = false,
		qrStatus = "",
		qrAsset = nil,
		progressDragging = false,
		progressRatio = 0,
		worldPreview = false,
		worldSystem = nil,
		worldTrackId = nil,
		artistTab = "songs",
		partyControl = true,
		hotkeyCapture = nil,
		lastPlayerTrack = nil,
		islandToken = 0,
		themeToken = 0,
	}

	local railScroll
	local accountNameLabel
	local accountSubLabel
	local accountAvatarLabel
	local player = {}
	local island = {}
	local lyrics = {}
	local world = {}
	local coverflow = {}
	local login = {}
	local viewHost
	local rail

	local renderRail
	local renderMain
	local renderPlayer
	local renderIsland
	local renderHud
	local setView
	local buildHome
	local buildCharts
	local buildCloud
	local buildPlaylist
	local buildSearch
	local buildQueue
	local buildParty
	local buildArtist
	local buildSettings
	local openLyrics
	local closeLyrics
	local renderLyrics
	local updateLyrics
	local openCoverflow
	local closeCoverflow
	local renderCoverflow
	local openLogin
	local closeLogin
	local renderLogin
	local startQrLogin
	local openWorldPreview
	local closeWorldPreview
	local syncWorld
	local updateWorld
	local refreshTheme
	local openTrackMenu
	local openAddToPlaylist
	local openEQ
	local openTune
	local openImportPlaylist
	local openAddTrackPanel

	local function sourceColors(source)
		local c1 = source and source.color1 and musicParseHex(source.color1, T.SurfaceRaised) or T.SurfaceRaised
		local c2 = source and source.color2 and musicParseHex(source.color2, T.Surface) or T.Surface
		return c1, c2
	end

	local function glassPanel(parent, props, frost)
		local merged = {
			BackgroundColor3 = T.Window,
			BackgroundTransparency = 0.16,
			BorderSizePixel = 0,
		}
		if props then
			for key, value in pairs(props) do
				merged[key] = value
			end
		end
		local radius = merged.Radius or 12
		merged.Radius = nil
		local root = U.frame(parent, merged)
		U.corner(root, radius)
		U.stroke(root, T.White, 0.9, 1)
		if frost and Nerx.Frosted and Nerx.Frosted.Enabled then
			pcall(function()
				Nerx.Frosted:Register(root, { Kind = "card", Radius = radius, Opacity = 0.9 })
			end)
		end
		return root
	end

	-- Native section card: same fill / hairline / top-light recipe the menu uses
	-- for page sections, so music content sits in the UI instead of on its own plate.
	local function nativeCard(parent, props, radius)
		local merged = {
			BackgroundColor3 = T.Surface,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}
		if props then
			for key, value in pairs(props) do
				merged[key] = value
			end
		end
		local topLight = merged.TopLight
		merged.TopLight = nil
		radius = radius or merged.Radius or 10
		merged.Radius = nil
		local root = U.frame(parent, merged)
		U.corner(root, radius)
		U.stroke(root, T.Stroke, 0.65, 1)
		if topLight ~= false then
			local light = U.frame(root, {
				BackgroundColor3 = T.White,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(14, 1),
				Size = UDim2.new(1, -28, 0, 1),
				ZIndex = (merged.ZIndex or 1) + 1,
			})
			local fade = Instance.new("UIGradient")
			fade.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0.72),
				NumberSequenceKeypoint.new(1, 1),
			})
			fade.Parent = light
		end
		return root
	end

	local function sectionTitle(parent, text, order, top, canvas)
		local row = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(canvas and 16 or 0, top or 0),
			Size = UDim2.new(1, -32, 0, 16),
			LayoutOrder = order,
		})
		U.label(row, {
			Text = string.upper(text),
			Font = F.Bold,
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.45,
			Position = UDim2.fromOffset(canvas and 0 or 16, 0),
			Size = UDim2.fromScale(1, 1),
		})
		return row
	end

	-- The ESP glow sheet (9-slice, soft rounded halo) — the same technique the
	-- user's gamesense ESP uses under its boxes. Much closer to real bloom than
	-- flat circles or multiple strokes.
	local GLOW_TEXTURE = "rbxassetid://110204605000367"
	local function bloom(parent, color, transparency, padding, props)
		props = props or {}
		local pad = padding or 24
		return U.new("ImageLabel", {
			Name = "NerxBloom",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = GLOW_TEXTURE,
			ImageColor3 = color or T.Accent,
			ImageTransparency = transparency or 0.88,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(21, 21, 79, 79),
			AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
			Position = props.Position or UDim2.fromOffset(-pad, -pad),
			Size = props.Size or UDim2.new(1, pad * 2, 1, pad * 2),
			Visible = props.Visible ~= false,
			ZIndex = props.ZIndex or 0,
		}, parent)
	end

	local function coverBox(parent, size, source, radius, options)
		options = options or {}
		local c1, c2 = sourceColors(source)
		local root = U.frame(parent, {
			BackgroundColor3 = c1,
			BorderSizePixel = 0,
			Size = size,
			ClipsDescendants = true,
			ZIndex = options.ZIndex or 1,
		})
		U.corner(root, radius or 6)
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new(c1, c2)
		gradient.Rotation = 135
		gradient.Parent = root
		local placeholder = U.icon(root, options.Icon or "music-note", options.IconSize or 16,
			musicLuminance(c1) > 0.62 and T.Black or T.White, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset((options.IconSize or 16) + 4, (options.IconSize or 16) + 4),
				TextTransparency = 0.55,
				ZIndex = (options.ZIndex or 1) + 1,
			})
		local image = U.new("ImageLabel", {
			Name = "Cover",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ImageTransparency = 1,
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = (options.ZIndex or 1) + 2,
		}, root)
		local url = source and (source.coverUrl or source.avatarUrl) or ""
		local targetTransparency = options.ImageTransparency or 0
		if url ~= "" then
			M:Cover(url, function(asset)
				if asset and image.Parent then
					image.Image = asset
					U.tween(image, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = targetTransparency })
				end
			end, options.CoverSize or 300)
		end
		if options.Stroke ~= false then
			U.stroke(root, T.White, 0.88, 1)
		end
		return root, image, placeholder
	end

	local function iconButton(parent, size, iconName, callback, options)
		options = options or {}
		local root = U.frame(parent, {
			BackgroundColor3 = T.White,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(size, size),
			ZIndex = options.ZIndex or 1,
		})
		U.corner(root, size / 2)
		local icon = U.icon(root, iconName, options.IconSize or math.floor(size * 0.52), options.Color or T.Muted, {
			Size = UDim2.fromScale(1, 1),
			TextTransparency = options.Transparency or 0.15,
			ZIndex = (options.ZIndex or 1) + 1,
		})
		local input = U.inputButton(root, callback)
		U.pressFx(input, root, 0.92)
		if options.Active then
			icon.TextColor3 = T.Accent
			icon.TextTransparency = 0.02
		end
		U.connect(input.MouseEnter, function()
			U.tween(root, U.Tween.Fast, { BackgroundTransparency = 0.9 })
			U.tween(icon, U.Tween.Fast, { TextColor3 = options.Active and T.Accent or T.Text, TextTransparency = 0 })
		end)
		U.connect(input.MouseLeave, function()
			U.tween(root, U.Tween.Fast, { BackgroundTransparency = 1 })
			U.tween(icon, U.Tween.Fast, {
				TextColor3 = options.Active and T.Accent or options.Color or T.Muted,
				TextTransparency = options.Active and 0.02 or options.Transparency or 0.15,
			})
		end)
		return icon
	end

	local function textButton(parent, width, height, text, iconName, primary, callback)
		local root = U.frame(parent, {
			BackgroundColor3 = primary and T.Accent or T.Button,
			BackgroundTransparency = primary and 0 or 0.55,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(width, height),
		})
		U.corner(root, 7)
		if not primary then
			U.stroke(root, T.Stroke, 0.55, 1)
		end
		local iconSize = 11
		local textSize = 9.5
		local textWidth = U.measure(text, textSize, F.Regular).X
		local total = textWidth + (iconName and (iconSize + 5) or 0)
		local startX = math.max(7, (width - total) / 2)
		if iconName then
			U.icon(root, iconName, iconSize, primary and accentText() or T.Muted, {
				Position = UDim2.fromOffset(startX, 0),
				Size = UDim2.fromOffset(iconSize + 2, height),
				TextTransparency = primary and 0.02 or 0.15,
			})
		end
		U.label(root, {
			Text = text,
			TextSize = textSize,
			TextColor3 = primary and accentText() or T.Text,
			TextTransparency = 0.04,
			Position = UDim2.fromOffset(startX + (iconName and (iconSize + 5) or 0), 0),
			Size = UDim2.fromOffset(textWidth + 6, height),
		})
		local input = U.inputButton(root, callback)
		U.pressFx(input, root, 0.96)
		U.connect(input.MouseEnter, function()
			if primary then
				U.tween(root, U.Tween.Fast, { BackgroundTransparency = 0.08 })
			else
				U.tween(root, U.Tween.Fast, { BackgroundColor3 = T.ButtonHover, BackgroundTransparency = 0.2 })
			end
		end)
		U.connect(input.MouseLeave, function()
			if primary then
				U.tween(root, U.Tween.Fast, { BackgroundTransparency = 0 })
			else
				U.tween(root, U.Tween.Fast, { BackgroundColor3 = T.Button, BackgroundTransparency = 0.55 })
			end
		end)
		return root
	end

	local function segmented(parent, width, height, items, selected, callback)
		local root = U.frame(parent, {
			BackgroundColor3 = T.Field,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(width, height),
		})
		U.corner(root, 8)
		U.stroke(root, T.Stroke, 0.55, 1)
		local buttons = {}
		local api = {}
		local function paint()
			for index, entry in ipairs(buttons) do
				local on = entry.Value == api.Value
				entry.Button.BackgroundTransparency = on and 0 or 1
				entry.Label.TextColor3 = on and accentText() or T.Muted
				entry.Label.TextTransparency = on and 0.02 or 0.2
			end
		end
		function api:Set(value, silent)
			for _, entry in ipairs(buttons) do
				if entry.Value == value then
					self.Value = value
					break
				end
			end
			paint()
			if not silent and callback then
				callback(self.Value)
			end
		end
		local itemWidth = (width - 4) / math.max(1, #items)
		for index, item in ipairs(items) do
			local value, label
			if type(item) == "table" then
				value = item.Value ~= nil and item.Value or item[1]
				label = item.Label ~= nil and item.Label or item[2] or tostring(value)
			else
				value = item
				label = tostring(item)
			end
			local button = U.frame(root, {
				BackgroundColor3 = T.Accent,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(2 + (index - 1) * itemWidth, 2),
				Size = UDim2.fromOffset(itemWidth, height - 4),
			})
			U.corner(button, 6)
			local text = U.label(button, {
				Text = label,
				TextSize = 9,
				TextColor3 = T.Muted,
				TextTransparency = 0.2,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 1),
			})
			local input = U.inputButton(button, function()
				api:Set(value)
			end)
			U.connect(input.MouseEnter, function()
				if api.Value ~= value then
					button.BackgroundTransparency = 0.94
					text.TextColor3 = T.Text
					text.TextTransparency = 0.05
				end
			end)
			U.connect(input.MouseLeave, function()
				if api.Value ~= value then
					button.BackgroundTransparency = 1
					text.TextColor3 = T.Muted
					text.TextTransparency = 0.2
				end
			end)
			buttons[#buttons + 1] = { Value = value, Button = button, Label = text }
		end
		api.Value = selected or (items[1] and (items[1].Value or items[1][1]))
		api.Root = root
		paint()
		return api
	end

	local function createSlider(parent, size, initial, onChanged, options)
		options = options or {}
		local value = math.clamp(tonumber(initial) or 0, 0, 1)
		local trackHeight = options.TrackHeight or 3
		local root = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = size,
		})
		local base = U.frame(root, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = options.BaseColor or T.Track,
			BackgroundTransparency = options.BaseTransparency or 0.5,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(1, 0, 0, trackHeight),
		})
		U.corner(base, math.ceil(trackHeight / 2))
		local fill = U.frame(root, {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = options.FillColor or T.Accent,
			BackgroundTransparency = options.FillTransparency or 0,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(value, 0, 0, trackHeight),
		})
		U.corner(fill, math.ceil(trackHeight / 2))
		local knobSize = options.KnobSize or 8
		local knob = U.frame(root, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = T.White,
			BorderSizePixel = 0,
			Position = UDim2.new(value, 0, 0.5, 0),
			Size = UDim2.fromOffset(knobSize, knobSize),
			Visible = options.KnobVisible == true,
			ZIndex = 3,
		})
		U.corner(knob, knobSize / 2)
		local api = { Root = root }
		function api:Set(newValue, silent)
			value = math.clamp(tonumber(newValue) or 0, 0, 1)
			fill.Size = UDim2.new(value, 0, 0, trackHeight)
			knob.Position = UDim2.new(value, 0, 0.5, 0)
		end
		function api:GetValue()
			return value
		end
		local holding = false
		local function applyFromInput(input)
			local position = root.AbsolutePosition
			local size2 = root.AbsoluteSize
			if size2.X <= 0 then
				return
			end
			local ratio = math.clamp((input.Position.X - position.X) / size2.X, 0, 1)
			api:Set(ratio)
			if onChanged then
				onChanged(ratio, true)
			end
		end
		local hit = U.inputButton(root, function() end)
		hit.ZIndex = 10
		U.connect(hit.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				holding = true
				applyFromInput(input)
			end
		end)
		U.connect(UserInputService.InputChanged, function(input)
			if not root.Parent then
				holding = false
				return
			end
			if holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				applyFromInput(input)
			end
		end)
		U.connect(UserInputService.InputEnded, function(input)
			if holding and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				holding = false
				knob.Visible = options.KnobVisible == true
				if onChanged then
					onChanged(value, false)
				end
			end
		end)
		U.connect(root.MouseEnter, function()
			knob.Visible = true
		end)
		U.connect(root.MouseLeave, function()
			if not holding then
				knob.Visible = options.KnobVisible == true
			end
		end)
		return api
	end

	local function formatCount(value)
		value = tonumber(value) or 0
		if value >= 100000000 then
			return string.format("%.1f亿", value / 100000000)
		elseif value >= 10000 then
			return string.format("%.1f万", value / 10000)
		end
		return tostring(math.floor(value))
	end

	local function currentPlaylist()
		if state.view.kind == "playlist" then
			return M:GetPlaylist(state.view.id)
		end
		return nil
	end

	local function currentIds()
		if state.view.kind == "liked" then
			return M:LikedIds()
		elseif state.view.kind == "playlist" then
			return M:PlaylistIds(currentPlaylist())
		elseif state.view.kind == "search" then
			if state.searchTab == "artists" or state.searchTab == "playlists" then
				return {}
			end
			local ids = {}
			for _, id in ipairs(M.SearchIds or {}) do
				if M.Tracks[id] then
					ids[#ids + 1] = id
				end
			end
			return ids
		end
		return {}
	end

	local function viewTitle()
		if state.view.kind == "home" then
			return "主页"
		elseif state.view.kind == "charts" then
			return "排行榜"
		elseif state.view.kind == "cloud" then
			return "云盘"
		elseif state.view.kind == "liked" then
			return "我喜欢的音乐"
		elseif state.view.kind == "settings" then
			return "设置"
		elseif state.view.kind == "search" then
			return "搜索结果"
		elseif state.view.kind == "queue" then
			return "正在播放"
		elseif state.view.kind == "party" then
			return "一起听"
		elseif state.view.kind == "artist" then
			local artist = M:GetArtist(state.view.id)
			return artist and artist.name or "歌手"
		end
		local playlist = currentPlaylist()
		return playlist and playlist.name or "音乐"
	end

	local function pageHeader(parent, eyebrow, title, subtitle)
		local head = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 68),
		})
		local dot = U.frame(head, {
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(18, 20),
			Size = UDim2.fromOffset(5, 5),
		})
		U.corner(dot, 3)
		U.label(head, {
			Text = eyebrow,
			Font = F.Bold,
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(30, 13),
			Size = UDim2.new(1, -48, 0, 12),
		})
		U.label(head, {
			Text = title,
			Font = F.Bold,
			TextSize = 23,
			TextColor3 = T.Text,
			TextTransparency = 0.02,
			Position = UDim2.fromOffset(18, 25),
			Size = UDim2.new(1, -36, 0, 30),
		})
		U.label(head, {
			Text = subtitle or "",
			TextSize = 9,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(20, 52),
			Size = UDim2.new(1, -40, 0, 12),
		})
		return head
	end

	local function newScroll(parent, top, bottom)
		local scroll = U.new("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.fromOffset(0, top),
			Size = UDim2.new(1, 0, 1, -(top + (bottom or 0))),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = T.Stroke,
			ScrollBarImageTransparency = 0.35,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.fromOffset(0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ElasticBehavior = Enum.ElasticBehavior.Never,
		}, parent)
		return scroll
	end

	-- -----------------------------------------------------------------------------------
	-- Shell
	-- -----------------------------------------------------------------------------------
	local shell = U.frame(canvas, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
	})

	-- The preview's dark glass stage: without it the bright in-game wallpaper
	-- bleeds through the cards and the page stops looking like the mockup.
	local stage = U.frame(shell, {
		Name = "NerxMusicStage",
		BackgroundColor3 = T.Window,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 0,
	})
	U.corner(stage, 18)
	U.stroke(stage, T.Stroke, 0.7, 1)
	local stageGradient = Instance.new("UIGradient")
	stageGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, T.Window:Lerp(T.Accent, 0.10)),
		ColorSequenceKeypoint.new(0.52, T.Main:Lerp(T.Accent, 0.03)),
		ColorSequenceKeypoint.new(1, T.Sidebar),
	})
	stageGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.55, 0.08),
		NumberSequenceKeypoint.new(1, 0.18),
	})
	stageGradient.Rotation = 145
	stageGradient.Parent = stage
	local function stageGlow(size, px, py, alpha)
		local glow = U.frame(stage, {
			BackgroundColor3 = T.Accent,
			BackgroundTransparency = alpha,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(px, 0, py, 0),
			Size = UDim2.fromOffset(size, size),
			ZIndex = 0,
		})
		U.corner(glow, 999)
	end
	stageGlow(SHELL_W * 0.58, 0.04, -0.1, 0.93)
	stageGlow(SHELL_W * 0.46, 0.99, 0.1, 0.95)
	stageGlow(SHELL_W * 0.5, 0.92, -0.04, 0.955)
	stageGlow(SHELL_W * 0.52, 0.6, 1.06, 0.955)
	U.frame(stage, {
		BackgroundColor3 = T.White,
		BackgroundTransparency = 0.74,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 22, 0, 0),
		Size = UDim2.new(1, -44, 0, 1),
		ZIndex = 1,
	})

	local ambient = U.frame(shell, {
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.975,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.42, 0, 0.18, 0),
		Size = UDim2.fromOffset(math.max(320, WORK_W * 0.7), math.max(220, MAIN_H * 0.5)),
	})
	U.corner(ambient, 999)

	rail = glassPanel(shell, {
		Position = UDim2.fromOffset(PAD, PAD),
		Size = UDim2.fromOffset(RAIL_W, SHELL_H - PAD * 2),
		BackgroundColor3 = T.Surface,
		BackgroundTransparency = 0.35,
		Radius = 14,
	}, false)
	rail.Position = UDim2.fromOffset(PAD, PAD)

	local brand = U.frame(rail, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 48),
		Size = UDim2.new(1, -24, 0, 28),
	})
	local mark = U.frame(brand, {
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(24, 24),
	})
	U.corner(mark, 7)
	U.label(mark, {
		Text = "N",
		Font = F.Bold,
		TextSize = 11,
		TextColor3 = accentText(),
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	U.label(brand, {
		Text = "Nerx Music",
		Font = F.Bold,
		TextSize = 11,
		TextColor3 = T.Text,
		TextTransparency = 0.05,
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -32, 0, 14),
	})
	U.label(brand, {
		Text = "网易云音乐 · v" .. tostring(Nerx.Version),
		TextSize = 7.5,
		TextColor3 = T.Muted,
		TextTransparency = 0.35,
		Position = UDim2.fromOffset(32, 14),
		Size = UDim2.new(1, -32, 0, 12),
	})

	local searchRoot = U.frame(rail, {
		BackgroundColor3 = T.FieldDeep,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(1, -20, 0, 30),
	})
	U.corner(searchRoot, 8)
	local searchStroke = U.stroke(searchRoot, T.Stroke, 0.7, 1)
	U.icon(searchRoot, "magnifying-glass", 11, T.Faint, {
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.fromOffset(13, 30),
		TextTransparency = 0.2,
	})
	local searchBox = U.new("TextBox", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = F.Regular,
		Text = "",
		PlaceholderText = "搜索网易云歌曲、歌手...",
		PlaceholderColor3 = T.Faint,
		TextColor3 = T.Text,
		TextSize = 9.5,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(26, 0),
		Size = UDim2.new(1, -34, 1, 0),
	}, searchRoot)
	U.connect(searchBox.Focused, function()
		U.tween(searchRoot, U.Tween.Fast, { BackgroundColor3 = T.FieldHover })
		searchStroke.Transparency = 0.35
	end)
	U.connect(searchBox.FocusLost, function()
		U.tween(searchRoot, U.Tween.Fast, { BackgroundColor3 = T.FieldDeep })
		searchStroke.Transparency = 0.7
	end)

	railScroll = U.new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(8, 84),
		Size = UDim2.new(1, -16, 1, -140),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = T.Stroke,
		ScrollBarImageTransparency = 0.5,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
	}, rail)
	U.list(railScroll, 1)

	local account = glassPanel(rail, {
		BackgroundColor3 = T.White,
		BackgroundTransparency = 0.955,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -10),
		Size = UDim2.new(1, -20, 0, 44),
		Radius = 8,
	})
	local avatar = U.frame(account, {
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.fromOffset(28, 28),
	})
	U.corner(avatar, 999)
	accountAvatarLabel = U.label(avatar, {
		Text = "N",
		Font = F.Bold,
		TextSize = 10,
		TextColor3 = accentText(),
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	accountNameLabel = U.label(account, {
		Text = "Nerx Music",
		Font = F.Bold,
		TextSize = 9.5,
		TextColor3 = T.Text,
		TextTransparency = 0.08,
		Position = UDim2.fromOffset(42, 7),
		Size = UDim2.new(1, -50, 0, 14),
	})
	accountSubLabel = U.label(account, {
		Text = "网易云音乐",
		TextSize = 7.5,
		TextColor3 = T.Muted,
		TextTransparency = 0.4,
		Position = UDim2.fromOffset(42, 21),
		Size = UDim2.new(1, -50, 0, 12),
	})
	local accountInput = U.inputButton(account, function()
		openLogin()
	end)

	local workspacePanel = U.frame(shell, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(RAIL_W + GAP + PAD, PAD),
		Size = UDim2.fromOffset(WORK_W, SHELL_H - PAD * 2),
	})

	viewHost = U.canvas(workspacePanel, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -(PLAYER_H + 12)),
		ClipsDescendants = true,
	})

	-- -----------------------------------------------------------------------------------
	-- Player bar
	-- -----------------------------------------------------------------------------------
	local playerBar = nativeCard(workspacePanel, {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 6, 1, -4),
		Size = UDim2.new(1, -12, 0, PLAYER_H),
		BackgroundTransparency = 0.24,
		ZIndex = 20,
	}, 12)
	player.Root = playerBar
	bloom(workspacePanel, T.Accent, 0.93, 0, {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, -10, 1, 22),
		Size = UDim2.new(1, 20, 0, PLAYER_H + 36),
		ZIndex = 19,
	})
	U.frame(playerBar, {
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 26, 0, 0),
		Size = UDim2.new(1, -52, 0, 1),
		ZIndex = 21,
	})

	local coverHolder = U.frame(playerBar, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, (PLAYER_H - 40) / 2 - 4),
		Size = UDim2.fromOffset(36, 36),
	})
	player.Cover = coverHolder
	player.CoverHolder = coverHolder
	player.CoverImage, player.CoverArt, player.CoverIcon = coverBox(coverHolder, UDim2.fromScale(1, 1), nil, 7, { IconSize = 14 })
	local coverInput = U.inputButton(coverHolder, function()
		openLyrics("page")
	end)
	coverInput.ZIndex = 10

	player.Title = U.label(playerBar, {
		Text = "未播放",
		Font = F.Bold,
		TextSize = 10,
		TextColor3 = T.Text,
		TextTransparency = 0.06,
		Position = UDim2.fromOffset(55, 13),
		Size = UDim2.fromOffset(math.clamp(WORK_W * 0.22, 100, 150), 14),
	})
	player.Artist = U.label(playerBar, {
		Text = "选择一首歌曲开始",
		TextSize = 8,
		TextColor3 = T.Muted,
		TextTransparency = 0.4,
		Position = UDim2.fromOffset(55, 27),
		Size = UDim2.fromOffset(math.clamp(WORK_W * 0.22, 100, 150), 12),
	})

	local controls = U.frame(playerBar, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, -10, 0, 10),
		Size = UDim2.fromOffset(158, 30),
	})
	player.Controls = controls
	local controlX = 0
	player.ShuffleIcon = iconButton(controls, 18, "two-arrows-switch-right", function()
		local value = not M.Settings.shuffle
		M:SetShuffle(value)
		notify("音乐", value and "乱序播放：开" or "乱序播放：关", "two-arrows-switch-right", value and T.Accent or T.Muted)
		renderPlayer()
	end)
	player.ShuffleIcon.Parent.Position = UDim2.fromOffset(controlX, 6)
	controlX = controlX + 22
	player.PrevIcon = iconButton(controls, 22, "skip-previous-large", function()
		M:Prev()
	end)
	player.PrevIcon.Parent.Position = UDim2.fromOffset(controlX, 4)
	controlX = controlX + 26
	local playButton = U.frame(controls, {
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(controlX, 1),
		Size = UDim2.fromOffset(28, 28),
	})
	U.corner(playButton, 14)
	player.PlayIcon = U.icon(playButton, "play-small", 13, accentText(), {
		Size = UDim2.fromScale(1, 1),
		TextTransparency = 0.02,
	})
	local playInput = U.inputButton(playButton, function()
		if not M.CurrentId then
			local ids = currentIds()
			if #ids == 0 then
				ids = M:OrderedIds()
			end
			if #ids > 0 then
				M:Play(ids[1], ids)
			end
		else
			M:Toggle()
		end
	end)
	U.pressFx(playInput, playButton, 0.92)
	U.connect(playInput.MouseEnter, function()
		U.tween(playButton, U.Tween.Fast, { BackgroundTransparency = 0.12 })
	end)
	U.connect(playInput.MouseLeave, function()
		U.tween(playButton, U.Tween.Fast, { BackgroundTransparency = 0 })
	end)
	controlX = controlX + 32
	player.NextIcon = iconButton(controls, 22, "skip-next-large", function()
		M:Next(true)
	end)
	player.NextIcon.Parent.Position = UDim2.fromOffset(controlX, 4)
	controlX = controlX + 26
	player.RepeatIcon = iconButton(controls, 18, "two-arrows-loop-clockwise", function()
		local mode = M.Settings.mode
		if mode == "order" then
			M:SetMode("all")
			notify("音乐", "列表循环", "two-arrows-loop-clockwise", T.Accent)
		elseif mode == "all" then
			M:SetMode("one")
			notify("音乐", "单曲循环", "two-arrows-loop-clockwise-1", T.Accent)
		else
			M:SetMode("order")
			notify("音乐", "顺序播放", "two-arrows-loop-clockwise", T.Muted)
		end
		renderPlayer()
	end)
	player.RepeatIcon.Parent.Position = UDim2.fromOffset(controlX, 6)

	local rightCluster = U.frame(playerBar, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 12),
		Size = UDim2.fromOffset(190, 26),
	})
	local rightX = 0
	player.LikeIcon = iconButton(rightCluster, 20, "heart", function()
		if M.CurrentId then
			local _, liked = M:ToggleLike(M.CurrentId)
			notify("音乐", liked and "已添加到我喜欢的音乐" or "已取消喜欢", "heart", liked and T.Pink or T.Muted, 0.5)
			renderPlayer()
		end
	end)
	player.LikeIcon.Parent.Position = UDim2.fromOffset(rightX, 3)
	rightX = rightX + 22
	player.LyricsIcon = iconButton(rightCluster, 20, "document-list-heart", function()
		openLyrics("page")
	end)
	player.LyricsIcon.Parent.Position = UDim2.fromOffset(rightX, 3)
	rightX = rightX + 22
	player.QueueIcon = iconButton(rightCluster, 20, "rectangle-list", function()
		setView({ kind = "queue" })
	end)
	player.QueueIcon.Parent.Position = UDim2.fromOffset(rightX, 3)
	rightX = rightX + 22
	local qualityLabel = U.label(rightCluster, {
		Text = "无损",
		TextSize = 7.5,
		TextColor3 = T.Muted,
		TextTransparency = 0.4,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(rightX, 0),
		Size = UDim2.fromOffset(34, 26),
	})
	player.QualityLabel = qualityLabel
	local qualityInput = U.inputButton(rightCluster, function(anchor)
		local items = {}
		for _, entry in ipairs(M.Qualities) do
			items[#items + 1] = {
				Text = entry.name .. (M.Settings.quality == entry.key and "  ·  当前" or ""),
				Callback = function()
					M.Settings.quality = entry.key
					M:Save()
					M:_Emit("settings")
					renderPlayer()
					notify("网易云", "音质：" .. entry.name, "music-note", T.Accent)
				end,
			}
		end
		UIHelpers.ContextMenu(qualityInput, items)
	end)
	qualityInput.Position = UDim2.fromOffset(rightX, 0)
	qualityInput.Size = UDim2.fromOffset(34, 26)
	rightX = rightX + 36
	local volumeWrap = U.frame(rightCluster, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(rightX, 7),
		Size = UDim2.fromOffset(48, 14),
	})
	U.icon(volumeWrap, "speaker", 10, T.Muted, {
		Position = UDim2.fromOffset(0, 1),
		Size = UDim2.fromOffset(11, 12),
		TextTransparency = 0.35,
	})
	player.VolumeSlider = createSlider(volumeWrap, UDim2.new(1, -15, 0, 12), M.Settings.volume, function(value, dragging)
		state.volumeDragging = dragging
		M:SetVolume(value, dragging)
	end, {
		FillColor = T.Accent,
		BaseColor = T.Track,
		BaseTransparency = 0.45,
		TrackHeight = 3,
		KnobSize = 7,
	})
	player.VolumeSlider.Root.Position = UDim2.fromOffset(14, 0)
	rightX = rightX + 50
	local moreIcon
	moreIcon = iconButton(rightCluster, 20, "three-dots-horizontal", function()
		UIHelpers.ContextMenu(moreIcon.Parent, {
			{ Text = "歌词页", Callback = function() openLyrics("page") end },
			{ Text = "沉浸歌词", Callback = function() openLyrics("immersive") end },
			{ Text = "世界 3D 歌词预览", Callback = function() openWorldPreview() end },
			{ Text = "均衡器", Callback = function() openEQ(moreIcon.Parent) end },
			{ Text = "速度 / 音高", Callback = function() openTune(moreIcon.Parent) end },
			{ Text = "添加到歌单", Callback = function() openAddToPlaylist(moreIcon.Parent, M.CurrentId) end },
			{ Text = M.Settings.cookie ~= "" and ("账号：" .. (M.Settings.nickname ~= "" and M.Settings.nickname or "已登录")) or "登录网易云", Callback = function() openLogin() end },
		})
	end)
	moreIcon.Parent.Position = UDim2.fromOffset(rightX, 3)

	local progressWrap = U.frame(playerBar, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, PLAYER_H - 15),
		Size = UDim2.new(1, -24, 0, 12),
	})
	player.CurrentTime = U.label(progressWrap, {
		Text = "00:00",
		Font = F.Mono,
		TextSize = 7.5,
		TextColor3 = T.Muted,
		TextTransparency = 0.35,
		Size = UDim2.fromOffset(30, 12),
	})
	player.RemainingTime = U.label(progressWrap, {
		Text = "-00:00",
		Font = F.Mono,
		TextSize = 7.5,
		TextColor3 = T.Muted,
		TextTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(1, -32, 0, 0),
		Size = UDim2.fromOffset(32, 12),
	})
	player.Progress = createSlider(progressWrap, UDim2.new(1, -72, 0, 10), 0, function(ratio, dragging)
		state.progressDragging = dragging
		state.progressRatio = ratio
		if not dragging then
			M:Seek(ratio)
			state.progressDragging = false
		end
		renderPlayer()
	end, {
		FillColor = T.Accent,
		BaseColor = T.Track,
		BaseTransparency = 0.5,
		TrackHeight = 3,
		KnobSize = 7,
	})
	player.Progress.Root.Position = UDim2.fromOffset(36, 0)

	-- -----------------------------------------------------------------------------------
	-- Dynamic island
	-- -----------------------------------------------------------------------------------
	island.Root = glassPanel(workspacePanel, {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = T.SurfaceRaised,
		BackgroundTransparency = 0.12,
		Position = UDim2.new(0.5, 0, 0, 4),
		Size = UDim2.fromOffset(260, 34),
		Radius = 17,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 60,
	}, false)
	island.CoverHolder = U.frame(island.Root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(5, 4),
		Size = UDim2.fromOffset(26, 26),
		ZIndex = 61,
	})
	island.Cover = coverBox(island.CoverHolder, UDim2.fromScale(1, 1), nil, 8, { ZIndex = 61, IconSize = 11 })
	island.Title = U.label(island.Root, {
		Text = "未播放",
		Font = F.Bold,
		TextSize = 9.5,
		TextColor3 = T.Text,
		Position = UDim2.fromOffset(38, 5),
		Size = UDim2.fromOffset(150, 13),
		ZIndex = 62,
	})
	island.Artist = U.label(island.Root, {
		Text = "网易云音乐",
		TextSize = 7.5,
		TextColor3 = T.Muted,
		TextTransparency = 0.25,
		Position = UDim2.fromOffset(38, 18),
		Size = UDim2.fromOffset(150, 11),
		ZIndex = 62,
	})
	island.Bars = U.frame(island.Root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(22, 14),
		ZIndex = 62,
	})
	for index = 1, 3 do
		local bar = U.frame(island.Bars, {
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, (index - 1) * 5, 1, 0),
			Size = UDim2.fromOffset(2, 4 + index * 2),
			ZIndex = 63,
		})
		U.corner(bar, 1)
		local info = TweenInfo.new(0.8 + index * 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		TweenService:Create(bar, info, { Size = UDim2.fromOffset(2, 12 - index) }):Play()
	end
	local islandInput = U.inputButton(island.Root, function()
		openLyrics("page")
	end)
	islandInput.ZIndex = 70

	-- -----------------------------------------------------------------------------------
	-- Rail
	-- -----------------------------------------------------------------------------------
	local function railSection(parent, text, order, onAdd)
		local row = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 22),
			LayoutOrder = order,
		})
		U.label(row, {
			Text = string.upper(text),
			Font = F.Bold,
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.45,
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -32, 0, 22),
		})
		if onAdd then
			local add = U.frame(row, {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = T.White,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -2, 0.5, 0),
				Size = UDim2.fromOffset(18, 18),
			})
			U.corner(add, 5)
			U.icon(add, "plus-small", 10, T.Faint, {
				Size = UDim2.fromScale(1, 1),
				TextTransparency = 0.1,
			})
			local input = U.inputButton(add, function()
				onAdd(add)
			end)
			U.connect(input.MouseEnter, function()
				U.tween(add, U.Tween.Fast, { BackgroundTransparency = 0.92 })
			end)
			U.connect(input.MouseLeave, function()
				U.tween(add, U.Tween.Fast, { BackgroundTransparency = 1 })
			end)
		end
		return row
	end

	local function railItem(order, iconName, text, count, active, callback, rightClick, coverSource)
		local item = U.frame(railScroll, {
			BackgroundColor3 = active and T.Accent or T.White,
			BackgroundTransparency = active and 0.9 or 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = order,
		})
		U.corner(item, 6)
		if active then
			local bar = U.frame(item, {
				BackgroundColor3 = T.Accent,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 6),
				Size = UDim2.fromOffset(2, 13),
			})
			U.corner(bar, 1)
		end
		local shift = 8
		if coverSource then
			local thumb = U.frame(item, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(8, 4),
				Size = UDim2.fromOffset(17, 17),
			})
			coverBox(thumb, UDim2.fromScale(1, 1), coverSource, 4, { IconSize = 8, Stroke = false })
			shift = 29
		else
			U.icon(item, iconName or "music-note", 11, active and T.Accent or T.Muted, {
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.fromOffset(12, 26),
				TextTransparency = active and 0 or 0.2,
			})
			shift = 28
		end
		U.label(item, {
			Text = text,
			TextSize = 10,
			TextColor3 = active and T.Text or T.Muted,
			TextTransparency = active and 0.02 or 0.15,
			Position = UDim2.fromOffset(shift, 0),
			Size = UDim2.new(1, -(shift + (count and 34 or 10)), 1, 0),
		})
		if count then
			U.label(item, {
				Text = tostring(count),
				TextSize = 7.5,
				TextColor3 = active and T.Accent or T.Muted,
				TextTransparency = active and 0.05 or 0.4,
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.new(1, -30, 0, 0),
				Size = UDim2.fromOffset(24, 26),
			})
		end
		local input = U.inputButton(item, function()
			if callback then
				callback(item)
			end
		end)
		U.connect(input.MouseEnter, function()
			if not active then
				U.tween(item, U.Tween.Fast, { BackgroundTransparency = 0.94 })
			end
		end)
		U.connect(input.MouseLeave, function()
			if not active then
				U.tween(item, U.Tween.Fast, { BackgroundTransparency = 1 })
			end
		end)
		if rightClick then
			U.connect(input.InputBegan, function(inputObject)
				if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
					rightClick(item)
				end
			end)
		end
		return item
	end

	renderRail = function()
		if not railScroll or not railScroll.Parent then
			return
		end
		for _, child in ipairs(railScroll:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
		local order = 0
		local function nextOrder()
			order = order + 1
			return order
		end
		local nickname = tostring(M.Settings.nickname or "")
		if accountNameLabel then
			accountNameLabel.Text = nickname ~= "" and nickname or "Nerx Music"
		end
		if accountSubLabel then
			accountSubLabel.Text = nickname ~= ""
				and "网易云音乐 · 已登录"
				or (M.Settings.cookie ~= "" and "网易云音乐 · Cookie" or "网易云音乐")
		end
		if accountAvatarLabel then
			accountAvatarLabel.Text = nickname ~= "" and string.upper(string.sub(nickname, 1, 1)) or "N"
		end

		railSection(railScroll, "发现", nextOrder())
		railItem(nextOrder(), "house", "主页", nil, state.view.kind == "home", function()
			setView({ kind = "home" })
		end)
		railItem(nextOrder(), "chart-line", "排行榜", nil, state.view.kind == "charts", function()
			setView({ kind = "charts" })
		end)
		railItem(nextOrder(), "music-note", "正在播放", nil, state.view.kind == "queue", function()
			setView({ kind = "queue" })
		end)
		railItem(nextOrder(), "microphone", "一起听", nil, state.view.kind == "party", function()
			setView({ kind = "party" })
		end)
		railItem(nextOrder(), "cloud", "云盘", nil, state.view.kind == "cloud", function()
			setView({ kind = "cloud" })
		end)

		railSection(railScroll, "我的歌单", nextOrder(), function(anchor)
			UIHelpers.InputPrompt(anchor, {
				Title = "新建歌单",
				Placeholder = "歌单名称，例如：深夜循环",
				Submit = "创建",
				Attribute = "NerxMusic",
				OnSubmit = function(name)
					local playlist = M:AddPlaylist(name)
					if playlist then
						setView({ kind = "playlist", id = playlist.id })
						notify("音乐", "已创建歌单「" .. playlist.name .. "」", "list-bulleted", T.Green)
					end
				end,
			})
		end)
		railItem(nextOrder(), "heart", "我喜欢的音乐", #M:LikedIds(), state.view.kind == "liked", function()
			setView({ kind = "liked" })
		end)

		for _, playlist in ipairs(M.Playlists or {}) do
			local entry = playlist
			if entry.kind == "custom" or entry.kind == "saved" then
				local count = #M:PlaylistIds(entry)
				railItem(nextOrder(), "list-bulleted", entry.name, count, state.view.kind == "playlist" and state.view.id == entry.id, function()
					setView({ kind = "playlist", id = entry.id })
				end, function(anchor)
					UIHelpers.ContextMenu(anchor, {
						{
							Text = "重命名",
							Callback = function()
								UIHelpers.InputPrompt(anchor, {
									Title = "重命名歌单",
									Initial = entry.name,
									Submit = "保存",
									Attribute = "NerxMusic",
									OnSubmit = function(name)
										if M:RenamePlaylist(entry.id, name) then
											notify("音乐", "已重命名为「" .. name .. "」", "pencil", T.Green)
										end
									end,
								})
							end,
						},
						{
							Text = "删除歌单",
							Color = T.Red,
							Callback = function()
								if M:DeletePlaylist(entry.id) then
									if state.view.kind == "playlist" and state.view.id == entry.id then
										state.view = { kind = "home" }
									end
									notify("音乐", "已删除歌单", "trash-can", T.Muted)
								end
							end,
						},
					})
				end)
			end
		end

		local accountSeen = {}
		if #M.MyPlaylists > 0 then
			railSection(railScroll, "我的网易云", nextOrder())
			for _, entry in ipairs(M.MyPlaylists) do
				accountSeen[entry.netId] = true
				local id = "ne_pl_" .. entry.netId
				railItem(nextOrder(), "cloud", entry.name, tonumber(entry.count) or 0, state.view.kind == "playlist" and state.view.id == id, function()
					local playlist = M:OpenNeteasePlaylist(entry.netId, entry)
					if playlist then
						setView({ kind = "playlist", id = playlist.id })
					end
				end, nil, entry)
			end
		end

		local netList = {}
		for _, entry in ipairs(M.Playlists or {}) do
			if entry.kind == "netease" and not accountSeen[entry.netId] then
				netList[#netList + 1] = entry
			end
		end
		if #netList > 0 then
			railSection(railScroll, "网易云歌单", nextOrder())
			for _, entry in ipairs(netList) do
				local count = #M:PlaylistIds(entry)
				if count == 0 then
					count = tonumber(entry.count) or 0
				end
				railItem(nextOrder(), "cloud", entry.name, count, state.view.kind == "playlist" and state.view.id == entry.id, function()
					M:OpenNeteasePlaylist(entry.netId, entry)
					setView({ kind = "playlist", id = entry.id })
				end, function(anchor)
					UIHelpers.ContextMenu(anchor, {
						{
							Text = "刷新歌单",
							Callback = function()
								M:OpenNeteasePlaylist(entry.netId, entry, nil, true)
								notify("网易云", "正在刷新歌单", "arrow-spin-clockwise", T.Accent)
							end,
						},
						{
							Text = "复制歌单 ID",
							Callback = function()
								Nerx.Storage:Copy(entry.netId)
								notify("网易云", "歌单 ID 已复制", "floppy-disk", T.Green)
							end,
						},
						{
							Text = "从侧栏移除",
							Color = T.Red,
							Callback = function()
								M:DeletePlaylist(entry.id)
								notify("网易云", "已从侧栏移除", "trash-can", T.Muted)
							end,
						},
					})
				end, entry)
			end
		end

		railSection(railScroll, "系统", nextOrder())
		railItem(nextOrder(), "gear", "设置", nil, state.view.kind == "settings", function()
			setView({ kind = "settings" })
		end)
		railItem(nextOrder(), "cloud-arrow-down", "导入歌单", nil, false, function(anchor)
			openImportPlaylist(anchor)
		end)
	end

	setView = function(view)
		state.view = view
		if view.kind ~= "search" then
			state.query = ""
			if searchBox.Text ~= "" then
				state.suppressSearch = true
				searchBox.Text = ""
				state.suppressSearch = false
			end
		end
		if closeCoverflow then
			closeCoverflow()
		end
		renderRail()
		renderMain()
	end

	local function openPlaylist(id)
		local playlist = M:GetPlaylist(id)
		if playlist then
			if playlist.kind == "netease" and not playlist.loaded then
				M:OpenNeteasePlaylist(playlist.netId, playlist)
			end
			setView({ kind = "playlist", id = id })
		end
	end

	local function openArtist(netId, meta)
		netId = tostring(netId or "")
		if not netId:match("^%d+$") then
			return
		end
		M:LoadArtist(netId, meta)
		setView({ kind = "artist", id = netId, name = meta and meta.name or nil })
	end

	openImportPlaylist = function(anchor)
		UIHelpers.InputPrompt(anchor, {
			Title = "导入网易云歌单",
			Placeholder = "歌单 ID 或 https://music.163.com/playlist?id=...",
			Submit = "导入",
			Attribute = "NerxMusic",
			OnSubmit = function(text)
				local netId = string.match(text, "id=(%d+)")
					or string.match(text, "/playlist/(%d+)")
					or string.match(text, "^%s*(%d+)%s*$")
				if not netId then
					notify("网易云", "无法识别歌单 ID", "triangle-exclamation", T.Amber)
					return
				end
				local playlist = M:OpenNeteasePlaylist(netId, { name = "网易云歌单 " .. netId })
				if playlist then
					setView({ kind = "playlist", id = playlist.id })
					notify("网易云", "正在从网易云加载歌单...", "cloud-arrow-down", T.Accent)
				end
			end,
		})
	end

	renderMain = function()
		if not viewHost or not viewHost.Parent then
			return
		end
		local key = tostring(state.view.kind) .. ":" .. tostring(state.view.id or state.query or "")
		local animate = state.lastViewKey ~= key
		state.lastViewKey = key
		viewHost:ClearAllChildren()
		if animate then
			if M.Settings.motion == false then
				U.setGroupTransparency(viewHost, 0)
			else
				U.setGroupTransparency(viewHost, 0.35)
				U.tween(viewHost, U.Tween.Fast, { GroupTransparency = 0 })
			end
		end
		if state.view.kind == "home" then
			buildHome(viewHost)
		elseif state.view.kind == "charts" then
			buildCharts(viewHost)
		elseif state.view.kind == "cloud" then
			buildCloud(viewHost)
		elseif state.view.kind == "settings" then
			buildSettings(viewHost)
		elseif state.view.kind == "queue" then
			buildQueue(viewHost)
		elseif state.view.kind == "party" then
			buildParty(viewHost)
		elseif state.view.kind == "artist" then
			buildArtist(viewHost)
		elseif state.view.kind == "search" then
			buildSearch(viewHost)
		else
			buildPlaylist(viewHost)
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Shared track list
	-- -----------------------------------------------------------------------------------
	local function paintTrackRow(row, playing)
		row.Root.BackgroundColor3 = playing and T.Accent or T.White
		row.Root.BackgroundTransparency = playing and 0.88 or row.BaseTransparency
		row.Title.TextColor3 = playing and T.Text or T.Text
		row.Mark.Visible = playing
		if row.Artist then
			row.Artist.TextColor3 = playing and T.Text or T.Muted
			row.Artist.TextTransparency = playing and 0.15 or 0.2
		end
		if row.Album then
			row.Album.TextColor3 = playing and T.Text or T.Muted
			row.Album.TextTransparency = playing and 0.3 or 0.3
		end
		if row.Duration then
			row.Duration.TextColor3 = playing and T.Text or T.Muted
			row.Duration.TextTransparency = playing and 0.3 or 0.28
		end
	end

	local function trackTableHead(parent, order)
		local head = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 22),
			LayoutOrder = order or 0,
		})
		U.label(head, {
			Text = "#",
			Font = F.Bold,
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.45,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.fromOffset(24, 22),
		})
		U.label(head, {
			Text = "TITLE",
			Font = F.Bold,
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.45,
			Position = UDim2.fromOffset(64, 0),
			Size = UDim2.new(1, -(156 + ALBUM_W), 0, 22),
		})
		U.label(head, {
			Text = "ALBUM",
			Font = F.Bold,
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.45,
			Position = UDim2.new(1, -(84 + ALBUM_W), 0, 0),
			Size = UDim2.fromOffset(ALBUM_W, 22),
		})
		U.label(head, {
			Text = "TIME",
			Font = F.Bold,
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.45,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -84, 0, 0),
			Size = UDim2.fromOffset(40, 22),
		})
		return head
	end

	local function createTrackRow(parent, index, track, ids, options)
		options = options or {}
		local edge = options.OnRemove and 24 or 0
		local row = U.frame(parent, {
			BackgroundColor3 = T.White,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, ROW_H),
			LayoutOrder = index,
		})
		U.corner(row, 8)
		local mark = U.frame(row, {
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, (ROW_H - 16) / 2),
			Size = UDim2.fromOffset(2, 16),
			Visible = false,
		})
		U.corner(mark, 1)
		U.label(row, {
			Text = tostring(index),
			TextSize = 8.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.fromOffset(2, 0),
			Size = UDim2.fromOffset(26, ROW_H),
		})
		local coverHolder = U.frame(row, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(30, (ROW_H - ROW_COVER) / 2),
			Size = UDim2.fromOffset(ROW_COVER, ROW_COVER),
		})
		coverBox(coverHolder, UDim2.fromScale(1, 1), track, 5, { IconSize = 10, Stroke = false })
		local title = U.label(row, {
			Text = track.name,
			Font = F.Bold,
			TextSize = 10,
			TextColor3 = T.Text,
			TextTransparency = 0.04,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(64, 3),
			Size = UDim2.new(1, -(156 + ALBUM_W + edge), 0, 14),
		})
		local artist = U.label(row, {
			Text = track.artist,
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.2,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(64, 19),
			Size = UDim2.new(1, -(156 + ALBUM_W + edge), 0, 12),
		})
		local album = U.label(row, {
			Text = (track.album or "") .. (tonumber(track.fee) == 1 and " · VIP" or ""),
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.3,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.new(1, -(84 + ALBUM_W + edge), 0, 0),
			Size = UDim2.fromOffset(ALBUM_W, ROW_H),
		})
		local duration = U.label(row, {
			Text = musicFormatTime(track.duration),
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.3,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -(84 + edge), 0, 0),
			Size = UDim2.fromOffset(40, ROW_H),
		})
		local more = U.frame(row, {
			BackgroundColor3 = T.Window,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -(28 + edge), 0.5, -9),
			Size = UDim2.fromOffset(18, 18),
			Visible = false,
			ZIndex = 5,
		})
		U.corner(more, 5)
		local moreIcon = U.icon(more, "three-dots-horizontal", 9, T.Muted, {
			Size = UDim2.fromScale(1, 1),
			ZIndex = 6,
			TextTransparency = 0.2,
		})
		local widget = {
			Root = row,
			Title = title,
			Artist = artist,
			Album = album,
			Duration = duration,
			Mark = mark,
			More = more,
			BaseTransparency = 1,
		}
		local input = U.inputButton(row, function()
			if not ids or #ids == 0 then
				ids = { track.id }
			end
			M:Play(track.id, ids)
		end)
		U.connect(input.MouseEnter, function()
			if track.id ~= M.CurrentId then
				U.tween(row, U.Tween.Fast, { BackgroundTransparency = 0.94 })
			end
			more.Visible = true
		end)
		U.connect(input.MouseLeave, function()
			paintTrackRow(widget, track.id == M.CurrentId)
			more.Visible = false
		end)
		U.connect(input.InputBegan, function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
				openTrackMenu(row, track.id)
			end
		end)
		local moreInput = U.inputButton(more, function()
			openTrackMenu(more, track.id)
		end)
		U.connect(moreInput.MouseEnter, function()
			U.tween(more, U.Tween.Fast, { BackgroundTransparency = 0.1 })
		end)
		U.connect(moreInput.MouseLeave, function()
			U.tween(more, U.Tween.Fast, { BackgroundTransparency = 0.25 })
		end)
		if options.OnRemove then
			local remove = U.frame(row, {
				BackgroundColor3 = T.White,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -24, 0.5, -9),
				Size = UDim2.fromOffset(18, 18),
				Visible = true,
				ZIndex = 5,
			})
			U.corner(remove, 5)
			U.icon(remove, "x-small", 9, T.Muted, {
				Size = UDim2.fromScale(1, 1),
				ZIndex = 6,
				TextTransparency = 0.2,
			})
			U.inputButton(remove, function()
				options.OnRemove(track.id)
			end)
		end
		paintTrackRow(widget, track.id == M.CurrentId)
		return widget
	end

	local function emptyState(parent, iconName, titleText, detailText, actionText, actionCallback)
		local box = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 190),
		})
		U.icon(box, iconName, 24, T.Faint, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.3, 0),
			Size = UDim2.fromOffset(28, 28),
			TextTransparency = 0.35,
		})
		U.label(box, {
			Text = titleText,
			Font = F.Bold,
			TextSize = 10.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.2,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.new(0, 0, 0.5, 4),
			Size = UDim2.new(1, 0, 0, 16),
		})
		U.label(box, {
			Text = detailText or "",
			TextSize = 8.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.45,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.new(0, 20, 0.5, 20),
			Size = UDim2.new(1, -40, 0, 28),
		})
		if actionText and actionCallback then
			local button = textButton(box, 104, 24, actionText, "arrow-spin-clockwise", true, actionCallback)
			button.AnchorPoint = Vector2.new(0.5, 0)
			button.Position = UDim2.new(0.5, 0, 0.5, 50)
		end
		return box
	end

	local function buildTrackList(parent, ids, options)
		options = options or {}
		local scroll = newScroll(parent, options.Top or 0, options.Bottom or 0)
		local content = U.frame(scroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		U.list(content, 0)
		if #ids == 0 then
			if options.EmptyText then
				emptyState(content, options.EmptyIcon or "cloud", options.EmptyText, options.EmptyDetail, options.EmptyAction, options.EmptyCallback)
			end
			return scroll
		end
		local count = 0
		for _, id in ipairs(ids) do
			if M.Tracks[id] then
				count = count + 1
			end
		end
		local holder = U.frame(content, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 22 + count * ROW_H + 8),
			LayoutOrder = 1,
		})
		local card = nativeCard(holder, {
			Size = UDim2.new(1, -32, 0, 22 + count * ROW_H + 8),
			Position = UDim2.fromOffset(16, 0),
			ClipsDescendants = true,
		}, 10)
		U.padding(card, 4, 3, 4, 3)
		U.list(card, 0)
		trackTableHead(card, 0)
		for index, id in ipairs(ids) do
			local track = M.Tracks[id]
			if track then
				createTrackRow(card, index, track, ids, options)
			end
		end
		return scroll
	end

	-- -----------------------------------------------------------------------------------
	-- Home
	-- -----------------------------------------------------------------------------------
	buildHome = function(parent)
		local scroll = newScroll(parent, 0, 0)
		local content = U.frame(scroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		U.list(content, 0)
		local playlists = M.Recommended or {}
		local head = pageHeader(content, "NERX MUSIC · NET EASE", "Nerx Music!",
			"为你推荐 · " .. tostring(#playlists) .. " 个网易云歌单")
		head.LayoutOrder = 1
		local chartsButton = textButton(head, 76, 24, "排行榜", "chart-line", false, function()
			setView({ kind = "charts" })
		end)
		chartsButton.AnchorPoint = Vector2.new(1, 0)
		chartsButton.Position = UDim2.new(1, -18, 0, 22)
		local refresh = iconButton(head, 22, "arrow-spin-clockwise", function()
			M:LoadRecommended(true)
			notify("网易云", "正在刷新推荐", "arrow-spin-clockwise", T.Accent)
		end)
		refresh.Parent.AnchorPoint = Vector2.new(1, 0)
		refresh.Parent.Position = UDim2.new(1, -102, 0, 23)

		local needCovers = false
		for _, entry in ipairs(playlists) do
			if (entry.coverUrl or "") == "" then
				needCovers = true
				break
			end
		end
		if needCovers and not state._homeCoverRefresh then
			state._homeCoverRefresh = true
			task.defer(function()
				if canvas.Parent then
					M:LoadRecommended(true)
				end
			end)
		end
		if #playlists == 0 and not M.RecommendedLoading and not M.RecommendedError then
			task.defer(function()
				if canvas.Parent and state.view.kind == "home" then
					M:LoadRecommended()
				end
			end)
		end

		if #playlists == 0 then
			local box = emptyState(content, "cloud",
				M.RecommendedError and "网易云推荐获取失败" or "正在连接网易云...",
				M.RecommendedError or "正在获取推荐歌单",
				M.RecommendedError and "重试" or nil,
				M.RecommendedError and function() M:LoadRecommended(true) end or nil)
			box.LayoutOrder = 2
			return
		end

		local gap = 12
		local columns = math.clamp(math.floor((WORK_W - 32 + gap) / (100 + gap)), 3, 5)
		local cardW = math.floor((WORK_W - 32 - gap * (columns - 1)) / columns)
		local cardH = cardW + 40
		local rows = math.ceil(#playlists / columns)
		sectionTitle(content, "推荐歌单", 2)
		local grid = U.frame(content, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, rows * cardH + 12),
			LayoutOrder = 3,
		})
		for index, entry in ipairs(playlists) do
			local column = (index - 1) % columns
			local rowIndex = math.floor((index - 1) / columns)
			local card = U.frame(grid, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(16 + column * (cardW + gap), rowIndex * cardH),
				Size = UDim2.fromOffset(cardW, cardH - 6),
			})
			local cardGlow = bloom(card, T.Accent, 0.9, 0, {
				Position = UDim2.fromOffset(-10, -10),
				Size = UDim2.fromOffset(cardW + 20, cardW + 20),
				Visible = false,
				ZIndex = 1,
			})
			local cover = coverBox(card, UDim2.fromOffset(cardW, cardW), entry, 9, { CoverSize = 320 })
			local badge = U.frame(cover, {
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = T.Accent,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.9, 0.9),
				Size = UDim2.fromOffset(26, 26),
				Visible = false,
				ZIndex = 5,
			})
			U.corner(badge, 13)
			U.icon(badge, "play-small", 11, accentText(), {
				Size = UDim2.fromScale(1, 1),
				ZIndex = 6,
			})
			local name = U.label(card, {
				Text = entry.name,
				Font = F.Bold,
				TextSize = 10.5,
				TextColor3 = T.Text,
				TextTransparency = 0.06,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(1, cardW + 7),
				Size = UDim2.fromOffset(cardW - 2, 14),
			})
			U.label(card, {
				Text = tostring(entry.creator or "网易云音乐") .. " · " .. formatCount(entry.playCount or entry.count) .. " 播放",
				TextSize = 8,
				TextColor3 = T.Muted,
				TextTransparency = 0.35,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(1, cardW + 23),
				Size = UDim2.fromOffset(cardW - 2, 12),
			})
			local input = U.inputButton(card, function()
				local playlist = M:OpenNeteasePlaylist(entry.netId, entry)
				if playlist then
					setView({ kind = "playlist", id = playlist.id })
				end
			end)
			U.connect(input.MouseEnter, function()
				badge.Visible = true
				cardGlow.Visible = true
				U.tween(name, U.Tween.Fast, { TextColor3 = T.Accent })
			end)
			U.connect(input.MouseLeave, function()
				badge.Visible = false
				cardGlow.Visible = false
				U.tween(name, U.Tween.Fast, { TextColor3 = T.Text })
			end)
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Charts
	-- -----------------------------------------------------------------------------------
	buildCharts = function(parent)
		local scroll = newScroll(parent, 0, 0)
		local content = U.frame(scroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		U.list(content, 0)
		local head = pageHeader(content, "NET EASE · CHARTS", "排行榜", "网易云官方榜单 · 每周更新")
		head.LayoutOrder = 1
		local refresh = iconButton(head, 22, "arrow-spin-clockwise", function()
			M:LoadCharts(true)
			notify("网易云", "正在刷新排行榜", "arrow-spin-clockwise", T.Accent)
		end)
		refresh.Parent.AnchorPoint = Vector2.new(1, 0)
		refresh.Parent.Position = UDim2.new(1, -18, 0, 24)

		if #M.Charts == 0 then
			if not M.ChartsLoading then
				task.defer(function()
					if canvas.Parent then
						M:LoadCharts()
					end
				end)
			end
			local box = emptyState(content, "chart-line", "正在获取排行榜...", "飙升榜 / 新歌榜 / 热歌榜 / 原创榜 / ACG / 说唱", "刷新", function()
				M:LoadCharts(true)
			end)
			box.LayoutOrder = 2
			return
		end

		local gap = 12
		local columns = math.clamp(math.floor((WORK_W - 32 + gap) / (100 + gap)), 3, 5)
		local cardW = math.floor((WORK_W - 32 - gap * (columns - 1)) / columns)
		local cardH = cardW + 40
		local rows = math.ceil(#M.Charts / columns)
		sectionTitle(content, "官方榜单", 2)
		local grid = U.frame(content, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, rows * cardH + 12),
			LayoutOrder = 3,
		})
		for index, entry in ipairs(M.Charts) do
			local column = (index - 1) % columns
			local rowIndex = math.floor((index - 1) / columns)
			local card = U.frame(grid, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(16 + column * (cardW + gap), rowIndex * cardH),
				Size = UDim2.fromOffset(cardW, cardH - 6),
			})
			local cardGlow = bloom(card, T.Accent, 0.9, 0, {
				Position = UDim2.fromOffset(-10, -10),
				Size = UDim2.fromOffset(cardW + 20, cardW + 20),
				Visible = false,
				ZIndex = 1,
			})
			local cover = coverBox(card, UDim2.fromOffset(cardW, cardW), entry, 10, { CoverSize = 320 })
			local rank = U.frame(cover, {
				BackgroundColor3 = T.Black,
				BackgroundTransparency = 0.35,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(7, 7),
				Size = UDim2.fromOffset(20, 20),
			})
			U.corner(rank, 6)
			U.label(rank, {
				Text = tostring(index),
				Font = F.Bold,
				TextSize = 9,
				TextColor3 = T.White,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 1),
			})
			local badge = U.frame(cover, {
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = T.Accent,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.92, 0.92),
				Size = UDim2.fromOffset(30, 30),
				Visible = false,
				ZIndex = 5,
			})
			U.corner(badge, 15)
			U.icon(badge, "play-small", 12, accentText(), {
				Size = UDim2.fromScale(1, 1),
				ZIndex = 6,
			})
			local name = U.label(card, {
				Text = entry.name,
				Font = F.Bold,
				TextSize = 10.5,
				TextColor3 = T.Text,
				TextTransparency = 0.05,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(1, cardW + 7),
				Size = UDim2.fromOffset(cardW - 2, 14),
			})
			U.label(card, {
				Text = tostring(entry.tag or "") .. " · " .. formatCount(entry.playCount or 0) .. " 播放",
				TextSize = 8,
				TextColor3 = T.Muted,
				TextTransparency = 0.35,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(1, cardW + 23),
				Size = UDim2.fromOffset(cardW - 2, 12),
			})
			local input = U.inputButton(card, function()
				local playlist = M:OpenNeteasePlaylist(entry.netId, entry)
				if playlist then
					setView({ kind = "playlist", id = playlist.id })
				end
			end)
			U.connect(input.MouseEnter, function()
				badge.Visible = true
				cardGlow.Visible = true
				U.tween(name, U.Tween.Fast, { TextColor3 = T.Accent })
			end)
			U.connect(input.MouseLeave, function()
				badge.Visible = false
				cardGlow.Visible = false
				U.tween(name, U.Tween.Fast, { TextColor3 = T.Text })
			end)
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Cloud
	-- -----------------------------------------------------------------------------------
	buildCloud = function(parent)
		local scroll = newScroll(parent, 0, 0)
		local content = U.frame(scroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		U.list(content, 0)
		local head = pageHeader(content, "NET EASE · CLOUD", "云盘", "网易云音乐云盘 · 需要登录")
		head.LayoutOrder = 1
		local refresh = iconButton(head, 22, "arrow-spin-clockwise", function()
			M:LoadCloud()
			notify("网易云", "正在读取云盘", "cloud", T.Accent)
		end)
		refresh.Parent.AnchorPoint = Vector2.new(1, 0)
		refresh.Parent.Position = UDim2.new(1, -18, 0, 24)

		if M.Settings.cookie == "" then
			local box = emptyState(content, "lock-closed", "还没有登录网易云", "登录后可以读取云盘歌曲", "登录网易云", function()
				openLogin()
			end)
			box.LayoutOrder = 2
			return
		end
		if #M.CloudIds == 0 then
			if not M.CloudLoading and not M.CloudError then
				task.defer(function()
					if canvas.Parent then
						M:LoadCloud()
					end
				end)
			end
			local box = emptyState(content, "cloud",
				M.CloudLoading and "正在读取云盘..." or (M.CloudError or "云盘暂无歌曲"),
				M.CloudLoading and "请稍候" or "部分云盘歌曲需要 VIP 或版权授权",
				M.CloudLoading and nil or "重试",
				M.CloudLoading and nil or function() M:LoadCloud() end)
			box.LayoutOrder = 2
			return
		end
		sectionTitle(content, "云盘歌曲 · " .. tostring(#M.CloudIds), 2)
		local list = buildTrackList(content, M.CloudIds, { Top = 0 })
		list.LayoutOrder = 3
		list.Size = UDim2.new(1, 0, 0, math.max(120, #M.CloudIds * ROW_H + 40))
		list.AutomaticCanvasSize = Enum.AutomaticSize.None
	end

	-- -----------------------------------------------------------------------------------
	-- Playlist
	-- -----------------------------------------------------------------------------------
	buildPlaylist = function(parent)
		local playlist = currentPlaylist()
		local ids = currentIds()
		local c1 = "#69cdff"
		local c2 = "#0d3247"
		local subtitle = "歌单"
		local description = ""
		local titleText = viewTitle()
		if state.view.kind == "liked" then
			c1 = "#ff5d8f"
			c2 = "#4c1029"
			subtitle = "收藏"
			ids = M:LikedIds()
		elseif playlist then
			c1 = playlist.color1 or c1
			c2 = playlist.color2 or c2
			subtitle = playlist.kind == "netease" and "网易云歌单" or "自建歌单"
			titleText = playlist.name
		end
		local total = 0
		for _, id in ipairs(ids) do
			local track = M.Tracks[id]
			total = total + (track and tonumber(track.duration) or 0)
		end
		if state.view.kind == "liked" then
			description = tostring(#ids) .. " 首歌曲 · " .. musicFormatTime(total)
		elseif playlist and playlist.kind == "netease" then
			if playlist.loading and #ids == 0 then
				description = "正在从网易云加载歌单..."
			elseif #ids == 0 and playlist.error then
				description = playlist.error
			else
				description = tostring(#ids) .. " 首歌曲 · " .. musicFormatTime(total)
				if (tonumber(playlist.count) or 0) > #ids and #ids > 0 then
					description = description .. " · 已加载 " .. tostring(#ids) .. "/" .. tostring(playlist.count)
				end
			end
		else
			description = tostring(#ids) .. " 首歌曲 · " .. musicFormatTime(total)
		end
		local source = {
			color1 = c1,
			color2 = c2,
			coverUrl = playlist and playlist.coverUrl or "",
		}
		-- Playlists saved before cover support have no coverUrl. Refresh once so
		-- the hero / rail thumbnails stop falling back to generated gradients.
		if playlist and playlist.kind == "netease" and (playlist.coverUrl or "") == ""
			and not playlist.loading and not playlist._coverTried then
			playlist._coverTried = true
			task.defer(function()
				if canvas.Parent then
					M:OpenNeteasePlaylist(playlist.netId, playlist, nil, true)
				end
			end)
		end
		-- Cached NetEase playlists from older builds keep tracks without a
		-- coverUrl; refresh the detail once so search/chart rows get artwork.
		if playlist and playlist.kind == "netease" and playlist.loaded and not playlist.loading
			and not playlist._trackCoverTried and #ids > 0 then
			local missingCover = false
			for _, id in ipairs(ids) do
				local entry = M.Tracks[id]
				if entry and (entry.coverUrl or "") == "" then
					missingCover = true
					break
				end
			end
			if missingCover then
				playlist._trackCoverTried = true
				task.defer(function()
					if canvas.Parent then
						M:OpenNeteasePlaylist(playlist.netId, playlist, nil, true)
					end
				end)
			end
		end
		local scroll = newScroll(parent, 0, 0)
		local content = U.frame(scroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		U.list(content, 6)

		local headWrap = U.frame(content, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 156),
			LayoutOrder = 1,
		})
		local head = nativeCard(headWrap, {
			Position = UDim2.fromOffset(16, 8),
			Size = UDim2.new(1, -32, 0, 144),
		}, 12)
		bloom(head, T.Accent, 0.86, 0, {
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.fromOffset(136, 136),
			ZIndex = 1,
		})
		local coverHolder = U.frame(head, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(16, 16),
			Size = UDim2.fromOffset(112, 112),
		})
		coverBox(coverHolder, UDim2.fromScale(1, 1), source, 12, {
			CoverSize = 360,
			Icon = state.view.kind == "liked" and "heart" or "music-note",
			IconSize = 26,
		})
		U.label(head, {
			Text = subtitle,
			Font = F.Bold,
			TextSize = 8.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.35,
			Position = UDim2.fromOffset(142, 13),
			Size = UDim2.new(1, -166, 0, 12),
		})
		U.label(head, {
			Text = titleText,
			Font = F.Bold,
			TextSize = 24,
			TextColor3 = T.Text,
			TextTransparency = 0.02,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(142, 27),
			Size = UDim2.new(1, -166, 0, 30),
		})
		U.label(head, {
			Text = description,
			TextSize = 9,
			TextColor3 = T.Muted,
			TextTransparency = 0.3,
			Position = UDim2.fromOffset(142, 59),
			Size = UDim2.new(1, -166, 0, 14),
		})
		U.label(head, {
			Text = playlist and playlist.creator or "Nerx Music · 网易云",
			TextSize = 8.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.45,
			Position = UDim2.fromOffset(142, 77),
			Size = UDim2.new(1, -166, 0, 12),
		})
		local actions = U.frame(head, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(142, 104),
			Size = UDim2.new(1, -158, 0, 26),
		})
		local cursor = 0
		local function playAll(shuffle)
			if #ids == 0 then
				notify("网易云", "这个歌单还没有歌曲", "music-note", T.Muted)
				return
			end
			if shuffle then
				M:SetShuffle(true)
				M:Play(ids[math.random(1, #ids)], ids)
				notify("网易云", "已开启乱序播放", "two-arrows-switch-right", T.Accent)
			else
				M:Play(ids[1], ids)
			end
		end
		textButton(actions, 78, 24, "播放全部", "play-small", true, function() playAll(false) end).Position = UDim2.fromOffset(cursor, 0)
		cursor = cursor + 84
		textButton(actions, 72, 24, "乱序", "two-arrows-switch-right", false, function() playAll(true) end).Position = UDim2.fromOffset(cursor, 0)
		cursor = cursor + 78
		textButton(actions, 78, 24, "Coverflow", "rectangle-play-stacked", false, function()
			openCoverflow(ids)
		end).Position = UDim2.fromOffset(cursor, 0)
		cursor = cursor + 84
		textButton(actions, 66, 24, "搜索", "magnifying-glass", false, function()
			searchBox:CaptureFocus()
		end).Position = UDim2.fromOffset(cursor, 0)
		cursor = cursor + 72
		if playlist and playlist.kind ~= "netease" then
			textButton(actions, 26, 24, "", "plus-small", false, function()
				openAddTrackPanel(actions, playlist.id)
			end).Position = UDim2.fromOffset(cursor, 0)
		end

		if #ids == 0 then
			local emptyWrap = U.frame(content, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 194),
				LayoutOrder = 2,
			})
			local emptyCard = nativeCard(emptyWrap, {
				Size = UDim2.new(1, -32, 0, 194),
				Position = UDim2.fromOffset(16, 0),
			}, 10)
			local empty = emptyState(emptyCard, playlist and playlist.kind == "netease" and "cloud" or "music-note",
				playlist and playlist.loading and "正在加载网易云歌单..." or "这里还没有歌曲",
				playlist and playlist.error or "从网易云搜索歌曲，或导入一个歌单",
				playlist and playlist.kind == "netease" and "刷新" or nil,
				playlist and playlist.kind == "netease" and function()
					M:OpenNeteasePlaylist(playlist.netId, playlist, nil, true)
				end or nil)
			empty.Position = UDim2.fromOffset(0, 4)
			empty.Size = UDim2.new(1, 0, 0, 180)
			return
		end
		local count = 0
		for _, id in ipairs(ids) do
			if M.Tracks[id] then
				count = count + 1
			end
		end
		local listWrap = U.frame(content, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 22 + count * ROW_H + 8),
			LayoutOrder = 2,
		})
		local listCard = nativeCard(listWrap, {
			Size = UDim2.new(1, -32, 0, 22 + count * ROW_H + 8),
			Position = UDim2.fromOffset(16, 0),
			ClipsDescendants = true,
		}, 10)
		U.padding(listCard, 4, 3, 4, 3)
		U.list(listCard, 0)
		trackTableHead(listCard, 0)
		for index, id in ipairs(ids) do
			local track = M.Tracks[id]
			if track then
				createTrackRow(listCard, index, track, ids)
			end
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Search
	-- -----------------------------------------------------------------------------------
	buildSearch = function(parent)
		local head = pageHeader(parent, "NET EASE · SEARCH", "搜索结果", '“' .. tostring(state.query) .. '”')
		local tabs = segmented(parent, 216, 24, {
			{ Value = "songs", Label = "歌曲" },
			{ Value = "artists", Label = "歌手" },
			{ Value = "playlists", Label = "歌单" },
		}, state.searchTab, function(value)
			state.searchTab = value
			renderMain()
			if state.query ~= "" then
				if value == "artists" and (#(M.ArtistResults or {}) == 0 and not M.ArtistSearching) then
					M:SearchArtists(state.query)
				elseif value == "playlists" and (#(M.PlaylistResults or {}) == 0 and not M.PlaylistSearching) then
					M:SearchPlaylists(state.query)
				end
			end
		end)
		tabs.Root.Position = UDim2.fromOffset(18, 62)
		local action = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -18, 0, 60),
			Size = UDim2.fromOffset(100, 26),
		})
		if state.searchTab == "songs" then
			textButton(action, 86, 24, "播放全部", "play-small", true, function()
				local ids = currentIds()
				if #ids > 0 then
					M:Play(ids[1], ids)
				end
			end)
		end
		if state.query == "" then
			emptyState(parent, "magnifying-glass", "输入关键词开始搜索", "可以搜索歌曲、歌手或歌单").Position = UDim2.fromOffset(0, 110)
			return
		end
		if state.searchTab == "songs" then
			local ids = currentIds()
			if #ids == 0 then
				local detail = M.Searching and "正在搜索网易云..." or (M.SearchError or "没有找到匹配的歌曲")
				emptyState(parent, "cloud", M.Searching and "正在搜索网易云..." or "没有找到匹配的歌曲", detail,
					M.Searching and nil or "重试", M.Searching and nil or function() M:SearchNetease(state.query) end).Position = UDim2.fromOffset(0, 104)
				return
			end
			local list = buildTrackList(parent, ids, { Top = 104 })
			list.ZIndex = 2
		elseif state.searchTab == "artists" then
			local results = M.ArtistResults or {}
			if #results == 0 then
				emptyState(parent, "person-standing", M.ArtistSearching and "正在搜索歌手..." or "没有找到匹配的歌手",
					M.ArtistSearching and "请稍候" or "试试别的关键词").Position = UDim2.fromOffset(0, 104)
				return
			end
			local scroll = newScroll(parent, 104, 0)
			local content = U.frame(scroll, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			U.list(content, 0)
			local cardWrap = U.frame(content, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, #results * 48 + 8),
				LayoutOrder = 1,
			})
			local card = nativeCard(cardWrap, {
				Size = UDim2.new(1, -32, 0, #results * 48 + 8),
				Position = UDim2.fromOffset(16, 0),
				ClipsDescendants = true,
			}, 10)
			U.padding(card, 4, 3, 4, 3)
			U.list(card, 0)
			for index, entry in ipairs(results) do
				local row = U.frame(card, {
					BackgroundColor3 = T.White,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 48),
					LayoutOrder = index,
				})
				U.corner(row, 7)
				local avatarHolder = U.frame(row, {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(10, 7),
					Size = UDim2.fromOffset(34, 34),
				})
				coverBox(avatarHolder, UDim2.fromScale(1, 1), { coverUrl = entry.avatarUrl, color1 = "#6a5acd", color2 = "#241a52" }, 999, { Icon = "person-standing", IconSize = 14 })
				U.label(row, {
					Text = entry.name,
					Font = F.Bold,
					TextSize = 10,
					TextColor3 = T.Text,
					TextTransparency = 0.04,
					Position = UDim2.fromOffset(56, 8),
					Size = UDim2.new(1, -76, 0, 16),
				})
				U.label(row, {
					Text = tostring(entry.musicSize or 0) .. " 首歌曲 · " .. formatCount(entry.fans or 0) .. " 粉丝",
					TextSize = 8,
					TextColor3 = T.Muted,
					TextTransparency = 0.35,
					Position = UDim2.fromOffset(56, 26),
					Size = UDim2.new(1, -76, 0, 14),
				})
				local input = U.inputButton(row, function()
					openArtist(entry.netId, entry)
				end)
				U.connect(input.MouseEnter, function()
					U.tween(row, U.Tween.Fast, { BackgroundTransparency = 0.94 })
				end)
				U.connect(input.MouseLeave, function()
					U.tween(row, U.Tween.Fast, { BackgroundTransparency = 1 })
				end)
			end
		else
			local results = M.PlaylistResults or {}
			if #results == 0 then
				emptyState(parent, "cloud", M.PlaylistSearching and "正在搜索歌单..." or "没有找到匹配的歌单",
					M.PlaylistSearching and "请稍候" or "试试别的关键词").Position = UDim2.fromOffset(0, 104)
				return
			end
			local scroll = newScroll(parent, 104, 0)
			local content = U.frame(scroll, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			U.list(content, 0)
			local gap = 12
			local columns = math.clamp(math.floor((WORK_W - 32 + gap) / (118 + gap)), 3, 5)
			local cardW = math.floor((WORK_W - 32 - gap * (columns - 1)) / columns)
			local cardH = cardW + 38
			local rows = math.ceil(#results / columns)
			local grid = U.frame(content, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, rows * cardH + 12),
				LayoutOrder = 1,
			})
			for index, entry in ipairs(results) do
				local column = (index - 1) % columns
				local rowIndex = math.floor((index - 1) / columns)
				local card = U.frame(grid, {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(16 + column * (cardW + gap), rowIndex * cardH),
					Size = UDim2.fromOffset(cardW, cardH - 6),
				})
				coverBox(card, UDim2.fromOffset(cardW, cardW), entry, 9, { CoverSize = 320 })
				U.label(card, {
					Text = entry.name,
					Font = F.Bold,
					TextSize = 9,
					TextColor3 = T.Text,
					TextTransparency = 0.06,
					Position = UDim2.fromOffset(1, cardW + 6),
					Size = UDim2.fromOffset(cardW - 2, 13),
				})
				U.label(card, {
					Text = tostring(entry.creator or "网易云音乐") .. " · " .. formatCount(entry.playCount or entry.count) .. " 播放",
					TextSize = 7,
					TextColor3 = T.Muted,
					TextTransparency = 0.35,
					Position = UDim2.fromOffset(1, cardW + 20),
					Size = UDim2.fromOffset(cardW - 2, 11),
				})
				U.inputButton(card, function()
					local playlist = M:OpenNeteasePlaylist(entry.netId, entry)
					if playlist then
						setView({ kind = "playlist", id = playlist.id })
					end
				end)
			end
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Queue
	-- -----------------------------------------------------------------------------------
	buildQueue = function(parent)
		local head = pageHeader(parent, "NOW PLAYING", "正在播放", "当前队列 · 点击歌曲切换")
		local clear = textButton(parent, 72, 24, "清空", "trash-can", false, function()
			local current = M.CurrentId
			M.Queue = current and { current } or {}
			M.QueueIndex = current and 1 or 0
			renderMain()
			notify("音乐", "已清空队列", "trash-can", T.Muted)
		end)
		clear.AnchorPoint = Vector2.new(1, 0)
		clear.Position = UDim2.new(1, -18, 0, 18)
		local track = M.CurrentId and M.Tracks[M.CurrentId] or nil
		local card = nativeCard(parent, {
			Position = UDim2.fromOffset(16, 64),
			Size = UDim2.new(1, -32, 0, 128),
		}, 12)
		if track then
			local coverHolder = U.frame(card, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(14, 16),
				Size = UDim2.fromOffset(96, 96),
			})
			coverBox(coverHolder, UDim2.fromScale(1, 1), track, 10, { CoverSize = 300 })
			U.label(card, {
				Text = track.name,
				Font = F.Bold,
				TextSize = 18,
				TextColor3 = T.Text,
				TextTransparency = 0.03,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(126, 20),
				Size = UDim2.new(1, -164, 0, 24),
			})
			U.label(card, {
				Text = track.artist,
				TextSize = 10,
				TextColor3 = T.Muted,
				TextTransparency = 0.3,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(126, 48),
				Size = UDim2.new(1, -164, 0, 15),
			})
			U.label(card, {
				Text = track.album,
				TextSize = 9,
				TextColor3 = T.Muted,
				TextTransparency = 0.45,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(126, 66),
				Size = UDim2.new(1, -164, 0, 14),
			})
			local like = iconButton(card, 26, "heart", function()
				M:ToggleLike(track.id)
				renderMain()
			end, { Active = track.liked })
			like.TextColor3 = track.liked and T.Pink or T.Muted
			like.Parent.AnchorPoint = Vector2.new(1, 0.5)
			like.Parent.Position = UDim2.new(1, -16, 0.5, 0)
		else
			U.label(card, {
				Text = "还没有正在播放的歌曲",
				TextSize = 11,
				TextColor3 = T.Muted,
				TextTransparency = 0.3,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 1),
			})
		end
		local ids = {}
		local seen = {}
		for _, id in ipairs(M.Queue or {}) do
			if M.Tracks[id] and not seen[id] then
				seen[id] = true
				ids[#ids + 1] = id
			end
		end
		if #ids == 0 then
			emptyState(parent, "rectangle-list", "队列是空的", "播放歌曲或点“下一首播放”添加到这里").Position = UDim2.fromOffset(0, 214)
			return
		end
		sectionTitle(parent, "接下来播放 · " .. tostring(#ids), 4, 204, true)
		local listHolder = U.frame(parent, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 224),
			Size = UDim2.new(1, 0, 1, -224),
		})
		local scroll = newScroll(listHolder, 0, 0)
		local content = U.frame(scroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		U.list(content, 0)
		local listWrap = U.frame(content, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, #ids * ROW_H + 8),
			LayoutOrder = 1,
		})
		local listCard = nativeCard(listWrap, {
			Size = UDim2.new(1, -32, 0, #ids * ROW_H + 8),
			Position = UDim2.fromOffset(16, 0),
			ClipsDescendants = true,
		}, 10)
		U.padding(listCard, 4, 3, 4, 3)
		U.list(listCard, 0)
		for index, id in ipairs(ids) do
			local item = M.Tracks[id]
			if item then
				createTrackRow(listCard, index, item, ids, {
					OnRemove = function(trackId)
						local nextQueue = {}
						for _, value in ipairs(M.Queue) do
							if value ~= trackId then
								nextQueue[#nextQueue + 1] = value
							end
						end
						M.Queue = nextQueue
						renderMain()
						notify("音乐", "已从队列移除", "x-small", T.Muted)
					end,
				})
			end
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Listen together (local preview)
	-- -----------------------------------------------------------------------------------
	buildParty = function(parent)
		local head = pageHeader(parent, "LISTEN TOGETHER", "一起听", "和好友同步听歌 · 本服预览")
		local code = string.format("NERX-%04X", LocalPlayer.UserId % 0xFFFF)
		local card = nativeCard(parent, {
			Position = UDim2.fromOffset(16, 64),
			Size = UDim2.new(1, -32, 0, 104),
		}, 10)
		U.label(card, {
			Text = "房间号",
			Font = F.Bold,
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(14, 12),
			Size = UDim2.new(1, -28, 0, 12),
		})
		U.label(card, {
			Text = code,
			Font = F.Mono,
			TextSize = 18,
			TextColor3 = T.Text,
			TextTransparency = 0.02,
			Position = UDim2.fromOffset(14, 24),
			Size = UDim2.new(1, -28, 0, 24),
		})
		local copy = textButton(card, 70, 24, "复制", "floppy-disk", false, function()
			Nerx.Storage:Copy(code)
			notify("一起听", "房间号已复制", "floppy-disk", T.Green)
		end)
		copy.Position = UDim2.fromOffset(14, 56)
		local invite = textButton(card, 88, 24, "邀请好友", "person-standing", true, function()
			Nerx.Storage:Copy("来一起听歌：房间 " .. code)
			notify("一起听", "邀请文案已复制", "person-standing", T.Accent)
		end)
		invite.Position = UDim2.fromOffset(90, 56)
		U.label(card, {
			Text = "跨客户端同步需要房间服务；这里展示本服成员与房间状态。",
			TextSize = 7.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(190, 56),
			Size = UDim2.new(1, -204, 0, 24),
		})

		sectionTitle(parent, "房间成员", 5, 176, true)
		local players = Players:GetPlayers()
		local sorted = {}
		for _, player in ipairs(players) do
			sorted[#sorted + 1] = player
		end
		table.sort(sorted, function(a, b)
			if a == LocalPlayer then
				return true
			end
			if b == LocalPlayer then
				return false
			end
			return a.Name < b.Name
		end)
		local scroll = newScroll(parent, 194, 10)
		local content = U.frame(scroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		U.list(content, 8)
		local memberWrap = U.frame(content, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, #players * 42 + 8),
			LayoutOrder = 1,
		})
		local listHolder = nativeCard(memberWrap, {
			Size = UDim2.new(1, -32, 0, #players * 42 + 8),
			Position = UDim2.fromOffset(16, 0),
			ClipsDescendants = true,
		}, 10)
		for index, player in ipairs(sorted) do
			local row = U.frame(listHolder, {
				BackgroundColor3 = T.White,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(4, 4 + (index - 1) * 42),
				Size = UDim2.new(1, -8, 0, 38),
			})
			U.corner(row, 7)
			local avatarFrame = U.frame(row, {
				BackgroundColor3 = T.Accent,
				BackgroundTransparency = 0.82,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(10, 4),
				Size = UDim2.fromOffset(30, 30),
			})
			U.corner(avatarFrame, 999)
			U.label(avatarFrame, {
				Text = string.upper(string.sub(player.Name, 1, 1)),
				Font = F.Bold,
				TextSize = 10,
				TextColor3 = T.Text,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 1),
			})
			U.label(row, {
				Text = player.Name,
				Font = F.Bold,
				TextSize = 10,
				TextColor3 = T.Text,
				TextTransparency = 0.05,
				Position = UDim2.fromOffset(50, 4),
				Size = UDim2.new(1, -160, 0, 15),
			})
			U.label(row, {
				Text = player == LocalPlayer and "房主 · 本机" or "听众 · 本服",
				TextSize = 8,
				TextColor3 = T.Muted,
				TextTransparency = 0.4,
				Position = UDim2.fromOffset(50, 19),
				Size = UDim2.new(1, -160, 0, 12),
			})
			local role = U.frame(row, {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = player == LocalPlayer and T.Accent or T.White,
				BackgroundTransparency = player == LocalPlayer and 0.84 or 0.94,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.fromOffset(40, 18),
			})
			U.corner(role, 6)
			U.label(role, {
				Text = player == LocalPlayer and "房主" or "成员",
				Font = F.Bold,
				TextSize = 7.5,
				TextColor3 = player == LocalPlayer and T.Accent or T.Muted,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 1),
			})
		end
		local controlWrap = U.frame(content, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 46),
			LayoutOrder = 2,
		})
		local controlCard = nativeCard(controlWrap, {
			Size = UDim2.new(1, -32, 0, 46),
			Position = UDim2.fromOffset(16, 0),
		}, 10)
		U.label(controlCard, {
			Text = "成员控制",
			Font = F.Bold,
			TextSize = 9.5,
			TextColor3 = T.Text,
			TextTransparency = 0.08,
			Position = UDim2.fromOffset(14, 8),
			Size = UDim2.new(1, -90, 0, 14),
		})
		U.label(controlCard, {
			Text = "允许房间成员切换歌曲",
			TextSize = 7.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(14, 23),
			Size = UDim2.new(1, -90, 0, 12),
		})
		local toggle = U.frame(controlCard, {
			BackgroundColor3 = state.partyControl and T.Accent or T.ToggleOff,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -14, 0.5, 0),
			Size = UDim2.fromOffset(30, 16),
		})
		U.corner(toggle, 8)
		local knob = U.frame(toggle, {
			BackgroundColor3 = T.White,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(state.partyControl and 16 or 2, 2),
			Size = UDim2.fromOffset(12, 12),
		})
		U.corner(knob, 6)
		U.inputButton(toggle, function()
			state.partyControl = not state.partyControl
			U.tween(toggle, U.Tween.Fast, { BackgroundColor3 = state.partyControl and T.Accent or T.ToggleOff })
			U.tween(knob, U.Tween.Fast, { Position = UDim2.fromOffset(state.partyControl and 16 or 2, 2) })
		end)
	end

	-- -----------------------------------------------------------------------------------
	-- Artist
	-- -----------------------------------------------------------------------------------
	buildArtist = function(parent)
		local artist = M:GetArtist(state.view.id)
		if not artist then
			artist = M:LoadArtist(state.view.id, { name = state.view.name })
		end
		if not artist then
			emptyState(parent, "person-standing", "歌手不存在", "请重新搜索").Position = UDim2.fromOffset(0, 80)
			return
		end
		if not artist.loaded and not artist.loading and not artist.error and #artist.songs == 0 then
			M:LoadArtist(artist.netId, artist, false)
		end
		local head = nativeCard(parent, {
			Position = UDim2.fromOffset(16, 6),
			Size = UDim2.new(1, -32, 0, 112),
		}, 10)
		local avatarHolder = U.frame(head, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(14, 16),
			Size = UDim2.fromOffset(80, 80),
		})
		coverBox(avatarHolder, UDim2.fromScale(1, 1), artist, 999, { Icon = "person-standing", IconSize = 24, CoverSize = 360 })
		U.label(head, {
			Text = "NET EASE · ARTIST",
			Font = F.Bold,
			TextSize = 7.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(108, 14),
			Size = UDim2.new(1, -126, 0, 12),
		})
		U.label(head, {
			Text = artist.name or "网易云歌手",
			Font = F.Bold,
			TextSize = 20,
			TextColor3 = T.Text,
			TextTransparency = 0.02,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(108, 26),
			Size = UDim2.new(1, -126, 0, 26),
		})
		U.label(head, {
			Text = tostring(artist.musicSize or #artist.songs) .. " 首歌曲 · " .. tostring(artist.albumSize or #artist.albums) .. " 张专辑 · " .. formatCount(artist.fans or 0) .. " 粉丝",
			TextSize = 8.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.35,
			Position = UDim2.fromOffset(108, 52),
			Size = UDim2.new(1, -126, 0, 14),
		})
		U.label(head, {
			Text = artist.briefDesc or "",
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.45,
			TextWrapped = true,
			Position = UDim2.fromOffset(108, 70),
			Size = UDim2.new(1, -126, 0, 28),
		})
		local tabs = segmented(parent, 150, 24, {
			{ Value = "songs", Label = "歌曲" },
			{ Value = "albums", Label = "专辑" },
		}, state.artistTab, function(value)
			state.artistTab = value
			renderMain()
		end)
		tabs.Root.Position = UDim2.fromOffset(18, 126)
		local playButton = textButton(parent, 80, 24, "播放全部", "play-small", true, function()
			if #(artist.songs or {}) > 0 then
				M:Play(artist.songs[1], artist.songs)
			else
				notify("网易云", artist.loading and "歌手歌曲正在加载" or "没有可播放的歌曲", "music-note", T.Muted)
			end
		end)
		playButton.AnchorPoint = Vector2.new(1, 0)
		playButton.Position = UDim2.new(1, -18, 0, 126)

		if #artist.songs == 0 and not artist.loaded and state.artistTab == "songs" then
			emptyState(parent, "person-standing", artist.loading and "正在加载歌手..." or (artist.error or "歌手暂无歌曲"),
				artist.loading and "请稍候" or "可以尝试刷新").Position = UDim2.fromOffset(0, 166)
			return
		end
		if state.artistTab == "albums" then
			local scroll = newScroll(parent, 166, 0)
			local content = U.frame(scroll, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			U.list(content, 0)
			local gap = 12
			local columns = math.clamp(math.floor((WORK_W - 32 + gap) / (118 + gap)), 3, 5)
			local cardW = math.floor((WORK_W - 32 - gap * (columns - 1)) / columns)
			local cardH = cardW + 38
			local albums = artist.albums or {}
			local rows = math.ceil(math.max(1, #albums) / columns)
			local grid = U.frame(content, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, rows * cardH + 12),
				LayoutOrder = 1,
			})
			if #albums == 0 then
				U.label(grid, {
					Text = "暂无专辑",
					TextSize = 9,
					TextColor3 = T.Muted,
					TextTransparency = 0.4,
					Position = UDim2.fromOffset(18, 8),
					Size = UDim2.new(1, -36, 0, 16),
				})
				return
			end
			for index, album in ipairs(albums) do
				local column = (index - 1) % columns
				local rowIndex = math.floor((index - 1) / columns)
				local card = U.frame(grid, {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(16 + column * (cardW + gap), rowIndex * cardH),
					Size = UDim2.fromOffset(cardW, cardH - 6),
				})
				coverBox(card, UDim2.fromOffset(cardW, cardW), album, 9, { CoverSize = 320 })
				U.label(card, {
					Text = album.name,
					Font = F.Bold,
					TextSize = 9,
					TextColor3 = T.Text,
					TextTransparency = 0.06,
					Position = UDim2.fromOffset(1, cardW + 6),
					Size = UDim2.fromOffset(cardW - 2, 13),
				})
				U.label(card, {
					Text = tostring(album.count or 0) .. " 首",
					TextSize = 7,
					TextColor3 = T.Muted,
					TextTransparency = 0.35,
					Position = UDim2.fromOffset(1, cardW + 20),
					Size = UDim2.fromOffset(cardW - 2, 11),
				})
				U.inputButton(card, function()
					if M.OpenNeteaseAlbum then
						local playlist = M:OpenNeteaseAlbum(album.netId, album)
						if playlist then
							setView({ kind = "playlist", id = playlist.id })
						end
					else
						notify("网易云", "专辑详情暂不可用", "triangle-exclamation", T.Amber)
					end
				end)
			end
		else
			local list = buildTrackList(parent, artist.songs, { Top = 166 })
			list.ZIndex = 2
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Settings
	-- -----------------------------------------------------------------------------------
	local function applySettings()
		M:ApplySoundEffects()
		if M.Sound then
			M.Sound.Volume = M.Settings.volume
		end
		renderPlayer()
		renderIsland(nil, true)
		if state.lyricsOpen then
			renderLyrics(true)
		end
		syncWorld(true)
	end

	local function settingsCard(content, title, desc, order)
		local card = U.frame(content, {
			BackgroundColor3 = T.Surface,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -32, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order,
		})
		U.corner(card, 10)
		U.stroke(card, T.Stroke, 0.65, 1)
		U.padding(card, 12, 12, 12, 12)
		local list = U.list(card, 8)
		list.Padding = UDim.new(0, 4)
		local head = U.frame(card, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = 1,
		})
		U.label(head, {
			Text = title,
			Font = F.Bold,
			TextSize = 11,
			TextColor3 = T.Text,
			TextTransparency = 0.04,
			Size = UDim2.new(1, 0, 0, 15),
		})
		U.label(head, {
			Text = desc or "",
			TextSize = 7.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.4,
			Position = UDim2.fromOffset(0, 16),
			Size = UDim2.new(1, 0, 0, 11),
		})
		local rowIndex = 1
		local function addRow(height)
			rowIndex = rowIndex + 1
			local row = U.frame(card, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, height or 32),
				LayoutOrder = rowIndex,
			})
			return row
		end
		return card, addRow
	end

	local function settingsLabel(row, label, sub, width)
		U.label(row, {
			Text = label,
			TextSize = 9.5,
			TextColor3 = T.Text,
			TextTransparency = 0.08,
			Position = UDim2.fromOffset(0, sub and 2 or 0),
			Size = UDim2.new(1, -(width or 190), 0, sub and 14 or 32),
		})
		if sub then
			U.label(row, {
				Text = sub,
				TextSize = 7.5,
				TextColor3 = T.Muted,
				TextTransparency = 0.45,
				Position = UDim2.fromOffset(0, 16),
				Size = UDim2.new(1, -(width or 190), 0, 12),
			})
		end
	end

	local function toggleControl(parent, value, callback)
		local track = U.frame(parent, {
			BackgroundColor3 = value and T.Accent or T.ToggleOff,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(32, 17),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
		})
		U.corner(track, 9)
		local knob = U.frame(track, {
			BackgroundColor3 = T.White,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(value and 17 or 2, 2),
			Size = UDim2.fromOffset(13, 13),
		})
		U.corner(knob, 7)
		local current = value == true
		local input = U.inputButton(track, function()
			current = not current
			U.tween(track, U.Tween.Fast, { BackgroundColor3 = current and T.Accent or T.ToggleOff })
			U.tween(knob, U.Tween.Fast, { Position = UDim2.fromOffset(current and 17 or 2, 2) })
			if callback then
				callback(current)
			end
		end)
		U.pressFx(input, track, 0.94)
		return track
	end

	local function toggleRow(card, addRow, label, sub, key, onChange)
		local row = addRow(32)
		settingsLabel(row, label, sub, 70)
		toggleControl(row, M.Settings[key] == true, function(value)
			M.Settings[key] = value
			M:Save()
			M:_Emit("settings")
			if onChange then
				onChange(value)
			end
			applySettings()
		end)
		return row
	end

	local function rangeRow(card, addRow, label, sub, key, min, max, step, suffix, onChange)
		local row = addRow(34)
		settingsLabel(row, label, sub, 200)
		local isVolume = key == "volume"
		local value = tonumber(M.Settings[key]) or min
		local function display(value2)
			if isVolume then
				return tostring(math.floor(value2 * 100 + 0.5)) .. "%"
			end
			return (step < 1 and string.format("%.1f", value2) or tostring(math.floor(value2 + 0.5))) .. (suffix or "")
		end
		local valueLabel = U.label(row, {
			Text = display(value),
			TextSize = 8,
			TextColor3 = T.Muted,
			TextTransparency = 0.3,
			TextXAlignment = Enum.TextXAlignment.Right,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(38, 20),
		})
		local initial = isVolume and value or (value - min) / math.max(0.001, max - min)
		local slider = createSlider(row, UDim2.new(1, -200, 0, 12), initial, function(ratio, dragging)
			local newValue
			if isVolume then
				newValue = ratio
			else
				newValue = min + ratio * (max - min)
				newValue = math.floor(newValue / step + 0.5) * step
				newValue = math.clamp(newValue, min, max)
			end
			M.Settings[key] = newValue
			valueLabel.Text = display(newValue)
			if not dragging then
				M:Save()
				M:_Emit("settings")
			end
			if onChange then
				onChange(newValue)
			end
			applySettings()
		end, {
			FillColor = T.Accent,
			BaseColor = T.Track,
			BaseTransparency = 0.5,
			TrackHeight = 3,
			KnobSize = 8,
		})
		slider.Root.AnchorPoint = Vector2.new(1, 0.5)
		slider.Root.Position = UDim2.new(1, -42, 0.5, 0)
		slider.Root.Size = UDim2.fromOffset(140, 12)
		return row
	end

	local function segRow(card, addRow, label, sub, key, items, onChange)
		local row = addRow(34)
		settingsLabel(row, label, sub, 220)
		local control = segmented(row, 190, 24, items, M.Settings[key], function(value)
			M.Settings[key] = value
			M:Save()
			M:_Emit("settings")
			if onChange then
				onChange(value)
			end
			applySettings()
		end)
		control.Root.AnchorPoint = Vector2.new(1, 0.5)
		control.Root.Position = UDim2.new(1, 0, 0.5, 0)
		return row
	end

	local function buttonRow(card, addRow, label, sub, buttons)
		local row = addRow(30)
		settingsLabel(row, label, sub, 170)
		local host = U.frame(row, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(0, 24),
			AutomaticSize = Enum.AutomaticSize.X,
		})
		U.hlist(host, 6, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
		for _, item in ipairs(buttons) do
			local button
			button = textButton(host, item.Width or 78, 24, item.Text, item.Icon, item.Primary == true, function()
				if item.Callback then
					item.Callback(button)
				end
			end)
			button.LayoutOrder = item.Order or 1
		end
		return row
	end

	local function hotkeyRow(card, addRow, label, key)
		local row = addRow(30)
		settingsLabel(row, label, nil, 120)
		local value = tostring(M.Settings.hotkeys[key] or "")
		local button = textButton(row, 84, 24, value ~= "" and value or "未设置", "key-caps-lock", false, nil)
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, 0, 0.5, 0)
		local input = U.inputButton(button, function()
			state.hotkeyCapture = key
			local label2
			for _, child in ipairs(button:GetDescendants()) do
				if child:IsA("TextLabel") and child.Text == (value ~= "" and value or "未设置") then
					label2 = child
					break
				end
			end
			if label2 then
				label2.Text = "按下按键..."
			end
		end)
		return row
	end

	buildSettings = function(parent)
		local head = pageHeader(parent, "MUSIC · SETTINGS", "设置", "歌词、播放、HUD 与网易云账号")
		local loginButton = textButton(parent, M.Settings.cookie ~= "" and 124 or 104, 26,
			M.Settings.cookie ~= "" and (M.Settings.nickname ~= "" and M.Settings.nickname or "已登录") or "登录网易云",
			"person-standing", M.Settings.cookie == "", function()
				openLogin()
			end)
		loginButton.AnchorPoint = Vector2.new(1, 0)
		loginButton.Position = UDim2.new(1, -18, 0, 18)

		local tabs = segmented(parent, 250, 26, {
			{ Value = "lyrics", Label = "歌词" },
			{ Value = "hud", Label = "音乐与 HUD" },
			{ Value = "look", Label = "外观" },
		}, state.settingsTab, function(value)
			state.settingsTab = value
			renderMain()
		end)
		tabs.Root.Position = UDim2.fromOffset(18, 72)

		local scroll = newScroll(parent, 108, 0)
		local content = U.frame(scroll, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		local list = U.list(content, 10)
		list.Padding = UDim.new(0, 6)
		list.HorizontalAlignment = Enum.HorizontalAlignment.Center

		if state.settingsTab == "lyrics" then
			local card, addRow = settingsCard(content, "通用歌词", "同时应用到菜单歌词和世界 3D 歌词。", 1)
			rangeRow(card, addRow, "字号", "主歌词大小", "fontSize", 18, 48, 1, "px")
			segRow(card, addRow, "字体", "平滑 / 像素", "lyricsFont", {
				{ Value = "smooth", Label = "平滑" },
				{ Value = "pixel", Label = "像素" },
			})
			rangeRow(card, addRow, "行距", "歌词行之间的间距", "lineGap", 0, 64, 1, "px")
			rangeRow(card, addRow, "时间偏移", "正数延后，负数提前", "offset", -5, 5, 0.1, "s")

			local card2, addRow2 = settingsCard(content, "高亮与翻译", "逐字点亮和双语显示。", 2)
			toggleRow(card2, addRow2, "逐字高亮", "按每个词的时间点亮", "wordHighlight")
			toggleRow(card2, addRow2, "显示翻译", "在主歌词下方显示翻译", "showTranslation")
			toggleRow(card2, addRow2, "发光", "当前行与高亮词的辉光", "glow")

			local card3, addRow3 = settingsCard(content, "菜单内 · 沉浸歌词", "在菜单里观看的舞台歌词，不是游戏内投影。", 3)
			toggleRow(card3, addRow3, "3D 纵深", "歌词前后分层、近大远小", "immersive3d")
			rangeRow(card3, addRow3, "背景压暗", "让歌词更聚焦", "immersiveDim", 0, 100, 1, "%")
			buttonRow(card3, addRow3, "预览", "不播放也能看效果", {
				{ Text = "歌词页", Icon = "document-list-heart", Callback = function() openLyrics("page") end },
				{ Text = "沉浸歌词", Icon = "eye", Primary = true, Callback = function() openLyrics("immersive") end },
			})

			local card4, addRow4 = settingsCard(content, "游戏内 · 世界 3D 歌词", "歌词投影到游戏世界的空间里。", 4)
			toggleRow(card4, addRow4, "在世界中显示", "关闭菜单后也在世界里显示", "worldLyrics", function()
				syncWorld(true)
			end)
			segRow(card4, addRow4, "投影方式", "跟随视角 / 固定墙面 / 环形空间", "worldProjection", {
				{ Value = "follow", Label = "跟随" },
				{ Value = "wall", Label = "墙面" },
				{ Value = "orbit", Label = "环绕" },
			}, function()
				syncWorld(true)
			end)
			rangeRow(card4, addRow4, "距离", "离玩家的距离", "worldDistance", 4, 20, 1, "m", function()
				syncWorld(true)
			end)
			rangeRow(card4, addRow4, "高度", "相对视线的高度", "worldHeight", -2, 4, 0.5, "m", function()
				syncWorld(true)
			end)
			rangeRow(card4, addRow4, "大小", "歌词整体缩放", "worldSize", 0.6, 1.8, 0.05, "x", function()
				syncWorld(true)
			end)

			local card5, addRow5 = settingsCard(content, "世界 3D 观感", "世界内歌词的渲染效果。", 5)
			rangeRow(card5, addRow5, "发光强度", "当前行与高亮词的辉光", "worldGlow", 0, 100, 1, "%", function()
				syncWorld(true)
			end)
			buttonRow(card5, addRow5, "预览", "隐藏菜单查看世界内效果", {
				{ Text = "打开世界 3D 预览", Icon = "eye", Primary = true, Width = 130, Callback = function() openWorldPreview() end },
			})
		elseif state.settingsTab == "hud" then
			local card, addRow = settingsCard(content, "播放", "音量、播放模式、音质与音效。", 1)
			rangeRow(card, addRow, "音量", "当前播放音量", "volume", 0, 1, 0.01, "%")
			segRow(card, addRow, "播放模式", "顺序 / 列表循环 / 单曲", "mode", {
				{ Value = "order", Label = "顺序" },
				{ Value = "all", Label = "列表" },
				{ Value = "one", Label = "单曲" },
			}, function(value)
				M:SetMode(value)
			end)
			segRow(card, addRow, "音质", "网易云音质", "quality", {
				{ Value = "standard", Label = "标准" },
				{ Value = "hq", Label = "HQ" },
				{ Value = "lossless", Label = "无损" },
				{ Value = "hires", Label = "Hi-Res" },
			}, function()
				if M.CurrentId and M.Tracks[M.CurrentId] then
					M:_Load(M.Tracks[M.CurrentId])
				end
			end)
			buttonRow(card, addRow, "均衡器 / 调音", "3 段 EQ、速度与音高", {
				{ Text = "EQ", Icon = "sliders", Callback = function(anchor) openEQ(anchor) end },
				{ Text = "调音", Icon = "music-note", Callback = function(anchor) openTune(anchor) end },
			})

			local card2, addRow2 = settingsCard(content, "歌曲卡片", "菜单外显示的当前歌曲 HUD。", 2)
			toggleRow(card2, addRow2, "启用歌曲卡片", "在屏幕角落显示当前歌曲", "songCard")
			rangeRow(card2, addRow2, "缩放", "卡片整体大小", "songCardScale", 0.7, 1.4, 0.05, "x")
			toggleRow(card2, addRow2, "暂停时也显示", "暂停后保留卡片", "songCardPaused")

			local card3, addRow3 = settingsCard(content, "灵动岛", "播放时在菜单顶部显示的液态玻璃胶囊。", 3)
			toggleRow(card3, addRow3, "启用灵动岛", "切歌和播放时显示", "island")
			toggleRow(card3, addRow3, "切歌通知", "切歌时展开提示", "islandNotify")
			rangeRow(card3, addRow3, "缩放", "胶囊整体大小", "islandScale", 0.8, 1.3, 0.05, "x")
			rangeRow(card3, addRow3, "通知时长", "通知展开时间", "islandTime", 1, 8, 0.5, "s")

			local card4, addRow4 = settingsCard(content, "热键", "点击后按下新的键位。", 4)
			hotkeyRow(card4, addRow4, "打开音乐", "open")
			hotkeyRow(card4, addRow4, "播放 / 暂停", "play")
			hotkeyRow(card4, addRow4, "上一首", "prev")
			hotkeyRow(card4, addRow4, "下一首", "next")
			hotkeyRow(card4, addRow4, "音量 +", "volUp")
			hotkeyRow(card4, addRow4, "音量 -", "volDown")
			hotkeyRow(card4, addRow4, "歌词", "lyrics")

			local card5, addRow5 = settingsCard(content, "网易云", "账号、推荐、缓存与导入。", 5)
			buttonRow(card5, addRow5, "账号", M.Settings.cookie ~= "" and ("已登录：" .. (M.Settings.nickname ~= "" and M.Settings.nickname or "Cookie")) or "未登录", {
				{ Text = M.Settings.cookie ~= "" and "切换账号" or "登录", Icon = "person-standing", Primary = true, Callback = function() openLogin() end },
				{ Text = "退出", Icon = "x-small", Callback = function()
					M:Logout()
					renderRail()
					renderMain()
					notify("网易云", "已退出登录", "x-small", T.Muted)
				end },
			})
			buttonRow(card5, addRow5, "推荐与缓存", "刷新推荐 / 清空音频缓存", {
				{ Text = "刷新推荐", Icon = "arrow-spin-clockwise", Callback = function()
					M:LoadRecommended(true)
					notify("网易云", "正在刷新推荐歌单", "arrow-spin-clockwise", T.Accent)
				end },
				{ Text = "清空缓存", Icon = "trash-can", Callback = function()
					local removed = M:ClearCache()
					notify("网易云", "已清理 " .. tostring(removed) .. " 个音频缓存", "trash-can", T.Green)
				end },
			})
			buttonRow(card5, addRow5, "导入歌单", "歌单 ID 或网易云链接", {
				{ Text = "导入", Icon = "cloud-arrow-down", Callback = function(anchor) openImportPlaylist(anchor) end },
			})
			U.label(card5, {
				Text = "存储：" .. Nerx.Storage:Path(MUSIC_STORE_FILE) .. " · 音频缓存：" .. tostring(M.CacheDir),
				TextSize = 7.5,
				TextColor3 = T.Muted,
				TextTransparency = 0.45,
				TextWrapped = true,
				Size = UDim2.new(1, -24, 0, 24),
				LayoutOrder = 100,
			})
		else
			local card, addRow = settingsCard(content, "主题", "音乐页跟随 Nerx 菜单的主题色与液态玻璃。", 1)
			local accentRow = addRow(34)
			settingsLabel(accentRow, "强调色", "来自菜单主题 Theme.Accent", 120)
			local swatch = U.frame(accentRow, {
				BackgroundColor3 = T.Accent,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -100, 0.5, 0),
				Size = UDim2.fromOffset(22, 22),
			})
			U.corner(swatch, 11)
			U.stroke(swatch, T.White, 0.65, 1)
			local themeButton = textButton(accentRow, 86, 24, "主题页", "paint-bucket", false, function()
				if window and window.SelectTabByName then
					window:SelectTabByName("Themes")
				end
			end)
			themeButton.AnchorPoint = Vector2.new(1, 0.5)
			themeButton.Position = UDim2.new(1, 0, 0.5, 0)
			U.label(card, {
				Text = "所有高亮、进度、播放行和世界歌词都会跟随这个颜色。",
				TextSize = 7.5,
				TextColor3 = T.Muted,
				TextTransparency = 0.45,
				TextWrapped = true,
				Size = UDim2.new(1, -24, 0, 22),
				LayoutOrder = 2,
			})

			local card2, addRow2 = settingsCard(content, "液态玻璃", "毛玻璃模式由菜单的 Frosted 系统控制。", 2)
			local frosted = Nerx.Frosted
			local frostedOn = frosted and frosted.Enabled == true
			buttonRow(card2, addRow2, "毛玻璃模式", frostedOn and "已开启 · 与菜单同步" or "已关闭", {
				{ Text = frostedOn and "关闭" or "开启", Icon = "eye", Callback = function()
					if frosted then
						frosted:SetEnabled(not frostedOn)
						renderMain()
						notify("Nerx", frostedOn and "毛玻璃已关闭" or "毛玻璃已开启", "eye", T.Accent)
					end
				end },
				{ Text = "主题页", Icon = "paint-bucket", Callback = function()
					if window and window.SelectTabByName then
						window:SelectTabByName("Themes")
					end
				end },
			})
			U.label(card2, {
				Text = "毛玻璃参数（模糊、透明度、色散）在主题页的“毛玻璃参数”里调整。",
				TextSize = 7.5,
				TextColor3 = T.Muted,
				TextTransparency = 0.45,
				TextWrapped = true,
				Size = UDim2.new(1, -24, 0, 22),
				LayoutOrder = 2,
			})

			local card3, addRow3 = settingsCard(content, "动效", "音乐页使用 Tween 弹性过渡；关闭菜单动效后仍保留基础渐变。", 3)
			toggleRow(card3, addRow3, "启用动效", "页面切换、歌词滚动和封面悬停", "motion")

			local card4, addRow4 = settingsCard(content, "关于", "Nerx Music · " .. tostring(Nerx.Version), 4)
			U.label(card4, {
				Text = "数据源：网易云音乐 · 播放：Sound + 本地缓存 · 歌词：LRC / YRC 逐字",
				TextSize = 7.5,
				TextColor3 = T.Muted,
				TextTransparency = 0.45,
				TextWrapped = true,
				Size = UDim2.new(1, -24, 0, 24),
				LayoutOrder = 2,
			})
			buttonRow(card4, addRow4, "账号", M.Settings.cookie ~= "" and "已登录" or "未登录", {
				{ Text = "登录", Icon = "person-standing", Primary = true, Callback = function() openLogin() end },
			})
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Player updates
	-- -----------------------------------------------------------------------------------
	renderPlayer = function()
		local track = M.CurrentId and M.Tracks[M.CurrentId] or nil
		local trackId = track and track.id or "none"
		if state.lastPlayerTrack ~= trackId then
			state.lastPlayerTrack = trackId
			player.CoverHolder:ClearAllChildren()
			local _, image, icon = coverBox(player.CoverHolder, UDim2.fromScale(1, 1), track, 7, { IconSize = 14 })
			player.CoverArt = image
			player.CoverIcon = icon
			local coverInputAgain = U.inputButton(player.CoverHolder, function()
				openLyrics("page")
			end)
			coverInputAgain.ZIndex = 10
		end
		player.Title.Text = track and track.name or "未播放"
		if track then
			player.Artist.Text = M.Loading and "正在从网易云加载音频..." or (track.artist .. " — " .. track.album)
		else
			player.Artist.Text = "选择一首歌曲开始"
		end
		player.PlayIcon.Text = M.Loading and "arrow-spin-clockwise" or (M.Playing and "pause-small" or "play-small")
		player.ShuffleIcon.TextColor3 = M.Settings.shuffle and T.Accent or T.Muted
		player.ShuffleIcon.TextTransparency = M.Settings.shuffle and 0.02 or 0.15
		player.RepeatIcon.Text = M.Settings.mode == "one" and "two-arrows-loop-clockwise-1" or "two-arrows-loop-clockwise"
		player.RepeatIcon.TextColor3 = M.Settings.mode ~= "order" and T.Accent or T.Muted
		player.RepeatIcon.TextTransparency = M.Settings.mode ~= "order" and 0.02 or 0.15
		if track then
			player.LikeIcon.Text = "heart"
			player.LikeIcon.TextColor3 = track.liked and T.Pink or T.Muted
			player.LikeIcon.TextTransparency = track.liked and 0.02 or 0.15
		end
		local qualityName = "无损"
		for _, entry in ipairs(M.Qualities) do
			if entry.key == M.Settings.quality then
				qualityName = entry.name
				break
			end
		end
		if player.QualityLabel then
			player.QualityLabel.Text = qualityName
		end
		if player.VolumeSlider then
			if not state.volumeDragging then
				player.VolumeSlider:Set(M.Settings.volume, true)
			end
		end
		local duration = M:GetDuration()
		local ratio
		if state.progressDragging then
			ratio = state.progressRatio or 0
		else
			ratio = duration > 0 and M:GetPosition() / duration or 0
		end
		ratio = math.clamp(ratio or 0, 0, 1)
		if player.Progress then
			player.Progress:Set(ratio, true)
		end
		local position = ratio * duration
		if player.CurrentTime then
			player.CurrentTime.Text = musicFormatTime(position)
		end
		if player.RemainingTime then
			player.RemainingTime.Text = "-" .. musicFormatTime(math.max(0, duration - position))
		end
	end

	renderIsland = function(track, silent)
		if not island.Root then
			return
		end
		if not M.Settings.island then
			island.Root.Visible = false
			return
		end
		track = track or (M.CurrentId and M.Tracks[M.CurrentId] or nil)
		if not track then
			island.Root.Visible = false
			return
		end
		if state.islandTrackId ~= track.id then
			state.islandTrackId = track.id
			island.CoverHolder:ClearAllChildren()
			coverBox(island.CoverHolder, UDim2.fromScale(1, 1), track, 8, { IconSize = 11 })
		end
		island.Title.Text = track.name
		island.Artist.Text = track.artist .. " — " .. track.album
		local scale = M.Settings.islandScale or 1
		pcall(function()
			island.Root.Size = UDim2.fromOffset(260 * scale, 34 * scale)
		end)
		if silent then
			if island.Root.Visible then
				island.Root.Position = UDim2.new(0.5, 0, 0, 6)
			end
			return
		end
		island.Root.Visible = true
		if M.Settings.motion == false then
			island.Root.Position = UDim2.new(0.5, 0, 0, 6)
		else
			island.Root.Position = UDim2.new(0.5, 0, 0, -42)
			U.tween(island.Root, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.5, 0, 0, 6),
			})
		end
		state.islandToken = (state.islandToken or 0) + 1
		local token = state.islandToken
		task.delay(math.max(1, M.Settings.islandTime or 3.5), function()
			if token ~= state.islandToken or not island.Root.Parent then
				return
			end
			if M.Settings.motion == false then
				island.Root.Visible = false
				return
			end
			U.tween(island.Root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, 0, 0, -42),
			})
			task.delay(0.32, function()
				if token == state.islandToken and island.Root.Parent then
					island.Root.Visible = false
				end
			end)
		end)
	end

	local function makeDots(parent, x, y, size, zIndex)
		local baseZ = zIndex or 1
		local holder = U.frame(parent, {
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(size * 3 + 24, size + 6),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = baseZ,
		})
		for index = 1, 3 do
			local dot = U.frame(holder, {
				BackgroundColor3 = T.White,
				BackgroundTransparency = 0.82,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset((index - 1) * (size + 12), 2),
				Size = UDim2.fromOffset(size, size),
				ZIndex = baseZ + 1,
			})
			U.corner(dot, size / 2)
			local info = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, (index - 1) * 0.54)
			TweenService:Create(dot, info, { BackgroundTransparency = 0 }):Play()
			TweenService:Create(dot, info, { Position = UDim2.fromOffset((index - 1) * (size + 12), 0) }):Play()
		end
		return holder
	end

	local function richLyricLine(entry, position, accentHex)
		if not entry then
			return ""
		end
		if not M.Settings.wordHighlight then
			return M:RichEscape(entry.Text)
		end
		local words = entry.Words
		if not words or #words == 0 then
			return M:RichEscape(entry.Text)
		end
		local parts = {}
		local lastIndex = #words
		for index, word in ipairs(words) do
			local color = "#7C7C86"
			if position >= word.End then
				color = index == lastIndex and accentHex or "#FFFFFF"
			elseif position >= word.Start then
				color = accentHex
			end
			parts[#parts + 1] = '<font color="' .. color .. '">' .. M:RichEscape(word.Text) .. "</font>"
		end
		return table.concat(parts)
	end

	local function paintLyricSystem(system, position, mode, accentHex)
		if not system or not system.Rows or not system.Track then
			return
		end
		local activeIndex = 0
		for index, row in ipairs(system.Rows) do
			if row.Entry and row.Entry.Time <= position + 0.03 then
				activeIndex = index
			end
		end
		local activeRow = system.Rows[activeIndex]
		local immersive = mode == "immersive"
		local centered = immersive or mode == "world"
		local depth = immersive and M.Settings.immersive3d ~= false
		for index, row in ipairs(system.Rows) do
			if row.Entry then
				local distance = math.abs(index - activeIndex)
				local isActive = index == activeIndex
				local near = distance == 1
				if isActive then
					row.Main.Text = richLyricLine(row.Entry, position, accentHex)
					row.Main.TextTransparency = 0
					row.Main.TextColor3 = T.White
					row.Main.TextSize = row.BaseTextSize + (depth and 2 or 0)
					row.Main.TextStrokeColor3 = T.Accent
					row.Main.TextStrokeTransparency = M.Settings.glow and 0.35 or 1
					if row.Glow then
						row.Glow.Visible = M.Settings.glow == true
					end
					if M.Settings.glow then
						pcall(function()
							local shadow = row.Main:FindFirstChildOfClass("UIShadow")
							if not shadow then
								shadow = Instance.new("UIShadow")
								shadow.Parent = row.Main
							end
							shadow.BlurSize = 20
							shadow.Color = T.Accent
							shadow.Transparency = 0.48
						end)
					end
					if row.Trans then
						row.Trans.TextTransparency = M.Settings.showTranslation and 0.15 or 1
					end
					row.Frame.ZIndex = 5
				else
					row.Main.Text = M:RichEscape(row.Entry.Text)
					row.Main.TextTransparency = near and 0.45 or (immersive and 0.72 or 0.62)
					row.Main.TextColor3 = T.White
					row.Main.TextSize = depth and (near and row.BaseTextSize or row.BaseTextSize - 2) or row.BaseTextSize
					row.Main.TextStrokeTransparency = 1
					if row.Glow then
						row.Glow.Visible = false
					end
					local staleShadow = row.Main:FindFirstChildOfClass("UIShadow")
					if staleShadow then
						staleShadow:Destroy()
					end
					if row.Trans then
						row.Trans.TextTransparency = M.Settings.showTranslation and (near and 0.7 or 0.85) or 1
					end
					row.Frame.ZIndex = 1
				end
				if depth then
					row.Main.Rotation = isActive and 0 or (near and (index < activeIndex and -1.2 or 1.2) or 0)
				else
					row.Main.Rotation = 0
				end
				row.Main.TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
			end
		end
		if activeRow then
			local clipHeight = system.Clip and system.Clip.AbsoluteSize.Y or system.Height or 400
			local center = (immersive and 0.5 or (mode == "world" and 0.44 or 0.3)) * clipHeight
			local target = center - (activeRow.TopY + activeRow.Height * 0.5)
			local xAnchor = immersive and 0.5 or 0
			if immersive then
				system.Track.AnchorPoint = Vector2.new(0.5, 0)
			else
				system.Track.AnchorPoint = Vector2.new(0, 0)
			end
			if system.TargetY ~= target then
				system.TargetY = target
				if M.Settings.motion == false then
					system.Track.Position = UDim2.new(xAnchor, 0, 0, target)
				else
					U.tween(system.Track, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(xAnchor, 0, 0, target),
					})
				end
			end
		end
		system.ActiveIndex = activeIndex
		return activeIndex
	end

	-- -----------------------------------------------------------------------------------
	-- Lyrics overlay
	-- -----------------------------------------------------------------------------------
	local overlayParent = window and window.Root or canvas
	local existingLyrics = overlayParent:FindFirstChild("NerxMusicLyrics")
	if existingLyrics then
		existingLyrics:Destroy()
	end
	lyrics.Root = U.canvas(overlayParent, {
		Name = "NerxMusicLyrics",
		BackgroundColor3 = T.Window,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Active = true,
		ZIndex = 80,
		ClipsDescendants = true,
	})
	pcall(function()
		lyrics.Root:SetAttribute("NerxMusic", true)
	end)
	lyrics.BgImage = U.new("ImageLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ImageTransparency = 0.55,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 0,
	}, lyrics.Root)
	lyrics.BgTint = U.frame(lyrics.Root, {
		BackgroundColor3 = T.Black,
		BackgroundTransparency = 0.32,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
	})
	lyrics.BgGradientFrame = U.frame(lyrics.Root, {
		BackgroundColor3 = T.White,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
	})
	lyrics.BgGradient = Instance.new("UIGradient")
	lyrics.BgGradient.Color = ColorSequence.new(T.Black, T.Black)
	lyrics.BgGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.45, 0.45),
		NumberSequenceKeypoint.new(1, 0.75),
	})
	lyrics.BgGradient.Rotation = 90
	lyrics.BgGradient.Parent = lyrics.BgGradientFrame
	-- Soft accent haze behind the lyric column.
	lyrics.Glow = bloom(lyrics.Root, T.Accent, 0.95, 0, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.45, 0, 0.38, 0),
		Size = UDim2.fromOffset(overlayHeight * 1.35, overlayHeight * 1.05),
		ZIndex = 1,
	})
	local lyricsVignette = U.frame(lyrics.Root, {
		BackgroundColor3 = T.Black,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
	})
	local vignette = Instance.new("UIGradient")
	vignette.Rotation = 90
	vignette.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.35, 0.82),
		NumberSequenceKeypoint.new(0.62, 0.86),
		NumberSequenceKeypoint.new(1, 0.35),
	})
	vignette.Parent = lyricsVignette

	lyrics.Tabs = U.frame(lyrics.Root, {
		BackgroundColor3 = T.White,
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -58, 0, 14),
		Size = UDim2.fromOffset(150, 26),
		ZIndex = 10,
	})
	U.corner(lyrics.Tabs, 8)
	local function lyricsTab(text, value, x, width)
		local button = U.frame(lyrics.Tabs, {
			BackgroundColor3 = T.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, 3),
			Size = UDim2.fromOffset(width, 20),
			ZIndex = 11,
		})
		U.corner(button, 6)
		local label = U.label(button, {
			Text = text,
			TextSize = 8.5,
			TextColor3 = T.Muted,
			TextTransparency = 0.2,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 12,
		})
		U.inputButton(button, function()
			openLyrics(value)
		end)
		return { Button = button, Label = label, Value = value }
	end
	lyrics.TabPage = lyricsTab("歌词页", "page", 3, 62)
	lyrics.TabImmersive = lyricsTab("沉浸歌词", "immersive", 67, 80)

	lyrics.Close = U.frame(lyrics.Root, {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = T.White,
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -14, 0, 12),
		Size = UDim2.fromOffset(28, 28),
		ZIndex = 11,
	})
	U.corner(lyrics.Close, 14)
	U.stroke(lyrics.Close, T.White, 0.86, 1)
	U.icon(lyrics.Close, "x-small", 12, T.White, {
		Size = UDim2.fromScale(1, 1),
		TextTransparency = 0.15,
	})
	U.inputButton(lyrics.Close, function()
		closeLyrics()
	end)

	local coverSize = math.min(overlayWidth * 0.3, overlayHeight * 0.46)
	lyrics.Left = U.frame(lyrics.Root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(overlayWidth * 0.076, overlayHeight * 0.112),
		Size = UDim2.fromOffset(overlayWidth * 0.304, overlayHeight * 0.78),
		ZIndex = 4,
	})
	lyrics.CoverHolder = U.frame(lyrics.Left, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(coverSize, coverSize),
		ZIndex = 4,
	})
	lyrics.CoverTilt = 0
	lyrics.Title = U.label(lyrics.Left, {
		Text = "—",
		Font = F.Bold,
		TextSize = 15,
		TextColor3 = T.White,
		TextTransparency = 0.02,
		Position = UDim2.fromOffset(0, coverSize + 16),
		Size = UDim2.new(1, 0, 0, 20),
		ZIndex = 4,
	})
	lyrics.Artist = U.label(lyrics.Left, {
		Text = "—",
		TextSize = 9,
		TextColor3 = T.White,
		TextTransparency = 0.3,
		Position = UDim2.fromOffset(0, coverSize + 38),
		Size = UDim2.new(1, 0, 0, 14),
		ZIndex = 4,
	})
	lyrics.Cur = U.label(lyrics.Left, {
		Text = "00:00",
		Font = F.Mono,
		TextSize = 8,
		TextColor3 = T.White,
		TextTransparency = 0.4,
		Position = UDim2.fromOffset(0, coverSize + 60),
		Size = UDim2.fromOffset(32, 16),
		ZIndex = 4,
	})
	lyrics.Dur = U.label(lyrics.Left, {
		Text = "-00:00",
		Font = F.Mono,
		TextSize = 8,
		TextColor3 = T.White,
		TextTransparency = 0.4,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.new(1, -32, 0, coverSize + 60),
		Size = UDim2.fromOffset(32, 16),
		ZIndex = 4,
	})
	lyrics.Slider = createSlider(lyrics.Left, UDim2.new(1, -74, 0, 14), 0, function(ratio, dragging)
		state.progressDragging = dragging
		state.progressRatio = ratio
		if not dragging then
			M:Seek(ratio)
			state.progressDragging = false
		end
	end, {
		FillColor = T.White,
		BaseColor = T.White,
		BaseTransparency = 0.78,
		TrackHeight = 5,
		KnobSize = 8,
	})
	lyrics.Slider.Root.Position = UDim2.fromOffset(36, coverSize + 60)
	lyrics.Slider.Root.ZIndex = 4
	lyrics.Controls = U.frame(lyrics.Left, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, coverSize + 84),
		Size = UDim2.new(1, 0, 0, 34),
		ZIndex = 4,
	})
	local function lyricsControl(iconName, x, size, callback)
		local root = U.frame(lyrics.Controls, {
			BackgroundColor3 = T.White,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, (34 - size) / 2),
			Size = UDim2.fromOffset(size, size),
			ZIndex = 4,
		})
		U.corner(root, size / 2)
		local icon = U.icon(root, iconName, math.floor(size * 0.5), T.White, {
			Size = UDim2.fromScale(1, 1),
			ZIndex = 5,
		})
		local input = U.inputButton(root, callback)
		U.connect(input.MouseEnter, function()
			U.tween(root, U.Tween.Fast, { BackgroundTransparency = 0.86 })
		end)
		U.connect(input.MouseLeave, function()
			U.tween(root, U.Tween.Fast, { BackgroundTransparency = 1 })
		end)
		return icon
	end
	local centered = overlayWidth * 0.304 / 2
	lyricsControl("skip-previous-large", centered - 76, 30, function() M:Prev() end)
	lyrics.PlayIcon = lyricsControl("play-large", centered - 16, 32, function()
		if not M.CurrentId then
			local ids = currentIds()
			if #ids == 0 then
				ids = M:OrderedIds()
			end
			if #ids > 0 then
				M:Play(ids[1], ids)
			end
		else
			M:Toggle()
		end
	end)
	lyricsControl("skip-next-large", centered + 46, 30, function() M:Next(true) end)
	lyrics.Volume = U.frame(lyrics.Left, {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 16),
		ZIndex = 4,
	})
	U.icon(lyrics.Volume, "speaker", 10, T.White, {
		Position = UDim2.fromOffset(0, 2),
		Size = UDim2.fromOffset(11, 12),
		TextTransparency = 0.45,
	})
	lyrics.VolumeSlider = createSlider(lyrics.Volume, UDim2.new(1, -32, 0, 14), M.Settings.volume, function(value, dragging)
		state.volumeDragging = dragging
		M:SetVolume(value, dragging)
	end, {
		FillColor = T.White,
		BaseColor = T.White,
		BaseTransparency = 0.78,
		TrackHeight = 5,
		KnobSize = 8,
	})
	lyrics.VolumeSlider.Root.Position = UDim2.fromOffset(18, 1)

	lyrics.Right = U.frame(lyrics.Root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(overlayWidth * 0.48, 0),
		Size = UDim2.new(0.48, 0, 1, 0),
		ClipsDescendants = true,
		ZIndex = 4,
	})
	lyrics.Lines = U.frame(lyrics.Right, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 4,
	})
	lyrics.Track = U.frame(lyrics.Lines, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		ZIndex = 4,
	})
	lyrics.Dots = makeDots(lyrics.Lines, 0, overlayHeight * 0.28, 16, 5)
	lyrics.Hint = U.label(lyrics.Lines, {
		Text = "",
		TextSize = 9.5,
		TextColor3 = T.White,
		TextTransparency = 0.55,
		Position = UDim2.fromOffset(0, overlayHeight * 0.28 + 34),
		Size = UDim2.new(1, 0, 0, 18),
		ZIndex = 5,
	})

	closeLyrics = function()
		state.lyricsOpen = false
		state.lyricToken = (state.lyricToken or 0) + 1
		if lyrics.Root then
			lyrics.Root.Visible = false
		end
	end

	openLyrics = function(mode)
		if state.worldPreview then
			closeWorldPreview()
		end
		state.lyricsOpen = true
		state.lyricsMode = mode or "page"
		lyrics.Root.Visible = true
		renderLyrics(true)
	end

	updateLyrics = function(force)
		if not state.lyricsOpen or not state.lyricsSystem then
			return
		end
		local duration = M:GetDuration()
		local rawPosition = M:GetPosition()
		local position = math.clamp(rawPosition + (M.Settings.offset or 0), 0, math.max(0.1, duration))
		local ratio = duration > 0 and rawPosition / duration or 0
		if lyrics.Slider and not state.progressDragging then
			lyrics.Slider:Set(ratio, true)
		end
		if lyrics.Cur then
			lyrics.Cur.Text = musicFormatTime(rawPosition)
		end
		if lyrics.Dur then
			lyrics.Dur.Text = "-" .. musicFormatTime(math.max(0, duration - rawPosition))
		end
		if lyrics.PlayIcon then
			lyrics.PlayIcon.Text = M.Loading and "arrow-spin-clockwise" or (M.Playing and "pause-large" or "play-large")
		end
		local active = paintLyricSystem(state.lyricsSystem, position, state.lyricsMode, U.hex(T.Accent))
		if active and active ~= state.lyricActive then
			state.lyricActive = active
		end
	end

	renderLyrics = function(force)
		if not state.lyricsOpen or not lyrics.Root then
			return
		end
		local track = M.CurrentId and M.Tracks[M.CurrentId] or nil
		local immersive = state.lyricsMode == "immersive"
		lyrics.Left.Visible = not immersive
		if immersive then
			lyrics.Right.Position = UDim2.fromOffset(0, 0)
			lyrics.Right.Size = UDim2.fromScale(1, 1)
			local dim = math.clamp(M.Settings.immersiveDim or 46, 0, 100)
			lyrics.BgTint.BackgroundTransparency = math.clamp(0.72 - dim / 100 * 0.6, 0.1, 0.72)
			lyrics.BgImage.ImageTransparency = 0.72
		else
			lyrics.Right.Position = UDim2.fromOffset(overlayWidth * 0.48, 0)
			lyrics.Right.Size = UDim2.new(0.48, 0, 1, 0)
			lyrics.BgTint.BackgroundTransparency = 0.32
			lyrics.BgImage.ImageTransparency = 0.5
		end
		lyrics.TabPage.Label.TextColor3 = state.lyricsMode == "page" and T.White or T.Muted
		lyrics.TabPage.Label.TextTransparency = state.lyricsMode == "page" and 0 or 0.2
		lyrics.TabPage.Button.BackgroundTransparency = state.lyricsMode == "page" and 0 or 1
		lyrics.TabPage.Label.TextColor3 = state.lyricsMode == "page" and T.White or T.Muted
		lyrics.TabImmersive.Label.TextColor3 = immersive and T.White or T.Muted
		lyrics.TabImmersive.Label.TextTransparency = immersive and 0 or 0.2
		lyrics.TabImmersive.Button.BackgroundTransparency = immersive and 0 or 1
		lyrics.Title.Text = track and track.name or "—"
		lyrics.Artist.Text = track and (track.artist .. " — " .. track.album) or "还没有播放中的歌曲"
		lyrics.PlayIcon.Text = M.Loading and "arrow-spin-clockwise" or (M.Playing and "pause-large" or "play-large")
		lyrics.Cur.Text = "00:00"
		lyrics.Dur.Text = "-00:00"
		lyrics.Slider:Set(0, true)
		lyrics.CoverHolder:ClearAllChildren()
		if track then
			coverBox(lyrics.CoverHolder, UDim2.fromScale(1, 1), track, 8, { CoverSize = 480 })
			if track.coverUrl and track.coverUrl ~= "" then
				M:Cover(track.coverUrl, function(asset)
					if asset and lyrics.BgImage.Parent then
						lyrics.BgImage.Image = asset
						lyrics.BgImage.ImageTransparency = immersive and 0.72 or 0.5
					end
				end, 600)
			else
				lyrics.BgImage.Image = ""
			end
		else
			lyrics.BgImage.Image = ""
		end
		lyrics.Track:ClearAllChildren()
		lyrics.Track.AnchorPoint = immersive and Vector2.new(0.5, 0) or Vector2.new(0, 0)
		lyrics.Track.Position = immersive and UDim2.new(0.5, 0, 0, 0) or UDim2.fromOffset(0, 0)
		lyrics.Track.Size = UDim2.new(1, 0, 0, 0)
		lyrics.Dots.Visible = true
		lyrics.Hint.Visible = false
		state.lyricsSystem = nil
		state.lyricActive = nil
		state.lyricToken = (state.lyricToken or 0) + 1
		local token = state.lyricToken
		if not track then
			lyrics.Dots.Visible = false
			lyrics.Hint.Text = "还没有播放中的歌曲"
			lyrics.Hint.Visible = true
			return
		end
		if track.source == "netease" then
			if track.lyrics == "" and not track.lyricsLoaded and not track.lyricsLoading then
				M:FetchNeteaseLyrics(track.id)
			end
			if track.lyricsLoading then
				lyrics.Dots.Visible = true
				lyrics.Hint.Text = "正在获取网易云歌词..."
				lyrics.Hint.Visible = true
				return
			end
			if track.lyrics == "" and track.lyricsError then
				lyrics.Dots.Visible = false
				lyrics.Hint.Text = "网易云歌词获取失败：" .. tostring(track.lyricsError)
				lyrics.Hint.Visible = true
				return
			end
		end
		local entries = M:ParseLyrics(track)
		if #entries == 0 then
			lyrics.Dots.Visible = false
			lyrics.Hint.Text = track.source == "netease" and "网易云暂无歌词" or "暂无歌词 · 关闭后可右键歌曲导入 LRC"
			lyrics.Hint.Visible = true
			return
		end
		task.defer(function()
			if token ~= state.lyricToken or not lyrics.Root.Visible then
				return
			end
			local width = (immersive and overlayWidth * 0.66 or overlayWidth * 0.47) - 16
			local mainSize = math.clamp(M.Settings.fontSize or 31, 18, 48)
			if immersive then
				mainSize = math.floor(mainSize * 1.05)
			end
			local mainFont = M.Settings.lyricsFont == "pixel" and F.Mono or F.Bold
			local transSize = math.max(11, math.floor(mainSize * 0.46))
			local gap = M.Settings.lineGap or 22
			local y = 0
			local rows = {}
			local previousTime = nil
			for _, entry in ipairs(entries) do
				if previousTime and entry.Time - previousTime >= 10 then
					local breakRow = U.frame(lyrics.Track, {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(0, y),
						Size = UDim2.fromOffset(width, 28),
						ZIndex = 3,
					})
					makeDots(breakRow, immersive and width / 2 - 30 or 0, 6, 12, 4)
					y = y + 28 + gap
				end
				local mainHeight = math.max(mainSize + 6, U.measureWrap(entry.Text, mainSize, mainFont, width).Y + 2)
				local transText = M.Settings.showTranslation and entry.Trans ~= "" and entry.Trans or nil
				local transHeight = 0
				if transText then
					transHeight = math.max(transSize + 2, U.measureWrap(transText, transSize, F.Regular, width).Y + 2)
				end
				local rowHeight = mainHeight + (transText and (transHeight + 4) or 0)
				local row = U.frame(lyrics.Track, {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, y),
					Size = UDim2.fromOffset(width, rowHeight),
					ZIndex = 1,
				})
				local rowGlow = bloom(row, T.Accent, 0.84, 0, {
					Position = UDim2.fromOffset(-30, -14),
					Size = UDim2.fromOffset(width + 60, rowHeight + 28),
					Visible = false,
					ZIndex = 1,
				})
				local main = U.label(row, {
					Text = M:RichEscape(entry.Text),
					Font = mainFont,
					TextSize = mainSize,
					TextColor3 = T.White,
					TextTransparency = 0.82,
					TextWrapped = true,
					RichText = true,
					TextXAlignment = immersive and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					Size = UDim2.fromOffset(width, mainHeight),
					ZIndex = 2,
				})
				local trans = nil
				if transText then
					trans = U.label(row, {
						Text = transText,
						TextSize = transSize,
						TextColor3 = T.White,
						TextTransparency = 0.85,
						TextWrapped = true,
						TextXAlignment = immersive and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						Position = UDim2.fromOffset(0, mainHeight + 4),
						Size = UDim2.fromOffset(width, transHeight),
						ZIndex = 2,
					})
				end
				local rowInfo = {
					Entry = entry,
					Frame = row,
					Main = main,
					Trans = trans,
					Glow = rowGlow,
					TopY = y,
					Height = rowHeight,
					BaseTextSize = mainSize,
				}
				rows[#rows + 1] = rowInfo
				U.inputButton(row, function()
					local duration = M:GetDuration()
					if duration > 0 then
						M:Seek(math.clamp(entry.Time / duration, 0, 1))
					end
				end)
				y = y + rowHeight + gap
				previousTime = entry.Time
			end
			lyrics.Track.Size = UDim2.fromOffset(width, math.max(1, y))
			state.lyricsSystem = {
				Rows = rows,
				Track = lyrics.Track,
				Clip = lyrics.Lines,
				Width = width,
				Height = y,
			}
			lyrics.Dots.Visible = false
			lyrics.Hint.Visible = false
			updateLyrics(true)
		end)
	end

	-- -----------------------------------------------------------------------------------
	-- World 3D lyrics (BillboardGui in the game world)
	-- -----------------------------------------------------------------------------------
	local oldWorldAnchor = workspace:FindFirstChild("NerxMusicWorldLyricsAnchor")
	if oldWorldAnchor then
		oldWorldAnchor:Destroy()
	end
	world.Lines = {}
	world.Entries = nil
	world.ActiveIndex = nil
	world.TrackId = nil

	local function destroyWorldLine(line)
		if line.Billboard then
			line.Billboard:Destroy()
		end
		if line.Part then
			line.Part:Destroy()
		end
	end

	local function clearWorldLines()
		for _, line in ipairs(world.Lines or {}) do
			destroyWorldLine(line)
		end
		world.Lines = {}
		world.ActiveIndex = nil
	end

	-- Dango spawns one lyric line at a time at a random point in front of the
	-- player, lets it float in world space (occluded by geometry), then fades
	-- the old one upward. No background plate, no screen-space rotation.
	local function spawnWorldLine(entry, index)
		local camera = workspace.CurrentCamera
		if not camera or not entry then
			return nil
		end
		local distance = math.clamp(tonumber(M.Settings.worldDistance) or 10, 4, 20)
		local height = math.clamp(tonumber(M.Settings.worldHeight) or 0, -2, 4)
		local scale = math.clamp(tonumber(M.Settings.worldSize) or 1, 0.6, 1.8)
		local projection = M.Settings.worldProjection or "follow"
		local yaw, pitch
		if projection == "wall" then
			yaw = 0
			pitch = -math.rad(7)
		elseif projection == "orbit" then
			yaw = ((index - 1) % 6) * (math.pi * 2 / 6)
			pitch = -math.rad(8)
		else
			yaw = (math.random() * 2 - 1) * math.rad(24)
			pitch = -math.rad(3 + math.random() * 9)
		end
		local base = camera.CFrame
		local position
		if projection == "orbit" then
			position = base.Position
				+ Vector3.new(math.sin(yaw) * distance, height + math.sin(pitch) * distance, math.cos(yaw) * distance)
		else
			local direction = (base * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)).LookVector
			position = base.Position + direction * distance + Vector3.new(0, height, 0)
		end
		local part = Instance.new("Part")
		part.Name = "NerxMusicWorldLyric"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(0.1, 0.1, 0.1)
		part.CFrame = CFrame.new(position)
		part.Parent = workspace

		local translation = M.Settings.showTranslation and entry.Trans ~= "" and entry.Trans or nil
		local textWidth = 560
		local mainH = math.max(40, U.measureWrap(entry.Text, 30, F.Bold, textWidth).Y + 6)
		local transH = 0
		if translation then
			transH = math.max(20, U.measureWrap(translation, 16, F.Regular, textWidth).Y + 4)
		end
		local totalH = mainH + (translation and (transH + 4) or 0)
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "NerxMusicWorldLyric"
		billboard.Adornee = part
		billboard.AlwaysOnTop = false
		billboard.LightInfluence = 0
		billboard.MaxDistance = 800
		billboard.Size = UDim2.fromOffset(textWidth * scale, totalH * scale)
		billboard.Enabled = true
		billboard.Parent = part

		local main = U.label(billboard, {
			Text = M:RichEscape(entry.Text),
			Font = F.Bold,
			TextSize = 30,
			TextScaled = true,
			TextWrapped = true,
			RichText = true,
			TextColor3 = T.White,
			TextTransparency = 1,
			TextStrokeColor3 = T.Accent,
			TextStrokeTransparency = 0.55,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Size = UDim2.new(1, 0, mainH / totalH, 0),
		})
		U.new("UITextSizeConstraint", {
			MaxTextSize = math.floor(96 * scale),
			MinTextSize = 10,
		}, main)
		local trans = nil
		if translation then
			trans = U.label(billboard, {
				Text = translation,
				TextSize = 16,
				TextScaled = true,
				TextWrapped = true,
				TextColor3 = T.White,
				TextTransparency = 1,
				TextStrokeTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Position = UDim2.new(0, 0, mainH / totalH, 0),
				Size = UDim2.new(1, 0, transH / totalH, 0),
			})
			U.new("UITextSizeConstraint", {
				MaxTextSize = math.floor(34 * scale),
				MinTextSize = 8,
			}, trans)
		end
		if M.Settings.glow then
			local amount = math.clamp((M.Settings.worldGlow or 70) / 100, 0, 1)
			local stroke = Instance.new("UIStroke")
			stroke.Thickness = 1.6 + amount * 2.4
			stroke.Color = T.Accent
			stroke.Transparency = 0.72 - amount * 0.32
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
			stroke.Parent = main
			pcall(function()
				local shadow = Instance.new("UIShadow")
				shadow.BlurSize = 18 + amount * 22
				shadow.Color = T.Accent
				shadow.Transparency = 0.55 - amount * 0.25
				shadow.Parent = main
			end)
		end
		U.tween(main, U.Tween.Fast, { TextTransparency = 0.06 })
		if trans then
			U.tween(trans, U.Tween.Fast, { TextTransparency = 0.25 })
		end
		local line = {
			Entry = entry,
			Index = index,
			Part = part,
			Billboard = billboard,
			Main = main,
			Trans = trans,
			BasePosition = position,
			BaseWidth = textWidth,
			BaseHeight = totalH,
			RefDistance = distance,
			Scale = scale,
			Spawned = os.clock(),
		}
		world.Lines[#world.Lines + 1] = line
		while #world.Lines > 5 do
			local old = table.remove(world.Lines, 1)
			destroyWorldLine(old)
		end
		return line
	end

	syncWorld = function(force)
		local enabled = (M.Settings.worldLyrics or state.worldPreview) and M.CurrentId ~= nil
		local track = enabled and M.CurrentId and M.Tracks[M.CurrentId] or nil
		if not track then
			clearWorldLines()
			world.Entries = nil
			world.TrackId = nil
			return
		end
		if track.source == "netease" and track.lyrics == "" and not track.lyricsLoaded and not track.lyricsLoading then
			M:FetchNeteaseLyrics(track.id)
		end
		local entries = M:ParseLyrics(track)
		local trackChanged = world.TrackId ~= track.id
		world.TrackId = track.id
		world.Entries = entries
		if force or trackChanged then
			clearWorldLines()
		end
		if #entries == 0 then
			world.ActiveIndex = nil
			return
		end
		updateWorld(true)
	end

	updateWorld = function(force)
		local entries = world.Entries
		if not entries or #entries == 0 then
			return
		end
		if not (M.Settings.worldLyrics or state.worldPreview) then
			return
		end
		local duration = M:GetDuration()
		local position = math.clamp(M:GetPosition() + (M.Settings.offset or 0), 0, math.max(0.1, duration))
		local active = 0
		for index, entry in ipairs(entries) do
			if entry.Time <= position + 0.03 then
				active = index
			else
				break
			end
		end
		if force or active ~= world.ActiveIndex then
			for _, line in ipairs(world.Lines) do
				if not line.Fading then
					line.Fading = os.clock()
				end
			end
			world.ActiveIndex = active
			if active > 0 then
				spawnWorldLine(entries[active], active)
			end
		end
		local now = os.clock()
		local accentHex = U.hex(T.Accent)
		local camera = workspace.CurrentCamera
		local repaint = not world.LastPaint or now - world.LastPaint >= 0.05
		if repaint then
			world.LastPaint = now
		end
		for index = #world.Lines, 1, -1 do
			local line = world.Lines[index]
			if camera and line.Billboard and line.Billboard.Parent then
				local distance = (camera.CFrame.Position - line.BasePosition).Magnitude
				local k = math.clamp((line.RefDistance / math.max(1, distance)) * line.Scale, 0.35, 2.8)
				line.Billboard.Size = UDim2.fromOffset(line.BaseWidth * k, line.BaseHeight * k)
			end
			if line.Fading then
				local t = (now - line.Fading) / 0.45
				if t >= 1 or not line.Billboard.Parent then
					destroyWorldLine(line)
					table.remove(world.Lines, index)
				else
					local a = 1 - t
					line.Main.TextTransparency = 0.06 + 0.94 * (1 - a)
					if line.Trans then
						line.Trans.TextTransparency = 0.25 + 0.75 * (1 - a)
					end
					line.Part.CFrame = CFrame.new(line.BasePosition + Vector3.new(0, t * 0.7, 0))
				end
			else
				if repaint then
					line.Main.Text = richLyricLine(line.Entry, position, accentHex)
				end
			end
		end
	end

	state.returnGui = nil
	openWorldPreview = function()
		state.worldPreview = true
		syncWorld(true)
		if window and window.Hide then
			window:Hide()
		end
		if not state.returnGui then
			local gui = U.new("ScreenGui", {
				Name = "NerxMusicWorldPreviewHud",
				ResetOnSpawn = false,
				IgnoreGuiInset = true,
				DisplayOrder = 999,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			})
			gui.Parent = parentGui
			local pill = glassPanel(gui, {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 18),
				Size = UDim2.fromOffset(280, 34),
				BackgroundColor3 = T.Black,
				BackgroundTransparency = 0.18,
				Radius = 17,
			}, true)
			local dot = U.frame(pill, {
				BackgroundColor3 = T.Green,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(14, 15),
				Size = UDim2.fromOffset(5, 5),
			})
			U.corner(dot, 3)
			U.label(pill, {
				Text = "世界 3D 歌词预览 · 点击返回菜单",
				TextSize = 9.5,
				TextColor3 = T.White,
				TextTransparency = 0.1,
				Position = UDim2.fromOffset(28, 0),
				Size = UDim2.new(1, -36, 1, 0),
			})
			U.inputButton(pill, function()
				closeWorldPreview()
			end)
			state.returnGui = gui
		end
		state.returnGui.Enabled = true
	end

	closeWorldPreview = function()
		state.worldPreview = false
		if state.returnGui then
			state.returnGui.Enabled = false
		end
		if window and window.Show then
			window:Show()
		end
		syncWorld(true)
	end

	-- -----------------------------------------------------------------------------------
	-- Coverflow
	-- -----------------------------------------------------------------------------------
	local existingCoverflow = workspacePanel:FindFirstChild("NerxMusicCoverflow")
	if existingCoverflow then
		existingCoverflow:Destroy()
	end
	coverflow.Root = U.canvas(workspacePanel, {
		Name = "NerxMusicCoverflow",
		BackgroundColor3 = T.Window,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Active = true,
		ZIndex = 40,
	})
	local cfGlow = U.frame(coverflow.Root, {
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.35),
		Size = UDim2.fromOffset(320, 320),
		ZIndex = 0,
	})
	U.corner(cfGlow, 999)
	local cfTop = U.frame(coverflow.Root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 42),
		ZIndex = 5,
	})
	U.label(cfTop, {
		Text = "Coverflow",
		Font = F.Bold,
		TextSize = 10.5,
		TextColor3 = T.Text,
		TextTransparency = 0.05,
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.fromOffset(120, 42),
	})
	local cfClose = U.frame(cfTop, {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = T.White,
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		ZIndex = 6,
	})
	U.corner(cfClose, 12)
	U.icon(cfClose, "x-small", 10, T.Muted, {
		Size = UDim2.fromScale(1, 1),
	})
	U.inputButton(cfClose, function()
		closeCoverflow()
	end)
	coverflow.Stage = U.frame(coverflow.Root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.new(1, 0, 1, -142),
		ClipsDescendants = true,
		ZIndex = 2,
	})
	coverflow.Title = U.label(coverflow.Root, {
		Text = "",
		Font = F.Bold,
		TextSize = 12,
		TextColor3 = T.Text,
		TextTransparency = 0.04,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.new(0, 0, 1, -100),
		Size = UDim2.new(1, 0, 0, 18),
		ZIndex = 5,
	})
	coverflow.Artist = U.label(coverflow.Root, {
		Text = "",
		TextSize = 8.5,
		TextColor3 = T.Muted,
		TextTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.new(0, 0, 1, -78),
		Size = UDim2.new(1, 0, 0, 14),
		ZIndex = 5,
	})
	local cfNav = U.frame(coverflow.Root, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -62),
		Size = UDim2.new(1, 0, 0, 48),
		ZIndex = 5,
	})
	local function cfButton(iconName, x, size, callback, primary)
		local root = U.frame(cfNav, {
			BackgroundColor3 = primary and T.Accent or T.White,
			BackgroundTransparency = primary and 0 or 0.94,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, (48 - size) / 2),
			Size = UDim2.fromOffset(size, size),
			ZIndex = 6,
		})
		U.corner(root, size / 2)
		U.icon(root, iconName, math.floor(size * 0.45), primary and accentText() or T.Muted, {
			Size = UDim2.fromScale(1, 1),
			ZIndex = 7,
		})
		U.inputButton(root, callback)
		return root
	end
	cfButton("chevron-small-left", WORK_W * 0.5 - 74, 28, function()
		state.cfIndex = state.cfIndex - 1
		renderCoverflow()
	end)
	cfButton("play-small", WORK_W * 0.5 - 17, 34, function()
		local ids = state.cfIds
		if #ids > 0 then
			local id = ids[((state.cfIndex - 1) % #ids) + 1]
			if id then
				M:Play(id, ids)
				closeCoverflow()
			end
		end
	end, true)
	cfButton("chevron-small-right", WORK_W * 0.5 + 46, 28, function()
		state.cfIndex = state.cfIndex + 1
		renderCoverflow()
	end)

	renderCoverflow = function()
		if not coverflow.Root then
			return
		end
		coverflow.Stage:ClearAllChildren()
		local ids = state.cfIds
		if #ids == 0 then
			coverflow.Title.Text = "没有可播放的歌曲"
			coverflow.Artist.Text = ""
			return
		end
		state.cfIndex = ((state.cfIndex - 1) % #ids) + 1
		local stageW = WORK_W
		local stageH = math.max(120, coverflow.Stage.AbsoluteSize.Y)
		for offset = -2, 2 do
			local id = ids[((state.cfIndex + offset - 1) % #ids) + 1]
			local track = M.Tracks[id]
			if track then
				local size = offset == 0 and 150 or (math.abs(offset) == 1 and 116 or 88)
				local x = stageW * 0.5 - size * 0.5 + offset * 118
				local y = stageH * 0.5 - size * 0.5 + math.abs(offset) * 8
				local cover = coverBox(coverflow.Stage, UDim2.fromOffset(size, size), track, 8, {
					CoverSize = 400,
					ZIndex = 30 - math.abs(offset) * 4,
					ImageTransparency = offset ~= 0 and (math.abs(offset) == 1 and 0.18 or 0.5) or 0,
				})
				cover.Position = UDim2.fromOffset(x, y)
				cover.BackgroundTransparency = offset ~= 0 and (math.abs(offset) == 1 and 0.18 or 0.5) or 0
				if offset ~= 0 then
					cover.Rotation = offset < 0 and -7 or 7
				end
				local input = U.inputButton(cover, function()
					if offset == 0 then
						M:Play(track.id, ids)
						closeCoverflow()
					else
						state.cfIndex = ((state.cfIndex + offset - 1) % #ids) + 1
						renderCoverflow()
					end
				end)
				input.ZIndex = 40
			end
		end
		local center = M.Tracks[ids[state.cfIndex]]
		coverflow.Title.Text = center and center.name or "—"
		coverflow.Artist.Text = center and (center.artist .. " — " .. center.album) or ""
	end

	openCoverflow = function(ids)
		ids = ids or currentIds()
		if #ids == 0 then
			ids = M:OrderedIds()
		end
		state.cfIds = ids
		state.cfIndex = 1
		for index, id in ipairs(ids) do
			if id == M.CurrentId then
				state.cfIndex = index
				break
			end
		end
		coverflow.Root.Visible = true
		renderCoverflow()
	end

	closeCoverflow = function()
		if coverflow.Root then
			coverflow.Root.Visible = false
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Login overlay
	-- -----------------------------------------------------------------------------------
	local existingLogin = overlayParent:FindFirstChild("NerxMusicLogin")
	if existingLogin then
		existingLogin:Destroy()
	end
	login.Root = U.canvas(overlayParent, {
		Name = "NerxMusicLogin",
		BackgroundColor3 = T.Black,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Active = true,
		ZIndex = 90,
	})
	login.Panel = glassPanel(login.Root, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.min(460, overlayWidth - 80), 360),
		BackgroundColor3 = T.Window,
		BackgroundTransparency = 0.03,
		Radius = 14,
	}, false)
	login.Header = U.frame(login.Panel, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 46),
	})
	U.label(login.Header, {
		Text = "登录网易云音乐",
		Font = F.Bold,
		TextSize = 14,
		TextColor3 = T.Text,
		TextTransparency = 0.03,
		Position = UDim2.fromOffset(16, 14),
		Size = UDim2.new(1, -70, 0, 20),
	})
	local loginClose = U.frame(login.Header, {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = T.White,
		BackgroundTransparency = 0.93,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -14, 0, 12),
		Size = UDim2.fromOffset(24, 24),
		ZIndex = 3,
	})
	U.corner(loginClose, 12)
	U.icon(loginClose, "x-small", 10, T.Muted, {
		Size = UDim2.fromScale(1, 1),
	})
	U.inputButton(loginClose, function()
		closeLogin()
	end)
	login.Tabs = segmented(login.Panel, 180, 26, {
		{ Value = "qr", Label = "扫码登录" },
		{ Value = "cookie", Label = "Cookie" },
	}, state.loginTab, function(value)
		state.loginTab = value
		renderLogin()
	end)
	login.Tabs.Root.Position = UDim2.fromOffset(16, 50)
	login.Body = U.frame(login.Panel, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 86),
		Size = UDim2.new(1, -32, 1, -160),
	})
	login.Footer = U.frame(login.Panel, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 326),
		Size = UDim2.new(1, -32, 0, 26),
	})

	renderLogin = function()
		if not login.Body then
			return
		end
		login.Body:ClearAllChildren()
		if state.loginTab == "qr" then
			local qrHolder = U.frame(login.Body, {
				BackgroundColor3 = T.White,
				BackgroundTransparency = 0.96,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 0),
				Size = UDim2.fromOffset(170, 170),
			})
			U.corner(qrHolder, 10)
			U.stroke(qrHolder, T.StrokeSoft, 0.4, 1)
			if state.qrAsset then
				U.new("ImageLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					Image = state.qrAsset,
					ScaleType = Enum.ScaleType.Fit,
					ZIndex = 2,
				}, qrHolder)
			else
				U.icon(qrHolder, "cloud", 28, T.Faint, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.4),
					Size = UDim2.fromOffset(32, 32),
					TextTransparency = 0.3,
				})
				U.label(qrHolder, {
					Text = state.qrBusy and "正在获取二维码..." or "二维码加载失败，可改用 Cookie 登录",
					TextSize = 8.5,
					TextColor3 = T.Faint,
					TextTransparency = 0.2,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					Position = UDim2.new(0, 8, 0.66, 0),
					Size = UDim2.new(1, -16, 0, 30),
				})
			end
			U.label(login.Body, {
				Text = "打开网易云音乐 App → 扫一扫",
				Font = F.Bold,
				TextSize = 11,
				TextColor3 = T.Text,
				TextTransparency = 0.08,
				Position = UDim2.fromOffset(190, 8),
				Size = UDim2.new(1, -190, 0, 16),
			})
			U.label(login.Body, {
				Text = state.qrStatus ~= "" and state.qrStatus or "二维码有效期约 2 分钟",
				TextSize = 8.5,
				TextColor3 = T.Faint,
				TextTransparency = 0.25,
				TextWrapped = true,
				Position = UDim2.fromOffset(190, 28),
				Size = UDim2.new(1, -190, 0, 40),
			})
			local refresh = textButton(login.Body, 106, 26, "刷新二维码", "arrow-spin-clockwise", true, function()
				startQrLogin()
			end)
			refresh.Position = UDim2.fromOffset(190, 76)
			U.label(login.Body, {
				Text = "提示：扫码后手机端确认登录，菜单会自动更新账号与歌单。",
				TextSize = 7.5,
				TextColor3 = T.Faint,
				TextTransparency = 0.3,
				TextWrapped = true,
				Position = UDim2.fromOffset(0, 182),
				Size = UDim2.new(1, 0, 0, 28),
			})
		else
			U.label(login.Body, {
				Text = "粘贴 MUSIC_U Cookie",
				Font = F.Bold,
				TextSize = 10,
				TextColor3 = T.Text,
				TextTransparency = 0.06,
				Position = UDim2.fromOffset(0, 0),
				Size = UDim2.new(1, 0, 0, 16),
			})
			U.label(login.Body, {
				Text = "浏览器登录 music.163.com → 开发者工具 → Application → Cookies → 复制 MUSIC_U 的值。",
				TextSize = 8,
				TextColor3 = T.Faint,
				TextTransparency = 0.25,
				TextWrapped = true,
				Position = UDim2.fromOffset(0, 18),
				Size = UDim2.new(1, 0, 0, 28),
			})
			local cookieBox = U.new("TextBox", {
				BackgroundColor3 = T.FieldDeep,
				BackgroundTransparency = 0.1,
				BorderSizePixel = 0,
				Font = F.Regular,
				Text = "",
				PlaceholderText = M.Settings.cookie ~= "" and "已保存 Cookie，输入新值覆盖" or "MUSIC_U=...",
				PlaceholderColor3 = T.Faint,
				TextColor3 = T.Text,
				TextSize = 9,
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(0, 52),
				Size = UDim2.new(1, -100, 0, 30),
			}, login.Body)
			U.corner(cookieBox, 7)
			local save = textButton(login.Body, 90, 30, "保存并验证", "circle-check", true, function()
				local value = musicTrim(cookieBox.Text)
				if value == "" then
					notify("网易云", "请先粘贴 MUSIC_U Cookie", "triangle-exclamation", T.Amber)
					return
				end
				M:SetCookie(value)
				cookieBox.Text = ""
				state.qrStatus = "正在验证 Cookie..."
				renderLogin()
				M:VerifyCookie(function(ok, message)
					if ok then
						notify("网易云", "已登录：" .. tostring(message), "circle-check", T.Green)
						closeLogin()
						renderRail()
					else
						state.qrStatus = "Cookie 验证失败：" .. tostring(message)
						notify("网易云", state.qrStatus, "triangle-exclamation", T.Amber)
						renderLogin()
					end
				end)
			end)
			save.Position = UDim2.new(1, -92, 0, 52)
			U.label(login.Body, {
				Text = state.qrStatus ~= "" and state.qrStatus or "",
				TextSize = 8.5,
				TextColor3 = T.Faint,
				TextTransparency = 0.2,
				TextWrapped = true,
				Position = UDim2.fromOffset(0, 90),
				Size = UDim2.new(1, 0, 0, 28),
			})
		end
		if login.Footer then
			login.Footer:ClearAllChildren()
		end
		local accountText = M.Settings.cookie ~= ""
			and ("当前账号：" .. (M.Settings.nickname ~= "" and M.Settings.nickname or "已登录") .. (M.Settings.uid ~= "" and (" · UID " .. M.Settings.uid) or ""))
			or "当前未登录"
		U.label(login.Footer, {
			Text = accountText,
			TextSize = 8,
			TextColor3 = T.Faint,
			TextTransparency = 0.3,
			Position = UDim2.fromOffset(0, 6),
			Size = UDim2.new(1, -90, 0, 14),
		})
		if M.Settings.cookie ~= "" then
			local logout = textButton(login.Footer, 70, 22, "退出登录", "x-small", false, function()
				M:Logout()
				closeLogin()
				renderRail()
				notify("网易云", "已退出登录", "x-small", T.Muted)
			end)
			logout.AnchorPoint = Vector2.new(1, 0)
			logout.Position = UDim2.new(1, 0, 0, 2)
		end
	end

	local function pollQrLogin(key, token)
		task.spawn(function()
			while state.loginOpen and state.qrToken == token and state.qrKey == key do
				task.wait(2)
				if not state.loginOpen or state.qrToken ~= token or state.qrKey ~= key then
					return
				end
				M:QrLoginPoll(key, function(status, message)
					if state.qrToken ~= token or not state.loginOpen then
						return
					end
					if status == "waiting" then
						state.qrStatus = "等待扫码..."
					elseif status == "scanned" then
						state.qrStatus = "已扫码，请在手机上确认"
					elseif status == "expired" then
						state.qrStatus = "二维码已过期，请刷新"
						state.qrKey = nil
					elseif status == "success" then
						state.qrStatus = "登录成功"
						notify("网易云", "登录成功：" .. tostring(message or M.Settings.nickname), "circle-check", T.Green)
						closeLogin()
						renderRail()
						return
					elseif status == "failed" then
						state.qrStatus = "登录失败：" .. tostring(message or "未知错误")
						state.qrKey = nil
					end
					renderLogin()
				end)
			end
		end)
	end

	startQrLogin = function()
		state.qrToken = (state.qrToken or 0) + 1
		local token = state.qrToken
		state.qrKey = nil
		state.qrAsset = nil
		state.qrBusy = true
		state.qrStatus = "正在获取二维码..."
		renderLogin()
		M:QrLoginStart(function(ok, key, asset, message)
			if state.qrToken ~= token or not state.loginOpen then
				return
			end
			state.qrBusy = false
			if ok then
				state.qrKey = key
				state.qrAsset = asset
				state.qrStatus = message or "等待扫码..."
				renderLogin()
				pollQrLogin(key, token)
			else
				state.qrStatus = tostring(message or "二维码获取失败")
				renderLogin()
			end
		end)
	end

	openLogin = function()
		state.loginOpen = true
		state.qrStatus = ""
		state.qrKey = nil
		state.qrAsset = nil
		login.Root.Visible = true
		renderLogin()
		if state.loginTab == "qr" then
			startQrLogin()
		end
	end

	closeLogin = function()
		state.loginOpen = false
		state.qrToken = (state.qrToken or 0) + 1
		if login.Root then
			login.Root.Visible = false
		end
	end

	-- -----------------------------------------------------------------------------------
	-- Popups
	-- -----------------------------------------------------------------------------------
	local function popupRange(card, y, labelText, value, min, max, suffix, callback)
		U.label(card, {
			Text = labelText,
			TextSize = 9,
			TextColor3 = T.Muted,
			TextTransparency = 0.15,
			Position = UDim2.fromOffset(0, y),
			Size = UDim2.fromOffset(90, 14),
		})
		local valueLabel = U.label(card, {
			Text = string.format((max - min <= 24 and min % 1 == 0) and "%.0f%s" or "%.1f%s", value, suffix or ""),
			TextSize = 8,
			TextColor3 = T.Faint,
			TextTransparency = 0.15,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -44, 0, y),
			Size = UDim2.fromOffset(44, 14),
		})
		local slider = createSlider(card, UDim2.new(1, 0, 0, 12), (value - min) / math.max(0.001, max - min), function(ratio, dragging)
			local newValue = min + ratio * (max - min)
			if max - min > 24 then
				newValue = math.floor(newValue + 0.5)
			else
				newValue = math.floor(newValue * 10 + 0.5) / 10
			end
			valueLabel.Text = string.format((max - min <= 24 and min % 1 == 0) and "%.0f%s" or "%.1f%s", newValue, suffix or "")
			if callback then
				callback(newValue)
			end
		end, {
			FillColor = T.Accent,
			BaseColor = T.Track,
			BaseTransparency = 0.5,
			TrackHeight = 3,
			KnobSize = 8,
		})
		slider.Root.Position = UDim2.fromOffset(0, y + 16)
		slider.Root.Size = UDim2.new(1, -50, 0, 12)
		return slider
	end

	openEQ = function(anchor)
		anchor = anchor or player.Root
		U.popup(anchor, 286, 300, function(card)
			pcall(function()
				card:SetAttribute("NerxMusic", true)
			end)
			U.padding(card, 12, 12, 12, 12)
			U.label(card, {
				Text = "均衡器",
				Font = F.Bold,
				TextSize = 11,
				TextColor3 = T.Text,
				TextTransparency = 0.04,
				Size = UDim2.new(1, 0, 0, 16),
			})
			U.label(card, {
				Text = "3 段 EQ · Roblox SoundEffect",
				TextSize = 7.5,
				TextColor3 = T.Faint,
				TextTransparency = 0.25,
				Position = UDim2.fromOffset(0, 18),
				Size = UDim2.new(1, 0, 0, 12),
			})
			U.label(card, {
				Text = "启用",
				TextSize = 9,
				TextColor3 = T.Muted,
				TextTransparency = 0.15,
				Position = UDim2.fromOffset(0, 40),
				Size = UDim2.fromOffset(80, 16),
			})
			toggleControl(card, M.Settings.eqEnabled == true, function(value)
				M.Settings.eqEnabled = value
				M:ApplySoundEffects()
				M:Save()
			end).Position = UDim2.new(1, -32, 0, 38)
			popupRange(card, 70, "低频", M.Settings.eqLow or 0, -12, 12, "dB", function(value)
				M.Settings.eqLow = value
				M:ApplySoundEffects()
			end)
			popupRange(card, 122, "中频", M.Settings.eqMid or 0, -12, 12, "dB", function(value)
				M.Settings.eqMid = value
				M:ApplySoundEffects()
			end)
			popupRange(card, 174, "高频", M.Settings.eqHigh or 0, -12, 12, "dB", function(value)
				M.Settings.eqHigh = value
				M:ApplySoundEffects()
			end)
			local reset = textButton(card, 70, 24, "重置", "arrow-spin-clockwise", false, function()
				M.Settings.eqLow = 0
				M.Settings.eqMid = 0
				M.Settings.eqHigh = 0
				M:ApplySoundEffects()
				M:Save()
				Nerx:ClosePopup(true)
				openEQ(anchor)
			end)
			reset.Position = UDim2.fromOffset(0, 226)
			U.label(card, {
				Text = "提示：EQ 只影响当前 Sound，不改变游戏音量。",
				TextSize = 7,
				TextColor3 = T.Faint,
				TextTransparency = 0.3,
				Position = UDim2.fromOffset(0, 256),
				Size = UDim2.new(1, 0, 0, 20),
			})
		end)
	end

	openTune = function(anchor)
		anchor = anchor or player.Root
		U.popup(anchor, 286, 270, function(card)
			pcall(function()
				card:SetAttribute("NerxMusic", true)
			end)
			U.padding(card, 12, 12, 12, 12)
			U.label(card, {
				Text = "速度 / 音高",
				Font = F.Bold,
				TextSize = 11,
				TextColor3 = T.Text,
				TextTransparency = 0.04,
				Size = UDim2.new(1, 0, 0, 16),
			})
			U.label(card, {
				Text = "PlaybackSpeed + PitchShiftSoundEffect",
				TextSize = 7.5,
				TextColor3 = T.Faint,
				TextTransparency = 0.25,
				Position = UDim2.fromOffset(0, 18),
				Size = UDim2.new(1, 0, 0, 12),
			})
			popupRange(card, 46, "速度", M.Settings.speed or 1, 0.5, 2, "x", function(value)
				M.Settings.speed = value
				M:ApplySoundEffects()
			end)
			popupRange(card, 100, "音高", M.Settings.pitch or 0, -12, 12, "半音", function(value)
				M.Settings.pitch = value
				M:ApplySoundEffects()
			end)
			local reset = textButton(card, 70, 24, "重置", "arrow-spin-clockwise", false, function()
				M.Settings.speed = 1
				M.Settings.pitch = 0
				M:ApplySoundEffects()
				M:Save()
				Nerx:ClosePopup(true)
				openTune(anchor)
			end)
			reset.Position = UDim2.fromOffset(0, 158)
			U.label(card, {
				Text = "提示：速度会改变歌词的时间轴，音高只改变音色。",
				TextSize = 7,
				TextColor3 = T.Faint,
				TextTransparency = 0.3,
				Position = UDim2.fromOffset(0, 192),
				Size = UDim2.new(1, 0, 0, 30),
			})
		end)
	end

	openAddTrackPanel = function(anchor, playlistId)
		U.popup(anchor, 300, 268, function(card)
			pcall(function()
				card:SetAttribute("NerxMusic", true)
			end)
			U.padding(card, 12, 12, 12, 12)
			U.label(card, {
				Text = "添加歌曲",
				Font = F.Bold,
				TextSize = 11,
				TextColor3 = T.Text,
				TextTransparency = 0.04,
				Size = UDim2.new(1, 0, 0, 16),
			})
			U.label(card, {
				Text = "粘贴 Roblox 音频 ID，播放使用 Sound。",
				TextSize = 7.5,
				TextColor3 = T.Faint,
				TextTransparency = 0.25,
				Position = UDim2.fromOffset(0, 18),
				Size = UDim2.new(1, 0, 0, 12),
			})
			local function field(y, labelText, placeholder)
				U.label(card, {
					Text = labelText,
					TextSize = 8.5,
					TextColor3 = T.Muted,
					TextTransparency = 0.15,
					Position = UDim2.fromOffset(0, y),
					Size = UDim2.new(1, 0, 0, 12),
				})
				local box = W.Input(card, {
					Width = 270,
					Height = 26,
					Placeholder = placeholder,
				})
				box.Root.Position = UDim2.fromOffset(0, y + 14)
				return box
			end
			local idBox = field(38, "音频 ID", "例如 9046863048")
			local nameBox = field(86, "歌曲名称", "显示在列表里的名字")
			local artistBox = field(134, "歌手 / 备注", "可选")
			local cancel = textButton(card, 64, 24, "取消", nil, false, function()
				Nerx:ClosePopup(true)
			end)
			cancel.Position = UDim2.new(1, -140, 1, -28)
			local add = textButton(card, 64, 24, "添加", "plus-small", true, function()
				local soundId = musicTrim(idBox:GetValue())
				if not string.match(soundId, "^%d+$") then
					notify("音乐", "请输入有效的数字音频 ID", "triangle-exclamation", T.Amber)
					return
				end
				local track = M:AddTrack({
					SoundId = soundId,
					Name = nameBox:GetValue(),
					Artist = artistBox:GetValue(),
					PlaylistId = playlistId,
				})
				if track then
					Nerx:ClosePopup(true)
					notify("音乐", "已添加「" .. track.name .. "」", "plus-small", T.Green)
					if state.view.kind == "playlist" then
						renderMain()
					end
				end
			end)
			add.Position = UDim2.new(1, -70, 1, -28)
		end)
	end

	openAddToPlaylist = function(anchor, trackId)
		trackId = trackId or M.CurrentId
		if not trackId then
			notify("音乐", "请先播放一首歌曲", "music-note", T.Muted)
			return
		end
		local playlists = {}
		for _, playlist in ipairs(M.Playlists or {}) do
			if playlist.kind == "custom" then
				playlists[#playlists + 1] = playlist
			end
		end
		if #playlists == 0 then
			UIHelpers.InputPrompt(anchor, {
				Title = "新建歌单",
				Placeholder = "歌单名称，例如：深夜循环",
				Submit = "创建并添加",
				Attribute = "NerxMusic",
				OnSubmit = function(name)
					local playlist = M:AddPlaylist(name)
					if playlist then
						M:AddToPlaylist(playlist.id, trackId)
						notify("音乐", "已添加「" .. playlist.name .. "」", "plus-small", T.Green)
					end
				end,
			})
			return
		end
		local items = {}
		for _, playlist in ipairs(playlists) do
			items[#items + 1] = {
				Text = playlist.name .. "  ·  " .. tostring(#M:PlaylistIds(playlist)) .. " 首",
				Callback = function()
					local ok = M:AddToPlaylist(playlist.id, trackId)
					notify("音乐", ok and ("已添加到「" .. playlist.name .. "」") or "歌曲已在该歌单中", "plus-small", ok and T.Green or T.Muted)
				end,
			}
		end
		UIHelpers.ContextMenu(anchor, items)
	end

	openTrackMenu = function(anchor, trackId)
		local track = M.Tracks[trackId]
		if not track then
			return
		end
		local playlist = currentPlaylist()
		local items = {
			{
				Text = "播放",
				Callback = function()
					M:Play(trackId, currentIds())
				end,
			},
			{
				Text = "下一首播放",
				Callback = function()
					M:QueueNext(trackId)
					notify("音乐", "已加入下一首播放", "play-small", T.Accent)
				end,
			},
			{
				Text = "添加到队列",
				Callback = function()
					local queue = {}
					local seen = false
					for _, id in ipairs(M.Queue or {}) do
						queue[#queue + 1] = id
						if id == trackId then
							seen = true
						end
					end
					if not seen then
						queue[#queue + 1] = trackId
					end
					M.Queue = queue
					notify("音乐", "已添加到队列", "rectangle-list", T.Green)
				end,
			},
			{
				Text = track.liked and "取消喜欢" or "添加到我喜欢的音乐",
				Callback = function()
					local _, liked = M:ToggleLike(trackId)
					notify("音乐", liked and "已添加到喜欢" or "已取消喜欢", "heart", liked and T.Pink or T.Muted)
					renderPlayer()
				end,
			},
			{
				Text = "查看歌词",
				Callback = function()
					if M.CurrentId ~= trackId then
						M:Play(trackId, currentIds())
					end
					openLyrics("page")
				end,
			},
			{
				Text = "添加到歌单",
				Callback = function()
					openAddToPlaylist(anchor, trackId)
				end,
			},
		}
		if track.artistId then
			items[#items + 1] = {
				Text = "前往歌手",
				Callback = function()
					openArtist(track.artistId, { name = track.artist })
				end,
			}
		end
		if track.source == "netease" then
			items[#items + 1] = {
				Text = "复制网易云链接",
				Callback = function()
					Nerx.Storage:Copy("https://music.163.com/song?id=" .. tostring(track.netId))
					notify("网易云", "歌曲链接已复制", "floppy-disk", T.Green)
				end,
			}
			items[#items + 1] = {
				Text = "重新获取歌词",
				Callback = function()
					track.lyrics = ""
					track.yrc = ""
					track.lyricsLoaded = false
					track.lyricsError = nil
					M:FetchNeteaseLyrics(trackId)
					notify("网易云", "正在重新获取歌词", "document-list-heart", T.Accent)
				end,
			}
		else
			items[#items + 1] = {
				Text = "导入歌词 (LRC)",
				Callback = function()
					UIHelpers.ImportPrompt(anchor, {
						Title = "导入歌词 (LRC)",
						Placeholder = "[00:12.34]歌词|翻译",
						Submit = "导入",
						OnSubmit = function(text)
							if M:SetLyrics(trackId, text) then
								notify("音乐", "歌词已保存", "document-list-heart", T.Green)
								if state.lyricsOpen then
									renderLyrics(true)
								end
							end
						end,
					})
				end,
			}
		end
		if playlist and playlist.kind ~= "netease" then
			local contains = false
			for _, id in ipairs(playlist.trackIds or {}) do
				if id == trackId then
					contains = true
					break
				end
			end
			if contains then
				items[#items + 1] = {
					Text = "从当前歌单移除",
					Color = T.Red,
					Callback = function()
						M:RemoveFromPlaylist(playlist.id, trackId)
						renderMain()
						notify("音乐", "已从歌单移除", "trash-can", T.Muted)
					end,
				}
			end
		end
		UIHelpers.ContextMenu(anchor, items)
	end

	-- -----------------------------------------------------------------------------------
	-- Song card HUD (outside the menu)
	-- -----------------------------------------------------------------------------------
	local oldHud = parentGui:FindFirstChild("NerxMusicSongCard")
	if oldHud then
		oldHud:Destroy()
	end
	local oldPreviewHud = parentGui:FindFirstChild("NerxMusicWorldPreviewHud")
	if oldPreviewHud then
		oldPreviewHud:Destroy()
	end
	local hudGui = U.new("ScreenGui", {
		Name = "NerxMusicSongCard",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 998,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	hudGui.Parent = parentGui
	local hudCard = glassPanel(hudGui, {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -14, 1, -14),
		Size = UDim2.fromOffset(236, 58),
		BackgroundColor3 = T.Black,
		BackgroundTransparency = 0.22,
		Radius = 12,
		Visible = false,
	}, true)
	local hudScale = Instance.new("UIScale")
	hudScale.Scale = M.Settings.songCardScale or 1
	hudScale.Parent = hudCard
	local hudCoverHolder = U.frame(hudCard, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(7, 8),
		Size = UDim2.fromOffset(42, 42),
	})
	local hudTitle = U.label(hudCard, {
		Text = "—",
		Font = F.Bold,
		TextSize = 9.5,
		TextColor3 = T.White,
		TextTransparency = 0.05,
		Position = UDim2.fromOffset(57, 10),
		Size = UDim2.new(1, -68, 0, 14),
	})
	local hudArtist = U.label(hudCard, {
		Text = "—",
		TextSize = 7.5,
		TextColor3 = T.White,
		TextTransparency = 0.4,
		Position = UDim2.fromOffset(57, 25),
		Size = UDim2.new(1, -68, 0, 11),
	})
	local hudBarBase = U.frame(hudCard, {
		BackgroundColor3 = T.White,
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(57, 42),
		Size = UDim2.new(1, -68, 0, 3),
	})
	U.corner(hudBarBase, 2)
	local hudBarFill = U.frame(hudBarBase, {
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
	})
	U.corner(hudBarFill, 2)
	U.inputButton(hudCard, function()
		if window and window.Show then
			window:Show()
		end
		openLyrics("page")
	end)
	state.hudTrackId = nil
	renderHud = function()
		local track = M.CurrentId and M.Tracks[M.CurrentId] or nil
		local visible = M.Settings.songCard and track and (M.Playing or M.Settings.songCardPaused)
		if not visible then
			hudCard.Visible = false
			return
		end
		hudCard.Visible = true
		hudScale.Scale = M.Settings.songCardScale or 1
		if state.hudTrackId ~= track.id then
			state.hudTrackId = track.id
			hudCoverHolder:ClearAllChildren()
			coverBox(hudCoverHolder, UDim2.fromScale(1, 1), track, 8, { IconSize = 12, CoverSize = 240 })
		end
		hudTitle.Text = track.name
		hudArtist.Text = track.artist .. " — " .. track.album
		local duration = M:GetDuration()
		local ratio = duration > 0 and M:GetPosition() / duration or 0
		hudBarFill.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
	end

	-- -----------------------------------------------------------------------------------
	-- Theme refresh
	-- -----------------------------------------------------------------------------------
	refreshTheme = function()
		state.themeToken = (state.themeToken or 0) + 1
		local token = state.themeToken
		task.delay(0.05, function()
			if token ~= state.themeToken or not canvas.Parent then
				return
			end
			renderRail()
			renderMain()
			renderPlayer()
			if state.lyricsOpen then
				renderLyrics(true)
			end
			syncWorld(true)
			renderHud()
		end)
	end
	U.onAccent(function()
		refreshTheme()
	end)

	-- -----------------------------------------------------------------------------------
	-- Search + library events
	-- -----------------------------------------------------------------------------------
	U.connect(searchBox:GetPropertyChangedSignal("Text"), function()
		if state.suppressSearch then
			return
		end
		local query = musicTrim(searchBox.Text)
		state.searchToken = (state.searchToken or 0) + 1
		local token = state.searchToken
		if query ~= "" then
			local wasSearch = state.view.kind == "search"
			if not wasSearch then
				state.lastView = state.view
			end
			state.query = query
			local tabChanged = state.searchTab ~= "songs"
			state.searchTab = "songs"
			state.view = { kind = "search" }
			M.SearchIds = {}
			M.SearchQuery = query
			M.Searching = true
			M.SearchError = nil
			M.ArtistResults = {}
			M.PlaylistResults = {}
			M.ArtistSearching = false
			M.PlaylistSearching = false
			if not wasSearch or tabChanged then
				renderRail()
				renderMain()
			end
			task.delay(0.35, function()
				if token ~= state.searchToken then
					return
				end
				if canvas.Parent then
					M:SearchNetease(query)
				end
			end)
		elseif state.view.kind == "search" then
			state.query = ""
			M:SearchNetease("")
			local target = state.lastView or { kind = "home" }
			if target.kind == "playlist" and not M:GetPlaylist(target.id) then
				target = { kind = "home" }
			end
			state.view = target
			renderRail()
			renderMain()
		end
	end)

	M:Subscribe(function(kind, payload)
		if not canvas.Parent then
			return
		end
		if kind == "library" then
			if state.view.kind == "playlist" and not currentPlaylist() then
				state.view = { kind = "home" }
			end
			renderRail()
			if state.view.kind ~= "settings" then
				renderMain()
			end
			renderPlayer()
			renderHud()
		elseif kind == "track" then
			renderPlayer()
			renderIsland(payload)
			if state.lyricsOpen then
				renderLyrics(true)
			end
			syncWorld(true)
			renderHud()
		elseif kind == "state" then
			renderPlayer()
			renderHud()
		elseif kind == "search" then
			if state.view.kind == "search" then
				renderMain()
			end
		elseif kind == "recommended" then
			if state.view.kind == "home" then
				renderMain()
			end
		elseif kind == "charts" then
			if state.view.kind == "charts" then
				renderMain()
			end
		elseif kind == "cloud" then
			if state.view.kind == "cloud" then
				renderMain()
			end
			if M.CloudLoading then
				renderMain()
			end
		elseif kind == "artist" then
			if state.view.kind == "artist" and state.view.id == (payload and payload.netId) then
				renderMain()
			end
		elseif kind == "account" then
			renderRail()
			if state.view.kind == "settings" then
				renderMain()
			end
		elseif kind == "lyrics" then
			if state.lyricsOpen then
				renderLyrics(true)
			end
			syncWorld(true)
		elseif kind == "settings" then
			renderPlayer()
			renderIsland(nil, true)
			renderHud()
			if state.lyricsOpen then
				renderLyrics(true)
			end
			syncWorld(true)
		elseif kind == "loadfail" then
			local track = payload and payload.track or payload
			local message = payload and payload.message
			local name = track and track.name or "音频"
			notify("网易云播放失败", message or ("无法播放「" .. tostring(name) .. "」"), "triangle-exclamation", T.Amber)
		elseif kind == "fallback" then
			notify("网易云音质", "当前音质无法解码，已自动回退标准音质", "music-note", T.Amber)
		end
	end)

	-- -----------------------------------------------------------------------------------
	-- Hotkeys
	-- -----------------------------------------------------------------------------------
	U.connect(UserInputService.InputBegan, function(input, gameProcessed)
		if state.hotkeyCapture then
			local keyName = U.keyName and U.keyName(input.KeyCode) or nil
			if keyName and input.KeyCode ~= Enum.KeyCode.Unknown then
				M.Settings.hotkeys[state.hotkeyCapture] = keyName
				M:Save()
				notify("音乐", "热键已设置：" .. keyName, "key-caps-lock", T.Green)
				state.hotkeyCapture = nil
				if state.view.kind == "settings" then
					renderMain()
				end
			end
			return
		end
		if gameProcessed then
			return
		end
		local focused = false
		pcall(function()
			focused = UserInputService:GetFocusedTextBox() ~= nil
		end)
		if focused then
			return
		end
		local hotkeys = M.Settings.hotkeys or {}
		local code = input.KeyCode
		local function is(keyValue)
			local parsed = keyValue and U.parseKey(keyValue) or nil
			return parsed ~= nil and parsed == code
		end
		if is(hotkeys.open) then
			if window and window.Toggle then
				if window.Visible then
					window:Hide()
				else
					window:Show()
					if window.SelectTabByName then
						window:SelectTabByName("Music")
					end
				end
			end
			return
		end
		if is(hotkeys.play) then
			M:Toggle()
			return
		end
		if is(hotkeys.prev) then
			M:Prev()
			return
		end
		if is(hotkeys.next) then
			M:Next(true)
			return
		end
		if is(hotkeys.volUp) then
			M:SetVolume(math.clamp((M.Settings.volume or 0) + 0.05, 0, 1))
			renderPlayer()
			return
		end
		if is(hotkeys.volDown) then
			M:SetVolume(math.clamp((M.Settings.volume or 0) - 0.05, 0, 1))
			renderPlayer()
			return
		end
		if is(hotkeys.lyrics) then
			if M.CurrentId then
				openLyrics("page")
			end
			return
		end
	end)

	-- -----------------------------------------------------------------------------------
	-- World lyric animation
	-- -----------------------------------------------------------------------------------
	U.connect(RunService.RenderStepped, function()
		if (M.Settings.worldLyrics or state.worldPreview) and world.Entries and #world.Entries > 0 then
			updateWorld()
		end
	end)

	if page.Root then
		U.connect(page.Root:GetPropertyChangedSignal("Visible"), function()
			if not page.Root.Visible then
				closeLyrics()
				closeCoverflow()
				closeLogin()
				if state.worldPreview then
					closeWorldPreview()
				end
			end
		end)
	end
	if window and window.Root then
		U.connect(window.Root:GetPropertyChangedSignal("Visible"), function()
			if not window.Root.Visible then
				closeLyrics()
				closeCoverflow()
				closeLogin()
			elseif state.worldPreview then
				state.worldPreview = false
				if state.returnGui then
					state.returnGui.Enabled = false
				end
				syncWorld(true)
			end
		end)
	end

	-- -----------------------------------------------------------------------------------
	-- Boot
	-- -----------------------------------------------------------------------------------
	renderRail()
	renderMain()
	renderPlayer()
	renderHud()
	if M.CurrentId then
		renderIsland(M.Tracks[M.CurrentId], true)
	end
	syncWorld(true)
	if M.Settings.cookie ~= "" then
		M:VerifyCookie()
	end
	task.spawn(function()
		while canvas.Parent do
			task.wait(0.1)
			if canvas.Parent then
				renderPlayer()
				if state.lyricsOpen then
					updateLyrics()
				end
				renderHud()
			end
		end
	end)
end



















return Nerx
