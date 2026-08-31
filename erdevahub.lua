-- [[ ERDEVA HUB v3.2 - PRECISE CHICKEN LEVEL HUD ]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

pcall(function()
    if CoreGui:FindFirstChild("ERDEVA_HUB") then
        CoreGui:FindFirstChild("ERDEVA_HUB"):Destroy()
    end
end)

local IsRunning = true
local W, H = 420, 260

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

local function Notify(title, desc, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = desc,
            Duration = duration or 4.5
        })
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
    AutoNoThanks        = true,
    AutoStartChaos      = false,
}

local LOCKED_RECYCLER_POS = nil
local ToggleUpdaters = {}
local CurrentBatchScraps = 0
local ChickenInTower = false
local LastTowerFinishedAt = 0

local function GetChar() return player.Character end
local function GetRoot()
    local c = GetChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end
local function GetHumanoid()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- NOCLIP REAL-TIME (TEMBUS SEMUA PAGAR)
RunService.Stepped:Connect(function()
    if not IsRunning then return end
    local char = GetChar()
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

local function IsVisibleGui(obj)
    if not obj:IsA("GuiObject") or not obj.Visible then return false end
    local cur = obj.Parent
    while cur and cur:IsA("GuiObject") do
        if not cur.Visible then return false end
        cur = cur.Parent
    end
    return true
end

-- DETEKSI LEVEL AYAM ASLI (HANYA DARI HUD AYAM KANAN ATAS)
local function GetHighestChickenLevel()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return 0 end
    
    for _, lbl in ipairs(pg:GetDescendants()) do
        if lbl:IsA("TextLabel") and IsVisibleGui(lbl) then
            local t = lbl.Text:lower()
            local pName = (lbl.Parent and lbl.Parent.Name:lower()) or ""
            local ppName = (lbl.Parent and lbl.Parent.Parent and lbl.Parent.Parent.Name:lower()) or ""
            
            -- Filter out bangunan/shop (Recycler Lv. 65, Feeder, dll)
            if not t:find("recycler") and not t:find("feeder") and not t:find("coop") and not t:find("shop") and not t:find("milestone") and not t:find("rebirth") and not t:find("floor")
               and not pName:find("recycler") and not pName:find("feeder") and not pName:find("coop") and not pName:find("shop") and not pName:find("milestone") and not pName:find("rebirth")
               and not ppName:find("recycler") and not ppName:find("feeder") and not ppName:find("coop") then
               
                local lv = lbl.Text:match("[Ll][Vv][Ll]?%.?:?%s*(%d+)") or lbl.Text:match("[Ll][Ee][Vv][Ee][Ll]%.?:?%s*(%d+)")
                if lv then
                    local num = tonumber(lv)
                    if num and num > 0 and num < 5000 then
                        -- Hanya ambil jika posisinya di bagian atas layar (HUD ayam kanan atas)
                        if lbl.AbsolutePosition.Y < 250 then
                            return num
                        end
                    end
                end
            end
        end
    end
    return 0
end

local State = {
    IDLE       = "IDLE",
    COLLECTING = "COLLECTING",
    RECYCLING  = "RECYCLING",
    UPGRADING  = "UPGRADING",
    REBIRTH    = "REBIRTH",
    WAITING    = "WAITING",
}

local CurrentState = State.IDLE
local ActionCooldowns = {}
local GuiCooldowns = {}
local BlacklistedScraps = {}

local function SetState(newState)
    if CurrentState ~= newState then
        CurrentState = newState
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

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    CurrentBatchScraps = 0
    ChickenInTower = false
end)

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
    timeout = timeout or 4.5
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
    return root and FlatDist(root.Position, targetPos) <= (stopDist + 2.5)
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
    local img = (btn:IsA("ImageButton") and btn.Image) or ""
    return ((btn:IsA("TextButton") and btn.Text or "") .. " " .. btn.Name .. " " .. img):lower()
end

