-- [[ SenaV4 Hub & OLIVER Auto Steal - Tween Delivery ]] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local function fn()
	return Workspace:FindFirstChild("World") or Workspace:FindFirstChild("__OBJECTS")
end

local genv = getgenv and getgenv() or _G

if type(genv.__SenaV4HubShutdown) == "function" then
	pcall(genv.__SenaV4HubShutdown)
end

local senaV4HubSession = {}
genv.__SenaV4HubSession = senaV4HubSession

local function fn2()
	return genv.__SenaV4HubSession == senaV4HubSession
end

-- ប្រព័ន្ធសុវត្ថិភាព និង Anti-Tamper[span_0](start_span)[span_0](end_span)
do
	local tbl2 = {"hookfunction", "hookmetamethod", "getconnections", "getgc", "getrawmetatable", "firetouchinterest", "newcclosure", "getnamecallmethod", "checkcaller", "getcallingscript"}
	local iscclosure = genv.iscclosure or rawget(_G, "iscclosure")
	local isfunctionhooked = genv.isfunctionhooked or rawget(_G, "isfunctionhooked")
	local tbl3 = {}

	for i, v2 in ipairs(tbl2) do
		tbl3[v2] = genv[v2]
	end

	local function fn3(arg)
		if type(arg) ~= "function" then
			return false
		end

		if type(iscclosure) == "function" then
			local ok, result = pcall(iscclosure, arg)
			if ok and result == false then
				return true
			end
		end

		if type(isfunctionhooked) == "function" then
			local ok, result = pcall(isfunctionhooked, arg)
			if ok and result == true then
				return true
			end
		end

		return false
	end

	local function fn4()
		for i, v2 in ipairs(tbl2) do
			local v3 = genv[v2]

			if v3 ~= tbl3[v2] then
				return "api:" .. v2
			elseif fn3(v3) then
				return "api:" .. v2
			end
		end

		local getrawmetatable = tbl3.getrawmetatable

		if type(getrawmetatable) == "function" then
			local ok, result = pcall(getrawmetatable, game)

			if ok and type(result) == "table" then
				for i, v2 in ipairs({"__namecall", "__index", "__newindex"}) do
					if fn3(rawget(result, v2)) then
						return "mt:" .. v2
					end
				end
			end
		end

		local remoteEvent = Instance.new("RemoteEvent")
		local remoteFunction = Instance.new("RemoteFunction")
		local v2 = if fn3(remoteEvent.FireServer) then "remote:FireServer" else if fn3(remoteFunction.InvokeServer) then "remote:InvokeServer" else nil
		remoteEvent:Destroy()
		remoteFunction:Destroy()
		return v2
	end

	local function fn5(arg)
		if genv.__SenaV4TamperRejoining then
			return
		end
		genv.__SenaV4TamperRejoining = true
		warn("[Sena] tamper detected (" .. tostring(arg) .. ") - rejoining")

		pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
		end)

		task.delay(5, function()
			pcall(function()
				TeleportService:Teleport(game.PlaceId, localPlayer)
			end)
		end)
	end

	local ok, result = pcall(fn4)

	if ok and result then
		fn5(result)
	end

	task.spawn(function()
		while fn2() do
			task.wait(3)
			local ok2, result2 = pcall(fn4)
			if ok2 and result2 then
				fn5(result2)
				break
			end
		end
	end)
end

genv.__SenaV4IdentityGetter = genv.getthreadidentity or genv.get_thread_identity or genv.getidentity or genv.getthreadcontext or genv.get_thread_context
genv.__SenaV4IdentitySetter = genv.setthreadidentity or genv.set_thread_identity or genv.setidentity or genv.setthreadcontext or genv.set_thread_context
local senaV4IdentitySetter = genv.__SenaV4IdentitySetter

if type(senaV4IdentitySetter) == "function" then
	pcall(senaV4IdentitySetter, 8)
	genv.__SenaV4UICapabilityIdentity = 8
end

if type(genv.__SenaV4TweenRuntimeCleanup) == "function" then
	pcall(genv.__SenaV4TweenRuntimeCleanup)
end

