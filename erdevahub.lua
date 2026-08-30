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
    AutoGrabScraps = false,
    AutoRecycleScrap = false,
    AutoUpgradeRecycler = false,
    ScrapCapacity = 20,
    AutoRebirth = false,
    AutoUpgradeCoop = false,
    AutoUpgradeFeeder = false,
    AutoBuyFeeders = false,
    AutoStartTower = false,
    AutoNoThanks = false,
    AutoStartChaos = false
}

local ToggleUpdaters = {}

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

RunService.Stepped:Connect(function()
    if IsRunning and (Flags.AutoGrabScraps or Flags.AutoRecycleScrap) then
        local char = GetChar()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

local function GetFlatDistance(posA, posB)
    return Vector2.new(posA.X - posB.X, posA.Z - posB.Z).Magnitude
end

local function GroundRunTo(targetPos, maxWait, stopDistance)
    if not IsRunning then return false end
    local root = GetRoot()
    local hum = GetHumanoid()
    if not root or not hum then return false end

    local stopDist = stopDistance or 2.2
    local start = tick()
    local timeout = maxWait or 3.0

    while IsRunning and GetFlatDistance(root.Position, targetPos) > stopDist and (tick() - start < timeout) do
        local dir = Vector3.new(targetPos.X - root.Position.X, 0, targetPos.Z - root.Position.Z).Unit
        root.AssemblyLinearVelocity = Vector3.new(dir.X * 22, root.AssemblyLinearVelocity.Y, dir.Z * 22)
        root.CFrame = CFrame.new(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
        hum:ChangeState(Enum.HumanoidStateType.Running)
        task.wait(0.02)
    end

    return GetFlatDistance(root.Position, targetPos) <= (stopDist + 1.0)
end

local mySavedPlot = nil
local mySavedRecycler = nil

local function DetectBase()
    if mySavedPlot and mySavedRecycler and mySavedRecycler.Parent then
        return mySavedPlot, mySavedRecycler
    end

    local root = GetRoot()

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            local text = (obj:IsA("TextLabel") and obj.Text or "")
            if (text:find(player.Name) or text:find(player.DisplayName)) and not text:find("Level") and not text:find("Health") then
                local pModel = obj:FindFirstAncestorWhichIsA("Model") or obj:FindFirstAncestorWhichIsA("Folder")
                if pModel and pModel ~= workspace then
                    mySavedPlot = pModel
                    break
                end
            end
        end
    end

    if not mySavedPlot then
        for _, folderName in ipairs({"Plots", "Farms", "Coops", "Islands"}) do
            local f = workspace:FindFirstChild(folderName)
            if f then
                for _, p in ipairs(f:GetChildren()) do
                    local owner = p:FindFirstChild("Owner") or p:FindFirstChild("Player") or p:FindFirstChild("UserId")
                    if (owner and (tostring(owner.Value) == player.Name or tostring(owner.Value) == tostring(player.UserId))) or (p.Name == player.Name or p.Name:find(player.Name)) then
                        mySavedPlot = p
                        break
                    end
                end
            end
            if mySavedPlot then break end
        end
    end

    if mySavedPlot then
        for _, child in ipairs(mySavedPlot:GetDescendants()) do
            local n = child.Name:lower()
            if (n:find("recycler") or n:find("deposit") or n:find("trashbin") or n:find("recycle")) and not n:find("upgrade") and not n:find("shop") and not n:find("button") then
                local part = child:IsA("BasePart") and child or child:FindFirstChildWhichIsA("BasePart")
                if part then mySavedRecycler = part break end
            end
        end
    end

    if not mySavedRecycler and root then
        local closest = nil
        local minD = 65
        for _, obj in ipairs(workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if (n:find("recycler") or n:find("deposit") or n:find("trashbin") or n:find("recycle")) and not n:find("upgrade") and not n:find("shop") and not n:find("button") then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local d = (root.Position - part.Position).Magnitude
                    if d < minD then
                        minD = d
                        closest = part
                    end
                end
            end
        end
        mySavedRecycler = closest
    end

    return mySavedPlot, mySavedRecycler
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

local function Trigger3DUpgrade(pattern)
    local plot = mySavedPlot or workspace
    pattern = pattern:lower()
    for _, obj in ipairs(plot:GetDescendants()) do
        local n = obj.Name:lower()
        local matches = n:find(pattern)
        if not matches and (obj:IsA("TextLabel") or obj:IsA("BillboardGui")) then
            local t = obj:IsA("TextLabel") and obj.Text:lower() or ""
            matches = t:find(pattern)
        end
        if matches then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local prompt = part:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    pcall(function() prompt:InputHoldBegin() task.wait(0.05) prompt:InputHoldEnd() end)
                end
                local click = part:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildOfClass("ClickDetector")
                if click and fireclickdetector then
                    pcall(function() fireclickdetector(click) end)
                end
            end
        end
    end

    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rn = remote.Name:lower()
            if rn:find(pattern) or (pattern:find("feeder") and (rn:find("buy") or rn:find("feed"))) or (pattern:find("coop") and rn:find("coop")) or (pattern:find("recycle") and rn:find("recycle")) then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer()
                    end
                end)
            end
        end
    end
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

local function IsGroundScrap(obj)
    if not obj:IsA("BasePart") or not obj.Parent then return false end
    local ancestorModel = obj:FindFirstAncestorOfClass("Model")
    if ancestorModel and ancestorModel:FindFirstChildOfClass("Humanoid") then
        return false
    end
    local n = obj.Name:lower()
    local pn = obj.Parent.Name:lower()
    if (n:find("scrap") or n:find("trash") or n:find("drop") or pn:find("scrap") or pn:find("trash")) and not n:find("recycler") and not n:find("feeder") and not n:find("upgrade") and not n:find("shop") and not n:find("button") then
        return true
    end
    return false
end

local collectedScraps = 0
local BlacklistedScraps = {}

task.spawn(function()
    while IsRunning do
        if Flags.AutoGrabScraps and not IsInBattle() then
            pcall(function()
                local root = GetRoot()
                local hum = GetHumanoid()
                if not root or not hum then task.wait(0.1) return end

                local targetCapacity = tonumber(Flags.ScrapCapacity) or 20
                local plot, myRecycler = DetectBase()

                if Flags.AutoRecycleScrap and myRecycler and collectedScraps >= targetCapacity then
                    GroundRunTo(myRecycler.Position, 4.0, 2.5)
                    root.AssemblyLinearVelocity = Vector3.zero
                    task.wait(1.5)
                    collectedScraps = 0
                    BlacklistedScraps = {}
                else
                    local closestPart = nil
                    local minDistance = 9999

                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if not Flags.AutoGrabScraps or not IsRunning then break end
                        if not BlacklistedScraps[obj] and IsGroundScrap(obj) then
                            local dist = GetFlatDistance(root.Position, obj.Position)
                            if dist < 85 and dist < minDistance then
                                minDistance = dist
                                closestPart = obj
                            end
                        end
                    end

                    if closestPart and collectedScraps < targetCapacity then
                        GroundRunTo(closestPart.Position, 1.6, 2.2)
                        BlacklistedScraps[closestPart] = true
                        collectedScraps = collectedScraps + 1
                    else
                        root.AssemblyLinearVelocity = Vector3.zero
                        BlacklistedScraps = {}
                        task.wait(0.08)
                    end
                end
            end)
        else
            task.wait(0.2)
        end
    end
end)

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

task.spawn(function()
    while IsRunning do
        if Flags.AutoRebirth and not IsInBattle() then
            pcall(function()
                local pGui = player:FindFirstChild("PlayerGui")
                if not pGui then return end

                local rebirthAvailable = false

                for _, b in ipairs(pGui:GetDescendants()) do
                    if (b:IsA("TextButton") or b:IsA("ImageButton")) and b.Visible then
                        local n = b.Name:lower() .. " " .. (b:IsA("TextButton") and b.Text:lower() or "")
                        if n:find("rebirth") and not n:find("autorebirth") then
                            rebirthAvailable = true
                            break
                        end
                    end
                end

                if rebirthAvailable then
                    ClickGuiByPattern("rebirth")
                    task.wait(0.3)

                    local canConfirm = false
                    for _, b in ipairs(pGui:GetDescendants()) do
                        if (b:IsA("TextButton") or b:IsA("ImageButton")) and b.Visible then
                            local n = (b:IsA("TextButton") and b.Text:lower() or "") .. " " .. b.Name:lower()
                            if (n:find("confirm") or n:find("yes") or n:find("do rebirth") or n:find("claim rebirth")) and not n:find("close") and not n:find("cancel") then
                                canConfirm = true
                                break
                            end
                        end
                    end

                    if canConfirm then
                        Trigger3DUpgrade("upgrade feeder")
                        Trigger3DUpgrade("upgrade incubator")
                        Trigger3DUpgrade("upgrade coop")
                        Trigger3DUpgrade("buy feeder")
                        ClickGuiByPattern("upgrade feeder")
                        ClickGuiByPattern("upgrade incubator")
                        ClickGuiByPattern("upgrade coop")
                        ClickGuiByPattern("buy feeder")
                        task.wait(0.2)

                        ClickGuiByPattern("confirm")
                        ClickGuiByPattern("yes")
                        ClickGuiByPattern("do rebirth")
                        ClickGuiByPattern("claim rebirth")

                        task.wait(3.0)
                        mySavedPlot = nil
                        mySavedRecycler = nil
                        collectedScraps = 0
                        BlacklistedScraps = {}
                        isTowerBusy = false
                    else
                        ClickGuiByPattern("close")
                    end
                end
            end)
        end
        task.wait(2.5)
    end
end)

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

task.spawn(function()
    while IsRunning do
        if Flags.AutoUpgradeRecycler and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("upgrade recycler")
                Trigger3DUpgrade("upgrade recycler")
                Trigger3DUpgrade("recycler")
            end)
        end
        if Flags.AutoUpgradeCoop and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("upgrade coop")
                Trigger3DUpgrade("upgrade coop")
                Trigger3DUpgrade("coop")
            end)
        end
        if Flags.AutoUpgradeFeeder and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("upgrade feeder")
                Trigger3DUpgrade("upgrade feeder")
                Trigger3DUpgrade("feeder")
            end)
        end
        if Flags.AutoBuyFeeders and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("buy feeder")
                Trigger3DUpgrade("buy feeder")
                Trigger3DUpgrade("buyfeeder")
            end)
        end
        task.wait(1.5)
    end
