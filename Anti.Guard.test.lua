-- OLIVER v3 | Anti Guard
-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ================= CONFIG =================
local LOGO_IMAGE = "rbxassetid://77896693340732" -- Logo OLIVER (ទុកទទេ = ប្រើអក្សរ "O")
local TWEEN_TIME = 0.04  -- ល្បឿនទៅ SafeZone (ស្ទើរដូច Teleport)
local STAY_TIME = 0.6    -- រយៈពេលនៅ SafeZone មុនត្រឡប់ (វិនាទី)
local RETURN_TIME = 0.05 -- ល្បឿនត្រឡប់ទៅកន្លែងដើម
local GLITCH = true      -- true = Glitch (ញ័រលឿន) ពេលនៅ SafeZone ដើម្បីកុំឱ្យ Guard ដេញ
local RETURN_BACK = true -- true = ត្រឡប់ទៅកន្លែងដើមវិញ
local SHOW_LOADING = true -- true = បង្ហាញ Loading ពេញអេក្រង់ ពេលកំពុងទៅ SafeZone
local ACCENT_1 = Color3.fromRGB(140, 90, 255)
local ACCENT_2 = Color3.fromRGB(60, 160, 255)
local ON_COLOR = Color3.fromRGB(60, 220, 130)
local OFF_COLOR = Color3.fromRGB(235, 80, 90)
local WHITE = Color3.new(1, 1, 1)
-- ==========================================

-- លុប GUI ចាស់ចោលបើមាន
local guiParent = CoreGui
pcall(function()
    if gethui then guiParent = gethui() end
end)
for _, name in ipairs({"StealAnEggUltimateFix", "OliverV3", "OliverLoading"}) do
    local old = guiParent:FindFirstChild(name) or CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ============ Helpers (ខ្លី) ============
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function corner(parent, radius) return new("UICorner", {CornerRadius = radius}, parent) end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {Color = color, Thickness = thickness or 1, Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent)
end

local function gradient(parent, c1, c2, rotation)
    return new("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rotation or 45}, parent)
end

local function tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function text(parent, str, size, font, color, pos, sz)
    return new("TextLabel", {Size = sz, Position = pos, BackgroundTransparency = 1, Text = str, TextColor3 = color,
        Font = font, TextSize = size, TextXAlignment = Enum.TextXAlignment.Left}, parent)
end

-- ============ ឥទ្ធិពលចំណាំងផ្លាត (Shine / Gloss / Rim) ============
local shines, rims = {}, {}
local NSK, CSK = NumberSequenceKeypoint.new, ColorSequenceKeypoint.new

-- ស៊ុមចំណាំងផ្លាត: ពណ៌ភ្លឺវិលជុំវិញ
local function rim(parent, thickness, transparency)
    local s = stroke(parent, WHITE, thickness, transparency)
    table.insert(rims, new("UIGradient", {Color = ColorSequence.new({
        CSK(0, ACCENT_1), CSK(0.3, ACCENT_2), CSK(0.5, WHITE), CSK(0.7, ACCENT_2), CSK(1, ACCENT_1),
    })}, s))
    return s
end

-- ពន្លឺកញ្ចក់ពាក់កណ្ដាលខាងលើ (ថេរ)
local function addGloss(parent, radius)
    local f = new("Frame", {Size = UDim2.fromScale(1, 0.5), BackgroundColor3 = WHITE, BorderSizePixel = 0,
        ZIndex = 49, Active = false}, parent)
    corner(f, radius)
    new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new(0.86, 1)}, f)
end

-- ជួរពន្លឺរំកិលកាត់ (ដូចចំណាំងផ្លាត)
local function addShine(parent, radius)
    local f = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0,
        ZIndex = 50, Active = false}, parent)
    corner(f, radius)
    table.insert(shines, new("UIGradient", {Rotation = 25, Transparency = NumberSequence.new({
        NSK(0, 1), NSK(0.4, 1), NSK(0.5, 0.6), NSK(0.6, 1), NSK(1, 1),
    })}, f))
