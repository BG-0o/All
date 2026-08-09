-- ToxScript.lua
local ToxScript = {}

function ToxScript:Init(parentPage, hub)
    hub:CreateButton("Infinite Yield", parentPage, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)

    hub:CreateButton("FE Emotes", parentPage, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VenezzaX/Usefulthings/refs/heads/main/FeEmotes.lua", true))()
    end)

    hub:CreateButton("Bundle Edit", parentPage, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/BundleEdit"))()
    end)

    hub:CreateButton("Wall Walk", parentPage, function()
        loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
    end)

    hub:CreateButton("PShade", parentPage, function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua"))()
    end)
end

return ToxScript