end)

local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "ERDEVA_HUB"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 9999

local function Shutdown()
    IsRunning = false
    for k in pairs(Flags) do
        Flags[k] = false
    end
    local root = GetRoot()
    local hum = GetHumanoid()
    if hum and root then
        root.AssemblyLinearVelocity = Vector3.zero
    end
    if Gui then
        Gui:Destroy()
    end
end

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
Close.MouseButton1Click:Connect(Shutdown)

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

local drag, dStart, fStart
local function SetupDrag(frame)
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dStart = i.Position
            fStart = Main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    drag = false
                end
            end)
        end
    end)
end

SetupDrag(Top)

UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        local cam = workspace.CurrentCamera
        local vSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)

        local curH = minState and 34 or H
        local targetX = fStart.X.Offset + d.X
        local targetY = fStart.Y.Offset + d.Y

        local clampedX = math.clamp(targetX, -vSize.X/2 + W/2 + 10, vSize.X/2 - W/2 - 10)
        local clampedY = math.clamp(targetY, -vSize.Y/2 + curH/2 + 25, vSize.Y/2 - curH/2 - 10)

        Main.Position = UDim2.new(0.5, clampedX, 0.5, clampedY)
    end
end)

local TabFrame = Instance.new("Frame", Main)
TabFrame.Size = UDim2.new(1, 0, 0, 28)
TabFrame.Position = UDim2.fromOffset(0, 34)
TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabFrame.BorderSizePixel = 0

