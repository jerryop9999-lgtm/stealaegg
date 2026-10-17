-- Steal an Egg | UI + Auto Steal (ទាញពី Senav6.2Hub)
-- ដាក់ដំណើរការតាម executor (ត្រូវការ require ក្នុង ReplicatedStorage)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

------------------------------------------------------------
-- Modules របស់ហ្គេម (ដូចក្នុង Sena)
------------------------------------------------------------
local EggState = require(RS.Client.EggState)
local Remotes = require(RS.Shared.Remotes)
local AreaEggs = require(RS.Shared.Types.AreaEggs)
local eggWorld = Remotes.EggWorld
local Assets = require(RS.Data.Assets)
local Ragdoll = require(RS.Shared.Modules.Ragdoll)

local SAFE_POS = Vector3.new(542.93, 71.5, -405.58) -- safe area (ផ្ទះ)
local SAFE_RADIUS = 30

------------------------------------------------------------
-- AUTO STEAL
------------------------------------------------------------
local Steal = {enabled = false, speed = 300, status = "Idle", rarities = {}}
local RARITIES = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Cosmic","Secret","Eternal","Divine"}

-- ឈ្មោះ rarity របស់ស៊ុត (ដូច Sena: Assets.Directory[AssetCategory].Rarity)
local function rarityOf(rec)
	local a = Assets.Directory[rec.AssetCategory]
	local r = a and a.Rarity
	return r and (r.DisplayName or r._id) or "Unknown"
end

local function passesFilter(rec)
	if next(Steal.rarities) == nil then return true end -- មិនជ្រើស = យកទាំងអស់
	return Steal.rarities[rarityOf(rec)] == true
end
local token = 0

local function getRoot()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function inSafe(root)
	local d = root.Position - SAFE_POS
	return Vector2.new(d.X, d.Z).Magnitude <= SAFE_RADIUS and math.abs(d.Y) <= 18
end

-- ផ្លាស់ទីទៅទីតាំងដោយល្បឿន studs/វិនាទី (អាចបញ្ឈប់ពាក់កណ្តាលផ្លូវបាន តាម abort())
local RunService = game:GetService("RunService")
local function moveTo(pos, abort)
	while true do
		local root = getRoot()
		if not root then return false end
		if abort and abort() then return false end
		local delta = pos - root.Position
		local dist = delta.Magnitude
		if dist < 2 then
			root.AssemblyLinearVelocity = Vector3.zero
			return true
		end
		local dt = RunService.Heartbeat:Wait()
		local step = math.min(dist, Steal.speed * dt)
		root.CFrame = CFrame.new(root.Position + delta.Unit * step) * (root.CFrame - root.CFrame.Position)
		root.AssemblyLinearVelocity = Vector3.zero
	end
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

local function rarityRank(rec)
	local name = rarityOf(rec)
	for i, n in ipairs(RARITIES) do
		if n == name then return i end
	end
	return 0
end