-- AUTO KLIK "NO THANKS" INSTAN
local function HandleTowerEndPopup()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    
    for _, obj in ipairs(pg:GetDescendants()) do
        local isMatch = false
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and IsVisibleGui(obj) then
            local t = obj.Text:lower()
            if t:find("no thanks") or t:find("nothanks") or t:find("no, thanks") then
                isMatch = true
            end
        elseif (obj:IsA("ImageButton") or obj:IsA("GuiObject")) and IsVisibleGui(obj) then
            local n = obj.Name:lower()
            if n:find("nothanks") or n:find("no_thanks") or n:find("decline") or n:find("skip") then
                isMatch = true
            end
        end
        
        if isMatch then
            local target = obj
            if not obj:IsA("TextButton") and not obj:IsA("ImageButton") then
                target = obj:FindFirstAncestorWhichIsA("TextButton") or obj:FindFirstAncestorWhichIsA("ImageButton") or obj.Parent
            end
            if target then
                ClickGuiButton(target)
                ChickenInTower = false
                LastTowerFinishedAt = tick()
                Notify("ERDEVA HUB", "Auto No Thanks diklik!", 2.0)
                return true
            end
        end
    end
    return false
end

-- TUTUP POPUP NOT ENOUGH CASH
local function DismissAllPopups()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    local clicked = false
    
    if Flags.AutoNoThanks then
        HandleTowerEndPopup()
    end
    
    for _, gui in ipairs(pg:GetDescendants()) do
        if gui:IsA("GuiObject") and IsVisibleGui(gui) then
            local text = (gui:IsA("TextLabel") and gui.Text:lower()) or ""
            local name = gui.Name:lower()
            
            if text:find("not enough cash") or text:find("not enough") or name:find("notenoughcash") then
                local container = gui.Parent
                while container and container ~= pg do
                    for _, b in ipairs(container:GetDescendants()) do
                        if (b:IsA("TextButton") or b:IsA("ImageButton")) and IsVisibleGui(b) then
                            local btnTxt = ButtonText(b)
                            if btnTxt:find("x") or btnTxt:find("close") or b.Name:lower() == "x" or b.Name:lower() == "close" then
                                clicked = ClickGuiButton(b) or clicked
                            end
                        end
                    end
                    container = container.Parent
                end
            end
            
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and (gui.Name:lower() == "x" or gui.Name:lower() == "close") then
                local pName = gui.Parent and gui.Parent.Name:lower() or ""
                if pName:find("popup") or pName:find("frame") or pName:find("modal") or pName:find("shop") or pName:find("cash") then
                    clicked = ClickGuiButton(gui) or clicked
                end
            end
        end
    end
    return clicked
end

