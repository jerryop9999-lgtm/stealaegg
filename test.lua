-- OLIVER v3 | Steal an Egg - Anti Guard (UI Update)
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
local TWEEN_TIME = 0.04   -- ល្បឿនទៅ SafeZone
local STAY_TIME = 0.6     -- រយៈពេលនៅ SafeZone មុនត្រឡប់ (វិនាទី)
local RETURN_TIME = 0.05  -- ល្បឿនត្រឡប់ទៅកន្លែងដើម
local GLITCH = true       -- ញ័រលឿនពេលនៅ SafeZone
local RETURN_BACK = true  -- ត្រឡប់ទៅកន្លែងដើមវិញ
local SHOW_LOADING = true -- បង្ហាញ Loading ពេញអេក្រង់ពេលទៅ SafeZone
-- រូបតំណាង Card (ដាក់ ID លេខ ឬ "rbxassetid://..." ; ទុកទទេ = ប្រើ Emoji)
local ICON_ANTIGUARD = "rbxassetid://74028582328837" -- ឧ. "rbxassetid://123456789" ឬ "123456789"
local ICON_INSTANT = "rbxassetid://127650947428392"
local ICON_ESP = "rbxassetid://115470460729074" -- រូបតំណាង ESP (ទុកទទេ = ប្រើ Emoji 👁)
local ACCENT_1 = Color3.fromRGB(255, 0, 20)
local ACCENT_2 = Color3.fromRGB(150, 0, 12)
local ON_COLOR = Color3.fromRGB(255, 0, 20)
local OFF_COLOR = Color3.fromRGB(105, 25, 30)
local WHITE = Color3.new(1, 1, 1)
local DARK = Color3.fromRGB(7, 7, 9)
local DIM = Color3.fromRGB(160, 170, 190)
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

-- ============ Helpers ============
local NSK, CSK = NumberSequenceKeypoint.new, ColorSequenceKeypoint.new

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function corner(parent, radius)
    return new("UICorner", {CornerRadius = radius}, parent)
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {Color = color, Thickness = thickness or 1, Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent)
end

