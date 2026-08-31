local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

pcall(function()
    if CoreGui:FindFirstChild("ERDEVA_HUB") then
        CoreGui:FindFirstChild("ERDEVA_HUB"):Destroy()
    end
    if CoreGui:FindFirstChild("ERDEVA_NOTIF") then
        CoreGui:FindFirstChild("ERDEVA_NOTIF"):Destroy()
    end
end)

local IsRunning = true
local W, H = 420, 250

local C = {
    Bg   = Color3.fromRGB(14, 14, 14),
    Top  = Color3.fromRGB(20, 20, 20),
    Card = Color3.fromRGB(22, 22, 22),
    Red  = Color3.fromRGB(220, 35, 35),
    Txt  = Color3.fromRGB(240, 240, 240),
    Sub  = Color3.fromRGB(150, 150, 150),
}

local function tw(o, p, t)
    TweenService:Create(o, TweenInfo.new(t or 0.15), p):Play()
end

-- NOTIFIKASI KANAN BAWAH
local function Notify(title, desc, duration)
    duration = duration or 4.5
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = desc, Duration = duration })
    end)
    task.spawn(function()
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "ERDEVA_NOTIF"
        notifGui.ResetOnSpawn = false
        notifGui.DisplayOrder = 10000
        pcall(function() notifGui.Parent = CoreGui end)
        if not notifGui.Parent then notifGui.Parent = player:FindFirstChild("PlayerGui") end

        local box = Instance.new("Frame", notifGui)
        box.Size = UDim2.fromOffset(260, 64)
        box.AnchorPoint = Vector2.new(1, 1)
        box.Position = UDim2.new(1, 280, 1, -20)
        box.BackgroundColor3 = C.Bg
        box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", box)
        stroke.Color = C.Red
        stroke.Thickness = 1.2

        local glow = Instance.new("Frame", box)
        glow.Size = UDim2.new(0, 4, 1, -12)
        glow.Position = UDim2.fromOffset(6, 6)
        glow.BackgroundColor3 = C.Red
        glow.BorderSizePixel = 0
        Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)

        local tLabel = Instance.new("TextLabel", box)
        tLabel.Size = UDim2.new(1, -25, 0, 20)
        tLabel.Position = UDim2.fromOffset(18, 8)
        tLabel.BackgroundTransparency = 1
        tLabel.Text = title
        tLabel.TextColor3 = C.Txt
        tLabel.TextSize = 13
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextXAlignment = Enum.TextXAlignment.Left

        local dLabel = Instance.new("TextLabel", box)
        dLabel.Size = UDim2.new(1, -25, 0, 28)
        dLabel.Position = UDim2.fromOffset(18, 28)
        dLabel.BackgroundTransparency = 1
        dLabel.Text = desc
        dLabel.TextColor3 = C.Sub
        dLabel.TextSize = 10
        dLabel.Font = Enum.Font.GothamMedium
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.TextWrapped = true

        box:TweenPosition(UDim2.new(1, -20, 1, -20), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.4, true)
        task.wait(duration)
        if box and box.Parent then
            box:TweenPosition(UDim2.new(1, 280, 1, -20), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.35, true)
            task.wait(0.4)
            pcall(function() notifGui:Destroy() end)
        end
    end)
end

Notify("ERDEVA HUB", "Chicken Farm Script Loaded! Ready to farm.", 4.5)

local Flags = {
    AutoOpenEggs        = false,
    AutoGrabScraps      = false,
    AutoRecycleScrap    = false,
    AutoUpgradeRecycler = false,
    ScrapCapacity       = 20,
    AutoRebirth         = false,
    AutoUpgradeCoop     = false,
    AutoUpgradeFeeder   = false,
    AutoBuyFeeders      = false,
    AutoStartTower      = false,
    TowerMinLevel       = 50,
    AutoNoThanks        = false,
    AutoStartChaos      = false,
}

local ToggleUpdaters = {}
local CurrentBatchScraps = 0
local ConsecutiveFails = 0

local function GetChar() return player.Character end
local function GetRoot()
    local c = GetChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end
local function GetHumanoid()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local State = {
    IDLE       = "IDLE",
    COLLECTING = "COLLECTING",
    RECYCLING  = "RECYCLING",
    UPGRADING  = "UPGRADING",
    TOWER      = "TOWER",
    REBIRTH    = "REBIRTH",
    WAITING    = "WAITING",
}

local CurrentState = State.IDLE
local StateStartedAt = tick()
local ActionCooldowns = {}
local GuiCooldowns = {}
local BlacklistedScraps = {}

