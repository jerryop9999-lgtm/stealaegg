-- [[ SenaV4 Hub & OLIVER Auto Steal - Fly Mod & Speed 1000 Delivery ]] --
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

genv.__SenaV4TweenRuntimeGeneration = (genv.__SenaV4TweenRuntimeGeneration or 0) + 1
local tbl2 = {genv.__SenaV4TweenRuntimeGeneration, {KEY = "__SenaV4StealAnEggMovementSpoof", VERSION = 436, INTEGRITY_KEY = "__SenaV4StealAnEggIntegritySpoof", SIGNAL = "ClientCharacter: GetDebugSnapshot", HEADROOM = 1.35, CLAMP = 0.15, PADDING = 24, MULTIPLIER = 10, MIN_INPUT = 20, MAX_INPUT = 100, DEF_INPUT = 60, MIN_SPEED = 200, MAX_SPEED = 1000, DEF_SPEED = 350, FIELDS = {"LastObservedSample", "LastSample", "LastGoodSample", "LastGameplayTrustedSample", "LastValidatedSample", "LastValidatedGroundedSample", "LastConfirmedGroundSample", "CandidateGroundedSample"}}}
tbl2.n = 2
local v2
_, v2 = tbl2[1], tbl2[2]
local key = v2.KEY
local version = v2.VERSION
local integrityKey = v2.INTEGRITY_KEY
local signal = v2.SIGNAL
local headroom = v2.HEADROOM
local clamp = v2.CLAMP
local padding = v2.PADDING
local multiplier = v2.MULTIPLIER
local minInput = v2.MIN_INPUT
local maxInput = v2.MAX_INPUT
local defInput = v2.DEF_INPUT
local minSpeed = v2.MIN_SPEED
local maxSpeed = v2.MAX_SPEED
local defSpeed = v2.DEF_SPEED
local fields = v2.FIELDS
local n = 60

RunService.Heartbeat:Connect(function(deltaTime)
	if deltaTime and deltaTime > 0 then
		n = n * 0.9 + 1 / deltaTime * 0.1
	end
end)