end

RunService.RenderStepped:Connect(function(dt)
    local p = (os.clock() % 3.4) / 3.4
    local x = p < 0.45 and (-1 + p / 0.45 * 2) or 1
    for _, g in ipairs(shines) do g.Offset = Vector2.new(x, 0) end
    for _, g in ipairs(rims) do g.Rotation = (g.Rotation + dt * 70) % 360 end
end)

-- Logo ពេញ 100% (កាត់មូល + ស៊ុម + ចំណាំងផ្លាត)
local function makeLogo(parent, size, position)
    local holder = new("Frame", {Size = size, Position = position or UDim2.new(), BackgroundColor3 = WHITE,
        BorderSizePixel = 0, Active = false, BackgroundTransparency = LOGO_IMAGE ~= "" and 1 or 0}, parent)
    corner(holder, UDim.new(1, 0))
    if LOGO_IMAGE ~= "" then
        corner(new("ImageLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = LOGO_IMAGE,
            ScaleType = Enum.ScaleType.Crop}, holder), UDim.new(1, 0))
    else
        gradient(holder, ACCENT_1, ACCENT_2, 45)
        local t = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "O",
            TextColor3 = WHITE, Font = Enum.Font.GothamBlack, TextScaled = true}, holder)
        new("UIPadding", {PaddingTop = UDim.new(0.18, 0), PaddingBottom = UDim.new(0.18, 0)}, t)
    end
    rim(holder, 1.5, 0.1)
    addGloss(holder, UDim.new(1, 0))
    addShine(holder, UDim.new(1, 0))
    return holder
end

local ScreenGui = new("ScreenGui", {Name = "OliverV3", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, guiParent)

-- ============ Floating Button ============
local FloatButton = new("ImageButton", {Name = "FloatButton", Size = UDim2.new(0, 56, 0, 56),
    Position = UDim2.new(0.1, 0, 0.1, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 25), BorderSizePixel = 0,
    AutoButtonColor = false, ScaleType = Enum.ScaleType.Crop, Image = LOGO_IMAGE,
    BackgroundTransparency = LOGO_IMAGE ~= "" and 1 or 0.2}, ScreenGui)
corner(FloatButton, UDim.new(1, 0))
rim(FloatButton, 2, 0.05)
if LOGO_IMAGE == "" then
    makeLogo(FloatButton, UDim2.new(1, 0, 1, 0))
else
    addGloss(FloatButton, UDim.new(1, 0))
    addShine(FloatButton, UDim.new(1, 0))
end

-- ============ Main UI (ស៊ុមកាត់តាមខ្លឹមសារ មិនវែងជាង Function) ============
local MainFrame = new("CanvasGroup", {Name = "MainFrame", Size = UDim2.new(0, 270, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y, AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.3, 135, 0.3, 120), GroupTransparency = 1, BackgroundTransparency = 1,
    BorderSizePixel = 0, Visible = false}, ScreenGui)
local menuScale = new("UIScale", {Scale = 0.8}, MainFrame)
local openMenu, closeMenu, toggleMenu
corner(MainFrame, UDim.new(0, 16))
rim(MainFrame, 1.8, 0.2)

-- Background ដាច់ដោយឡែក
local Bg = new("Frame", {Name = "Bg", Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE,
    BackgroundTransparency = 0.12, BorderSizePixel = 0, Active = false, ZIndex = 0}, MainFrame)
corner(Bg, UDim.new(0, 16))
gradient(Bg, Color3.fromRGB(52, 38, 92), Color3.fromRGB(18, 24, 48), 120)

-- Body: រៀបជាជួរ (Header → Divider → Cards → Status) ហើយទំហំតាមខ្លឹមសារ
local Body = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1}, MainFrame)
new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center}, Body)

