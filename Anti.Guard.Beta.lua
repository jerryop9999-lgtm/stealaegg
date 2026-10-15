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
local ACCENT_1 = Color3.fromRGB(140, 90, 255)
local ACCENT_2 = Color3.fromRGB(60, 160, 255)
local ON_COLOR = Color3.fromRGB(60, 220, 130)
local OFF_COLOR = Color3.fromRGB(235, 80, 90)
local WHITE = Color3.new(1, 1, 1)
local DARK = Color3.fromRGB(12, 12, 22)
local DIM = Color3.fromRGB(170, 170, 195)
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

-- ============ Main UI ============
local MainFrame = new("CanvasGroup", {Name = "MainFrame", Size = UDim2.new(0, 280, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y, AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.3, 140, 0.3, 120), GroupTransparency = 1, BackgroundTransparency = 1,
    BorderSizePixel = 0, Visible = false}, ScreenGui)
local menuScale = new("UIScale", {Scale = 0.8}, MainFrame)
local openMenu, closeMenu, toggleMenu
corner(MainFrame, UDim.new(0, 18))
local frameStroke = stroke(MainFrame, WHITE, 1.5, 0.3)
new("UIGradient", {Color = ColorSequence.new(ACCENT_1, ACCENT_2), Rotation = 90}, frameStroke)

local Bg = new("Frame", {Name = "Bg", Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE,
    BackgroundTransparency = 0.08, BorderSizePixel = 0, Active = false, ZIndex = 0}, MainFrame)
corner(Bg, UDim.new(0, 18))
gradient(Bg, Color3.fromRGB(46, 34, 86), Color3.fromRGB(14, 18, 38), 120)

local Body = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1}, MainFrame)
new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center}, Body)

-- Header
local Header = new("Frame", {Size = UDim2.new(1, 0, 0, 62), BackgroundTransparency = 1, LayoutOrder = 1}, Body)
makeLogo(Header, UDim2.fromOffset(40, 40), UDim2.fromOffset(14, 11), 2)

local Title = label(Header, "OLIVER", 19, Enum.Font.GothamBlack, WHITE,
    UDim2.fromOffset(62, 10), UDim2.fromOffset(80, 24))
new("UIGradient", {Color = ColorSequence.new(WHITE, Color3.fromRGB(200, 185, 255)), Rotation = 90}, Title)

local Version = label(Header, "v3", 11, Enum.Font.GothamBold, WHITE,
    UDim2.fromOffset(138, 14), UDim2.fromOffset(28, 17), Enum.TextXAlignment.Center)
Version.BackgroundTransparency = 0.3
Version.BackgroundColor3 = ACCENT_1
corner(Version, UDim.new(1, 0))
gradient(Version, ACCENT_1, ACCENT_2, 45)

label(Header, "Steal an Egg  •  Anti Guard", 11, Enum.Font.Gotham, DIM,
    UDim2.fromOffset(62, 34), UDim2.fromOffset(160, 16))

local CloseBtn = new("TextButton", {Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -42, 0, 17),
    BackgroundColor3 = WHITE, BackgroundTransparency = 0.9, Text = "×", TextColor3 = WHITE,
    Font = Enum.Font.GothamBold, TextSize = 20, AutoButtonColor = false}, Header)
corner(CloseBtn, UDim.new(1, 0))
CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, 0.15, {BackgroundTransparency = 0.75}) end)
CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, 0.15, {BackgroundTransparency = 0.9}) end)
CloseBtn.MouseButton1Click:Connect(function() closeMenu() end)

-- Divider (ចុងស្រាល កណ្ដាលភ្លឺ)
local Divider = new("Frame", {Size = UDim2.new(1, -28, 0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    LayoutOrder = 2}, Body)
new("UIGradient", {Transparency = NumberSequence.new({NSK(0, 1), NSK(0.5, 0.6), NSK(1, 1)})}, Divider)

-- Cards
local Cards = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1, LayoutOrder = 3}, Body)
new("UIPadding", {PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)}, Cards)
new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)}, Cards)

