local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")
local starterGui = game:GetService("StarterGui")

local isRunning = false
local isMinimized = false
local currentTab = "Main"
local autoCollectEnabled = false
local autoOpenEnabled = false
local autoFuseEnabled = false
local autoSellEnabled = false
local autoRebirthEnabled = false
local autoTowerEnabled = false
local autoScrapEnabled = false
local autoPitEnabled = false
local autoFightEnabled = false
local autoChaosEnabled = false
local autoUpgradeCoop = false
local autoUpgradeFeeder = false
local autoBuyFeeder = false
local autoUpgradeRecycler = false
local autoBuyRecycler = false
local autoSkipFloor = false
local delayMin = 3
local delayMax = 8
local sellRarity = "Common"
local walkSpeed = 20
local tweenSpeed = 10
local minHealth = 50
local scrapLimit = 10

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

local function findLocal(namePattern)
    for _, child in pairs(player:GetChildren()) do
        if string.match(child.Name, namePattern) then
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
local pitRemote = findRemote("[Pp]it")
local fightRemote = findRemote("[Ff]ight|[Bb]attle")
local chaosRemote = findRemote("[Cc]haos")
local upgradeRemote = findRemote("[Uu]pgrade")
local buyRemote = findRemote("[Bb]uy")

local playerData = player:FindFirstChild("Data") or player:FindFirstChild("leaderstats")
local eggs = playerData and playerData:FindFirstChild("Eggs")
local money = playerData and playerData:FindFirstChild("Money")
local level = playerData and playerData:FindFirstChild("Level")
local rebirths = playerData and playerData:FindFirstChild("Rebirths")

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
        if math.random() < 0.2 then
            randomDelay(10, 20)
        end
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
        if math.random() < 0.15 then
            randomDelay(5, 10)
        end
    end
end

local function autoRebirth()
    while autoRebirthEnabled do
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

local function autoPit()
    while autoPitEnabled do
        pcall(function()
            if pitRemote then
                pitRemote:FireServer()
            end
        end)
        randomDelay(3, 7)
    end
end

local function autoFight()
    while autoFightEnabled do
        pcall(function()
            if fightRemote then
                fightRemote:FireServer()
            end
        end)
        randomDelay(2, 5)
        if math.random() < 0.2 then
            randomDelay(8, 15)
        end
    end
end

local function autoChaos()
    while autoChaosEnabled do
        pcall(function()
            if chaosRemote then
                chaosRemote:FireServer()
            end
        end)
        randomDelay(4, 10)
    end
end

local function autoUpgradeCoop()
    while autoUpgradeCoop do
        pcall(function()
            if upgradeRemote then
                upgradeRemote:FireServer("Coop")
            end
        end)
        randomDelay(5, 12)
    end
end

local function autoUpgradeFeeder()
    while autoUpgradeFeeder do
        pcall(function()
            if upgradeRemote then
                upgradeRemote:FireServer("Feeder")
            end
        end)
        randomDelay(5, 12)
    end
end

local function autoBuyFeeder()
    while autoBuyFeeder do
        pcall(function()
            if buyRemote then
                buyRemote:FireServer("Feeder")
            end
        end)
        randomDelay(3, 8)
    end
end

local function autoUpgradeRecycler()
    while autoUpgradeRecycler do
        pcall(function()
            if upgradeRemote then
                upgradeRemote:FireServer("Recycler")
            end
        end)
        randomDelay(5, 12)
    end
end

