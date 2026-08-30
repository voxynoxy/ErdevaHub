local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

pcall(function()
    if CoreGui:FindFirstChild("ERDEVA_HUB") then
        CoreGui:FindFirstChild("ERDEVA_HUB"):Destroy()
    end
end)

local Camera = Workspace.CurrentCamera
local Viewport = Camera.ViewportSize

local isSmallScreen = Viewport.X < 600
local UI_W = isSmallScreen and math.min(Viewport.X - 30, 440) or 480
local UI_H = isSmallScreen and math.min(Viewport.Y - 40, 280) or 300

local THEME = {
    Bg        = Color3.fromRGB(13, 13, 13),
    TopBar    = Color3.fromRGB(20, 20, 20),
    TabBar    = Color3.fromRGB(16, 16, 16),
    TabOn     = Color3.fromRGB(35, 12, 12),
    Card      = Color3.fromRGB(18, 18, 18),
    Border    = Color3.fromRGB(45, 45, 45),
    Red       = Color3.fromRGB(225, 35, 35),
    Text      = Color3.fromRGB(235, 235, 235),
    Sub       = Color3.fromRGB(150, 150, 150),
    ToggleOff = Color3.fromRGB(55, 55, 55),
    ToggleOn  = Color3.fromRGB(225, 35, 35)
}

local function Tween(obj, props, dur)
    TweenService:Create(obj, TweenInfo.new(dur or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- ==================== UI SETUP ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ERDEVA_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.Size = UDim2.fromOffset(UI_W, UI_H)
Main.Position = UDim2.new(0.5, -UI_W / 2, 0.5, -UI_H / 2)
Main.BackgroundColor3 = THEME.Bg
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.Red
MainStroke.Thickness = 1.2
MainStroke.Parent = Main

-- TOPBAR
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = THEME.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = THEME.Border
TopLine.BorderSizePixel = 0
TopLine.Parent = TopBar

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
Title.Text = "ERDEVA HUB  <font color='#e12323' size='11'>v1.0</font>"
Title.RichText = true
Title.TextColor3 = THEME.Text
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local function CreateTopBtn(text, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(24, 24)
    btn.Position = UDim2.new(1, xOffset, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = THEME.Sub
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TopBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
    end)
    return btn
end

local CloseBtn = CreateTopBtn("✕", -30)
local MinBtn = CreateTopBtn("—", -58)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Main:FindFirstChild("TabBar").Visible = not isMinimized
    Main:FindFirstChild("ContentArea").Visible = not isMinimized
    Tween(Main, {Size = UDim2.fromOffset(UI_W, isMinimized and 36 or UI_H)}, 0.15)
end)

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.Position = UDim2.fromOffset(0, 36)
TabBar.BackgroundColor3 = THEME.TabBar
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TabBarLine = Instance.new("Frame")
TabBarLine.Size = UDim2.new(1, 0, 0, 1)
TabBarLine.Position = UDim2.new(0, 0, 1, -1)
TabBarLine.BackgroundColor3 = THEME.Border
TabBarLine.BorderSizePixel = 0
TabBarLine.Parent = TabBar

-- CONTENT SCROLL AREA
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, 0, 1, -68)
ContentArea.Position = UDim2.fromOffset(0, 68)
ContentArea.BackgroundColor3 = THEME.Bg
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = THEME.Red
ContentArea.ScrollingDirection = Enum.ScrollingDirection.Y
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.Parent = Main

local ContentPad = Instance.new("UIPadding")
ContentPad.PaddingTop = UDim.new(0, 8)
ContentPad.PaddingLeft = UDim.new(0, 8)
ContentPad.PaddingRight = UDim.new(0, 8)
ContentPad.PaddingBottom = UDim.new(0, 12)
ContentPad.Parent = ContentArea

-- ==================== TAB SYSTEM ====================
local Tabs = {}
local TabBtns = {}
local currentTab = nil

local TAB_NAMES = {"Farm", "Plot", "Battle", "Info"}

local function SwitchTab(tabName)
    if currentTab == tabName then return end
    currentTab = tabName

    for name, page in pairs(Tabs) do
        page.Visible = (name == tabName)
    end

    for name, btnData in pairs(TabBtns) do
        if name == tabName then
            Tween(btnData.Button, {BackgroundColor3 = THEME.TabOn, TextColor3 = THEME.Text})
            btnData.Indicator.Visible = true
        else
            Tween(btnData.Button, {BackgroundColor3 = THEME.TabBar, TextColor3 = THEME.Sub})
            btnData.Indicator.Visible = false
        end
    end

    local activePage = Tabs[tabName]
    if activePage and activePage:FindFirstChild("UIListLayout") then
        local layout = activePage.UIListLayout
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end
    ContentArea.CanvasPosition = Vector2.new(0, 0)
end

for idx, name in ipairs(TAB_NAMES) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "TabBtn"
    tabBtn.Size = UDim2.new(1 / #TAB_NAMES, 0, 1, 0)
    tabBtn.BackgroundColor3 = THEME.TabBar
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = THEME.Sub
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.AutoButtonColor = false
    tabBtn.LayoutOrder = idx
    tabBtn.Parent = TabBar

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(1, 0, 0, 2)
    ind.Position = UDim2.new(0, 0, 1, -2)
    ind.BackgroundColor3 = THEME.Red
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.Parent = tabBtn

    TabBtns[name] = {Button = tabBtn, Indicator = ind}

    local pageFrame = Instance.new("Frame")
    pageFrame.Name = name .. "Page"
    pageFrame.Size = UDim2.new(1, 0, 1, 0)
    pageFrame.BackgroundTransparency = 1
    pageFrame.BorderSizePixel = 0
    pageFrame.Visible = false
    pageFrame.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.FillDirection = Enum.FillDirection.Vertical
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = pageFrame

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if currentTab == name then
            ContentArea.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 24)
        end
    end)

    Tabs[name] = pageFrame

    tabBtn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

