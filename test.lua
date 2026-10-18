-- OLIVER | Steal an Egg  -  Auto Steal (Tween)
-- ដំណើរការតាម executor (ត្រូវការ require ក្នុង ReplicatedStorage)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
local TITLE = "OLIVER"
local LOGO_ID = "rbxassetid://0" -- ← ដាក់ Logo ID របស់អ្នកនៅទីនេះ (ឧ. "rbxassetid://123456789")
local ACCENT = Color3.fromRGB(110, 120, 255)

local SAFE_POS = Vector3.new(542.93, 71.5, -405.58) -- safe area (ផ្ទះ)
local SAFE_RADIUS = 30

------------------------------------------------------------
-- Modules របស់ហ្គេម (ដូចក្នុង Sena)
------------------------------------------------------------
local EggState = require(RS.Client.EggState)
local Remotes = require(RS.Shared.Remotes)
local AreaEggs = require(RS.Shared.Types.AreaEggs)
local Assets = require(RS.Data.Assets)
local eggWorld = Remotes.EggWorld

------------------------------------------------------------
-- AUTO STEAL (Tween)
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
local MODES = {
	{name = "Instant Steal", speed = 600, desc = "Fastest tween, straight line"},
	{name = "High Speed Normal", speed = 300, desc = "Ground tween (default)"},
	{name = "High Speed (Fly)", speed = 300, desc = "Tween up, across, then down"},
	{name = "Zig-Zag", speed = 300, desc = "Tween with side-to-side path"},
}

local Steal = {
	enabled = false,
	status = "Idle",
	target = "-",
	guard = "Sleeping",
	carrying = false,
	mode = "High Speed Normal",
	rarities = {},      -- ទទេ = យកទាំងអស់ (ល្អបំផុតមុន)
	holdSeconds = 5,    -- ឈរលើស៊ុតមុនយក (Sena: ~5s)
	flyHeight = 60,
	vip = {Secret = true, Eternal = true, Divine = true}, -- មិនរំលង ព្យាយាមរហូត
}
local token = 0

local function modeSpeed()
	for _, m in ipairs(MODES) do
		if m.name == Steal.mode then return m.speed end
	end
	return 300
end

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

-- Tween ទៅទីតាំង (TweenService) - អាចបញ្ឈប់ពាក់កណ្តាលផ្លូវបានតាម abort()
local function tweenTo(pos, abort)
	local root = getRoot()
	if not root then return false end
	local dist = (root.Position - pos).Magnitude
	if dist < 1 then return true end
	local keepRot = root.CFrame - root.CFrame.Position
	local tw = TweenService:Create(
		root,
		TweenInfo.new(math.max(dist / modeSpeed(), 0.03), Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(pos) * keepRot}
	)
	tw:Play()
	local aborted = false
	while tw.PlaybackState == Enum.PlaybackState.Playing or tw.PlaybackState == Enum.PlaybackState.Begin do
		if not root.Parent or (abort and abort()) then
			aborted = true
			tw:Cancel()
			break
		end
		RunService.Heartbeat:Wait()
	end
	if root.Parent then
		root.AssemblyLinearVelocity = Vector3.zero
	end
	return not aborted
end

-- ជ្រើសផ្លូវតាម MOD (ទាំងអស់ប្រើ Tween)
local function travel(pos, abort)
	local root = getRoot()
	if not root then return false end
	local mode = Steal.mode
	if mode == "High Speed (Fly)" then
		local alt = math.max(root.Position.Y, pos.Y) + Steal.flyHeight
		return tweenTo(Vector3.new(root.Position.X, alt, root.Position.Z), abort)
			and tweenTo(Vector3.new(pos.X, alt, pos.Z), abort)
			and tweenTo(pos, abort)
	elseif mode == "Zig-Zag" then
		local from = root.Position
		local flat = Vector3.new(pos.X - from.X, 0, pos.Z - from.Z)
		local len = flat.Magnitude
		if len > 30 then
			local dir = flat.Unit
			local side = Vector3.new(-dir.Z, 0, dir.X)
			local n = math.floor(len / 25)
			for i = 1, n do
				local base = from + dir * (len * i / (n + 1))
				local wp = base + side * (i % 2 == 0 and 14 or -14)
				if not tweenTo(Vector3.new(wp.X, from.Y + (pos.Y - from.Y) * i / (n + 1), wp.Z), abort) then
					return false
				end
			end
		end
		return tweenTo(pos, abort)
	end
	return tweenTo(pos, abort)
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