local function gradient(parent, c1, c2, rotation)
    return new("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rotation or 45}, parent)
end

local function tween(obj, time, props, style, dir)
    TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

local function label(parent, str, size, font, color, pos, sz, align)
    return new("TextLabel", {Size = sz, Position = pos, BackgroundTransparency = 1, Text = str, TextColor3 = color,
        Font = font, TextSize = size, TextXAlignment = align or Enum.TextXAlignment.Left}, parent)
end

-- ============ Logo ស៊ុមចំណាំងផ្លាត (ស៊ុមតែលើ Logo ប៉ុណ្ណោះ មិនមែន UI) ============
local shines, rims = {}, {}

local function makeLogo(parent, size, position, thickness)
    thickness = thickness or 3

    -- ស៊ុមក្រៅ: ពណ៌ភ្លឺវិលជុំវិញ
    local ring = new("Frame", {Name = "LogoFrame", Size = size, Position = position or UDim2.new(),
        BackgroundColor3 = WHITE, BorderSizePixel = 0, Active = false}, parent)
    corner(ring, UDim.new(1, 0))
    table.insert(rims, new("UIGradient", {Color = ColorSequence.new({
        CSK(0, ACCENT_1), CSK(0.25, ACCENT_2), CSK(0.5, WHITE), CSK(0.75, ACCENT_2), CSK(1, ACCENT_1),
    })}, ring))

    -- គម្លាតងងឹតរវាងស៊ុម និង Logo
    local gap = new("Frame", {Size = UDim2.new(1, -thickness * 2, 1, -thickness * 2),
        Position = UDim2.fromOffset(thickness, thickness), BackgroundColor3 = DARK, BorderSizePixel = 0,
        Active = false}, ring)
    corner(gap, UDim.new(1, 0))

    -- Logo ខាងក្នុង
    local inset = thickness + 2
    local innerSize = UDim2.new(1, -inset * 2, 1, -inset * 2)
    local innerPos = UDim2.fromOffset(inset, inset)
    if LOGO_IMAGE ~= "" then
        local img = new("ImageLabel", {Size = innerSize, Position = innerPos, BackgroundTransparency = 1,
            Image = LOGO_IMAGE, ScaleType = Enum.ScaleType.Crop}, ring)
        corner(img, UDim.new(1, 0))
    else
        local fill = new("Frame", {Size = innerSize, Position = innerPos, BackgroundColor3 = WHITE,
            BorderSizePixel = 0}, ring)
        corner(fill, UDim.new(1, 0))
        gradient(fill, ACCENT_1, ACCENT_2, 45)
        new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "O",
            TextColor3 = WHITE, Font = Enum.Font.GothamBlack, TextScaled = true}, fill)
        new("UIPadding", {PaddingTop = UDim.new(0.2, 0), PaddingBottom = UDim.new(0.2, 0)}, fill)
    end

    -- ពន្លឺកញ្ចក់ពាក់កណ្ដាលខាងលើ
    local gloss = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0,
        ZIndex = 5, Active = false}, ring)
    corner(gloss, UDim.new(1, 0))
    new("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NSK(0, 0.78), NSK(0.5, 1), NSK(1, 1)})}, gloss)

    -- ជួរពន្លឺរំកិលកាត់
    local shine = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0,
        ZIndex = 6, Active = false}, ring)
    corner(shine, UDim.new(1, 0))
    table.insert(shines, new("UIGradient", {Rotation = 25, Transparency = NumberSequence.new({
        NSK(0, 1), NSK(0.4, 1), NSK(0.5, 0.45), NSK(0.6, 1), NSK(1, 1),
    })}, shine))

    return ring
end

RunService.RenderStepped:Connect(function(dt)
    local p = (os.clock() % 3.2) / 3.2
    local x = p < 0.45 and (-1 + p / 0.45 * 2) or 1
    for _, g in ipairs(shines) do g.Offset = Vector2.new(x, 0) end
    for _, g in ipairs(rims) do g.Rotation = (g.Rotation + dt * 80) % 360 end
end)

