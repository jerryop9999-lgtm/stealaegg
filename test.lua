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
local Steal = {enabled = false, speed = 300, status = "Idle", rarities = {}, avoidGuards = true, guardRadius = 70, mode = "High Speed Normal", flyHeight = 60, holdSeconds = 5, carrySpeed = 300, carrying = false, chaseVip = true, vip = {Secret = true, Eternal = true, Divine = true}, instantSpeed = 1000}
local RARITIES = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Cosmic","Secret","Eternal","Divine"}

-- ឈ្មោះ rarity របស់ស៊ុត (ដូច Sena: Assets.Directory[AssetCategory].Rarity)
local function rarityOf(rec)
	local a = Assets.Directory[rec.AssetCategory]
	local r = a and a.Rarity
	return r and (r.DisplayName or r._id) or "Unknown"
end

local function isVip(rec)
	return Steal.chaseVip and Steal.vip[rarityOf(rec)] == true
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
		local spd = Steal.carrying and Steal.carrySpeed or ((Steal.mode == "Instant Steal") and Steal.instantSpeed or Steal.speed)
		local step = math.min(dist, spd * dt)
		root.CFrame = CFrame.new(root.Position + delta.Unit * step) * (root.CFrame - root.CFrame.Position)
		root.AssemblyLinearVelocity = Vector3.zero
	end
end

-- ជញ្ជាំង reset ស៊ុត (ពេល reset ស៊ុតត្រូវត្រឡប់ទៅកន្លែងដើម) - ដូច Sena: AreaEggResetWall.IsSealed()
local function wallSealed()
	local ok, res = pcall(function()
		return require(RS.Client.AreaEggResetWall).IsSealed()
	end)
	return ok and res == true
end

-- ជ្រើសផ្លូវធ្វើដំណើរតាម Mode: Normal / Fly / Zig-Zag
local function travel(pos, abort)
	local root = getRoot()
	if not root then return false end
	local mode = Steal.mode
	if mode == "High Speed (Fly)" then
		local alt = math.max(root.Position.Y, pos.Y) + Steal.flyHeight
		return moveTo(Vector3.new(root.Position.X, alt, root.Position.Z), abort)
			and moveTo(Vector3.new(pos.X, alt, pos.Z), abort)
			and moveTo(pos, abort)
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
				if not moveTo(Vector3.new(wp.X, from.Y + (pos.Y - from.Y) * i / (n + 1), wp.Z), abort) then
					return false
				end
			end
		end
		return moveTo(pos, abort)
	end
	return moveTo(pos, abort)
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

-- ពិនិត្យ guard នៅជិតស៊ុត (ដើម្បីរំលងស៊ុតដែលមាន guard យាម)
local guardAreasFolder
local function guardRoots()
	if not (guardAreasFolder and guardAreasFolder.Parent) then
		guardAreasFolder = nil
		for _, d in ipairs(workspace:GetDescendants()) do
			if d.Name == "GuardAreas" then guardAreasFolder = d break end
		end
	end
	local list = {}
	if guardAreasFolder then
		for _, area in ipairs(guardAreasFolder:GetChildren()) do
			local g = area:FindFirstChild("Guard")
			local r = g and (g:FindFirstChild("HumanoidRootPart") or g:FindFirstChild("Collider") or (g:IsA("Model") and g.PrimaryPart))
			if r then table.insert(list, r) end
		end
	end
	return list
end

local function nearGuard(pos)
	if not Steal.avoidGuards then return false end
	for _, r in ipairs(guardRoots()) do
		if (r.Position - pos).Magnitude <= Steal.guardRadius then return true end
	end
	return false
end

