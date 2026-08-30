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
local IsBusy = false
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

local Flags = {
    AutoOpenEggs       = false,
    AutoGrabScraps     = false,
    AutoRecycleScrap   = false,
    AutoUpgradeRecycler= false,
    ScrapCapacity      = 20,
    AutoRebirth        = false,
    AutoUpgradeCoop    = false,
    AutoUpgradeFeeder  = false,
    AutoBuyFeeders     = false,
    AutoStartTower     = false,
    TowerMinLevel      = 50,
    AutoNoThanks       = false,
    AutoStartChaos     = false,
}

local ToggleUpdaters = {}

local function GetChar() return player.Character end
local function GetRoot()
    local c = GetChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end
local function GetHumanoid()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

RunService.Stepped:Connect(function()
    if IsRunning and (Flags.AutoGrabScraps or Flags.AutoRecycleScrap or Flags.AutoBuyFeeders or Flags.AutoUpgradeFeeder or Flags.AutoUpgradeRecycler) then
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

local function FlatDist(a, b)
    return Vector2.new(a.X - b.X, a.Z - b.Z).Magnitude
end

local function WalkTo(targetPos, timeout, stopDist)
    if not IsRunning then return end
    local hum  = GetHumanoid()
    local root = GetRoot()
    if not hum or not root then return end
    stopDist = stopDist or 3.0
    timeout  = timeout  or 6.0
    local t0 = tick()
    while IsRunning and FlatDist(root.Position, targetPos) > stopDist and (tick() - t0) < timeout do
        hum:MoveTo(targetPos)
        task.wait(0.1)
    end
end

local RECYCLER_POS = nil

local function GetRecyclerPos() return RECYCLER_POS end

local function LockRecycler()
    local root = GetRoot()
    if root then
        RECYCLER_POS = root.Position
        return true
    end
    return false
end

local function ClickGuiButton(btn)
    if not btn then return end
    pcall(function()
        if getconnections then
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
            for _, c in ipairs(getconnections(btn.Activated))        do c:Fire() end
        end
        if firesignal then firesignal(btn.MouseButton1Click) end
    end)
end

local function ClickGuiByPattern(pat)
    if not IsRunning then return false end
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    pat = pat:lower()
    for _, b in ipairs(pg:GetDescendants()) do
        if (b:IsA("TextButton") or b:IsA("ImageButton")) and b.Visible then
            local t = (b:IsA("TextButton") and b.Text:lower() or "") .. " " .. b.Name:lower()
            if t:find(pat) then ClickGuiButton(b) return true end
        end
    end
    return false
end

local function TriggerPrompt(prompt)
    if not prompt or not prompt.Parent then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.05)
            prompt:InputHoldEnd()
        end
    end)
end

local function FindSpecificPads(actionKeyword)
    local root = GetRoot()
    local results = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local matched = false
        local part = nil
        local prompt = nil

        if obj:IsA("ProximityPrompt") then
            local act = obj.ActionText:lower()
            local objT = obj.ObjectText:lower()
            local pn = (obj.Parent and obj.Parent.Name:lower()) or ""
            local gn = (obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name:lower()) or ""
            local comb = act .. " " .. objT .. " " .. pn .. " " .. gn
            if comb:find(actionKeyword) then
                matched = true
                prompt = obj
                part = obj.Parent
            end
        elseif obj:IsA("TextLabel") or obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            local text = (obj:IsA("TextLabel") and obj.Text:lower()) or ""
            local n = obj.Name:lower()
            if text:find(actionKeyword) or n:find(actionKeyword) then
                local pPart = obj:FindFirstAncestorWhichIsA("BasePart") or (obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent)
                if pPart then
                    matched = true
                    part = pPart
                    prompt = pPart:FindFirstChildOfClass("ProximityPrompt") or pPart:FindFirstChildOfClass("ClickDetector")
                end
            end
        end

        if matched and part and part:IsA("BasePart") then
            if root and (root.Position - part.Position).Magnitude < 300 then
                table.insert(results, {part = part, prompt = prompt})
            end
        end
    end
    return results
end

