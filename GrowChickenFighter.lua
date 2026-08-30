local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local CoreGui     = game:GetService("CoreGui")
local TweenSvc    = game:GetService("TweenService")

local player = Players.LocalPlayer

pcall(function()
    local o = CoreGui:FindFirstChild("ERDEVA_HUB")
    if o then o:Destroy() end
end)

local C = {
    Bg      = Color3.fromRGB(11, 11, 11),
    TopBar  = Color3.fromRGB(16, 16, 16),
    TabBar  = Color3.fromRGB(13, 13, 13),
    Card    = Color3.fromRGB(17, 17, 17),
    Border  = Color3.fromRGB(38, 38, 38),
    Red     = Color3.fromRGB(218, 35, 35),
    Text    = Color3.fromRGB(228, 228, 228),
    Sub     = Color3.fromRGB(135, 135, 135),
    Off     = Color3.fromRGB(52, 52, 52),
    TabOn   = Color3.fromRGB(30, 10, 10),
    TabOff  = Color3.fromRGB(13, 13, 13),
}

local function tw(o, p, t)
    TweenSvc:Create(o, TweenInfo.new(t or 0.13, Enum.EasingStyle.Quad), p):Play()
end

local Gui = Instance.new("ScreenGui")
Gui.Name           = "ERDEVA_HUB"
Gui.ResetOnSpawn   = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder   = 999
Gui.Parent         = CoreGui

local Main = Instance.new("Frame")
Main.AnchorPoint      = Vector2.new(0.5, 0.5)
Main.Size             = UDim2.new(0.94, 0, 0.88, 0)
Main.Position         = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Main.Parent           = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MS = Instance.new("UIStroke", Main)
MS.Color     = C.Red
MS.Thickness = 1

local TOP_H = 44
local TAB_H = 36

local TopBar = Instance.new("Frame")
TopBar.Size             = UDim2.new(1, 0, 0, TOP_H)
TopBar.BackgroundColor3 = C.TopBar
TopBar.BorderSizePixel  = 0
TopBar.Parent           = Main

local TDiv = Instance.new("Frame")
TDiv.Size              = UDim2.new(1, 0, 0, 1)
TDiv.Position          = UDim2.new(0, 0, 1, -1)
TDiv.BackgroundColor3  = C.Border
TDiv.BorderSizePixel   = 0
TDiv.Parent            = TopBar

local TAcc = Instance.new("Frame")
TAcc.Size              = UDim2.fromOffset(3, 20)
TAcc.Position          = UDim2.fromOffset(12, 12)
TAcc.BackgroundColor3  = C.Red
TAcc.BorderSizePixel   = 0
TAcc.Parent            = TopBar
Instance.new("UICorner", TAcc).CornerRadius = UDim.new(1, 0)

local TTitle = Instance.new("TextLabel")
TTitle.Size             = UDim2.fromOffset(220, TOP_H)
TTitle.Position         = UDim2.fromOffset(22, -5)
TTitle.BackgroundTransparency = 1
TTitle.Text             = "ERDEVA HUB"
TTitle.TextColor3       = C.Text
TTitle.TextSize         = 15
TTitle.Font             = Enum.Font.GothamBold
TTitle.TextXAlignment   = Enum.TextXAlignment.Left
TTitle.Parent           = TopBar

local TSub = Instance.new("TextLabel")
TSub.Size               = UDim2.fromOffset(220, TOP_H)
TSub.Position           = UDim2.fromOffset(22, 15)
TSub.BackgroundTransparency = 1
TSub.Text               = "v1.0  Chicken Farm"
TSub.TextColor3         = C.Red
TSub.TextSize           = 9
TSub.Font               = Enum.Font.Gotham
TSub.TextXAlignment     = Enum.TextXAlignment.Left
TSub.Parent             = TopBar

local function MkBtn(txt, rp)
    local B = Instance.new("TextButton")
    B.Size             = UDim2.fromOffset(28, 28)
    B.Position         = UDim2.new(1, -rp, 0.5, -14)
    B.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    B.BorderSizePixel  = 0
    B.Text             = txt
    B.TextColor3       = C.Sub
    B.TextSize         = 13
    B.Font             = Enum.Font.GothamBold
    B.AutoButtonColor  = false
    B.Parent           = TopBar
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    B.MouseEnter:Connect(function() tw(B, {BackgroundColor3 = Color3.fromRGB(40,40,40)}) end)
    B.MouseLeave:Connect(function() tw(B, {BackgroundColor3 = Color3.fromRGB(26,26,26)}) end)
    return B
