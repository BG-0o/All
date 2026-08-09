-- ToxVisuals.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxVisuals = {}

function ToxVisuals:UpdateESP()
	if not ToxConfig.Settings.ESP then return end
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= LocalPlayer and targetPlayer.Character then
			local char = targetPlayer.Character
			local hl = char:FindFirstChild("ToxESP") or Instance.new("Highlight")
			hl.Name = "ToxESP"
			hl.FillColor = ToxConfig.Settings.EspColor
			hl.OutlineColor = Color3.fromRGB(255, 255, 255)
			hl.FillTransparency = 0.5
			hl.Adornee = char
			hl.Parent = char
		end
	end
end

function ToxVisuals:Init(parentPage, hub)
    hub:CreateToggleWithValue("Enable ESP", parentPage, ToxConfig.Settings.ESP, ToxConfig.Settings.EspSize, function(v) ToxConfig.Settings.ESP = v end, function(val) ToxConfig.Settings.EspSize = val end)
    
    hub:CreateDropdown("ESP Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Magenta", "Orange", "Purple"}, parentPage, ToxConfig.Settings.EspColorName, function(v)
        ToxConfig.Settings.EspColorName = v
        ToxConfig.Settings.EspColor = ToxConfig.ColorMap[v] or Color3.fromRGB(255, 255, 255)
        self:UpdateESP()
    end)

    hub:CreateDropdown("Name Display", {"Display", "Username"}, parentPage, ToxConfig.Settings.NameType, function(v) ToxConfig.Settings.NameType = v end)
    hub:CreateToggle("Show Health", parentPage, ToxConfig.Settings.ShowHealth, function(v) ToxConfig.Settings.ShowHealth = v end)
    hub:CreateToggle("Chams Highlight", parentPage, ToxConfig.Settings.Chams, function(v) ToxConfig.Settings.Chams = v end)
    hub:CreateToggle("Use Team Color", parentPage, ToxConfig.Settings.ShowTeamColor, function(v) ToxConfig.Settings.ShowTeamColor = v end)
    hub:CreateToggle("Ignore Team", parentPage, ToxConfig.Settings.DisableTeam, function(v) ToxConfig.Settings.DisableTeam = v end)
    
    hub:CreateInputWithToggle("Spectate Player", parentPage, "", function(enabled, nick)
        ToxConfig.Settings.Spectating = enabled
    end)

    hub:CreateToggle("Freecam", parentPage, ToxConfig.Settings.Freecam, function(v) ToxConfig.Settings.Freecam = v end)
    hub:CreateToggleWithValue("FOV Editor", parentPage, ToxConfig.Settings.FOVEnabled, ToxConfig.Settings.FOVValue, function(v) ToxConfig.Settings.FOVEnabled = v end, function(val) ToxConfig.Settings.FOVValue = val end)
    hub:CreateToggle("Fullbright", parentPage, ToxConfig.Settings.Fullbright, function(v) ToxConfig.Settings.Fullbright = v end)
end

return ToxVisuals