-- Header
local Header = new("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, LayoutOrder = 1}, Body)
makeLogo(Header, UDim2.new(0, 34, 0, 34), UDim2.new(0, 14, 0, 9))
text(Header, "OLIVER", 20, Enum.Font.GothamBlack, WHITE, UDim2.new(0, 58, 0, 9), UDim2.new(0, 90, 0, 34))
local Version = text(Header, "v3", 12, Enum.Font.GothamBold, WHITE, UDim2.new(0, 142, 0, 17), UDim2.new(0, 30, 0, 18))
Version.BackgroundTransparency = 0.35
Version.BackgroundColor3 = ACCENT_1
Version.TextXAlignment = Enum.TextXAlignment.Center
corner(Version, UDim.new(1, 0))

local CloseBtn = new("TextButton", {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -40, 0, 12),
    BackgroundColor3 = WHITE, BackgroundTransparency = 0.88, Text = "×", TextColor3 = WHITE,
    Font = Enum.Font.GothamBold, TextSize = 20, AutoButtonColor = false}, Header)
corner(CloseBtn, UDim.new(1, 0))
CloseBtn.MouseButton1Click:Connect(function() closeMenu() end)

new("Frame", {Size = UDim2.new(1, -28, 0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.85,
    BorderSizePixel = 0, LayoutOrder = 2}, Body)

-- Cards (ជួរ Function)
local Cards = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1, LayoutOrder = 3}, Body)
new("UIPadding", {PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 4),
    PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)}, Cards)
new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}, Cards)

-- Card Switch (ប្រើម្តងទៀតសម្រាប់ Function ទាំងអស់)
local function makeCard(titleText, subText, order)
    local btn = new("TextButton", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = WHITE,
        BackgroundTransparency = 0.92, Text = "", AutoButtonColor = false, LayoutOrder = order}, Cards)
    corner(btn, UDim.new(0, 12))
    local st = stroke(btn, OFF_COLOR, 1.5, 0.4)
    text(btn, titleText, 16, Enum.Font.GothamBold, WHITE, UDim2.new(0, 14, 0, 9), UDim2.new(1, -90, 0, 24))
    text(btn, subText, 11, Enum.Font.Gotham, Color3.fromRGB(200, 200, 220), UDim2.new(0, 14, 0, 33), UDim2.new(1, -90, 0, 18))
    local sw = new("Frame", {Size = UDim2.new(0, 48, 0, 26), Position = UDim2.new(1, -62, 0.5, -13),
        BackgroundColor3 = OFF_COLOR, BorderSizePixel = 0}, btn)
    corner(sw, UDim.new(1, 0))
    local kn = new("Frame", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 3, 0.5, -10),
        BackgroundColor3 = WHITE, BorderSizePixel = 0}, sw)
    corner(kn, UDim.new(1, 0))
    btn.MouseEnter:Connect(function() tween(btn, 0.15, {BackgroundTransparency = 0.84}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.15, {BackgroundTransparency = 0.92}) end)
    return btn, sw, kn, st
end

local AntiGuardBtn, Switch, Knob, btnStroke = makeCard("Anti Guard", "Anti Hit", 1)
local InstantBtn, InstantSwitch, InstantKnob, instantStroke = makeCard("Instant Prompt", "Hold time = 0 (no waiting)", 2)

local Status = text(Body, "Status: OFF", 11, Enum.Font.Gotham, Color3.fromRGB(170, 170, 195),
    UDim2.new(), UDim2.new(1, -28, 0, 30))
Status.LayoutOrder = 4

-- ចំណាំងផ្លាតលើស៊ុមធំ (ដាក់ក្រោយគេ ដើម្បីនៅលើគេ)
addGloss(MainFrame, UDim.new(0, 16))
addShine(MainFrame, UDim.new(0, 16))