-- ជ្រើសស៊ុត: rarity ខ្ពស់បំផុតមុន (បន្ទាប់មកជិតបំផុត) តាម filter
local function pickTarget(skip)
	local root = getRoot()
	if not root then return nil end
	local best, bestRank, bestDist
	for _, rec in ipairs(readRecords()) do
		if (rec.State == AreaEggs.States.Slot or rec.State == AreaEggs.States.Dropped)
		and not (skip and skip[rec.Uid]) and passesFilter(rec) then
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
	local lastUid = nil   -- ស៊ុតដែលយើងទើបកាន់ (ដើម្បីរើសវិញបើធ្លាក់)
	local skip = {}       -- ស៊ុតដែលចាប់មិនបាន ដកចេញបណ្តោះអាសន្ន
	local function stopped() return not Steal.enabled or token ~= myToken end

	while not stopped() do
		local root, hum = getRoot()
		if not root or not hum or hum.Health <= 0 then
			Steal.status = "Waiting for character"
			task.wait(1)
		else
			local carried = myCarriedEgg()
			if carried then
				-- កំពុងកាន់ → យកទៅផ្ទះ ហើយបើធ្លាក់ពាក់កណ្តាលផ្លូវ បញ្ឈប់ភ្លាម
				lastUid = carried.Uid
				Steal.status = "Carrying home"
				if not inSafe(root) then
					moveTo(SAFE_POS, function() return stopped() or not myCarriedEgg() end)
				end
				task.wait(0.3)
			else
				local target
				-- ស៊ុតទើបធ្លាក់ ត្រូវរើសវិញមុនគេ (បើវានៅ Dropped)
				if lastUid then
					local rec = findByUid(lastUid)
					if rec and rec.State == AreaEggs.States.Dropped then
						target = rec
						Steal.status = "Egg dropped! Re-grabbing"
					else
						lastUid = nil -- ដឹកដល់ផ្ទះ ឬត្រូវគេយក
					end
				end
				target = target or pickTarget(skip)

				if not target then
					skip = {}
					Steal.status = "No egg found"
					task.wait(1)
				else
					Steal.status = "Going to " .. rarityOf(target)
					local pos = eggPos(target)
					local arrived = pos and moveTo(pos + Vector3.new(0, 3, 0), function()
						if stopped() then return true end
						local r = findByUid(target.Uid)
						return not r or (r.State ~= AreaEggs.States.Slot and r.State ~= AreaEggs.States.Dropped)
					end)
					if arrived and not stopped() then
						Steal.status = "Grabbing"
						for _ = 1, 3 do
							pcall(function()
								eggWorld.AskFieldEggCarry:InvokeServer({Uid = target.Uid})
							end)
							task.wait(0.25)
							if myCarriedEgg() then break end
						end
						if myCarriedEgg() then
							lastUid = target.Uid
						else
							skip[target.Uid] = true -- ចាប់មិនបាន រំលងសិន
						end
					end
				end
			end
		end
		task.wait()
	end
	Steal.status = "Idle"
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
-- ANTI GUARD (ការពារ ragdoll / knockback ពី guard - ខាងកូនសំណាក់ client)
------------------------------------------------------------
local Anti = {enabled = false, orig = {}, conns = {}, gates = {}, scanned = false}

local function recoverBody()
	local c = player.Character
	local hum = c and c:FindFirstChildOfClass("Humanoid")
	local root = c and c:FindFirstChild("HumanoidRootPart")
	if not (c and hum and root) then return end
	pcall(function()
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		hum.PlatformStand = false
		hum.Sit = false
		local st = hum:GetState()
		if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.FallingDown
		or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.PlatformStanding then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			hum:ChangeState(Enum.HumanoidStateType.Running)
		end
	end)
	for _, d in ipairs(c:GetDescendants()) do
		if d:IsA("Motor6D") then
			d.Enabled = true
		elseif (d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint"))
		and (d.Name:find("Ragdoll", 1, true) or d:GetAttribute("RagdollConstraint")) then
			pcall(d.Destroy, d)
		end
	end
	local v = root.AssemblyLinearVelocity
	if Vector3.new(v.X, 0, v.Z).Magnitude > 80 or math.abs(v.Y) > 120 then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

local function watchCharacter(c)
	if not c then return end
	table.insert(Anti.conns, c.DescendantAdded:Connect(function(d)
		if not Anti.enabled then return end
		if (d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint"))
		and (d.Name:find("Ragdoll", 1, true) or d:GetAttribute("RagdollConstraint")) then
			pcall(d.Destroy, d)
			recoverBody()
		end
	end))
end

function Anti.set(on)
	Anti.enabled = on
	if on then
		-- (A) Guard ជាប់វ៉ៃ: បិទចម្ងាយវាយរបស់ guard (ដូច Sena: ResolveHitDistance = -inf)
		pcall(function()
			local Policy = require(RS.Shared.Modules.GuardAreas.GuardChasePolicy)
			if Policy and type(Policy.ResolveHitDistance) == "function" and not Anti.orig.ResolveHitDistance then
				local orig = Policy.ResolveHitDistance
				Anti.orig.ResolveHitDistance = orig
				Policy.ResolveHitDistance = function(...)
					if Anti.enabled then return -math.huge end
					return orig(...)
				end
			end
		end)

		-- (B) Guard attack handler (client): មិនឱ្យវាដំណើរការ ដូច្នេះមិនបាន report ការវាយទៅ server
		if not Anti.scanned and type(getgc) == "function" then
			Anti.scanned = true
			task.spawn(function()
				local ok, list = pcall(getgc, true)
				if not ok or type(list) ~= "table" then Anti.scanned = false return end
				for i, t in ipairs(list) do
					if i % 20000 == 0 then RunService.Heartbeat:Wait() end
					if type(t) == "table" and rawget(t, "_areaId") ~= nil
					and type(rawget(t, "_attackHandler")) == "function" then
						local orig = rawget(t, "_attackHandler")
						table.insert(Anti.gates, {comp = t, orig = orig})
						rawset(t, "_attackHandler", function(...)
							if Anti.enabled then recoverBody() return end
							return orig(...)
						end)
					end
				end
			end)
		end

		-- ចាប់ function ragdoll របស់ហ្គេម
		for _, name in ipairs({"ApplyClientRagdoll", "Ragdoll", "TimedRagdoll", "TimedRagdollAsync"}) do
			if type(Ragdoll[name]) == "function" and not Anti.orig[name] then
				local orig = Ragdoll[name]
				Anti.orig[name] = orig
				Ragdoll[name] = function(...)
					if Anti.enabled then recoverBody() return end
					return orig(...)
				end
			end
		end
		if type(Ragdoll.IsRagdolled) == "function" and not Anti.orig.IsRagdolled then
			local orig = Ragdoll.IsRagdolled
			Anti.orig.IsRagdolled = orig
			Ragdoll.IsRagdolled = function(c)
				if Anti.enabled and c == player.Character then return false end
				return orig(c)
			end
		end
		watchCharacter(player.Character)
		table.insert(Anti.conns, player.CharacterAdded:Connect(watchCharacter))
		task.spawn(function()
			while Anti.enabled do
				recoverBody()
				task.wait(0.1)
			end
		end)
	else
		for _, c in ipairs(Anti.conns) do pcall(c.Disconnect, c) end
		Anti.conns = {}
	end
end

------------------------------------------------------------
-- UI
------------------------------------------------------------
local old = player.PlayerGui:FindFirstChild("MenuUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MenuUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

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
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
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

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 330)
main.Position = UDim2.new(0.5, -130, 0.5, -165)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
title.Text = "MY MENU"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)
makeDraggable(title, main)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -10, 1, -46)
content.Position = UDim2.new(0, 5, 0, 41)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 3
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new()
content.Parent = main
Instance.new("UIListLayout", content).Padding = UDim.new(0, 6)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
toggleBtn.Text = "☰"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextSize = 24
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local wasMoved = makeDraggable(toggleBtn, toggleBtn)
toggleBtn.MouseButton1Click:Connect(function()
	if not wasMoved() then
		main.Visible = not main.Visible
	end
end)