local lastFeederActionTime = 0
local function BuyFeederDirectly()
    if tick() - lastFeederActionTime < 3.0 then return false end
    lastFeederActionTime = tick()

    local pads = FindSpecificPads("buy feeder")
    if #pads == 0 then
        ClickGuiByPattern("buy feeder")
        TriggerRemote("buy feeder")
        return false
    end

    IsBusy = true
    for _, item in ipairs(pads) do
        if not IsRunning then break end
        if item.part and item.part.Parent then
            WalkTo(item.part.Position, 3.5, 3.0)
            task.wait(0.15)
            if item.prompt then
                if item.prompt:IsA("ProximityPrompt") then
                    TriggerPrompt(item.prompt)
                elseif item.prompt:IsA("ClickDetector") and fireclickdetector then
                    pcall(function() fireclickdetector(item.prompt) end)
                end
            end
            ClickGuiByPattern("buy feeder")
            TriggerRemote("buy feeder")
            task.wait(0.2)
        end
    end
    IsBusy = false
    return true
end

local function UpgradeFeederDirectly()
    if tick() - lastFeederActionTime < 3.0 then return false end
    lastFeederActionTime = tick()

    local pads = FindSpecificPads("upgrade feeder")
    if #pads == 0 then
        ClickGuiByPattern("upgrade feeder")
        TriggerRemote("feeder")
        return false
    end

    IsBusy = true
    for _, item in ipairs(pads) do
        if not IsRunning then break end
        if item.part and item.part.Parent then
            WalkTo(item.part.Position, 3.5, 3.0)
            task.wait(0.15)
            if item.prompt then
                if item.prompt:IsA("ProximityPrompt") then
                    TriggerPrompt(item.prompt)
                elseif item.prompt:IsA("ClickDetector") and fireclickdetector then
                    pcall(function() fireclickdetector(item.prompt) end)
                end
            end
            ClickGuiByPattern("upgrade feeder")
            TriggerRemote("feeder")
            task.wait(0.2)
        end
    end
    IsBusy = false
    return true
end

local function WalkAndFireAll(patterns)
    local root = GetRoot()
    if not root then return end
    local targets = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local combined = ""
        local prompt = nil
        if obj:IsA("ProximityPrompt") then
            local pn = (obj.Parent and obj.Parent.Name:lower()) or ""
            local gn = (obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name:lower()) or ""
            combined = obj.ActionText:lower() .. " " .. obj.ObjectText:lower() .. " " .. pn .. " " .. gn
            prompt = obj
        elseif obj:IsA("ClickDetector") then
            local pn = (obj.Parent and obj.Parent.Name:lower()) or ""
            local gn = (obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name:lower()) or ""
            combined = pn .. " " .. gn
            prompt = obj
        end
        if combined ~= "" and prompt then
            for _, pat in ipairs(patterns) do
                if combined:find(pat) then
                    table.insert(targets, prompt)
                    break
                end
            end
        end
    end
    if #targets == 0 then return end
    IsBusy = true
    local savedPos = root.Position
    for _, prompt in ipairs(targets) do
        if not IsRunning then break end
        local part = prompt.Parent
        if not part or not part:IsA("BasePart") then continue end
        root = GetRoot()
        if not root then break end
        if (root.Position - part.Position).Magnitude < 250 then
            WalkTo(part.Position, 4.0, 3.5)
            task.wait(0.2)
            if prompt:IsA("ProximityPrompt") then
                TriggerPrompt(prompt)
            elseif prompt:IsA("ClickDetector") and fireclickdetector then
                pcall(function() fireclickdetector(prompt) end)
            end
            task.wait(0.3)
        end
    end
    local r2 = GetRoot()
    if r2 then WalkTo(savedPos, 3.0, 3.5) end
    IsBusy = false
end

local function TriggerRemote(pattern)
    pattern = pattern:lower()
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rn = remote.Name:lower()
            if rn:find(pattern)
            or (pattern:find("feeder")  and (rn:find("buy") or rn:find("feed")))
            or (pattern:find("coop")    and rn:find("coop"))
            or (pattern:find("recycle") and rn:find("recycle")) then
                pcall(function()
                    if remote:IsA("RemoteEvent") then remote:FireServer()
                    else remote:InvokeServer() end
                end)
            end
        end
    end
end