local ScreenGui = new("ScreenGui", {Name = "OliverV3", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, guiParent)

-- ============ Floating Button ============
local FloatButton = new("ImageButton", {Name = "FloatButton", Size = UDim2.fromOffset(60, 60),
    Position = UDim2.fromScale(0.1, 0.1), BackgroundTransparency = 1, AutoButtonColor = false, Image = ""}, ScreenGui)
makeLogo(FloatButton, UDim2.fromScale(1, 1), nil, 3)

-- ============ OLIVER RED / BLACK UI ============
local MainFrame = new("CanvasGroup", {
    Name = "MainFrame",
    Size = UDim2.fromOffset(620, 360),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    GroupTransparency = 1,
    BackgroundColor3 = Color3.fromRGB(5, 5, 7),
    BorderSizePixel = 0,
    Visible = false,
    Active = true,
}, ScreenGui)
local camera = Workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
local fitScale = math.min(1, viewport.X / 650, viewport.Y / 390)
local menuScale = new("UIScale", {Scale = fitScale * 0.8}, MainFrame)
local openMenu, closeMenu, toggleMenu
corner(MainFrame, UDim.new(0, 18))
stroke(MainFrame, Color3.fromRGB(255, 0, 20), 2, 0)

local Bg = new("Frame", {
    Name = "Bg", Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(5, 5, 7),
    BorderSizePixel = 0, Active = false, ZIndex = 0,
}, MainFrame)
corner(Bg, UDim.new(0, 18))
gradient(Bg, Color3.fromRGB(16, 4, 6), Color3.fromRGB(3, 3, 5), 35)

-- Header
local Header = new("Frame", {
    Name = "Header", Size = UDim2.new(1, 0, 0, 76),
    BackgroundColor3 = Color3.fromRGB(10, 5, 7),
    BackgroundTransparency = 0.05, BorderSizePixel = 0,
}, MainFrame)
corner(Header, UDim.new(0, 18))
makeLogo(Header, UDim2.fromOffset(54, 54), UDim2.fromOffset(18, 10), 3)

local Title = label(Header, "OLIVER", 26, Enum.Font.GothamBlack,
    Color3.fromRGB(255, 20, 30), UDim2.fromOffset(82, 13), UDim2.fromOffset(150, 28))
local SubTitle = label(Header, "DELTA EXECUTOR", 13, Enum.Font.GothamBold,
    WHITE, UDim2.fromOffset(245, 18), UDim2.fromOffset(180, 20))
label(Header, "SCRIPT HUB  •  PLAY DIFFERENT", 10, Enum.Font.Gotham,
    DIM, UDim2.fromOffset(246, 40), UDim2.fromOffset(210, 16))

local MinBtn = new("TextButton", {
    Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -78, 0, 22),
    BackgroundTransparency = 1, Text = "—", TextColor3 = Color3.fromRGB(255, 0, 20),
    Font = Enum.Font.GothamBold, TextSize = 24, AutoButtonColor = false,
}, Header)
local CloseBtn = new("TextButton", {
    Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -42, 0, 22),
    BackgroundTransparency = 1, Text = "×", TextColor3 = Color3.fromRGB(255, 0, 20),
    Font = Enum.Font.GothamBold, TextSize = 28, AutoButtonColor = false,
}, Header)
CloseBtn.MouseButton1Click:Connect(function() closeMenu() end)

local HeaderLine = new("Frame", {
    Size = UDim2.new(1, -2, 0, 2), Position = UDim2.new(0, 1, 0, 75),
    BackgroundColor3 = Color3.fromRGB(255, 0, 20), BorderSizePixel = 0,
}, MainFrame)

-- Sidebar: only one tab, Main
local Sidebar = new("Frame", {
    Name = "Sidebar", Size = UDim2.new(0, 150, 1, -78),
    Position = UDim2.fromOffset(0, 78),
    BackgroundColor3 = Color3.fromRGB(8, 5, 7), BorderSizePixel = 0,
}, MainFrame)
local MainTab = new("TextButton", {
    Name = "MainTab", Size = UDim2.new(1, -20, 0, 48),
    Position = UDim2.fromOffset(10, 20),
    BackgroundColor3 = Color3.fromRGB(75, 0, 10),
    Text = "⌂   Main", TextColor3 = WHITE,
    Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false,
}, Sidebar)
corner(MainTab, UDim.new(0, 10))
stroke(MainTab, Color3.fromRGB(255, 0, 20), 1.5, 0.1)
gradient(MainTab, Color3.fromRGB(100, 0, 12), Color3.fromRGB(35, 0, 5), 0)

local SideCaption = label(Sidebar, "OLIVER SCRIPT", 13, Enum.Font.GothamBold,
    Color3.fromRGB(255, 20, 30), UDim2.new(0, 15, 1, -48), UDim2.new(1, -25, 0, 20))
label(Sidebar, "PLAY DIFFERENT", 10, Enum.Font.Gotham,
    DIM, UDim2.new(0, 15, 1, -28), UDim2.new(1, -25, 0, 16))

local SideDivider = new("Frame", {
    Size = UDim2.new(0, 1, 1, -78), Position = UDim2.new(0, 150, 0, 78),
    BackgroundColor3 = Color3.fromRGB(80, 15, 20), BorderSizePixel = 0,
}, MainFrame)