-- ===== Smooth Drag (អូសរលូន) =====
local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local targetPos = guiObject.Position
    local state = {moved = false}

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            state.moved = false
            dragInput = input
            dragStart = input.Position
            startPos = guiObject.Position
            targetPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                end
            end)
        end
    end)

    -- ប្រើ UserInputService (មិនឈប់ពេលម្រាមដៃរំកិលលឿនហួសប៊ូតុង)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            if not state.moved and delta.Magnitude > 6 then
                state.moved = true
                -- ចាប់ផ្តើមអូសពីចំណុចនេះ (កុំឱ្យលោតពេលចាប់ផ្តើម)
                dragStart = dragInput.Position
                startPos = guiObject.Position
                delta = Vector3.new(0, 0, 0)
            end
            if state.moved then
                targetPos = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
        -- Smoothing ស្មើរៀងរាល់ FPS (គ្មានកន្ត្រាក់)
        local alpha = 1 - math.exp(-dt * 30)
        guiObject.Position = guiObject.Position:Lerp(targetPos, alpha)
    end)

    return state
end

local floatDrag = makeDraggable(FloatButton)
makeDraggable(MainFrame)

-- ===== Animation បើក/បិទម៉ឺនុយ =====
local menuOpen = false
local menuToken = 0
local openInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local closeInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

openMenu = function()
    menuOpen = true
    menuToken += 1
    MainFrame.Visible = true
    TweenService:Create(menuScale, openInfo, {Scale = 1}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
end

closeMenu = function()
    menuOpen = false
    menuToken += 1
    local token = menuToken
    local t = TweenService:Create(menuScale, closeInfo, {Scale = 0.8})
    TweenService:Create(MainFrame, closeInfo, {GroupTransparency = 1}):Play()
    t:Play()
    t.Completed:Connect(function()
        if token == menuToken then MainFrame.Visible = false end
    end)
end

toggleMenu = function()
    if menuOpen then closeMenu() else openMenu() end
end

-- ===== Animation ប៊ូតុងអណ្ដែត =====
local floatScale = new("UIScale", {Scale = 0}, FloatButton)
TweenService:Create(floatScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

FloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(floatScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.88}):Play()
    end
end)
FloatButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(floatScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
end)

-- ចុចប៊ូតុង → បើក/បិទ UI (មិនបើកពេលអូស)
FloatButton.MouseButton1Click:Connect(function()
    if not floatDrag.moved then
        toggleMenu()
    end
end)

-- ===== (ពីកូដដើម) ប្រព័ន្ធ Anti Guard & Prompt Scanning =====
-- ===== Loading UI ពេញអេក្រង់ =====
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "OliverLoading"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.DisplayOrder = 999
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingGui.Parent = guiParent

local Loading = Instance.new("Frame")
Loading.Name = "Loading"
Loading.Size = UDim2.new(1, 0, 1, 0)
Loading.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
Loading.BackgroundTransparency = 0 -- មិនថ្លា (ងងឹតពេញ)
Loading.BorderSizePixel = 0
Loading.Visible = false
Loading.Parent = LoadingGui

-- Logo ចំកណ្ដាល
makeLogo(Loading, UDim2.new(0, 84, 0, 84), UDim2.new(0.5, -42, 0.5, -70))

-- Ring វិល
local Ring = Instance.new("Frame")
Ring.Size = UDim2.new(0, 108, 0, 108)
Ring.Position = UDim2.new(0.5, -54, 0.5, -82)
Ring.BackgroundTransparency = 1
Ring.Parent = Loading
corner(Ring, UDim.new(1, 0))
local ringStroke = stroke(Ring, ACCENT_2, 3, 0)
local ringGrad = gradient(ringStroke, ACCENT_1, ACCENT_2, 0)
ringGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(0.55, 0.85),
    NumberSequenceKeypoint.new(1, 1),
})

