local E = getgenv().ToxEnv
local ScriptsPage = E.Pages["SCRIPTS"]

E.CreateButton("Infinite Yield", ScriptsPage, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

E.CreateButton("FE Emotes", ScriptsPage, function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/FeEmotes.lua'),true))()
end)

E.CreateButton("Bundle Edit", ScriptsPage, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/BundleEdit.lua"))()
end)

E.CreateButton("Wall Walk", ScriptsPage, function()
    loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
end)

E.CreateButton("PShade", ScriptsPage, function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua'))()
end)