local STATE_TIMEOUTS = {
    [State.COLLECTING] = 15,
    [State.RECYCLING]  = 4,
    [State.UPGRADING]  = 4,
    [State.TOWER]      = 120,
    [State.REBIRTH]    = 10,
    [State.WAITING]    = 4,
}

local function SetState(newState)
    if CurrentState ~= newState then
        CurrentState = newState
        StateStartedAt = tick()
    end
end

local function CanRunAction(action, cooldown)
    local now = tick()
    if ActionCooldowns[action] and now - ActionCooldowns[action] < cooldown then
        return false
    end
    ActionCooldowns[action] = now
    return true
end

local function ApplyNoCollision(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    CurrentBatchScraps = 0
    ConsecutiveFails = 0
    if IsRunning then ApplyNoCollision(char) end
end)
ApplyNoCollision(GetChar())

local function FlatDist(a, b)
    return Vector2.new(a.X - b.X, a.Z - b.Z).Magnitude
end

local function FastTouch(part)
    local root = GetRoot()
    if not root or not part or not part:IsA("BasePart") then return end
    if firetouchinterest then
        firetouchinterest(root, part, 0)
        task.wait()
        firetouchinterest(root, part, 1)
    end
end

local function TriggerPrompt(prompt)
    if not prompt or not prompt.Parent then return false end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait((prompt.HoldDuration or 0) + 0.02)
            prompt:InputHoldEnd()
        end
    end)
    return true
end

local function TriggerNearbyPrompt(keyword, radius)
    local root = GetRoot()
    if not root then return false end
    keyword = keyword and keyword:lower() or nil
    radius = radius or 14
    local best, bestDist = nil, radius
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent or obj:FindFirstAncestorWhichIsA("BasePart")
            if part then
                local text = (obj.ActionText .. " " .. obj.ObjectText .. " " .. obj.Name .. " " .. part.Name):lower()
                local d = (root.Position - part.Position).Magnitude
                if d <= bestDist and (not keyword or text:find(keyword)) then
                    best = obj
                    bestDist = d
                end
            end
        end
    end
    if best then return TriggerPrompt(best) end
    return false
end

local function WalkTo(targetPos, timeout, stopDist)
    if not IsRunning then return false end
    local hum = GetHumanoid()
    local root = GetRoot()
    if not hum or not root then return false end
    stopDist = stopDist or 2.5
    timeout = timeout or 2.2
    local t0 = tick()
    local char = GetChar()

    while IsRunning and tick() - t0 < timeout do
        if GetChar() ~= char then return false end
        hum = GetHumanoid()
        root = GetRoot()
        if not hum or not root or hum.Health <= 0 then return false end
        
        local d = FlatDist(root.Position, targetPos)
        if d <= stopDist then return true end

        hum:MoveTo(targetPos)
        task.wait(0.03)
    end

    root = GetRoot()
    return root and FlatDist(root.Position, targetPos) <= (stopDist + 2.0)
end

local RECYCLER_POS = nil
local function LockRecycler()
    local root = GetRoot()
    if root then
        RECYCLER_POS = root.Position
        return true
    end
    return false
end

local function ClickGuiButton(btn)
    if not btn or not btn.Parent then return false end
    pcall(function()
        if getconnections then
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
            for _, c in ipairs(getconnections(btn.Activated)) do c:Fire() end
        end
        if firesignal then 
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        end
    end)
    return true
end

local function ButtonText(btn)
    if not btn then return "" end
    return ((btn:IsA("TextButton") and btn.Text or "") .. " " .. btn.Name):lower()
end

local function IsVisibleGui(obj)
    if not obj:IsA("GuiObject") or not obj.Visible then return false end
    local cur = obj.Parent
    while cur and cur:IsA("GuiObject") do
        if not cur.Visible then return false end
        cur = cur.Parent
    end
    return true
end