local TabList = Instance.new("UIListLayout", TabFrame)
TabList.FillDirection = Enum.FillDirection.Horizontal

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

local function SetToggleState(flagKey, targetState)
    Flags[flagKey] = targetState
    if ToggleUpdaters[flagKey] then
        ToggleUpdaters[flagKey](targetState)
    end
end

local function AddToggle(parent, text, flagKey, defaultVal)
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
    b.BackgroundColor3 = (defaultVal and C.Red or Color3.fromRGB(50, 50, 50))
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    local k = Instance.new("Frame", b)
    k.Size = UDim2.fromOffset(14, 14)
    k.Position = (defaultVal and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2))
    k.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)

    local function updateVisual(on)
        tw(b, {BackgroundColor3 = (on and C.Red or Color3.fromRGB(50, 50, 50))})
        tw(k, {Position = (on and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2))})
    end

    ToggleUpdaters[flagKey] = updateVisual

    b.MouseButton1Click:Connect(function()
        local newState = not Flags[flagKey]
        SetToggleState(flagKey, newState)

        if flagKey == "AutoRebirth" then
            SetToggleState("AutoGrabScraps", newState)
            SetToggleState("AutoRecycleScrap", newState)
            SetToggleState("AutoUpgradeRecycler", newState)
            SetToggleState("AutoBuyFeeders", newState)
            SetToggleState("AutoUpgradeFeeder", newState)
            SetToggleState("AutoUpgradeCoop", newState)
            SetToggleState("AutoStartTower", newState)
            SetToggleState("AutoNoThanks", newState)
        end
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
            if val < 1 then val = 1 end
            vl.Text = tostring(val) .. "/" .. tostring(maxV)
            Flags[flagKey] = val
        end
    end)
end

local FarmPage = MakeTab("Farm", 1)
local PlotPage = MakeTab("Plot", 2)
local BattlePage = MakeTab("Battle", 3)
local InfoPage = MakeTab("Info", 4)

AddToggle(FarmPage, "Auto Open Eggs", "AutoOpenEggs", false)
AddToggle(FarmPage, "Auto Grab Scraps", "AutoGrabScraps", false)
AddToggle(FarmPage, "Auto Recycle Scrap", "AutoRecycleScrap", false)
AddToggle(FarmPage, "Auto Upgrade Recycler", "AutoUpgradeRecycler", false)
AddSlider(FarmPage, "Scrap Capacity", 50, 20, "ScrapCapacity")

AddToggle(PlotPage, "Auto Rebirth (Master)", "AutoRebirth", false)
AddToggle(PlotPage, "Auto Buy Feeders", "AutoBuyFeeders", false)
AddToggle(PlotPage, "Auto Upgrade Feeder", "AutoUpgradeFeeder", false)
AddToggle(PlotPage, "Auto Upgrade Coop", "AutoUpgradeCoop", false)

AddToggle(BattlePage, "Auto Start Tower", "AutoStartTower", false)
AddToggle(BattlePage, "Auto No Thanks", "AutoNoThanks", false)
AddToggle(BattlePage, "Auto Start Chaos", "AutoStartChaos", false)

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