-- Main page content
local Content = new("Frame", {
    Name = "MainPage", Size = UDim2.new(1, -170, 1, -100),
    Position = UDim2.fromOffset(170, 96),
    BackgroundTransparency = 1, BorderSizePixel = 0,
}, MainFrame)
local PageTitle = label(Content, "Main", 28, Enum.Font.GothamBlack, WHITE,
    UDim2.fromOffset(8, 0), UDim2.new(1, -16, 0, 36))
label(Content, "Open main features", 13, Enum.Font.Gotham,
    DIM, UDim2.fromOffset(9, 36), UDim2.new(1, -18, 0, 20))

-- Anti Guard card (the only function shown on Main)
local AntiGuardButton = new("TextButton", {
    Name = "AntiGuardCard", Size = UDim2.new(1, -8, 0, 88),
    Position = UDim2.fromOffset(4, 76),
    BackgroundColor3 = Color3.fromRGB(13, 8, 10),
    Text = "", AutoButtonColor = false,
}, Content)
corner(AntiGuardButton, UDim.new(0, 14))
local AntiStroke = stroke(AntiGuardButton, Color3.fromRGB(255, 0, 20), 1.5, 0.1)

local IconBox = new("Frame", {
    Size = UDim2.fromOffset(54, 54), Position = UDim2.new(0, 14, 0.5, -27),
    BackgroundColor3 = Color3.fromRGB(35, 0, 5), BorderSizePixel = 0,
}, AntiGuardButton)
corner(IconBox, UDim.new(0, 12))
stroke(IconBox, Color3.fromRGB(255, 0, 20), 1.5, 0)
local iconAsset = tostring(ICON_ANTIGUARD or "")
if iconAsset:match("^%d+$") then iconAsset = "rbxassetid://" .. iconAsset end
if iconAsset ~= "" then
    new("ImageLabel", {
        Size = UDim2.new(1, -12, 1, -12), Position = UDim2.fromOffset(6, 6),
        BackgroundTransparency = 1, Image = iconAsset, ScaleType = Enum.ScaleType.Fit,
    }, IconBox)
else
    new("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = "🛡", TextSize = 27, Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(255, 0, 20),
    }, IconBox)
end

label(AntiGuardButton, "Anti Guard", 17, Enum.Font.GothamBold, WHITE,
    UDim2.fromOffset(82, 19), UDim2.new(1, -250, 0, 25))
label(AntiGuardButton, "Anti Hit protection toggle", 12, Enum.Font.Gotham,
    DIM, UDim2.fromOffset(82, 47), UDim2.new(1, -250, 0, 20))

local Toggle = new("Frame", {
    Name = "Toggle", Size = UDim2.fromOffset(104, 36),
    Position = UDim2.new(1, -118, 0.5, -18),
    BackgroundColor3 = Color3.fromRGB(40, 10, 14), BorderSizePixel = 0,
}, AntiGuardButton)
corner(Toggle, UDim.new(1, 0))
stroke(Toggle, Color3.fromRGB(255, 0, 20), 1.2, 0)
local OffText = label(Toggle, "OFF", 12, Enum.Font.GothamBold, DIM,
    UDim2.fromOffset(10, 0), UDim2.fromOffset(30, 36), Enum.TextXAlignment.Center)
local OnText = label(Toggle, "ON", 12, Enum.Font.GothamBold, Color3.fromRGB(255, 0, 20),
    UDim2.new(1, -36, 0, 0), UDim2.fromOffset(30, 36), Enum.TextXAlignment.Center)
local Knob = new("Frame", {
    Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 6, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(220, 220, 225), BorderSizePixel = 0,
}, Toggle)
corner(Knob, UDim.new(1, 0))

local StatusDot = new("Frame", {
    Size = UDim2.fromOffset(7, 7), Position = UDim2.new(0, 8, 1, -22),
    BackgroundColor3 = OFF_COLOR, BorderSizePixel = 0,
}, Content)
corner(StatusDot, UDim.new(1, 0))
local Status = label(Content, "Status: OFF", 11, Enum.Font.Gotham,
    DIM, UDim2.new(0, 22, 1, -28), UDim2.new(1, -30, 0, 18))

