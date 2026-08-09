-- ========================================================
-- ToxScript.lua - Módulo para a Aba SCRIPTS
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local ScriptsPage = env.ScriptsPage
local CreateButton = env.CreateButton
local CustomNotify = env.CustomNotify

CreateButton("Infinite Yield FE", ScriptsPage, function()
    CustomNotify("Loading Infinite Yield...", Color3.fromRGB(100, 255, 100))
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

CreateButton("Dark Dex V3", ScriptsPage, function()
    CustomNotify("Loading Dex Explorer...", Color3.fromRGB(100, 255, 100))
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

CreateButton("SimpleSpy V2", ScriptsPage, function()
    CustomNotify("Loading RemoteSpy...", Color3.fromRGB(100, 255, 100))
    loadstring(game:HttpGet("https://raw.githubusercontent.com/exserter/SimpleSpyV2/main/SimpleSpy.lua"))()
end)

CreateButton("Rejoin Server", ScriptsPage, function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, env.Player)
end)

CreateButton("Server Hop", ScriptsPage, function()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local function ListServers(cursor)
        local Raw = game:HttpGet(Api .. (cursor and "&cursor=" .. cursor or ""))
        return Http:JSONDecode(Raw)
    end
    
    local ServerList = ListServers()
    for _, server in ipairs(ServerList.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TPS:TeleportToPlaceInstance(game.PlaceId, server.id)
            break
        end
    end
end)