-- ស្ថានភាព guard (attribute GuardState: Sleeping / Waking / Chasing)
local guardAreasFolder
local function guardState()
	if not (guardAreasFolder and guardAreasFolder.Parent) then
		guardAreasFolder = nil
		for _, d in ipairs(workspace:GetDescendants()) do
			if d.Name == "GuardAreas" then guardAreasFolder = d break end
		end
	end
	local name = "Sleeping"
	if guardAreasFolder then
		for _, area in ipairs(guardAreasFolder:GetChildren()) do
			local g = area:FindFirstChild("Guard")
			local st = g and g:GetAttribute("GuardState")
			if st == "Waking" or st == "Chasing" then return true, st end
			if st then name = st end
		end
	end
	return false, name
end

-- ជ្រើសស៊ុត: rarity ខ្ពស់បំផុតមុន បន្ទាប់មកជិតបំផុត
local function pickTarget(skip)
	local root = getRoot()
	if not root then return nil end
	local best, bestRank, bestDist
	for _, rec in ipairs(readRecords()) do
		if (rec.State == AreaEggs.States.Slot or rec.State == AreaEggs.States.Dropped)
		and passesFilter(rec) and (isVip(rec) or not skip[rec.Uid]) then
			local pos = eggPos(rec)
			if pos then
				local rank = rarityRank(rec)
				local d = (pos - root.Position).Magnitude
				if not best or rank > bestRank or (rank == bestRank and d < bestDist) then
					best, bestRank, bestDist = rec, rank, d
				end
			end
		end
	end
	return best
end

local function stealLoop(myToken)
	local lastUid
	local calmSince
	local skip = {}
	local function stopped() return not Steal.enabled or token ~= myToken end

	while not stopped() do
		local root, hum = getRoot()
		if not root or not hum or hum.Health <= 0 then
			Steal.status = "Waiting for character"
			task.wait(1)
		else
			local carried = myCarriedEgg()
			local awake, gst = guardState()
			Steal.carrying = carried ~= nil
			Steal.guard = gst

			if carried then
				-- ដឹកទៅ safe area ហើយឈរចាំ server ទទួលស៊ុត
				lastUid = carried.Uid
				Steal.status = "Delivering egg"
				if not inSafe(root) then
					travel(safeTarget(), function() return stopped() or not myCarriedEgg() end)
				else
					Steal.status = "Waiting for deposit"
					root.CFrame = CFrame.new(safeTarget()) * (root.CFrame - root.CFrame.Position)
					root.AssemblyLinearVelocity = Vector3.zero
					task.wait(0.1)
				end
			elseif wallSealed() then
				Steal.status = "Egg reset - waiting"
				task.wait(0.5)
			elseif awake then
				-- guard ភ្ញាក់ → ត្រឡប់ទៅ safe area រង់ចាំវាដេកវិញ
				calmSince = nil
				Steal.status = "Guard " .. gst .. " - waiting"
				if not inSafe(root) then
					travel(safeTarget(), stopped)
				else
					task.wait(0.3)
				end
			elseif (function()
				calmSince = calmSince or os.clock()
				return os.clock() - calmSince < 2
			end)() then
				Steal.status = "Guard asleep - settling"
				task.wait(0.2)
			else
				local target
				-- ស៊ុតទើបធ្លាក់ ត្រូវរើសវិញមុនគេ
				if lastUid then
					local rec = findByUid(lastUid)
					if rec and rec.State == AreaEggs.States.Dropped then
						target = rec
						Steal.status = "Egg dropped - re-grabbing"
					else
						lastUid = nil
					end
				end
				target = target or pickTarget(skip)

				if not target then
					skip = {}
					Steal.target = "-"
					Steal.status = "No egg found"
					task.wait(1)
				else
					local rname = rarityOf(target)
					Steal.target = rname
					Steal.status = "Going to " .. rname
					local pos = eggPos(target)
					local arrived = pos and travel(pos + Vector3.new(0, 3, 0), function()
						if stopped() then return true end
						if select(1, guardState()) then return true end
						local r = findByUid(target.Uid)
						return not r or (r.State ~= AreaEggs.States.Slot and r.State ~= AreaEggs.States.Dropped)
					end)

					if arrived and not stopped() then
						-- ឈរជាប់លើស៊ុតមួយរយៈ ទើប server ឱ្យយក
						local holdPos = pos + Vector3.new(0, 3, 0)
						local holdUntil = os.clock() + Steal.holdSeconds
						local lost = false
						while os.clock() < holdUntil and not stopped() do
							Steal.status = string.format("Securing %s (%.1fs)", rname, holdUntil - os.clock())
							local r = findByUid(target.Uid)
							if select(1, guardState())
							or not r or (r.State ~= AreaEggs.States.Slot and r.State ~= AreaEggs.States.Dropped) then
								lost = true
								break
							end
							local rt = getRoot()
							if rt then
								rt.CFrame = CFrame.new(holdPos)
								rt.AssemblyLinearVelocity = Vector3.zero
							end
							task.wait(0.1)
						end

						if not lost and not stopped() then
							Steal.status = "Grabbing " .. rname
							local untilAt = os.clock() + 3
							while os.clock() < untilAt and not stopped() and not myCarriedEgg() do
								pcall(function()
									eggWorld.AskFieldEggCarry:InvokeServer({Uid = target.Uid})
								end)
								task.wait(0.3)
							end
							if myCarriedEgg() then
								lastUid = target.Uid
							elseif isVip(target) then
								Steal.status = "Retrying " .. rname
								task.wait(0.3)
							else
								skip[target.Uid] = true
							end
						end
					end
				end
			end
		end
		task.wait()
	end
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
-- UI
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
local old = parentGui:FindFirstChild("OliverAutoSteal")
if old then old:Destroy() end

