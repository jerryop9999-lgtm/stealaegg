-- ==========================================
-- OLIVER | Steal an Egg - Mod Instant & Full Protection (Final)
-- ==========================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
local TITLE = "OLIVER."
local VERSION = "V3.6 Mod Instant"
local LOGO_ID = "rbxassetid://77896693340732"
local ACCENT = Color3.fromRGB(110, 120, 255)

local SAFE_POS = Vector3.new(542.93, 71.5, -405.58) -- safe area (ផ្ទះ)
local SAFE_RADIUS = 30

------------------------------------------------------------
-- Modules របស់ហ្គេម
------------------------------------------------------------
local EggState = require(RS.Client.EggState)
local Remotes = require(RS.Shared.Remotes)
local AreaEggs = require(RS.Shared.Types.AreaEggs)
local Assets = require(RS.Data.Assets)
local eggWorld = Remotes.EggWorld
local okER, EggRecords = pcall(function() return require(RS.Shared.Util.EggRecords) end)

------------------------------------------------------------
-- AUTO STEAL & MOD INSTANT MODE
------------------------------------------------------------
local RARITIES = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic", "Secret", "Eternal", "Divine"}
local RARITY_COLORS = {
	Common = Color3.fromRGB(170, 175, 190),
	Uncommon = Color3.fromRGB(90, 210, 120),
	Rare = Color3.fromRGB(80, 160, 255),
	Epic = Color3.fromRGB(170, 100, 255),
	Legendary = Color3.fromRGB(255, 170, 60),
	Mythic = Color3.fromRGB(255, 90, 90),
	Cosmic = Color3.fromRGB(70, 220, 230),
	Secret = Color3.fromRGB(255, 100, 190),
	Eternal = Color3.fromRGB(255, 215, 90),
	Divine = Color3.fromRGB(255, 245, 200),
}

local Steal = {
	enabled = false,
	status = "Idle",
	target = "-",
	carrying = false,
	rarities = {},      
	speed = 1000,         -- ល្បឿនលឿនសម្រាប់ Mod Instant
	vip = {Secret = true, Eternal = true, Divine = true}, 
}
local token = 0

local function rarityOf(rec)
	local a = Assets.Directory[rec.AssetCategory]
	local r = a and a.Rarity
	return r and (r.DisplayName or r._id) or "Unknown"
end

local function rarityRank(rec)
	local name = rarityOf(rec)
	for i, n in ipairs(RARITIES) do
		if n == name then return i end
	end
	return 0
end

local function weightOf(rec)
	if okER and EggRecords and type(EggRecords.WeightKgForScale) == "function" then
		local ok, r = pcall(EggRecords.WeightKgForScale, rec.AssetCategory, tonumber(rec.AssetScale) or 1)
		if ok and type(r) == "number" then return r end
	end
	return 0
end

local function isVip(rec)
	return Steal.vip[rarityOf(rec)] == true
end

local function passesFilter(rec)
	if next(Steal.rarities) == nil then return true end
	return Steal.rarities[rarityOf(rec)] == true
end

local function getRoot()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function safeTarget()
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}
	local hit = workspace:Raycast(SAFE_POS + Vector3.new(0, 60, 0), Vector3.new(0, -200, 0), params)
	if hit then
		return Vector3.new(SAFE_POS.X, hit.Position.Y + 3.2, SAFE_POS.Z)
	end
	return SAFE_POS
end

local function inSafe(root)
	local d = root.Position - SAFE_POS
	return Vector2.new(d.X, d.Z).Magnitude <= SAFE_RADIUS and math.abs(d.Y) <= 18
end

------------------------------------------------------------
-- PROTECTION SYSTEM (Anti-Cheat & Anti-Death)
------------------------------------------------------------
local Protect = {pad = nil, conn = nil, hb = nil, autoRotate = nil}