local function autoBuyRecycler()
    while autoBuyRecycler do
        pcall(function()
            if buyRemote then
                buyRemote:FireServer("Recycler")
            end
        end)
        randomDelay(3, 8)
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
    if autoPitEnabled then task.spawn(autoPit) end
    if autoFightEnabled then task.spawn(autoFight) end
    if autoChaosEnabled then task.spawn(autoChaos) end
    if autoUpgradeCoop then task.spawn(autoUpgradeCoop) end
    if autoUpgradeFeeder then task.spawn(autoUpgradeFeeder) end
    if autoBuyFeeder then task.spawn(autoBuyFeeder) end
    if autoUpgradeRecycler then task.spawn(autoUpgradeRecycler) end
    if autoBuyRecycler then task.spawn(autoBuyRecycler) end
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
    autoPitEnabled = false
    autoFightEnabled = false
    autoChaosEnabled = false
    autoUpgradeCoop = false
    autoUpgradeFeeder = false
    autoBuyFeeder = false
    autoUpgradeRecycler = false
    autoBuyRecycler = false
    log("Stopped all features")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ErdevaHubV7"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = coreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 480)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 28)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Color = Color3.fromRGB(0, 200, 255)
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
header.BackgroundTransparency = 0.15
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 35, 1, 0)
logo.Position = UDim2.new(0, 8, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "⚡"
logo.TextColor3 = Color3.fromRGB(0, 200, 255)
logo.TextSize = 24
logo.Font = Enum.Font.GothamBold
logo.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 48, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ERDEVA HUB V7"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -65, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
minimizeBtn.TextSize = 22
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = header
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 380, 0, 50), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 380, 0, 480), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.25, true)
    end
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -32, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function()
    stopAll()
    screenGui:Destroy()
end)

local tabs = {"Main", "Farm", "Upgrade", "Fight"}
local tabButtons = {}

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 38)
tabFrame.Position = UDim2.new(0, 10, 0, 55)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

for i, tab in pairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25 - 0.01, 0, 1, -4)
    btn.Position = UDim2.new((i-1) * 0.25 + 0.005, 0, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
    btn.TextColor3 = Color3.fromRGB(150, 150, 200)
    btn.Text = tab
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    tabButtons[tab] = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTab = tab
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
            b.TextColor3 = Color3.fromRGB(150, 150, 200)
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        btn.TextColor3 = Color3.fromRGB(12, 12, 28)
        updateContent(tab)
    end)
end

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -115)
contentFrame.Position = UDim2.new(0, 10, 0, 98)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
contentFrame.ScrollBarThickness = 3
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
contentFrame.Parent = mainFrame

local canvas = Instance.new("Frame")
canvas.Size = UDim2.new(1, 0, 1, 0)
canvas.BackgroundTransparency = 1
canvas.Parent = contentFrame

local function createToggle(parent, text, y, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(16, 16, 35)
    frame.BackgroundTransparency = 0.5
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 22)
    toggleBtn.Position = UDim2.new(0.78, 0, 0.5, -11)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(60, 60, 80)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = default and Color3.fromRGB(12, 12, 28) or Color3.fromRGB(200, 200, 200)
    toggleBtn.TextSize = 10
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn
    
    local state = default or false
    local callback = nil
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(60, 60, 80)
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.TextColor3 = state and Color3.fromRGB(12, 12, 28) or Color3.fromRGB(200, 200, 200)
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
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(16, 16, 35)
    frame.BackgroundTransparency = 0.5
    frame.Parent = parent
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.5, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.78, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.7, 0, 0, 3)
    sliderFrame.Position = UDim2.new(0.1, 0, 0.7, 0)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    sliderFrame.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = UDim2.new((default - min) / (max - min), -6, 0, -4.5)
    thumb.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    thumb.Parent = sliderFrame
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
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
            thumb.Position = UDim2.new(newVal, -6, 0, -4.5)
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