local function addToggle(name, callback)
	local state = false
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 34)
	b.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
	b.Text = name .. ": OFF"
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Parent = content
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = name .. ": " .. (state and "ON" or "OFF")
		b.BackgroundColor3 = state and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(50, 50, 58)
		callback(state)
	end)
end

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 22)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = content

addToggle("Auto Steal", Steal.set)
addToggle("Anti Guard", Anti.set)

-- Rarity filter (មិនជ្រើស = យកគ្រប់ rarity)
local rtitle = Instance.new("TextLabel")
rtitle.Size = UDim2.new(1, 0, 0, 20)
rtitle.BackgroundTransparency = 1
rtitle.Text = "Rarity Filter (ទទេ = យកល្អបំផុតមុន)"
rtitle.TextColor3 = Color3.fromRGB(200, 200, 210)
rtitle.Font = Enum.Font.GothamBold
rtitle.TextSize = 12
rtitle.Parent = content

local grid = Instance.new("Frame")
grid.Size = UDim2.new(1, 0, 0, 0)
grid.AutomaticSize = Enum.AutomaticSize.Y
grid.BackgroundTransparency = 1
grid.Parent = content
local gl = Instance.new("UIGridLayout", grid)
gl.CellSize = UDim2.new(0.5, -4, 0, 26)
gl.CellPadding = UDim2.new(0, 6, 0, 4)

for _, name in ipairs(RARITIES) do
	local chip = Instance.new("TextButton")
	chip.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
	chip.Text = name
	chip.TextColor3 = Color3.new(1, 1, 1)
	chip.Font = Enum.Font.Gotham
	chip.TextSize = 12
	chip.Parent = grid
	Instance.new("UICorner", chip)
	chip.MouseButton1Click:Connect(function()
		local on = not Steal.rarities[name]
		Steal.rarities[name] = on or nil
		chip.BackgroundColor3 = on and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(50, 50, 58)
	end)
end

task.spawn(function()
	while gui.Parent do
		statusLabel.Text = "Status: " .. Steal.status
		task.wait(0.3)
	end
end)
