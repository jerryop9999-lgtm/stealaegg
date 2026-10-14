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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OliverV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

-- ============ Helpers ============
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function gradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rotation or 45
    g.Parent = parent
    return g
end

local function tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Logo ពេញប៊ូតុង (Image ពេញ 100% + កាត់មូល)
local function makeLogo(parent, size, position)
    local holder = Instance.new("Frame")
    holder.Size = size
    holder.Position = position or UDim2.new(0, 0, 0, 0)
    holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    holder.BorderSizePixel = 0
    holder.Active = false
    holder.Parent = parent
    corner(holder, UDim.new(1, 0))

    if LOGO_IMAGE ~= "" then
        holder.BackgroundTransparency = 1
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, 0, 1, 0)
        img.Position = UDim2.new(0, 0, 0, 0)
        img.BackgroundTransparency = 1
        img.Image = LOGO_IMAGE
        img.ScaleType = Enum.ScaleType.Crop
        img.Parent = holder
        corner(img, UDim.new(1, 0))
    else
        gradient(holder, ACCENT_1, ACCENT_2, 45)
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 1, 0)
        t.BackgroundTransparency = 1
        t.Text = "O"
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.Font = Enum.Font.GothamBlack
        t.TextScaled = true
        t.Parent = holder
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0.18, 0)
        pad.PaddingBottom = UDim.new(0.18, 0)
        pad.Parent = t
    end
    return holder
end

-- ============ Floating Button (Logo ពេញប៊ូតុង) ============
-- ប៊ូតុងខ្លួនឯងជា ImageButton → Logo ត្រូវកាត់មូលពេញ 100% តាមប៊ូតុង គ្មានជ្រុង
local FloatButton = Instance.new("ImageButton")
FloatButton.Name = "FloatButton"
FloatButton.Size = UDim2.new(0, 56, 0, 56)
FloatButton.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatButton.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
FloatButton.BorderSizePixel = 0
FloatButton.AutoButtonColor = false
FloatButton.ScaleType = Enum.ScaleType.Crop
if LOGO_IMAGE ~= "" then
    FloatButton.Image = LOGO_IMAGE
    FloatButton.BackgroundTransparency = 1
else
    FloatButton.BackgroundTransparency = 0.2
end
FloatButton.Parent = ScreenGui
corner(FloatButton, UDim.new(1, 0))
local floatStroke = stroke(FloatButton, ACCENT_1, 2, 0.1)
gradient(floatStroke, ACCENT_1, ACCENT_2, 90)

if LOGO_IMAGE == "" then
    makeLogo(FloatButton, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
end

-- ============ Main UI (ថ្លាៗ) ============
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 270, 0, 354)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.3, 135, 0.3, 177)
MainFrame.GroupTransparency = 1
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
local menuScale = Instance.new("UIScale")
menuScale.Scale = 0.8
menuScale.Parent = MainFrame
local openMenu, closeMenu, toggleMenu
corner(MainFrame, UDim.new(0, 16))
local frameStroke = stroke(MainFrame, ACCENT_1, 1.5, 0.35)
gradient(frameStroke, ACCENT_1, ACCENT_2, 90)

MainFrame.BackgroundTransparency = 1

-- Background ដាច់ដោយឡែក (Gradient នៅទីនេះ មិនប៉ះពាល់អក្សរ/Logo)
local Bg = Instance.new("Frame")
Bg.Name = "Bg"
Bg.Size = UDim2.new(1, 0, 1, 0)
Bg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Bg.BackgroundTransparency = 0.22
Bg.BorderSizePixel = 0
Bg.Active = false
Bg.Parent = MainFrame
corner(Bg, UDim.new(0, 16))
gradient(Bg, Color3.fromRGB(52, 38, 92), Color3.fromRGB(18, 24, 48), 120)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

makeLogo(Header, UDim2.new(0, 34, 0, 34), UDim2.new(0, 14, 0, 9))

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 90, 0, 34)
Title.Position = UDim2.new(0, 58, 0, 9)
Title.BackgroundTransparency = 1
Title.Text = "OLIVER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(0, 30, 0, 18)
Version.Position = UDim2.new(0, 142, 0, 17)
Version.BackgroundColor3 = ACCENT_1
Version.BackgroundTransparency = 0.35
Version.Text = "v3"
Version.TextColor3 = Color3.fromRGB(255, 255, 255)
Version.Font = Enum.Font.GothamBold
Version.TextSize = 12
Version.Parent = Header
corner(Version, UDim.new(1, 0))

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0, 12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundTransparency = 0.88
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
corner(CloseBtn, UDim.new(1, 0))
CloseBtn.MouseButton1Click:Connect(function() closeMenu() end)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -28, 0, 1)
Divider.Position = UDim2.new(0, 14, 0, 52)
Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Divider.BackgroundTransparency = 0.85
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Anti Guard Button
local AntiGuardBtn = Instance.new("TextButton")
AntiGuardBtn.Name = "AntiGuardBtn"
AntiGuardBtn.Size = UDim2.new(1, -28, 0, 62)
AntiGuardBtn.Position = UDim2.new(0, 14, 0, 68)
AntiGuardBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AntiGuardBtn.BackgroundTransparency = 0.9
AntiGuardBtn.Text = ""
AntiGuardBtn.AutoButtonColor = false
AntiGuardBtn.Parent = MainFrame
corner(AntiGuardBtn, UDim.new(0, 12))
local btnStroke = stroke(AntiGuardBtn, OFF_COLOR, 1.5, 0.4)

