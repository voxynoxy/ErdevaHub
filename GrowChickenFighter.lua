-- ============================================================
-- GROW-A-CHICKEN-FIGHTER | ERDEVA HUB 
-- ============================================================

local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local coreGui = game:GetService("CoreGui")

local isRunning = false
local currentTab = "Main"
local autoCollectEnabled = false
local autoOpenEnabled = false
local autoFuseEnabled = false
local autoSellEnabled = false
local autoRebirthEnabled = false
local autoTowerEnabled = false
local autoScrapEnabled = false
local delayMin = 3
local delayMax = 8
local sellRarity = "Common"

local function randomDelay(min, max)
    local delay = min + math.random() * (max - min)
    task.wait(delay)
end

local function randomInt(min, max)
    return math.random(min, max)
end

local function findRemote(namePattern)
    for _, child in pairs(replicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") and string.match(child.Name, namePattern) then
            return child
        end
    end
    return nil
end

local claimRemote = findRemote("[Cc]laim|[Hh]arvest|[Cc]ollect")
local sellRemote = findRemote("[Ss]ell")
local fuseRemote = findRemote("[Ff]use")
local rebirthRemote = findRemote("[Rr]ebirth")
local towerRemote = findRemote("[Tt]ower")
local scrapRemote = findRemote("[Ss]crap")

local function log(message)
    print("[Erdeva] " .. message)
end

local function autoCollect()
    while autoCollectEnabled do
        pcall(function()
            if claimRemote then
                claimRemote:FireServer()
            end
        end)
        randomDelay(delayMin, delayMax)
        if math.random() < 0.08 then
            task.wait(randomDelay(5, 10))
        end
    end
end

local function autoOpen()
    while autoOpenEnabled do
        pcall(function()
            if claimRemote then
                claimRemote:FireServer()
            end
        end)
        randomDelay(2, 5)
    end
end

local function autoFuse()
    while autoFuseEnabled do
        pcall(function()
            if fuseRemote then
                fuseRemote:FireServer()
            end
        end)
        randomDelay(5, 15)
    end
end

local function autoSell()
    while autoSellEnabled do
        pcall(function()
            if sellRemote then
                sellRemote:FireServer()
            end
        end)
        randomDelay(3, 8)
    end
end

local function autoRebirth()
    while autoRebirthEnabled do
        local data = player:FindFirstChild("Data") or player:FindFirstChild("leaderstats")
        local level = data and data:FindFirstChild("Level")
        if level and level.Value > 10 then
            pcall(function()
                if rebirthRemote then
                    rebirthRemote:FireServer()
                end
            end)
            randomDelay(2, 5)
        end
        randomDelay(10, 20)
    end
end

local function autoTower()
    while autoTowerEnabled do
        pcall(function()
            if towerRemote then
                towerRemote:FireServer()
            end
        end)
        randomDelay(1, 3)
        if math.random() < 0.3 then
            randomDelay(5, 10)
        end
    end
end

local function autoScrap()
    while autoScrapEnabled do
        pcall(function()
            if scrapRemote then
                scrapRemote:FireServer()
            end
        end)
        randomDelay(2, 6)
    end
end

local function startAll()
    isRunning = true
    log("Started all features")
    
    if autoCollectEnabled then task.spawn(autoCollect) end
    if autoOpenEnabled then task.spawn(autoOpen) end
    if autoFuseEnabled then task.spawn(autoFuse) end
    if autoSellEnabled then task.spawn(autoSell) end
    if autoRebirthEnabled then task.spawn(autoRebirth) end
    if autoTowerEnabled then task.spawn(autoTower) end
    if autoScrapEnabled then task.spawn(autoScrap) end
end

local function stopAll()
    isRunning = false
    autoCollectEnabled = false
    autoOpenEnabled = false
    autoFuseEnabled = false
    autoSellEnabled = false
    autoRebirthEnabled = false
    autoTowerEnabled = false
    autoScrapEnabled = false
    log("Stopped all features")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ErdevaHubV3"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = coreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 500)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Color = Color3.fromRGB(255, 60, 60)
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
header.BackgroundTransparency = 0.15
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐔 Erdeva Hub V3"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("ImageButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 7)
closeBtn.BackgroundTransparency = 1
closeBtn.Image = "rbxassetid://6031093303"
closeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function()
    stopAll()
    screenGui:Destroy()
end)

local tabs = {"Main", "Farm", "Upgrade", "Scrap", "Tower"}
local tabButtons = {}

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 40)
tabFrame.Position = UDim2.new(0, 10, 0, 50)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

for i, tab in pairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, -2, 1, -4)
    btn.Position = UDim2.new((i-1) * 0.2 + 0.005, 0, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Text = tab
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    tabButtons[tab] = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTab = tab
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            b.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        updateContent(tab)
    end)
end

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -110)
contentFrame.Position = UDim2.new(0, 10, 0, 95)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
contentFrame.Parent = mainFrame