local function ensureProtect()
	local root, hum = getRoot()
	if not root or not hum then return end
	if root:GetAttribute("KillPartIgnore") ~= true then
		root:SetAttribute("KillPartIgnore", true)
	end
	if Protect.autoRotate == nil then
		Protect.autoRotate = hum.AutoRotate
		hum.AutoRotate = false
	end
	if not (Protect.pad and Protect.pad.Parent) then
		local part = Instance.new("Part")
		part.Name = "OliverHoverPad"
		part.Anchored = true
		part.CanCollide = true
		part.CanQuery = false 
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(8, 1, 8)
		part.Parent = workspace
		Protect.pad = part
	end
	if not Protect.hb then
		local function pin()
			local r, h = getRoot()
			if not r or not h then return end
			pcall(function()
				h.BreakJointsOnDeath = false
				h.RequiresNeck = false
				h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
				if h.Health <= 0 then h.Health = math.max(h.MaxHealth, 100) end
				if h:GetState() == Enum.HumanoidStateType.Dead then
					h:ChangeState(Enum.HumanoidStateType.Running)
				end
				if r.Anchored then r.Anchored = false end
			end)
		end
		pin()
		Protect.hb = RunService.Heartbeat:Connect(pin)
	end
	if not Protect.conn then
		Protect.conn = RunService.PreSimulation:Connect(function()
			local r, h = getRoot()
			if r and h and Protect.pad and Protect.pad.Parent then
				local p = r.Position
				local feet = h.HipHeight + r.Size.Y / 2
				Protect.pad.CFrame = CFrame.new(p.X, p.Y - feet - 0.55, p.Z)
			end
		end)
	end
end

local function stopProtect()
	if Protect.conn then Protect.conn:Disconnect() Protect.conn = nil end
	if Protect.hb then Protect.hb:Disconnect() Protect.hb = nil end
	if Protect.pad then Protect.pad:Destroy() Protect.pad = nil end
	local root, hum = getRoot()
	if root then root:SetAttribute("KillPartIgnore", nil) end
	if hum then
		pcall(function()
			hum.BreakJointsOnDeath = true
			hum.RequiresNeck = true
			hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		end)
	end
	if hum and Protect.autoRotate ~= nil then hum.AutoRotate = Protect.autoRotate end
	Protect.autoRotate = nil
end

local MIN_SPEED, MAX_SPEED = 500, 1500

local function travel(pos, abort)
	local speed = math.clamp(Steal.speed, MIN_SPEED, MAX_SPEED)
	local slowUntil, lastMag, arrivedAt = 0, nil, nil
	while true do
		local root, hum = getRoot()
		if not root or not hum or hum.Health <= 0 then return false end
		if abort and abort() then return false end
		local dt = RunService.Heartbeat:Wait()
		root, hum = getRoot()
		if not root or not hum then return false end
		dt = math.max(math.min(dt, 0.15), 1 / 240)

		local cur = root.Position
		local delta = pos - cur
		local mag = delta.Magnitude
		local flat = Vector3.new(delta.X, 0, delta.Z)
		local look = root.CFrame.LookVector
		local lookFlat = Vector3.new(look.X, 0, look.Z)
		local face = flat.Magnitude > 0.001 and flat.Unit
			or (lookFlat.Magnitude > 0.001 and lookFlat.Unit or Vector3.new(0, 0, -1))

		if lastMag and mag > lastMag + 2 then
			slowUntil = os.clock() + 0.1
		end
		lastMag = mag
		local curSpeed = os.clock() < slowUntil and math.max(MIN_SPEED, speed * 0.45) or speed
		local step = curSpeed * dt

		if mag <= math.max(step, 0.05) then
			root.CFrame = CFrame.lookAt(pos, pos + face)
			root.AssemblyLinearVelocity = Vector3.zero
			arrivedAt = arrivedAt or os.clock()
			if os.clock() - arrivedAt >= 0.01 then return true end
		else
			arrivedAt = nil
			local nextPos = cur + delta.Unit * math.min(step, mag)
			root.CFrame = CFrame.lookAt(nextPos, nextPos + face)
			root.AssemblyLinearVelocity = Vector3.zero
		end
	end
end

local function wallSealed()
	local ok, res = pcall(function()
		return require(RS.Client.AreaEggResetWall).IsSealed()
	end)
	return ok and res == true
end

local function readRecords()
	local ok, snap = pcall(EggState.ReadFieldEggs)
	if ok and snap then return snap.Records or {} end
	return {}
end

local function myCarriedEgg()
	for _, rec in ipairs(readRecords()) do
		if rec.State == AreaEggs.States.Carried and rec.CarrierUserId == player.UserId then
			return rec
		end
	end
end

local function findByUid(uid)
	for _, rec in ipairs(readRecords()) do
		if rec.Uid == uid then return rec end
	end
end

local function eggPos(rec)
	local cf = rec.BottomCFrame or rec.BoundsCFrame
	return cf and cf.Position
end

