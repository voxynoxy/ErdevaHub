local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

pcall(function()
    if CoreGui:FindFirstChild("ERDEVA_HUB") then
        CoreGui:FindFirstChild("ERDEVA_HUB"):Destroy()
    end
end)

local W, H = 420, 250
local C = {
    Bg = Color3.fromRGB(14, 14, 14),
    Top = Color3.fromRGB(20, 20, 20),
    Card = Color3.fromRGB(22, 22, 22),
    Red = Color3.fromRGB(220, 35, 35),
    Txt = Color3.fromRGB(240, 240, 240),
    Sub = Color3.fromRGB(150, 150, 150),
    Brd = Color3.fromRGB(45, 45, 45)
}

local function tw(o, p, t)
    TweenService:Create(o, TweenInfo.new(t or 0.15), p):Play()
end

local Flags = {
    AutoOpenEggs = false,
    AutoFuseChickens = false,
    AutoGrabScraps = false,
    AutoRecycleScrap = false,
    AutoUpgradeRecycler = false,
    RecycleThreshold = 10,
    AutoRebirth = false,
    AutoUpgradeCoop = false,
    AutoUpgradeFeeder = false,
    AutoBuyFeeders = false,
    AutoStartTower = false,
    AutoNoThanks = false,
    AutoStartChaos = false
}

--==================================================
-- GAME UTILITIES & KNIT ENGINE
--==================================================

local function GetRoot()
    local char = player.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function ClickButton(btn)
    if not btn then return end
    pcall(function()
        if getconnections then
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
            for _, c in ipairs(getconnections(btn.MouseButton1Down)) do c:Fire() end
            for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() end
        end
        if firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        end
    end)
end

local function ClickGuiByPattern(pattern)
    local pGui = player:FindFirstChild("PlayerGui")
    if not pGui then return false end
    pattern = pattern:lower()
    for _, b in ipairs(pGui:GetDescendants()) do
        if (b:IsA("TextButton") or b:IsA("ImageButton")) and b.Visible then
            local text = (b:IsA("TextButton") and b.Text:lower() or "") .. " " .. b.Name:lower()
            if text:find(pattern) then
                ClickButton(b)
                return true
            end
        end
    end
    return false
end

local function CallRemotes(keywords, ...)
    local args = {...}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, k in ipairs(keywords) do
                if name:find(k:lower()) then
                    pcall(function()
                        if obj:IsA("RemoteEvent") then
                            obj:FireServer(unpack(args))
                        else
                            obj:InvokeServer(unpack(args))
                        end
                    end)
                end
            end
        end
    end
end

local function TouchPads(keywords)
    local root = GetRoot()
    if not root then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower() .. " " .. (obj.Parent and obj.Parent.Name:lower() or "")
            for _, k in ipairs(keywords) do
                if name:find(k:lower()) then
                    if firetouchinterest then
                        firetouchinterest(root, obj, 0)
                        firetouchinterest(root, obj, 1)
                    end
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and fireproximityprompt then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
    end
end

-- 1. AUTO GRAB SCRAPS
task.spawn(function()
    while true do
        if Flags.AutoGrabScraps then
            pcall(function()
                local root = GetRoot()
                if root then
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if not Flags.AutoGrabScraps then break end
                        local n = obj.Name:lower()
                        if n:find("scrap") or n:find("trash") or n:find("drop") or n:find("debris") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                if not part.Anchored then
                                    part.CFrame = root.CFrame
                                end
                                if firetouchinterest then
                                    firetouchinterest(root, part, 0)
                                    firetouchinterest(root, part, 1)
                                end
                                local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if p and fireproximityprompt then
                                    fireproximityprompt(p)
                                end
                            end
                        end
                    end
                end
                CallRemotes({"scrap", "collect", "grab", "pickup"})
            end)
        end
        task.wait(0.15)
    end
end)

-- 2. AUTO OPEN EGGS
task.spawn(function()
    while true do
        if Flags.AutoOpenEggs then
            pcall(function()
                CallRemotes({"egg", "hatch", "openegg", "incubator", "buyegg", "startegg"})
                TouchPads({"egg", "hatch", "incubator"})
                ClickGuiByPattern("hatch")
                ClickGuiByPattern("open")
                ClickGuiByPattern("egg")
            end)
        end
        task.wait(0.5)
    end
end)

-- 3. AUTO FUSE CHICKENS
task.spawn(function()
    while true do
        if Flags.AutoFuseChickens then
            pcall(function()
                CallRemotes({"fuse", "merge", "chicken", "autofuse"})
                TouchPads({"fuse", "merge"})
                ClickGuiByPattern("fuse")
                ClickGuiByPattern("merge")
            end)
        end
        task.wait(0.8)
    end
end)

-- 4. AUTO RECYCLE SCRAP
task.spawn(function()
    while true do
        if Flags.AutoRecycleScrap then
            pcall(function()
                TouchPads({"recycler", "recycle"})
                CallRemotes({"recycle", "deposit", "recycler"}, Flags.RecycleThreshold)
                ClickGuiByPattern("recycle")
            end)
        end
        task.wait(0.8)
    end
end)