-- AUTO CLOSE POPUP "NOT ENOUGH CASH" & POPUP SHOP
local function DismissAllPopups()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    local clicked = false
    
    for _, gui in ipairs(pg:GetDescendants()) do
        if gui:IsA("GuiObject") and IsVisibleGui(gui) then
            local name = gui.Name:lower()
            local text = (gui:IsA("TextLabel") and gui.Text:lower()) or ""
            
            if text:find("not enough cash") or text:find("not enough") or name:find("notenoughcash") then
                local container = gui.Parent
                while container and container ~= pg do
                    for _, b in ipairs(container:GetDescendants()) do
                        if (b:IsA("TextButton") or b:IsA("ImageButton")) and IsVisibleGui(b) then
                            local btnTxt = ButtonText(b)
                            if btnTxt:find("x") or btnTxt:find("close") or btnTxt:find("exit") or b.Name:lower() == "x" or b.Name:lower() == "close" or b.Name:lower() == "closebtn" then
                                clicked = ClickGuiButton(b) or clicked
                            end
                        end
                    end
                    container = container.Parent
                end
            end
            
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and (gui.Name:lower() == "x" or gui.Name:lower() == "close" or gui.Name:lower() == "closebutton") then
                local parentName = gui.Parent and gui.Parent.Name:lower() or ""
                if parentName:find("popup") or parentName:find("frame") or parentName:find("modal") or parentName:find("shop") or parentName:find("cash") then
                    clicked = ClickGuiButton(gui) or clicked
                end
            end
        end
    end
    return clicked
end

task.spawn(function()
    while IsRunning do
        pcall(function()
            DismissAllPopups()
        end)
        task.wait(0.2)
    end
end)

local function TryClickGuiAction(actionName, patterns, cooldown)
    if not IsRunning or not CanRunAction("GUI_" .. actionName, cooldown or 1.0) then return false end
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, b in ipairs(pg:GetDescendants()) do
        if (b:IsA("TextButton") or b:IsA("ImageButton")) and IsVisibleGui(b) then
            local text = ButtonText(b)
            for _, pat in ipairs(patterns) do
                if text:find(pat) then
                    local key = actionName .. ":" .. b:GetFullName()
                    if not GuiCooldowns[key] or tick() - GuiCooldowns[key] > (cooldown or 1.0) then
                        GuiCooldowns[key] = tick()
                        return ClickGuiButton(b)
                    end
                end
            end
        end
    end
    return false
end

-- DETEKSI LEMPENGAN SCRAP DI LANTAI SECARA AKURAT
local function IsGroundScrap(obj)
    if not obj:IsA("BasePart") or not obj.Parent then return false end
    
    -- Jangan ambil part dari karakter player
    local char = GetChar()
    if char and obj:IsDescendantOf(char) then return false end
    local anc = obj:FindFirstAncestorOfClass("Model")
    if anc and anc:FindFirstChildOfClass("Humanoid") then return false end
    
    local n = obj.Name:lower()
    local pn = obj.Parent.Name:lower()
    local ppn = (obj.Parent.Parent and obj.Parent.Parent.Name:lower()) or ""
    
    -- Cek nama atau bentuk lempengan/plat di lantai
    local isScrapName = (n:find("scrap") or n:find("plate") or n:find("trash") or n:find("drop") or n:find("poop") or pn:find("scrap") or pn:find("plate") or pn:find("trash") or pn:find("drop") or ppn:find("scrap"))
    local isExcluded = (n:find("recycler") or n:find("feeder") or n:find("upgrade") or n:find("shop") or n:find("button") or n:find("coop") or pn:find("recycler") or pn:find("feeder") or pn:find("shop") or n:find("arena") or pn:find("arena") or n:find("floor") or n:find("base") or n:find("fence"))
    
    if isScrapName and not isExcluded then return true end
    
    -- Deteksi bentuk plat tipis jika nama tidak spesifik (lebar 1-5 studs, tebal < 0.8)
    if not isExcluded and obj.Size.Y < 0.8 and obj.Size.X > 0.8 and obj.Size.Z > 0.8 and obj.Size.X < 6 and obj.Size.Z < 6 then
        if obj.Position.Y < 50 and (obj.Material == Enum.Material.CorrodedMetal or obj.Material == Enum.Material.Metal or obj.Material == Enum.Material.SmoothPlastic or obj.Material == Enum.Material.Neon) then
            return true
        end
    end
    
    return false
end

local function CleanupScrapBlacklist()
    local now = tick()
    for scrap, t in pairs(BlacklistedScraps) do
        if typeof(scrap) ~= "Instance" or not scrap.Parent or now - t > 3.0 then
            BlacklistedScraps[scrap] = nil
        end
    end
end

local function FindBestScrap()
    CleanupScrapBlacklist()
    local root = GetRoot()
    if not root then return nil end
    local best, bestDist = nil, 9999
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if IsGroundScrap(obj) and not BlacklistedScraps[obj] then
            local d = FlatDist(root.Position, obj.Position)
            if d < 350 and d < bestDist then
                best = obj
                bestDist = d
            end
        end
    end
    return best
