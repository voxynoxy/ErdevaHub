--[[
    ERDEVA HUB - Perfected Scrap Collector & Recycler
    - NoClip navigation (Never gets stuck on fences)
    - Stacks all scraps from coop
    - Physical Recycler Bin deposit (Fixed "Cash Not Enough" bug)
    - Smart Tower & Rebirth progression
    - Complete Shutdown on [X]
]]

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

local IsRunning = true

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
-- MOVEMENT & NOCLIP ENGINE
--==================================================

local function GetChar()
    return player.Character
end

local function GetRoot()
    local char = GetChar()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function GetHumanoid()
    local char = GetChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Continuous NoClip when auto-moving to prevent getting stuck on fences
local noclipConnection = nil
local isNoclipActive = false

local function SetNoClip(state)
    isNoclipActive = state
    if state and not noclipConnection then
        noclipConnection = RunService.Stepped:Connect(function()
            if not isNoclipActive or not IsRunning then return end
            local char = GetChar()
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end
        end)
    elseif not state and noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

-- Smooth, non-stuck movement
local function SafeGlideTo(targetPos, maxTime)
    if not IsRunning then return false end
    local root = GetRoot()
    local hum = GetHumanoid()
    if not root or not hum then return false end

    local dist = (root.Position - targetPos).Magnitude
    if dist <= 3.5 then return true end

    SetNoClip(true)
    local speed = 38
    local duration = math.clamp(dist / speed, 0.1, maxTime or 2)

    local targetCF = CFrame.new(targetPos.X, targetPos.Y + 2.5, targetPos.Z)
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCF})
    tween:Play()

    local start = tick()
    while IsRunning and (root.Position - targetPos).Magnitude > 3.5 and (tick() - start < duration + 0.15) do
        task.wait(0.04)
    end
    tween:Cancel()
    SetNoClip(false)
    return (root.Position - targetPos).Magnitude <= 5
end

-- Find the Recycler bin on the plot (Rusty box with pipe)
local function FindRecyclerBin()
    local root = GetRoot()
    if not root then return nil end
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("recycler") or n:find("recycle") or n:find("deposit") or n:find("trashbin")) and not n:find("upgrade") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part and (root.Position - part.Position).Magnitude < 180 then
                return part, obj
            end
        end
    end
    return nil, nil
end

local function ClickButton(btn)
    if not btn or not IsRunning then return end
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
    if not IsRunning then return false end
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

local function IsInBattle()
    local pGui = player:FindFirstChild("PlayerGui")
    if not pGui then return false end
    for _, g in ipairs(pGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled then
            local n = g.Name:lower()
            if n:find("battle") or n:find("fight") or n:find("tower") or n:find("arena") then
                for _, el in ipairs(g:GetDescendants()) do
                    if el:IsA("GuiObject") and el.Visible then
                        local en = el.Name:lower()
                        if en:find("health") or en:find("hp") or en:find("enemy") or en:find("round") then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

--==================================================
-- STATE MACHINE: SCRAP PICKUP & RECYCLER DEPOSIT
--==================================================

local collectedCount = 0
local ProcessedScraps = {}

task.spawn(function()
    while IsRunning do
        if Flags.AutoGrabScraps and not IsInBattle() then
            pcall(function()
                local root = GetRoot()
                if not root then task.wait(0.5) return end

                -- Check if we need to deposit to recycler
                if Flags.AutoRecycleScrap and collectedCount >= Flags.RecycleThreshold then
                    local recPart, recModel = FindRecyclerBin()
                    if recPart then
                        SafeGlideTo(recPart.Position, 2)
                        
                        -- Interact with recycler bin directly (NO purchase remotes!)
                        local prompt = recModel:FindFirstChildWhichIsA("ProximityPrompt", true) or recPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                        
                        local cd = recModel:FindFirstChildWhichIsA("ClickDetector", true) or recPart:FindFirstChildWhichIsA("ClickDetector", true)
                        if cd and fireclickdetector then fireclickdetector(cd) end
                        
                        if firetouchinterest then
                            firetouchinterest(root, recPart, 0)
                            firetouchinterest(root, recPart, 1)
                        end
                        
                        task.wait(0.6)
                        collectedCount = 0
                        ProcessedScraps = {}
                    end
                end

                -- Scan all scraps on the ground inside the coop
                local availableScraps = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not Flags.AutoGrabScraps or not IsRunning then break end
                    if not ProcessedScraps[obj] then
                        local n = obj.Name:lower()
                        local pn = obj.Parent and obj.Parent.Name:lower() or ""
                        if (n:find("scrap") or n:find("trash") or n:find("drop") or pn:find("scrap")) and not n:find("recycler") and not n:find("feeder") and not n:find("upgrade") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part and not ProcessedScraps[part] then
                                local dist = (root.Position - part.Position).Magnitude
                                if dist < 120 then
                                    table.insert(availableScraps, {Part = part, Obj = obj, Dist = dist})
                                end
                            end
                        end
                    end
                end

                -- Sort closest first
                table.sort(availableScraps, function(a, b) return a.Dist < b.Dist end)

                if #availableScraps > 0 then
                    local target = availableScraps[1]
                    SafeGlideTo(target.Part.Position, 1.2)

                    -- Trigger pickup
                    local prompt = target.Obj:FindFirstChildWhichIsA("ProximityPrompt", true) or target.Part:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and fireproximityprompt then fireproximityprompt(prompt) end

                    local cd = target.Obj:FindFirstChildWhichIsA("ClickDetector", true) or target.Part:FindFirstChildWhichIsA("ClickDetector", true)
                    if cd and fireclickdetector then fireclickdetector(cd) end

                    if firetouchinterest then
                        firetouchinterest(root, target.Part, 0)
                        firetouchinterest(root, target.Part, 1)
                    end

                    ProcessedScraps[target.Obj] = true
                    ProcessedScraps[target.Part] = true
                    collectedCount = collectedCount + 1
                    task.wait(0.08)
                else
                    -- No more scraps on ground: if holding any, deposit to recycler
                    if Flags.AutoRecycleScrap and collectedCount > 0 then
                        local recPart, recModel = FindRecyclerBin()
                        if recPart then
                            SafeGlideTo(recPart.Position, 2)
                            local prompt = recModel:FindFirstChildWhichIsA("ProximityPrompt", true) or recPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                            if firetouchinterest then
                                firetouchinterest(root, recPart, 0)
                                firetouchinterest(root, recPart, 1)
                            end
                            task.wait(0.5)
                            collectedCount = 0
                        end
                    end
                    ProcessedScraps = {}
                    task.wait(0.3)
                end
            end)
        else
            task.wait(0.5)
        end
    end
end)

--==================================================
-- AUTOMATION: TOWER, REBIRTH & UPGRADES
--==================================================

-- AUTO TOWER (Start -> Wait Fight -> Claim -> Return)
local isTowerBusy = false
task.spawn(function()
    while IsRunning do
        if Flags.AutoStartTower and not isTowerBusy then
            pcall(function()
                if not IsInBattle() then
                    isTowerBusy = true
                    ClickGuiByPattern("tower")

                    task.wait(2.5)
                    local elapsed = 0
                    while elapsed < 90 and IsRunning and Flags.AutoStartTower do
                        task.wait(1)
                        elapsed = elapsed + 1

                        ClickGuiByPattern("claim")
                        ClickGuiByPattern("next floor")
                        ClickGuiByPattern("victory")
                        ClickGuiByPattern("no thanks")
                        ClickGuiByPattern("nothanks")
                        ClickGuiByPattern("continue")

                        if not IsInBattle() and elapsed > 5 then
                            break
                        end
                    end

                    task.wait(1.5)
                    isTowerBusy = false
                end
            end)
        end
        task.wait(1)
    end
end)

-- AUTO REBIRTH
task.spawn(function()
    while IsRunning do
        if Flags.AutoRebirth and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("rebirth")
                task.wait(0.25)
                ClickGuiByPattern("confirm")
                ClickGuiByPattern("yes")
                ClickGuiByPattern("do rebirth")
            end)
        end
        task.wait(1.5)
    end
end)