task.spawn(function()
    while IsRunning do
        pcall(function() DismissAllPopups() end)
        task.wait(0.1)
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

-- DETEKSI PLAT ASLI DI ARENA
local function IsRealScrap(obj)
    if not obj:IsA("BasePart") or not obj.Parent then return false end
    
    local char = GetChar()
    if char and obj:IsDescendantOf(char) then return false end
    local anc = obj:FindFirstAncestorOfClass("Model")
    if anc and anc:FindFirstChildOfClass("Humanoid") then return false end
    
    local n = obj.Name:lower()
    local pn = obj.Parent.Name:lower()
    local ppn = (obj.Parent.Parent and obj.Parent.Parent.Name:lower()) or ""
    
    if n:find("fence") or n:find("wall") or n:find("floor") or n:find("base") or n:find("spawn") or n:find("grass") or n:find("terrain") then
        return false
    end
    if n:find("recycler") or n:find("feeder") or n:find("coop") or n:find("incubator") or n:find("shop") or n:find("pad") or n:find("button") then
        return false
    end
    if pn:find("recycler") or pn:find("feeder") or pn:find("coop") or pn:find("incubator") or pn:find("shop") or pn:find("plot") then
        return false
    end
    if ppn:find("plot") or ppn:find("base") or ppn:find("feeder") or ppn:find("recycler") then
        return false
    end
    
    if n:find("scrap") or n:find("plate") or n:find("drop") or n:find("trash") or n:find("sheet") or n:find("debris") or pn:find("scrap") or pn:find("plate") or pn:find("drop") or pn:find("drops") then
        return true
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

-- CARI PLAT SCRAP TERDEKAT DI ARENA
local function FindNearestArenaScrap()
    CleanupScrapBlacklist()
    local root = GetRoot()
    if not root then return nil end
    local best, bestDist = nil, 9999
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if IsRealScrap(obj) and not BlacklistedScraps[obj] then
            local d = FlatDist(root.Position, obj.Position)
            if d < 800 and d < bestDist then
                best = obj
                bestDist = d
            end
        end
    end
    return best
end

-- AMBIL LEMPENGAN PLAT
local function CollectScrapPlate(scrap)
    if not scrap or not scrap.Parent then return false end
    local root = GetRoot()
    local char = GetChar()
    if not root or not char then return false end
    
    FastTouch(scrap)
    WalkTo(scrap.Position, 1.8, 2.5)
    FastTouch(scrap)
    TriggerNearbyPrompt("scrap", 10)

    CurrentBatchScraps = CurrentBatchScraps + 1
    BlacklistedScraps[scrap] = tick()
    return true
end

-- CARI PAD DI BASE
local function FindBasePad(keywords)
    local root = GetRoot()
    if not root then return nil end
    local bestPart, bestPrompt, bestDist = nil, nil, 9999
    
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
                bestPart = targetPart
                bestPrompt = prompt
            end
        end
    end
    
    if bestPart then
        return { part = bestPart, prompt = bestPrompt }
    end
    return nil
end

local function ExecuteBasePad(actionName, keywords, guiPatterns, cooldown)
    if not CanRunAction(actionName, cooldown or 2.0) then return false end
    local pad = FindBasePad(keywords)
    if pad and pad.part then
        FastTouch(pad.part)
        if WalkTo(pad.part.Position, 2.5, 3.5) then
            FastTouch(pad.part)
            if pad.prompt and pad.prompt:IsA("ProximityPrompt") then
                TriggerPrompt(pad.prompt)
            elseif pad.prompt and pad.prompt:IsA("ClickDetector") and fireclickdetector then
                pcall(function() fireclickdetector(pad.prompt) end)
            else
                for _, kw in ipairs(keywords) do
                    TriggerNearbyPrompt(kw, 12)
                end
            end
        end
    end
    if guiPatterns then
        TryClickGuiAction(actionName, guiPatterns, cooldown or 2.0)
    end
    DismissAllPopups()
    return true
end

-- RECYCLE DI BASE (LOCKED POSISI)
local function DoRecycleAtBase()
    if not CanRunAction("RecycleScrap", 2.0) then return false end
    
    local targetPos = LOCKED_RECYCLER_POS
    local pad = nil
    
    if not targetPos then
        pad = FindBasePad({ "recycler", "recycle", "sell scrap", "convert" })
        if pad and pad.part then
            targetPos = pad.part.Position
        end
    end
    
    if not targetPos then
        return false
    end
    
    local reached = WalkTo(targetPos, 5.0, 2.8)
    
    if pad and pad.part then
        FastTouch(pad.part)
    end
    
    TriggerNearbyPrompt("recycle", 14)
    TryClickGuiAction("RecycleScrap", { "recycle", "sell scrap", "convert", "empty", "deposit" }, 1.0)
    
    task.wait(0.4)
    
    local root = GetRoot()
    if root and FlatDist(root.Position, targetPos) <= 4.0 then
        CurrentBatchScraps = 0
        table.clear(BlacklistedScraps)
    end
    
    DismissAllPopups()
    return true
end

-- UPGRADES
local function DoUpgrades()
    if Flags.AutoBuyFeeders or Flags.AutoRebirth then
        ExecuteBasePad("BuyFeeder", { "buy feeder", "new feeder", "feeder", "purchase feeder", "unlock feeder", "add feeder" }, { "buy feeder", "new feeder" }, 2.5)
    end
    if Flags.AutoUpgradeFeeder or Flags.AutoRebirth then
        ExecuteBasePad("UpgradeFeeder", { "upgrade feeder", "feed speed", "feeder level", "feeder upgrade" }, { "upgrade feeder", "upgrade speed" }, 2.5)
    end
    if Flags.AutoUpgradeRecycler or Flags.AutoRebirth then
        ExecuteBasePad("UpgradeRecycler", { "upgrade recycler", "recycler speed", "recycler level" }, { "upgrade recycler" }, 2.5)
    end
    if Flags.AutoUpgradeCoop then
        ExecuteBasePad("UpgradeCoop", { "upgrade coop", "coop level", "expand coop" }, { "upgrade coop" }, 2.5)
    end
    if Flags.AutoOpenEggs then
        TryClickGuiAction("OpenEggs", { "hatch", "open egg", "open", "egg" }, 2.0)
    end
    DismissAllPopups()
end

-- KIRIM AYAM KE TOWER (1X KLIK)
local function SendChickenToTower()
    if ChickenInTower then return false end
    if tick() - LastTowerFinishedAt < 3.0 then return false end
    if not CanRunAction("SendChickenTower", 4.0) then return false end
    
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    
    for _, b in ipairs(pg:GetDescendants()) do
        if (b:IsA("TextButton") or b:IsA("ImageButton")) and IsVisibleGui(b) then
            local text = ButtonText(b)
            if (text:find("tower") or text:find("kastil") or b.Name:lower() == "tower") and not text:find("rebirth") and not text:find("not yet") and not text:find("no thanks") then
                ClickGuiButton(b)
                ChickenInTower = true
                Notify("ERDEVA HUB", "Ayam dikirim ke Tower!", 2.5)
                return true
            end
        end
    end
    return false
end

-- REBIRTH SYSTEM
local function CheckAndDoRebirth()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    
    for _, modal in ipairs(pg:GetDescendants()) do
        if modal:IsA("Frame") and IsVisibleGui(modal) and modal.Name:lower():find("rebirth") then
            for _, b in ipairs(modal:GetDescendants()) do
                if (b:IsA("TextButton") or b:IsA("ImageButton")) and IsVisibleGui(b) then
                    local text = ButtonText(b)
                    if text:find("not yet") or text:find("milestones") or text:find("x") or text:find("close") then
                        -- Abaikan NOT YET
                    elseif (text:find("rebirth") or text:find("claim") or text:find("yes")) and CanRunAction("ExecuteRebirth", 5) then
                        ClickGuiButton(b)
                        task.wait(0.3)
                        TryClickGuiAction("RebirthConfirm", { "confirm", "yes", "do rebirth" }, 1.5)
                        task.wait(1.5)
                        
                        CurrentBatchScraps = 0
                        table.clear(BlacklistedScraps)
                        DoUpgrades()
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- CARI PUSAT ARENA DI DEPAN
local function GetArenaCenter()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("arena") or n:find("pen") or n:find("chickenarena")) and obj:IsA("BasePart") then
            return obj.Position
        end
    end
    return nil