end

-- AMBIL LEMPENGAN PLAT DENGAN CEPAT
local function TryCollectScrap(scrap)
    if not scrap or not scrap.Parent or not IsGroundScrap(scrap) then return false end
    
    local root = GetRoot()
    if not root then return false end
    
    FastTouch(scrap)
    local reached = WalkTo(scrap.Position, 1.5, 2.5)
    FastTouch(scrap)
    TriggerNearbyPrompt("scrap", 10)

    local disappeared = not scrap.Parent
    if disappeared or reached then
        CurrentBatchScraps = CurrentBatchScraps + 1
        ConsecutiveFails = 0
        BlacklistedScraps[scrap] = nil
        return true
    else
        ConsecutiveFails = ConsecutiveFails + 1
        BlacklistedScraps[scrap] = tick()
        return false
    end
end

local function FindPadByKeywords(keywords)
    local root = GetRoot()
    if not root then return nil end
    local bestObj, bestDist = nil, 9999
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        local targetPart, prompt = nil, nil
        local matched = false

        if obj:IsA("ProximityPrompt") then
            local part = obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent or obj:FindFirstAncestorWhichIsA("BasePart")
            local text = (obj.ActionText .. " " .. obj.ObjectText .. " " .. obj.Name .. " " .. (part and part.Name or "")):lower()
            for _, kw in ipairs(keywords) do
                if text:find(kw:lower()) then
                    matched = true
                    targetPart = part
                    prompt = obj
                    break
                end
            end
        elseif obj:IsA("TextLabel") or obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            local text = (obj:IsA("TextLabel") and obj.Text or ""):lower()
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if text:find(kw:lower()) or name:find(kw:lower()) then
                    matched = true
                    targetPart = obj:FindFirstAncestorWhichIsA("BasePart")
                    if targetPart then
                        prompt = targetPart:FindFirstChildOfClass("ProximityPrompt") or targetPart:FindFirstChildOfClass("ClickDetector")
                    end
                    break
                end
            end
        elseif obj:IsA("BasePart") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw:lower()) then
                    matched = true
                    targetPart = obj
                    prompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ClickDetector")
                    break
                end
            end
        end

        if matched and targetPart and targetPart:IsA("BasePart") then
            local d = (root.Position - targetPart.Position).Magnitude
            if d < 300 and d < bestDist then
                bestDist = d
                bestObj = { part = targetPart, prompt = prompt }
            end
        end
    end
    return bestObj
end

local function ExecutePadAction(actionName, keywords, guiPatterns, cooldown)
    if not CanRunAction(actionName, cooldown or 2.0) then return false end
    local did = false
    local pad = FindPadByKeywords(keywords)
    if pad and pad.part and pad.part.Parent then
        FastTouch(pad.part)
        if WalkTo(pad.part.Position, 2.0, 3.5) then
            FastTouch(pad.part)
            if pad.prompt then
                if pad.prompt:IsA("ProximityPrompt") then
                    did = TriggerPrompt(pad.prompt) or did
                elseif pad.prompt:IsA("ClickDetector") and fireclickdetector then
                    pcall(function() fireclickdetector(pad.prompt) end)
                    did = true
                end
            else
                for _, kw in ipairs(keywords) do
                    did = TriggerNearbyPrompt(kw, 12) or did
                    if did then break end
                end
            end
        end
    end
    if guiPatterns then
        did = TryClickGuiAction(actionName, guiPatterns, cooldown or 2.0) or did
    end
    DismissAllPopups()
    return did
end

local function RecycleScrap()
    local recyclerPos = RECYCLER_POS
    local recyclerPad = nil
    if not recyclerPos then
        recyclerPad = FindPadByKeywords({ "recycle", "recycler", "sell scrap", "convert" })
        recyclerPos = recyclerPad and recyclerPad.part and recyclerPad.part.Position or nil
    end
    
    if not recyclerPos then 
        CurrentBatchScraps = 0
        return false 
    end

    if not CanRunAction("RecycleScrap", 1.5) then return false end
    
    if recyclerPad and recyclerPad.part then
        FastTouch(recyclerPad.part)
    end
    
    WalkTo(recyclerPos, 3.5, 3.2)
    
    if recyclerPad and recyclerPad.part then
        FastTouch(recyclerPad.part)
    end
    
    if recyclerPad and recyclerPad.prompt and recyclerPad.prompt:IsA("ProximityPrompt") then
        TriggerPrompt(recyclerPad.prompt)
    else
        TriggerNearbyPrompt("recycle", 14)
    end
    
    TryClickGuiAction("RecycleScrap", { "recycle", "sell scrap", "convert", "empty", "deposit" }, 1.0)
    
    task.wait(0.3)
    CurrentBatchScraps = 0
    ConsecutiveFails = 0
    table.clear(BlacklistedScraps)
    DismissAllPopups()
    
    return true