if type(genv.__SenaV4EggRuntimeCleanup) == "function" then
	pcall(genv.__SenaV4EggRuntimeCleanup)
end

if type(genv.__SenaV4AntiGuardCleanup) == "function" then
	pcall(genv.__SenaV4AntiGuardCleanup)
end

-- Guard Presentation / Bypass
pcall(function()
	local GuardPresentationComponent = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardPresentationComponent)
	if type(GuardPresentationComponent) == "table" then
		genv.__SenaV4GuardPresentOrig = genv.__SenaV4GuardPresentOrig or {PlayWake = GuardPresentationComponent.PlayWake, PlayHit = GuardPresentationComponent.PlayHit}
		local function playWake() end
		GuardPresentationComponent.PlayWake = playWake
		GuardPresentationComponent.PlayHit = function() return 0 end
		GuardPresentationComponent.PlayAfterWake = playWake
		GuardPresentationComponent.ScheduleAfterWake = playWake
	end
end)

------------------------------------------------------------
-- OLIVER | Steal an Egg UI & Speed 1000 Delivery Integration
------------------------------------------------------------
local TITLE = "OLIVER."
local VERSION = "V3"
local LOGO_ID = "rbxassetid://0"
local ACCENT = Color3.fromRGB(110, 120, 255)

local SAFE_POS = Vector3.new(542.93, 71.5, -405.58)
local SAFE_RADIUS = 30

local EggState = require(ReplicatedStorage.Client.EggState)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local AreaEggs = require(ReplicatedStorage.Shared.Types.AreaEggs)
local Assets = require(ReplicatedStorage.Data.Assets)
local eggWorld = Remotes.EggWorld
local okER, EggRecords = pcall(function() return require(ReplicatedStorage.Shared.Util.EggRecords) end)

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
	{key = "Instant", name = "Instant Steal (Recommended)", desc = "Bait guard, hop to egg, drop in Safe"},
	{key = "Tween", name = "Tween", desc = "Tween to egg and to Safe"},
}

local Steal = {
	mode = "Instant",
	enabled = false,
	status = "Idle",
	target = "-",
	carrying = false,
	rarities = {},
	holdSeconds = 5,
	speed = 350, -- ល្បឿនពេលទៅយក Egg (តាមการកំណត់ក្នុង UI/Game)
	deliverSpeed = 450, -- ល្បឿនពេលដឹកពងមក Base (រក Sweet spot: 350 ត្រូវ Guard តាម / 600 Server បដិសេធ)
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
	local c = localPlayer.Character
	return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function safeCFrame()
	local x, y, z = SAFE_POS.X, SAFE_POS.Y, SAFE_POS.Z
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {localPlayer.Character}
	local hit = Workspace:Raycast(Vector3.new(x, y + 30, z), Vector3.new(0, -80, 0), params)
	return CFrame.new(x, hit and hit.Position.Y + 3.2 or y, z)
end

local function getSafePos()
	return safeCFrame().Position
end

local function inSafe(root)
	local d = root.Position - getSafePos()
	return Vector2.new(d.X, d.Z).Magnitude <= SAFE_RADIUS and math.abs(d.Y) <= 18
end

local Protect = {hb = nil, autoRotate = nil}

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
end

local function stopProtect()
	if Protect.hb then Protect.hb:Disconnect() Protect.hb = nil end
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

local MIN_SPEED, MAX_SPEED = 200, 1000

-- Tween ទៅទីតាំង (Linear) ដោយប្រើល្បឿន Steal.speed
local function travel(pos, abort)
	local root, hum = getRoot()
	if not root or not hum then return false end
	local speed = math.clamp(Steal.speed, MIN_SPEED, MAX_SPEED)
	local rot = root.CFrame - root.CFrame.Position
	local t = math.max((root.Position - pos).Magnitude / speed, 0.05)
	local tw = TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos) * rot})
	local done = false
	local conn = tw.Completed:Connect(function() done = true end)
	tw:Play()
	while not done do
		root, hum = getRoot()
		if not root or not hum or hum.Health <= 0 or (abort and abort()) then
			tw:Cancel()
			conn:Disconnect()
			if root then root.AssemblyLinearVelocity = Vector3.zero end
			return false
		end
		root.AssemblyLinearVelocity = Vector3.zero
		RunService.Heartbeat:Wait()
	end
	conn:Disconnect()
	root, hum = getRoot()
	if root then root.AssemblyLinearVelocity = Vector3.zero end
	return root ~= nil