local AntiGuardCard = {Button = AntiGuardButton}
local antiGuardVisualOn = false
function AntiGuardCard.Set(on)
    antiGuardVisualOn = on
    tween(Knob, 0.18, {
        Position = on and UDim2.new(1, -30, 0.5, -12) or UDim2.new(0, 6, 0.5, -12)
    }, Enum.EasingStyle.Back)
    tween(Toggle, 0.18, {
        BackgroundColor3 = on and Color3.fromRGB(120, 0, 15) or Color3.fromRGB(40, 10, 14)
    })
    tween(AntiStroke, 0.18, {
        Color = on and Color3.fromRGB(255, 0, 20) or Color3.fromRGB(110, 25, 30),
        Transparency = on and 0 or 0.2
    })
    tween(StatusDot, 0.18, {BackgroundColor3 = on and Color3.fromRGB(255, 0, 20) or OFF_COLOR})
    OffText.TextColor3 = on and DIM or WHITE
    OnText.TextColor3 = on and Color3.fromRGB(255, 0, 20) or DIM
end

MinBtn.MouseButton1Click:Connect(function()
    if menuOpen then closeMenu() end
end)

-- ===== Smooth Drag =====
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
    TweenService:Create(menuScale, openInfo, {Scale = fitScale}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {GroupTransparency = 0}):Play()
end

closeMenu = function()
    menuOpen = false
    menuToken += 1
    local token = menuToken
    local t = TweenService:Create(menuScale, closeInfo, {Scale = fitScale * 0.8})
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

FloatButton.MouseButton1Click:Connect(function()
    if not floatDrag.moved then
        toggleMenu()
    end
end)

-- ===== Loading UI ពេញអេក្រង់ =====
local LoadingGui = new("ScreenGui", {Name = "OliverLoading", ResetOnSpawn = false, IgnoreGuiInset = true,
    DisplayOrder = 999, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, guiParent)
-- ពេញអេក្រង់ពិតប្រាកដ: មិនទុក Inset ណាមួយ (Notch/Safe Area/Top bar)
pcall(function() LoadingGui.ScreenInsets = Enum.ScreenInsets.None end)

-- Loading ធំជាងអេក្រង់ 200px គ្រប់ទិស (ចំកណ្ដាលដដែល) ដើម្បីគ្របគែមទាំងអស់ គ្មានគម្លាត
-- ប្រើ Frame ធម្មតា (មិនមែន CanvasGroup) ដើម្បីឱ្យអក្សរមុត មិនព្រិល
local Loading = new("Frame", {Name = "Loading", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 400, 1, 400),
    BackgroundColor3 = Color3.fromRGB(8, 8, 16), BackgroundTransparency = 0, BorderSizePixel = 0,
    Visible = false}, LoadingGui)

local LoadBg = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    ZIndex = 0, Active = false}, Loading)
gradient(LoadBg, Color3.fromRGB(26, 18, 52), Color3.fromRGB(6, 8, 18), 90)

local function center(yOffset)
    return UDim2.new(0.5, 0, 0.5, yOffset)
end

-- Logo ចំកណ្ដាល + Ring វិល
local LoadLogo = makeLogo(Loading, UDim2.fromOffset(88, 88), center(-60), 3)
LoadLogo.AnchorPoint = Vector2.new(0.5, 0.5)

local Ring = new("Frame", {Size = UDim2.fromOffset(122, 122), AnchorPoint = Vector2.new(0.5, 0.5),
    Position = center(-60), BackgroundTransparency = 1}, Loading)
corner(Ring, UDim.new(1, 0))
local ringStroke = stroke(Ring, WHITE, 3, 0)
local ringGrad = new("UIGradient", {Color = ColorSequence.new(ACCENT_1, ACCENT_2), Transparency = NumberSequence.new({
    NSK(0, 0), NSK(0.55, 0.85), NSK(1, 1),
})}, ringStroke)