end

local function RebirthAvailable()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, b in ipairs(pg:GetDescendants()) do
        if (b:IsA("TextButton") or b:IsA("ImageButton")) and IsVisibleGui(b) then
            local text = ButtonText(b)
            local looksReady = text:find("claim") or text:find("available") or text:find("ready")
                or text:find("do rebirth") or text:find("rebirth")
            local blocked = text:find("auto") or text:find("master") or text:find("locked")
                or text:find("require") or text:find("need")
            if looksReady and text:find("rebirth") and not blocked then
                return true
            end
        end
    end
    return false
end

local function DoRebirth()
    if not CanRunAction("Rebirth", 5) then return false end
    if not RebirthAvailable() then return false end
    TryClickGuiAction("RebirthOpen", { "rebirth" }, 1.5)
    task.wait(0.25)
    local ok = TryClickGuiAction("RebirthConfirm", { "confirm", "yes", "do rebirth", "claim rebirth" }, 1.5)
    if ok then
        task.wait(1.5)
        CurrentBatchScraps = 0
        table.clear(BlacklistedScraps)
        table.clear(ActionCooldowns)
        return true
    end
    DismissAllPopups()
    return false
end

local function RunUpgrades()
    local did = false
    if Flags.AutoBuyFeeders or Flags.AutoRebirth then
        did = ExecutePadAction("BuyFeeder", { "buy feeder", "new feeder", "feeder", "purchase feeder", "unlock feeder", "add feeder" }, { "buy feeder", "new feeder" }, 3.0) or did
    end
    if Flags.AutoUpgradeFeeder or Flags.AutoRebirth then
        did = ExecutePadAction("UpgradeFeeder", { "upgrade feeder", "feed speed", "feeder level", "feeder upgrade" }, { "upgrade feeder", "upgrade speed" }, 3.0) or did
    end
    if Flags.AutoUpgradeRecycler then
        did = ExecutePadAction("UpgradeRecycler", { "upgrade recycler", "recycler speed", "recycler level" }, { "upgrade recycler" }, 3.0) or did
    end
    if Flags.AutoUpgradeCoop then
        did = ExecutePadAction("UpgradeCoop", { "upgrade coop", "coop level", "expand coop" }, { "upgrade coop" }, 3.0) or did
    end
    if Flags.AutoOpenEggs then
        did = TryClickGuiAction("OpenEggs", { "hatch", "open egg", "open", "egg" }, 2.0) or did
    end
    DismissAllPopups()
    return did
end

local function ShouldRunAutomation()
    return Flags.AutoRebirth or Flags.AutoGrabScraps or Flags.AutoRecycleScrap or Flags.AutoBuyFeeders
        or Flags.AutoUpgradeFeeder or Flags.AutoUpgradeRecycler or Flags.AutoUpgradeCoop
        or Flags.AutoStartTower or Flags.AutoOpenEggs or Flags.AutoStartChaos
end

local function RecoverIfStuck()
    local timeout = STATE_TIMEOUTS[CurrentState]
    if not timeout or tick() - StateStartedAt <= timeout then return end
    SetState(State.COLLECTING)
end

