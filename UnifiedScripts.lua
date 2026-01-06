--[[ 
    Kitty Hub - Master Embedded Rayfield Script
    Includes:
    1) Music Player
    2) Cheese Escape Rayfield
    3) SATK Get All Weapons
    4) Advanced Stealth Adonis Bypass
--]]

-- Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local placeID = game.PlaceId

-- ======================================
-- Create a single Window for all tabs
-- ======================================
local Window = Rayfield:CreateWindow({
    Name = "Kitty Hub",
    LoadingTitle = "Kitty Hub",
    LoadingSubtitle = "by iamcheese-man",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "kitty hub",
        FileName = "KittyHubConfig"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

-- ======================================
-- Music Player Tab
-- ======================================
local musicTab = Window:CreateTab("Music Player", 4483362458)
musicTab:CreateSection("Sound Player")

local function makeSound()
    local old = player.PlayerGui:FindFirstChild("LocalSound")
    if old then old:Destroy() end
    local s = Instance.new("Sound")
    s.Name = "LocalSound"
    s.Parent = player.PlayerGui
    s.Volume = 1
    return s
end

local sound = makeSound()
local recommendedSounds = {
    "9045743976", "1846405622", "1837768517", "1840684529"
}
local SoundId = ""

-- Sound ID input
musicTab:CreateInput({
    Name = "Sound ID",
    CurrentValue = "",
    PlaceholderText = "Enter Sound ID",
    RemoveTextAfterFocusLost = false,
    Flag = "SoundID",
    Callback = function(Text)
        SoundId = Text
    end
})

-- Recommended sounds dropdown
musicTab:CreateDropdown({
    Name = "Recommended Sounds",
    Options = recommendedSounds,
    CurrentOption = nil,
    Flag = "Recommended",
    Callback = function(Option)
        if typeof(Option) == "table" then
            SoundId = Option[1]
        else
            SoundId = Option
        end
    end
})

-- Volume slider
musicTab:CreateSlider({
    Name = "Volume",
    Range = {0,100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 100,
    Flag = "Volume",
    Callback = function(Value)
        sound.Volume = math.clamp(Value/100,0,1)
    end
})

-- Play button
musicTab:CreateButton({
    Name = "▶ Play",
    Callback = function()
        local id = tonumber(SoundId)
        if id then
            sound.SoundId = "rbxassetid://"..id
            sound:Play()
            Rayfield:Notify({Title="Playing",Content="Sound ID: "..id,Duration=3})
        else
            Rayfield:Notify({Title="Error",Content="Invalid Sound ID",Duration=3})
        end
    end
})

-- Stop button
musicTab:CreateButton({
    Name = "⏹ Stop",
    Callback = function()
        if sound.IsPlaying then sound:Stop() end
    end
})

-- Respawn fix
player.CharacterAdded:Connect(function()
    task.wait(1)
    sound = makeSound()
end)

-- ======================================
-- Cheese Escape Tab
-- ======================================
local cheeseTab = Window:CreateTab("Cheese Escape", 4483362458)
cheeseTab:CreateSection("Server")

-- Get Cheese
cheeseTab:CreateButton({
    Name = "Get 1 Cheese",
    Callback = function()
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage").AddCheese:FireServer()
        end)
        if not success then warn(err) end
    end
})

-- Local Player Section
cheeseTab:CreateSection("Local Player")
local currentWalkSpeed = 16

-- WalkSpeed slider
cheeseTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {0,1000},
    Increment = 1,
    Suffix = "",
    CurrentValue = currentWalkSpeed,
    Flag = "walkspeed",
    Callback = function(Value)
        currentWalkSpeed = Value
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = currentWalkSpeed
        end
    end
})

-- Update WalkSpeed on respawn
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentWalkSpeed
end)

-- Teleport to player input
cheeseTab:CreateInput({
    Name = "Teleport To",
    CurrentValue = "",
    PlaceholderText = "Player Name",
    RemoveTextAfterFocusLost = false,
    Flag = "TPInput",
    Callback = function(Text)
        local targetPlayer = game.Players:FindFirstChild(Text)
        if targetPlayer and targetPlayer.Character and player.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                player.Character:MoveTo(targetHRP.Position + Vector3.new(2,5,0))
            end
        else
            warn("Invalid player or missing parts")
        end
    end
})