local function pickTarget(skip)
	local root = getRoot()
	if not root then return nil end
	local best, bestRank, bestW, bestDist
	for _, rec in ipairs(readRecords()) do
		if (rec.State == AreaEggs.States.Slot or rec.State == AreaEggs.States.Dropped)
		and passesFilter(rec) and (isVip(rec) or not skip[rec.Uid]) then
			local pos = eggPos(rec)
			if pos then
				local rank = rarityRank(rec)
				local w = weightOf(rec)
				local d = (pos - root.Position).Magnitude
				local better = not best
					or rank > bestRank
					or (rank == bestRank and w > bestW + 1e-6)
					or (rank == bestRank and math.abs(w - bestW) <= 1e-6 and d < bestDist)
				if better then
					best, bestRank, bestW, bestDist = rec, rank, w, d
				end
			end
		end
	end
	return best
end

------------------------------------------------------------
-- MOD INSTANT LOOP (True Instant Server Call)
------------------------------------------------------------
local function stealLoop(myToken)
	local lastUid
	local skip = {}
	local function stopped() return not Steal.enabled or token ~= myToken end

	while not stopped() do
		local root, hum = getRoot()
		if not root or not hum or hum.Health <= 0 then
			Steal.status = "Waiting for character"
			task.wait(0.1)
		else
			ensureProtect()
			local carried = myCarriedEgg()
			Steal.carrying = carried ~= nil

			if carried then
				lastUid = carried.Uid
				Steal.status = "Mod Instant Delivering..."
				if not inSafe(root) then
					travel(safeTarget(), function() return stopped() or not myCarriedEgg() end)
				else
					Steal.status = "Deposited"
					root.CFrame = CFrame.new(safeTarget()) * (root.CFrame - root.CFrame.Position)
					root.AssemblyLinearVelocity = Vector3.zero
					task.wait(0.01)
				end
			elseif wallSealed() then
				Steal.status = "Egg reset - waiting"
				task.wait(0.1)
			else
				local target
				if lastUid then
					local rec = findByUid(lastUid)
					if rec and rec.State == AreaEggs.States.Dropped then
						target = rec
						Steal.status = "Mod Instant Re-grabbing"
					else
						lastUid = nil
					end
				end
				target = target or pickTarget(skip)

				if not target then
					skip = {}
					Steal.target = "-"
					Steal.status = "No egg found"
					task.wait(0.1)
				else
					local rname = rarityOf(target)
					local wtxt = string.format("%s %.1fkg", rname, weightOf(target))
					Steal.target = wtxt
					Steal.status = "Mod Instant Grab: " .. wtxt
					local pos = eggPos(target)
					local arrived = pos and travel(pos + Vector3.new(0, 2, 0), function()
						if stopped() then return true end
						local r = findByUid(target.Uid)
						return not r or (r.State ~= AreaEggs.States.Slot and r.State ~= AreaEggs.States.Dropped)
					end)

					if arrived and not stopped() then
						-- MOD INSTANT MODE: ហៅ Remote ភ្លាមៗដោយគ្មានការរង់ចាំ Hold Timer
						pcall(function()
							eggWorld.AskFieldEggCarry:InvokeServer({Uid = target.Uid})
						end)
						task.wait(0.01)
						
						if myCarriedEgg() then
							lastUid = target.Uid
						else
							skip[target.Uid] = true
						end
					end
				end
			end
		end
		task.wait(0.01)
	end
	if token == myToken or not Steal.enabled then stopProtect() end
	Steal.status = "Idle"
	Steal.target = "-"
	Steal.carrying = false
end

function Steal.set(on)
	Steal.enabled = on
	token += 1
	if on then
		local t = token
		task.spawn(stealLoop, t)
	end
end

------------------------------------------------------------
-- UI & Delta Floating Button Setup
------------------------------------------------------------
local BG = Color3.fromRGB(16, 17, 24)
local BG2 = Color3.fromRGB(22, 23, 32)
local PANEL = Color3.fromRGB(30, 32, 44)
local PANEL2 = Color3.fromRGB(40, 43, 58)
local STROKE = Color3.fromRGB(52, 55, 74)
local TEXT = Color3.fromRGB(235, 237, 245)
local MUTED = Color3.fromRGB(140, 146, 170)
local GREEN = Color3.fromRGB(60, 200, 120)

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	o.Parent = parent
	return o
