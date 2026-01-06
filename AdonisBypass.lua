-- Advanced Stealth Adonis Bypass
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local badFunctions = {
    "Crash", "CPUCrash", "GPUCrash", "Shutdown", "SoftShutdown",
    "Kick", "SoftKick", "Seize", "BlockInput", "Break", "Lock",
    "SetCore", "ServerKick", "ServerShutdown", "Ban", "Mute",
    "Freeze", "TeleportKill", "ForceReset", "CrashClient",
    "CrashServer", "MemoryLeak", "BlackScreen", "KickAll"
}
local function tableFind(tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end
local function neutralizeModule(modTable)
    if type(modTable) ~= "table" then
        return
    end
    for name, fn in pairs(modTable) do
        if tableFind(badFunctions, name) and type(fn) == "function" then
            modTable[name] = function(...)
                warn("[Bypass] Blocked Adonis:", name)
                return nil
            end
        end
    end
end
do
    local oldRequire = require
    local adonisKeywords = {
        "adonis",
        "clientcommands",
        "security",
        "module"
    }

    _G.require = function(mod)
        local result = oldRequire(mod)

        if typeof(mod) == "Instance" and mod.Name then
            local lname = mod.Name:lower()
            for _, kw in ipairs(adonisKeywords) do
                if lname:find(kw) then
                    pcall(neutralizeModule, result)
                    break
                end
            end
        end

        return result
    end
end
for _, mod in ipairs(getloadedmodules()) do
    if mod.Name and mod.Name:lower():find("adonis") then
        local ok, env = pcall(getsenv, mod)
        if ok and env then
            neutralizeModule(env)
        end

        local ok2, mt = pcall(getmetatable, mod)
        if ok2 and type(mt) == "table" then
            for k, v in pairs(mt) do
                if type(v) == "function" then
                    mt[k] = function(...)
                        return nil
                    end
                end
            end
        end
    end
end
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and obj.Name:lower():find("client") then
        obj.OnClientEvent:Connect(function(cmd, ...)
            if type(cmd) == "string" and tableFind(badFunctions, cmd) then
                warn("[Bypass] Blocked Adonis Remote Command:", cmd)
                return
            end
            -- allow other events
        end)
    end
end

print("[Bypass] Advanced Adonis stealth bypass loaded.")