local canvas = Instance.new("Frame")
canvas.Size = UDim2.new(1, 0, 1, 0)
canvas.BackgroundTransparency = 1
canvas.Parent = contentFrame

local function createToggle(parent, text, y, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    frame.BackgroundTransparency = 0.5
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 65, 0, 28)
    toggleBtn.Position = UDim2.new(0.85, 0, 0.5, -14)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(80, 80, 100)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 11
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn
    
    local state = default or false
    local callback = nil
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 80) or Color3.fromRGB(80, 80, 100)
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then
            callback(state)
        end
    end)
    
    return function(cb)
        callback = cb
    end
end

local function createSlider(parent, text, y, min, max, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    frame.BackgroundTransparency = 0.5
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.5, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.78, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.7, 0, 0, 4)
    sliderFrame.Position = UDim2.new(0.12, 0, 0.7, 0)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sliderFrame.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new((default - min) / (max - min), -8, 0, -6)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Parent = sliderFrame
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    local thumbStroke = Instance.new("UIStroke")
    thumbStroke.Thickness = 2
    thumbStroke.Color = Color3.fromRGB(255, 60, 60)
    thumbStroke.Parent = thumb
    
    local callback = nil
    local dragging = false
    
    thumb.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    thumb.MouseButton1Up:Connect(function()
        dragging = false
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X - sliderFrame.AbsolutePosition.X
            local newVal = math.clamp(pos / sliderFrame.AbsoluteSize.X, 0, 1)
            local value = math.round(min + (max - min) * newVal)
            fill.Size = UDim2.new(newVal, 0, 1, 0)
            thumb.Position = UDim2.new(newVal, -8, 0, -6)
            valueLabel.Text = tostring(value)
            if callback then
                callback(value)
            end
        end
    end)
    
    return function(cb)
        callback = cb
    end
end