end
local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, o) end
local function stroke(o, c, t)
	return new("UIStroke", {Color = c, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end
local function pad(o, l, t, r, b)
	return new("UIPadding", {
		PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b),
	}, o)
end
local function label(parent, text, size, color, font, xalign)
	return new("TextLabel", {
		BackgroundTransparency = 1, Text = text, TextSize = size, TextColor3 = color or TEXT,
		Font = font or Enum.Font.Gotham, TextXAlignment = xalign or Enum.TextXAlignment.Left,
	}, parent)
end
local function tween(o, t, props)
	TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function makeDraggable(handle, target)
	local dragging, dragStart, startPos
	local moved = false
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			if d.Magnitude > 5 then moved = true end
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	return function() return moved end
end

local parentGui = player:WaitForChild("PlayerGui")
pcall(function()
	if gethui then parentGui = gethui() end
end)

local old = parentGui:FindFirstChild("OliverAutoStealFinal")
if old then old:Destroy() end

local gui = new("ScreenGui", {
	Name = "OliverAutoStealFinal", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parentGui)

local main = new("Frame", {
	Size = UDim2.fromOffset(420, 260), Position = UDim2.new(0.5, -210, 0.5, -130),
	BackgroundColor3 = BG, ClipsDescendants = true,
}, gui)
corner(main, 14)
stroke(main, STROKE, 1)
local scale = new("UIScale", {Scale = 1}, main)

local header = new("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = BG2}, main)
corner(header, 14)
new("Frame", {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14), BackgroundColor3 = BG2, BorderSizePixel = 0}, header)
local titleLbl = label(header, TITLE, 17, ACCENT, Enum.Font.GothamBold)
titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
titleLbl.Position = UDim2.fromOffset(14, 0)
local verLbl = label(header, VERSION, 13, MUTED, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
verLbl.Size = UDim2.new(0.5, 0, 1, 0)
verLbl.Position = UDim2.new(0, -14, 0, 0)
new("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = STROKE, BorderSizePixel = 0}, header)

local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -36, 0, 6),
	BackgroundColor3 = PANEL, Text = "✕", TextColor3 = MUTED, TextSize = 14,
	Font = Enum.Font.GothamBold, AutoButtonColor = false,
}, header)
corner(closeBtn, 8)
makeDraggable(header, main)

local body = new("Frame", {Size = UDim2.new(1, 0, 1, -40), Position = UDim2.fromOffset(0, 40), BackgroundTransparency = 1}, main)
local rail = new("Frame", {Size = UDim2.new(0, 122, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0}, body)
pad(rail, 8, 10, 8, 8)
new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, rail)

new("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.fromOffset(121, 0), BackgroundColor3 = STROKE, BorderSizePixel = 0}, body)
local pagesHolder = new("Frame", {Size = UDim2.new(1, -122, 1, 0), Position = UDim2.fromOffset(122, 0), BackgroundTransparency = 1}, body)

local tabs = {}
local function selectTab(name)
	for n, t in pairs(tabs) do
		local on = n == name
		t.page.Visible = on
		tween(t.btn, 0.15, {BackgroundTransparency = on and 0 or 1, BackgroundColor3 = on and PANEL2 or PANEL})
		t.btn.TextColor3 = on and TEXT or MUTED
		t.bar.Visible = on
	end
end
local function addTab(name, glyph, order)
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = PANEL, BackgroundTransparency = 1,
		Text = "  " .. glyph .. "  " .. name, TextColor3 = MUTED, TextSize = 12,
		Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false, LayoutOrder = order, TextTruncate = Enum.TextTruncate.AtEnd,
	}, rail)
	corner(btn, 8)
	local bar = new("Frame", {Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 0, 0.5, -9), BackgroundColor3 = ACCENT, Visible = false}, btn)
	corner(bar, 2)
	local page = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, ScrollBarImageColor3 = STROKE, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
	}, pagesHolder)
	pad(page, 10, 10, 12, 10)
	new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
	tabs[name] = {btn = btn, page = page, bar = bar}
	btn.MouseButton1Click:Connect(function() selectTab(name) end)
	return page
end

local stealPage = addTab("Main", "◆", 1)

local function makeSection(parent, title, order, startOpen)
	local card = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = PANEL, LayoutOrder = order,
	}, parent)
	corner(card, 10)
	stroke(card, STROKE, 1)
	new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, card)

	local head = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = 1,
	}, card)
	local t = label(head, title, 14, TEXT, Enum.Font.GothamBold)
	t.Size = UDim2.new(1, -50, 1, 0)
	t.Position = UDim2.fromOffset(12, 0)
	local arrow = label(head, startOpen and "↓" or "↑", 18, ACCENT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	arrow.Size = UDim2.fromOffset(30, 38)
	arrow.Position = UDim2.new(1, -38, 0, 0)

	local content = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Visible = startOpen, LayoutOrder = 2,
	}, card)
	pad(content, 10, 0, 10, 10)
	new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, content)

	head.MouseButton1Click:Connect(function()
		content.Visible = not content.Visible
		arrow.Text = content.Visible and "↓" or "↑"
	end)
	return content