end

local function wallSealed()
	local ok, res = pcall(function()
		return require(ReplicatedStorage.Client.AreaEggResetWall).IsSealed()
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
		if rec.State == AreaEggs.States.Carried and rec.CarrierUserId == localPlayer.UserId then
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
-- INSTANT STEAL (ពី Open.lua / Senav6.2Hub)
-- 1) យក Primer Egg ក្នុង Forest  2) ទាញ Guard ឲ្យវាយ (Bait)
-- 3) Hop ទៅ Egg គោលដៅ ហើយ Hover រង់ចាំ  4) Grab  5) Hop ទៅ Safe រួច Drop
------------------------------------------------------------
local HOP = {studs = 500, gap = 0.15, height = 40}
local HOVER_UP = 14
local GUARD_FRONT = 2.5
local STRIKE_TIME = 1.5
local KB_SPEED = 18

local function tp(cf)
    local r = getRoot()
    if not r then return false end
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
    r.CFrame = cf
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function feetOffset(root, hum)
    if hum.RigType == Enum.HumanoidRigType.R15 then
        return root.Size.Y * 0.5 + math.max(hum.HipHeight, 0.5)
    end
    return root.Size.Y * 0.5 + 2
end

local function dataPing()
    local ok, v = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and tonumber(v) or 0
end

local function forestGuard()
    local w = fn()
    local areas = w and w:FindFirstChild("Areas")
    local ga = areas and areas:FindFirstChild("GuardAreas")
    local forest = ga and ga:FindFirstChild("Forest")
    local g = forest and forest:FindFirstChild("Guard")
    return g, g and g:FindFirstChild("HumanoidRootPart")
end

local function choosePrimer(excludeUid)
    local _, ghrp = forestGuard()
    local root = getRoot()
    local origin = ghrp and ghrp.Position or (root and root.Position)
    if not origin then return nil end
    local best, bestScore
    for _, rec in ipairs(readRecords()) do
        if rec.State == AreaEggs.States.Slot and rec.AreaId == "Forest" and rec.Uid ~= excludeUid then
            local pos = eggPos(rec)
            if pos then
                local score = -(pos - origin).Magnitude - rarityRank(rec) * 100
                if not bestScore or score > bestScore then best, bestScore = rec, score end
            end
        end
    end
    return best
end

local function knockbackLanded()
    local root, hum = getRoot()
    if not root or not hum then return false end
    if hum.PlatformStand or hum.Sit then return true end
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
        or st == Enum.HumanoidStateType.PlatformStanding then return true end
    return root.AssemblyLinearVelocity.Magnitude > KB_SPEED
end