local function createDropdown(parent, options, y, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    frame.BackgroundTransparency = 0.5
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = default or options[1]
    label.TextColor3 = Color3.fromRGB(230, 230, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0.1, 0, 1, 0)
    arrow.Position = UDim2.new(0.9, 0, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.Gotham
    arrow.Parent = frame
    
    local callback = nil
    local selectedIndex = 1
    
    frame.MouseButton1Click:Connect(function()
        selectedIndex = selectedIndex % #options + 1
        label.Text = options[selectedIndex]
        if callback then
            callback(options[selectedIndex])
        end
    end)
    
    return function(cb)
        callback = cb
    end
end

local function updateContent(tab)
    for _, child in pairs(canvas:GetChildren()) do
        child:Destroy()
    end
    
    local y = 5
    
    if tab == "Main" then
        local statusFrame = Instance.new("Frame")
        statusFrame.Size = UDim2.new(1, -10, 0, 60)
        statusFrame.Position = UDim2.new(0, 5, 0, y)
        statusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        statusFrame.BackgroundTransparency = 0.5
        statusFrame.Parent = canvas
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(0, 6)
        statusCorner.Parent = statusFrame
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, 0, 1, 0)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "🤖 Status: " .. (isRunning and "Running" or "Stopped")
        statusLabel.TextColor3 = isRunning and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(255, 100, 100)
        statusLabel.TextSize = 16
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = statusFrame
        
        y = y + 65
        
        local startBtn = Instance.new("TextButton")
        startBtn.Size = UDim2.new(0.45, -5, 0, 40)
        startBtn.Position = UDim2.new(0.025, 0, 0, y)
        startBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
        startBtn.Text = "▶ Start All"
        startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        startBtn.TextSize = 14
        startBtn.Font = Enum.Font.GothamBold
        startBtn.Parent = canvas
        
        local startCorner = Instance.new("UICorner")
        startCorner.CornerRadius = UDim.new(0, 8)
        startCorner.Parent = startBtn
        
        startBtn.MouseButton1Click:Connect(function()
            isRunning = true
            startAll()
            updateContent(tab)
        end)
        
        local stopBtn = Instance.new("TextButton")
        stopBtn.Size = UDim2.new(0.45, -5, 0, 40)
        stopBtn.Position = UDim2.new(0.525, 0, 0, y)
        stopBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        stopBtn.Text = "■ Stop All"
        stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        stopBtn.TextSize = 14
        stopBtn.Font = Enum.Font.GothamBold
        stopBtn.Parent = canvas
        
        local stopCorner = Instance.new("UICorner")
        stopCorner.CornerRadius = UDim.new(0, 8)
        stopCorner.Parent = stopBtn
        
        stopBtn.MouseButton1Click:Connect(function()
            stopAll()
            updateContent(tab)
        end)
        
        y = y + 50
        
        createSlider(canvas, "Delay Min (s)", y, 1, 10, delayMin)
        y = y + 48
        
        createSlider(canvas, "Delay Max (s)", y, 2, 15, delayMax)
        y = y + 48
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
    elseif tab == "Farm" then
        autoCollectEnabled, autoCollectCallback = createToggle(canvas, "Auto Collect Eggs", y, autoCollectEnabled)
        y = y + 42
        
        autoOpenEnabled, autoOpenCallback = createToggle(canvas, "Auto Open Eggs", y, autoOpenEnabled)
        y = y + 42
        
        autoFuseEnabled, autoFuseCallback = createToggle(canvas, "Auto Fuse Chickens", y, autoFuseEnabled)
        y = y + 42
        
        autoSellEnabled, autoSellCallback = createToggle(canvas, "Auto Sell Chickens", y, autoSellEnabled)
        y = y + 42
        
        local sellRarityFrame, sellRarityLabel = createDropdown(canvas, {"Common", "Uncommon", "Rare", "Epic", "Legendary"}, y, sellRarity)
        y = y + 42
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
    elseif tab == "Upgrade" then
        autoRebirthEnabled, autoRebirthCallback = createToggle(canvas, "Auto Rebirth", y, autoRebirthEnabled)
        y = y + 42
        
        local upgradeFrame = Instance.new("Frame")
        upgradeFrame.Size = UDim2.new(1, -10, 0, 35)
        upgradeFrame.Position = UDim2.new(0, 5, 0, y)
        upgradeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        upgradeFrame.BackgroundTransparency = 0.5
        upgradeFrame.Parent = canvas
        
        local upgradeCorner = Instance.new("UICorner")
        upgradeCorner.CornerRadius = UDim.new(0, 6)
        upgradeCorner.Parent = upgradeFrame
        
        local upgradeLabel = Instance.new("TextLabel")
        upgradeLabel.Size = UDim2.new(1, 0, 1, 0)
        upgradeLabel.BackgroundTransparency = 1
        upgradeLabel.Text = "🔧 Upgrade features coming soon"
        upgradeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        upgradeLabel.TextSize = 13
        upgradeLabel.Font = Enum.Font.Gotham
        upgradeLabel.Parent = upgradeFrame
        
        y = y + 42
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
    elseif tab == "Scrap" then
        autoScrapEnabled, autoScrapCallback = createToggle(canvas, "Auto Grab Scrap", y, autoScrapEnabled)
        y = y + 42
        
        createSlider(canvas, "Walk Speed", y, 5, 50, 20)
        y = y + 48
        
        createSlider(canvas, "Tween Speed", y, 5, 30, 10)
        y = y + 48
        
        local limitFrame = Instance.new("Frame")
        limitFrame.Size = UDim2.new(1, -10, 0, 35)
        limitFrame.Position = UDim2.new(0, 5, 0, y)
        limitFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        limitFrame.BackgroundTransparency = 0.5
        limitFrame.Parent = canvas
        
        local limitCorner = Instance.new("UICorner")
        limitCorner.CornerRadius = UDim.new(0, 6)
        limitCorner.Parent = limitFrame
        
        local limitLabel = Instance.new("TextLabel")
        limitLabel.Size = UDim2.new(0.7, 0, 1, 0)
        limitLabel.Position = UDim2.new(0, 12, 0, 0)
        limitLabel.BackgroundTransparency = 1
        limitLabel.Text = "Limit Scrap: 10 pcs"
        limitLabel.TextColor3 = Color3.fromRGB(230, 230, 255)
        limitLabel.TextSize = 13
        limitLabel.Font = Enum.Font.Gotham
        limitLabel.TextXAlignment = Enum.TextXAlignment.Left
        limitLabel.Parent = limitFrame
        
        y = y + 42
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
    elseif tab == "Tower" then
        autoTowerEnabled, autoTowerCallback = createToggle(canvas, "Auto Tower", y, autoTowerEnabled)
        y = y + 42
        
        local towerFrame = Instance.new("Frame")
        towerFrame.Size = UDim2.new(1, -10, 0, 35)
        towerFrame.Position = UDim2.new(0, 5, 0, y)
        towerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        towerFrame.BackgroundTransparency = 0.5
        towerFrame.Parent = canvas
        
        local towerCorner = Instance.new("UICorner")
        towerCorner.CornerRadius = UDim.new(0, 6)
        towerCorner.Parent = towerFrame
        
        local towerLabel = Instance.new("TextLabel")
        towerLabel.Size = UDim2.new(1, 0, 1, 0)
        towerLabel.BackgroundTransparency = 1
        towerLabel.Text = "🏰 Tower features coming soon"
        towerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        towerLabel.TextSize = 13
        towerLabel.Font = Enum.Font.Gotham
        towerLabel.Parent = towerFrame
        
        y = y + 42
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end
end

tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(255, 50, 50)
tabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
updateContent("Main")

log("==========================================")
log("  GROW-A-CHICKEN-FIGHTER | ERDEVA HUB ")
log("==========================================")
