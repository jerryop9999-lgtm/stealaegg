--[[
    Egg ESP + Select Rarity  (Clean Menu)
    - Toggle button (draggable) opens / closes the menu
    - Menu (draggable by its title bar)
    - ESP  : name / rarity / kg / mutation / value on every field egg
    - Select Rarity : choose which rarities ESP shows (none selected = all)
    Extracted & rewritten from Open2.lua
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")

local genv = (getgenv and getgenv()) or _G
local localPlayer = Players.LocalPlayer

if type(genv.__EggEspMenuUnload) == "function" then
	pcall(genv.__EggEspMenuUnload)
end

---------------------------------------------------------------------
-- Game modules
---------------------------------------------------------------------
local function safeRequire(path)
	local ok, result = pcall(function()
		return require(path)
	end)
	return ok and result or nil
end

local Assets       = safeRequire(ReplicatedStorage.Data.Assets)
local EggState     = safeRequire(ReplicatedStorage.Client.EggState)
local AreaEggs     = safeRequire(ReplicatedStorage.Shared.Types.AreaEggs)
local EggRecords   = safeRequire(ReplicatedStorage.Shared.Util.EggRecords)
local AssetEarning = safeRequire(ReplicatedStorage.Shared.Util.AssetEarnings)
local FormatNumber = safeRequire(ReplicatedStorage.Packages.FormatNumber.Simple)

if not (Assets and EggState and AreaEggs) then
	warn("[EggESP] Required game modules not found - wrong game?")
	return
end

local RARITY_RANK = {
	Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5,
	Mythic = 6, Cosmic = 7, Secret = 8, Eternal = 9, Divine = 10,
}

---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
local Config = {
	Esp = false,
	Rarities = {},          -- [name] = true ; empty = show all
	Details = {
		Icon = true, Rarity = true, Name = true,
		Kg = true, Mutation = true, Value = true,
	},
}

local TAG_GUI, TAG_HL = "__EggEspGui", "__EggEspHighlight"

---------------------------------------------------------------------
-- Egg helpers
---------------------------------------------------------------------
local function resolve(record)
	local asset  = record and Assets.Directory[record.AssetCategory]
	local rarity = asset and asset.Rarity
	local rName  = rarity and (rarity.DisplayName or rarity._id) or "Unknown"
	return {
		name   = asset and (asset.DisplayName or asset._id) or tostring(record and record.AssetCategory or "Unknown"),
		rarity = rName,
		color  = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or Color3.new(1, 1, 1),
		icon   = (asset and type(asset.Egg) == "table" and type(asset.Egg.Icon) == "string" and asset.Egg.Icon)
			or (asset and type(asset.Icon) == "string" and asset.Icon) or nil,
	}
end

local function valuePerSec(record)
	if not AssetEarning or type(record) ~= "table" then return nil end
	local category = record.Category or record.AssetCategory
	local scale = tonumber(record.Scale or record.AssetScale)
	if type(category) ~= "string" or not scale or scale <= 0 then return nil end
	local ok, result = pcall(AssetEarning.MutationOnlyRatePerSecond, {
		Category = category,
		Scale = scale,
		Mutations = type(record.Mutations) == "table" and table.clone(record.Mutations) or {},
		BaseMutation = type(record.BaseMutation) == "string" and record.BaseMutation or nil,
	})
	return ok and type(result) == "number" and result or nil
end

local function weightKg(record)
	if not EggRecords or not record.AssetScale or not record.AssetCategory then return nil end
	local ok, result = pcall(EggRecords.WeightKgForScale, record.AssetCategory, record.AssetScale)
	return ok and type(result) == "number" and result or nil
end

local function formatNumber(n)
	if FormatNumber and type(FormatNumber.FormatCompact) == "function" then
		local ok, s = pcall(FormatNumber.FormatCompact, n, ".#")
		if ok and type(s) == "string" then return s end
	end
	local a = math.abs(n)
	if a >= 1e12 then return string.format("%.2fT", n / 1e12)
	elseif a >= 1e9 then return string.format("%.2fB", n / 1e9)
	elseif a >= 1e6 then return string.format("%.1fM", n / 1e6)
	elseif a >= 1e3 then return string.format("%.1fK", n / 1e3) end
	return tostring(math.floor(n))
end

local function rarityPasses(rarityName)
	if next(Config.Rarities) == nil then return true end
	return Config.Rarities[rarityName] == true
end

---------------------------------------------------------------------
-- ESP
---------------------------------------------------------------------
local function clearEsp()
	local folder = workspace:FindFirstChild("AreaEggSlotsClient")
	if not folder then return end
	for _, slot in ipairs(folder:GetChildren()) do
		local g = slot:FindFirstChild(TAG_GUI)
		local h = slot:FindFirstChild(TAG_HL)
		if g then g:Destroy() end
		if h then h:Destroy() end
	end
end

local function buildBillboard(slot, hitbox)
	local gui = Instance.new("BillboardGui")
	gui.Name = TAG_GUI
	gui.AlwaysOnTop = true
	gui.Size = UDim2.fromOffset(220, 72)
	gui.StudsOffset = Vector3.new(0, 4.4, 0)
	gui.MaxDistance = 1000
	gui.Adornee = hitbox

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.AnchorPoint = Vector2.new(0.5, 1)
	icon.Position = UDim2.fromScale(0.5, 0.42)
	icon.Size = UDim2.fromOffset(30, 30)
	icon.BackgroundTransparency = 1
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Visible = false
	icon.Parent = gui

	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.AnchorPoint = Vector2.new(0.5, 0)
	text.Position = UDim2.fromScale(0.5, 0.45)
	text.Size = UDim2.fromScale(1, 0.55)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextSize = 13
	text.TextStrokeTransparency = 0.35
	text.Parent = gui

	gui.Parent = slot
	return gui
end

local function updateEsp()
	local folder = workspace:FindFirstChild("AreaEggSlotsClient")
	if not folder then return end

	local records = {}
	local snapshot = EggState.ReadFieldEggs()
	for _, rec in pairs(snapshot and (snapshot.Records or snapshot) or {}) do
		if type(rec) == "table" and type(rec.Uid) == "string" then
			records[rec.Uid] = rec
		end
	end

	for _, slot in ipairs(folder:GetChildren()) do
		local rec = records[slot.Name]
		local info = rec and resolve(rec)
		local visible = Config.Esp and rec ~= nil
			and (rec.State == AreaEggs.States.Slot or rec.State == AreaEggs.States.Dropped)
			and rarityPasses(info.rarity)

		local hitbox = visible and (slot:FindFirstChild("Hitbox") or slot:FindFirstChildWhichIsA("BasePart", true))
		local gui = slot:FindFirstChild(TAG_GUI)
		local hl  = slot:FindFirstChild(TAG_HL)

		if not hitbox then
			if gui then gui:Destroy() end
			if hl then hl:Destroy() end
		else
			gui = gui or buildBillboard(slot, hitbox)
			gui.Adornee = hitbox

			local icon = gui:FindFirstChild("Icon")
			local useIcon = Config.Details.Icon and info.icon
			icon.Image = useIcon or ""
			icon.Visible = useIcon ~= nil and useIcon ~= ""

			local parts = {}
			if Config.Details.Rarity then parts[#parts + 1] = string.upper(info.rarity) end
			if Config.Details.Name then parts[#parts + 1] = info.name end
			if Config.Details.Kg then
				local kg = weightKg(rec)
				if kg then parts[#parts + 1] = string.format("%d Kg", math.floor(kg)) end
			end
			if Config.Details.Mutation and type(rec.Mutations) == "table" and next(rec.Mutations) then
				local list = {}
				for _, m in pairs(rec.Mutations) do list[#list + 1] = tostring(m) end
				table.sort(list)
				parts[#parts + 1] = table.concat(list, ", ")
			end
			if Config.Details.Value then
				local v = valuePerSec(rec)
				if v then parts[#parts + 1] = "$" .. formatNumber(v) .. "/s" end
			end

			local label = gui:FindFirstChild("Text")
			label.Text = table.concat(parts, " | ")
			label.TextColor3 = info.color

			if not (hl and hl:IsA("Highlight")) then
				if hl then hl:Destroy() end
				hl = Instance.new("Highlight")
				hl.Name = TAG_HL
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.Parent = slot
			end
			hl.Adornee = slot
			hl.FillColor = info.color
			hl.OutlineColor = info.color
			hl.FillTransparency = 0.72
			hl.OutlineTransparency = 0
		end
	end
end

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
local THEME = {
	bg       = Color3.fromRGB(24, 24, 32),
	panel    = Color3.fromRGB(34, 34, 46),
	item     = Color3.fromRGB(44, 44, 60),
	accent   = Color3.fromRGB(99, 102, 241),
	on       = Color3.fromRGB(74, 222, 128),
	off      = Color3.fromRGB(90, 90, 110),
	text     = Color3.fromRGB(235, 235, 245),
	subtext  = Color3.fromRGB(160, 160, 180),
}

local function create(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do obj[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = obj end
	return obj
end

local function corner(r) return create("UICorner", {CornerRadius = UDim.new(0, r or 8)}) end
local function pad(n) return create("UIPadding", {
	PaddingTop = UDim.new(0, n), PaddingBottom = UDim.new(0, n),
	PaddingLeft = UDim.new(0, n), PaddingRight = UDim.new(0, n),
}) end

local gui = create("ScreenGui", {
	Name = "EggEspMenu",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
})
do
	local ok = pcall(function()
		gui.Parent = (gethui and gethui()) or CoreGui
	end)
	if not ok then gui.Parent = localPlayer:WaitForChild("PlayerGui") end
end

local connections = {}
local function track(conn) connections[#connections + 1] = conn return conn end

-- Generic drag helper. `onTap` is fired when the pointer barely moved (click).
local function makeDraggable(handle, target, onTap)
	local dragging, startPos, startInput, moved = false, nil, nil, 0

	track(handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging, moved = true, 0
			startPos = Vector2.new(input.Position.X, input.Position.Y)
			startInput = target.Position
			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
					if onTap and moved < 6 then onTap() end
				end
			end)
		end
	end))

	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - startPos
			moved = math.max(moved, delta.Magnitude)
			target.Position = UDim2.new(
				startInput.X.Scale, startInput.X.Offset + delta.X,
				startInput.Y.Scale, startInput.Y.Offset + delta.Y
			)
		end
	end))
end

-- Main window ---------------------------------------------------------
local window = create("Frame", {
	Name = "Window",
	Size = UDim2.fromOffset(300, 380),
	Position = UDim2.new(0.5, -150, 0.5, -190),
	BackgroundColor3 = THEME.bg,
	BorderSizePixel = 0,
	Visible = false,
	Parent = gui,
}, {
	corner(12),
	create("UIStroke", {Color = THEME.accent, Thickness = 1.5, Transparency = 0.35}),
})

local titleBar = create("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, 38),
	BackgroundColor3 = THEME.panel,
	BorderSizePixel = 0,
	Parent = window,
}, {corner(12)})
-- square off the bottom corners of the title bar
create("Frame", {
	Size = UDim2.new(1, 0, 0, 12),
	Position = UDim2.new(0, 0, 1, -12),
	BackgroundColor3 = THEME.panel,
	BorderSizePixel = 0,
	Parent = titleBar,
})
create("TextLabel", {
	Size = UDim2.new(1, -50, 1, 0),
	Position = UDim2.fromOffset(14, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = THEME.text,
	Text = "Egg ESP",
	Parent = titleBar,
})
local closeBtn = create("TextButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -34, 0, 5),
	BackgroundColor3 = THEME.item,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextColor3 = THEME.text,
	Text = "X",
	AutoButtonColor = true,
	Parent = titleBar,
}, {corner(8)})

local body = create("ScrollingFrame", {
	Name = "Body",
	Size = UDim2.new(1, 0, 1, -38),
	Position = UDim2.fromOffset(0, 38),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = THEME.accent,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent = window,
}, {
	pad(10),
	create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}),
})

local order = 0
local function nextOrder() order += 1 return order end

local function sectionLabel(text)
	return create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.subtext,
		Text = string.upper(text),
		LayoutOrder = nextOrder(),
		Parent = body,
	})
end

-- A row with a label and a switch
local function addSwitch(text, default, callback, parent)
	local row = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = THEME.item,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = nextOrder(),
		Parent = parent or body,
	}, {corner(8)})
	create("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.text,
		Text = text,
		Parent = row,
	})
	local track_ = create("Frame", {
		Size = UDim2.fromOffset(38, 20),
		Position = UDim2.new(1, -48, 0.5, -10),
		BackgroundColor3 = THEME.off,
		BorderSizePixel = 0,
		Parent = row,
	}, {corner(10)})
	local knob = create("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Parent = track_,
	}, {corner(8)})

	local state = default
	local function render()
		local info = TweenInfo.new(0.15)
		TweenService:Create(track_, info, {BackgroundColor3 = state and THEME.on or THEME.off}):Play()
		TweenService:Create(knob, info, {Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)}):Play()
	end
	render()
	row.Activated:Connect(function()
		state = not state
		render()
		callback(state)
	end)