end

-- MAIN AUTOMATION LOOP
task.spawn(function()
    while IsRunning do
        pcall(function()
            local active = Flags.AutoRebirth or Flags.AutoGrabScraps or Flags.AutoRecycleScrap or Flags.AutoStartTower
            if not active then
                SetState(State.IDLE)
                task.wait(0.3)
                return
            end
            
            local root = GetRoot()
            local hum = GetHumanoid()
            if not root or not hum or hum.Health <= 0 then
                SetState(State.WAITING)
                task.wait(0.3)
                return
            end
            
            -- 1. CEK TOWER
            local curLv = GetHighestChickenLevel()
            local reqLv = tonumber(Flags.TowerMinLevel) or 50
            if (Flags.AutoStartTower or Flags.AutoRebirth) and curLv >= reqLv and not ChickenInTower then
                SendChickenToTower()
            end
            
            -- 2. CEK REBIRTH
            if Flags.AutoRebirth then
                CheckAndDoRebirth()
            end
            
            local targetCap = tonumber(Flags.ScrapCapacity) or 20
            
            -- 3. SIKLUS UTAMA: LARI KE DEPAN KE ARENA MEMUNGUT 20 PLAT
            if CurrentBatchScraps < targetCap then
                SetState(State.COLLECTING)
                local scrap = FindNearestArenaScrap()
                if scrap then
                    CollectScrapPlate(scrap)
                else
                    local arenaPos = GetArenaCenter()
                    if arenaPos and FlatDist(root.Position, arenaPos) > 15 then
                        WalkTo(arenaPos, 3.5, 6.0)
                    else
                        task.wait(0.15)
                    end
                end
            else
                -- 4. JALAN PULANG KE RECYCLER DI BASE HANYA SAAT 20 PLAT PENUH
                SetState(State.RECYCLING)
                DoRecycleAtBase()
                
                -- 5. UPGRADE FEEDER SETELAH SETOR
                if CurrentBatchScraps == 0 then
                    SetState(State.UPGRADING)
                    DoUpgrades()
                    
                    if Flags.AutoRebirth then
                        SetState(State.REBIRTH)
                        CheckAndDoRebirth()
                    end
                end
                
                SetState(State.COLLECTING)
            end
        end)
        task.wait(0.02)
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
Title.Text = "ERDEVA HUB <font color='#dc2323'>v3.2</font>"
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
                SetFlag("AutoUpgradeRecycler", true)
                SetFlag("AutoBuyFeeders", true)
                SetFlag("AutoUpgradeFeeder", true)
                SetFlag("AutoStartTower", true)
                SetFlag("AutoNoThanks", true)
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

local function AddButton(parent, label, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,30) b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    b.Text = label b.TextColor3 = C.Txt b.TextSize = 11 b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
        tw(b, {BackgroundColor3 = C.Red}, 0.1)
        task.delay(0.2, function() tw(b, {BackgroundColor3 = Color3.fromRGB(35,35,35)}, 0.15) end)
        if callback then callback(b) end
    end)
    return b
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
AddButton(PlotPage, "[LOCK] Set Recycler Pad", function(btn)
    local root = GetRoot()
    if root then
        LOCKED_RECYCLER_POS = root.Position
        btn.Text = "✓ Recycler Pad Locked!"
        Notify("ERDEVA HUB", "Recycler Pad successfully locked at current position!", 3.5)
        task.delay(2.5, function() btn.Text = "[LOCK] Set Recycler Pad" end)
    end
end)
AddToggle(PlotPage, "Auto Buy Feeders",      "AutoBuyFeeders")
AddToggle(PlotPage, "Auto Upgrade Feeder",   "AutoUpgradeFeeder")
AddToggle(PlotPage, "Auto Upgrade Coop",     "AutoUpgradeCoop")

