-- OLIVER v3 | Steal an Egg - Anti Guard
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
local AUTO_STEAL_SPEED = 150        -- Auto Steal: ល្បឿនធ្វើដំណើរ (studs/វិនាទី) ធំ = លឿន តែប្រថុយ Anti-cheat ខ្ពស់
local AUTO_STEAL_CARRY_TIMEOUT = 3  -- រង់ចាំបញ្ជាក់ថាបានយក Egg (វិនាទី) បើអស់ពេលរំលង Egg នោះ
-- ការ Select របស់ Auto Steal (កែតាម UI "Auto Steal Filters")
local AUTO_CFG = {
    Mode = "Tween",      -- Tween / Fly (ហោះតាមកម្ពស់) / Teleport (ភ្លាមៗ)
    Priority = "Rarity", -- Rarity / Value / Weight / Nearest (ស្មើគ្នា → យកជិតជាង)
    Rarities = {},       -- set: ទទេ = យកទាំងអស់
    Areas = {},
    Names = {},
    Mutations = {},
    MinValue = 0,
    MinWeight = 0,
}
local RARITY_RANK = {
    Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5,
    Mythic = 6, Cosmic = 7, Secret = 8, Eternal = 9, Divine = 10
}
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
MainFrame.Size = UDim2.new(0, 270, 0, 284)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.3, 135, 0.3, 142)
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
BtnSub.Text = "Auto teleport to SafeZone"
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

local AutoBtn, AutoSwitch, AutoKnob, autoStroke = makeCard("Auto Steal", "Auto grab eggs → SafeZone", 138)

-- ===== Auto Steal Filters (Select UI) =====
local FilterBtn = Instance.new("TextButton")
FilterBtn.Name = "FilterBtn"
FilterBtn.Size = UDim2.new(1, -28, 0, 32)
FilterBtn.Position = UDim2.new(0, 14, 0, 208)
FilterBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FilterBtn.BackgroundTransparency = 0.92
FilterBtn.Text = "⚙   Auto Steal Filters"
FilterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FilterBtn.Font = Enum.Font.GothamBold
FilterBtn.TextSize = 13
FilterBtn.AutoButtonColor = false
FilterBtn.Parent = MainFrame
corner(FilterBtn, UDim.new(0, 10))
stroke(FilterBtn, ACCENT_1, 1.2, 0.4)