local LoadLabel = Instance.new("TextLabel")
LoadLabel.Size = UDim2.new(0, 220, 0, 28)
LoadLabel.Position = UDim2.new(0.5, -110, 0.5, 38)
LoadLabel.BackgroundTransparency = 1
LoadLabel.Text = "Loading"
LoadLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadLabel.Font = Enum.Font.GothamBold
LoadLabel.TextSize = 20
LoadLabel.Parent = Loading

local LoadSub = Instance.new("TextLabel")
LoadSub.Size = UDim2.new(0, 260, 0, 20)
LoadSub.Position = UDim2.new(0.5, -130, 0.5, 66)
LoadSub.BackgroundTransparency = 1
LoadSub.Text = "OLIVER v3 • Steal Egg"
LoadSub.TextColor3 = Color3.fromRGB(180, 180, 205)
LoadSub.Font = Enum.Font.Gotham
LoadSub.TextSize = 13
LoadSub.Parent = Loading

local BarTrack = Instance.new("Frame")
BarTrack.Size = UDim2.new(0, 220, 0, 6)
BarTrack.Position = UDim2.new(0.5, -110, 0.5, 100)
BarTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarTrack.BackgroundTransparency = 0.85
BarTrack.BorderSizePixel = 0
BarTrack.Parent = Loading
corner(BarTrack, UDim.new(1, 0))

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarTrack
corner(BarFill, UDim.new(1, 0))
gradient(BarFill, ACCENT_1, ACCENT_2, 0)

local loadingToken = 0
local loadingConn = nil

local function showLoading(duration)
    if not SHOW_LOADING then return end
    loadingToken += 1
    Loading.Visible = true

    BarFill.Size = UDim2.new(0, 0, 1, 0)
    TweenService:Create(BarFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)}):Play()

    if loadingConn then loadingConn:Disconnect() end
    loadingConn = RunService.RenderStepped:Connect(function(dt)
        ringGrad.Rotation = (ringGrad.Rotation + dt * 400) % 360
        LoadLabel.Text = "Loading" .. string.rep(".", math.floor(os.clock() * 3) % 4)
    end)
end

local function hideLoading()
    if not SHOW_LOADING then return end
    loadingToken += 1
    Loading.Visible = false
    if loadingConn then
        loadingConn:Disconnect()
        loadingConn = nil
    end
end

local antiGuardActive = false
local currentTween = nil
local busy = false

local function resetCamera()
    local cam = Workspace.CurrentCamera
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if cam and hum then
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = hum
    end
end

-- ===== Camera Follow (ឱ្យ Camera តាមតួអង្គជានិច្ច ពេលយក Egg) =====
local camFollowUntil = 0
local camHoldCF = nil -- បើមានតម្លៃ = Camera ជាប់នៅកន្លែងនោះ (មិនតាមតួអង្គ)
local camOffset = Vector3.new(0, 8, 14)

pcall(function() RunService:UnbindFromRenderStep("OliverCamFollow") end)
RunService:BindToRenderStep("OliverCamFollow", Enum.RenderPriority.Camera.Value + 1, function()
    -- ពេលទៅ SafeZone: ទុក Camera នៅកន្លែងដដែល មិនតាមតួអង្គ
    if camHoldCF then
        local cam = Workspace.CurrentCamera
        if cam then
            if cam.CameraType ~= Enum.CameraType.Scriptable then
                cam.CameraType = Enum.CameraType.Scriptable
            end
            cam.CFrame = camHoldCF
        end
        return
    end

    if os.clock() > camFollowUntil then return end

    local cam = Workspace.CurrentCamera
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (cam and root and hum) then return end

    -- បង្ខំឱ្យ Camera ជាប្រភេទតាមតួអង្គ
    if cam.CameraType ~= Enum.CameraType.Custom then
        cam.CameraType = Enum.CameraType.Custom
    end
    if cam.CameraSubject ~= hum then
        cam.CameraSubject = hum
    end

    -- បើ Camera នៅឆ្ងាយពីតួអង្គ (នៅកន្លែងដដែល) → ទាញមកតាមតួអង្គភ្លាម
    if (cam.CFrame.Position - root.Position).Magnitude > 45 then
        local rot = cam.CFrame - cam.CFrame.Position
        cam.CFrame = CFrame.new(root.Position + camOffset) * rot
    end
end)