end

-- ESP section
sectionLabel("ESP")
addSwitch("Egg ESP", Config.Esp, function(v)
	Config.Esp = v
	if v then updateEsp() else clearEsp() end
end)

-- Select Rarity section
sectionLabel("Select Rarity  (none = all)")

local chipHolder = create("Frame", {
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundColor3 = THEME.item,
	BorderSizePixel = 0,
	LayoutOrder = nextOrder(),
	Parent = body,
}, {
	corner(8),
	pad(8),
	create("UIGridLayout", {
		CellSize = UDim2.new(0.333, -6, 0, 28),
		CellPadding = UDim2.fromOffset(6, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

local rarityNames = {}
for name in pairs(Assets.ByRarity or {}) do rarityNames[#rarityNames + 1] = name end
table.sort(rarityNames, function(a, b)
	local ra, rb = RARITY_RANK[a] or 99, RARITY_RANK[b] or 99
	if ra ~= rb then return ra < rb end
	return tostring(a) < tostring(b)
end)

local chips = {}
local function renderChip(name)
	local chip = chips[name]
	local selected = Config.Rarities[name] == true
	chip.BackgroundColor3 = selected and THEME.accent or THEME.panel
	chip.TextColor3 = selected and Color3.new(1, 1, 1) or THEME.subtext
end

for i, name in ipairs(rarityNames) do
	local chip = create("TextButton", {
		BackgroundColor3 = THEME.panel,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		Text = name,
		TextColor3 = THEME.subtext,
		AutoButtonColor = false,
		LayoutOrder = i,
		Parent = chipHolder,
	}, {corner(6)})
	chips[name] = chip
	chip.Activated:Connect(function()
		Config.Rarities[name] = not Config.Rarities[name] or nil
		renderChip(name)
		if Config.Esp then updateEsp() end
	end)
end

local clearBtn = create("TextButton", {
	Size = UDim2.new(1, 0, 0, 30),
	BackgroundColor3 = THEME.item,
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = THEME.text,
	Text = "Clear selection",
	LayoutOrder = nextOrder(),
	Parent = body,
}, {corner(8)})
clearBtn.Activated:Connect(function()
	table.clear(Config.Rarities)
	for name in pairs(chips) do renderChip(name) end
	if Config.Esp then updateEsp() end
end)

-- ESP details section
sectionLabel("ESP details")
for _, key in ipairs({"Icon", "Rarity", "Name", "Kg", "Mutation", "Value"}) do
	addSwitch(key, Config.Details[key], function(v)
		Config.Details[key] = v
		if Config.Esp then updateEsp() end
	end)
end

-- Toggle button (draggable) -------------------------------------------
local toggleBtn = create("TextButton", {
	Name = "ToggleButton",
	Size = UDim2.fromOffset(48, 48),
	Position = UDim2.new(0, 20, 0.5, -24),
	BackgroundColor3 = THEME.accent,
	Font = Enum.Font.GothamBold,
	Text = "",
	AutoButtonColor = false,
	Parent = gui,
}, {
	corner(24),
	create("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 1.5, Transparency = 0.6}),
})

-- Egg icon drawn with UI (no emoji / image needed)
create("Frame", {
	Name = "EggIcon",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(20, 26),
	BackgroundColor3 = Color3.fromRGB(255, 244, 214),
	BorderSizePixel = 0,
	Active = false,
	Parent = toggleBtn,
}, {
	create("UICorner", {CornerRadius = UDim.new(0.5, 0)}),
	create("UIStroke", {Color = Color3.fromRGB(120, 90, 40), Thickness = 1.5}),
})

-- Use the game's real egg image on the toggle button (falls back to the drawn egg)
do
	local best, bestRank
	for _, asset in pairs(Assets.Directory or {}) do
		if type(asset) == "table" and type(asset.Egg) == "table" and type(asset.Egg.Icon) == "string" then
			local r = asset.Rarity and (asset.Rarity.DisplayName or asset.Rarity._id)
			local rank = RARITY_RANK[r] or 99
			if not bestRank or rank < bestRank then best, bestRank = asset.Egg.Icon, rank end
		end
	end
	if best then
		create("ImageLabel", {
			Name = "EggImage",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(34, 34),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			Image = best,
			Active = false,
			Parent = toggleBtn,
		})
		local drawn = toggleBtn:FindFirstChild("EggIcon")
		if drawn then drawn.Visible = false end
	end
end

local function setMenu(open)
	window.Visible = open
	toggleBtn.BackgroundColor3 = open and THEME.on or THEME.accent
end

makeDraggable(toggleBtn, toggleBtn, function() setMenu(not window.Visible) end)
makeDraggable(titleBar, window)
closeBtn.Activated:Connect(function() setMenu(false) end)

---------------------------------------------------------------------
-- Runtime loop + cleanup
---------------------------------------------------------------------
local alive = true

task.spawn(function()
	while alive do
		if Config.Esp then
			local ok, err = pcall(updateEsp)
			if not ok then warn("[EggESP] update error: " .. tostring(err)) end
		end
		task.wait(0.4)
	end
end)

genv.__EggEspMenuUnload = function()
	alive = false
	for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
	pcall(clearEsp)
	pcall(function() gui:Destroy() end)
	genv.__EggEspMenuUnload = nil
end