do
    local RS = game:GetService("ReplicatedStorage")
    local WHITE = Color3.fromRGB(255, 255, 255)

    local function label(parent, text, size, pos, font, tsize, color, align)
        local l = Instance.new("TextLabel")
        l.Size = size
        l.Position = pos
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = color or WHITE
        l.Font = font or Enum.Font.Gotham
        l.TextSize = tsize or 13
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.Parent = parent
        return l
    end
    local function button(parent, text, size, pos, bgT)
        local b = Instance.new("TextButton")
        b.Size = size
        b.Position = pos
        b.BackgroundColor3 = WHITE
        b.BackgroundTransparency = bgT or 0.88
        b.Text = text
        b.TextColor3 = WHITE
        b.Font = Enum.Font.GothamBold
        b.TextSize = 13
        b.AutoButtonColor = false
        b.Parent = parent
        return b
    end

    -- ---------- Panel ----------
    local Panel = Instance.new("Frame")
    Panel.Name = "FilterPanel"
    Panel.Size = UDim2.new(1, 0, 1, 0)
    Panel.BackgroundColor3 = Color3.fromRGB(22, 18, 44)
    Panel.BackgroundTransparency = 0.04
    Panel.BorderSizePixel = 0
    Panel.Visible = false
    Panel.ZIndex = 5
    Panel.Parent = MainFrame
    corner(Panel, UDim.new(0, 16))

    local Back = button(Panel, "‹", UDim2.new(0, 30, 0, 30), UDim2.new(0, 10, 0, 10))
    Back.TextSize = 22
    corner(Back, UDim.new(1, 0))
    label(Panel, "Auto Steal Filters", UDim2.new(1, -130, 0, 30), UDim2.new(0, 48, 0, 10), Enum.Font.GothamBlack, 15)
    local ResetBtn = button(Panel, "Reset", UDim2.new(0, 56, 0, 26), UDim2.new(1, -66, 0, 12))
    ResetBtn.TextSize = 12
    corner(ResetBtn, UDim.new(0, 8))

    local Rows = Instance.new("ScrollingFrame")
    Rows.Size = UDim2.new(1, -20, 1, -54)
    Rows.Position = UDim2.new(0, 10, 0, 48)
    Rows.BackgroundTransparency = 1
    Rows.BorderSizePixel = 0
    Rows.ScrollBarThickness = 3
    Rows.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Rows.CanvasSize = UDim2.new(0, 0, 0, 0)
    Rows.Parent = Panel
    local rowsLayout = Instance.new("UIListLayout")
    rowsLayout.Padding = UDim.new(0, 8)
    rowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowsLayout.Parent = Rows

    local function makeRow(order)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -6, 0, 38)
        b.LayoutOrder = order
        b.BackgroundColor3 = WHITE
        b.BackgroundTransparency = 0.9
        b.Text = ""
        b.AutoButtonColor = false
        b.Parent = Rows
        corner(b, UDim.new(0, 10))
        local l = label(b, "", UDim2.new(1, -34, 1, 0), UDim2.new(0, 12, 0, 0), Enum.Font.GothamBold, 12)
        label(b, "›", UDim2.new(0, 20, 1, 0), UDim2.new(1, -24, 0, 0), Enum.Font.GothamBold, 18, nil, Enum.TextXAlignment.Center)
        return b, l
    end

    local function summary(set)
        local names = {}
        for k in pairs(set) do table.insert(names, k) end
        table.sort(names)
        if #names == 0 then return "Any" end
        if #names <= 2 then return table.concat(names, ", ") end
        return #names .. " selected"
    end

    local ModeRow, ModeLbl = makeRow(1)
    local PriorityRow, PriorityLbl = makeRow(2)
    local RarityRow, RarityLbl = makeRow(3)
    local AreaRow, AreaLbl = makeRow(4)
    local NameRow, NameLbl = makeRow(5)
    local MutationRow, MutationLbl = makeRow(6)

    -- Min Value / Min Weight (TextBox)
    local function makeBoxRow(order, text, placeholder)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, 38)
        row.LayoutOrder = order
        row.BackgroundColor3 = WHITE
        row.BackgroundTransparency = 0.9
        row.Parent = Rows
        corner(row, UDim.new(0, 10))
        label(row, text, UDim2.new(0.55, 0, 1, 0), UDim2.new(0, 12, 0, 0), Enum.Font.GothamBold, 12)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.38, 0, 0, 26)
        box.Position = UDim2.new(0.62, -8, 0.5, -13)
        box.BackgroundColor3 = WHITE
        box.BackgroundTransparency = 0.85
        box.Text = "0"
        box.PlaceholderText = placeholder
        box.TextColor3 = WHITE
        box.PlaceholderColor3 = Color3.fromRGB(170, 170, 195)
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.ClearTextOnFocus = false
        box.Parent = row
        corner(box, UDim.new(0, 8))
        return box
    end
    local ValueBox = makeBoxRow(7, "Min Value", "1k / 2.5m")
    local WeightBox = makeBoxRow(8, "Min Weight (kg)", "0")

    local function refreshRows()
        ModeLbl.Text = "Steal Mode:  " .. AUTO_CFG.Mode
        PriorityLbl.Text = "Priority:  " .. AUTO_CFG.Priority
        RarityLbl.Text = "Rarity:  " .. summary(AUTO_CFG.Rarities)
        AreaLbl.Text = "Area:  " .. summary(AUTO_CFG.Areas)
        NameLbl.Text = "Name:  " .. summary(AUTO_CFG.Names)
        MutationLbl.Text = "Mutation:  " .. summary(AUTO_CFG.Mutations)
    end
    refreshRows()

    -- ---------- Select Popup ----------
    local Popup = Instance.new("Frame")
    Popup.Size = UDim2.new(1, 0, 1, 0)
    Popup.BackgroundColor3 = Color3.fromRGB(18, 16, 36)
    Popup.BorderSizePixel = 0
    Popup.Visible = false
    Popup.ZIndex = 10
    Popup.Parent = Panel
    corner(Popup, UDim.new(0, 16))

    local PopTitle = label(Popup, "", UDim2.new(1, -100, 0, 28), UDim2.new(0, 14, 0, 12), Enum.Font.GothamBlack, 15)
    local DoneBtn = button(Popup, "Done", UDim2.new(0, 62, 0, 28), UDim2.new(1, -74, 0, 12), 0.5)
    DoneBtn.BackgroundColor3 = ACCENT_1
    corner(DoneBtn, UDim.new(0, 8))

    local Search = Instance.new("TextBox")
    Search.Size = UDim2.new(1, -24, 0, 30)
    Search.Position = UDim2.new(0, 12, 0, 48)
    Search.BackgroundColor3 = WHITE
    Search.BackgroundTransparency = 0.9
    Search.Text = ""
    Search.PlaceholderText = "Search..."
    Search.TextColor3 = WHITE
    Search.PlaceholderColor3 = Color3.fromRGB(170, 170, 195)
    Search.Font = Enum.Font.Gotham
    Search.TextSize = 13
    Search.ClearTextOnFocus = false
    Search.Parent = Popup
    corner(Search, UDim.new(0, 8))

    local AllBtn = button(Popup, "Select All", UDim2.new(0.5, -18, 0, 28), UDim2.new(0, 12, 0, 84))
    corner(AllBtn, UDim.new(0, 8))
    local ClearBtn = button(Popup, "Clear", UDim2.new(0.5, -18, 0, 28), UDim2.new(0.5, 6, 0, 84))
    corner(ClearBtn, UDim.new(0, 8))

    local List = Instance.new("ScrollingFrame")
    List.Size = UDim2.new(1, -20, 1, -126)
    List.Position = UDim2.new(0, 10, 0, 118)
    List.BackgroundTransparency = 1
    List.BorderSizePixel = 0
    List.ScrollBarThickness = 3
    List.AutomaticCanvasSize = Enum.AutomaticSize.Y
    List.CanvasSize = UDim2.new(0, 0, 0, 0)
    List.Parent = Popup
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = List

    local popSet, popOptions = {}, {}

    local function renderList()
        for _, c in ipairs(List:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        local q = string.lower(Search.Text or "")
        if #popOptions == 0 then
            local empty = label(List, "ផ្ទុកបញ្ជីមិនបាន (Executor ត្រូវគាំទ្រ require)", UDim2.new(1, -6, 0, 40), UDim2.new(0, 0, 0, 0), Enum.Font.Gotham, 12, Color3.fromRGB(200, 200, 220))
            empty.TextWrapped = true
            return
        end
        for i, name in ipairs(popOptions) do
            if q == "" or string.find(string.lower(name), q, 1, true) then
                local it = Instance.new("TextButton")
                it.Size = UDim2.new(1, -6, 0, 32)
                it.LayoutOrder = i
                it.BackgroundColor3 = WHITE
                it.Text = ""
                it.AutoButtonColor = false
                it.Parent = List
                corner(it, UDim.new(0, 8))
                label(it, name, UDim2.new(1, -40, 1, 0), UDim2.new(0, 12, 0, 0), Enum.Font.Gotham, 12)
                local mark = label(it, "", UDim2.new(0, 24, 1, 0), UDim2.new(1, -30, 0, 0), Enum.Font.GothamBold, 15, ON_COLOR, Enum.TextXAlignment.Center)
                local function paint()
                    mark.Text = popSet[name] and "✓" or ""
                    it.BackgroundTransparency = popSet[name] and 0.75 or 0.93
                end
                paint()
                it.MouseButton1Click:Connect(function()
                    popSet[name] = (not popSet[name]) or nil
                    paint()
                end)
            end
        end
    end
    Search:GetPropertyChangedSignal("Text"):Connect(renderList)

    -- ---------- Data providers (ពី Module របស់ហ្គេម) ----------
    local cache = {}
    local function getOptions(kind)
        if cache[kind] and #cache[kind] > 0 then return cache[kind] end
        local list = {}
        pcall(function()
            if kind == "Rarity" then
                local Assets = require(RS.Data.Assets)
                for k in pairs(Assets.ByRarity) do table.insert(list, k) end
                table.sort(list, function(a, b)
                    return (RARITY_RANK[a] or 99) < (RARITY_RANK[b] or 99)
                end)
            elseif kind == "Area" then
                local Areas = require(RS.Data.Areas)
                local Guards = require(RS.Data.Guards)
                for k, v in pairs(Areas.Directory) do
                    if type(k) == "string" and type(v) == "table" and type(v.DropTable) == "table" then
                        table.insert(list, k)
                    end
                end
                table.sort(list, function(a, b)
                    local ga, gb = Guards.Directory[a], Guards.Directory[b]
                    local wa = ga and ga.WalkSpeed or math.huge
                    local wb = gb and gb.WalkSpeed or math.huge
                    if wa == wb then return a < b end
                    return wa < wb
                end)
            elseif kind == "Name" then
                local Assets = require(RS.Data.Assets)
                local seen = {}
                for _, v in pairs(Assets.Directory) do
                    local n = v.DisplayName or v._id
                    if type(n) == "string" and n ~= "" and not seen[n] then
                        seen[n] = true
                        table.insert(list, n)
                    end
                end
                table.sort(list)
            elseif kind == "Mutation" then
                local M = require(RS.Shared.Modules.Mutations)
                for id in pairs(M.Ids()) do
                    if type(id) == "string" and id ~= M.NO_MUTATION then
                        local ok, lab = pcall(M.LabelOf, id)
                        table.insert(list, (ok and type(lab) == "string" and lab ~= "") and lab or id)
                    end
                end
                table.sort(list)
            end
        end)
        cache[kind] = list
        return list
    end

    local function openSelect(title, kind, set)
        PopTitle.Text = title
        popSet = set
        popOptions = getOptions(kind)
        Search.Text = ""
        renderList()
        Popup.Visible = true
    end

    AllBtn.MouseButton1Click:Connect(function()
        local q = string.lower(Search.Text or "")
        for _, name in ipairs(popOptions) do
            if q == "" or string.find(string.lower(name), q, 1, true) then
                popSet[name] = true
            end
        end
        renderList()
    end)
    ClearBtn.MouseButton1Click:Connect(function()
        for k in pairs(popSet) do popSet[k] = nil end
        renderList()
    end)
    DoneBtn.MouseButton1Click:Connect(function()
        Popup.Visible = false
        refreshRows()
    end)

    -- ---------- Row actions ----------
    local modes = {"Tween", "Fly", "Teleport"}
    ModeRow.MouseButton1Click:Connect(function()
        local idx = table.find(modes, AUTO_CFG.Mode) or 1
        AUTO_CFG.Mode = modes[idx % #modes + 1]
        refreshRows()
    end)
    local priorities = {"Rarity", "Value", "Weight", "Nearest"}
    PriorityRow.MouseButton1Click:Connect(function()
        local idx = table.find(priorities, AUTO_CFG.Priority) or 1
        AUTO_CFG.Priority = priorities[idx % #priorities + 1]
        refreshRows()
    end)
    RarityRow.MouseButton1Click:Connect(function() openSelect("Select Rarity", "Rarity", AUTO_CFG.Rarities) end)
    AreaRow.MouseButton1Click:Connect(function() openSelect("Select Area", "Area", AUTO_CFG.Areas) end)
    NameRow.MouseButton1Click:Connect(function() openSelect("Select Name", "Name", AUTO_CFG.Names) end)
    MutationRow.MouseButton1Click:Connect(function() openSelect("Select Mutation", "Mutation", AUTO_CFG.Mutations) end)

    local function parseValue(text)
        local t = string.lower(tostring(text or "")):gsub("[%s,]", "")
        if t == "" then return 0 end
        local num, suffix = string.match(t, "^(%d+%.?%d*)([kmb]?)$")
        local n = tonumber(num)
        if not n then return nil end
        local mult = ({k = 1e3, m = 1e6, b = 1e9})[suffix] or 1
        return n * mult
    end
    ValueBox.FocusLost:Connect(function()
        local v = parseValue(ValueBox.Text)
        if v then
            AUTO_CFG.MinValue = v
        else
            ValueBox.Text = tostring(AUTO_CFG.MinValue)
        end
    end)
    WeightBox.FocusLost:Connect(function()
        local v = tonumber(WeightBox.Text)
        if v and v >= 0 then
            AUTO_CFG.MinWeight = v
        else
            WeightBox.Text = tostring(AUTO_CFG.MinWeight)
        end
    end)

    ResetBtn.MouseButton1Click:Connect(function()
        for _, key in ipairs({"Rarities", "Areas", "Names", "Mutations"}) do
            for k in pairs(AUTO_CFG[key]) do AUTO_CFG[key][k] = nil end
        end
        AUTO_CFG.Mode = "Tween"
        AUTO_CFG.Priority = "Rarity"
        AUTO_CFG.MinValue = 0
        AUTO_CFG.MinWeight = 0
        ValueBox.Text = "0"
        WeightBox.Text = "0"
        refreshRows()
    end)

    Back.MouseButton1Click:Connect(function()
        Popup.Visible = false
        Panel.Visible = false
    end)
    FilterBtn.MouseButton1Click:Connect(function()
        refreshRows()
        Panel.Visible = true
    end)
end


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
LoadSub.Text = "OLIVER v3 • Moving to SafeZone"
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

-- ===== Auto Steal =====
-- ប្រើ Module/Remote របស់ហ្គេមផ្ទាល់ (EggState, EggWorld) ដើម្បីរក Egg → ទៅយក → ទៅ SafeZone
local autoStealActive = false
local autoStealToken = 0
local autoBusy = false -- true ពេល Auto Steal កំពុងធ្វើដំណើរ (ដើម្បីបញ្ឈប់ភ្លាមៗពេលបិទ)

local function setAutoStatus(txt)
    if autoStealActive then
        Status.Text = "Auto Steal: " .. txt
        Status.TextColor3 = ON_COLOR
    end
end
local carrying = false
local carryInflight = false
local EggStateMod, EggWorldRemote, ResetWallMod, AssetsMod, CycleMod, EggRecordsMod, AreaEggSlotIdentityMod
local STATE = {Slot = "Slot", Dropped = "Dropped", Carried = "Carried"}
local skipUntil = {}
local warnedModules = false
local SAFE_POS = Vector3.new(544.76, 71.5, -416.48) -- ទីតាំង Safe (ដូច Script គេ)
local SAFE_RADIUS = 30                               -- ក្នុងរង្វង់នេះ = ដល់ Safe ហើយ
local EARLY_CARRY_DISTANCE = 8                       -- ចម្ងាយចាប់ផ្តើមស្នើ Carry មុនទៅដល់
local printedFields = false
local warnedArea = false

local function loadEggModules()
    if EggStateMod and EggWorldRemote then return true end
    local RS = game:GetService("ReplicatedStorage")
    local ok = pcall(function()
        EggStateMod = require(RS.Client.EggState)
        EggWorldRemote = require(RS.Shared.Remotes).EggWorld
    end)
    if not ok or not EggStateMod or not EggWorldRemote then
        EggStateMod, EggWorldRemote = nil, nil
        return false
    end
    pcall(function() ResetWallMod = require(RS.Client.AreaEggResetWall) end)
    pcall(function() AssetsMod = require(RS.Data.Assets) end)
    pcall(function() CycleMod = require(RS.Shared.Util.AreaEggCycle) end)
    pcall(function() EggRecordsMod = require(RS.Shared.Util.EggRecords) end)
    pcall(function() AreaEggSlotIdentityMod = require(RS.Shared.Util.AreaEggSlotIdentity) end)
    pcall(function()
        local T = require(RS.Shared.Types.AreaEggs)
        if T and type(T.States) == "table" then
            for k in pairs(STATE) do
                if T.States[k] ~= nil then STATE[k] = T.States[k] end
            end
        end
    end)
    -- ដឹងថាកំពុងសែង Egg ឬអត់
    pcall(function()
        EggStateMod.CarryChanged:Connect(function(info)
            carrying = type(info) == "table" and info.IsCarrying == true
        end)
    end)
    return true
end

-- បញ្ជាក់ Carry ពី record (ដូច Script គេ): State = Carried ហើយ CarrierUserId = យើង
local function isMyCarry(uid)
    local rec
    pcall(function() rec = EggStateMod.ReadFieldEgg(uid) end)
    return rec ~= nil and rec.State == STATE.Carried and rec.CarrierUserId == player.UserId
end

local function wallSealed()
    if CycleMod and type(CycleMod.IsNightPhase) == "function" then
        local ok, res = pcall(CycleMod.IsNightPhase, Workspace:GetServerTimeNow())
        if ok and res == true then return true end
    end
    if ResetWallMod and type(ResetWallMod.IsSealed) == "function" then
        local ok, res = pcall(ResetWallMod.IsSealed)
        if ok and res == true then return true end
    end
    return false
end

local function weightOf(rec)
    local w
    pcall(function()
        if EggRecordsMod and type(EggRecordsMod.WeightKgForScale) == "function" then
            w = EggRecordsMod.WeightKgForScale(rec.AssetScale or 1)
        end
    end)
    return tonumber(w)
end

local function rarityOf(rec)
    local name
    pcall(function()
        local info = AssetsMod and AssetsMod.Directory[rec.AssetCategory]
        local r = info and info.Rarity
        name = r and (r.DisplayName or r._id)
    end)
    return name
end

local function nameOf(rec)
    local name
    pcall(function()
        local info = AssetsMod and AssetsMod.Directory[rec.AssetCategory]
        name = info and (info.DisplayName or info._id)
    end)
    return name or tostring(rec.AssetCategory)
end

local EarningsMod
local function eggValue(rec)
    local v = 0
    pcall(function()
        EarningsMod = EarningsMod or require(game:GetService("ReplicatedStorage").Shared.Util.AssetEarnings)
        v = EarningsMod.MutationOnlyRatePerSecond({
            Category = rec.AssetCategory,
            Scale = rec.AssetScale or 1,
            Mutations = rec.Mutations or {},
            BaseMutation = rec.BaseMutation,
            EyeColor = rec.AssetEyeColor,
            ColorSeed = rec.AssetColorSeed,
            ColorIndex = rec.AssetColorIndex,
            Gender = rec.Gender,
            Personality = rec.Personality or "Normal",
            HasBeenFirstPlaced = rec.HasBeenFirstPlaced == true
        })
    end)
    return tonumber(v) or 0
end

-- ស្គាល់ Area របស់ Egg: ១) ពី field ក្នុង record  ២) ពីទីតាំង (Position) ធៀបនឹង World.Areas.GuardAreas
local areaBoxes = nil

local function buildAreaBoxes()
    local boxes = {}
    local world = Workspace:FindFirstChild("World")
    local areas = world and world:FindFirstChild("Areas")
    local guard = areas and areas:FindFirstChild("GuardAreas")
    if not guard then return nil end

    for _, child in ipairs(guard:GetChildren()) do
        local cf, size
        if child:IsA("Model") then
            local ok, c, sz = pcall(child.GetBoundingBox, child)
            if ok then cf, size = c, sz end
        elseif child:IsA("BasePart") then
            cf, size = child.CFrame, child.Size
        end
        if cf then
            table.insert(boxes, {name = child.Name, cf = cf, size = size})
        end
    end
    if #boxes == 0 then return nil end

    local names = {}
    for _, b in ipairs(boxes) do table.insert(names, b.name) end
    print("[Auto Steal] Areas detected: " .. table.concat(names, ", "))
    return boxes
end

local function areaByPosition(pos)
    areaBoxes = areaBoxes or buildAreaBoxes()
    if not areaBoxes then return nil end

    local best, bestScore = nil, math.huge
    for _, a in ipairs(areaBoxes) do
        local rel = a.cf:PointToObjectSpace(pos)
        local half = a.size / 2
        local inside = math.abs(rel.X) <= half.X and math.abs(rel.Z) <= half.Z
        local d = (a.cf.Position - pos).Magnitude
        if inside then d = d * 0.01 end -- ប្រើ Area ដែលមាន Egg នៅក្នុងជាមុន
        if d < bestScore then
            best, bestScore = a.name, d
        end
    end
    return best
end

local AREA_FIELDS = {"AreaId", "Area", "AreaName", "AreaKey", "AreaCategory", "SourceArea"}
local function areaOf(rec)
    for _, f in ipairs(AREA_FIELDS) do
        local v = rec[f]
        if type(v) == "string" then return v end
    end
    if rec.BottomCFrame then
        return areaByPosition(rec.BottomCFrame.Position)
    end
    return nil
end

local function normName(n)
    return (string.lower(tostring(n)):gsub("[%s_%-]", ""))
end

local function areaSelected(a)
    local na = normName(a)
    for k in pairs(AUTO_CFG.Areas) do
        local nk = normName(k)
        if nk == na or string.find(nk, na, 1, true) or string.find(na, nk, 1, true) then
            return true
        end
    end
    return false
end

local function selectedMutationIds()
    if next(AUTO_CFG.Mutations) == nil then return nil end
    local ids = {}
    pcall(function()
        local M = require(game:GetService("ReplicatedStorage").Shared.Modules.Mutations)
        for id in pairs(M.Ids()) do
            if id ~= M.NO_MUTATION then
                local ok, lab = pcall(M.LabelOf, id)
                if AUTO_CFG.Mutations[id] or (ok and AUTO_CFG.Mutations[lab]) then
                    ids[id] = true
                end
            end
        end
    end)
    return ids
end

local function passesFilters(rec, mutIds)
    if next(AUTO_CFG.Rarities) ~= nil and not AUTO_CFG.Rarities[rarityOf(rec) or ""] then
        return false
    end
    if next(AUTO_CFG.Names) ~= nil and not AUTO_CFG.Names[nameOf(rec)] then
        return false
    end
    if next(AUTO_CFG.Areas) ~= nil then
        local a = areaOf(rec)
        if a == nil then
            if not warnedArea then
                warnedArea = true
                warn("[Auto Steal] រកមិនឃើញ Area របស់ Egg (World.Areas.GuardAreas) → Area filter ត្រូវបានរំលង")
            end
        elseif not areaSelected(a) then
            return false
        end
    end
    if mutIds then
        local ok = false
        for _, m in ipairs(rec.Mutations or {}) do
            if mutIds[m] then ok = true break end
        end
        if not ok and rec.BaseMutation ~= nil and mutIds[rec.BaseMutation] then ok = true end
        if not ok then return false end
    end
    if AUTO_CFG.MinValue > 0 and eggValue(rec) < AUTO_CFG.MinValue then
        return false
    end
    if AUTO_CFG.MinWeight > 0 then
        local w = weightOf(rec)
        if not w or w < AUTO_CFG.MinWeight then return false end
    end
    return true
end

local function pickTarget(fromPos)
    local snapshot
    pcall(function() snapshot = EggStateMod.ReadFieldEggs() end)
    local records = snapshot and snapshot.Records
    if not records then return nil end

    if not printedFields then
        for _, rec in pairs(records) do
            local keys = {}
            for k in pairs(rec) do table.insert(keys, tostring(k)) end
            table.sort(keys)
            print("[Auto Steal] Egg record fields: " .. table.concat(keys, ", "))
            printedFields = true
            break
        end
    end

    local mutIds = selectedMutationIds()
    local bestUid, bestRec, bestScore = nil, nil, -math.huge
    for uid, rec in pairs(records) do
        local state = rec.State
        if (state == STATE.Slot or state == STATE.Dropped) and rec.BottomCFrame
            and (skipUntil[uid] or 0) < os.clock() and passesFilters(rec, mutIds) then
            local dist = (rec.BottomCFrame.Position - fromPos).Magnitude
            -- ស្មើគ្នា → យកជិតជាង (ដូច Script គេ)
            local score = -dist
            if AUTO_CFG.Priority == "Rarity" then
                score = (RARITY_RANK[rarityOf(rec) or ""] or 0) * 1e6 - dist
            elseif AUTO_CFG.Priority == "Value" then
                score = eggValue(rec) - dist * 1e-6
            elseif AUTO_CFG.Priority == "Weight" then
                score = (weightOf(rec) or 0) - dist * 1e-6
            end
            if score > bestScore then
                bestUid, bestRec, bestScore = uid, rec, score
            end
        end
    end
    return bestUid, bestRec
end

local function getSafeCFrame(root)
    local y = SAFE_POS.Y
    pcall(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {player.Character}
        local hit = Workspace:Raycast(Vector3.new(SAFE_POS.X, SAFE_POS.Y + 60, SAFE_POS.Z), Vector3.new(0, -120, 0), params)
        if hit then y = hit.Position.Y + 3.2 end
    end)
    return CFrame.new(SAFE_POS.X, y, SAFE_POS.Z) * root.CFrame.Rotation
end

local function inSafeArea(root)
    local d = root.Position - SAFE_POS
    return Vector2.new(d.X, d.Z).Magnitude <= SAFE_RADIUS and math.abs(d.Y) <= 18
end

-- ចំណុចឈរលើ Egg: BottomCFrame + កម្ពស់ជើង (HipHeight + ពាក់កណ្ដាល Root) ដូច SenaHub
local function eggDestination(root, rec)
    local hum = root.Parent and root.Parent:FindFirstChildOfClass("Humanoid")
    local feet = 3
    if hum then feet = math.max(hum.HipHeight + root.Size.Y / 2, 3) end
    return CFrame.new(rec.BottomCFrame.Position + Vector3.new(0, feet + 0.15, 0))
end

local function legTime(a, b)
    return math.max((a - b).Magnitude / AUTO_STEAL_SPEED, 0.03)
end

-- ធ្វើដំណើរតាម Mode: Tween (ត្រង់) / Fly (ឡើងកម្ពស់ → ទៅ → ចុះ) / Teleport (ភ្លាមៗ)
-- onNear: ហៅម្តងពេលនៅក្នុងចម្ងាយ EARLY_CARRY_DISTANCE ពីគោលដៅ
local function travel(root, cf, onNear)
    local watcher
    if onNear then
        watcher = task.spawn(function()
            while root.Parent do
                if (root.Position - cf.Position).Magnitude <= EARLY_CARRY_DISTANCE then
                    onNear()
                    return
                end
                task.wait()
            end
        end)
    end

    local mode = AUTO_CFG.Mode
    if mode == "Teleport" then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.CFrame = cf
    elseif mode == "Fly" then
        local from, to = root.Position, cf.Position
        -- ហោះកម្ពស់ 110 បើគោលដៅទាប (ដូច SenaHub) បើខ្ពស់ជាងនេះ ហោះលើគោលដៅបន្តិច
        local cruiseY = math.max(from.Y, (to.Y >= 104) and (to.Y + 5) or 110)
        local up = Vector3.new(from.X, cruiseY, from.Z)
        local over = Vector3.new(to.X, cruiseY, to.Z)
        goTo(root, CFrame.new(up), legTime(from, up))
        goTo(root, CFrame.new(over), legTime(up, over))
        goTo(root, cf, legTime(over, to))
    else
        goTo(root, cf, legTime(root.Position, cf.Position))
    end

    if watcher then pcall(task.cancel, watcher) end
end

local function pingWait()
    local ms = 0
    pcall(function()
        ms = game:GetService("Stats").Network.ServerStats.Ping:GetValue()
    end)
    return math.max(0.3, ms * 2.5 / 1000)
end

-- ស្នើយក Egg (Unequip Tool មុន ដូច Script គេ)
-- Carry request follows SenaHub's normal request shape, including the first-area
-- slot identity when the selected egg is a slot-based egg.
local function requestCarry(uid, rec)
    if carryInflight then return false end
    carryInflight = true
    local accepted = false
    local ok, err = pcall(function()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root then
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        if hum then pcall(hum.UnequipTools, hum) end
        task.wait(pingWait())

        local args = {Uid = uid}
        if rec and AreaEggSlotIdentityMod
            and type(AreaEggSlotIdentityMod.LooksLikeFirstAreaUid) == "function"
            and type(AreaEggSlotIdentityMod.SlotKey) == "function" then
            local looksLikeSlot = false
            pcall(function()
                looksLikeSlot = AreaEggSlotIdentityMod.LooksLikeFirstAreaUid(uid) == true
            end)
            if looksLikeSlot and rec.AreaId ~= nil and rec.NestId ~= nil then
                local keyOk, key = pcall(AreaEggSlotIdentityMod.SlotKey, rec.AreaId, rec.NestId)
                if keyOk and key ~= nil then args.FirstAreaSlotKey = key end
            end
        end

        local response, reason = EggWorldRemote.AskFieldEggCarry:InvokeServer(args)
        accepted = response == true
        if not accepted and type(reason) == "string" and reason ~= "" then
            warn("[Auto Steal] Carry request refused: " .. reason)
        end
    end)
    carryInflight = false
    if not ok then warn("[Auto Steal] Carry request error: " .. tostring(err)) end
    return accepted
end

local function autoStealStep()
    if busy then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum0 = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum0 or hum0.Health <= 0 then
        setAutoStatus("Waiting for character")
        task.wait(0.5)
        return
    end

    if not loadEggModules() then
        if not warnedModules then
            warnedModules = true
            warn("[Auto Steal] ផ្ទុក EggState/Remotes មិនបាន (Executor ត្រូវតែគាំទ្រ require)")
        end
        task.wait(2)
        return
    end
    if wallSealed() then
        setAutoStatus("Waiting for reset wall")
        return
    end

    -- កំពុងសែង Egg → ត្រឡប់ទៅ Safe
    if carrying then
        if not inSafeArea(root) then
            setAutoStatus("Returning to safe zone")
            busy = true
            autoBusy = true
            local ok, err = pcall(travel, root, getSafeCFrame(root), nil)
            autoBusy = false
            busy = false
            if not ok then warn("[Auto Steal] Deliver error: " .. tostring(err)) end
        end
        setAutoStatus("Delivering egg")
        local t0 = os.clock()
        while autoStealActive and carrying and os.clock() - t0 < 4 do
            task.wait(0.1)
        end
        return
    end

    -- រក Egg តាម Filter
    local uid, rec = pickTarget(root.Position)
    if not rec then
        setAutoStatus("No matching eggs")
        task.wait(0.4)
        return
    end

    print(string.format("[Auto Steal] Target: %s | %s | area=%s | %.0f studs | mode=%s",
        nameOf(rec), tostring(rarityOf(rec) or "?"), tostring(areaOf(rec) or "?"),
        (rec.BottomCFrame.Position - root.Position).Magnitude, AUTO_CFG.Mode))

    busy = true
    autoBusy = true
    local ok, err = pcall(function()
        local dest = eggDestination(root, rec)
        setAutoStatus("Going to " .. tostring(nameOf(rec)))

        -- ទៅរក Egg ហើយស្នើ Carry មុនទៅដល់ (ក្នុង 8 studs)
        travel(root, dest, function()
            task.spawn(requestCarry, uid, rec)
        end)

        -- ជាប់នៅលើ Egg រហូតដល់បញ្ជាក់ថាបានយក (ពី record) ដូច "arrival hold" របស់ SenaHub
        setAutoStatus("Securing egg")
        local deadline = os.clock() + AUTO_STEAL_CARRY_TIMEOUT
        while autoStealActive and not carrying and os.clock() < deadline do
            if not root.Parent then break end
            if isMyCarry(uid) then
                task.wait(0.25) -- បញ្ជាក់ម្តងទៀតមុនចេញដំណើរ
                if isMyCarry(uid) then
                    carrying = true
                    break
                end
            end
            if not carryInflight then
                task.spawn(requestCarry, uid, rec)
            end
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            root.CFrame = dest
            task.wait()
        end
    end)
    autoBusy = false
    busy = false
    if not ok then warn("[Auto Steal] Error: " .. tostring(err)) end
    if not carrying then
        skipUntil[uid] = os.clock() + 15 -- រំលង Egg នេះ 15 វិនាទី
    end
end

local function autoStealLoop(token)
    print("[Auto Steal] Started")
    while autoStealActive and token == autoStealToken do
        local ok, err = pcall(autoStealStep)
        if not ok then
            busy = false
            warn("[Auto Steal] " .. tostring(err))
            task.wait(1)
        end
        task.wait(0.1)
    end
    print("[Auto Steal] Stopped")
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
    if autoStealActive then table.insert(parts, "Auto Steal") end
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

AutoBtn.MouseButton1Click:Connect(function()
    autoStealActive = not autoStealActive
    autoStealToken += 1
    setCard(AutoSwitch, AutoKnob, autoStroke, autoStealActive)
    refreshStatus()
    if autoStealActive then
        task.spawn(autoStealLoop, autoStealToken)
    elseif autoBusy and currentTween then
        -- បិទ Auto Steal ពេលកំពុងធ្វើដំណើរ → បញ្ឈប់ Tween ភ្លាមៗ
        pcall(function() currentTween:Cancel() end)
    end
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
