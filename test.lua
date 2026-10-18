-- [[ SenaV4 Hub - Full Complete Script ]] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

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

if not rawget(_G, "setfpscap") and not rawget(_G, "set_fps_cap") then
	senaV4IdentitySetter = type(setfpscap) == "function"
end

genv.__SenaV4SetCapFps = function(arg)
	local n = tonumber(arg) or 240
	local n2 = math.clamp(math.floor(n), 1, 1000)
	local flag = rawget(_G, "setfpscap") or rawget(_G, "set_fps_cap") or type(setfpscap) == "function" and setfpscap
	if type(flag) == "function" then
		return pcall(flag, n2)
	end
	return false
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
local tbl2 = {genv.__SenaV4TweenRuntimeGeneration, {KEY = "__SenaV4StealAnEggMovementSpoof", VERSION = 436, INTEGRITY_KEY = "__SenaV4StealAnEggIntegritySpoof", SIGNAL = "ClientCharacter: GetDebugSnapshot", HEADROOM = 1.35, CLAMP = 0.15, PADDING = 24, MULTIPLIER = 10, MIN_INPUT = 20, MAX_INPUT = 100, DEF_INPUT = 60, MIN_SPEED = 200, MAX_SPEED = 1000, DEF_SPEED = 600, FIELDS = {"LastObservedSample", "LastSample", "LastGoodSample", "LastGameplayTrustedSample", "LastValidatedSample", "LastValidatedGroundedSample", "LastConfirmedGroundSample", "CandidateGroundedSample"}}}
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

local n2, n3, name, str, v3 = 8, 1, "__SenaV4HoverPad", "SenaV4RuntimeOwner"
local str2 = tostring(math.random(100000, 999999))
local connection, connection2
local tbl3, v4, fn4

local function fn5()
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

	if humanoidRootPart then
		if not humanoid then
			return false
		end
	else
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
		part.Material = Enum.Material.SmoothPlastic
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

	if type(v5) ~= "table" then
		return false
	elseif typeof(v5.CFrame) ~= "CFrame" then
		return false
	end

	if localPlayer.Character ~= v5.Character then
		v4 = nil
		return false
	else
		if v5.RootPart then
			if not v5.RootPart.Parent then
				v4 = nil
				return false
			end
		else
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
							local function fn18(arg4, arg5, arg6)
								if v5 then
									return
								elseif type(arg4) ~= "table" then
									return
								elseif arg5 > 3 then
									return
								elseif arg6[arg4] then
									return
								end

								arg6[arg4] = true
								if rawget(arg4, "Player") == arg and (rawget(arg4, "Character") == arg.Character and (rawget(arg4, "Humanoid") == arg2 and (rawget(arg4, "RootPart") == arg3 and (type(rawget(arg4, "SampleHistory")) == "table" and type(rawget(arg4, "Evidence")) == "table")))) then
									v5 = arg4
									return
								end
								local n4 = 0

								for k, v6 in pairs(arg4) do
									n4 += 1
									if n4 > 128 then
										break
									end

									if type(v6) == "table" then
										fn18(v6, arg5 + 1, arg6)
									end
								end
							end

							for i = 1, result4.nups or 0, 1 do
								local ok5, result5 = pcall(debug.getupvalue, result3, i)

								if ok5 and type(result5) == "table" then
									fn18(result5, 0, {})
									if v5 then
										break
									end
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
	if type(found) == "table" and (rawget(found, "Player") == arg and (rawget(found, "Character") == arg.Character and (rawget(found, "Humanoid") == arg2 and rawget(found, "RootPart") == arg3))) then
		return found
	end

	if tbl4.busy then
		return nil
	elseif os.clock() < tbl4.nextAt then
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

	local function fn20(arg4)
		if type(arg4) == "table" then
			rawset(arg4, "WalkSpeed", arg2)

			if cFrame then
				rawset(arg4, "CFrame", cFrame)
				rawset(arg4, "Position", position)
				rawset(arg4, "LinearVelocity", vector)
				rawset(arg4, "AngularVelocity", (Vector3.new(0, 0, 0)))
			end
		end
	end

	for i, field in ipairs(fields) do
		fn20(rawget(arg, field))
	end

	for k, v5 in pairs(rawget(arg, "SampleHistory") or {}) do
		fn20(v5)
	end

	for k, v5 in pairs(rawget(arg, "SafeGroundCheckpoints") or {}) do
		fn20(v5)
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
		fn20(value3.PreMovementSafeSample)
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

	if fn21(state, humanoid, rootPart) then
	else
		local now = os.clock()
		if now < (v5.NextSearchAt or 0) then
			return false
		end
		v5.NextSearchAt = now + 0.2
		state = fn18(localPlayer, humanoid, rootPart)
	end

	if not state then
		return false
	end

	if not fn22(state, humanoid, rootPart) then
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

	if type(v5) ~= "table" then
		return false
	elseif v5.Enabled then
		if v5.Humanoid ~= arg then
			return false
		elseif v5.RootPart ~= arg2 then
			return false
		elseif not fn22(v5.State, arg, arg2) then
			return false
		end
	else
		return false
	end

	v5.WalkSpeed = math.clamp(arg3 * headroom, minSpeed, maxSpeed * headroom)

	if typeof(travelVelocity) == "Vector3" then
		v5.TravelVelocity = travelVelocity
	elseif typeof(v5.TravelVelocity) ~= "Vector3" then
		v5.TravelVelocity = Vector3.new(0, 0, 0)
	end

	return fn19(v5.State, v5.WalkSpeed, v5.TravelVelocity)
end

