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

local function GetChar() return player.Character end
local function GetRoot()
    local char = GetChar()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end
local function GetHumanoid()
    local char = GetChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetFlatDistance(posA, posB)
    return Vector2.new(posA.X - posB.X, posA.Z - posB.Z).Magnitude
end

local function GroundRunTo(targetPos, maxWait, stopDistance)
    if not IsRunning then return false end
    local hum = GetHumanoid()
    local root = GetRoot()
    if not hum or not root then return false end
    local stopDist = stopDistance or 3.5
    local timeout = maxWait or 8.0
    local start = tick()
    hum.WalkSpeed = 16
    while IsRunning and GetFlatDistance(root.Position, targetPos) > stopDist and (tick() - start < timeout) do
        hum:MoveTo(targetPos)
        task.wait(0.08 + math.random() * 0.04)
    end
    return GetFlatDistance(root.Position, targetPos) <= (stopDist + 2.0)
end


-- STRICT RECYCLER LOCK: satu-satunya sumber kebenaran posisi recycler milikku
local RECYCLER_POS = nil  -- hanya diisi oleh user klik tombol atau auto-detect SEKALI

local function SetRecyclerByCurrentPos()
    local root = GetRoot()
    if root then
        RECYCLER_POS = root.Position
        return true
    end
    return false
end

