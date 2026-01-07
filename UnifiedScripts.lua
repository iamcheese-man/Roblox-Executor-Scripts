--[[ 
    Kitty Hub - Master Embedded Rayfield Script
    Includes:
    1) Music Player
    2) Cheese Escape Rayfield
    3) SATK Get All Weapons
    4) Advanced Stealth Adonis Bypass
--]]

-- ===============================
-- Load Rayfield 
-- ===============================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ===============================
-- Services
-- ===============================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ===============================
-- Main Window
-- ===============================
local Window = Rayfield:CreateWindow({
    Name = "Kitty Hub",
    LoadingTitle = "Kitty Hub",
    LoadingSubtitle = "Unified Script",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "KittyHub",
        FileName = "Main"
    },
    KeySystem = false
})

-- ########################
-- ####  Music Player  ####
-- ########################

local MusicTab = Window:CreateTab("Music", "music")
MusicTab:CreateSection("Local Music Player")

local SoundId = ""
local VolumeValue = 1
local LoopSound = false
local Sound

local recommendedSounds = {
    "9045743976",
    "1846405622",
    "1837768517",
    "1840684529"
}

local function ensureSound()
    if not Sound or not Sound.Parent then
        Sound = Instance.new("Sound")
        Sound.Name = "LocalSound"
        Sound.Parent = player:WaitForChild("PlayerGui")
    end
    Sound.Volume = VolumeValue
    Sound.Looped = LoopSound
end

ensureSound()

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    ensureSound()
end)

MusicTab:CreateInput({
    Name = "Sound ID",
    PlaceholderText = "Enter Sound ID",
    Flag = "Music_SoundID",
    Callback = function(text)
        SoundId = text
    end
})

MusicTab:CreateDropdown({
    Name = "Recommended Sounds",
    Options = recommendedSounds,
    Flag = "Music_Recommended",
    Callback = function(option)
        SoundId = typeof(option) == "table" and option[1] or option
        Rayfield:Notify({
            Title = "Selected",
            Content = "Sound ID: "..SoundId,
            Duration = 2
        })
    end
})

MusicTab:CreateSlider({
    Name = "Volume",
    Range = {0,100},
    Increment = 1,
    CurrentValue = 100,
    Flag = "Music_Volume",
    Callback = function(v)
        VolumeValue = v / 100
        ensureSound()
    end
})

MusicTab:CreateToggle({
    Name = "Loop Sound",
    CurrentValue = false,
    Flag = "Music_Loop",
    Callback = function(v)
        LoopSound = v
        ensureSound()
    end
})

MusicTab:CreateButton({
    Name = "▶ Play",
    Callback = function()
        local id = tonumber(SoundId)
        if not id then
            Rayfield:Notify({Title="Error",Content="Invalid Sound ID",Duration=2})
            return
        end
        ensureSound()
        Sound.SoundId = "rbxassetid://"..id
        Sound:Play()
        Rayfield:Notify({
            Title = "Playing",
            Content = "Sound ID: "..id,
            Duration = 3
        })
    end
})

MusicTab:CreateButton({
    Name = "⏹ Stop",
    Callback = function()
        if Sound and Sound.IsPlaying then
            Sound:Stop()
        end
    end
})
-- #######################
-- ####  Draw or Oof  ####
-- #######################

local ChatTab = Window:CreateTab("Draw or Oof!", "brush")
ChatTab:CreateSection("Chat Bypass + Spam")

local ChatMessage = ""
local SpamDelay = 1
local Spamming = false

ChatTab:CreateInput({
	Name = "Message",
	PlaceholderText = "msg here",
	Flag = "Chat_Message",
	Callback = function(txt)
		ChatMessage = txt
	end
})

ChatTab:CreateInput({
	Name = "Delay (sec)",
	PlaceholderText = "1",
	Flag = "Chat_Delay",
	Callback = function(txt)
		SpamDelay = tonumber(txt) or 1
	end
})

ChatTab:CreateButton({
	Name = "Send Once",
	Callback = function()
		if ChatMessage == "" then return end
		pcall(function()
			ReplicatedStorage.Remotes.BuyPlatform:FireServer(ChatMessage)
		end)
	end
})

ChatTab:CreateToggle({
	Name = "Spam",
	CurrentValue = false,
	Flag = "Chat_Spam",
	Callback = function(state)
		Spamming = state
		if state then
			task.spawn(function()
				while Spamming do
					if ChatMessage ~= "" then
						pcall(function()
							ReplicatedStorage.Remotes.BuyPlatform:FireServer(ChatMessage)
						end)
					end
					task.wait(SpamDelay)
				end
			end)
		end
	end
})