AddToggle(BattlePage, "Auto Start Tower",  "AutoStartTower")
AddSlider(BattlePage, "Min Chicken Lv for Tower", 100, 50, "TowerMinLevel")
AddToggle(BattlePage, "Auto No Thanks",    "AutoNoThanks")
AddToggle(BattlePage, "Auto Start Chaos",  "AutoStartChaos")

local LiveCarriedLabel = nil
local LiveLevelLabel = nil

local function AddInfo(k, v, isLive, isLevel)
    local f = Instance.new("Frame", InfoPage)
    f.Size = UDim2.new(1,0,0,26) f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.55,0,1,0) l.Position = UDim2.fromOffset(8,0)
    l.BackgroundTransparency = 1 l.Text = k l.TextColor3 = C.Txt l.TextSize = 11
    l.Font = Enum.Font.GothamMedium l.TextXAlignment = Enum.TextXAlignment.Left
    local r = Instance.new("TextLabel", f)
    r.Size = UDim2.new(0.45,-8,1,0) r.Position = UDim2.new(0.55,0,0,0)
    r.BackgroundTransparency = 1 r.Text = v r.TextColor3 = C.Red r.TextSize = 11
    r.Font = Enum.Font.GothamBold r.TextXAlignment = Enum.TextXAlignment.Right
    if isLive then LiveCarriedLabel = r end
    if isLevel then LiveLevelLabel = r end
end

AddInfo("Hub",                 "ERDEVA HUB")
AddInfo("Plates Grabbed",      "0 / 20", true, false)
AddInfo("Chicken Lv Detected", "Lv 0",   false, true)
AddInfo("Status",              "Operational")

task.spawn(function()
    while IsRunning do
        if LiveCarriedLabel and LiveCarriedLabel.Parent then
            LiveCarriedLabel.Text = tostring(CurrentBatchScraps) .. " / " .. tostring(Flags.ScrapCapacity or 20)
        end
        if LiveLevelLabel and LiveLevelLabel.Parent then
            LiveLevelLabel.Text = "Lv " .. tostring(GetHighestChickenLevel()) .. " (Target: " .. tostring(Flags.TowerMinLevel or 50) .. ")"
        end
        task.wait(0.15)
    end
end)

SetTab("Plot")
