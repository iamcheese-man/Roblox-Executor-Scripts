-- ======================================================
-- ALLOWLIST-ONLY HTTP FIREWALL (EXECUTOR ONLY)
-- ======================================================

local Firewall = {
    Enabled = true,
    Silent = false,
    Log = true,

    -- =====================
    -- DOMAIN + PATH ALLOWLIST
    -- =====================
    Allowlist = {
        ["raw.githubusercontent.com"] = {
            "/iamcheese-man/"
        },

        ["example.com"] = true,
        ["myapi.com"] = true
    },

    -- =====================
    -- BLOCK RESPONSE
    -- =====================
    BlockResponse = {
        StatusCode = 403,
        StatusMessage = "Blocked by HTTP Firewall",
        Body = '{"error":"request blocked"}',
        Headers = {["Content-Type"] = "application/json"},
        Success = false
    }
}

-- ======================================================
-- URL PARSER
-- ======================================================
local function parseUrl(url)
    local _, _, host, path = url:find("^https?://([^/]+)(/.*)$")
    return host, path or "/"
end

-- ======================================================
-- CHECK ALLOWLIST
-- ======================================================
local function shouldBlock(req)
    if not Firewall.Enabled then return false end
    if type(req) ~= "table" or type(req.Url) ~= "string" then
        return true
    end

    local host, path = parseUrl(req.Url)
    if not host then return true end

    local rule = Firewall.Allowlist[host]
    if not rule then
        return true -- domain not allowed
    end

    if rule == true then
        return false -- entire domain allowed
    end

    for _, allowedPath in ipairs(rule) do
        if path:sub(1, #allowedPath) == allowedPath then
            return false
        end
    end

    return true
end

-- ======================================================
-- HTTP HOOKING (EXECUTOR SAFE)
-- ======================================================
local function hook(tbl, name)
    if not tbl or type(tbl[name]) ~= "function" then return end
    local original = tbl[name]

    tbl[name] = function(req)
        if shouldBlock(req) then
            if Firewall.Log then
                warn("[FW] BLOCKED", name, req.Method or "GET", req.Url)
            end

            if Firewall.Silent then
                return {
                    StatusCode = 200,
                    StatusMessage = "OK",
                    Body = "",
                    Headers = {},
                    Success = true
                }
            end

            return {
                StatusCode = Firewall.BlockResponse.StatusCode,
                StatusMessage = Firewall.BlockResponse.StatusMessage,
                Body = Firewall.BlockResponse.Body,
                Headers = Firewall.BlockResponse.Headers,
                Success = false
            }
        end

        return original(req)
    end
end

-- Synapse / forks
if syn then
    hook(syn, "request")
end

-- Generic executors
hook(getfenv(), "http_request")
hook(getfenv(), "request")

-- ======================================================
-- CHAT COMMANDS
-- ======================================================
game.Players.LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()

    if msg == "/fwhttp on" then
        Firewall.Enabled = true
        warn("[FW] HTTP Firewall ENABLED")

    elseif msg == "/fwhttp off" then
        Firewall.Enabled = false
        warn("[FW] HTTP Firewall DISABLED")

    elseif msg == "/fwhttp silent on" then
        Firewall.Silent = true
        warn("[FW] Silent mode ON")

    elseif msg == "/fwhttp silent off" then
        Firewall.Silent = false
        warn("[FW] Silent mode OFF")
    end
end)

warn("[FW] Allowlist-only HTTP firewall loaded ✅")