end

local toggleCard = new("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = PANEL, LayoutOrder = 0}, stealPage)
corner(toggleCard, 10)
local toggleStroke = stroke(toggleCard, STROKE, 1)
local toggleTitle = label(toggleCard, "Auto Mod Instant", 16, TEXT, Enum.Font.GothamBold)
toggleTitle.Size = UDim2.new(1, -80, 0, 22)
toggleTitle.Position = UDim2.fromOffset(14, 8)
local toggleSub = label(toggleCard, "Idle", 11, MUTED)
toggleSub.Size = UDim2.new(1, -80, 0, 16)
toggleSub.Position = UDim2.fromOffset(14, 31)
toggleSub.TextTruncate = Enum.TextTruncate.AtEnd

local pill = new("Frame", {Size = UDim2.fromOffset(46, 24), Position = UDim2.new(1, -60, 0.5, -12), BackgroundColor3 = PANEL2}, toggleCard)
corner(pill, 12)
local knob = new("Frame", {Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = TEXT}, pill)
corner(knob, 9)
local toggleBtn = new("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 5}, toggleCard)

local function renderToggle(on)
	tween(pill, 0.15, {BackgroundColor3 = on and GREEN or PANEL2})
	tween(knob, 0.15, {Position = on and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3)})
	tween(toggleStroke, 0.15, {Color = on and GREEN or STROKE})
end
toggleBtn.MouseButton1Click:Connect(function()
	Steal.set(not Steal.enabled)
	renderToggle(Steal.enabled)
end)

local filters = makeSection(stealPage, "Filters / Rarity", 1, false)
local grid = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2}, filters)
new("UIGridLayout", {CellSize = UDim2.new(1 / 3, -5, 0, 28), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder}, grid)

local chips = {}
local function renderChip(name)
	local c = chips[name]
	local on = Steal.rarities[name] == true
	local col = RARITY_COLORS[name]
	tween(c.btn, 0.12, {BackgroundColor3 = on and col or PANEL2})
	c.btn.TextColor3 = on and Color3.fromRGB(20, 20, 28) or col
end
for i, name in ipairs(RARITIES) do
	local b = new("TextButton", {
		BackgroundColor3 = PANEL2, Text = name, TextSize = 12, Font = Enum.Font.GothamMedium,
		TextColor3 = RARITY_COLORS[name], AutoButtonColor = false, LayoutOrder = i,
	}, grid)
	corner(b, 7)
	chips[name] = {btn = b}
	b.MouseButton1Click:Connect(function()
		Steal.rarities[name] = (not Steal.rarities[name]) or nil
		renderChip(name)
	end)
end

-- Floating Button
local hasLogo = LOGO_ID ~= "" and not LOGO_ID:match("^rbxassetid://0?$")
local fab = new("ImageButton", {
	Size = UDim2.fromOffset(54, 54), Position = UDim2.new(0, 16, 0.5, -27),
	BackgroundColor3 = PANEL, Image = hasLogo and LOGO_ID or "", ScaleType = Enum.ScaleType.Crop,
	AutoButtonColor = false, ZIndex = 20,
}, gui)
corner(fab, 27)
stroke(fab, ACCENT, 2)
if not hasLogo then
	local l = label(fab, TITLE:sub(1, 1), 24, ACCENT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	l.Size = UDim2.new(1, 0, 1, 0)
	l.ZIndex = 21
end
local liveDot = new("Frame", {
	Size = UDim2.fromOffset(12, 12), Position = UDim2.new(1, -14, 0, 2), BackgroundColor3 = GREEN, Visible = false, ZIndex = 22,
}, fab)
corner(liveDot, 6)
stroke(liveDot, BG, 2)

local opened = true
local function setOpen(v)
	opened = v
	if v then
		main.Visible = true
		scale.Scale = 0.85
		TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	else
		tween(scale, 0.12, {Scale = 0.85})
		task.delay(0.12, function()
			if not opened then main.Visible = false end
		end)
	end
end
local fabMoved = makeDraggable(fab, fab)
fab.MouseButton1Click:Connect(function()
	if not fabMoved() then setOpen(not opened) end
end)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)

selectTab("Main")

task.spawn(function()
	while gui.Parent do
		toggleSub.Text = Steal.status
		liveDot.Visible = Steal.enabled
		task.wait(0.25)
	end
end)