local function goTo(rootPart, cf, t)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(rootPart, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    currentTween:Play()
    currentTween.Completed:Wait()
    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

local function runAntiGuard(rootPart, safeZone)
    busy = true
    showLoading(TWEEN_TIME + STAY_TIME + RETURN_TIME)

    -- ចងចាំចម្ងាយ Camera ពីតួអង្គ
    local cam = Workspace.CurrentCamera
    if cam then
        local off = cam.CFrame.Position - rootPart.Position
        if off.Magnitude > 3 and off.Magnitude < 45 then
            camOffset = off
        else
            camOffset = Vector3.new(0, 8, 14)
        end
    end
    camFollowUntil = 0
    if cam then camHoldCF = cam.CFrame end -- ចាក់សោ Camera ពេលទៅ SafeZone

    local origin = rootPart.CFrame
    local target = safeZone.CFrame + Vector3.new(0, 3, 0)

    -- ១. ទៅ SafeZone លឿន (ដូច Teleport)
    goTo(rootPart, target, TWEEN_TIME)

    -- ២. នៅ SafeZone + Glitch (ញ័រលឿន)
    local t0 = os.clock()
    while os.clock() - t0 < STAY_TIME do
        if not rootPart.Parent then break end
        if GLITCH then
            rootPart.CFrame = target * CFrame.new(math.random(-20, 20) / 10, 0, math.random(-20, 20) / 10)
        else
            rootPart.CFrame = target
        end
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        task.wait()
    end

    -- ៣. ត្រឡប់ទៅកន្លែងដើម
    if rootPart.Parent then
        rootPart.CFrame = target
        if RETURN_BACK then
            goTo(rootPart, origin, RETURN_TIME)
        end
    end
    -- ដោះសោ Camera ឱ្យតាមតួអង្គវិញ
    camHoldCF = nil
    camFollowUntil = os.clock() + 1.5
    resetCamera()
    task.delay(0.15, resetCamera)
    task.delay(0.6, resetCamera)
    hideLoading()
    busy = false
end

-- ===== Instant Prompt =====
-- ធ្វើឱ្យ ProximityPrompt ទាំងអស់ចុចភ្លាម (HoldDuration = 0) ហើយស្តារតម្លៃដើមពេលបិទ
local instantPromptActive = false
local instantPromptConn = nil

local function applyInstantPrompt(inst)
    if inst:IsA("ProximityPrompt") then
        if inst:GetAttribute("OliverOrigHold") == nil then
            inst:SetAttribute("OliverOrigHold", inst.HoldDuration)
        end
        inst.HoldDuration = 0
    end
end

local function restoreInstantPrompt(inst)
    if inst:IsA("ProximityPrompt") then
        local orig = inst:GetAttribute("OliverOrigHold")
        if orig ~= nil then
            inst.HoldDuration = orig
            inst:SetAttribute("OliverOrigHold", nil)
        end
    end
end

local function setInstantPrompt(on)
    instantPromptActive = on
    if instantPromptConn then
        instantPromptConn:Disconnect()
        instantPromptConn = nil
    end
    if on then
        for _, inst in ipairs(Workspace:GetDescendants()) do
            applyInstantPrompt(inst)
        end
        -- Prompt ថ្មីៗដែលលេចឡើងក្រោយ
        instantPromptConn = Workspace.DescendantAdded:Connect(function(inst)
            task.defer(applyInstantPrompt, inst)
        end)
    else
        for _, inst in ipairs(Workspace:GetDescendants()) do
            restoreInstantPrompt(inst)
        end
    end
end

-- ===== Switch + Status =====
local function setCard(sw, knob, st, on)
    if on then
        tween(sw, 0.2, {BackgroundColor3 = ON_COLOR})
        tween(knob, 0.2, {Position = UDim2.new(1, -23, 0.5, -10)})
        tween(st, 0.2, {Color = ON_COLOR})
    else
        tween(sw, 0.2, {BackgroundColor3 = OFF_COLOR})
        tween(knob, 0.2, {Position = UDim2.new(0, 3, 0.5, -10)})
        tween(st, 0.2, {Color = OFF_COLOR})
    end
end

local function refreshStatus()
    local parts = {}
    if antiGuardActive then table.insert(parts, "Anti Guard") end
    if instantPromptActive then table.insert(parts, "Instant Prompt") end
    if #parts > 0 then
        Status.Text = "Status: " .. table.concat(parts, " + ") .. " ON"
        Status.TextColor3 = ON_COLOR
    else
        Status.Text = "Status: OFF"
        Status.TextColor3 = Color3.fromRGB(170, 170, 195)
    end
end

AntiGuardBtn.MouseButton1Click:Connect(function()
    antiGuardActive = not antiGuardActive
    setCard(Switch, Knob, btnStroke, antiGuardActive)
    refreshStatus()
    print(antiGuardActive and "[Anti Guard] Activated!" or "[Anti Guard] Deactivated!")
end)

InstantBtn.MouseButton1Click:Connect(function()
    setInstantPrompt(not instantPromptActive)
    setCard(InstantSwitch, InstantKnob, instantStroke, instantPromptActive)
    refreshStatus()
    print(instantPromptActive and "[Instant Prompt] ON" or "[Instant Prompt] OFF")
end)

-- មុខងារភ្ជាប់ Event ជាមួយ ProximityPrompt
local function setupPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        if not prompt:GetAttribute("UltimateHooked") then
            prompt:SetAttribute("UltimateHooked", true)

            prompt.Triggered:Connect(function(plr)
                if plr == player and antiGuardActive then
                    print("[Anti Guard] Prompt Triggered! Teleporting to SafeZone...")

                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local rootPart = character.HumanoidRootPart

                        -- យកទីតាំង SafeZone តាម Path ពិតប្រាកដ
                        local safeZone = Workspace:FindFirstChild("World")
                            and Workspace.World:FindFirstChild("Areas")
                            and Workspace.World.Areas:FindFirstChild("EggCarryBounds")
                            and Workspace.World.Areas.EggCarryBounds:FindFirstChild("SafeZone")

                        if safeZone then
                            if not busy then
                                task.spawn(function()
                                    local ok, err = pcall(runAntiGuard, rootPart, safeZone)
                                    if not ok then
                                        warn("[Anti Guard] Error: " .. tostring(err))
                                        camHoldCF = nil
                                        hideLoading()
                                        busy = false
                                    end
                                end)
                            end
                        else
                            warn("[Anti Guard] SafeZone not found!")
                        end
                    end
                end
            end)
        end
    end
end

task.spawn(function()
    print("[Anti Guard] Waiting for AreaEggSlotsClient...")

    local areaSlots = Workspace:WaitForChild("AreaEggSlotsClient", 60)

    if areaSlots then
        print("[Anti Guard] AreaEggSlotsClient detected!")

        for _, obj in pairs(areaSlots:GetDescendants()) do
            setupPrompt(obj)
        end

        areaSlots.DescendantAdded:Connect(function(obj)
            task.wait(0.1)
            setupPrompt(obj)
        end)
    end
end)

-- Backup: ស្កេនទូទាំង Workspace
task.spawn(function()
    for _, obj in pairs(Workspace:GetDescendants()) do
        setupPrompt(obj)
    end

    Workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        setupPrompt(obj)
    end)
end)