local gui = new("ScreenGui", {
	Name = "OliverAutoSteal", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parentGui)

-- Window
local main = new("Frame", {
	Size = UDim2.fromOffset(420, 260), Position = UDim2.new(0.5, -210, 0.5, -130),
	BackgroundColor3 = BG, ClipsDescendants = true,
}, gui)
corner(main, 14)
stroke(main, STROKE, 1)
local scale = new("UIScale", {Scale = 1}, main)

-- Header
local header = new("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = BG2}, main)
corner(header, 14)
new("Frame", {Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14), BackgroundColor3 = BG2, BorderSizePixel = 0}, header)
local titleLbl = label(header, TITLE, 16, ACCENT, Enum.Font.GothamBold)
titleLbl.Size = UDim2.new(0, 90, 1, 0)
titleLbl.Position = UDim2.fromOffset(14, 0)
local subLbl = label(header, "Auto Steal  ·  Steal an Egg", 11, MUTED)
subLbl.Size = UDim2.new(1, -170, 1, 0)
subLbl.Position = UDim2.fromOffset(90, 2)
new("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = STROKE, BorderSizePixel = 0}, header)

local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -36, 0, 6),
	BackgroundColor3 = PANEL, Text = "✕", TextColor3 = MUTED, TextSize = 14,
	Font = Enum.Font.GothamBold, AutoButtonColor = false,
}, header)
corner(closeBtn, 8)
makeDraggable(header, main)