-- ==================== UI BUILDERS ====================
local function CreateCard(parentPage, title)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
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
    header.Size = UDim2.new(1, 0, 0, 26)
    header.BackgroundTransparency = 1
    header.Parent = card

    local hLine = Instance.new("Frame")
    hLine.Size = UDim2.new(1, 0, 0, 1)
    hLine.Position = UDim2.new(0, 0, 1, -1)
    hLine.BackgroundColor3 = THEME.Border
    hLine.BorderSizePixel = 0
    hLine.Parent = header

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
    container.Position = UDim2.fromOffset(0, 26)
    container.Size = UDim2.new(1, 0, 0, 0)
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

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 10)
        card.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 36)
    end)

    return container
end

local function CreateToggle(parentContainer, labelText, defaultState, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = parentContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 1, 0)
    label.Position = UDim2.fromOffset(2, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.Sub
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
            Tween(label, {TextColor3 = THEME.Sub})
        end
    end

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        updateState()
        if callback then callback(state) end
    end)

    if state then updateState() end
    return toggleBtn
end

local function CreateSlider(parentContainer, labelText, minVal, maxVal, defaultVal, callback)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 36)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parentContainer

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 16)
    label.Position = UDim2.fromOffset(2, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = THEME.Sub
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

        if callback then callback(value) end
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

-- ==================== FARM FEATURES ====================
local farmState = {
    autoOpenEggs = false,
    autoFuseChickens = false,
    autoGrabScraps = false,
    autoRecycleScrap = false,
    autoUpgradeRecycler = false,
    recycleThreshold = 10
}

-- Find relevant game objects
local function findEggs()
    local eggs = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (obj.Name:lower():find("egg") or obj.Name:lower():find("egg%_")) then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                table.insert(eggs, obj)
            end
        end
    end
    return eggs
end

local function findChickens()
    local chickens = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (obj.Name:lower():find("chicken") or obj.Name:lower():find("hen") or obj.Name:lower():find("rooster")) then
            if obj:IsA("Model") then
                table.insert(chickens, obj)
            end
        end
    end
    return chickens
end

local function findScraps()
    local scraps = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (obj.Name:lower():find("scrap") or obj.Name:lower():find("trash") or obj.Name:lower():find("debris")) then
            if obj:IsA("BasePart") then
                table.insert(scraps, obj)
            end
        end
    end
    return scraps
end

local function findRecycler()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (obj.Name:lower():find("recycler") or obj.Name:lower():find("recycle")) then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                return obj
            end
        end
    end
    return nil
end

local function findFeeder()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("feeder") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                return obj
            end
        end
    end
    return nil
end

local function findCoop()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("coop") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                return obj
            end
        end
    end
    return nil
end

-- Auto Open Eggs
local function autoOpenEggs()
    if not farmState.autoOpenEggs then return end
    
    local eggs = findEggs()
    for _, egg in pairs(eggs) do
        if egg:IsA("Model") then
            local clickDetector = egg:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                task.wait(0.2)
            end
        elseif egg:IsA("BasePart") then
            local clickDetector = egg:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                task.wait(0.2)
            end
        end
    end
end

-- Auto Fuse Chickens
local function autoFuseChickens()
    if not farmState.autoFuseChickens then return end
    
    local chickens = findChickens()
    for _, chicken in pairs(chickens) do
        -- Look for fuse button or click detector on chickens
        local fuseBtn = chicken:FindFirstChild("FuseButton")
        if fuseBtn and fuseBtn:IsA("ClickDetector") then
            fireclickdetector(fuseBtn)
            task.wait(0.3)
        end
    end
end

-- Auto Grab Scraps
local function autoGrabScraps()
    if not farmState.autoGrabScraps then return end
    
    local scraps = findScraps()
    for _, scrap in pairs(scraps) do
        if scrap:IsA("BasePart") then
            local clickDetector = scrap:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                task.wait(0.15)
            end
        end
    end
end

-- Auto Recycle Scrap
local function autoRecycleScrap()
    if not farmState.autoRecycleScrap then return end
    
    local recycler = findRecycler()
    if recycler then
        local clickDetector = recycler:FindFirstChild("ClickDetector")
        if clickDetector then
            fireclickdetector(clickDetector)
            task.wait(0.3)
        end
    end
end

-- Auto Upgrade Recycler
local function autoUpgradeRecycler()
    if not farmState.autoUpgradeRecycler then return end
    
    local recycler = findRecycler()
    if recycler then
        local upgradeBtn = recycler:FindFirstChild("UpgradeButton")
        if upgradeBtn and upgradeBtn:IsA("ClickDetector") then
            fireclickdetector(upgradeBtn)
            task.wait(0.5)
        end
    end
end

-- ==================== PLOT FEATURES ====================
local plotState = {
    autoRebirth = false,
    autoUpgradeCoop = false,
    autoUpgradeFeeder = false,
    autoBuyFeeders = false
}

-- Auto Rebirth
local function autoRebirth()
    if not plotState.autoRebirth then return end
    
    -- Look for rebirth button or trigger
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (obj.Name:lower():find("rebirth") or obj.Name:lower():find("prestige")) then
            local clickDetector = obj:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                task.wait(0.5)
                break
            end
        end
    end
end

-- Auto Upgrade Coop
local function autoUpgradeCoop()
    if not plotState.autoUpgradeCoop then return end
    
    local coop = findCoop()
    if coop then
        local upgradeBtn = coop:FindFirstChild("UpgradeButton")
        if upgradeBtn and upgradeBtn:IsA("ClickDetector") then
            fireclickdetector(upgradeBtn)
            task.wait(0.3)
        end
    end
end

-- Auto Upgrade Feeder
local function autoUpgradeFeeder()
    if not plotState.autoUpgradeFeeder then return end
    
    local feeder = findFeeder()
    if feeder then
        local upgradeBtn = feeder:FindFirstChild("UpgradeButton")
        if upgradeBtn and upgradeBtn:IsA("ClickDetector") then
            fireclickdetector(upgradeBtn)
            task.wait(0.3)
        end
    end
end

-- Auto Buy Feeders
local function autoBuyFeeders()
    if not plotState.autoBuyFeeders then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("buyfeeder") then
            local clickDetector = obj:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                task.wait(0.5)
            end
        end
    end
end

-- ==================== BATTLE FEATURES ====================
local battleState = {
    autoStartTower = false,
    autoNoThanks = false,
    autoStartChaos = false
}

-- Auto Start Tower
local function autoStartTower()
    if not battleState.autoStartTower then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (obj.Name:lower():find("tower") and obj.Name:lower():find("start")) then
            local clickDetector = obj:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                task.wait(0.5)
                break
            end
        end
    end
end

-- Auto No Thanks
local function autoNoThanks()
    if not battleState.autoNoThanks then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and obj.Name:lower():find("nothanks") then
            local clickDetector = obj:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                task.wait(0.3)
            end
        end
    end
end

-- Auto Start Chaos
local function autoStartChaos()
    if not battleState.autoStartChaos then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name and (obj.Name:lower():find("chaos") and obj.Name:lower():find("start")) then
            local clickDetector = obj:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                task.wait(0.5)
                break
            end
        end
    end
end

-- ==================== MAIN LOOP ====================
local function mainLoop()
    while ScreenGui.Parent do
        -- Farm features
        pcall(autoOpenEggs)
        pcall(autoFuseChickens)
        pcall(autoGrabScraps)
        pcall(autoRecycleScrap)
        pcall(autoUpgradeRecycler)
        
        -- Plot features
        pcall(autoRebirth)
        pcall(autoUpgradeCoop)
        pcall(autoUpgradeFeeder)
        pcall(autoBuyFeeders)
        
        -- Battle features
        pcall(autoStartTower)
        pcall(autoNoThanks)
        pcall(autoStartChaos)
        
        task.wait(0.5) -- Loop every 0.5 seconds
    end
end

-- ==================== POPULATE UI ====================

-- [1] FARM TAB
local farmCard = CreateCard(Tabs["Farm"], "Auto Farm")
CreateToggle(farmCard, "Auto Open Eggs", false, function(state)
    farmState.autoOpenEggs = state
end)
CreateToggle(farmCard, "Auto Fuse Chickens", false, function(state)
    farmState.autoFuseChickens = state
end)
CreateToggle(farmCard, "Auto Grab Scraps", false, function(state)
    farmState.autoGrabScraps = state
end)
CreateToggle(farmCard, "Auto Recycle Scrap", false, function(state)
    farmState.autoRecycleScrap = state
end)
CreateToggle(farmCard, "Auto Upgrade Recycler", false, function(state)
    farmState.autoUpgradeRecycler = state
end)
CreateSlider(farmCard, "Recycle threshold", 1, 20, 10, function(value)
    farmState.recycleThreshold = value
end)

-- [2] PLOT TAB
local plotCard = CreateCard(Tabs["Plot"], "Plot Settings")
CreateToggle(plotCard, "Auto Rebirth", false, function(state)
    plotState.autoRebirth = state
end)
CreateToggle(plotCard, "Auto Upgrade Coop", false, function(state)
    plotState.autoUpgradeCoop = state
end)
CreateToggle(plotCard, "Auto Upgrade Feeder", false, function(state)
    plotState.autoUpgradeFeeder = state
end)
CreateToggle(plotCard, "Auto Buy Feeders", false, function(state)
    plotState.autoBuyFeeders = state
end)

-- [3] BATTLE TAB
local battleCard = CreateCard(Tabs["Battle"], "Battle System")
CreateToggle(battleCard, "Auto Start Tower", false, function(state)
    battleState.autoStartTower = state
end)
CreateToggle(battleCard, "Auto No Thanks", false, function(state)
    battleState.autoNoThanks = state
end)
CreateToggle(battleCard, "Auto Start Chaos", false, function(state)
    battleState.autoStartChaos = state
end)

-- [4] INFO TAB
local infoCard = CreateCard(Tabs["Info"], "Information")
local function AddInfoRow(k, v)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1, 0, 0, 22)
    r.BackgroundTransparency = 1
    r.Parent = infoCard

    local l1 = Instance.new("TextLabel")
    l1.Size = UDim2.new(0.5, 0, 1, 0)
    l1.BackgroundTransparency = 1
    l1.Text = k
    l1.TextColor3 = THEME.Sub
    l1.TextSize = 11
    l1.Font = Enum.Font.Gotham
    l1.TextXAlignment = Enum.TextXAlignment.Left
    l1.Parent = r

    local l2 = Instance.new("TextLabel")
    l2.Size = UDim2.new(0.5, 0, 1, 0)
    l2.Position = UDim2.new(0.5