-- Main Loop
task.spawn(function()
    while IsRunning do
        pcall(function()
            RecoverIfStuck()
            
            if not ShouldRunAutomation() then
                SetState(State.IDLE)
                task.wait(0.25)
                return
            end
            
            local root = GetRoot()
            local hum = GetHumanoid()
            if not root or not hum or hum.Health <= 0 then
                SetState(State.WAITING)
                task.wait(0.3)
                return
            end
            
            if CurrentState == State.IDLE or CurrentState == State.WAITING then
                SetState(State.COLLECTING)
            end
            
            if CurrentState == State.COLLECTING then
                local targetCap = tonumber(Flags.ScrapCapacity) or 20
                
                if Flags.AutoOpenEggs then
                    TryClickGuiAction("OpenEggs", { "hatch", "open egg", "open", "egg" }, 2)
                end
                
                -- RECYCLE JIKA TARGET CAPACITY SUDAH TERCAPAI ATAU JIKA TANGAN SUDAH PENUH (GAGAL AMBIL 4x)
                if Flags.AutoRecycleScrap and (CurrentBatchScraps >= targetCap or (CurrentBatchScraps > 0 and ConsecutiveFails >= 4)) then
                    SetState(State.RECYCLING)
                    return
                end
                
                -- AMBIL PLAT DI LANTAI
                if Flags.AutoGrabScraps then
                    local scrap = FindBestScrap()
                    if scrap then
                        TryCollectScrap(scrap)
                    else
                        task.wait(0.15)
                    end
                else
                    RunUpgrades()
                    task.wait(0.4)
                end
                
            elseif CurrentState == State.RECYCLING then
                RecycleScrap()
                SetState(State.UPGRADING)
                
            elseif CurrentState == State.UPGRADING then
                RunUpgrades()
                if Flags.AutoRebirth and RebirthAvailable() then
                    SetState(State.REBIRTH)
                else
                    SetState(State.COLLECTING)
                end
                
            elseif CurrentState == State.REBIRTH then
                DoRebirth()
                SetState(State.COLLECTING)
            end
        end)
        task.wait(0.03)
    end
end)

-- [[ GUI SETUP ]]
local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "ERDEVA_HUB"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 9999

local function Shutdown()
    IsRunning = false
    for k in pairs(Flags) do Flags[k] = false end
    pcall(function() Gui:Destroy() end)
end

local Main = Instance.new("Frame", Gui)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.Size = UDim2.fromOffset(W,H)
Main.Position = UDim2.new(0.5,0,0.5,0)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = C.Red Stroke.Thickness = 1.2

local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,34)
Top.BackgroundColor3 = C.Top Top.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1,-70,1,0)
Title.Position = UDim2.fromOffset(12,0)
Title.BackgroundTransparency = 1
Title.Text = "ERDEVA HUB <font color='#dc2323'>v1.6</font>"
Title.RichText = true Title.TextColor3 = C.Txt Title.TextSize = 13
Title.Font = Enum.Font.GothamBold Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Top)
CloseBtn.Size = UDim2.fromOffset(24,24) CloseBtn.Position = UDim2.new(1,-28,0.5,-12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
CloseBtn.Text = "✕" CloseBtn.TextColor3 = C.Sub CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,5)
CloseBtn.MouseButton1Click:Connect(Shutdown)

local MinBtn = Instance.new("TextButton", Top)
MinBtn.Size = UDim2.fromOffset(24,24) MinBtn.Position = UDim2.new(1,-56,0.5,-12)
MinBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
MinBtn.Text = "—" MinBtn.TextColor3 = C.Sub MinBtn.TextSize = 11
MinBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,5)
local minState = false
MinBtn.MouseButton1Click:Connect(function()
    minState = not minState
    tw(Main, {Size=UDim2.fromOffset(W, minState and 34 or H)}, 0.15)
end)

local drag, dStart, fStart = false
Top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag=true dStart=i.Position fStart=Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag=false end end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        local vs = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
        Main.Position = UDim2.new(0.5, math.clamp(fStart.X.Offset+d.X,-vs.X/2+W/2+10,vs.X/2-W/2-10),
                                  0.5, math.clamp(fStart.Y.Offset+d.Y,-vs.Y/2+(minState and 34 or H)/2+25,vs.Y/2-(minState and 34 or H)/2-10))
    end
end)

local TabFrame = Instance.new("Frame", Main)
TabFrame.Size = UDim2.new(1,0,0,28) TabFrame.Position = UDim2.fromOffset(0,34)
TabFrame.BackgroundColor3 = Color3.fromRGB(18,18,18) TabFrame.BorderSizePixel = 0
Instance.new("UIListLayout", TabFrame).FillDirection = Enum.FillDirection.Horizontal

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1,-12,1,-68) Content.Position = UDim2.fromOffset(6,64)
Content.BackgroundTransparency = 1 Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3 Content.ScrollBarImageColor3 = C.Red
Content.CanvasSize = UDim2.new(0,0,0,0) Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
local CL = Instance.new("UIListLayout", Content)
CL.Padding = UDim.new(0,4)

local Pages, TabBtns = {}, {}
local function SetTab(name)
    for n,p in pairs(Pages) do p.Visible=(n==name) end
    for n,b in pairs(TabBtns) do
        tw(b,{BackgroundColor3=(n==name and Color3.fromRGB(40,14,14) or Color3.fromRGB(18,18,18)),
              TextColor3=(n==name and C.Txt or C.Sub)})
    end
