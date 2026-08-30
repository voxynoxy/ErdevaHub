-- ERDEVA HUB - Mobile & PC Optimized
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

pcall(function()
    if CoreGui:FindFirstChild("ERDEVA_HUB") then
        CoreGui:FindFirstChild("ERDEVA_HUB"):Destroy()
    end
end)

local Camera = workspace.CurrentCamera
local Viewport = Camera.ViewportSize

local UI_WIDTH = math.clamp(Viewport.X * 0.7, 360, 480)
local UI_HEIGHT = math.clamp(Viewport.Y * 0.75, 260, 320)

local THEME = {
    Background = Color3.fromRGB(12, 12, 12),
    TopBar     = Color3.fromRGB(18, 18, 18),
    Sidebar    = Color3.fromRGB(15, 15, 15),
    Card       = Color3.fromRGB(18, 18, 18),
    Border     = Color3.fromRGB(45, 45, 45),
    Red        = Color3.fromRGB(220, 35, 35),
    RedActive  = Color3.fromRGB(35, 12, 12),
    Text       = Color3.fromRGB(235, 235, 235),
    SubText    = Color3.fromRGB(150, 150, 150),
    ToggleOff  = Color3.fromRGB(50, 50, 50),
    ToggleOn   = Color3.fromRGB(220, 35, 35)
}

local function Tween(instance, properties, duration)
    TweenService:Create(instance, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ERDEVA_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.Size = UDim2.fromOffset(UI_WIDTH, UI_HEIGHT)
Main.Position = UDim2.new(0.5, -UI_WIDTH / 2, 0.5, -UI_HEIGHT / 2)
Main.BackgroundColor3 = THEME.Background
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.Red
MainStroke.Thickness = 1.2
MainStroke.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = THEME.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TopBarLine = Instance.new("Frame")
TopBarLine.Size = UDim2.new(1, 0, 0, 1)
TopBarLine.Position = UDim2.new(0, 0, 1, -1)
TopBarLine.BackgroundColor3 = THEME.Border
TopBarLine.BorderSizePixel = 0
TopBarLine.Parent = TopBar

local TitleAccent = Instance.new("Frame")
TitleAccent.Size = UDim2.fromOffset(3, 18)
TitleAccent.Position = UDim2.fromOffset(10, 9)
TitleAccent.BackgroundColor3 = THEME.Red
TitleAccent.BorderSizePixel = 0
TitleAccent.Parent = TopBar

local AccentCorner = Instance.new("UICorner")
AccentCorner.CornerRadius = UDim.new(1, 0)
AccentCorner.Parent = TitleAccent

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "ERDEVA HUB  <font color='#dc2323' size='11'>v1.0</font>"
Title.RichText = true
Title.TextColor3 = THEME.Text
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local function CreateHeaderButton(text, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(26, 26)
    btn.Position = UDim2.new(1, xOffset, 0.5, -13)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = THEME.SubText
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TopBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)})
    end)
    return btn
end

local CloseBtn = CreateHeaderButton("✕", -32)
local MinBtn = CreateHeaderButton("—", -62)

CloseBtn.MouseEnter:Connect(function()
    Tween(CloseBtn, {TextColor3 = THEME.Red})
end)
CloseBtn.MouseLeave:Connect(function()
    Tween(CloseBtn, {TextColor3 = THEME.SubText})
end)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetHeight = isMinimized and 36 or UI_HEIGHT
    Tween(Main, {Size = UDim2.fromOffset(UI_WIDTH, targetHeight)}, 0.2)
    Main:FindFirstChild("Sidebar").Visible = not isMinimized
    Main:FindFirstChild("ContentArea").Visible = not isMinimized
end)