-- Disable Damage
cheeseTab:CreateButton({
    Name = "Disable Damage",
    Callback = function()
        if ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DamagePlayer") then
            ReplicatedStorage.Events.DamagePlayer:Destroy()
        end
    end
})

-- ======================================
-- SATK Tab
-- ======================================
local satkTab = Window:CreateTab("SATK Weapons", 4483362458)
satkTab:CreateSection("Weapons")

satkTab:CreateButton({
    Name = "Teleport to All Weapons",
    Callback = function()
        local function getPositionOfModel(model)
            if model:IsA("Model") then
                if model.PrimaryPart then
                    return model.PrimaryPart.Position
                else
                    for _, part in ipairs(model:GetDescendants()) do
                        if part:IsA("BasePart") then return part.Position end
                    end
                end
            end
            return nil
        end

        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local weaponsFolder = workspace:WaitForChild("Weapons")
        local originalCFrame = hrp.CFrame

        local weaponPositions = {}
        for _, child in ipairs(weaponsFolder:GetChildren()) do
            local pos = getPositionOfModel(child)
            if pos then table.insert(weaponPositions,pos) end
        end

        local index = 1
        local heartbeatConn
        heartbeatConn = RunService.Heartbeat:Connect(function()
            if index > #weaponPositions then
                hrp.CFrame = originalCFrame
                heartbeatConn:Disconnect()
                return
            end
            hrp.CFrame = CFrame.new(weaponPositions[index])
            index += 1
        end)
    end
})

-- ======================================
-- Advanced Stealth Adonis Bypass Tab
-- ======================================
local adonisTab = Window:CreateTab("Adonis Bypass", 4483362458)
adonisTab:CreateSection("Stealth Bypass")

do
    local badFunctions = {
        "Crash","CPUCrash","GPUCrash","Shutdown","SoftShutdown",
        "Kick","SoftKick","Seize","BlockInput","Break","Lock",
        "SetCore","ServerKick","ServerShutdown","Ban","Mute",
        "Freeze","TeleportKill","ForceReset","CrashClient",
        "CrashServer","MemoryLeak","BlackScreen","KickAll"
    }

    local function tableFind(tbl,val)
        for i=1,#tbl do if tbl[i]==val then return true end end
        return false
    end

    local function neutralizeModule(modTable)
        if type(modTable)~="table" then return end
        for name,fn in pairs(modTable) do
            if tableFind(badFunctions,name) and type(fn)=="function" then
                modTable[name] = function(...) warn("[Bypass] Blocked Adonis:",name) return nil end
            end
        end
    end

    local oldRequire = require
    local adonisKeywords = {"adonis","clientcommands","security","module"}

    _G.require = function(mod)
        local result = oldRequire(mod)
        if typeof(mod)=="Instance" and mod.Name then
            local lname = mod.Name:lower()
            for _,kw in ipairs(adonisKeywords) do
                if lname:find(kw) then
                    pcall(neutralizeModule,result)
                    break
                end
            end
        end
        return result
    end

    for _,mod in ipairs(getloadedmodules()) do
        if mod.Name and mod.Name:lower():find("adonis") then
            local ok,env = pcall(getsenv,mod)
            if ok and env then neutralizeModule(env) end
            local ok2,mt = pcall(getmetatable,mod)
            if ok2 and type(mt)=="table" then
                for k,v in pairs(mt) do if type(v)=="function" then mt[k]=function(...) return nil end end
            end
        end
    end

    for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("client") then
            obj.OnClientEvent:Connect(function(cmd,...)
                if type(cmd)=="string" and tableFind(badFunctions,cmd) then
                    warn("[Bypass] Blocked Adonis Remote Command:",cmd)
                    return
                end
            end)
        end
    end

    adonisTab:CreateLabel("Advanced Stealth Adonis Bypass active")
end

print("[Kitty Hub] Master Embedded Rayfield Script Loaded Successfully")