local BtnTitle = Instance.new("TextLabel")
BtnTitle.Size = UDim2.new(1, -90, 0, 24)
BtnTitle.Position = UDim2.new(0, 14, 0, 10)
BtnTitle.BackgroundTransparency = 1
BtnTitle.Text = "Anti Guard"
BtnTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnTitle.Font = Enum.Font.GothamBold
BtnTitle.TextSize = 16
BtnTitle.TextXAlignment = Enum.TextXAlignment.Left
BtnTitle.Parent = AntiGuardBtn

local BtnSub = Instance.new("TextLabel")
BtnSub.Size = UDim2.new(1, -90, 0, 18)
BtnSub.Position = UDim2.new(0, 14, 0, 34)
BtnSub.BackgroundTransparency = 1
BtnSub.Text = "Anti Hit"
BtnSub.TextColor3 = Color3.fromRGB(200, 200, 220)
BtnSub.Font = Enum.Font.Gotham
BtnSub.TextSize = 11
BtnSub.TextXAlignment = Enum.TextXAlignment.Left
BtnSub.Parent = AntiGuardBtn

local Switch = Instance.new("Frame")
Switch.Size = UDim2.new(0, 48, 0, 26)
Switch.Position = UDim2.new(1, -62, 0.5, -13)
Switch.BackgroundColor3 = OFF_COLOR
Switch.BorderSizePixel = 0
Switch.Parent = AntiGuardBtn
corner(Switch, UDim.new(1, 0))

local Knob = Instance.new("Frame")
Knob.Size = UDim2.new(0, 20, 0, 20)
Knob.Position = UDim2.new(0, 3, 0.5, -10)
Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Knob.BorderSizePixel = 0
Knob.Parent = Switch
corner(Knob, UDim.new(1, 0))

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -28, 0, 20)
Status.Position = UDim2.new(0, 14, 1, -28)
Status.BackgroundTransparency = 1
Status.Text = "Status: OFF"
Status.TextColor3 = Color3.fromRGB(170, 170, 195)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = MainFrame

-- Card Switch (ប្រើម្តងទៀតសម្រាប់ Mode ផ្សេង)
local function makeCard(titleText, subText, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -28, 0, 62)
    btn.Position = UDim2.new(0, 14, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.9
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = MainFrame
    corner(btn, UDim.new(0, 12))
    local st = stroke(btn, OFF_COLOR, 1.5, 0.4)

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1, -90, 0, 24)
    ttl.Position = UDim2.new(0, 14, 0, 10)
    ttl.BackgroundTransparency = 1
    ttl.Text = titleText
    ttl.TextColor3 = Color3.fromRGB(255, 255, 255)
    ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 16
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Parent = btn

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -90, 0, 18)
    sub.Position = UDim2.new(0, 14, 0, 34)
    sub.BackgroundTransparency = 1
    sub.Text = subText
    sub.TextColor3 = Color3.fromRGB(200, 200, 220)
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = btn

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 48, 0, 26)
    sw.Position = UDim2.new(1, -62, 0.5, -13)
    sw.BackgroundColor3 = OFF_COLOR
    sw.BorderSizePixel = 0
    sw.Parent = btn
    corner(sw, UDim.new(1, 0))

    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0, 20, 0, 20)
    kn.Position = UDim2.new(0, 3, 0.5, -10)
    kn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kn.BorderSizePixel = 0
    kn.Parent = sw
    corner(kn, UDim.new(1, 0))

    return btn, sw, kn, st
end

local InstantBtn, InstantSwitch, InstantKnob, instantStroke = makeCard("Instant Prompt", "Hold time = 0 (no waiting)", 138)

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
local floatScale = Instance.new("UIScale")
floatScale.Scale = 0
floatScale.Parent = FloatButton
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

-- ស៊ុមប៊ូតុងវិលរលូនជានិច្ច
local floatGradient = floatStroke:FindFirstChildOfClass("UIGradient")
RunService.RenderStepped:Connect(function(dt)
    if floatGradient then
        floatGradient.Rotation = (floatGradient.Rotation + dt * 90) % 360
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