local SIDEBAR_WIDTH = 110

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -36)
Sidebar.Position = UDim2.fromOffset(0, 36)
Sidebar.BackgroundColor3 = THEME.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, -1, 0, 0)
SidebarLine.BackgroundColor3 = THEME.Border
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 3)
SidebarLayout.FillDirection = Enum.FillDirection.Vertical
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 6)
SidebarPad.PaddingLeft = UDim.new(0, 5)
SidebarPad.PaddingRight = UDim.new(0, 5)
SidebarPad.Parent = Sidebar

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, -36)
ContentArea.Position = UDim2.fromOffset(SIDEBAR_WIDTH, 36)
ContentArea.BackgroundColor3 = THEME.Background
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = THEME.Red
ContentArea.CanvasSize = UDim2.fromOffset(0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.ScrollingDirection = Enum.ScrollingDirection.Y
ContentArea.Parent = Main

local ContentPad = Instance.new("UIPadding")
ContentPad.PaddingTop = UDim.new(0, 6)
ContentPad.PaddingLeft = UDim.new(0, 8)
ContentPad.PaddingRight = UDim.new(0, 8)
ContentPad.PaddingBottom = UDim.new(0, 10)
ContentPad.Parent = ContentArea

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.FillDirection = Enum.FillDirection.Vertical
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentArea

local Tabs = {}
local TabButtons = {}
local currentTab = nil

local function SwitchTab(tabName)
    if currentTab == tabName then return end
    currentTab = tabName

    for name, page in pairs(Tabs) do
        page.Visible = (name == tabName)
    end

    for name, btnData in pairs(TabButtons) do
        if name == tabName then
            Tween(btnData.Button, {BackgroundColor3 = THEME.RedActive, BackgroundTransparency = 0})
            Tween(btnData.Label, {TextColor3 = THEME.Text})
            btnData.Indicator.Visible = true
        else
            Tween(btnData.Button, {BackgroundTransparency = 1})
            Tween(btnData.Label, {TextColor3 = THEME.SubText})
            btnData.Indicator.Visible = false
        end
    end
    ContentArea.CanvasPosition = Vector2.new(0, 0)
end

local function CreateTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = THEME.RedActive
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.fromOffset(3, 16)
    indicator.Position = UDim2.fromOffset(0, 8)
    indicator.BackgroundColor3 = THEME.Red
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = btn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = THEME.SubText
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            Tween(btn, {BackgroundTransparency = 0.8})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then
            Tween(btn, {BackgroundTransparency = 1})
        end
    end)
    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)

    TabButtons[name] = {Button = btn, Label = label, Indicator = indicator}

    local pageFrame = Instance.new("Frame")
    pageFrame.Name = name .. "Page"
    pageFrame.Size = UDim2.new(1, 0, 0, 0)
    pageFrame.AutomaticSize = Enum.AutomaticSize.Y
    pageFrame.BackgroundTransparency = 1
    pageFrame.BorderSizePixel = 0
    pageFrame.Visible = false
    pageFrame.LayoutOrder = order
    pageFrame.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.FillDirection = Enum.FillDirection.Vertical
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = pageFrame

    Tabs[name] = pageFrame
    return pageFrame
end

local function CreateCard(parentPage, title)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = THEME.Card
    card.BorderSizePixel = 0
    card.Parent = parentPage

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = THEME.Border
    stroke.Thickness = 1
    stroke.Parent = card

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundTransparency = 1
    header.Parent = card

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = THEME.Border
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, -16, 1, 0)
    cardTitle.Position = UDim2.fromOffset(8, 0)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = title
    cardTitle.TextColor3 = THEME.Text
    cardTitle.TextSize = 11
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = header

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Position = UDim2.fromOffset(0, 28)
    container.BackgroundTransparency = 1
    container.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    return container
end

local function CreateToggle(parentContainer, labelText, defaultState, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.Parent = parentContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -48, 1, 0)
    label.Position = UDim2.fromOffset(2, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.SubText
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.fromOffset(36, 18)
    toggleBtn.Position = UDim2.new(1, -38, 0.5, -9)
    toggleBtn.BackgroundColor3 = THEME.ToggleOff
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBtn

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = defaultState or false

    local function updateState()
        if state then
            Tween(toggleBtn, {BackgroundColor3 = THEME.ToggleOn})
            Tween(knob, {Position = UDim2.fromOffset(20, 2)})
            Tween(label, {TextColor3 = THEME.Text})
        else
            Tween(toggleBtn, {BackgroundColor3 = THEME.ToggleOff})
            Tween(knob, {Position = UDim2.fromOffset(2, 2)})
            Tween(label, {TextColor3 = THEME.SubText})
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        updateState()
        if callback then
            callback(state)
        end
    end)

    if state then
        updateState()
    end

    return toggleBtn
end