local function GetRecyclerPos()
    return RECYCLER_POS
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
    pattern = pattern:lower()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        local matches = n:find(pattern)
        if not matches and (obj:IsA("TextLabel") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui")) then
            local t = (obj:IsA("TextLabel") and obj.Text:lower() or "") .. " " .. obj.Name:lower()
            if t:find(pattern) then matches = true end
        end
        if matches then
            local root = GetRoot()
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart") or (obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent)
            if part and root and (root.Position - part.Position).Magnitude < 200 then
                local prompt = part:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    pcall(function()
                        if fireproximityprompt then fireproximityprompt(prompt)
                        else prompt:InputHoldBegin() task.wait(0.05) prompt:InputHoldEnd() end
                    end)
                end
                local click = part:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildOfClass("ClickDetector")
                if click and fireclickdetector then pcall(function() fireclickdetector(click) end) end
            end
        end
    end
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rn = remote.Name:lower()
            if rn:find(pattern) or (pattern:find("feeder") and (rn:find("buy") or rn:find("feed"))) or (pattern:find("coop") and rn:find("coop")) or (pattern:find("recycle") and rn:find("recycle")) then
                pcall(function()
                    if remote:IsA("RemoteEvent") then remote:FireServer()
                    elseif remote:IsA("RemoteFunction") then remote:InvokeServer() end
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
    if ancestorModel and ancestorModel:FindFirstChildOfClass("Humanoid") then return false end
    local n = obj.Name:lower()
    local pn = obj.Parent.Name:lower()
    local ppn = obj.Parent.Parent and obj.Parent.Parent.Name:lower() or ""
    return (n:find("scrap") or n:find("trash") or n:find("drop") or n:find("plate") or n:find("poop")
        or pn:find("scrap") or pn:find("trash") or pn:find("drop")
        or ppn:find("scrap") or ppn:find("drop"))
        and not n:find("recycler") and not n:find("feeder") and not n:find("upgrade")
        and not n:find("shop") and not n:find("button")
end

local collectedScraps = 0
local BlacklistedScraps = {}
local IsBusy = false  -- ketika true, loop scrap berhenti bergerak

task.spawn(function()
    while IsRunning do
        if Flags.AutoGrabScraps and not IsInBattle() and not IsBusy then
            pcall(function()
                local root = GetRoot()
                local hum = GetHumanoid()
                if not root or not hum then task.wait(0.1) return end

                local targetCapacity = tonumber(Flags.ScrapCapacity) or 20
                local recyclerPos = GetRecyclerPos()

                if Flags.AutoRecycleScrap and recyclerPos and collectedScraps >= targetCapacity then
                    GroundRunTo(recyclerPos, 8.0, 3.0)
                    task.wait(1.2 + math.random() * 0.6)
                    collectedScraps = 0
                    BlacklistedScraps = {}
                else
                    local closestPart = nil
                    local minDistance = 9999
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if not Flags.AutoGrabScraps or not IsRunning then break end
                        if not BlacklistedScraps[obj] and IsGroundScrap(obj) then
                            local dist = GetFlatDistance(root.Position, obj.Position)
                            if dist < 400 and dist < minDistance then
                                minDistance = dist
                                closestPart = obj
                            end
                        end
                    end
                    if closestPart and collectedScraps < targetCapacity then
                        GroundRunTo(closestPart.Position, 4.0, 3.0)
                        task.wait(0.15 + math.random() * 0.2)
                        BlacklistedScraps[closestPart] = true
                        collectedScraps = collectedScraps + 1
                    else
                        BlacklistedScraps = {}
                        task.wait(0.3 + math.random() * 0.3)
                    end
                end
            end)
        else
            task.wait(0.25)
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
                        if not IsInBattle() and elapsed > 5 then break end
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
                        Trigger3DUpgrade("upgrade coop")
                        Trigger3DUpgrade("buy feeder")
                        ClickGuiByPattern("upgrade feeder")
                        ClickGuiByPattern("upgrade coop")
                        ClickGuiByPattern("buy feeder")
                        task.wait(0.2)
                        ClickGuiByPattern("confirm")
                        ClickGuiByPattern("yes")
                        ClickGuiByPattern("do rebirth")
                        ClickGuiByPattern("claim rebirth")
                        task.wait(3.0)
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

-- Jalan ke pad fisik di world, lalu tekan semua ProximityPrompt/ClickDetector yang cocok
local function WalkAndFireAllPrompts(patterns)
    local root = GetRoot()
    if not root then return end

    local targets = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local combined = ""
        if obj:IsA("ProximityPrompt") then
            local actionText = obj.ActionText:lower()
            local objectText = obj.ObjectText:lower()
            local parentName = (obj.Parent and obj.Parent.Name:lower()) or ""
            local grandName = (obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name:lower()) or ""
            combined = actionText .. " " .. objectText .. " " .. parentName .. " " .. grandName
        elseif obj:IsA("ClickDetector") then
            local parentName = (obj.Parent and obj.Parent.Name:lower()) or ""
            local grandName = (obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name:lower()) or ""
            combined = parentName .. " " .. grandName
        end
        if combined ~= "" then
            for _, pat in ipairs(patterns) do
                if combined:find(pat) then
                    table.insert(targets, obj)
                    break
                end
            end
        end
    end

    if #targets == 0 then return end

    -- Pause loop scrap agar tidak berebut kontrol karakter
    IsBusy = true
    local savedPos = root.Position

    for _, prompt in ipairs(targets) do
        if not IsRunning then break end
        local part = prompt.Parent
        if not part or not part:IsA("BasePart") then continue end
        root = GetRoot()
        if not root then break end
        local dist = (root.Position - part.Position).Magnitude
        if dist < 400 then
            GroundRunTo(part.Position, 4.0, 3.0)
            task.wait(0.2)
            -- Coba semua metode tekan [E] sampai salah satu berhasil
            pcall(function()
                if prompt:IsA("ProximityPrompt") then
                    -- Metode 1: fireproximityprompt (paling umum di executor)
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    end
                    -- Metode 2: InputHoldBegin / InputHoldEnd
                    pcall(function()
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration + 0.05)
                        prompt:InputHoldEnd()
                    end)
                    -- Metode 3: Simulasi tekan E via VirtualInputManager
                    pcall(function()
                        local vim = game:GetService("VirtualInputManager")
                        vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end)
                    -- Metode 4: firesignal jika tersedia
                    if firesignal then
                        pcall(function() firesignal(prompt.Triggered, player) end)
                    end
                elseif prompt:IsA("ClickDetector") then
                    if fireclickdetector then fireclickdetector(prompt) end
                    pcall(function() prompt.MouseClick:Fire(player) end)
                end
            end)
            task.wait(0.4)
        end
    end

    -- Kembalikan karakter ke posisi semula (dekat arena scrap)
    local root2 = GetRoot()
    if root2 then
        GroundRunTo(savedPos, 3.0, 4.0)
    end
    IsBusy = false
end

task.spawn(function()
    while IsRunning do
        if Flags.AutoUpgradeRecycler and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("upgrade recycler")
                Trigger3DUpgrade("recycler")
                WalkAndFireAllPrompts({"recycler", "upgrade recycler"})
            end)
        end
        if Flags.AutoUpgradeCoop and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("upgrade coop")
                Trigger3DUpgrade("coop")
                WalkAndFireAllPrompts({"coop", "upgrade coop"})
            end)
        end
        if Flags.AutoUpgradeFeeder and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("upgrade feeder")
                Trigger3DUpgrade("feeder")
                WalkAndFireAllPrompts({"upgrade feeder", "feeder upgrade", "feeder"})
            end)
        end
        if Flags.AutoBuyFeeders and not IsInBattle() then
            pcall(function()
                ClickGuiByPattern("buy feeder")
                Trigger3DUpgrade("buy feeder")
                WalkAndFireAllPrompts({"buy feeder", "buy feed", "purchase feeder", "feeder"})
            end)
        end
        task.wait(2.0)
    end
end)

-- ===== GUI =====

local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "ERDEVA_HUB"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 9999