end

local MakeTab = function(name, order)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(0.25,0,1,0) btn.BackgroundColor3 = Color3.fromRGB(18,18,18)
    btn.BorderSizePixel = 0 btn.Text = name btn.TextColor3 = C.Sub
    btn.TextSize = 11 btn.Font = Enum.Font.GothamBold btn.LayoutOrder = order
    TabBtns[name] = btn
    local page = Instance.new("Frame", Content)
    page.Size = UDim2.new(1,0,0,0) page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1 page.Visible = false
    local pl = Instance.new("UIListLayout", page) pl.Padding = UDim.new(0,4)
    Pages[name] = page
    btn.MouseButton1Click:Connect(function() SetTab(name) end)
    return page
end

local function SetFlag(key, val)
    Flags[key] = val
    if ToggleUpdaters[key] then ToggleUpdaters[key](val) end
end

local function AddToggle(parent, label, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,0,0,30) f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-50,1,0) l.Position = UDim2.fromOffset(8,0)
    l.BackgroundTransparency = 1 l.Text = label l.TextColor3 = C.Txt
    l.TextSize = 11 l.Font = Enum.Font.GothamMedium l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.fromOffset(36,18) b.Position = UDim2.new(1,-42,0.5,-9)
    b.BackgroundColor3 = Color3.fromRGB(50,50,50) b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    local k = Instance.new("Frame", b)
    k.Size = UDim2.fromOffset(14,14) k.Position = UDim2.fromOffset(2,2)
    k.BackgroundColor3 = Color3.fromRGB(240,240,240)
    Instance.new("UICorner", k).CornerRadius = UDim.new(1,0)
    local function upd(on)
        tw(b,{BackgroundColor3=(on and C.Red or Color3.fromRGB(50,50,50))})
        tw(k,{Position=(on and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2))})
    end
    ToggleUpdaters[key] = upd
    upd(Flags[key])
    b.MouseButton1Click:Connect(function()
        local ns = not Flags[key]
        SetFlag(key, ns)
        if key == "AutoRebirth" then
            if ns then
                SetFlag("AutoGrabScraps", true)
                SetFlag("AutoRecycleScrap", true)
                SetFlag("AutoBuyFeeders", true)
                SetFlag("AutoUpgradeFeeder", true)
            else
                for _, fk in ipairs({"AutoOpenEggs","AutoGrabScraps","AutoRecycleScrap","AutoUpgradeRecycler",
                                      "AutoBuyFeeders","AutoUpgradeFeeder","AutoUpgradeCoop",
                                      "AutoStartTower","AutoNoThanks","AutoStartChaos"}) do
                    SetFlag(fk, false)
                end
                CurrentBatchScraps = 0
                table.clear(BlacklistedScraps)
                SetState(State.IDLE)
            end
        end
    end)
end

local function AddSlider(parent, label, maxV, defV, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,0,0,36) f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-60,0,16) l.Position = UDim2.fromOffset(8,2)
    l.BackgroundTransparency = 1 l.Text = label l.TextColor3 = C.Txt
    l.TextSize = 11 l.Font = Enum.Font.GothamMedium l.TextXAlignment = Enum.TextXAlignment.Left
    local vl = Instance.new("TextLabel", f)
    vl.Size = UDim2.fromOffset(50,16) vl.Position = UDim2.new(1,-58,0,2)
    vl.BackgroundTransparency = 1 vl.Text = tostring(defV).."/"..tostring(maxV)
    vl.TextColor3 = C.Red vl.TextSize = 11 vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right
    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1,-16,0,4) bar.Position = UDim2.fromOffset(8,22)
    bar.BackgroundColor3 = Color3.fromRGB(45,45,45) bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(defV/maxV,0,1,0) fill.BackgroundColor3 = C.Red
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local sld = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sld=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sld=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sld and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local r = math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(r,0,1,0)
            local v = math.max(1,math.floor(r*maxV+0.5))
            vl.Text = tostring(v).."/"..tostring(maxV)
            Flags[key] = v
        end
    end)
end

local FarmPage   = MakeTab("Farm",   1)
local PlotPage   = MakeTab("Plot",   2)
local BattlePage = MakeTab("Battle", 3)
local InfoPage   = MakeTab("Info",   4)