ChatTab:CreateLabel("⚠ Lobby only")

-- #######################
-- #### Cheese Escape ####
-- #######################

local CheeseTab = Window:CreateTab("Cheese Escape", "rat")
CheeseTab:CreateSection("Server")

CheeseTab:CreateButton({
    Name = "Get 1 Cheese",
    Callback = function()
        pcall(function()
            ReplicatedStorage.AddCheese:FireServer()
        end)
    end
})

CheeseTab:CreateSection("Local Player")

local WalkSpeedValue = 16

local function applyWalkSpeed()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = WalkSpeedValue
        end
    end
end

CheeseTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {0,500},
    Increment = 1,
    CurrentValue = 16,
    Flag = "Cheese_WalkSpeed",
    Callback = function(v)
        WalkSpeedValue = v
        applyWalkSpeed()
    end
})

player.CharacterAdded:Connect(function()
    task.wait(0.2)
    applyWalkSpeed()
end)

CheeseTab:CreateInput({
    Name = "Teleport To Player",
    PlaceholderText = "Player Name",
    Flag = "Cheese_Teleport",
    Callback = function(name)
        local target = Players:FindFirstChild(name)
        if target and target.Character and player.Character then
            local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if tHRP and myHRP then
                myHRP.CFrame = tHRP.CFrame * CFrame.new(2,0,0)
            end
        end
    end
})

CheeseTab:CreateButton({
    Name = "Disable Damage",
    Callback = function()
        local events = ReplicatedStorage:FindFirstChild("Events")
        if events and events:FindFirstChild("DamagePlayer") then
            events.DamagePlayer:Destroy()
        end
    end
})

-- #######################
-- ####     SATK      ####
-- #######################

local SATKTab = Window:CreateTab("SATK", "sword")
SATKTab:CreateSection("Weapons")

SATKTab:CreateButton({
    Name = "Teleport to All Weapons",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local weapons = workspace:WaitForChild("Weapons")
        local original = hrp.CFrame

        local positions = {}
        for _, m in ipairs(weapons:GetChildren()) do
            if m:IsA("Model") then
                local part = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    table.insert(positions, part.Position)
                end
            end
        end

        local i = 1
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if i > #positions then
                hrp.CFrame = original
                conn:Disconnect()
                return
            end
            hrp.CFrame = CFrame.new(positions[i])
            i += 1
        end)
    end
})

-- #######################
-- #### Adonis Bypass ####
-- #######################

local AdonisTab = Window:CreateTab("Adonis", "shield")
AdonisTab:CreateSection("Client Protection")

local BypassEnabled = false

local badFunctions = {
    "Crash","CPUCrash","GPUCrash","Shutdown","SoftShutdown",
    "Kick","SoftKick","Seize","BlockInput","Break","Lock",
    "SetCore","ServerKick","ServerShutdown","Ban","Mute",
    "Freeze","TeleportKill","ForceReset","CrashClient",
    "CrashServer","MemoryLeak","BlackScreen","KickAll"
}

local function tableFind(t,v)
    for _,x in ipairs(t) do if x == v then return true end end
end

local function neutralize(tbl)
    if type(tbl) ~= "table" then return end
    for k,v in pairs(tbl) do
        if tableFind(badFunctions,k) and type(v)=="function" then
            tbl[k] = function() warn("[Adonis Blocked]",k) end
        end
    end
end

AdonisTab:CreateToggle({
    Name = "Enable Adonis Bypass",
    CurrentValue = false,
    Flag = "Adonis_Enable",
    Callback = function(v)
        BypassEnabled = v
        if not v then return end

        for _,m in ipairs(getloadedmodules()) do
            if m.Name and m.Name:lower():find("adonis") then
                pcall(function() neutralize(getsenv(m)) end)
            end
        end

        for _,r in ipairs(ReplicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") then
                r.OnClientEvent:Connect(function(cmd)
                    if BypassEnabled and type(cmd)=="string" and tableFind(badFunctions,cmd) then
                        warn("[Blocked Adonis Remote]",cmd)
                        return
                    end
                end)
            end
        end

        Rayfield:Notify({
            Title = "Adonis",
            Content = "Bypass Enabled",
            Duration = 3
        })
    end
})

print("[Kitty Hub] loaded, more features coming soon")