local LoadLabel = label(Loading, "Loading", 26, Enum.Font.GothamBlack, WHITE, center(28),
    UDim2.fromOffset(260, 34), Enum.TextXAlignment.Center)
LoadLabel.AnchorPoint = Vector2.new(0.5, 0)
LoadLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
LoadLabel.TextStrokeTransparency = 0.45

local LoadSub = label(Loading, "OLIVER v3 • Steal Egg", 16, Enum.Font.GothamBold, Color3.fromRGB(235, 235, 255),
    center(66), UDim2.fromOffset(300, 24), Enum.TextXAlignment.Center)
LoadSub.AnchorPoint = Vector2.new(0.5, 0)
LoadSub.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
LoadSub.TextStrokeTransparency = 0.55

local BarTrack = new("Frame", {Size = UDim2.fromOffset(240, 8), AnchorPoint = Vector2.new(0.5, 0),
    Position = center(102), BackgroundColor3 = WHITE, BackgroundTransparency = 0.85, BorderSizePixel = 0}, Loading)
corner(BarTrack, UDim.new(1, 0))
local BarFill = new("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0}, BarTrack)
corner(BarFill, UDim.new(1, 0))
gradient(BarFill, ACCENT_1, ACCENT_2, 0)

local LoadPct = label(Loading, "0%", 16, Enum.Font.GothamBold, WHITE,
    center(120), UDim2.fromOffset(100, 22), Enum.TextXAlignment.Center)
LoadPct.AnchorPoint = Vector2.new(0.5, 0)
LoadPct.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
LoadPct.TextStrokeTransparency = 0.55

local loadingToken = 0
local loadingConn = nil

local function showLoading(duration)
    if not SHOW_LOADING then return end
    loadingToken += 1
    Loading.Visible = true

    local startT = os.clock()
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    if loadingConn then loadingConn:Disconnect() end
    loadingConn = RunService.RenderStepped:Connect(function(dt)
        ringGrad.Rotation = (ringGrad.Rotation + dt * 400) % 360
        LoadLabel.Text = "Loading" .. string.rep(".", math.floor(os.clock() * 3) % 4)
        local p = math.clamp((os.clock() - startT) / math.max(duration, 0.01), 0, 1)
        BarFill.Size = UDim2.new(p, 0, 1, 0)
        LoadPct.Text = math.floor(p * 100) .. "%"
    end)
end

local function hideLoading()
    if not SHOW_LOADING then return end
    loadingToken += 1
    BarFill.Size = UDim2.new(1, 0, 1, 0)
    LoadPct.Text = "100%"
    Loading.Visible = false
    if loadingConn then
        loadingConn:Disconnect()
        loadingConn = nil
    end
end

-- ===== ប្រព័ន្ធ Anti Guard & Camera =====
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

local camFollowUntil = 0
local camHoldCF = nil
local camOffset = Vector3.new(0, 8, 14)
local camSettleCF, camSettleUntil = nil, 0

pcall(function() RunService:UnbindFromRenderStep("OliverCamFollow") end)
RunService:BindToRenderStep("OliverCamFollow", Enum.RenderPriority.Last.Value, function()
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

    if camSettleCF and os.clock() < camSettleUntil then
        local cam = Workspace.CurrentCamera
        if cam then cam.CFrame = camSettleCF end
        return
    end

    if os.clock() > camFollowUntil then return end

    local cam = Workspace.CurrentCamera
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (cam and root and hum) then return end

    if cam.CameraType ~= Enum.CameraType.Custom then
        cam.CameraType = Enum.CameraType.Custom
    end
    if cam.CameraSubject ~= hum then
        cam.CameraSubject = hum
    end

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
    if cam then camHoldCF = cam.CFrame end

    local origin = rootPart.CFrame
    local target = safeZone.CFrame + Vector3.new(0, 3, 0)

    -- ១. ទៅ SafeZone
    goTo(rootPart, target, TWEEN_TIME)

    -- ២. នៅ SafeZone + Glitch
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
    camSettleCF, camSettleUntil = camHoldCF, os.clock() + 0.4
    camHoldCF = nil
    camFollowUntil = os.clock() + 1.5
    resetCamera()
    task.delay(0.15, resetCamera)
    task.delay(0.6, resetCamera)
    hideLoading()
    busy = false
end

-- ===== Instant Prompt (HoldDuration = 0) =====
local instantPromptActive = false
local instantAddedConn = nil
local instantToken = 0
local instantConns = setmetatable({}, {__mode = "k"})

local function applyInstantPrompt(inst)
    if not inst:IsA("ProximityPrompt") then return end
    if inst:GetAttribute("OliverOrigHold") == nil then
        inst:SetAttribute("OliverOrigHold", inst.HoldDuration)
    end
    inst.HoldDuration = 0
    -- បើហ្គេមកែតម្លៃត្រឡប់វិញ → កំណត់ជា 0 ម្តងទៀត
    if not instantConns[inst] then
        instantConns[inst] = inst:GetPropertyChangedSignal("HoldDuration"):Connect(function()
            if instantPromptActive and inst.HoldDuration ~= 0 then
                inst.HoldDuration = 0
            end
        end)
    end
end

local function restoreInstantPrompt(inst)
    if not inst:IsA("ProximityPrompt") then return end
    local orig = inst:GetAttribute("OliverOrigHold")
    if orig ~= nil then
        inst.HoldDuration = orig
        inst:SetAttribute("OliverOrigHold", nil)
    end
end

local function setInstantPrompt(on)
    instantPromptActive = on
    instantToken += 1
    local token = instantToken

    if instantAddedConn then
        instantAddedConn:Disconnect()
        instantAddedConn = nil
    end

    if on then
        instantAddedConn = Workspace.DescendantAdded:Connect(function(inst)
            task.defer(applyInstantPrompt, inst)
        end)
        task.spawn(function()
            for i, inst in ipairs(Workspace:GetDescendants()) do
                if token ~= instantToken then return end
                applyInstantPrompt(inst)
                if i % 1500 == 0 then task.wait() end
            end
        end)
    else
        for inst, conn in pairs(instantConns) do
            conn:Disconnect()
            instantConns[inst] = nil
        end
        task.spawn(function()
            for i, inst in ipairs(Workspace:GetDescendants()) do
                if token ~= instantToken then return end
                restoreInstantPrompt(inst)
                if i % 1500 == 0 then task.wait() end
            end
        end)
    end
end

-- ===== ESP (Rarity + Icon Pet) =====
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local espActive = false
local espToken = 0
local ESP_TAG = "__OliverEspGui"

local function safeRequire(path)
    local ok, result = pcall(function() return require(path) end)
    return ok and result or nil
end

local espAssets, espEggState, espAreaEggs
pcall(function()
    espAssets = safeRequire(ReplicatedStorage.Data.Assets)
    espEggState = safeRequire(ReplicatedStorage.Client.EggState)
    espAreaEggs = safeRequire(ReplicatedStorage.Shared.Types.AreaEggs)
end)
local ESP_READY = (espAssets and espEggState and espAreaEggs) and true or false
if not ESP_READY then warn("[ESP] Game modules not found") end

local function espResolve(record)
    local asset = record and espAssets.Directory[record.AssetCategory]
    local rarity = asset and asset.Rarity
    return {
        rarity = rarity and (rarity.DisplayName or rarity._id) or "Unknown",
        color = rarity and typeof(rarity.Color) == "Color3" and rarity.Color or WHITE,
        icon = asset and type(asset.Icon) == "string" and asset.Icon or nil,
    }
end

local function clearEsp()
    local folder = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not folder then return end
    for _, slot in ipairs(folder:GetChildren()) do
        local g = slot:FindFirstChild(ESP_TAG)
        if g then g:Destroy() end
    end
end

local function buildEspGui(slot, hitbox)
    local g = new("BillboardGui", {Name = ESP_TAG, AlwaysOnTop = true, Size = UDim2.fromOffset(160, 64),
        StudsOffset = Vector3.new(0, 4.4, 0), MaxDistance = 1000, Adornee = hitbox}, slot)
    new("ImageLabel", {Name = "Icon", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(36, 36), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit,
        Visible = false}, g)
    new("TextLabel", {Name = "Text", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 38),
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
        TextSize = 14, TextStrokeTransparency = 0.35, Text = ""}, g)
    return g
end

local function updateEsp()
    if not ESP_READY then return end
    local folder = Workspace:FindFirstChild("AreaEggSlotsClient")
    if not folder then return end

    local records = {}
    local snapshot = espEggState.ReadFieldEggs()
    for _, rec in pairs(snapshot and (snapshot.Records or snapshot) or {}) do
        if type(rec) == "table" and type(rec.Uid) == "string" then
            records[rec.Uid] = rec
        end
    end

    for _, slot in ipairs(folder:GetChildren()) do
        local rec = records[slot.Name]
        local visible = espActive and rec ~= nil
            and (rec.State == espAreaEggs.States.Slot or rec.State == espAreaEggs.States.Dropped)
        local hitbox = visible and (slot:FindFirstChild("Hitbox") or slot:FindFirstChildWhichIsA("BasePart", true))
        local g = slot:FindFirstChild(ESP_TAG)

        if not hitbox then
            if g then g:Destroy() end
        else
            local info = espResolve(rec)
            g = g or buildEspGui(slot, hitbox)
            g.Adornee = hitbox

            local icon = g:FindFirstChild("Icon")
            icon.Image = info.icon or ""
            icon.Visible = info.icon ~= nil and info.icon ~= ""

            local txt = g:FindFirstChild("Text")
            txt.Text = string.upper(info.rarity)
            txt.TextColor3 = info.color
        end
    end
end

local function setEsp(on)
    espActive = on
    espToken += 1
    local token = espToken
    if on then
        task.spawn(function()
            while espActive and token == espToken do
                local ok, err = pcall(updateEsp)
                if not ok then warn("[ESP] update error: " .. tostring(err)) end
                task.wait(0.4)
            end
        end)
    else
        pcall(clearEsp)
    end
end

-- ===== Switch + Status =====
local function refreshStatus()
    local parts = {}
    if antiGuardActive then table.insert(parts, "Anti Guard") end
    if #parts > 0 then
        Status.Text = "Status: " .. table.concat(parts, " + ") .. " ON"
        tween(Status, 0.2, {TextColor3 = ON_COLOR})
        tween(StatusDot, 0.2, {BackgroundColor3 = ON_COLOR})
    else
        Status.Text = "Status: OFF"
        tween(Status, 0.2, {TextColor3 = DIM})
        tween(StatusDot, 0.2, {BackgroundColor3 = OFF_COLOR})
    end
end

AntiGuardCard.Button.MouseButton1Click:Connect(function()
    antiGuardActive = not antiGuardActive
    AntiGuardCard.Set(antiGuardActive)
    refreshStatus()
    print(antiGuardActive and "[Anti Guard] Activated!" or "[Anti Guard] Deactivated!")
end)

-- ===== ភ្ជាប់ Event ជាមួយ ProximityPrompt =====
local function setupPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        if not prompt:GetAttribute("UltimateHooked") then
            prompt:SetAttribute("UltimateHooked", true)

            prompt.Triggered:Connect(function(plr)
                if plr == player and antiGuardActive then
                    print("[Anti Guard]  Stealing eggs in progress...")

                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local rootPart = character.HumanoidRootPart

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
