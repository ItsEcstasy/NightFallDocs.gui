local Utility                   = {}
local developer                 = loadstring(game:HttpGet("https://raw.githubusercontent.com/ItsEcstasy/Astral/refs/heads/main/dev/devs"))()
local notifyLibrary             = loadstring(game:HttpGet("https://raw.githubusercontent.com/ItsEcstasy/Astral/refs/heads/main/dev/Notify"))()
local NotifyUI                  = notifyLibrary.Notify;
local debugMode                 = loadstring(game:HttpGet("https://raw.githubusercontent.com/ItsEcstasy/Astral/refs/heads/main/dev/debugMode"))()
local Versions                  = loadstring(game:HttpGet("https://raw.githubusercontent.com/ItsEcstasy/Astral/refs/heads/main/dev/Versions"))()
local Maid                      = loadstring(game:HttpGet("https://raw.githubusercontent.com/ItsEcstasy/Astral/refs/heads/main/dev/Maid"))()
local banList                   = loadstring(game:HttpGet("https://raw.githubusercontent.com/ItsEcstasy/Astral/refs/heads/main/dev/banList"))()
local supportedExecs            = loadstring(game:HttpGet("https://raw.githubusercontent.com/ItsEcstasy/Astral/refs/heads/main/dev/supportedExecs"))()
local services         = setmetatable({}, {__index = function(self, index) self[index] = game:GetService(index) return self[index] end})
local player                    = services.Players.LocalPlayer
local Bypassed                  = true


-- MARK: Security

local Time = tick()
while tick() - Time <= 5 do if game:IsLoaded() then break end task.wait() end


if tick() - Time > 5 then
    return warn("[Astral]: Ping too high to execute Astral")
end


if not table.find(developer, player.Name) and not table.find(supportedExecs,  Utility:fetchExecutor()) then
    return player:Kick("Executor Not Supported")
end




-- MARK: Functions

function Utility:log(...)
    if player and table.find(developer, tostring(player)) then
        print("[Astral]:", ...)
    end
end


function Utility:debug(...)
    if debugMode then
        print("[Debug]:", ...)
    end
end
if debugMode then
    for v = 1, 50 do
        print(" ")
    end
end


function Utility:fetchExecutor()
    return identifyexecutor and identifyexecutor() or "Unknown"
end


function Utility:fetchDevice()
    local platforms = {
        [Enum.Platform.Windows] = "Windows",
        [Enum.Platform.OSX]     = "Mac",
        [Enum.Platform.IOS]     = "iOS",
        [Enum.Platform.Android] = "Android",
        [Enum.Platform.XBoxOne] = "Xbox One",
        [Enum.Platform.PS4]     = "PS4"
    }
    return platforms[services.UserInputService:GetPlatform()] or "N/A"
end


function Utility:fetchLocation()
    local countryCode = services.LocalizationService:GetCountryRegionForPlayerAsync(player)
    if countryCode then
        return countryCode
    else
        return "N/A"
    end
end


function Utility:CheckVoiceChat(Plr)
    if services.VoiceChatService then
        local success, result = pcall(function()
            return services.VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)
        end)
        if success then
            return result and "Enabled" or "Disabled"
        end
    end
    
print(Utility:CheckVoiceChat(Plr))
    return "Disabled"
end



-- MARK: Stats

Utility.Stats = {
    Ping     = "N/A",
    FPS      = "N/A",
    CPU      = "N/A",
    Device   = "N/A",
    Executor = "Unknown"
}

function Utility:trackStats()

    local lastUpdated  = 0
    local fpsCounter   = 0
    local elapsedTime  = 0

    services.RunService.Heartbeat:Connect(function(runTime)
        -- track our ping
        local ping = player:GetNetworkPing() * 1000
        self.Stats.Ping = ping and string.format("%.2f ms", ping) or "N/A"

        -- track our fps
        fpsCounter = fpsCounter + 1
        elapsedTime = elapsedTime + runTime

        if elapsedTime >= 1 then
            self.Stats.FPS = math.floor(fpsCounter / elapsedTime)
            fpsCounter = 0
            elapsedTime = 0
        end

        -- update our cpu usage every .5s
        lastUpdated = lastUpdated + runTime
        if lastUpdated >= 0.5 then
            lastUpdated = 0
            local cpuUsage = services.Stats.PerformanceStats.CPU and services.Stats.PerformanceStats.CPU:GetValue()
            self.Stats.CPU = cpuUsage and (math.floor(cpuUsage) .. "%") or "N/A"
        end
    end)
end


function Utility:fetchStats()
    return self.Stats
end



-- MARK: antiHook


local protectedFunctions = {
    kick = player.Kick
}


local function detectHooks()
    for name, originalFunc in pairs(protectedFunctions) do
        local currentFunc = player[name == "kick" and "Kick" or nil]

        if currentFunc and originalFunc then
            local info = debug.getinfo(currentFunc)
            if info and info.what ~= "C" then
                return true, name
            end
        end
    end
    return false, nil
end


local isHooked, funcName = detectHooks()
if isHooked then
    player:Kick("Bypass detected: HookFunction on " .. funcName)
else
    -- print("No function tampering detected.")
    Bypassed = false
end



-- MARK: Checks

if table.find(banList, services.Players:GetPlayerByUserId(player.UserId).Name) then
    player:Kick("Banned from AstralHub")
    return
end


if not table.find(supportedExecs,  Utility:fetchExecutor()) then
    NotifyUI({
        Description = Utility:fetchExecutor() .. " is not fully supported. Some features may not work";
        Title = " Compatibility Warning";
        Duration = 15;
    })
end


if setmetatable and Bypassed and not table.find(developer, player.Name) then
    hookfunction(setmetatable, function()
        player:Kick("setmetatable not allowed")
    end)
end


if rconsoleprint and Bypassed and not table.find(developer, player.Name) then
    hookfunction(rconsoleprint, function()
        player:Kick("Rconsoles not allowed")
    end)
end


if loadstring and Bypassed and not table.find(developer, player.Name) then
    hookfunction(loadstring, function()
        player:Kick("loadstring not allowed")
    end)
end


if hookfunction and Bypassed and not table.find(developer, player.Name) then
    hookfunction(hookfunction, function()
        player:Kick("hookfunctions not allowed")
    end)
end



-- MARK: Versions Checks

function Utility:checkVersion(Name, Current, Latest)
    if Current ~= Latest then
        NotifyUI({
            Description = ("%s is outdated. Current version: %s, Latest version: %s"):format(Name, Current, Latest),
            Title = "Version Mismatch",
            Duration = 15
        })
    end
end

Utility:checkVersion("Maid Version", Maid.Version, Versions.Maid)
Utility:checkVersion("Script Version", Maid.ScriptVersion, Versions.Script)
Utility:checkVersion("Game Version", Maid.GameVersion, Versions.Game)


return Utility