local function CreateSlider(parentContainer, labelText, minVal, maxVal, defaultVal, callback)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 38)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parentContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 16)
    label.Position = UDim2.fromOffset(2, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.SubText
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrapper

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.fromOffset(50, 16)
    valueLabel.Position = UDim2.new(1, -52, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal) .. "/" .. tostring(maxVal)
    valueLabel.TextColor3 = THEME.Red
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = wrapper

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -4, 0, 4)
    sliderTrack.Position = UDim2.fromOffset(2, 22)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = wrapper

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack

    local sliderFill = Instance.new("Frame")
    local initRatio = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    sliderFill.Size = UDim2.new(initRatio, 0, 1, 0)
    sliderFill.BackgroundColor3 = THEME.Red
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.fromOffset(12, 12)
    thumb.Position = UDim2.new(initRatio, -6, 0.5, -6)
    thumb.BackgroundColor3 = THEME.Red
    thumb.BorderSizePixel = 0
    thumb.Parent = sliderTrack

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local isDraggingSlider = false

    local function updateSlider(inputX)
        local trackPos = sliderTrack.AbsolutePosition.X
        local trackWidth = sliderTrack.AbsoluteSize.X
        local ratio = math.clamp((inputX - trackPos) / trackWidth, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * ratio + 0.5)

        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        thumb.Position = UDim2.new(ratio, -6, 0.5, -6)
        valueLabel.Text = tostring(value) .. "/" .. tostring(maxVal)

        if callback then
            callback(value)
        end
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSlider = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingSlider = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)
end

--==================================================
-- PAGES SETUP
--==================================================

local FarmPage = CreateTab("Farm", 1)
local PlotPage = CreateTab("Plot", 2)
local BattlePage = CreateTab("Battle", 3)
local InfoPage = CreateTab("Info", 4)

-- Farm Card
local farmCard = CreateCard(FarmPage, "Auto Farm")
CreateToggle(farmCard, "Auto Open Eggs", false)
CreateToggle(farmCard, "Auto Fuse Chickens", false)
CreateToggle(farmCard, "Auto Grab Scraps", false)
CreateToggle(farmCard, "Auto Recycle Scrap", false)
CreateToggle(farmCard, "Auto Upgrade Recycler", false)
CreateSlider(farmCard, "Recycle threshold", 1, 20, 10)

-- Plot Card
local plotCard = CreateCard(PlotPage, "Plot Upgrades")
CreateToggle(plotCard, "Auto Rebirth", false)
CreateToggle(plotCard, "Auto Upgrade Coop", false)
CreateToggle(plotCard, "Auto Upgrade Feeder", false)
CreateToggle(plotCard, "Auto Buy Feeders", false)

-- Battle Card
local battleCard = CreateCard(BattlePage, "Battle Mode")
CreateToggle(battleCard, "Auto Start Tower", false)
CreateToggle(battleCard, "Auto No Thanks", false)
CreateToggle(battleCard, "Auto Start Chaos", false)

-- Info Card
local infoCard = CreateCard(InfoPage, "Information")
local function AddInfoLine(name, val)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.Parent = infoCard

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = THEME.SubText
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = row

    local r = Instance.new("TextLabel")
    r.Size = UDim2.new(0.5, 0, 1, 0)
    r.Position = UDim2.new(0.5, 0, 0, 0)
    r.BackgroundTransparency = 1
    r.Text = val
    r.TextColor3 = THEME.Red
    r.TextSize = 11
    r.Font = Enum.Font.GothamBold
    r.TextXAlignment = Enum.TextXAlignment.Right
    r.Parent = row
end

AddInfoLine("Script", "ERDEVA HUB")
AddInfoLine("Game", "Chicken Farm")
AddInfoLine("User", player.DisplayName)
AddInfoLine("Status", "Active")

--==================================================
-- DRAG LOGIC (MOBILE & PC)
--==================================================

local isDragging = false
local dragStartPos = nil
local startFramePos = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPos = input.Position
        startFramePos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        Main.Position = UDim2.new(
            startFramePos.X.Scale,
            startFramePos.X.Offset + delta.X,
            startFramePos.Y.Scale,
            startFramePos.Y.Offset + delta.Y
        )
    end
end)

-- Default open Farm tab directly so user sees features immediately
SwitchTab("Farm")

print("[ERDEVA HUB] Loaded successfully!")
