local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local CoreGui       = game:GetService("CoreGui")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")

local player = Players.LocalPlayer

local function VP() return workspace.CurrentCamera.ViewportSize end
local function isMobile() return VP().X < 700 end

local function getW() return math.min(VP().X - 24, isMobile() and 340 or 650) end
local function getH() return math.min(VP().Y - 48, isMobile() and 500 or 540) end

local C = {
    Bg      = Color3.fromRGB(11, 11, 11),
    Sidebar = Color3.fromRGB(13, 13, 13),
    TopBar  = Color3.fromRGB(17, 17, 17),
    Card    = Color3.fromRGB(16, 16, 16),
    Border  = Color3.fromRGB(38, 38, 38),
    Red     = Color3.fromRGB(215, 35, 35),
    Text    = Color3.fromRGB(228, 228, 228),
    Sub     = Color3.fromRGB(120, 120, 120),
    Gray    = Color3.fromRGB(55, 55, 55),
}

pcall(function()
    local o = CoreGui:FindFirstChild("ERDEVA_HUB")
    if o then o:Destroy() end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name            = "ERDEVA_HUB"
Gui.ResetOnSpawn    = false
Gui.IgnoreGuiInset  = true
Gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder    = 999
Gui.Parent          = CoreGui

local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local W, H = getW(), getH()

local Main = Instance.new("Frame")
Main.Name               = "Main"
Main.Size               = UDim2.fromOffset(W, H)
Main.Position           = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3   = C.Bg
Main.BorderSizePixel    = 0
Main.ClipsDescendants   = true
Main.Parent             = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color        = C.Red
MainStroke.Thickness    = 1

local TOP_H = 44

local TopBar = Instance.new("Frame")
TopBar.Name             = "TopBar"
TopBar.Size             = UDim2.new(1, 0, 0, TOP_H)
TopBar.BackgroundColor3 = C.TopBar
TopBar.BorderSizePixel  = 0
TopBar.ZIndex           = 10
TopBar.Parent           = Main

local TopDiv = Instance.new("Frame")
TopDiv.Size             = UDim2.new(1, 0, 0, 1)
TopDiv.Position         = UDim2.new(0, 0, 1, -1)
TopDiv.BackgroundColor3 = C.Border
TopDiv.BorderSizePixel  = 0
TopDiv.Parent           = TopBar

local Accent = Instance.new("Frame")
Accent.Size             = UDim2.fromOffset(3, 20)
Accent.Position         = UDim2.fromOffset(12, 12)
Accent.BackgroundColor3 = C.Red
Accent.BorderSizePixel  = 0
Accent.Parent           = TopBar
Instance.new("UICorner", Accent).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel")
Title.Size              = UDim2.fromOffset(200, TOP_H)
Title.Position          = UDim2.fromOffset(22, 0)
Title.BackgroundTransparency = 1
Title.Text              = "ERDEVA HUB"
Title.TextColor3        = C.Text
Title.TextSize          = 15
Title.Font              = Enum.Font.GothamBold
Title.TextXAlignment    = Enum.TextXAlignment.Left
Title.Parent            = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size           = UDim2.fromOffset(200, TOP_H)
SubTitle.Position       = UDim2.fromOffset(22, 14)
SubTitle.BackgroundTransparency = 1
SubTitle.Text           = "v1.0  |  Chicken Farm"
SubTitle.TextColor3     = C.Red
SubTitle.TextSize       = 9
SubTitle.Font           = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent         = TopBar

local function MakeHeaderBtn(txt, rightPad)
    local B = Instance.new("TextButton")
    B.Size              = UDim2.fromOffset(28, 28)
    B.Position          = UDim2.new(1, -rightPad, 0.5, -14)
    B.BackgroundColor3  = Color3.fromRGB(26, 26, 26)
    B.BorderSizePixel   = 0
    B.Text              = txt
    B.TextColor3        = C.Sub
    B.TextSize          = 13
    B.Font              = Enum.Font.GothamBold
    B.AutoButtonColor   = false
    B.ZIndex            = 15
    B.Parent            = TopBar
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    B.MouseEnter:Connect(function()  tw(B, {BackgroundColor3 = Color3.fromRGB(38,38,38)}) end)
    B.MouseLeave:Connect(function()  tw(B, {BackgroundColor3 = Color3.fromRGB(26,26,26)}) end)
    return B
end

local BtnClose = MakeHeaderBtn("x", 10)
local BtnMin   = MakeHeaderBtn("-", 44)

BtnClose.MouseEnter:Connect(function() tw(BtnClose, {TextColor3 = C.Red}) end)
BtnClose.MouseLeave:Connect(function() tw(BtnClose, {TextColor3 = C.Sub}) end)
BtnClose.MouseButton1Click:Connect(function() Gui:Destroy() end)

local SIDE_W = isMobile() and 44 or 170

local Sidebar = Instance.new("Frame")
Sidebar.Name            = "Sidebar"
Sidebar.Size            = UDim2.new(0, SIDE_W, 1, -TOP_H)
Sidebar.Position        = UDim2.fromOffset(0, TOP_H)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent          = Main

local SideDiv = Instance.new("Frame")
SideDiv.Size            = UDim2.new(0, 1, 1, 0)
SideDiv.Position        = UDim2.new(1, -1, 0, 0)
SideDiv.BackgroundColor3 = C.Border
SideDiv.BorderSizePixel = 0
SideDiv.Parent          = Sidebar

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding      = UDim.new(0, 3)
SideLayout.SortOrder    = Enum.SortOrder.LayoutOrder

local SidePad = Instance.new("UIPadding", Sidebar)
SidePad.PaddingTop      = UDim.new(0, 8)
SidePad.PaddingLeft     = UDim.new(0, 4)
SidePad.PaddingRight    = UDim.new(0, 4)

local Content = Instance.new("ScrollingFrame")
Content.Name            = "Content"
Content.Size            = UDim2.new(1, -SIDE_W, 1, -TOP_H)
Content.Position        = UDim2.fromOffset(SIDE_W, TOP_H)
Content.BackgroundColor3 = C.Bg
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = C.Red
Content.CanvasSize      = UDim2.fromOffset(0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollingDirection = Enum.ScrollingDirection.Y
Content.Parent          = Main

local CPad = Instance.new("UIPadding", Content)
CPad.PaddingTop         = UDim.new(0, 8)
CPad.PaddingLeft        = UDim.new(0, 8)
CPad.PaddingRight       = UDim.new(0, 8)
CPad.PaddingBottom      = UDim.new(0, 12)

local CLayout = Instance.new("UIListLayout", Content)
CLayout.Padding         = UDim.new(0, 8)
CLayout.SortOrder       = Enum.SortOrder.LayoutOrder

local Pages      = {}
local SideBtns   = {}
local curPage    = nil

local function SetPage(name)
    for n, d in pairs(Pages) do
        d.Frame.Visible = (n == name)
    end
    for n, b in pairs(SideBtns) do
        if n == name then
            tw(b.Bg, {BackgroundColor3 = Color3.fromRGB(32,10,10), BackgroundTransparency = 0})
            tw(b.Lbl, {TextColor3 = C.Text})
            b.Dot.Visible = true
        else
            tw(b.Bg, {BackgroundTransparency = 1})
            tw(b.Lbl, {TextColor3 = C.Sub})
            b.Dot.Visible = false
        end
    end
    Content.CanvasPosition = Vector2.new(0, 0)
    curPage = name
end

local mobile = isMobile()

local function AddPage(name, icon, order)
    local btnH = mobile and 40 or 36

    local Bg = Instance.new("TextButton")
    Bg.Size             = UDim2.new(1, 0, 0, btnH)
    Bg.BackgroundColor3 = Color3.fromRGB(32,10,10)
    Bg.BackgroundTransparency = 1
    Bg.BorderSizePixel  = 0
    Bg.Text             = ""
    Bg.AutoButtonColor  = false
    Bg.LayoutOrder      = order
    Bg.Parent           = Sidebar
    Instance.new("UICorner", Bg).CornerRadius = UDim.new(0, 7)

    local Dot = Instance.new("Frame")
    Dot.Size            = UDim2.fromOffset(3, 18)
    Dot.Position        = UDim2.fromOffset(0, btnH/2 - 9)
    Dot.BackgroundColor3 = C.Red
    Dot.BorderSizePixel = 0
    Dot.Visible         = false
    Dot.Parent          = Bg
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size            = UDim2.new(1, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3      = C.Sub
    Lbl.TextSize        = mobile and 13 or 12
    Lbl.Font            = Enum.Font.GothamMedium
    Lbl.Parent          = Bg

    if mobile then
        Lbl.Text            = icon
        Lbl.TextXAlignment  = Enum.TextXAlignment.Center
    else
        Lbl.Text            = icon .. "  " .. name
        Lbl.TextXAlignment  = Enum.TextXAlignment.Left
        local P = Instance.new("UIPadding", Bg)
        P.PaddingLeft       = UDim.new(0, 10)
    end

    Bg.MouseEnter:Connect(function()
        if curPage ~= name then tw(Bg, {BackgroundTransparency = 0.75}) end
    end)
    Bg.MouseLeave:Connect(function()
        if curPage ~= name then tw(Bg, {BackgroundTransparency = 1}) end
    end)
    Bg.MouseButton1Click:Connect(function() SetPage(name) end)

    SideBtns[name] = {Bg = Bg, Lbl = Lbl, Dot = Dot}

    local PF = Instance.new("Frame")
    PF.Size             = UDim2.new(1, 0, 0, 0)
    PF.AutomaticSize    = Enum.AutomaticSize.Y
    PF.BackgroundTransparency = 1
    PF.BorderSizePixel  = 0
    PF.Visible          = false
    PF.Parent           = Content

    local FL = Instance.new("UIListLayout", PF)
    FL.Padding          = UDim.new(0, 8)
    FL.SortOrder        = Enum.SortOrder.LayoutOrder

    Pages[name] = {Frame = PF, n = 0}
end

AddPage("Main",     "[H]", 1)
AddPage("Farm",     "[F]", 2)
AddPage("Battle",   "[B]", 3)
AddPage("Info",     "[I]", 4)
AddPage("Settings", "[S]", 5)

local function MakeCard(page, title, order)
    local d = Pages[page]
    local Card = Instance.new("Frame")
    Card.Size           = UDim2.new(1, 0, 0, 0)
    Card.AutomaticSize  = Enum.AutomaticSize.Y
    Card.BackgroundColor3 = C.Card
    Card.BorderSizePixel = 0
    Card.LayoutOrder    = order or d.n
    d.n                 = d.n + 1
    Card.Parent         = d.Frame
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 9)
    local S = Instance.new("UIStroke", Card)
    S.Color             = C.Border
    S.Thickness         = 1

    local Head = Instance.new("Frame")
    Head.Size           = UDim2.new(1, 0, 0, 38)
    Head.BackgroundTransparency = 1
    Head.Parent         = Card

    local Div = Instance.new("Frame")
    Div.Size            = UDim2.new(1, 0, 0, 1)
    Div.Position        = UDim2.new(0, 0, 1, -1)
    Div.BackgroundColor3 = C.Border
    Div.BorderSizePixel = 0
    Div.Parent          = Head

    local HT = Instance.new("TextLabel")
    HT.Size             = UDim2.new(1, -20, 1, 0)
    HT.Position         = UDim2.fromOffset(14, 0)
    HT.BackgroundTransparency = 1
    HT.Text             = title
    HT.TextColor3       = C.Text
    HT.TextSize         = 12
    HT.Font             = Enum.Font.GothamMedium
    HT.TextXAlignment   = Enum.TextXAlignment.Left
    HT.Parent           = Head

    local Body = Instance.new("Frame")
    Body.Size           = UDim2.new(1, 0, 0, 0)
    Body.AutomaticSize  = Enum.AutomaticSize.Y
    Body.BackgroundTransparency = 1
    Body.Position       = UDim2.fromOffset(0, 38)
    Body.Parent         = Card

    local BP = Instance.new("UIPadding", Body)
    BP.PaddingTop       = UDim.new(0, 6)
    BP.PaddingBottom    = UDim.new(0, 10)
    BP.PaddingLeft      = UDim.new(0, 12)
    BP.PaddingRight     = UDim.new(0, 12)

    local BL = Instance.new("UIListLayout", Body)
    BL.Padding          = UDim.new(0, 0)
    BL.SortOrder        = Enum.SortOrder.LayoutOrder

    return Body
end

local TS = {}

local function AddToggle(body, label, cb)
    local Row = Instance.new("Frame")
    Row.Size            = UDim2.new(1, 0, 0, 38)
    Row.BackgroundTransparency = 1
    Row.Parent          = body

    local Lbl = Instance.new("TextLabel")
    Lbl.Size            = UDim2.new(1, -56, 1, 0)
    Lbl.Position        = UDim2.fromOffset(0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text            = label
    Lbl.TextColor3      = C.Sub
    Lbl.TextSize        = 12
    Lbl.Font            = Enum.Font.Gotham
    Lbl.TextXAlignment  = Enum.TextXAlignment.Left
    Lbl.Parent          = Row

    local Track = Instance.new("TextButton")
    Track.Size          = UDim2.fromOffset(40, 20)
    Track.Position      = UDim2.new(1, -42, 0.5, -10)
    Track.BackgroundColor3 = C.Gray
    Track.BorderSizePixel = 0
    Track.Text          = ""
    Track.AutoButtonColor = false
    Track.Parent        = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size           = UDim2.fromOffset(14, 14)
    Knob.Position       = UDim2.fromOffset(3, 3)
    Knob.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
    Knob.BorderSizePixel = 0
    Knob.Parent         = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local state = false
    TS[label]   = false

    Track.MouseButton1Click:Connect(function()
        state     = not state
        TS[label] = state
        if state then
            tw(Track, {BackgroundColor3 = C.Red})
            tw(Knob,  {Position = UDim2.fromOffset(23, 3)})
            tw(Lbl,   {TextColor3 = C.Text})
        else
            tw(Track, {BackgroundColor3 = C.Gray})
            tw(Knob,  {Position = UDim2.fromOffset(3, 3)})
            tw(Lbl,   {TextColor3 = C.Sub})
        end
        if cb then cb(state) end
    end)

    return Track
end

local mainBody = MakeCard("Main", "Overview", 0)

local WRow = Instance.new("Frame")
WRow.Size               = UDim2.new(1, 0, 0, 50)
WRow.BackgroundColor3   = Color3.fromRGB(22, 8, 8)
WRow.BorderSizePixel    = 0
WRow.Parent             = mainBody
Instance.new("UICorner", WRow).CornerRadius = UDim.new(0, 7)

local WLbl = Instance.new("TextLabel")
WLbl.Size               = UDim2.new(1, -16, 1, 0)
WLbl.Position           = UDim2.fromOffset(12, 0)
WLbl.BackgroundTransparency = 1
WLbl.Text               = "Welcome, " .. player.DisplayName .. "!  |  Erdeva Hub is ready."
WLbl.TextColor3         = C.Text
WLbl.TextSize           = 11
WLbl.Font               = Enum.Font.Gotham
WLbl.TextXAlignment     = Enum.TextXAlignment.Left
WLbl.TextYAlignment     = Enum.TextYAlignment.Center
WLbl.TextWrapped        = true
WLbl.Parent             = WRow

local farmBody = MakeCard("Farm", "Auto Farm", 0)
AddToggle(farmBody, "Auto Open Eggs")
AddToggle(farmBody, "Auto Fuse Chickens")
AddToggle(farmBody, "Auto Grab Scraps")
AddToggle(farmBody, "Auto Recycle Scrap")
AddToggle(farmBody, "Auto Upgrade Recycler")

local plotBody = MakeCard("Farm", "Plot", 1)
AddToggle(plotBody, "Auto Rebirth")
AddToggle(plotBody, "Auto Upgrade Coop")
AddToggle(plotBody, "Auto Upgrade Feeder")
AddToggle(plotBody, "Auto Buy Feeders")

local slideBody = MakeCard("Farm", "Recycle Threshold", 2)

local SRow = Instance.new("Frame")
SRow.Size               = UDim2.new(1, 0, 0, 30)
SRow.BackgroundTransparency = 1
SRow.Parent             = slideBody

local SLbl = Instance.new("TextLabel")
SLbl.Size               = UDim2.new(1, -60, 1, 0)
SLbl.BackgroundTransparency = 1
SLbl.Text               = "Recycle when scrap:"
SLbl.TextColor3         = C.Sub
SLbl.TextSize           = 12
SLbl.Font               = Enum.Font.Gotham
SLbl.TextXAlignment     = Enum.TextXAlignment.Left
SLbl.Parent             = SRow

local SVal = Instance.new("TextLabel")
SVal.Size               = UDim2.fromOffset(52, 30)
SVal.Position           = UDim2.new(1, -52, 0, 0)
SVal.BackgroundTransparency = 1
SVal.Text               = "10 / 20"
SVal.TextColor3         = C.Red
SVal.TextSize           = 12
SVal.Font               = Enum.Font.GothamBold
SVal.TextXAlignment     = Enum.TextXAlignment.Right
SVal.Parent             = SRow

local STrack = Instance.new("Frame")
STrack.Size             = UDim2.new(1, 0, 0, 5)
STrack.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
STrack.BorderSizePixel  = 0
STrack.Parent           = slideBody
Instance.new("UICorner", STrack).CornerRadius = UDim.new(1, 0)

local SFill = Instance.new("Frame")
SFill.Size              = UDim2.new(0.5, 0, 1, 0)
SFill.BackgroundColor3  = C.Red
SFill.BorderSizePixel   = 0
SFill.Parent            = STrack
Instance.new("UICorner", SFill).CornerRadius = UDim.new(1, 0)

local SThumb = Instance.new("Frame")
SThumb.Size             = UDim2.fromOffset(16, 16)
SThumb.Position         = UDim2.new(0.5, -8, 0.5, -8)
SThumb.BackgroundColor3 = C.Red
SThumb.BorderSizePixel  = 0
SThumb.Parent           = STrack
Instance.new("UICorner", SThumb).CornerRadius = UDim.new(1, 0)
local SG = Instance.new("UIStroke", SThumb)
SG.Color                = Color3.fromRGB(255, 70, 70)
SG.Thickness            = 1.5

local sDrag = false
SThumb.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        sDrag = true
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        sDrag = false
    end
end)
UIS.InputChanged:Connect(function(i)
    if sDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local pct = math.clamp((i.Position.X - STrack.AbsolutePosition.X) / STrack.AbsoluteSize.X, 0, 1)
        SFill.Size          = UDim2.new(pct, 0, 1, 0)
        SThumb.Position     = UDim2.new(pct, -8, 0.5, -8)
        SVal.Text           = math.floor(pct * 20 + 0.5) .. " / 20"
    end
end)

local battleBody = MakeCard("Battle", "Battle", 0)
AddToggle(battleBody, "Auto Start Tower")
AddToggle(battleBody, "Auto No Thanks")
AddToggle(battleBody, "Auto Start Chaos")

local infoBody = MakeCard("Info", "Credits", 0)
local function IRow(a, b)
    local R = Instance.new("Frame")
    R.Size              = UDim2.new(1, 0, 0, 30)
    R.BackgroundTransparency = 1
    R.Parent            = infoBody
    local La = Instance.new("TextLabel", R)
    La.Size             = UDim2.new(0.55, 0, 1, 0)
    La.BackgroundTransparency = 1
    La.Text             = a
    La.TextColor3       = C.Sub
    La.TextSize         = 12
    La.Font             = Enum.Font.Gotham
    La.TextXAlignment   = Enum.TextXAlignment.Left
    local Lb = Instance.new("TextLabel", R)
    Lb.Size             = UDim2.new(0.45, 0, 1, 0)
    Lb.Position         = UDim2.new(0.55, 0, 0, 0)
    Lb.BackgroundTransparency = 1
    Lb.Text             = b
    Lb.TextColor3       = C.Red
    Lb.TextSize         = 12
    Lb.Font             = Enum.Font.GothamBold
    Lb.TextXAlignment   = Enum.TextXAlignment.Right
end
IRow("Script",  "ERDEVA HUB")
IRow("Version", "v1.0")
IRow("Game",    "Chicken Farm")
IRow("Author",  "Erdeva")

local settBody = MakeCard("Settings", "Interface", 0)
AddToggle(settBody, "Show Notifications")
AddToggle(settBody, "Sound Effects")

local dragging    = false
local dragStart   = nil
local startPos    = nil
local dragBegan   = false

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local mp = input.Position
    local tp = TopBar.AbsolutePosition
    local ts = TopBar.AbsoluteSize
    if mp.X >= tp.X and mp.X <= tp.X + ts.X and mp.Y >= tp.Y and mp.Y <= tp.Y + ts.Y then
        dragging  = true
        dragStart = mp
        startPos  = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local d = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local minimized = false
BtnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    Sidebar.Visible = not minimized
    Content.Visible = not minimized
    tw(Main, {Size = minimized and UDim2.fromOffset(W, TOP_H) or UDim2.fromOffset(W, H)}, 0.18)
end)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    W = getW()
    H = getH()
    Main.Size     = UDim2.fromOffset(W, minimized and TOP_H or H)
    Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
end)

SetPage("Main")

print("[ERDEVA HUB] Loaded")
