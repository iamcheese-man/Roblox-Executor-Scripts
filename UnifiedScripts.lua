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

-- #################################
-- ## Click / Touch Multi Manager ##
-- #################################

local InteractTab = Window:CreateTab("Interactions", "mouse-pointer")
InteractTab:CreateSection("ClickDetector / TouchInterest")

local PathsText = ""
local SpamEnabled = false
local SpamDelay = 1

-- ======================
-- Path Resolver
-- ======================
local function resolvePath(path)
    local current = game
    for part in string.gmatch(path, "[^%.]+") do
        if part == "game" then
            current = game
        else
            current = current:FindFirstChild(part)
        end
        if not current then return nil end
    end
    return current
end

-- ======================
-- Fire Single Instance
-- ======================
local function fireInstance(inst)
    if inst:IsA("ClickDetector") then
        pcall(function()
            fireclickdetector(inst)
        end)
        print("[Interaction] ClickDetector:", inst:GetFullName())
        Rayfield:Notify({
            Title = "ClickDetector",
            Content = inst.Name.." fired",
            Duration = 1.5
        })
        return true
    end

    if inst:IsA("TouchInterest") then
        local char = Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local part = inst.Parent

        if hrp and part then
            pcall(function()
                firetouchinterest(hrp, part, 0)
                task.wait()
                firetouchinterest(hrp, part, 1)
            end)
            print("[Interaction] TouchInterest:", inst:GetFullName())
            Rayfield:Notify({
                Title = "TouchInterest",
                Content = inst.Name.." touched",
                Duration = 1.5
            })
            return true
        end
    end

    return false
end

-- ======================
-- Process All Paths
-- ======================
local function processAll()
    for line in string.gmatch(PathsText, "[^\r\n]+") do
        local path = line:gsub("^%s+", ""):gsub("%s+$", "")
        if path ~= "" then
            local inst = resolvePath(path)
            if inst then
                fireInstance(inst)
            else
                warn("[Interaction] Invalid path:", path)
            end
        end
    end
end

-- ======================
-- Inputs
-- ======================
InteractTab:CreateInput({
    Name = "Instance Paths",
    PlaceholderText = 
        "workspace.Button.ClickDetector\nworkspace.Pad.TouchInterest",
    Flag = "Interact_Paths",
    Callback = function(v)
        PathsText = v
    end
})

InteractTab:CreateInput({
    Name = "Spam Delay (seconds)",
    PlaceholderText = "1",
    Flag = "Interact_Delay",
    Callback = function(v)
        SpamDelay = tonumber(v) or 1
    end
})

-- ======================
-- Buttons
-- ======================
InteractTab:CreateButton({
    Name = "Fire Once",
    Callback = function()
        processAll()
    end
})

InteractTab:CreateToggle({
    Name = "Spam All",
    CurrentValue = false,
    Flag = "Interact_Spam",
    Callback = function(state)
        SpamEnabled = state
        if state then
            task.spawn(function()
                while SpamEnabled do
                    processAll()
                    task.wait(SpamDelay)
                end
            end)
        end
    end
})

InteractTab:CreateLabel("✔ One path per line | Auto‑detects type")

-- ########################
-- #### Client Firewall ###
-- ########################

local FirewallTab = Window:CreateTab("Firewall", "shield")
FirewallTab:CreateSection("HTTP Request Control")

local FirewallEnabled = false
local BlockCode = 403
local BlockMessage = "Blocked by Client Firewall"
local OriginalRequests = {}

local function hookRequest(name, fn)
    if typeof(fn) ~= "function" then return end
    if OriginalRequests[name] then return end

    OriginalRequests[name] = fn

    pcall(function()
        hookfunction(fn, function(req)
            if FirewallEnabled then
                local url = typeof(req) == "table" and req.Url or tostring(req)
                warn("[Firewall] Blocked request:", url)
                Rayfield:Notify({
            Title = "Firewall Blocked Request",
            Content = url,
            Duration = 3
        })

                return {
                    Success = false,
                    StatusCode = BlockCode,
                    Body = BlockMessage,
                    Headers = {}
                }
            end

            return OriginalRequests[name](req)
        end)
    end)
end

-- Hook all known executor HTTP APIs safely
pcall(function()
    hookRequest("syn.request", syn and syn.request)
    hookRequest("http.request", http and http.request)
    hookRequest("http_request", http_request)
    hookRequest("request", request)
    hookRequest("fluxus.request", fluxus and fluxus.request)
    hookRequest("krnl.request", krnl and krnl.request)
end)

-- ======================
-- UI Controls
-- ======================

FirewallTab:CreateToggle({
    Name = "Block ALL HTTP Requests",
    CurrentValue = false,
    Flag = "Firewall_BlockAll",
    Callback = function(state)
        FirewallEnabled = state
        Rayfield:Notify({
            Title = "Client Firewall",
            Content = state and "All HTTP requests blocked" or "HTTP requests restored",
            Duration = 3
        })
    end
})

FirewallTab:CreateInput({
    Name = "Return Status Code",
    PlaceholderText = "403",
    Flag = "Firewall_Code",
    Callback = function(v)
        local n = tonumber(v)
        if n then BlockCode = n end
    end
})