local function fn25(arg)
	local v5 = fn13()[integrityKey]
	if type(v5) ~= "table" then
		return
	end

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
	if connection3 then
		return
	end

	connection3 = RunService.PreSimulation:Connect(function()
		if genv.__SenaV4TweenRuntimeGeneration ~= v then
			local v5 = connection3
			connection3 = nil

			if v5 then
				pcall(v5.Disconnect, v5)
			end

			return
		end

		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if character then
			if humanoidRootPart then
				if not humanoid then
					return
				end
			else
				return
			end
		else
			return
		end

		local v5 = fn4()
		fn15(character, v5 * headroom)

		if not fn24(humanoid, humanoidRootPart, v5) then
			fn23(humanoid, humanoidRootPart, v5)
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

local function fn28()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end
	local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local walkSpeed = humanoid and humanoid.WalkSpeed or 0
	local vector = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

	if vector.Magnitude > math.max(400, walkSpeed * 1.5) or math.abs(assemblyLinearVelocity.Y) > 400 then
		local n4 = math.max(100, walkSpeed)
		local v5 = if vector.Magnitude > n4 then vector.Unit * n4 else vector
		humanoidRootPart.AssemblyLinearVelocity = Vector3.new(v5.X, math.clamp(assemblyLinearVelocity.Y, -100, 100), v5.Z)
	end
end

RunService.Heartbeat:Connect(fn28)
local flag = false

pcall(function()
	local queueOnTeleport = queue_on_teleport or queueonteleport or syn and syn.queue_on_teleport

	if queueOnTeleport then
		pcall(queueOnTeleport, "")
	end
end)

pcall(function()
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)

local connection4, connection5

local function fn29(arg)
	if not arg then
		return
	end
	local humanoid = arg:WaitForChild("Humanoid", 5) or arg:FindFirstChildOfClass("Humanoid")

	if not arg:WaitForChild("HumanoidRootPart", 5) then
		arg:FindFirstChild("HumanoidRootPart")
	end

	if not humanoid then
		return
	end
	local health = math.max(humanoid.MaxHealth, 100)
	local flag2 = false
	local n4 = 0

	local function fn30()
		if flag2 then
			return
		elseif not humanoid.Parent then
			return
		end

		local now = os.clock()
		if now - n4 < 0.1 and (humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead) then
			return
		end
		n4, flag2 = now, true

		pcall(function()
			humanoid.BreakJointsOnDeath = false
			humanoid.RequiresNeck = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

			if humanoid.Health <= 0 then
				humanoid.Health = health
			end

			if humanoid:GetState() == Enum.HumanoidStateType.Dead then
				humanoid:ChangeState(Enum.HumanoidStateType.Running)
			end
		end)

		flag2 = false
	end

	fn30()

	if connection4 then
		pcall(connection4.Disconnect, connection4)
	end

	if connection5 then
		pcall(connection5.Disconnect, connection5)
	end

	connection4 = humanoid.HealthChanged:Connect(function(health2)
		if health2 <= 0 then
			fn30()
		elseif health2 < health then
			fn30()
		end
	end)

	connection5 = RunService.Heartbeat:Connect(fn30)
end

task.spawn(function()
	fn29(localPlayer.Character or localPlayer.CharacterAdded:Wait())
end)

local function fn30(character)
	fn29(character)
end

localPlayer.CharacterAdded:Connect(fn30)
local senaV4Config = {AutoSteal = false, HelpFriend = false, LowSpeedBoost = false, StarAlert = true, ScrambleTradeInTrade = false, ScrambleTradeInReroll = false, ScrambleTradeInBanners = {}, ScrambleBossAuto = false, StealMode = "Instant", FlyAerial = false, FlyZigzag = false, StealHoldSeconds = 5, StealAreas = {"None"}, StealRarities = {"None"}, StealNamesFilter = {"None"}, StealMinValue = 0, StealMutations = {"None"}, StealMinWeight = 0, StealPriority = "Rarity", TaskOrder = {"auto_steal", "race", "star", "mech_boss", "butterfly", "auto_place", "use_scrambled", "auto_sell", "treadmill"}, AutoFavorite = false, FavMode = "Rarity", FavRarities = {"None"}, FavSpecies = {"None"}, AutoEquipBest = false, AutoClaimOffline = false, AutoBaseUpgrade = false, AutoClaimAlmanac = false, AutoFusePets = false, ScrambleAutoBuy = false, ScrambleBuyList = {}, ButterflyAutoNet = false, ButterflyAutoCatch = false, ButterflyEsp = false, ButterflyTiers = {}, ButterflyAutoTrade = false, ButterflyTradeRecipe = "All", ButterflyCatchMode = "Tween", ButterflyAutoCraft = false, WispAutoQuest = false, BanjoAuto = false, Noclip = false, BottingMode = false, AntiCutscene = false, FuseSelectedOnly = false, FuseRarities = {"None"}, FuseSpecies = {"None"}, EspDetails = {"Name", "Rarity", "Value"}, BackpackRateEsp = false, AntiAFK = true, AutoReconnect = true, AutoExecute = false, AutoPlace = false, PlaceRarities = {"None"}, AutoHatch = false, SellAll = false, AutoSell = false, SellNames = {"None"}, SellRarities = {"None"}, AutoSellEgg = false, SellEggRarities = {"None"}, WebhookEnabled = false, WebhookURL = "", WebhookDisconnect = false, TweenSpeedMultiplier = 60, AutoTreadmillIdle = false, AutoTreadmillUpgrade = false, AntiTreadmill = false, HopNoMatch = false, PrivateServerMax = "2", PrivateServerAuto = false, HopCooldown = 5, AutoIndex = false, AntiHitGuard = false, FlyForCapture = false, AutoStealCapture = false, InstantGrab = false, InfiniteJump = false, WalkSpeedMultiplier = 1, AntiGuardKnockback = true, GodMode = true, EggPredictUI = false, EggESP = false, StealPlayers = false, StealPlayerRarities = {"None"}, StealPlayerMinValue = 0, StealPlayerTarget = "Any Player", WebhookRarities = {"None"}, WebhookMinValue = 0}
local EggState = require(game:GetService("ReplicatedStorage").Client.EggState)
EggState.GetAreaEggSnapshot = EggState.ReadFieldEggs
EggState.GetAreaEggRecord = EggState.ReadFieldEgg
EggState.RequestAreaEggSnapshot = EggState.SyncFieldEggs
EggState.RequestCarryAreaEgg = EggState.CarryFieldEgg
EggState.RequestDropHeldAreaEgg = EggState.DropFieldEgg
EggState.AreaEggCarryStateChanged = EggState.CarryChanged
EggState.AreaEggClaimed = EggState.FieldClaimed
EggState.AreaEggUpdated = EggState.FieldShifted
EggState.AreaEggRemoved = EggState.FieldGone
EggState.GetOwnerRuntimeRecords = EggState.ReadOwnerEggs
EggState.RequestEquipTool = EggState.WearEggTool
EggState.RequestPlaceEgg = EggState.PlantEgg
EggState.RequestHatchEgg = EggState.BeginHatch
EggState.RequestCompleteHatchEgg = EggState.FinishHatch
EggState.RequestRuntimeSnapshot = EggState.SyncOwnedEggs
EggState.RuntimeOwnerUpdated = EggState.OwnerRefreshed
EggState.RuntimeOwnerCleared = EggState.OwnerCleared
local PlotState = require(game:GetService("ReplicatedStorage").Client.PlotState)
PlotState.GetMySlot = PlotState.ResolveLocalSlot
PlotState.GetPlotsFolder = PlotState.ResolveFolder
PlotState.IsWorldPositionWithinLocalPlotBounds = PlotState.ContainsLocalPoint
PlotState.GetPlotData = PlotState.ResolvePlot
local AreaEggResetWall = require(game:GetService("ReplicatedStorage").Client.AreaEggResetWall)
AreaEggResetWall.IsClosed = AreaEggResetWall.IsSealed

fn4 = function()
	if genv.__SenaV4AdminBoost == true then
		return 4000
	end
	return math.clamp(math.floor((tonumber(senaV4Config.TweenSpeedMultiplier) or v2.DEF_INPUT) + 0.5), v2.MIN_INPUT, v2.MAX_INPUT) * v2.MULTIPLIER
end

senaV4Config.applyStealValueInput = function(arg, arg2)
	local str3 = string.lower(tostring(arg2 or "")):gsub("[%s,]", "")
	if str3 == "" then
		arg.StealMinValue = 0
		return true
	end
	local v5, v6 = string.match(str3, "^([%d]+%.?[%d]*)([kmb]?)$")
	local num = tonumber(v5)
	if not num then
		return false
	end
	arg.StealMinValue = num * (if v6 == "k" then 1000 else if v6 == "m" then 1000000 else if v6 == "b" then 1000000000 else 1)
	return true
end

senaV4Config.getAreaEggValue = function(arg, arg2)
	if not arg._assetGenerationUtil then
		arg._assetGenerationUtil = require(game:GetService("ReplicatedStorage").Shared.Util.AssetEarnings)
	end

	return arg._assetGenerationUtil.MutationOnlyRatePerSecond({Category = arg2.AssetCategory, Scale = arg2.AssetScale or 1, Mutations = arg2.Mutations or {}, BaseMutation = arg2.BaseMutation, EyeColor = arg2.AssetEyeColor, ColorSeed = arg2.AssetColorSeed, ColorIndex = arg2.AssetColorIndex, Gender = arg2.Gender, Personality = arg2.Personality or "Normal", HasBeenFirstPlaced = arg2.HasBeenFirstPlaced == true})
end

local AreaEggCycle, AreaEggResetWall2

pcall(function()
	AreaEggCycle = require(ReplicatedStorage.Shared.Util.AreaEggCycle)
	AreaEggResetWall2 = require(ReplicatedStorage.Client.AreaEggResetWall)
end)

local function fn31()
	if AreaEggCycle and type(AreaEggCycle.IsNightPhase) == "function" then
		local ok, result = pcall(AreaEggCycle.IsNightPhase, workspace:GetServerTimeNow())
		if ok and result == true then
			return true
		end
	end

	if AreaEggResetWall2 then
		if type(AreaEggResetWall2.IsSealed) == "function" then
			local ok, result = pcall(AreaEggResetWall2.IsSealed)
			if ok and result == true then
				return true
			end
		end

		if type(AreaEggResetWall2.IsClosed) == "function" then
			local ok, result = pcall(AreaEggResetWall2.IsClosed)
			if ok and result == true then
				return true
			end
		end
	end

	return false
end

local senaV4TaskLadder = {}

do
	senaV4TaskLadder.DEFAULT = {"auto_steal", "race", "star", "mech_boss", "butterfly", "auto_place", "use_scrambled", "auto_sell", "treadmill"}
	senaV4TaskLadder.TITLES = {auto_steal = "Auto Steal", race = "Race Rally", star = "Shooting Star", mech_boss = "Mech Boss", butterfly = "Butterfly Bloom", auto_place = "Auto Place", use_scrambled = "Use Scrambled", auto_sell = "Auto Sell", treadmill = "Treadmill"}
	senaV4TaskLadder.PINNED = {treadmill = true}
	local tbl5 = {}

	senaV4TaskLadder.register = function(arg, arg2)
		tbl5[arg] = arg2
	end

	senaV4TaskLadder.sanitize = function(arg)
		local tbl6 = {}
		local tbl7 = {}

		local function fn32(arg2)
			local str3 = tostring(arg2)

			if senaV4TaskLadder.TITLES[str3] and (not tbl7[str3] and not senaV4TaskLadder.PINNED[str3]) then
				tbl7[str3] = true
				tbl6[#tbl6 + 1] = str3
			end
		end

		for i, v5 in ipairs(type(arg) == "table" and arg or {}) do
			fn32(v5)
		end

		for i, v5 in ipairs(senaV4TaskLadder.DEFAULT) do
			fn32(v5)
		end

		for i, v5 in ipairs(senaV4TaskLadder.DEFAULT) do
			if senaV4TaskLadder.PINNED[v5] and not tbl7[v5] then
				tbl7[v5] = true
				tbl6[#tbl6 + 1] = v5
			end
		end

		return tbl6
	end

	local v5, v6

	senaV4TaskLadder.order = function()
		local taskOrder = senaV4Config and senaV4Config.TaskOrder

		if taskOrder ~= v6 or not v5 then
			v6 = taskOrder
			v5 = senaV4TaskLadder.sanitize(taskOrder)
		end

		return v5
	end

	senaV4TaskLadder.rank = function(arg)
		for i, v7 in ipairs(senaV4TaskLadder.order()) do
			if v7 == arg then
				return i
			end
		end

		return 1 / 0
	end

	local function fn32(arg, arg2)
		local result = tbl5[arg]
		local v7 = result and result[arg2]
		if type(v7) ~= "function" then
			return nil
		end
		arg2, result = pcall(v7)
		if arg2 then
			return result
		end
		return nil
	end

	senaV4TaskLadder.wants = function(arg)
		return fn32(arg, "wants") == true
	end

	senaV4TaskLadder.active = function(arg)
		return fn32(arg, "active") == true
	end

	senaV4TaskLadder.enabled = function(arg)
		return fn32(arg, "enabled") == true
	end

	senaV4TaskLadder.bossFighting = function()
		if localPlayer:GetAttribute("InScrambleArena") == true then
			return true
		end

		if type(localPlayer:GetAttribute("RaceId")) == "string" then
			return true
		end
		local senaV4ScrambleBoss = genv.__SenaV4ScrambleBoss
		return senaV4ScrambleBoss ~= nil and not senaV4ScrambleBoss.destroyed and senaV4ScrambleBoss.enabled == true and senaV4ScrambleBoss:_inArena() == true
	end

	senaV4TaskLadder.stealCarrying = function()
		local senaV4EggRuntime = genv.__SenaV4EggRuntime

		if senaV4EggRuntime then
			if senaV4EggRuntime.destroyed then
				return false
			end
		else
			return false
		end

		if senaV4EggRuntime._instantReturnToken ~= nil then
			return true
		elseif senaV4EggRuntime._forestDropInProgress ~= nil then
			return true
		end

		local carry = senaV4EggRuntime.carry
		return carry ~= nil and carry.active == true and carry.uid ~= nil and carry.uid ~= senaV4EggRuntime.primerUid
	end

	local tbl6 = {}

	local function fn33(arg)
		if arg ~= "mech_boss" and senaV4TaskLadder.bossFighting() then
			return "mech_boss"
		end

		if arg ~= "auto_steal" and senaV4TaskLadder.stealCarrying() then
			return "auto_steal"
		end

		for i, v7 in ipairs(senaV4TaskLadder.order()) do
			if v7 == arg then
				return nil
			end

			if senaV4TaskLadder.wants(v7) then
				return v7
			end
		end

		return nil
	end

	senaV4TaskLadder.blocker = function(arg)
		local now = os.clock()
		local v7 = tbl6[arg]
		if v7 and now - v7.at < 0.1 then
			return v7.value
		end
		local v8 = fn33(arg)

		if v7 then
			v7.at = now
			v7.value = v8
		else
			tbl6[arg] = {at = now, value = v8}
		end

		return v8
	end

	senaV4TaskLadder.holder = function(arg)
		for i, v7 in ipairs(senaV4TaskLadder.order()) do
			if v7 ~= arg and (not senaV4TaskLadder.PINNED[v7] and senaV4TaskLadder.active(v7)) then
				return v7
			end
		end

		return nil
	end

	senaV4TaskLadder.yieldLabel = function(arg)
		local v7 = senaV4TaskLadder.blocker(arg)
		return v7 and "Yielding to " .. senaV4TaskLadder.TITLES[v7] or nil
	end

	senaV4TaskLadder.current = function()
		if senaV4TaskLadder.bossFighting() then
			return "mech_boss"
		end

		if senaV4TaskLadder.stealCarrying() then
			return "auto_steal"
		end

		for i, v7 in ipairs(senaV4TaskLadder.order()) do
			if senaV4TaskLadder.active(v7) then
				return v7
			end
		end

		return nil
	end

	senaV4TaskLadder.describe = function(arg)
		if not senaV4TaskLadder.enabled(arg) then
			return "Off", "off"
		end
		local v7 = fn32(arg, "status")
		local flag2 = type(v7) == "string" and v7 ~= "" and v7 or nil

		if senaV4TaskLadder.active(arg) then
			return flag2 or "Running", "run"
		elseif senaV4TaskLadder.current() == arg then
			return flag2 or "Running", "run"
		end

		local v8 = senaV4TaskLadder.blocker(arg)
		if v8 and senaV4TaskLadder.wants(arg) then
			return "Yielding to " .. senaV4TaskLadder.TITLES[v8], "wait"
		end
		return flag2 or "Idle", "off"
	end
end

genv.__SenaV4TaskLadder = senaV4TaskLadder

local function fn32()
	return senaV4TaskLadder.blocker("auto_sell") == nil
end

local function fn33(arg)
	if not arg or type(arg.GetValue) ~= "function" then
		return nil
	end

	local ok, result = pcall(function()
		return arg:GetValue()
	end)

	if not ok then
		return nil
	end

	if type(result) == "table" then
		local tbl5 = {}

		for k, v5 in pairs(result) do
			if type(k) == "number" then
				table.insert(tbl5, v5)
			elseif type(k) == "string" then
				if v5 == true then
					table.insert(tbl5, k)
				end
			end
		end

		return tbl5
	end

	if type(result) == "string" then
		return {result}
	end
	return nil
end

local function fn34(arg, arg2, arg3, arg4)
	if senaV4Config.SellAll then
		return true
	end

	if type(arg3) ~= "table" then
		return false
	elseif type(arg4) ~= "table" then
		return false
	end

	return (if #arg3 == 0 then false else if table.find(arg3, "None") then false else if table.find(arg3, "All") then true else table.find(arg3, arg) ~= nil) or (if #arg4 == 0 then false else if table.find(arg4, "None") then false else if table.find(arg4, "All") then true else table.find(arg4, arg2) ~= nil)
end

local function fn35(arg, arg2)
	if type(arg2) ~= "table" then
		return false
	end

	if #arg2 == 0 then
		return false
	elseif table.find(arg2, "None") then
		return false
	end

	if table.find(arg2, "All") then
		return true
	end
	return table.find(arg2, arg) ~= nil
end

local function fn36(arg)
	local humanoidRootPart = arg and arg:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart:SetAttribute("KillPartIgnore", true)
	end
end

local n4 = 0.15
local n5 = 0.4
local vector = Vector3.new(542.93, 71.5, -405.58)
local n6 = 5
local tbl5 = {CarryRetry = 0.25, CarryTimeout = 2, EarlyCarryDistance = 8, SafeStable = 0.35, ReturnValidation = 0.08, NextTarget = 0.05, SafeHandoff = 0.15}

local function fn37(arg)
	local tweenSpeedMultiplier = math.clamp(math.floor((tonumber(arg) or v2.DEF_INPUT) + 0.5), v2.MIN_INPUT, v2.MAX_INPUT)
	if math.abs((senaV4Config.TweenSpeedMultiplier or 0) - tweenSpeedMultiplier) <= 0.001 then
		return
	end
	senaV4Config.TweenSpeedMultiplier = tweenSpeedMultiplier
end

local n7 = 0.08
local tbl6 = {}

local function fn38(arg, cameraSubject, arg2, arg3, arg4, arg5, arg6)
	if arg then
		if not cameraSubject then
			return false
		elseif typeof(arg2) ~= "CFrame" then
			return false
		end
	else
		return false
	end

	if arg3 and arg3() then
		return false
	end
	local v5 = tbl6[arg]

	if v5 then
		v5.cancelled = true
		tbl6[arg] = nil
	end

	local parent = arg.Parent
	if not parent then
		return false
	end
	fn9()
	fn36(parent)
	fn26()
	local currentCamera = workspace.CurrentCamera

	if currentCamera and currentCamera.CameraSubject ~= cameraSubject then
		pcall(function()
			currentCamera.CameraSubject = cameraSubject
		end)
	end

	local autoRotate = cameraSubject.AutoRotate
	cameraSubject.AutoRotate = false
	local n8 = arg6 and math.max(arg.Position.Y, arg2.Position.Y + n6, vector.Y + n6) or nil
	local n9 = n8 and CFrame.new(arg2.Position.X, n8, arg2.Position.Z) * arg2.Rotation or arg2
	local n10 = math.clamp(fn4(), v2.MIN_SPEED, genv.__SenaV4AdminBoost == true and 3000 or v2.MAX_SPEED)
	fn15(parent, n10 * v2.HEADROOM)
	local tbl7 = {cancelled = false}
	tbl6[arg] = tbl7
	fn7()
	local str3 = n8 and (math.abs(arg.Position.Y - n8) > 0.35 and "takeoff" or "cruise") or nil
	local magnitude = (n9.Position - arg.Position).Magnitude
	local n11 = os.clock() + math.max(magnitude / n10, n7) * 3 + 8
	local v6, now
	local n12 = 0
	local flag2 = false
	local flag3 = false

	while not tbl7.cancelled do
		if arg3 and arg3() then
			break
		end

		if not arg.Parent then
			break
		end

		if os.clock() >= n11 then
			break
		end
		local result = RunService.Heartbeat:Wait()
		local n13 = math.max(math.min(result, n4), 0.004166666666666667)
		local n14 = math.clamp(fn4(), v2.MIN_SPEED, genv.__SenaV4AdminBoost == true and 3000 or v2.MAX_SPEED)
		fn15(parent, n14 * v2.HEADROOM)
		local v7 = fn13()[v2.INTEGRITY_KEY]
		local state = type(v7) == "table" and v7.State or nil

		if fn22(state, cameraSubject, arg) then
			local position = arg.Position
			local n15 = n9.Position - position
			local magnitude2 = n15.Magnitude
			local vector2 = Vector3.new(n15.X, 0, n15.Z)
			str3 = if n8 then if str3 == "takeoff" then if math.abs(position.Y - n8) <= 0.35 then "cruise" else str3 else str3 else str3
			local n16 = (n8 and str3 == "takeoff" and Vector3.new(position.X, n8, position.Z) or n9.Position) - position
			local magnitude3 = n16.Magnitude
			local magnitude4 = n8 and vector2.Magnitude or magnitude2
			n12 = if v6 then if magnitude4 > v6 + 2 then os.clock() + 0.5 else n12 else n12
			local n17 = (os.clock() < n12 and math.max(v2.MIN_SPEED, n14 * 0.45) or n14) * n13

			if arg5 then
				if flag2 then
				else
					if magnitude2 <= tbl5.EarlyCarryDistance then
						task.spawn(arg5)
						flag2 = true
					end
				end
			end

			local vector3 = Vector3.new(arg.CFrame.LookVector.X, 0, arg.CFrame.LookVector.Z)
			local unit = vector2.Magnitude > 0.001 and vector2.Unit or (vector3.Magnitude > 0.001 and vector3.Unit or Vector3.new(0, 0, -1))

			if (if n8 then str3 == "cruise" else not n8) and magnitude2 <= math.max(n17, 0.05) then
				now = if magnitude2 > 0.5 then nil else now
				fn6(n9.Position)
				arg.CFrame = CFrame.lookAt(n9.Position, n9.Position + unit)
				arg.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				arg.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				fn6(n9.Position)
				fn24(cameraSubject, arg, n14, (Vector3.new(0, 0, 0)))
				now = now or os.clock()

				if os.clock() - now >= n5 then
					v6 = magnitude4
					flag3 = true
					break
				end
			else
				now = nil

				if magnitude3 <= 0.001 then
					arg.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					arg.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					fn6(position)
					v6 = magnitude4
					continue
				end

				local n18 = math.min(n17, magnitude3)
				local n19 = position + n16.Unit * n18
				local n20 = (n19 - position) / n13
				fn6(n19)
				arg.CFrame = CFrame.lookAt(n19, n19 + unit)
				arg.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				fn6(n19)

				if not fn24(cameraSubject, arg, n14, n20) then
					fn23(cameraSubject, arg, n14)
					fn24(cameraSubject, arg, n14, n20)
				end
			end

			v6 = magnitude4
		else
			v6 = nil
			now = nil
			arg.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			arg.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			fn6(arg.Position)

			if fn21(state, cameraSubject, arg) then
				fn19(state, n14 * v2.HEADROOM, (Vector3.new(0, 0, 0)))
			else
				fn23(cameraSubject, arg, n14)
			end
		end
	end

	if cameraSubject.Parent and autoRotate ~= nil then
		cameraSubject.AutoRotate = autoRotate
	end

	arg.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	arg.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

	if flag3 then
		if arg4 then
			fn10(arg, n9)
		else
			fn8()
		end
	else
		fn8()
	end

	return flag3 and not tbl7.cancelled
end

do
	local function fn39(arg, cFrame)
		if not arg or typeof(cFrame) ~= "CFrame" then
			return false
		end

		if not pcall(function()
			arg.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			arg.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			arg.CFrame = cFrame
			arg.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			arg.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end) then
			return false
		end

		fn6(cFrame.Position)
		local parent = arg.Parent
		local humanoid = parent and parent:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local n8 = math.clamp(fn4(), v2.MIN_SPEED, genv.__SenaV4AdminBoost == true and 3000 or v2.MAX_SPEED)
			fn15(parent, n8 * v2.HEADROOM)

			if not fn24(humanoid, arg, n8, (Vector3.new(0, 0, 0))) then
				fn23(humanoid, arg, n8)
				fn24(humanoid, arg, n8, (Vector3.new(0, 0, 0)))
			end
		end

		return true
	end

	getgenv().SenaV4Config = senaV4Config

	local function fn40(arg)
		if arg and arg.Name == "PlayerTrap" then
			pcall(function()
				arg:Destroy()
			end)
		end
	end

	local function fn41()
		local function fn42(arg)
			if not arg then
				return
			end

			for i, child in ipairs(arg:GetChildren()) do
				fn40(child)
			end

			local function fn43(child)
				fn40(child)
			end

			arg.ChildAdded:Connect(fn43)
		end

		local transient = workspace:FindFirstChild("Transient")

		if transient then
			fn42(transient)
		end

		local debris = workspace:FindFirstChild("__DEBRIS")

		if debris then
			fn42(debris)
		end

		local v5 = workspace

		local function fn43(child)
			if child.Name == "Transient" then
				fn42(child)
			elseif child.Name == "__DEBRIS" then
				fn42(child)
			elseif child.Name == "PlayerTrap" then
				fn40(child)
			elseif child.Name:lower():find("trap") then
				fn40(child)
			end
		end

		v5.ChildAdded:Connect(fn43)

		task.spawn(function()
			while fn2() do
				for i, v6 in ipairs({workspace:FindFirstChild("Transient"), workspace:FindFirstChild("__DEBRIS")}) do
					if v6 then
						for i2, child in ipairs(v6:GetChildren()) do
							fn40(child)
						end
					end
				end

				task.wait(1.5)
			end
		end)
	end

	task.spawn(fn41)
	local v5
	local flag2 = false
	local tbl7 = {HoldSeconds = 0.3, ConfirmStableSeconds = 0.3, ConfirmTimeout = 2.5, PollSeconds = 0.05, ArrivalSettle = 0.5, DecoyName = "__SenaV4TweenTreadmillDecoy"}

	local function fn42()
		local ok, result = pcall(function()
			return require(game:GetService("ReplicatedStorage").Shared.Remotes).Treadmill.AskRenderSnapshot:InvokeServer()
		end)

		if ok then
			if type(result) ~= "table" then
				return nil
			end
		else
			return nil
		end

		return table.find(result, localPlayer.UserId) ~= nil
	end

	local function fn43()
		local ok, result, result2 = pcall(function()
			return require(game:GetService("ReplicatedStorage").Shared.Remotes).Treadmill.AskDoff:InvokeServer()
		end)

		if not ok then
			return false, tostring(result)
		end

		if result ~= true then
			return false, tostring(result2)
		end
		return true
	end

	local function fn44()
		local ok, result = pcall(function()
			local PlotState2 = require(ReplicatedStorage.Client.PlotState)
			local flag3 = type(PlotState2.ResolveLocalSlot) == "function" and PlotState2.ResolveLocalSlot() or PlotState2.GetMySlot()
			local flag4 = type(PlotState2.ResolveFolder) == "function" and PlotState2.ResolveFolder() or PlotState2.GetPlotsFolder()
			local v6 = flag4 and flag3 and flag4:FindFirstChild(tostring(flag3))
			local treadmillBottom = v6 and v6:FindFirstChild("TreadmillBottom")

			if treadmillBottom then
				if not treadmillBottom:IsA("BasePart") then
					return nil
				end
			else
				return nil
			end

			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoidRootPart then
				if not humanoid then
					return nil
				end
			else
				return nil
			end

			local n8 = humanoid.RigType == Enum.HumanoidRigType.R15 and humanoidRootPart.Size.Y * 0.5 + math.max(humanoid.HipHeight, 0.5) or humanoidRootPart.Size.Y * 0.5 + 2
			return treadmillBottom.CFrame * CFrame.new(0, treadmillBottom.Size.Y * 0.5 + n8 + 0.05, 0)
		end)

		return ok and result or nil
	end

	tbl7.destroyTrail = function(arg)
		if typeof(arg) == "Instance" and arg:IsA("Trail") then
			pcall(arg.Destroy, arg)
		end
	end

	tbl7.destroyStealPopup = function(arg)
		if senaV4TaskLadder.current() == "auto_steal" and typeof(arg) == "Instance" then
			if arg.Name == "SpeedGainPopup" then
				pcall(arg.Destroy, arg)
			elseif arg.Name == "PlusOne" then
				pcall(arg.Destroy, arg)
			end
		end
	end

	tbl7.purgeStealPopups = function()
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		if not playerGui then
			return
		end

		for i, descendant in ipairs(playerGui:GetDescendants()) do
			tbl7.destroyStealPopup(descendant)
		end
	end

	tbl7.guiConnection = localPlayer:WaitForChild("PlayerGui").DescendantAdded:Connect(function(descendant)
		tbl7.destroyStealPopup(descendant)
	end)

	tbl7.removeDecoy = function()
		if tbl7.cameraConnection then
			pcall(tbl7.cameraConnection.Disconnect, tbl7.cameraConnection)
			tbl7.cameraConnection = nil
		end

		if tbl7.characterConnection then
			pcall(tbl7.characterConnection.Disconnect, tbl7.characterConnection)
			tbl7.characterConnection = nil
		end

		for k, v6 in pairs(tbl7.transparency or {}) do
			if typeof(k) == "Instance" and k.Parent then
				pcall(function()
					k.LocalTransparencyModifier = v6
				end)
			end
		end

		tbl7.transparency = nil
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			pcall(function()
				currentCamera.CameraSubject = humanoid or tbl7.cameraSubject
			end)
		end

		tbl7.cameraSubject = nil

		if tbl7.decoy then
			pcall(tbl7.decoy.Destroy, tbl7.decoy)
		end

		tbl7.decoy = nil
	end

	tbl7.spawnDecoy = function(arg)
		tbl7.removeDecoy()
		local character = localPlayer.Character
		if not character then
			return false
		end
		local archivable = character.Archivable
		character.Archivable = true
		local ok, decoy = pcall(character.Clone, character)
		character.Archivable = archivable

		if ok then
			if not decoy then
				return false
			elseif typeof(decoy) ~= "Instance" then
				return false
			end
		else
			return false
		end

		decoy.Name = tbl7.DecoyName

		for i, descendant in ipairs(decoy:GetDescendants()) do
			if descendant:IsA("Script") then
				pcall(descendant.Destroy, descendant)
			elseif descendant:IsA("LocalScript") then
				pcall(descendant.Destroy, descendant)
			elseif descendant:IsA("BillboardGui") then
				pcall(descendant.Destroy, descendant)
			elseif descendant:IsA("Sound") then
				pcall(descendant.Destroy, descendant)
			elseif descendant:IsA("Trail") then
				pcall(descendant.Destroy, descendant)
			elseif descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = 0
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
			end
		end

		local humanoid = decoy:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			decoy:Destroy()
			return false
		end

		pcall(function()
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		end)

		decoy.Parent = workspace
		decoy:PivotTo(arg)
		tbl7.decoy = decoy
		local transparency = setmetatable({}, {__mode = "k"})

		fn45 = function(arg2)
			if arg2 then
				if arg2:IsA("BasePart") then
					if not arg2:IsDescendantOf(character) then
						return
					end
				else
					return
				end
			else
				return
			end

			if transparency[arg2] == nil then
				transparency[arg2] = arg2.LocalTransparencyModifier
			end

			arg2.LocalTransparencyModifier = 1
		end

		for i, descendant in ipairs(character:GetDescendants()) do
			fn45(descendant)
			tbl7.destroyTrail(descendant)
		end

		tbl7.transparency = transparency

		tbl7.characterConnection = character.DescendantAdded:Connect(function(descendant)
			if tbl7.decoy == decoy then
				pcall(fn45, descendant)
				tbl7.destroyTrail(descendant)
			end
		end)

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			tbl7.cameraSubject = currentCamera.CameraSubject
			currentCamera.CameraSubject = humanoid
		end

		tbl7.cameraConnection = RunService.RenderStepped:Connect(function()
			if tbl7.decoy ~= decoy then
				return
			elseif decoy.Parent then
				if not humanoid.Parent then
					return
				end
			else
				return
			end

			for k in pairs(transparency) do
				if k.Parent and k.LocalTransparencyModifier ~= 1 then
					k.LocalTransparencyModifier = 1
				end
			end

			local currentCamera2 = workspace.CurrentCamera

			if currentCamera2 and currentCamera2.CameraSubject ~= humanoid then
				currentCamera2.CameraSubject = humanoid
			end
		end)

		return true
	end

	tbl7.requestEquip = function()
		local ok, result, result2 = pcall(function()
			return require(ReplicatedStorage.Shared.Remotes).Treadmill.AskWearStill:InvokeServer()
		end)

		if if ok then result == false else not ok then
			return false, tostring(result2 or result)
		end
		return true
	end

	tbl7.prepare = function(arg, arg2)
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoidRootPart then
			if humanoid then
				if typeof(arg) ~= "CFrame" then
					return false
				end
			else
				return false
			end
		else
			return false
		end

		local function fn45()
			return arg2 ~= nil and arg2()
		end

		local function fn46()
			local character2 = localPlayer.Character
			local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 then
				fn39(humanoidRootPart2, arg)
				task.wait(0.1)
			end

			tbl7.removeDecoy()
		end

		flag2 = true
		tbl7.purgeStealPopups()
		fn9()
		fn8()
		if not tbl7.spawnDecoy(arg) then
			flag2 = false
			return false
		end
		local v6 = fn44()

		if (if v6 then fn45() else not v6) or not fn39(humanoidRootPart, v6) then
			fn43()
			fn46()
			flag2 = false
			return false
		end

		task.wait(tbl7.ArrivalSettle)

		if fn45() then
			fn43()
			fn46()
			flag2 = false
			return false
		end

		if not tbl7.requestEquip() then
			fn43()
			fn46()
			flag2 = false
			return false
		end

		character, humanoidRootPart = os.clock() + tbl7.ConfirmTimeout
		humanoid = false

		while true do
			local v7 = fn45()
			if not (if v7 then not v7 else os.clock() < character) then
				break
			end

			if fn42() == true then
				humanoidRootPart = humanoidRootPart or os.clock()
				if os.clock() - humanoidRootPart >= tbl7.ConfirmStableSeconds then
					humanoid = true
					break
				end
			else
				humanoidRootPart = nil
			end

			task.wait(tbl7.PollSeconds)
		end

		if if humanoid then fn45() else not humanoid then
			fn43()
			fn46()
			flag2 = false
			return false
		end

		character = os.clock() + tbl7.HoldSeconds

		while true do
			local v7 = fn45()
			if not (if v7 then not v7 else os.clock() < character) then
				break
			end
			task.wait(tbl7.PollSeconds)
		end

		local n8 = os.clock() + tbl7.ConfirmTimeout
		humanoidRootPart = false

		while true do
			local v7 = fn45()
			if not (if v7 then not v7 else os.clock() < n8) then
				break
			end
			fn43()
			task.wait(tbl7.PollSeconds)
			if fn42() == false then
				v5, humanoidRootPart = nil, true
				break
			end
		end

		fn46()
		flag2 = false
		return humanoidRootPart and not fn45()
	end

	tbl7.previousCleanup = genv.__SenaV4TweenRuntimeCleanup

	genv.__SenaV4TweenRuntimeCleanup = function()
		flag2 = false
		fn43()
		tbl7.removeDecoy()

		if tbl7.guiConnection then
			pcall(tbl7.guiConnection.Disconnect, tbl7.guiConnection)
			tbl7.guiConnection = nil
		end

		if type(tbl7.previousCleanup) == "function" then
			tbl7.previousCleanup()
		end
	end

	localPlayer.CharacterRemoving:Connect(function()
		flag2 = false
		tbl7.removeDecoy()
	end)
end

do
	if type(genv.__SenaV4CosmeticSuppressCleanup) == "function" then
		pcall(genv.__SenaV4CosmeticSuppressCleanup)
	end

	local tbl7 = {}

	local function fn39(child)
		if not child or child.Name ~= "DropHeldEgg" then
			return
		end

		if not child:IsA("ScreenGui") and not child:IsA("LayerCollector") then
			return
		end

		pcall(function()
			child.Enabled = false
		end)

		table.insert(tbl7, child:GetPropertyChangedSignal("Enabled"):Connect(function()
			if child.Enabled then
				pcall(function()
					child.Enabled = false
				end)
			end
		end))
	end

	local function fn40()
		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
		if not playerGui then
			return
		end

		for i, child in ipairs(playerGui:GetChildren()) do
			fn39(child)
		end

		table.insert(tbl7, playerGui.ChildAdded:Connect(fn39))
	end

	fn40()

	table.insert(tbl7, localPlayer.CharacterAdded:Connect(function()
		task.defer(fn40)
	end))

	pcall(function()
		local GuardPresentationComponent = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardPresentationComponent)

		if type(GuardPresentationComponent) == "table" then
			genv.__SenaV4GuardPresentOrig = genv.__SenaV4GuardPresentOrig or {PlayWake = GuardPresentationComponent.PlayWake, PlayHit = GuardPresentationComponent.PlayHit, PlayAfterWake = GuardPresentationComponent.PlayAfterWake, ScheduleAfterWake = GuardPresentationComponent.ScheduleAfterWake}

			local function playWake()
			end

			GuardPresentationComponent.PlayWake = playWake

			GuardPresentationComponent.PlayHit = function()
				return 0
			end

			GuardPresentationComponent.PlayAfterWake = playWake
			GuardPresentationComponent.ScheduleAfterWake = playWake
		end
	end)
end

print("[SenaV4 Hub] Full Script Successfully Loaded and Initialized!")