local function makeCard(iconId, emoji, titleText, subText, order)
    local btn = new("TextButton", {Size = UDim2.new(1, 0, 0, 66), BackgroundColor3 = WHITE,
        BackgroundTransparency = 0.93, Text = "", AutoButtonColor = false, LayoutOrder = order}, Cards)
    corner(btn, UDim.new(0, 14))
    local st = stroke(btn, OFF_COLOR, 1.5, 0.5)

    local bar = new("Frame", {Size = UDim2.fromOffset(3, 30), Position = UDim2.new(0, 0, 0.5, -15),
        BackgroundColor3 = OFF_COLOR, BorderSizePixel = 0}, btn)
    corner(bar, UDim.new(1, 0))

    local iconBox = new("Frame", {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, 14, 0.5, -20),
        BackgroundColor3 = WHITE, BorderSizePixel = 0}, btn)
    corner(iconBox, UDim.new(0, 12))
    gradient(iconBox, ACCENT_1, ACCENT_2, 45)
    local assetId = tostring(iconId or "")
    if assetId:match("^%d+$") then assetId = "rbxassetid://" .. assetId end
    if assetId ~= "" then
        new("ImageLabel", {Size = UDim2.new(1, -12, 1, -12), Position = UDim2.fromOffset(6, 6),
            BackgroundTransparency = 1, Image = assetId, ScaleType = Enum.ScaleType.Fit}, iconBox)
    else
        new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = emoji,
            TextSize = 19, Font = Enum.Font.GothamBold, TextColor3 = WHITE}, iconBox)
    end

    label(btn, titleText, 15, Enum.Font.GothamBold, WHITE, UDim2.fromOffset(64, 13), UDim2.new(1, -130, 0, 22))
    label(btn, subText, 11, Enum.Font.Gotham, DIM, UDim2.fromOffset(64, 35), UDim2.new(1, -130, 0, 16))

    local sw = new("Frame", {Size = UDim2.fromOffset(48, 26), Position = UDim2.new(1, -62, 0.5, -13),
        BackgroundColor3 = OFF_COLOR, BorderSizePixel = 0}, btn)
    corner(sw, UDim.new(1, 0))
    local kn = new("Frame", {Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0, 3, 0.5, -10),
        BackgroundColor3 = WHITE, BorderSizePixel = 0}, sw)
    corner(kn, UDim.new(1, 0))

    local isOn = false
    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, {BackgroundTransparency = isOn and 0.84 or 0.88})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, {BackgroundTransparency = isOn and 0.88 or 0.93})
    end)

    local card = {Button = btn}
    function card.Set(on)
        isOn = on
        local c = on and ON_COLOR or OFF_COLOR
        tween(sw, 0.2, {BackgroundColor3 = c})
        tween(kn, 0.2, {Position = on and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)},
            Enum.EasingStyle.Back)
        tween(st, 0.2, {Color = c, Transparency = on and 0.3 or 0.5})
        tween(bar, 0.2, {BackgroundColor3 = c})
        tween(btn, 0.2, {BackgroundTransparency = on and 0.88 or 0.93})
    end
    return card
end

local AntiGuardCard = makeCard(ICON_ANTIGUARD, "🛡", "Anti Guard", "Anti Hit • SafeZone", 1)
local InstantCard = makeCard(ICON_INSTANT, "⚡", "Instant Prompt", "Hold time = 0 (no waiting)", 2)

-- Footer Status
local Footer = new("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, LayoutOrder = 4}, Body)
local StatusDot = new("Frame", {Size = UDim2.fromOffset(8, 8), Position = UDim2.new(0, 18, 0.5, -4),
    BackgroundColor3 = OFF_COLOR, BorderSizePixel = 0}, Footer)
corner(StatusDot, UDim.new(1, 0))
local Status = label(Footer, "Status: OFF", 11, Enum.Font.Gotham, DIM,
    UDim2.fromOffset(34, 0), UDim2.new(1, -48, 1, 0))

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
    TweenService:Create(menuScale, openInfo, {Scale = 1}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {GroupTransparency = 0}):Play()
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

-- ===== Switch + Status =====
local function refreshStatus()
    local parts = {}
    if antiGuardActive then table.insert(parts, "Anti Guard") end
    if instantPromptActive then table.insert(parts, "Instant Prompt") end
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

InstantCard.Button.MouseButton1Click:Connect(function()
    setInstantPrompt(not instantPromptActive)
    InstantCard.Set(instantPromptActive)
    refreshStatus()
    print(instantPromptActive and "[Instant Prompt] ON" or "[Instant Prompt] OFF")
end)

-- ===== ភ្ជាប់ Event ជាមួយ ProximityPrompt =====
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