local function Shutdown()
    IsRunning = false
    for k in pairs(Flags) do Flags[k] = false end
    local root = GetRoot()
    if root then root.AssemblyLinearVelocity = Vector3.zero end
    if Gui then Gui:Destroy() end
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
Top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dStart = i.Position
        fStart = Main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        local cam = workspace.CurrentCamera
        local vSize = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        Main.Position = UDim2.new(0.5, math.clamp(fStart.X.Offset + d.X, -vSize.X/2+W/2+10, vSize.X/2-W/2-10), 0.5, math.clamp(fStart.Y.Offset + d.Y, -vSize.Y/2+(minState and 34 or H)/2+25, vSize.Y/2-(minState and 34 or H)/2-10))
    end
end)

local TabFrame = Instance.new("Frame", Main)
TabFrame.Size = UDim2.new(1, 0, 0, 28)
TabFrame.Position = UDim2.fromOffset(0, 34)
TabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabFrame.BorderSizePixel = 0
Instance.new("UIListLayout", TabFrame).FillDirection = Enum.FillDirection.Horizontal

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

local Pages, TabBtns = {}, {}
local function SetTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(TabBtns) do
        tw(b, {BackgroundColor3 = (n == name and Color3.fromRGB(40,14,14) or Color3.fromRGB(18,18,18)), TextColor3 = (n == name and C.Txt or C.Sub)})
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

local function SetToggleState(flagKey, state)
    Flags[flagKey] = state
    if ToggleUpdaters[flagKey] then ToggleUpdaters[flagKey](state) end
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

    local function updateVisual(on)
        tw(b, {BackgroundColor3 = (on and C.Red or Color3.fromRGB(50, 50, 50))})
        tw(k, {Position = (on and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2))})
    end
    ToggleUpdaters[flagKey] = updateVisual

    b.MouseButton1Click:Connect(function()
        local newState = not Flags[flagKey]
        SetToggleState(flagKey, newState)
        if flagKey == "AutoRebirth" then
            for _, key in ipairs({"AutoGrabScraps","AutoRecycleScrap","AutoUpgradeRecycler","AutoBuyFeeders","AutoUpgradeFeeder","AutoUpgradeCoop","AutoStartTower","AutoNoThanks"}) do
                SetToggleState(key, newState)
            end
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
            local val = math.max(1, math.floor(r * maxV + 0.5))
            vl.Text = tostring(val) .. "/" .. tostring(maxV)
            Flags[flagKey] = val
        end
    end)
end

local FarmPage = MakeTab("Farm", 1)
local PlotPage = MakeTab("Plot", 2)
local BattlePage = MakeTab("Battle", 3)
local InfoPage = MakeTab("Info", 4)

AddToggle(FarmPage, "Auto Open Eggs", "AutoOpenEggs")
AddToggle(FarmPage, "Auto Grab Scraps", "AutoGrabScraps")
AddToggle(FarmPage, "Auto Recycle Scrap", "AutoRecycleScrap")
AddToggle(FarmPage, "Auto Upgrade Recycler", "AutoUpgradeRecycler")
AddSlider(FarmPage, "Scrap Capacity", 50, 20, "ScrapCapacity")

AddToggle(PlotPage, "Auto Rebirth (Master)", "AutoRebirth")
AddToggle(PlotPage, "Auto Buy Feeders", "AutoBuyFeeders")
AddToggle(PlotPage, "Auto Upgrade Feeder", "AutoUpgradeFeeder")
AddToggle(PlotPage, "Auto Upgrade Coop", "AutoUpgradeCoop")

-- TOMBOL SET BASE — PERBAIKAN MUTLAK
local setBaseBtnLabel = nil
do
    local f = Instance.new("Frame", PlotPage)
    f.Size = UDim2.new(1, 0, 0, 56)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", f)
    stroke.Color = C.Red
    stroke.Thickness = 1

    local info = Instance.new("TextLabel", f)
    info.Size = UDim2.new(1, -8, 0, 18)
    info.Position = UDim2.fromOffset(4, 2)
    info.BackgroundTransparency = 1
    info.Text = "⚠ Berdiri di Recycler kamu, lalu klik:"
    info.TextColor3 = Color3.fromRGB(255, 200, 50)
    info.TextSize = 10
    info.Font = Enum.Font.GothamBold
    info.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.Position = UDim2.fromOffset(4, 22)
    btn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    btn.Text = "📌 KUNCI POSISI RECYCLER SAYA"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    setBaseBtnLabel = btn

    btn.MouseButton1Click:Connect(function()
        local ok = SetRecyclerByCurrentPos()
        if ok then
            btn.Text = "✅ TERKUNCI! Bot hanya ke posisi ini"
            btn.BackgroundColor3 = Color3.fromRGB(20, 120, 20)
            task.delay(2, function()
                if btn and btn.Parent then
                    btn.Text = "📌 KUNCI POSISI RECYCLER SAYA"
                    btn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
                end
            end)
        end
    end)
end

AddToggle(BattlePage, "Auto Start Tower", "AutoStartTower")
AddToggle(BattlePage, "Auto No Thanks", "AutoNoThanks")
AddToggle(BattlePage, "Auto Start Chaos", "AutoStartChaos")

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