AddToggle(FarmPage, "Auto Open Eggs",        "AutoOpenEggs")
AddToggle(FarmPage, "Auto Grab Scraps",      "AutoGrabScraps")
AddToggle(FarmPage, "Auto Recycle Scrap",    "AutoRecycleScrap")
AddToggle(FarmPage, "Auto Upgrade Recycler", "AutoUpgradeRecycler")
AddSlider(FarmPage, "Scrap Capacity", 50, 20, "ScrapCapacity")

AddToggle(PlotPage, "Auto Rebirth (Master)", "AutoRebirth")
AddToggle(PlotPage, "Auto Buy Feeders",      "AutoBuyFeeders")
AddToggle(PlotPage, "Auto Upgrade Feeder",   "AutoUpgradeFeeder")
AddToggle(PlotPage, "Auto Upgrade Coop",     "AutoUpgradeCoop")

do
    local wrapper = Instance.new("Frame", PlotPage)
    wrapper.Size = UDim2.new(1,0,0,56)
    wrapper.BackgroundColor3 = Color3.fromRGB(18,18,18)
    Instance.new("UICorner", wrapper).CornerRadius = UDim.new(0,6)
    local s = Instance.new("UIStroke", wrapper) s.Color=C.Red s.Thickness=1
    local hint = Instance.new("TextLabel", wrapper)
    hint.Size = UDim2.new(1,-8,0,18) hint.Position = UDim2.fromOffset(4,2)
    hint.BackgroundTransparency = 1 hint.Text = "[!] Stand on your Recycler pad, then click:"
    hint.TextColor3 = Color3.fromRGB(255,200,50) hint.TextSize = 10
    hint.Font = Enum.Font.GothamBold hint.TextXAlignment = Enum.TextXAlignment.Left
    local lockBtn = Instance.new("TextButton", wrapper)
    lockBtn.Size = UDim2.new(1,-8,0,28) lockBtn.Position = UDim2.fromOffset(4,22)
    lockBtn.BackgroundColor3 = Color3.fromRGB(180,30,30)
    lockBtn.Text = "[LOCK] Set My Recycler Position"
    lockBtn.TextColor3 = Color3.fromRGB(255,255,255)
    lockBtn.TextSize = 11 lockBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0,5)
    lockBtn.MouseButton1Click:Connect(function()
        if LockRecycler() then
            lockBtn.Text = "[OK] Recycler Position Locked"
            lockBtn.BackgroundColor3 = Color3.fromRGB(20,120,20)
            task.delay(2, function()
                if lockBtn and lockBtn.Parent then
                    lockBtn.Text = "[LOCK] Set My Recycler Position"
                    lockBtn.BackgroundColor3 = Color3.fromRGB(180,30,30)
                end
            end)
        end
    end)
end

AddToggle(BattlePage, "Auto Start Tower",  "AutoStartTower")
AddSlider(BattlePage, "Min Chicken Lv for Tower", 100, 50, "TowerMinLevel")
AddToggle(BattlePage, "Auto No Thanks",    "AutoNoThanks")
AddToggle(BattlePage, "Auto Start Chaos",  "AutoStartChaos")

local LiveCarriedLabel = nil
local function AddInfo(k, v, isLive)
    local f = Instance.new("Frame", InfoPage)
    f.Size = UDim2.new(1,0,0,26) f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.5,0,1,0) l.Position = UDim2.fromOffset(8,0)
    l.BackgroundTransparency = 1 l.Text = k l.TextColor3 = C.Txt l.TextSize = 11
    l.Font = Enum.Font.GothamMedium l.TextXAlignment = Enum.TextXAlignment.Left
    local r = Instance.new("TextLabel", f)
    r.Size = UDim2.new(0.5,-8,1,0) r.Position = UDim2.new(0.5,0,0,0)
    r.BackgroundTransparency = 1 r.Text = v r.TextColor3 = C.Red r.TextSize = 11
    r.Font = Enum.Font.GothamBold r.TextXAlignment = Enum.TextXAlignment.Right
    if isLive then LiveCarriedLabel = r end
end

AddInfo("Hub",            "ERDEVA HUB")
AddInfo("Game",           "Chicken Farm")
AddInfo("Plates Grabbed", "0 / 20", true)
AddInfo("Status",         "Operational")

task.spawn(function()
    while IsRunning do
        if LiveCarriedLabel and LiveCarriedLabel.Parent then
            LiveCarriedLabel.Text = tostring(CurrentBatchScraps) .. " / " .. tostring(Flags.ScrapCapacity or 20)
        end
        task.wait(0.2)
    end
end)

SetTab("Farm")