FirewallTab:CreateInput({
    Name = "Return Message",
    PlaceholderText = "Blocked by Client Firewall",
    Flag = "Firewall_Message",
    Callback = function(v)
        if v ~= "" then
            BlockMessage = v
        end
    end
})

FirewallTab:CreateLabel("⚠ Returned to calling script")

-- ########################
-- #### Webhook Manager ###
-- ########################

local WebhookTab = Window:CreateTab("Webhooks", "webhook")
WebhookTab:CreateSection("Webhook Manager")

local HttpService = game:GetService("HttpService")

-- ======================
-- State
-- ======================
local WebhookURL = ""
local Username = "Kitty Hub"
local AvatarURL = ""
local MessageContent = ""
local EmbedTitle = ""
local EmbedDescription = ""
local EmbedColor = 0xFF69B4

local SpamEnabled = false
local SpamDelay = 1

-- ======================
-- HTTP Resolver
-- ======================
local http_request =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

-- ======================
-- Inputs
-- ======================
WebhookTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    Flag = "Webhook_URL",
    Callback = function(v)
        WebhookURL = v
    end
})

WebhookTab:CreateInput({
    Name = "Username",
    PlaceholderText = "Kitty Hub",
    Flag = "Webhook_Username",
    Callback = function(v)
        Username = v
    end
})

WebhookTab:CreateInput({
    Name = "Avatar URL",
    PlaceholderText = "https://image.png",
    Flag = "Webhook_Avatar",
    Callback = function(v)
        AvatarURL = v
    end
})

WebhookTab:CreateInput({
    Name = "Message",
    PlaceholderText = "Hello from Kitty Hub",
    Flag = "Webhook_Message",
    Callback = function(v)
        MessageContent = v
    end
})

WebhookTab:CreateSection("Embed")

WebhookTab:CreateInput({
    Name = "Embed Title",
    PlaceholderText = "Optional",
    Flag = "Webhook_EmbedTitle",
    Callback = function(v)
        EmbedTitle = v
    end
})

WebhookTab:CreateInput({
    Name = "Embed Description",
    PlaceholderText = "Optional",
    Flag = "Webhook_EmbedDesc",
    Callback = function(v)
        EmbedDescription = v
    end
})

WebhookTab:CreateInput({
    Name = "Embed Color (HEX)",
    PlaceholderText = "FF69B4",
    Flag = "Webhook_EmbedColor",
    Callback = function(v)
        local n = tonumber(v, 16)
        if n then EmbedColor = n end
    end
})

-- ======================
-- Delay Slider
-- ======================
WebhookTab:CreateSlider({
    Name = "Spam Delay (seconds)",
    Range = {0.1, 10},
    Increment = 0.1,
    CurrentValue = 1,
    Flag = "Webhook_Delay",
    Callback = function(v)
        SpamDelay = v
    end
})

-- ======================
-- Send Function
-- ======================
local function sendWebhook()
    if WebhookURL == "" or not http_request then return end

    local payload = {
        username = Username ~= "" and Username or nil,
        avatar_url = AvatarURL ~= "" and AvatarURL or nil,
        content = MessageContent ~= "" and MessageContent or nil,
        embeds = {}
    }

    if EmbedTitle ~= "" or EmbedDescription ~= "" then
        table.insert(payload.embeds, {
            title = EmbedTitle ~= "" and EmbedTitle or nil,
            description = EmbedDescription ~= "" and EmbedDescription or nil,
            color = EmbedColor
        })
    end

    http_request({
        Url = WebhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(payload)
    })
end

-- ======================
-- Buttons
-- ======================
WebhookTab:CreateButton({
    Name = "Send Once",
    Callback = function()
        sendWebhook()
        Rayfield:Notify({
            Title = "Webhook",
            Content = "Message sent",
            Duration = 2
        })
    end
})

WebhookTab:CreateToggle({
    Name = "Spam Webhook",
    CurrentValue = false,
    Flag = "Webhook_Spam",
    Callback = function(state)
        SpamEnabled = state
        if state then
            task.spawn(function()
                while SpamEnabled do
                    sendWebhook()
                    task.wait(SpamDelay)
                end
            end)
        end
    end
})

-- ======================
-- CLEAR TEXTBOXES (LOCAL)
-- ======================
WebhookTab:CreateButton({
    Name = "Clear Textboxes",
    Callback = function()
        WebhookURL = ""
        Username = "Kitty Hub"
        AvatarURL = ""
        MessageContent = ""
        EmbedTitle = ""
        EmbedDescription = ""
        EmbedColor = 0xFF69B4

        Rayfield:Notify({
            Title = "Webhook",
            Content = "Textboxes cleared",
            Duration = 2
        })
    end
})

-- ======================
-- DELETE WEBHOOK (REAL)
-- ======================
WebhookTab:CreateButton({
    Name = "Delete Webhook",
    Callback = function()
        if WebhookURL == "" or not http_request then
            Rayfield:Notify({
                Title = "Webhook",
                Content = "Invalid or missing URL",
                Duration = 2
            })
            return
        end

        http_request({
            Url = WebhookURL,
            Method = "DELETE"
        })

        Rayfield:Notify({
            Title = "Webhook",
            Content = "DELETE request sent",
            Duration = 3
        })
    end
})

WebhookTab:CreateLabel("⚠ Delete permanently removes the webhook")

-- #######################
-- ####  Chat Bypass  ####
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
