-- ========================================================
-- ToxScript.lua - Aba SCRIPTS
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local ScriptsPage = env.ScriptsPage
local CreateButton = env.CreateButton

CreateButton("Infinite Yield", ScriptsPage, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

CreateButton("FE Emotes", ScriptsPage, function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/VenezzaX/Useful-things/refs/heads/main/FeEmotes.lua'),true))()
end)

CreateButton("Bundle Edit", ScriptsPage, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/BundleEdit?token=GHSAT0AAAAAAEEZIWW5WJZ2VEJNTVX5JP422TW5S7Q"))()
end)

CreateButton("Wall Walk", ScriptsPage, function()
    loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
end)

CreateButton("PShade", ScriptsPage, function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua'))()
end)