end

local BClose = MkBtn("x", 10)
local BMin   = MkBtn("-", 44)
BClose.MouseEnter:Connect(function() tw(BClose, {TextColor3 = C.Red}) end)
BClose.MouseLeave:Connect(function() tw(BClose, {TextColor3 = C.Sub}) end)
BClose.MouseButton1Click:Connect(function() Gui:Destroy() end)

local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(1, 0, 0, TAB_H)
TabBar.Position         = UDim2.fromOffset(0, TOP_H)
TabBar.BackgroundColor3 = C.TabBar
TabBar.BorderSizePixel  = 0
TabBar.Parent           = Main

local TabDiv = Instance.new("Frame")
TabDiv.Size             = UDim2.new(1, 0, 0, 1)
TabDiv.Position         = UDim2.new(0, 0, 1, -1)
TabDiv.BackgroundColor3 = C.Border
TabDiv.BorderSizePixel  = 0
TabDiv.Parent           = TabBar

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
TabLayout.Padding       = UDim.new(0, 0)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size              = UDim2.new(1, 0, 1, -(TOP_H + TAB_H))
Scroll.Position          = UDim2.fromOffset(0, TOP_H + TAB_H)
Scroll.BackgroundColor3  = C.Bg
Scroll.BorderSizePixel   = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = C.Red
Scroll.CanvasSize        = UDim2.fromOffset(0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.Parent            = Main

local ScrPad = Instance.new("UIPadding", Scroll)
ScrPad.PaddingTop    = UDim.new(0, 8)
ScrPad.PaddingLeft   = UDim.new(0, 8)
ScrPad.PaddingRight  = UDim.new(0, 8)
ScrPad.PaddingBottom = UDim.new(0, 14)

local ScrLayout = Instance.new("UIListLayout", Scroll)
ScrLayout.Padding    = UDim.new(0, 8)
ScrLayout.SortOrder  = Enum.SortOrder.LayoutOrder

local Pages   = {}
local Tabs    = {}
local curPage = nil
local TAB_NAMES = {"Main", "Farm", "Battle", "Info", "Settings"}
local TAB_COUNT = #TAB_NAMES

for i, name in ipairs(TAB_NAMES) do
    local PF = Instance.new("Frame")
    PF.Size              = UDim2.new(1, 0, 0, 0)
    PF.AutomaticSize     = Enum.AutomaticSize.Y
    PF.BackgroundTransparency = 1
    PF.BorderSizePixel   = 0
    PF.Visible           = false
    PF.LayoutOrder       = i
    PF.Parent            = Scroll

    local FL = Instance.new("UIListLayout", PF)
    FL.Padding           = UDim.new(0, 8)
    FL.SortOrder         = Enum.SortOrder.LayoutOrder

    Pages[name] = {Frame = PF, n = 0}

    local TB = Instance.new("TextButton")
    TB.Size              = UDim2.new(1/TAB_COUNT, 0, 1, 0)
    TB.BackgroundColor3  = C.TabOff
    TB.BorderSizePixel   = 0
    TB.Text              = name
    TB.TextColor3        = C.Sub
    TB.TextSize          = 11
    TB.Font              = Enum.Font.GothamMedium
    TB.AutoButtonColor   = false
    TB.LayoutOrder       = i
    TB.Parent            = TabBar

    local TBLine = Instance.new("Frame")
    TBLine.Name          = "Line"
    TBLine.Size          = UDim2.new(1, 0, 0, 2)
    TBLine.Position      = UDim2.new(0, 0, 1, -2)
    TBLine.BackgroundColor3 = C.TabBar
    TBLine.BorderSizePixel  = 0
    TBLine.Parent           = TB

    Tabs[name] = {Btn = TB, Line = TBLine}

    TB.MouseButton1Click:Connect(function()
        if curPage == name then return end
        if curPage then
            Pages[curPage].Frame.Visible = false
            tw(Tabs[curPage].Btn,  {BackgroundColor3 = C.TabOff, TextColor3 = C.Sub})
            tw(Tabs[curPage].Line, {BackgroundColor3 = C.TabBar})
        end
        Pages[name].Frame.Visible = true
        tw(TB,     {BackgroundColor3 = C.TabOn, TextColor3 = C.Text})
        tw(TBLine, {BackgroundColor3 = C.Red})
        Scroll.CanvasPosition = Vector2.new(0, 0)
        curPage = name
    end)
end

local function Card(page, title, order)
    local d = Pages[page]
    local F = Instance.new("Frame")
    F.Size             = UDim2.new(1, 0, 0, 0)
    F.AutomaticSize    = Enum.AutomaticSize.Y
    F.BackgroundColor3 = C.Card
    F.BorderSizePixel  = 0
    F.LayoutOrder      = order or d.n
    d.n = d.n + 1
    F.Parent           = d.Frame
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
    local St = Instance.new("UIStroke", F)
    St.Color     = C.Border
    St.Thickness = 1

    local Head = Instance.new("Frame")
    Head.Size            = UDim2.new(1, 0, 0, 36)
    Head.BackgroundTransparency = 1
    Head.Parent          = F

    local HDiv = Instance.new("Frame")
    HDiv.Size            = UDim2.new(1, 0, 0, 1)
    HDiv.Position        = UDim2.new(0, 0, 1, -1)
    HDiv.BackgroundColor3 = C.Border
    HDiv.BorderSizePixel  = 0
    HDiv.Parent           = Head

    local HLine = Instance.new("Frame")
    HLine.Size           = UDim2.fromOffset(3, 18)
    HLine.Position       = UDim2.fromOffset(10, 9)
    HLine.BackgroundColor3 = C.Red
    HLine.BorderSizePixel  = 0
    HLine.Parent           = Head
    Instance.new("UICorner", HLine).CornerRadius = UDim.new(1, 0)

    local HT = Instance.new("TextLabel")
    HT.Size              = UDim2.new(1, -30, 1, 0)
    HT.Position          = UDim2.fromOffset(20, 0)
    HT.BackgroundTransparency = 1
    HT.Text              = title
    HT.TextColor3        = C.Text
    HT.TextSize          = 12
    HT.Font              = Enum.Font.GothamMedium
    HT.TextXAlignment    = Enum.TextXAlignment.Left
    HT.Parent            = Head

    local Body = Instance.new("Frame")
    Body.Size            = UDim2.new(1, 0, 0, 0)
    Body.AutomaticSize   = Enum.AutomaticSize.Y
    Body.BackgroundTransparency = 1
    Body.Position        = UDim2.fromOffset(0, 36)
    Body.Parent          = F

    local BP = Instance.new("UIPadding", Body)
    BP.PaddingTop    = UDim.new(0, 6)
    BP.PaddingBottom = UDim.new(0, 10)
    BP.PaddingLeft   = UDim.new(0, 12)
    BP.PaddingRight  = UDim.new(0, 12)

    local BL = Instance.new("UIListLayout", Body)
    BL.Padding   = UDim.new(0, 0)
    BL.SortOrder = Enum.SortOrder.LayoutOrder

    return Body
end

local function Toggle(body, label, cb)
    local Row = Instance.new("Frame")
    Row.Size             = UDim2.new(1, 0, 0, 38)
    Row.BackgroundTransparency = 1
    Row.Parent           = body

    local Lbl = Instance.new("TextLabel")
    Lbl.Size             = UDim2.new(1, -54, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text             = label
    Lbl.TextColor3       = C.Sub
    Lbl.TextSize         = 12
    Lbl.Font             = Enum.Font.Gotham
    Lbl.TextXAlignment   = Enum.TextXAlignment.Left
    Lbl.Parent           = Row

    local Track = Instance.new("TextButton")
    Track.Size           = UDim2.fromOffset(38, 20)
    Track.Position       = UDim2.new(1, -40, 0.5, -10)
    Track.BackgroundColor3 = C.Off
    Track.BorderSizePixel  = 0
    Track.Text           = ""
    Track.AutoButtonColor = false
    Track.Parent         = Row
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size            = UDim2.fromOffset(14, 14)
    Knob.Position        = UDim2.fromOffset(3, 3)
    Knob.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
    Knob.BorderSizePixel  = 0
    Knob.Parent          = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local Div = Instance.new("Frame")
    Div.Size             = UDim2.new(1, 0, 0, 1)
    Div.Position         = UDim2.new(0, 0, 1, -1)
    Div.BackgroundColor3 = C.Border
    Div.BorderSizePixel  = 0
    Div.Parent           = Row

    local on = false
    Track.MouseButton1Click:Connect(function()
        on = not on
        if on then
            tw(Track, {BackgroundColor3 = C.Red})
            tw(Knob,  {Position = UDim2.fromOffset(21, 3)})
            tw(Lbl,   {TextColor3 = C.Text})
        else
            tw(Track, {BackgroundColor3 = C.Off})
            tw(Knob,  {Position = UDim2.fromOffset(3, 3)})
            tw(Lbl,   {TextColor3 = C.Sub})
        end
        if cb then cb(on) end
    end)
end

local mainBody = Card("Main", "Overview", 0)
local WRow = Instance.new("Frame")
WRow.Size             = UDim2.new(1, 0, 0, 50)
WRow.BackgroundColor3 = Color3.fromRGB(22, 8, 8)
WRow.BorderSizePixel  = 0
WRow.Parent           = mainBody
Instance.new("UICorner", WRow).CornerRadius = UDim.new(0, 7)
local WL = Instance.new("TextLabel")
WL.Size               = UDim2.new(1, -16, 1, 0)
WL.Position           = UDim2.fromOffset(12, 0)
WL.BackgroundTransparency = 1
WL.Text               = "Welcome, " .. player.DisplayName .. "!  Erdeva Hub is ready."
WL.TextColor3         = C.Text
WL.TextSize           = 11
WL.Font               = Enum.Font.Gotham
WL.TextXAlignment     = Enum.TextXAlignment.Left
WL.TextYAlignment     = Enum.TextYAlignment.Center
WL.TextWrapped        = true
WL.Parent             = WRow

local farmBody = Card("Farm", "Auto Farm", 0)
Toggle(farmBody, "Auto Open Eggs")
Toggle(farmBody, "Auto Fuse Chickens")
Toggle(farmBody, "Auto Grab Scraps")
Toggle(farmBody, "Auto Recycle Scrap")
Toggle(farmBody, "Auto Upgrade Recycler")

local plotBody = Card("Farm", "Plot", 1)
Toggle(plotBody, "Auto Rebirth")
Toggle(plotBody, "Auto Upgrade Coop")
Toggle(plotBody, "Auto Upgrade Feeder")
Toggle(plotBody, "Auto Buy Feeders")

local slideBody = Card("Farm", "Recycle Threshold", 2)

local SR = Instance.new("Frame")
SR.Size               = UDim2.new(1, 0, 0, 30)
SR.BackgroundTransparency = 1
SR.Parent             = slideBody

local SL = Instance.new("TextLabel")
SL.Size               = UDim2.new(1, -58, 1, 0)
SL.BackgroundTransparency = 1
SL.Text               = "Recycle when scrap:"
SL.TextColor3         = C.Sub
SL.TextSize           = 12
SL.Font               = Enum.Font.Gotham
SL.TextXAlignment     = Enum.TextXAlignment.Left
SL.Parent             = SR

local SV = Instance.new("TextLabel")
SV.Size               = UDim2.fromOffset(50, 30)
SV.Position           = UDim2.new(1, -50, 0, 0)
SV.BackgroundTransparency = 1
SV.Text               = "10 / 20"
SV.TextColor3         = C.Red
SV.TextSize           = 12
SV.Font               = Enum.Font.GothamBold
SV.TextXAlignment     = Enum.TextXAlignment.Right
SV.Parent             = SR

local STr = Instance.new("Frame")
STr.Size              = UDim2.new(1, 0, 0, 5)
STr.BackgroundColor3  = Color3.fromRGB(40, 40, 40)
STr.BorderSizePixel   = 0
STr.Parent            = slideBody
Instance.new("UICorner", STr).CornerRadius = UDim.new(1, 0)

local SFl = Instance.new("Frame")
SFl.Size              = UDim2.new(0.5, 0, 1, 0)
SFl.BackgroundColor3  = C.Red
SFl.BorderSizePixel   = 0
SFl.Parent            = STr
Instance.new("UICorner", SFl).CornerRadius = UDim.new(1, 0)

local STh = Instance.new("Frame")
STh.Size              = UDim2.fromOffset(15, 15)
STh.Position          = UDim2.new(0.5, -7, 0.5, -7)
STh.BackgroundColor3  = C.Red
STh.BorderSizePixel   = 0
STh.Parent            = STr
Instance.new("UICorner", STh).CornerRadius = UDim.new(1, 0)
local SG = Instance.new("UIStroke", STh)
SG.Color              = Color3.fromRGB(255, 70, 70)
SG.Thickness          = 1.5

local sld = false
STh.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sld = true end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sld = false end
end)
UIS.InputChanged:Connect(function(i)
    if sld and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local p = math.clamp((i.Position.X - STr.AbsolutePosition.X) / STr.AbsoluteSize.X, 0, 1)
        SFl.Size     = UDim2.new(p, 0, 1, 0)
        STh.Position = UDim2.new(p, -7, 0.5, -7)
        SV.Text      = math.floor(p * 20 + 0.5) .. " / 20"
    end
end)

local battleBody = Card("Battle", "Battle", 0)
Toggle(battleBody, "Auto Start Tower")
Toggle(battleBody, "Auto No Thanks")
Toggle(battleBody, "Auto Start Chaos")

local infoBody = Card("Info", "Credits", 0)
local function IR(a, b)
    local R = Instance.new("Frame")
    R.Size              = UDim2.new(1, 0, 0, 32)
    R.BackgroundTransparency = 1
    R.Parent            = infoBody
    local La = Instance.new("TextLabel", R)
    La.Size             = UDim2.new(0.5, 0, 1, 0)
    La.BackgroundTransparency = 1
    La.Text             = a
    La.TextColor3       = C.Sub
    La.TextSize         = 12
    La.Font             = Enum.Font.Gotham
    La.TextXAlignment   = Enum.TextXAlignment.Left
    local Lb = Instance.new("TextLabel", R)
    Lb.Size             = UDim2.new(0.5, 0, 1, 0)
    Lb.Position         = UDim2.new(0.5, 0, 0, 0)
    Lb.BackgroundTransparency = 1
    Lb.Text             = b
    Lb.TextColor3       = C.Red
    Lb.TextSize         = 12
    Lb.Font             = Enum.Font.GothamBold
    Lb.TextXAlignment   = Enum.TextXAlignment.Right
end
IR("Script",  "ERDEVA HUB")
IR("Version", "v1.0")
IR("Game",    "Chicken Farm")
IR("Author",  "Erdeva")

local settBody = Card("Settings", "Interface", 0)
Toggle(settBody, "Show Notifications")
Toggle(settBody, "Sound Effects")

local dragging  = false
local dragStart = nil
local dragPos   = nil

UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    local t = inp.UserInputType
    if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
    local mp = inp.Position
    local tp = TopBar.AbsolutePosition
    local ts = TopBar.AbsoluteSize
    if mp.X >= tp.X and mp.X <= tp.X + ts.X and mp.Y >= tp.Y and mp.Y <= tp.Y + ts.Y then
        dragging  = true
        dragStart = mp
        dragPos   = Main.Position
    end
end)

UIS.InputChanged:Connect(function(inp)
    if not dragging then return end
    local t = inp.UserInputType
    if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
    local d = inp.Position - dragStart
    Main.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + d.X, dragPos.Y.Scale, dragPos.Y.Offset + d.Y)
end)

UIS.InputEnded:Connect(function(inp)
    local t = inp.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local minimized = false
BMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    TabBar.Visible  = not minimized
    Scroll.Visible  = not minimized
    if minimized then
        tw(Main, {Size = UDim2.new(0.94, 0, 0, TOP_H)}, 0.18)
    else
        tw(Main, {Size = UDim2.new(0.94, 0, 0.88, 0)}, 0.18)
    end
end)

Tabs["Main"].Btn:MouseButton1Click()

print("[ERDEVA HUB] Loaded")