-- Tab rail
local body = new("Frame", {Size = UDim2.new(1, 0, 1, -40), Position = UDim2.fromOffset(0, 40), BackgroundTransparency = 1}, main)
local rail = new("Frame", {Size = UDim2.new(0, 104, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0}, body)
new("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = STROKE, BorderSizePixel = 0}, rail)
pad(rail, 8, 10, 8, 8)
new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, rail)

local pagesHolder = new("Frame", {Size = UDim2.new(1, -104, 1, 0), Position = UDim2.fromOffset(104, 0), BackgroundTransparency = 1}, body)

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
		Text = "  " .. glyph .. "  " .. name, TextColor3 = MUTED, TextSize = 13,
		Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false, LayoutOrder = order,
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

local stealPage = addTab("Steal", "◆", 1)
local statusPage = addTab("Status", "●", 2)

-- Collapsible card (↑ = ปิด / ↓ = เปิด)
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

-- Auto Steal switch card
local toggleCard = new("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = PANEL, LayoutOrder = 0}, stealPage)
corner(toggleCard, 10)
local toggleStroke = stroke(toggleCard, STROKE, 1)
local toggleTitle = label(toggleCard, "Auto Steal", 16, TEXT, Enum.Font.GothamBold)
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

-- Filters / Rarity
local filters = makeSection(stealPage, "Filters / Rarity", 1, false)
local hintRow = new("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 1}, filters)
local hint = label(hintRow, "None selected = best rarity first", 11, MUTED)
hint.Size = UDim2.new(1, -60, 1, 0)
local clearBtn = new("TextButton", {
	Size = UDim2.fromOffset(52, 22), Position = UDim2.new(1, -52, 0, 0), BackgroundColor3 = PANEL2,
	Text = "Clear", TextColor3 = TEXT, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false,
}, hintRow)
corner(clearBtn, 6)

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
clearBtn.MouseButton1Click:Connect(function()
	Steal.rarities = {}
	for _, name in ipairs(RARITIES) do renderChip(name) end
end)

-- MOD
local mods = makeSection(stealPage, "MOD", 2, false)
local modButtons = {}
local function renderMods()
	for name, m in pairs(modButtons) do
		local on = name == Steal.mode
		tween(m.btn, 0.12, {BackgroundColor3 = on and Color3.fromRGB(48, 52, 96) or PANEL2})
		m.stroke.Color = on and ACCENT or PANEL2
		m.dot.BackgroundColor3 = on and ACCENT or STROKE
	end
end
for i, m in ipairs(MODES) do
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = PANEL2, Text = "", AutoButtonColor = false, LayoutOrder = i,
	}, mods)
	corner(b, 8)
	local st = stroke(b, PANEL2, 1.5)
	local n = label(b, m.name, 13, TEXT, Enum.Font.GothamBold)
	n.Size = UDim2.new(1, -40, 0, 18)
	n.Position = UDim2.fromOffset(12, 5)
	local d = label(b, m.desc, 11, MUTED)
	d.Size = UDim2.new(1, -40, 0, 14)
	d.Position = UDim2.fromOffset(12, 23)
	local dot = new("Frame", {Size = UDim2.fromOffset(12, 12), Position = UDim2.new(1, -24, 0.5, -6), BackgroundColor3 = STROKE}, b)
	corner(dot, 6)
	modButtons[m.name] = {btn = b, stroke = st, dot = dot}
	b.MouseButton1Click:Connect(function()
		Steal.mode = m.name
		renderMods()
	end)
end
renderMods()
for _, name in ipairs(RARITIES) do renderChip(name) end

-- Status tab
local function infoRow(order, key)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = PANEL, LayoutOrder = order}, statusPage)
	corner(row, 8)
	local k = label(row, key, 12, MUTED)
	k.Size = UDim2.new(0.4, 0, 1, 0)
	k.Position = UDim2.fromOffset(12, 0)
	local v = label(row, "-", 12, TEXT, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
	v.Size = UDim2.new(0.6, -24, 1, 0)
	v.Position = UDim2.new(0.4, 0, 0, 0)
	v.TextTruncate = Enum.TextTruncate.AtEnd
	return v
end
local vStatus = infoRow(1, "Status")
local vTarget = infoRow(2, "Target rarity")
local vGuard = infoRow(3, "Guard")
local vCarry = infoRow(4, "Carrying egg")
local vMode = infoRow(5, "MOD")

-- Floating logo button
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

selectTab("Steal")

-- Live update
task.spawn(function()
	while gui.Parent do
		toggleSub.Text = Steal.status
		vStatus.Text = Steal.status
		vTarget.Text = Steal.target
		vGuard.Text = Steal.guard
		vCarry.Text = Steal.carrying and "Yes" or "No"
		vMode.Text = Steal.mode
		liveDot.Visible = Steal.enabled
		task.wait(0.25)
	end
end)