genv.__SenaV4NetPing = function()
	local n2 = 0
	pcall(function()
		n2 = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	return tonumber(n2) or 0
end

-- Hover Pad System (Fly Mod) & Sena Integrity Core
local n2, n3, name, str, v3 = 8, 1, "__SenaV4HoverPad", "SenaV4RuntimeOwner"
local str2 = tostring(math.random(100000, 999999))
local connection, connection2
local tbl3, v4, fn4

local function fn5()
	fn4 = nil
	for i, child in ipairs(Workspace:GetChildren()) do
		if child:IsA("BasePart") and (child.Name == name and child ~= v3) then
			pcall(child.Destroy, child)
		end
	end
end

local function fn6(arg)
	if v3 then
		if not v3.Parent then
			return false
		end
	else
		return false
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoidRootPart or not humanoid then
		return false
	end

	local position = typeof(arg) == "Vector3" and arg or humanoidRootPart.Position
	local n4 = humanoid.RigType == Enum.HumanoidRigType.R15 and humanoidRootPart.Size.Y * 0.5 + math.max(humanoid.HipHeight, 0.5) or humanoidRootPart.Size.Y * 0.5 + 2
	v3.CFrame = CFrame.new(position.X, position.Y - n4 - n3 * 0.5 - 0.05, position.Z)
	return true
end

local function fn7()
	if (if v3 then not v3.Parent else not v3) or v3:GetAttribute(str) ~= str2 then
		fn5()
		if v3 and v3.Parent then
			pcall(v3.Destroy, v3)
		end

		local part = Instance.new("Part")
		part.Name = name
		part:SetAttribute(str, str2)
		part.Anchored = true
		part.CanCollide = true
		part.CanQuery = true
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(n2, n3, n2)
		v3 = part
		part.Parent = Workspace
	end

	fn6()

	if not connection then
		connection = RunService.PreSimulation:Connect(function()
			if not fn6() then
				fn7()
			end
		end)
	end

	if not connection2 then
		connection2 = RunService.PostSimulation:Connect(function()
			fn6()
		end)
	end
end

local function fn8()
	if connection then
		pcall(connection.Disconnect, connection)
		connection = nil
	end

	if connection2 then
		pcall(connection2.Disconnect, connection2)
		connection2 = nil
	end

	if v3 then
		pcall(v3.Destroy, v3)
		v3 = nil
	end

	fn5()
end

fn8()

local function fn9()
	v4 = nil
end

local function fn10(rootPart, cFrame)
	local tbl4 = {}
	if rootPart and typeof(cFrame) == "CFrame" then
		tbl4[1] = {}
		tbl4[1].Character = localPlayer.Character
		tbl4[1].RootPart = rootPart
		tbl4[1].CFrame = cFrame
		v4 = tbl4[1]
	end
end

local function fn11()
	local v5 = v4
	if type(v5) ~= "table" or typeof(v5.CFrame) ~= "CFrame" then
		return false
	end

	if localPlayer.Character ~= v5.Character then
		v4 = nil
		return false
	else
		if not v5.RootPart or not v5.RootPart.Parent then
			v4 = nil
			return false
		end
	end

	fn7()
	v5.RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	v5.RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	fn6(v5.CFrame.Position)
	v5.RootPart.CFrame = v5.CFrame
	fn6(v5.CFrame.Position)
	return true
end

local function fn12()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	for k, v5 in pairs(tbl3) do
		if type(v5) == "table" then
			v5.cancelled = true
		end
	end

	table.clear(tbl3)

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	end

	fn9()
	fn8()
end

genv.__SenaV4TweenRuntimeCleanup = function()
	for k, v5 in pairs(tbl3) do
		if type(v5) == "table" then
			v5.cancelled = true
		end
	end
	table.clear(tbl3)
	fn9()
	fn8()
end

local function fn13()
	return getgenv and getgenv() or _G
end

local function fn14()
	local v5 = fn13()
	local tbl4 = v5[key]

	if type(tbl4) ~= "table" or tbl4.Version ~= version then
		if type(tbl4) == "table" then
			tbl4.Enabled = false
		end

		tbl4 = {Version = version, Installed = false, Enabled = false, Mode = "StateBaseline", Humanoid = nil, RootPart = nil, WalkSpeed = defSpeed}
		v5[key] = tbl4
	end

	return tbl4
end

local function fn15(arg, arg2)
	local v5 = fn14()
	if not v5 then
		return false
	end
	local humanoid = arg and arg:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = arg and arg:FindFirstChild("HumanoidRootPart")
	v5.Humanoid = humanoid
	v5.RootPart = humanoidRootPart
	v5.WalkSpeed = math.clamp(tonumber(arg2) or defSpeed, minSpeed, maxSpeed * headroom)
	v5.Enabled = false
	return humanoid ~= nil and humanoidRootPart ~= nil
end

local function fn16()
	local v5 = fn13()[key]
	if type(v5) == "table" then
		v5.Enabled = false
		v5.Humanoid = nil
		v5.RootPart = nil
	end
end

local function fn17(arg, arg2, arg3)
	local v5
	if type(getcallbackvalue) == "function" and type(debug) == "table" and type(debug.getupvalue) == "function" then
		local signal2 = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Signal")
		if signal2 then
			local ok, result = pcall(require, signal2)
			if ok and type(result) == "table" and type(result.Invoked) == "function" then
				local ok2, result2 = pcall(result.Invoked, signal)
				if ok2 and result2 then
					local ok3, result3 = pcall(getcallbackvalue, result2, "OnInvoke")
					if ok3 and type(result3) == "function" then
						local ok4, result4 = pcall(debug.getinfo, result3)
						if ok4 then
							local function fn18_inner(arg4, arg5, arg6)
								if v5 or type(arg4) ~= "table" or arg5 > 3 or arg6[arg4] then
									return
								end
								arg6[arg4] = true
								if rawget(arg4, "Player") == arg and rawget(arg4, "Character") == arg.Character and rawget(arg4, "Humanoid") == arg2 and rawget(arg4, "RootPart") == arg3 and type(rawget(arg4, "SampleHistory")) == "table" and type(rawget(arg4, "Evidence")) == "table" then
									v5 = arg4
									return
								end
								local n4 = 0
								for k, v6 in pairs(arg4) do
									n4 += 1
									if n4 > 128 then break end
									if type(v6) == "table" then
										fn18_inner(v6, arg5 + 1, arg6)
									end
								end
							end

							for i = 1, result4.nups or 0, 1 do
								local ok5, result5 = pcall(debug.getupvalue, result3, i)
								if ok5 and type(result5) == "table" then
									fn18_inner(result5, 0, {})
									if v5 then break end
								end
							end
						end
					end
				end
			end
		end
	end

	if not v5 and type(getgc) == "function" then
		local ok, result = pcall(getgc, true)
		if ok and type(result) == "table" then
			for i, v6 in ipairs(result) do
				if type(v6) == "table" and rawget(v6, "Player") == arg and rawget(v6, "Character") == arg.Character and rawget(v6, "Humanoid") == arg2 and rawget(v6, "RootPart") == arg3 and type(rawget(v6, "SampleHistory")) == "table" and type(rawget(v6, "Evidence")) == "table" then
					v5 = v6
					break
				end
			end
		end
	end

	return v5
end

local tbl4 = {busy = false, nextAt = 0, misses = 0, found = nil}

local function fn18(arg, arg2, arg3)
	local found = tbl4.found
	if type(found) == "table" and rawget(found, "Player") == arg and rawget(found, "Character") == arg.Character and rawget(found, "Humanoid") == arg2 and rawget(found, "RootPart") == arg3 then
		return found
	end

	if tbl4.busy or os.clock() < tbl4.nextAt then
		return nil
	end

	tbl4.busy = true
	task.spawn(function()
		task.wait()
		local ok, result = pcall(fn17, arg, arg2, arg3)
		local v5 = ok and result or nil
		tbl4.found = v5
		tbl4.misses = v5 and 0 or tbl4.misses + 1
		tbl4.nextAt = os.clock() + (v5 and 0.2 or (tbl4.misses >= 5 and 10 or 1))
		tbl4.busy = false
	end)

	return nil
end

local function fn19(arg, arg2, arg3)
	if type(arg) ~= "table" then
		return false
	end
	local value = rawget(arg, "RootPart")
	local cFrame = value and value.Parent and value.CFrame or nil
	local position = cFrame and cFrame.Position or nil
	local vector = typeof(arg3) == "Vector3" and arg3 or Vector3.new(0, 0, 0)

	local function fn20_inner(arg4)
		if type(arg4) == "table" then
			rawset(arg4, "WalkSpeed", arg2)
			if cFrame then
				rawset(arg4, "CFrame", cFrame)
				rawset(arg4, "Position", position)
				rawset(arg4, "LinearVelocity", vector)
				rawset(arg4, "AngularVelocity", Vector3.new(0, 0, 0))
			end
		end
	end

	for i, field in ipairs(fields) do
		fn20_inner(rawget(arg, field))
	end

	for k, v5 in pairs(rawget(arg, "SampleHistory") or {}) do
		fn20_inner(v5)
	end

	for k, v5 in pairs(rawget(arg, "SafeGroundCheckpoints") or {}) do
		fn20_inner(v5)
	end

	local value2 = rawget(arg, "Evidence")
	if type(value2) == "table" then
		value2.Speed = 0
		value2.Teleport = 0
		value2.Flight = 0
	end

	local value3 = rawget(arg, "ImpulseContext")
	if type(value3) == "table" then
		local maxHorizontalSpeed = math.max(tonumber(value3.MaxHorizontalSpeed) or 0, arg2)
		local n4 = math.max((tonumber(value3.ExpiresAt) or 0) - (tonumber(value3.StartedAt) or 0), clamp)
		value3.MaxHorizontalSpeed = maxHorizontalSpeed
		if position then
			value3.OriginPosition = position
		end
		value3.MaxHorizontalDistance = math.max(tonumber(value3.MaxHorizontalDistance) or 0, maxHorizontalSpeed * n4 + padding * 2)
		fn20_inner(value3.PreMovementSafeSample)
	end

	if rawget(arg, "CorrectionContext") == nil then
		rawset(arg, "FirstSuspiciousAt", nil)
		if rawget(arg, "ThreatLevel") == "Observing" then
			rawset(arg, "ThreatLevel", "Trusted")
		end
	end

	return true
end

local function fn20()
	local v5 = fn13()
	local tbl5 = v5[integrityKey]
	if type(tbl5) ~= "table" then
		tbl5 = {}
		v5[integrityKey] = tbl5
	end
	return tbl5
end

local function fn21(arg, arg2, arg3)
	return type(arg) == "table" and rawget(arg, "Player") == localPlayer and rawget(arg, "Character") == localPlayer.Character and rawget(arg, "Humanoid") == arg2 and rawget(arg, "RootPart") == arg3
end

local function fn22(arg, arg2, arg3)
	return fn21(arg, arg2, arg3)
end

local function fn23(humanoid, rootPart, arg)
	local v5 = fn20()
	local state = v5.State

	if not fn21(state, humanoid, rootPart) then
		local now = os.clock()
		if now < (v5.NextSearchAt or 0) then
			return false
		end
		v5.NextSearchAt = now + 0.2
		state = fn18(localPlayer, humanoid, rootPart)
	end

	if not state or not fn22(state, humanoid, rootPart) then
		v5.Enabled = false
		v5.Humanoid = humanoid
		v5.RootPart = rootPart
		v5.State = state
		return false
	end

	v5.NextSearchAt = 0
	v5.Enabled = true
	v5.Humanoid = humanoid
	v5.RootPart = rootPart
	v5.State = state
	v5.WalkSpeed = math.clamp(arg * headroom, minSpeed, maxSpeed * headroom)
	v5.TravelVelocity = Vector3.new(0, 0, 0)
	fn19(state, v5.WalkSpeed, v5.TravelVelocity)
	return true
end

local function fn24(arg, arg2, arg3, travelVelocity)
	local v5 = fn13()[integrityKey]
	if type(v5) ~= "table" or not v5.Enabled then
		return false
	elseif v5.Humanoid ~= arg or v5.RootPart ~= arg2 or not fn22(v5.State, arg, arg2) then
		return false
	end

	v5.WalkSpeed = math.clamp(arg3 * headroom, minSpeed, maxSpeed * headroom)
	v5.TravelVelocity = typeof(travelVelocity) == "Vector3" and travelVelocity or (typeof(v5.TravelVelocity) == "Vector3" and v5.TravelVelocity or Vector3.new(0, 0, 0))

	return fn19(v5.State, v5.WalkSpeed, v5.TravelVelocity)
end

local function fn25(arg)
	local v5 = fn13()[integrityKey]
	if type(v5) ~= "table" then return end
	if arg == nil or v5.Humanoid == arg then
		v5.Enabled = false
		v5.Humanoid = nil
		v5.RootPart = nil
		v5.State = nil
		v5.TravelVelocity = nil
		v5.NextSearchAt = 0
	end
end

local connection3
local function fn26()
	if connection3 then return end
	connection3 = RunService.PreSimulation:Connect(function()
		if genv.__SenaV4TweenRuntimeGeneration ~= v then
			local v5 = connection3
			connection3 = nil
			if v5 then pcall(v5.Disconnect, v5) end
			return
		end

		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not character or not humanoidRootPart or not humanoid then return end

		local speedInput = 350
		fn15(character, speedInput * headroom)
		if not fn24(humanoid, humanoidRootPart, speedInput) then
			fn23(humanoid, humanoidRootPart, speedInput)
		end
		fn11()
	end)
end

local function fn27()
	if connection3 then
		pcall(connection3.Disconnect, connection3)
		connection3 = nil
	end
	fn16()
	fn25()
end

genv.__SenaV4TweenRuntimeCleanup = function()
	fn12()
	fn27()
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
	{name = "High Speed Fly Mod", desc = "Sena Fly + Integrity Spoof + Delivery Speed 1000"},
}