-- ជ្រើសស៊ុត: rarity ខ្ពស់បំផុតមុន (បន្ទាប់មកជិតបំផុត) តាម filter
local function pickTarget(skip)
	local root = getRoot()
	if not root then return nil end
	local best, bestRank, bestDist
	for _, rec in ipairs(readRecords()) do
		if (rec.State == AreaEggs.States.Slot or rec.State == AreaEggs.States.Dropped)
		and (isVip(rec) or (not (skip and skip[rec.Uid]) and passesFilter(rec))) then
			local pos = eggPos(rec)
			if pos and (isVip(rec) or not nearGuard(pos)) then
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
			Steal.carrying = carried ~= nil
			if carried then
				-- កំពុងកាន់ → យកទៅផ្ទះ ហើយបើធ្លាក់ពាក់កណ្តាលផ្លូវ បញ្ឈប់ភ្លាម
				lastUid = carried.Uid
				Steal.status = "Carrying home"
				Steal.carrying = true
				if not inSafe(root) then
					travel(safeTarget(), function() return stopped() or not myCarriedEgg() end)
				else
					-- ដល់ safe area ហើយ: ឈរនៅកន្លែង រង់ចាំ server ទទួលស៊ុត (Sena: "Waiting for deposit")
					Steal.status = "Waiting for deposit"
					root.CFrame = CFrame.new(safeTarget()) * (root.CFrame - root.CFrame.Position)
					root.AssemblyLinearVelocity = Vector3.zero
					task.wait(0.1)
				end
			elseif wallSealed() then
				Steal.status = "Egg reset - waiting"
				task.wait(0.5)
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
					local arrived = pos and travel(pos + Vector3.new(0, 3, 0), function()
						if stopped() then return true end
						local r = findByUid(target.Uid)
						return not r or (r.State ~= AreaEggs.States.Slot and r.State ~= AreaEggs.States.Dropped)
					end)
					if arrived and not stopped() then
						-- ឈរនៅលើស៊ុតមួយរយៈ (Sena: StealHoldSeconds ~5s) ទើប server ឱ្យយក
						local holdPos = pos + Vector3.new(0, 3, 0)
						local holdUntil = os.clock() + Steal.holdSeconds
						local lost = false
						while os.clock() < holdUntil and not stopped() do
							Steal.status = string.format("Securing egg (%.1fs)", holdUntil - os.clock())
							local r = findByUid(target.Uid)
							if not r or (r.State ~= AreaEggs.States.Slot and r.State ~= AreaEggs.States.Dropped) then
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
							Steal.status = "Grabbing"
							local untilAt = os.clock() + 3
							while os.clock() < untilAt and not stopped() and not myCarriedEgg() do
								pcall(function()
									eggWorld.AskFieldEggCarry:InvokeServer({Uid = target.Uid})
								end)
								task.wait(0.3)
							end
						end
						if myCarriedEgg() then
							lastUid = target.Uid
						else
							if not isVip(target) then
								skip[target.Uid] = true -- ចាប់មិនបាន រំលងសិន (Secret/Eternal/Divine មិនរំលងទេ ព្យាយាមរហូត)
							else
								Steal.status = "Retrying " .. rarityOf(target)
								task.wait(0.3)
							end
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
-- DIAGNOSTIC: កត់ត្រាមូលហេតុដែលស៊ុតធ្លាក់ / ត្រឡប់ទៅដើម
------------------------------------------------------------
local Diag = {text = "none yet", relocateAt = 0, ragdollAt = 0}

local function dropReason(extra)
	local now = os.clock()
	local parts = {}
	if now - Diag.relocateAt < 2 then table.insert(parts, "server Relocate") end
	if now - Diag.ragdollAt < 2 then table.insert(parts, "ragdoll/hit") end
	if wallSealed() then table.insert(parts, "egg reset wall") end
	if #parts == 0 then table.insert(parts, "unknown (server decision)") end
	Diag.text = extra .. ": " .. table.concat(parts, " + ")
	print("[AutoSteal] " .. Diag.text)
end

pcall(function()
	eggWorld.OwnerDropped.OnClientEvent:Connect(function() dropReason("Egg dropped") end)
end)
pcall(function()
	Remotes.RigSync.Refresh.OnClientEvent:Connect(function() Diag.relocateAt = os.clock() end)
end)
local function watchRagdoll(c)
	local hum = c and c:WaitForChild("Humanoid", 5)
	if not hum then return end
	hum.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Ragdoll or new == Enum.HumanoidStateType.FallingDown
		or new == Enum.HumanoidStateType.PlatformStanding then
			Diag.ragdollAt = os.clock()
		end
	end)
end
watchRagdoll(player.Character)
player.CharacterAdded:Connect(watchRagdoll)

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
-- FLY (ហោះ) - ទូរស័ព្ទ: joystick ដើរ + មើលទៅលើ/ក្រោមតាម camera, ប៊ូតុង ▲▼ | PC: Space ឡើង, Shift ចុះ
------------------------------------------------------------
local Fly = {enabled = false, speed = 60, up = false, down = false, bv = nil, conn = nil}

local function flyStop()
	Fly.enabled = false
	if Fly.conn then Fly.conn:Disconnect() Fly.conn = nil end
	if Fly.bv then Fly.bv:Destroy() Fly.bv = nil end
end

function Fly.set(on)
	flyStop()
	if not on then return end
	Fly.enabled = true
	Fly.conn = RunService.RenderStepped:Connect(function()
		local root, hum = getRoot()
		if not root or not hum or hum.Health <= 0 then return end
		if not Fly.bv or Fly.bv.Parent ~= root then
			if Fly.bv then Fly.bv:Destroy() end
			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			bv.Velocity = Vector3.zero
			bv.Parent = root
			Fly.bv = bv
		end
		local cam = workspace.CurrentCamera
		local move = hum.MoveDirection
		local vel = Vector3.zero
		if move.Magnitude > 0 then
			-- ទៅមុខ = ទិសដៅ camera (រួមទាំងទិសឡើង/ចុះ)
			local look = cam.CFrame.LookVector
			local flat = Vector3.new(look.X, 0, look.Z)
			local fwd = flat.Magnitude > 0 and move:Dot(flat.Unit) or 0
			vel = move * Fly.speed + Vector3.new(0, look.Y * fwd * Fly.speed, 0)
		end
		if Fly.up or UIS:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, Fly.speed, 0) end
		if Fly.down or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel -= Vector3.new(0, Fly.speed, 0) end
		Fly.bv.Velocity = vel
	end)
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
main.Size = UDim2.new(0, 260, 0, 360)
main.Position = UDim2.new(0.5, -130, 0.5, -180)
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

