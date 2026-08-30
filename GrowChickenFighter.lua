-- ============================================================
-- GROW A CHICKEN FIGHTER - SAFE AUTO FARM
-- ============================================================
-- Human-like behavior | Random delays | Undetected pattern
-- ============================================================

local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

-- ============================================================
-- KONFIGURASI
-- ============================================================
local CONFIG = {
    AutoCollect = true,      -- Auto collect eggs
    AutoFuse = false,        -- Auto fuse chickens
    AutoRebirth = false,     -- Auto rebirth
    DelayMin = 3,            -- Jeda minimal (detik)
    DelayMax = 8,            -- Jeda maksimal (detik)
}

-- ============================================================
-- FUNGSI RANDOM DELAY
-- ============================================================
local function randomDelay(min, max)
    local delay = min + math.random() * (max - min)
    task.wait(delay)
end

-- ============================================================
-- FIND REMOTE
-- ============================================================
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

-- ============================================================
-- AUTO COLLECT (SAFE)
-- ============================================================
local function autoCollect()
    while CONFIG.AutoCollect do
        pcall(function()
            if claimRemote then
                claimRemote:FireServer()
            end
        end)
        
        -- Jeda acak 3-8 detik
        randomDelay(CONFIG.DelayMin, CONFIG.DelayMax)
        
        -- Kadang skip 1-2 siklus (seperti manusia yang lupa)
        if math.random() < 0.1 then
            randomDelay(5, 10)
        end
    end
end

-- ============================================================
-- AUTO FUSE (SAFE)
-- ============================================================
local function autoFuse()
    while CONFIG.AutoFuse do
        pcall(function()
            if fuseRemote then
                fuseRemote:FireServer()
            end
        end)
        
        -- Jeda lebih lama untuk fuse
        randomDelay(5, 15)
    end
end

-- ============================================================
-- AUTO REBIRTH (SAFE)
-- ============================================================
local function autoRebirth()
    while CONFIG.AutoRebirth do
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

-- ============================================================
-- START
-- ============================================================
local function start()
    print("==========================================")
    print("  GROW A CHICKEN FIGHTER - SAFE AUTO FARM")
    print("==========================================")
    print("  Auto Collect: " .. tostring(CONFIG.AutoCollect))
    print("  Auto Fuse: " .. tostring(CONFIG.AutoFuse))
    print("  Auto Rebirth: " .. tostring(CONFIG.AutoRebirth))
    print("  Delay: " .. CONFIG.DelayMin .. "-" .. CONFIG.DelayMax .. " detik")
    print("==========================================")
    
    if CONFIG.AutoCollect then
        task.spawn(autoCollect)
    end
    
    if CONFIG.AutoFuse then
        task.spawn(autoFuse)
    end
    
    if CONFIG.AutoRebirth then
        task.spawn(autoRebirth)
    end
end

start()