-- AUTO NO THANKS
task.spawn(function()
    while IsRunning do
        if Flags.AutoNoThanks then
            pcall(function()
                ClickGuiByPattern("no thanks")
                ClickGuiByPattern("nothanks")
                ClickGuiByPattern("skip")
                ClickGuiByPattern("claim")
                ClickGuiByPattern("close")
            end)
        end
        task.wait(0.35)
    end
end)

-- AUTO CHAOS
task.spawn(function()
    while IsRunning do
        if Flags.AutoStartChaos and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("to chaos")
                ClickGuiByPattern("chaos")
                task.wait(3)
            end)
        end
        task.wait(1)
    end
end)

-- AUTO OPEN EGGS
task.spawn(function()
    while IsRunning do
        if Flags.AutoOpenEggs and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("hatch")
                ClickGuiByPattern("open")
                ClickGuiByPattern("egg")
            end)
        end
        task.wait(0.6)
    end
end)

-- AUTO FUSE CHICKENS
task.spawn(function()
    while IsRunning do
        if Flags.AutoFuseChickens and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("fuse")
                ClickGuiByPattern("merge")
            end)
        end
        task.wait(1)
    end
end)

-- AUTO UPGRADE RECYCLER, COOP & FEEDERS
task.spawn(function()
    while IsRunning do
        if Flags.AutoUpgradeRecycler and not IsInBattle() then
            pcall(function() ClickGuiByPattern("upgrade recycler") end)
        end
        if Flags.AutoUpgradeCoop and not IsInBattle() then
            pcall(function() ClickGuiByPattern("upgrade coop") end)
        end
        if Flags.AutoUpgradeFeeder and not IsInBattle() then
            pcall(function() ClickGuiByPattern("upgrade feeder") end)
        end
        if Flags.AutoBuyFeeders and not IsInBattle() then
            pcall(function() ClickGuiByPattern("buy feeder") end)
        end
        task.wait(1)
    end
end)

--==================================================
-- CLEAN SHUTDOWN FUNCTION
--==================================================

local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "ERDEVA_HUB"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 9999

local function Shutdown()
    IsRunning = false
    SetNoClip(false)
    for k in pairs(Flags) do
        Flags[k] = false
    end
    local root = GetRoot()
    local hum = GetHumanoid()
    if hum and root then
        hum:MoveTo(root.Position)
    end
    if Gui then
        Gui:Destroy()
    end
    print("[ERDEVA HUB] Terminated.")
end

--==================================================
-- GUI CREATION
--==================================================

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

-- Close Button
local Close = Instance.new("TextButton", Top)
Close.Size = UDim2.fromOffset(24, 24)
Close.Position = UDim2.new(1, -28, 0.5, -12)
Close.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Close.Text = "✕"
Close.TextColor3 = C.Sub
Close.TextSize = 11
Close.Font = Enum.Font.GothamBold
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 5)
Close.MouseButton1Click:Connect(Shutdown)

-- Minimize Button
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
print("[ERDEVA HUB] State machine ready.")