local function updateContent(tab)
    for _, child in pairs(canvas:GetChildren()) do
        child:Destroy()
    end
    
    local y = 5
    
    if tab == "Main" then
        local statusFrame = Instance.new("Frame")
        statusFrame.Size = UDim2.new(1, -10, 0, 50)
        statusFrame.Position = UDim2.new(0, 5, 0, y)
        statusFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 35)
        statusFrame.BackgroundTransparency = 0.5
        statusFrame.Parent = canvas
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(0, 6)
        statusCorner.Parent = statusFrame
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, 0, 1, 0)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "⚡ Status: " .. (isRunning and "ON" or "OFF")
        statusLabel.TextColor3 = isRunning and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 80, 80)
        statusLabel.TextSize = 14
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = statusFrame
        
        y = y + 55
        
        local startBtn = Instance.new("TextButton")
        startBtn.Size = UDim2.new(0.45, -5, 0, 35)
        startBtn.Position = UDim2.new(0.025, 0, 0, y)
        startBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        startBtn.Text = "▶ START"
        startBtn.TextColor3 = Color3.fromRGB(12, 12, 28)
        startBtn.TextSize = 13
        startBtn.Font = Enum.Font.GothamBold
        startBtn.Parent = canvas
        
        local startCorner = Instance.new("UICorner")
        startCorner.CornerRadius = UDim.new(0, 6)
        startCorner.Parent = startBtn
        
        startBtn.MouseButton1Click:Connect(function()
            isRunning = true
            startAll()
            updateContent(tab)
        end)
        
        local stopBtn = Instance.new("TextButton")
        stopBtn.Size = UDim2.new(0.45, -5, 0, 35)
        stopBtn.Position = UDim2.new(0.525, 0, 0, y)
        stopBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        stopBtn.Text = "■ STOP"
        stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        stopBtn.TextSize = 13
        stopBtn.Font = Enum.Font.GothamBold
        stopBtn.Parent = canvas
        
        local stopCorner = Instance.new("UICorner")
        stopCorner.CornerRadius = UDim.new(0, 6)
        stopCorner.Parent = stopBtn
        
        stopBtn.MouseButton1Click:Connect(function()
            stopAll()
            updateContent(tab)
        end)
        
        y = y + 45
        
        createSlider(canvas, "Delay Min", y, 1, 5, delayMin)
        y = y + 45
        
        createSlider(canvas, "Delay Max", y, 3, 10, delayMax)
        y = y + 45
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
    elseif tab == "Farm" then
        autoCollectEnabled, autoCollectCallback = createToggle(canvas, "Auto Collect Eggs", y, autoCollectEnabled)
        y = y + 40
        
        autoOpenEnabled, autoOpenCallback = createToggle(canvas, "Auto Open Eggs", y, autoOpenEnabled)
        y = y + 40
        
        autoFuseEnabled, autoFuseCallback = createToggle(canvas, "Auto Fuse", y, autoFuseEnabled)
        y = y + 40
        
        autoSellEnabled, autoSellCallback = createToggle(canvas, "Auto Sell", y, autoSellEnabled)
        y = y + 40
        
        autoChaosEnabled, autoChaosCallback = createToggle(canvas, "Auto Chaos", y, autoChaosEnabled)
        y = y + 40
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
    elseif tab == "Upgrade" then
        autoRebirthEnabled, autoRebirthCallback = createToggle(canvas, "Auto Rebirth", y, autoRebirthEnabled)
        y = y + 40
        
        autoTowerEnabled, autoTowerCallback = createToggle(canvas, "Auto Tower", y, autoTowerEnabled)
        y = y + 40
        
        autoSkipFloor, autoSkipFloorCallback = createToggle(canvas, "Skip Floor", y, autoSkipFloor)
        y = y + 40
        
        autoUpgradeCoop, autoUpgradeCoopCallback = createToggle(canvas, "Upgrade Coop", y, autoUpgradeCoop)
        y = y + 40
        
        autoUpgradeFeeder, autoUpgradeFeederCallback = createToggle(canvas, "Upgrade Feeder", y, autoUpgradeFeeder)
        y = y + 40
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
        
    elseif tab == "Fight" then
        autoScrapEnabled, autoScrapCallback = createToggle(canvas, "Auto Scrap", y, autoScrapEnabled)
        y = y + 40
        
        autoPitEnabled, autoPitCallback = createToggle(canvas, "Auto Pit", y, autoPitEnabled)
        y = y + 40
        
        autoFightEnabled, autoFightCallback = createToggle(canvas, "Auto Fight", y, autoFightEnabled)
        y = y + 40
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end
end

tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(0, 200, 255)
tabButtons["Main"].TextColor3 = Color3.fromRGB(12, 12, 28)
updateContent("Main")

log("ERDEVA HUB V7 LOADED")
starterGui:SetCore("SendNotification", {
    Title = "Erdeva Hub",
    Text = "Script loaded successfully!",
    Duration = 3
})