local function GetHighestChickenLevel()
    local highest = 0
    local pg = player:FindFirstChild("PlayerGui")
    if pg then
        for _, lbl in ipairs(pg:GetDescendants()) do
            if lbl:IsA("TextLabel") and lbl.Visible then
                local t = lbl.Text
                local lv = t:match("[Ll][Vv]%.?%s*(%d+)") or t:match("[Ll][Ee][Vv][Ee][Ll]%s*(%d+)")
                if lv then
                    local num = tonumber(lv)
                    if num and num > highest and num < 10000 then
                        highest = num
                    end
                end
            end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            local t = (obj:IsA("TextLabel") and obj.Text) or ""
            local lv = t:match("[Ll][Vv]%.?%s*(%d+)") or t:match("[Ll][Ee][Vv][Ee][Ll]%s*(%d+)")
            if lv then
                local num = tonumber(lv)
                if num and num > highest and num < 10000 then
                    highest = num
                end
            end
        end
    end
    return highest
end

local function IsInBattle()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, g in ipairs(pg:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled then
            local n = g.Name:lower()
            if n:find("battle") or n:find("fight") or n:find("tower") or n:find("arena") then
                for _, el in ipairs(g:GetDescendants()) do
                    if el:IsA("GuiObject") and el.Visible then
                        local en = el.Name:lower()
                        if en:find("health") or en:find("hp") or en:find("enemy") or en:find("round") or en:find("floor") then
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
    local anc = obj:FindFirstAncestorOfClass("Model")
    if anc and anc:FindFirstChildOfClass("Humanoid") then return false end
    local n   = obj.Name:lower()
    local pn  = obj.Parent.Name:lower()
    local ppn = (obj.Parent.Parent and obj.Parent.Parent.Name:lower()) or ""
    return (n:find("scrap") or n:find("trash") or n:find("drop") or n:find("plate") or n:find("poop")
         or pn:find("scrap") or pn:find("trash") or pn:find("drop")
         or ppn:find("scrap") or ppn:find("drop"))
       and not n:find("recycler") and not n:find("feeder")
       and not n:find("upgrade")  and not n:find("shop") and not n:find("button")
end

local collectedScraps = 0
local BlacklistedScraps = {}

task.spawn(function()
    while IsRunning do
        if Flags.AutoGrabScraps and not IsInBattle() and not IsBusy then
            pcall(function()
                local root = GetRoot()
                if not root then task.wait(0.2) return end
                local cap         = tonumber(Flags.ScrapCapacity) or 20
                local recyclerPos = GetRecyclerPos()

                if Flags.AutoRecycleScrap and recyclerPos and collectedScraps >= cap then
                    WalkTo(recyclerPos, 7.0, 2.5)
                    task.wait(1.2)
                    collectedScraps = 0
                    table.clear(BlacklistedScraps)
                    if Flags.AutoBuyFeeders or Flags.AutoRebirth then
                        BuyFeederDirectly()
                    end
                    if Flags.AutoUpgradeFeeder then
                        UpgradeFeederDirectly()
                    end
                else
                    local best, bestDist = nil, 9999
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if not IsRunning or not Flags.AutoGrabScraps then break end
                        if not BlacklistedScraps[obj] and IsGroundScrap(obj) then
                            local d = FlatDist(root.Position, obj.Position)
                            if d < 400 and d < bestDist then
                                bestDist = d
                                best = obj
                            end
                        end
                    end
                    if best and collectedScraps < cap then
                        WalkTo(best.Position, 3.5, 2.5)
                        BlacklistedScraps[best] = true
                        collectedScraps = collectedScraps + 1
                    else
                        table.clear(BlacklistedScraps)
                        task.wait(0.25)
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
                local curLv = GetHighestChickenLevel()
                local reqLv = tonumber(Flags.TowerMinLevel) or 50
                if curLv >= reqLv and not IsInBattle() then
                    isTowerBusy = true
                    ClickGuiByPattern("tower")
                    task.wait(2.5)
                    local elapsed = 0
                    while elapsed < 120 and IsRunning and Flags.AutoStartTower do
                        task.wait(1)
                        elapsed = elapsed + 1
                        ClickGuiByPattern("claim")
                        ClickGuiByPattern("next floor")
                        ClickGuiByPattern("victory")
                        ClickGuiByPattern("no thanks")
                        ClickGuiByPattern("continue")
                        if not IsInBattle() and elapsed > 6 then
                            break
                        end
                    end
                    task.wait(2.0)
                    isTowerBusy = false
                end
            end)
        end
        task.wait(1.5)
    end
end)

task.spawn(function()
    while IsRunning do
        if Flags.AutoRebirth and not IsInBattle() then
            pcall(function()
                local pg = player:FindFirstChild("PlayerGui")
                if not pg then return end
                local found = false
                for _, b in ipairs(pg:GetDescendants()) do
                    if (b:IsA("TextButton") or b:IsA("ImageButton")) and b.Visible then
                        local n = b.Name:lower().." "..(b:IsA("TextButton") and b.Text:lower() or "")
                        if n:find("rebirth") and not n:find("autorebirth") then found=true break end
                    end
                end
                if found then
                    ClickGuiByPattern("rebirth") task.wait(0.4)
                    local confirm = false
                    for _, b in ipairs(pg:GetDescendants()) do
                        if (b:IsA("TextButton") or b:IsA("ImageButton")) and b.Visible then
                            local n = (b:IsA("TextButton") and b.Text:lower() or "").." "..b.Name:lower()
                            if (n:find("confirm") or n:find("yes") or n:find("do rebirth") or n:find("claim rebirth")) and not n:find("close") and not n:find("cancel") then
                                confirm=true break
                            end
                        end
                    end
                    if confirm then
                        UpgradeFeederDirectly()
                        BuyFeederDirectly()
                        task.wait(0.3)
                        ClickGuiByPattern("confirm") ClickGuiByPattern("yes") ClickGuiByPattern("do rebirth") ClickGuiByPattern("claim rebirth")
                        task.wait(3.5)
                        collectedScraps=0 BlacklistedScraps={} isTowerBusy=false
                        BuyFeederDirectly()
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
                ClickGuiByPattern("no thanks") ClickGuiByPattern("nothanks")
                ClickGuiByPattern("skip") ClickGuiByPattern("claim") ClickGuiByPattern("close")
            end)
        end
        task.wait(0.4)
    end
end)

task.spawn(function()
    while IsRunning do
        if Flags.AutoStartChaos and not IsInBattle() then
            pcall(function() ClickGuiByPattern("to chaos") ClickGuiByPattern("chaos") task.wait(3) end)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while IsRunning do
        if Flags.AutoOpenEggs and not IsInBattle() then
            pcall(function() ClickGuiByPattern("hatch") ClickGuiByPattern("open") ClickGuiByPattern("egg") end)
        end
        task.wait(0.7)
    end
end)

task.spawn(function()
    while IsRunning do
        if Flags.AutoUpgradeRecycler and not IsInBattle() then
            pcall(function() ClickGuiByPattern("upgrade recycler") TriggerRemote("recycler") WalkAndFireAll({"recycler","upgrade recycler"}) end)
        end
        if Flags.AutoUpgradeCoop and not IsInBattle() then
            pcall(function() ClickGuiByPattern("upgrade coop") TriggerRemote("coop") WalkAndFireAll({"coop","upgrade coop"}) end)
        end
        if Flags.AutoUpgradeFeeder and not IsInBattle() then
            pcall(function() UpgradeFeederDirectly() end)
        end
        if Flags.AutoBuyFeeders and not IsInBattle() then
            pcall(function() BuyFeederDirectly() end)
        end
        task.wait(3.0)
    end
end)

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
Title.Text = "ERDEVA HUB <font color='#dc2323'>v1.0</font>"
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

local function MakeTab(name, order)
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
    b.MouseButton1Click:Connect(function()
        local ns = not Flags[key]
        SetFlag(key, ns)
        if key == "AutoRebirth" then
            for _, fk in ipairs({"AutoGrabScraps","AutoRecycleScrap","AutoUpgradeRecycler",
                                  "AutoBuyFeeders","AutoUpgradeFeeder",
                                  "AutoStartTower","AutoNoThanks"}) do
                SetFlag(fk, ns)
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

local function AddInfo(k, v)
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
end
AddInfo("Hub",    "ERDEVA HUB")
AddInfo("Game",   "Chicken Farm")
AddInfo("Player", player.DisplayName)
AddInfo("Status", "Operational")

SetTab("Farm")