-- 5. AUTO UPGRADE RECYCLER
task.spawn(function()
    while true do
        if Flags.AutoUpgradeRecycler then
            pcall(function()
                TouchPads({"upgraderecycler", "recyclerupgrade"})
                CallRemotes({"upgraderecycler", "recyclerupgrade"})
                ClickGuiByPattern("upgrade recycler")
            end)
        end
        task.wait(1)
    end
end)

-- 6. AUTO REBIRTH
task.spawn(function()
    while true do
        if Flags.AutoRebirth then
            pcall(function()
                ClickGuiByPattern("rebirth")
                ClickGuiByPattern("confirm")
                ClickGuiByPattern("yes")
                CallRemotes({"rebirth", "dorebirth", "playerrebirth"})
                TouchPads({"rebirth"})
            end)
        end
        task.wait(0.5)
    end
end)

-- 7. PLOT UPGRADES
task.spawn(function()
    while true do
        if Flags.AutoUpgradeCoop then
            pcall(function()
                TouchPads({"coop", "upgrade coop", "upgradeplot"})
                CallRemotes({"upgradecoop", "coopupgrade", "upgradeplot"})
                ClickGuiByPattern("upgrade coop")
            end)
        end
        if Flags.AutoUpgradeFeeder then
            pcall(function()
                TouchPads({"upgrade feeder", "feeder"})
                CallRemotes({"upgradefeeder", "feederupgrade"})
                ClickGuiByPattern("upgrade feeder")
            end)
        end
        if Flags.AutoBuyFeeders then
            pcall(function()
                TouchPads({"buy feeder", "feeder"})
                CallRemotes({"buyfeeder", "purchasefeeder", "feeder"})
                ClickGuiByPattern("buy feeder")
            end)
        end
        task.wait(0.8)
    end
end)

-- 8. BATTLE HANDLERS
task.spawn(function()
    while true do
        if Flags.AutoStartTower then
            pcall(function()
                ClickGuiByPattern("tower")
                CallRemotes({"tower", "starttower", "entertower"})
                TouchPads({"tower"})
            end)
        end
        if Flags.AutoStartChaos then
            pcall(function()
                ClickGuiByPattern("to chaos")
                ClickGuiByPattern("chaos")
                CallRemotes({"chaos", "startchaos", "enterchaos"})
                TouchPads({"chaos"})
            end)
        end
        if Flags.AutoNoThanks then
            pcall(function()
                ClickGuiByPattern("no thanks")
                ClickGuiByPattern("nothanks")
                ClickGuiByPattern("skip")
                ClickGuiByPattern("claim")
                CallRemotes({"nothanks", "skip", "decline"})
            end)
        end
        task.wait(0.3)
    end
end)

--==================================================
-- GUI CREATION
--==================================================
local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "ERDEVA_HUB"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 9999

local Main = Instance.new("Frame", Gui)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Size = UDim2.fromOffset(W, H)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = C.Red
Stroke.Thickness = 1.2

-- TopBar
local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1, 0, 0, 34)
Top.BackgroundColor3 = C.Top
Top.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "ERDEVA HUB <font color='#dc2323'>v1.0</font>"
Title.RichText = true
Title.TextColor3 = C.Txt
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local Close = Instance.new("TextButton", Top)
Close.Size = UDim2.fromOffset(24, 24)
Close.Position = UDim2.new(1, -28, 0.5, -12)
Close.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Close.Text = "✕"
Close.TextColor3 = C.Sub
Close.TextSize = 11
Close.Font = Enum.Font.GothamBold
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 5)
Close.MouseButton1Click:Connect(function() Gui:Destroy() end)

local Min = Instance.new("TextButton", Top)
Min.Size = UDim2.fromOffset(24, 24)
Min.Position = UDim2.new(1, -56, 0.5, -12)
Min.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Min.Text = "—"
Min.TextColor3 = C.Sub
Min.TextSize = 11
Min.Font = Enum.Font.GothamBold
Instance.new("UICorner", Min).CornerRadius = UDim.new(0, 5)

local minState = false
Min.MouseButton1Click:Connect(function()
    minState = not minState
    tw(Main, {Size = UDim2.fromOffset(W, minState and 34 or H)}, 0.15)
end)

-- Drag System
local drag, dStart, fStart
Top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dStart = i.Position
        fStart = Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        Main.Position = UDim2.new(fStart.X.Scale, fStart.X.Offset + d.X, fStart.Y.Scale, fStart.Y.Offset + d.Y)
    end
end)

-- Tab Bar
local TabFrame = Instance.new("Frame", Main)
TabFrame.Size = UDim2.new(1, 0, 0, 28)
TabFrame.Position = UDim2.fromOffset(0, 34)
TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabFrame.BorderSizePixel = 0

local TabList = Instance.new("UIListLayout", TabFrame)
TabList.FillDirection = Enum.FillDirection.Horizontal