local Steal = {
	enabled = false,
	status = "Idle",
	target = "-",
	carrying = false,
	mode = "High Speed Fly Mod",
	rarities = {},
	holdSeconds = 5,
	speed = 350, -- ល្បឿនពេលទៅយក Egg (តាមการកំណត់ក្នុង UI/Game)
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

local function inSafe(root)
	local d = root.Position - SAFE_POS
	return Vector2.new(d.X, d.Z).Magnitude <= SAFE_RADIUS and math.abs(d.Y) <= 18
end

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
		part.Size = Vector3.new(8, 2, 8) -- បង្កើនទំហំកម្ពស់ Fly Pad ឱ្យផុតពីដី
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

local MIN_SPEED, MAX_SPEED = 200, 1000

local function travel(pos, abort)
	local speed = math.clamp(Steal.speed, MIN_SPEED, MAX_SPEED)
	local root, hum = getRoot()
	if not root or not hum then return false end
	
	fn26()
	fn23(hum, root, speed)
	
	local takeoffPos = Vector3.new(pos.X, math.max(pos.Y, root.Position.Y + 10), pos.Z)
	
	local slowUntil, lastMag, arrivedAt = 0, nil, nil
	while true do
		root, hum = getRoot()
		if not root or not hum or hum.Health <= 0 then fn27() return false end
		if abort and abort() then fn27() return false end
		
		local dt = RunService.Heartbeat:Wait()
		root, hum = getRoot()
		if not root or not hum then fn27() return false end
		dt = math.max(math.min(dt, 0.15), 1 / 240)

		local cur = root.Position
		local delta = takeoffPos - cur
		local mag = delta.Magnitude
		local flat = Vector3.new(delta.X, 0, delta.Z)
		local look = root.CFrame.LookVector
		local lookFlat = Vector3.new(look.X, 0, look.Z)
		local face = flat.Magnitude > 0.001 and flat.Unit or (lookFlat.Magnitude > 0.001 and lookFlat.Unit or Vector3.new(0, 0, -1))

		if lastMag and mag > lastMag + 2 then
			slowUntil = os.clock() + 0.5
		end
		lastMag = mag
		local curSpeed = os.clock() < slowUntil and math.max(MIN_SPEED, speed * 0.45) or speed
		local step = curSpeed * dt

		if mag <= math.max(step, 0.05) then
			root.CFrame = CFrame.lookAt(takeoffPos, takeoffPos + face)
			root.AssemblyLinearVelocity = Vector3.zero
			
			fn24(hum, root, speed, Vector3.new(0, 0, 0))
			
			arrivedAt = arrivedAt or os.clock()
			if os.clock() - arrivedAt >= 0.4 then fn27() return true end
		else
			arrivedAt = nil
			local nextPos = cur + delta.Unit * math.min(step, mag)
			local travelVel = (nextPos - cur) / dt
			
			root.CFrame = CFrame.lookAt(nextPos, nextPos + face)
			root.AssemblyLinearVelocity = Vector3.zero
			
			fn24(hum, root, speed, travelVel)
		end
	end
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
				Steal.status = "Delivering egg (Speed 1000)"
				if not inSafe(root) then
					-- 🚀 កំណត់ល្បឿនមក Base វិញ ឱ្យលឿនបំផុត 1000
					local oldSpeed = Steal.speed
					Steal.speed = 600 
					travel(SAFE_POS + Vector3.new(0, 2, 0), function() return stopped() or not myCarriedEgg() end)
					Steal.speed = oldSpeed
				else
					Steal.status = "Waiting for deposit"
					root.CFrame = CFrame.new(SAFE_POS + Vector3.new(0, 1, 0))
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
	Steal.mode = "High Speed Fly Mod"
	Steal.rarities = {}
	Steal.holdSeconds = 0
	Steal.speed = 300
	refreshAll()
end

local function cfgSave()
	if type(writefile) ~= "function" then return false, "Executor has no writefile" end
	local rars = {}
	for n in pairs(Steal.rarities) do table.insert(rars, n) end
	local data = {
		mode = Steal.mode, rarities = rars, hold = Steal.holdSeconds, speed = Steal.speed,
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
		if m.name == data.mode then Steal.mode = m.name end
	end
	Steal.rarities = {}
	for _, n in ipairs(type(data.rarities) == "table" and data.rarities or {}) do
		if RARITY_COLORS[n] then Steal.rarities[n] = true end
	end
	Steal.holdSeconds = math.clamp(tonumber(data.hold) or 5, 1, 10)
	Steal.speed = math.clamp(tonumber(data.speed) or 350, MIN_SPEED, MAX_SPEED)
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
print("[SenaV4 + OLIVER] Fly Mod & Speed 1000 Delivery Initialized!")
