
-- ERDEVA HUB V6 - GROW A CHICKEN FIGHTER


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
local autoFuseEnabled = false
local autoRebirthEnabled = false
local delayMin = 3
local delayMax = 8

local function randomDelay(min, max)
    local delay = min + math.random() * (max - min)
    task.wait(delay)
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
local fuseRemote = findRemote("[Ff]use")
local rebirthRemote = findRemote("[Rr]ebirth")

local playerData = player:FindFirstChild("Data") or player:FindFirstChild("leaderstats")
local level = playerData and playerData:FindFirstChild("Level")

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

local function startAll()
    isRunning = true
    log("Started all features")
    if autoCollectEnabled then task.spawn(autoCollect) end
    if autoFuseEnabled then task.spawn(autoFuse) end
    if autoRebirthEnabled then task.spawn(autoRebirth) end
end

local function stopAll()
    isRunning = false
    autoCollectEnabled = false
    autoFuseEnabled = false
    autoRebirthEnabled = false
    log("Stopped all features")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ErdevaHubV6"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = coreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Color = Color3.fromRGB(0, 255, 0)
mainStroke.Transparency = 0.5
mainStroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
header.BackgroundTransparency = 0.1
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 30, 1, 0)
logo.Position = UDim2.new(0, 5, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "⚡"
logo.TextColor3 = Color3.fromRGB(0, 255, 0)
logo.TextSize = 22
logo.Font = Enum.Font.GothamBold
logo.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 40, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ERDEVA HUB"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 1, 0)
minimizeBtn.Position = UDim2.new(1, -55, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = header
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 45), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
    else
        mainFrame:TweenSize(UDim2.new(0, 320, 0, 380), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
    end
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 1, 0)
closeBtn.Position = UDim2.new(1, -28, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function()
    stopAll()
    screenGui:Destroy()
end)

local tabs = {"Main", "Farm"}
local tabButtons = {}

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 35)
tabFrame.Position = UDim2.new(0, 10, 0, 50)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

for i, tab in pairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5 - 0.01, 0, 1, -4)
    btn.Position = UDim2.new((i-1) * 0.5 + 0.005, 0, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    btn.TextColor3 = Color3.fromRGB(150, 150, 200)
    btn.Text = tab
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    tabButtons[tab] = btn
    
    btn.MouseButton1Click:Connect(function()
        currentTab = tab
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
            b.TextColor3 = Color3.fromRGB(150, 150, 200)
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        btn.TextColor3 = Color3.fromRGB(10, 10, 20)
        updateContent(tab)
    end)
end

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -110)
contentFrame.Position = UDim2.new(0, 10, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
contentFrame.ScrollBarThickness = 3
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 0)
contentFrame.Parent = mainFrame

local canvas = Instance.new("Frame")
canvas.Size = UDim2.new(1, 0, 1, 0)
canvas.BackgroundTransparency = 1
canvas.Parent = contentFrame

local function createToggle(parent, text, y, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.Position = UDim2.new(0, 5, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
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
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(60, 60, 80)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = default and Color3.fromRGB(10, 10, 20) or Color3.fromRGB(200, 200, 200)
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
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(60, 60, 80)
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.TextColor3 = state and Color3.fromRGB(10, 10, 20) or Color3.fromRGB(200, 200, 200)
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
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
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
    valueLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
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
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = UDim2.new((default - min) / (max - min), -6, 0, -4.5)
    thumb.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
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
        statusFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
        statusFrame.BackgroundTransparency = 0.5
        statusFrame.Parent = canvas
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(0, 6)
        statusCorner.Parent = statusFrame
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, 0, 1, 0)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "⚡ Status: " .. (isRunning and "ON" or "OFF")
        statusLabel.TextColor3 = isRunning and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        statusLabel.TextSize = 14
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = statusFrame
        
        y = y + 55
        
        local startBtn = Instance.new("TextButton")
        startBtn.Size = UDim2.new(0.45, -5, 0, 35)
        startBtn.Position = UDim2.new(0.025, 0, 0, y)
        startBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        startBtn.Text = "▶ START"
        startBtn.TextColor3 = Color3.fromRGB(10, 10, 20)
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
        stopBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
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
        
        autoFuseEnabled, autoFuseCallback = createToggle(canvas, "Auto Fuse", y, autoFuseEnabled)
        y = y + 40
        
        autoRebirthEnabled, autoRebirthCallback = createToggle(canvas, "Auto Rebirth", y, autoRebirthEnabled)
        y = y + 40
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end
end

tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
tabButtons["Main"].TextColor3 = Color3.fromRGB(10, 10, 20)
updateContent("Main")

log("==========================================")
log("  ERDEVA HUB V6 - GROW A CHICKEN FIGHTER")
log("  All Features Loaded!")
log("==========================================")
starterGui:SetCore("SendNotification", {
    Title = "Erdeva Hub",
    Text = "Script loaded successfully!",
    Duration = 3
})