-- Content Area
local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -12, 1, -68)
Content.Position = UDim2.fromOffset(6, 64)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = C.Red
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local CLayout = Instance.new("UIListLayout", Content)
CLayout.Padding = UDim.new(0, 4)

-- System Tabs & Elements
local Pages, CurTab, TabBtns = {}, nil, {}
local function SetTab(name)
    CurTab = name
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(TabBtns) do
        tw(b, {BackgroundColor3 = (n == name and Color3.fromRGB(40, 14, 14) or Color3.fromRGB(18, 18, 18)), TextColor3 = (n == name and C.Txt or C.Sub)})
    end
end

local function MakeTab(name, order)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = C.Sub
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order
    TabBtns[name] = btn

    local page = Instance.new("Frame", Content)
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    local PL = Instance.new("UIListLayout", page)
    PL.Padding = UDim.new(0, 4)
    Pages[name] = page

    btn.MouseButton1Click:Connect(function() SetTab(name) end)
    return page
end

local function AddToggle(parent, text, flagKey)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 30)
    f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -50, 1, 0)
    l.Position = UDim2.fromOffset(8, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.Txt
    l.TextSize = 11
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.fromOffset(36, 18)
    b.Position = UDim2.new(1, -42, 0.5, -9)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    local k = Instance.new("Frame", b)
    k.Size = UDim2.fromOffset(14, 14)
    k.Position = UDim2.fromOffset(2, 2)
    k.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

    b.MouseButton1Click:Connect(function()
        Flags[flagKey] = not Flags[flagKey]
        local on = Flags[flagKey]
        tw(b, {BackgroundColor3 = (on and C.Red or Color3.fromRGB(50, 50, 50))})
        tw(k, {Position = (on and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2))})
    end)
end

local function AddSlider(parent, text, maxV, defV, flagKey)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -60, 0, 16)
    l.Position = UDim2.fromOffset(8, 2)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.Txt
    l.TextSize = 11
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left

    local vl = Instance.new("TextLabel", f)
    vl.Size = UDim2.fromOffset(50, 16)
    vl.Position = UDim2.new(1, -58, 0, 2)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(defV) .. "/" .. tostring(maxV)
    vl.TextColor3 = C.Red
    vl.TextSize = 11
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -16, 0, 4)
    bar.Position = UDim2.fromOffset(8, 22)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(defV/maxV, 0, 1, 0)
    fill.BackgroundColor3 = C.Red
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sld = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sld = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sld = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sld and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local r = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(r, 0, 1, 0)
            local val = math.floor(r * maxV + 0.5)
            vl.Text = tostring(val) .. "/" .. tostring(maxV)
            Flags[flagKey] = val
        end
    end)
end

-- Setup Tabs
local FarmPage = MakeTab("Farm", 1)
local PlotPage = MakeTab("Plot", 2)
local BattlePage = MakeTab("Battle", 3)
local InfoPage = MakeTab("Info", 4)

-- 1. Farm
AddToggle(FarmPage, "Auto Open Eggs", "AutoOpenEggs")
AddToggle(FarmPage, "Auto Fuse Chickens", "AutoFuseChickens")
AddToggle(FarmPage, "Auto Grab Scraps", "AutoGrabScraps")
AddToggle(FarmPage, "Auto Recycle Scrap", "AutoRecycleScrap")
AddToggle(FarmPage, "Auto Upgrade Recycler", "AutoUpgradeRecycler")
AddSlider(FarmPage, "Recycle threshold", 20, 10, "RecycleThreshold")

-- 2. Plot
AddToggle(PlotPage, "Auto Rebirth", "AutoRebirth")
AddToggle(PlotPage, "Auto Upgrade Coop", "AutoUpgradeCoop")
AddToggle(PlotPage, "Auto Upgrade Feeder", "AutoUpgradeFeeder")
AddToggle(PlotPage, "Auto Buy Feeders", "AutoBuyFeeders")

-- 3. Battle
AddToggle(BattlePage, "Auto Start Tower", "AutoStartTower")
AddToggle(BattlePage, "Auto No Thanks", "AutoNoThanks")
AddToggle(BattlePage, "Auto Start Chaos", "AutoStartChaos")

-- 4. Info
local function AddInfo(k, v)
    local f = Instance.new("Frame", InfoPage)
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.fromOffset(8, 0)
    l.BackgroundTransparency = 1
    l.Text = k
    l.TextColor3 = C.Txt
    l.TextSize = 11
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left

    local r = Instance.new("TextLabel", f)
    r.Size = UDim2.new(0.5, -8, 1, 0)
    r.Position = UDim2.new(0.5, 0, 0, 0)
    r.BackgroundTransparency = 1
    r.Text = v
    r.TextColor3 = C.Red
    r.TextSize = 11
    r.Font = Enum.Font.GothamBold
    r.TextXAlignment = Enum.TextXAlignment.Right
end
AddInfo("Hub", "ERDEVA HUB")
AddInfo("Game", "Chicken Farm")
AddInfo("Player", player.DisplayName)
AddInfo("Status", "Operational")

SetTab("Farm")
print("[ERDEVA HUB] All features fully armed and working!")