-- ទាញ Guard ឲ្យវាយ (Primer ក្នុងដៃ) ដល់ពេល Knockback
local function baitGuard(primer, stopped)
    local gmodel, ghrp = forestGuard()
    if not ghrp then return false end
    local collider = gmodel:FindFirstChild("Collider") or ghrp
    local strike = Remotes.GuardPatrol and Remotes.GuardPatrol.ForestStrike
    local anchor
    local landed = false
    local untilT = os.clock() + STRIKE_TIME
    while os.clock() < untilT and not stopped() do
        local root, hum = getRoot()
        if not root or not hum then return false end
        local gp = ghrp.Position
        local look = ghrp.CFrame.LookVector * GUARD_FRONT
        anchor = Vector3.new(gp.X + look.X, root.Position.Y, gp.Z + look.Z)
        root.CFrame = CFrame.lookAt(anchor, Vector3.new(gp.X, anchor.Y, gp.Z))
        root.AssemblyLinearVelocity = Vector3.zero
        if firetouchinterest then
            pcall(function()
                firetouchinterest(root, collider, 0)
                firetouchinterest(root, collider, 1)
            end)
        end
        if strike then
            pcall(function() strike:FireServer({EggUid = primer.Uid, GuardCFrame = ghrp.CFrame}) end)
        end
        local t = os.clock() + 0.05
        while os.clock() < t do
            if knockbackLanded() then landed = true break end
            RunService.Heartbeat:Wait()
        end
        if landed then break end
    end
    if landed then
        local settleEnd = os.clock() + 0.35
        while os.clock() < settleEnd and not stopped() do
            local root, hum = getRoot()
            if not root then return false end
            if hum then
                pcall(function()
                    hum.PlatformStand = false
                    hum.Sit = false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end
            if anchor then root.CFrame = CFrame.new(anchor) end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
        end
    end
    return landed, anchor
end

-- Hop ជាជំហាន 500 studs នៅកម្ពស់ +40 (ដូច _hopRoot ក្នុង Open.lua)
local function hopRoot(cf, abort)
    local r0, h0 = getRoot()
    if not r0 or not h0 then return false end
    pcall(function() h0.AutoRotate = false end)
    local target = cf.Position
    local cruiseY = target.Y + HOP.height
    local deadline = os.clock() + 20
    while os.clock() < deadline do
        local r, h = getRoot()
        if not r or not h or h.Health <= 0 or (abort and abort()) then return false end
        local p = r.Position
        local flat = Vector3.new(target.X - p.X, 0, target.Z - p.Z)
        if flat.Magnitude <= HOP.studs then
            return tp(cf)
        end
        local np = Vector3.new(p.X, cruiseY, p.Z) + flat.Unit * HOP.studs
        local c2 = CFrame.new(np, np + flat.Unit)
        tp(c2)
        local gapEnd = os.clock() + HOP.gap
        while os.clock() < gapEnd do
            RunService.Heartbeat:Wait()
            local r2, h2 = getRoot()
            if not r2 or not h2 or (abort and abort()) then return false end
            tp(c2)
        end
    end
    return false
end

local function settleSeconds(areaId)
    local s = tostring(areaId or ""):lower()
    local a, b = 8, 3.5
    if s:find("enchanted") then a, b = 18, 12
    elseif s:find("light") or s:find("dark") then a, b = 16, 10
    elseif s:find("titan") or s:find("cosmic") or s:find("cherry") then a, b = 10, 8 end
    local hold = math.clamp(tonumber(Steal.holdSeconds) or 5, 1, 10)
    local secs = math.max(b, a * ((11 - hold) / 6))
    if dataPing() > 300 then secs += 1 end
    return secs
end

local function requestGrab(rec, secs, stopped)
    local untilAt = os.clock() + secs
    while os.clock() < untilAt and not stopped() do
        if myCarriedEgg() then return true end
        pcall(function() eggWorld.AskFieldEggCarry:InvokeServer({Uid = rec.Uid}) end)
        task.wait(0.15)
    end
    return myCarriedEgg() ~= nil
end

-- return: true = កាន់ Egg គោលដៅហើយ | false = បរាជ័យ | "retry" = ព្យាយាមម្ដងទៀត (មិន Skip)
local function instantSteal(target, stopped, skip)
    local rname = rarityOf(target)
    local function gone(uid)
        local r = findByUid(uid)
        return not r or (r.State ~= AreaEggs.States.Slot and r.State ~= AreaEggs.States.Dropped)
    end

    -- 1. Primer
    local primer = choosePrimer(target.Uid)
    if not primer then
        Steal.status = "Preparing steal"
        task.wait(0.25)
        return "retry"
    end
    local root, hum = getRoot()
    local ppos = eggPos(primer)
    if not root or not hum or not ppos then return "retry" end
    skip[primer.Uid] = true

    Steal.status = "Priming guard"
    local primeCF = CFrame.new(ppos + Vector3.new(0, feetOffset(root, hum) + 0.15, 0))
    tp(primeCF)
    local got = false
    local untilAt = os.clock() + 3
    while os.clock() < untilAt and not stopped() do
        if myCarriedEgg() then got = true break end
        tp(primeCF)
        pcall(function() eggWorld.AskFieldEggCarry:InvokeServer({Uid = primer.Uid}) end)
        task.wait(0.15)
    end
    if stopped() then return false end
    if not got then return "retry" end

    -- 2. Bait guard
    Steal.status = "Baiting guard"
    local landed, anchor = baitGuard(primer, stopped)
    local c = myCarriedEgg()
    if c and c.Uid == primer.Uid then
        pcall(EggState.DropFieldEgg, "PlayerRequest")
        task.wait(0.1)
    end
    if stopped() then return false end
    if not landed then return "retry" end

    -- 3. Hunt target
    if gone(target.Uid) then return "retry" end
    local r = findByUid(target.Uid)
    local tpos = r and eggPos(r)
    root, hum = getRoot()
    if not tpos or not root or not hum then return "retry" end
    if anchor then tp(CFrame.new(anchor)) end

    local dest = CFrame.new(tpos + Vector3.new(0, feetOffset(root, hum) + 0.15, 0))
    local hover = dest + Vector3.new(0, HOVER_UP, 0)
    local function abort() return stopped() or gone(target.Uid) end

    Steal.status = "Heading to " .. rname
    if not hopRoot(hover, abort) then return "retry" end

    local secs = settleSeconds(r.AreaId)
    local untilT = os.clock() + secs
    while os.clock() < untilT do
        if abort() then
            if stopped() then return false end
            return "retry"
        end
        Steal.status = string.format("Securing %s (%.1fs)", rname, math.max(0, untilT - os.clock()))
        tp(hover)
        RunService.Heartbeat:Wait()
    end

    if not hopRoot(dest, abort) then return "retry" end
    Steal.status = "Grabbing " .. rname
    return requestGrab(target, 3, stopped)
end

local function instantDeliver(stopped)
    local sc = safeCFrame()
    for _ = 1, 3 do
        if stopped() or not myCarriedEgg() then break end
        Steal.status = "Bringing egg home"
        hopRoot(sc, function() return stopped() or not myCarriedEgg() end)
        if stopped() then return end
        if myCarriedEgg() then
            local ping = 0.05
            pcall(function() ping = localPlayer:GetNetworkPing() or 0.05 end)
            task.wait(math.clamp(0.5 + ping * 4, 0.8, 2))
            if stopped() then return end
            if myCarriedEgg() then
                Steal.status = "Dropping egg in Safe"
                pcall(EggState.DropFieldEgg, "PlayerRequest")
            end
            local t = os.clock() + 0.85
            while not stopped() and myCarriedEgg() and os.clock() < t do
                RunService.Heartbeat:Wait()
            end
        end
        if not myCarriedEgg() then break end
    end
    task.wait(0.4)
end

local function stealLoop(myToken)
	local lastUid
	local skip = {}
	local function stopped() return not Steal.enabled or token ~= myToken end

	while not stopped() do
		local root, hum = getRoot()
		if not root or not hum or hum.Health <= 0 then
			Steal.status = "Waiting for character"
			task.wait(1)
		else
			ensureProtect()
			local carried = myCarriedEgg()
			Steal.carrying = carried ~= nil

			if carried then
				lastUid = carried.Uid
				Steal.status = string.format("Delivering egg (Speed %d)", Steal.deliverSpeed)
				if Steal.mode == "Instant" then
					instantDeliver(stopped)
					lastUid = nil
				elseif not inSafe(root) then
					local oldSpeed = Steal.speed
					Steal.speed = Steal.deliverSpeed
					travel(getSafePos(), function() return stopped() or not myCarriedEgg() end)
					Steal.speed = oldSpeed
				else
					Steal.status = "Waiting for deposit"
					root.AssemblyLinearVelocity = Vector3.zero
					task.wait(0.3) -- ពេលរង់ចាំខ្លីឱ្យ Server ទទួលស៊ុតចូល Base
				end
			elseif wallSealed() then
				Steal.status = "Egg reset - waiting"
				task.wait(0.5)
			else
				-- 🐢 ពេលទៅយក Egg ប្រើល្បឿនធម្មតាដែលអ្នកកំណត់ក្នុង Game/UI (Steal.speed)
				local target
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
				elseif Steal.mode == "Instant" then
					local res = instantSteal(target, stopped, skip)
					if res == true then
						lastUid = target.Uid
					elseif res == false and not stopped() and not isVip(target) then
						skip[target.Uid] = true
					end
				else
					local rname = rarityOf(target)
					local wtxt = string.format("%s %.1fkg", rname, weightOf(target))
					Steal.target = wtxt
					Steal.status = "Going to " .. wtxt
					local pos = eggPos(target)
					local arrived = pos and travel(pos + Vector3.new(0, 3, 0), function()
						if stopped() then return true end
						local r = findByUid(target.Uid)
						return not r or (r.State ~= AreaEggs.States.Slot and r.State ~= AreaEggs.States.Dropped)
					end)

					if arrived and not stopped() then
						local rt = getRoot()
						if rt then
							rt.CFrame = CFrame.new(pos + Vector3.new(0, 1.5, 0))
							rt.AssemblyLinearVelocity = Vector3.zero
						end
						task.wait(0.3)

						local holdPos = pos + Vector3.new(0, 1.5, 0)
						local holdUntil = os.clock() + Steal.holdSeconds
						local lost = false
						while os.clock() < holdUntil and not stopped() do
							Steal.status = string.format("Securing %s (%.1fs)", rname, holdUntil - os.clock())
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
							Steal.status = "Grabbing " .. rname
							local untilAt = os.clock() + 3
							while os.clock() < untilAt and not stopped() and not myCarriedEgg() do
								pcall(function()
									eggWorld.AskFieldEggCarry:InvokeServer({Uid = target.Uid})
								end)
								task.wait(0.2)
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
-- UI SETUP (Oliver Interface)
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
	UserInputService.InputChanged:Connect(function(input)
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

local parentGui = localPlayer:WaitForChild("PlayerGui")
local old = parentGui:FindFirstChild("OliverAutoSteal")
if old then old:Destroy() end

local gui = new("ScreenGui", {
	Name = "OliverAutoSteal", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
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
verLbl.Size = UDim2.fromOffset(40, 40)
verLbl.Position = UDim2.new(1, -86, 0, 0)
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
local settingsPage = addTab("Settings Config", "⚙", 2)

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

local filters = makeSection(stealPage, "Filters / Rarity", 1, false)
local hintRow = new("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = 1}, filters)
local hint = label(hintRow, "Highest rarity first, then heaviest kg", 11, MUTED)
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

local mods = makeSection(stealPage, "Steal Mode", 2, true)
local modButtons = {}
local function renderMods()
	for key, m in pairs(modButtons) do
		local on = key == Steal.mode
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
	modButtons[m.key] = {btn = b, stroke = st, dot = dot}
	b.MouseButton1Click:Connect(function()
		Steal.mode = m.key
		renderMods()
	end)
end
renderMods()
for _, name in ipairs(RARITIES) do renderChip(name) end

local refreshers = {}
local function addStepper(parent, order, title, get, set, minV, maxV, stepV, suffix)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = PANEL2, LayoutOrder = order}, parent)
	corner(row, 8)
	local t = label(row, title, 12, TEXT, Enum.Font.GothamMedium)
	t.Size = UDim2.new(1, -140, 1, 0)
	t.Position = UDim2.fromOffset(10, 0)
	local function mk(txt, x)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(26, 24), Position = UDim2.new(1, x, 0.5, -12), BackgroundColor3 = PANEL,
			Text = txt, TextColor3 = TEXT, TextSize = 16, Font = Enum.Font.GothamBold, AutoButtonColor = false,
		}, row)
		corner(b, 6)
		return b
	end
	local minus = mk("−", -126)
	local plus = mk("+", -36)
	local val = label(row, "", 12, TEXT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
	val.Size = UDim2.fromOffset(60, 34)
	val.Position = UDim2.new(1, -98, 0, 0)
	local function refresh() val.Text = tostring(get()) .. suffix end
	minus.MouseButton1Click:Connect(function() set(math.clamp(get() - stepV, minV, maxV)) refresh() end)
	plus.MouseButton1Click:Connect(function() set(math.clamp(get() + stepV, minV, maxV)) refresh() end)
	refresh()
	table.insert(refreshers, refresh)
end

local tweenCfg = makeSection(settingsPage, "Movement Settings", 1, true)
addStepper(tweenCfg, 1, "Hold at egg", function() return Steal.holdSeconds end, function(v) Steal.holdSeconds = v end, 1, 10, 1, "s")
addStepper(tweenCfg, 2, "Speed (To Egg)", function() return Steal.speed end, function(v) Steal.speed = v end, MIN_SPEED, MAX_SPEED, 50, "")
addStepper(tweenCfg, 3, "Speed (Deliver)", function() return Steal.deliverSpeed end, function(v) Steal.deliverSpeed = v end, MIN_SPEED, MAX_SPEED, 50, "")

local CONFIG_FILE = "OLIVER_AutoSteal.json"
local cfgSection = makeSection(settingsPage, "Config", 2, true)
local cfgRow = new("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = 1}, cfgSection)
local cfgMsg = label(cfgSection, "", 11, MUTED)
cfgMsg.Size = UDim2.new(1, 0, 0, 16)
cfgMsg.LayoutOrder = 2

local function cfgNotify(text, good)
	cfgMsg.Text = text
	cfgMsg.TextColor3 = good and GREEN or Color3.fromRGB(255, 110, 110)
	task.delay(2.5, function()
		if cfgMsg.Text == text then cfgMsg.Text = "" end
	end)
end

local function refreshAll()
	renderMods()
	for _, name in ipairs(RARITIES) do renderChip(name) end
	for _, f in ipairs(refreshers) do f() end
end

local function cfgReset()
	Steal.rarities = {}
	Steal.holdSeconds = 0
	Steal.mode = "Instant"
	Steal.speed = 300
	Steal.deliverSpeed = 450
	refreshAll()
end

local function cfgSave()
	if type(writefile) ~= "function" then return false, "Executor has no writefile" end
	local rars = {}
	for n in pairs(Steal.rarities) do table.insert(rars, n) end
	local data = {
		mode = Steal.mode, rarities = rars, hold = Steal.holdSeconds, speed = Steal.speed, deliver = Steal.deliverSpeed,
	}
	local ok, err = pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(data)) end)
	return ok, ok and "Saved" or tostring(err)
end

local function cfgLoad()
	if type(readfile) ~= "function" or type(isfile) ~= "function" then return false, "Executor has no readfile" end
	if not isfile(CONFIG_FILE) then return false, "No saved config" end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
	if not ok or type(data) ~= "table" then return false, "Config file is invalid" end
	for _, m in ipairs(MODES) do
		if m.key == data.mode then Steal.mode = m.key end
	end
	Steal.rarities = {}
	for _, n in ipairs(type(data.rarities) == "table" and data.rarities or {}) do
		if RARITY_COLORS[n] then Steal.rarities[n] = true end
	end
	Steal.holdSeconds = math.clamp(tonumber(data.hold) or 5, 1, 10)
	Steal.speed = math.clamp(tonumber(data.speed) or 350, MIN_SPEED, MAX_SPEED)
	Steal.deliverSpeed = math.clamp(tonumber(data.deliver) or 450, MIN_SPEED, MAX_SPEED)
	refreshAll()
	return true, "Loaded"
end

local function cfgButton(text, x, color, fn)
	local b = new("TextButton", {
		Size = UDim2.new(1 / 3, -4, 1, 0), Position = UDim2.new(x, 0, 0, 0), BackgroundColor3 = color,
		Text = text, TextColor3 = Color3.new(1, 1, 1), TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false,
	}, cfgRow)
	corner(b, 8)
	b.MouseButton1Click:Connect(function()
		local ok, msg = fn()
		cfgNotify(msg, ok)
	end)
end
cfgButton("Save", 0, Color3.fromRGB(70, 100, 230), cfgSave)
cfgButton("Load", 1 / 3, Color3.fromRGB(60, 150, 110), cfgLoad)
cfgButton("Reset", 2 / 3, Color3.fromRGB(150, 70, 80), function() cfgReset() return true, "Reset to default" end)

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

pcall(cfgLoad)
print("[OLIVER] Auto Steal (Instant + Tween) Initialized!")