local function addToggle(name, callback, default)
	local state = default == true
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 34)
	b.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
	b.Text = name .. ": " .. (state and "ON" or "OFF")
	b.BackgroundColor3 = state and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(50, 50, 58)
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

local dropLabel = Instance.new("TextLabel")
dropLabel.Size = UDim2.new(1, 0, 0, 34)
dropLabel.BackgroundTransparency = 1
dropLabel.TextWrapped = true
dropLabel.TextXAlignment = Enum.TextXAlignment.Left
dropLabel.Text = "Last drop: none yet"
dropLabel.TextColor3 = Color3.fromRGB(255, 180, 120)
dropLabel.Font = Enum.Font.Gotham
dropLabel.TextSize = 11
dropLabel.Parent = content

addToggle("Auto Steal", Steal.set)

-- ជ្រើស Mode របស់ Auto Steal
local modes = {"Instant Steal", "High Speed Normal", "High Speed (Fly)", "Zig-Zag"}
local mi = 2
local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(1, 0, 0, 34)
modeBtn.BackgroundColor3 = Color3.fromRGB(70, 60, 140)
modeBtn.Text = "Mode: High Speed Normal  ▼"
modeBtn.TextColor3 = Color3.new(1, 1, 1)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 14
modeBtn.Parent = content
Instance.new("UICorner", modeBtn)
modeBtn.MouseButton1Click:Connect(function()
	mi = mi % #modes + 1
	Steal.mode = modes[mi]
	modeBtn.Text = "Mode: " .. Steal.mode .. "  ▼"
end)
-- ពេលឈរនៅលើស៊ុតមុនយក (វិនាទី) - Sena លំនាំដើម 5
local holds = {1, 2, 3, 5, 7, 10}
local hi = 4
local holdBtn = Instance.new("TextButton")
holdBtn.Size = UDim2.new(1, 0, 0, 34)
holdBtn.BackgroundColor3 = Color3.fromRGB(70, 60, 140)
holdBtn.Text = "Hold: 5s  ▼"
holdBtn.TextColor3 = Color3.new(1, 1, 1)
holdBtn.Font = Enum.Font.GothamBold
holdBtn.TextSize = 14
holdBtn.Parent = content
Instance.new("UICorner", holdBtn)
holdBtn.MouseButton1Click:Connect(function()
	hi = hi % #holds + 1
	Steal.holdSeconds = holds[hi]
	holdBtn.Text = "Hold: " .. Steal.holdSeconds .. "s  ▼"
end)
-- ល្បឿនពេលដឹកស៊ុតទៅផ្ទះ (ទាប = server ទទួលងាយជាង)
local csp = {100, 150, 200, 300, 600}
local ci = 4
local carryBtn = Instance.new("TextButton")
carryBtn.Size = UDim2.new(1, 0, 0, 34)
carryBtn.BackgroundColor3 = Color3.fromRGB(70, 60, 140)
carryBtn.Text = "Carry Speed: 300  ▼"
carryBtn.TextColor3 = Color3.new(1, 1, 1)
carryBtn.Font = Enum.Font.GothamBold
carryBtn.TextSize = 14
carryBtn.Parent = content
Instance.new("UICorner", carryBtn)
carryBtn.MouseButton1Click:Connect(function()
	ci = ci % #csp + 1
	Steal.carrySpeed = csp[ci]
	carryBtn.Text = "Carry Speed: " .. Steal.carrySpeed .. "  ▼"
end)
addToggle("Anti Guard", Anti.set)
addToggle("Chase Secret/Eternal/Divine", function(on) Steal.chaseVip = on end, true)
addToggle("Avoid Guards", function(on) Steal.avoidGuards = on end, true)
addToggle("Fly", Fly.set)

-- ល្បឿន Fly + ប៊ូតុង ▲ ▼ (សម្រាប់ទូរស័ព្ទ)
local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 34)
row.BackgroundTransparency = 1
row.Parent = content

local function rowBtn(text, xScale, wScale, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(wScale, -4, 1, 0)
	b.Position = UDim2.new(xScale, 2, 0, 0)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.Parent = row
	Instance.new("UICorner", b)
	return b
end

local speedBtn = rowBtn("Speed: " .. Fly.speed, 0, 0.5, Color3.fromRGB(50, 50, 58))
local speeds = {30, 60, 100, 150, 250}
local si = 2
speedBtn.MouseButton1Click:Connect(function()
	si = si % #speeds + 1
	Fly.speed = speeds[si]
	speedBtn.Text = "Speed: " .. Fly.speed
end)

local upBtn = rowBtn("▲", 0.5, 0.25, Color3.fromRGB(60, 120, 255))
local downBtn = rowBtn("▼", 0.75, 0.25, Color3.fromRGB(60, 120, 255))
local function hold(btn, key)
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Fly[key] = true
		end
	end)
	btn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Fly[key] = false
		end
	end)
end
hold(upBtn, "up")
hold(downBtn, "down")

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
		dropLabel.Text = "Last drop: " .. Diag.text
		task.wait(0.3)
	end
end)
