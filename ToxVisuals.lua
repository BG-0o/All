-- ToxVisuals.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxVisuals.lua")) or loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxVisuals = {
    ESPStorage = {}
}

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
    local function CreateDropdown(Name, Options, Page, DefaultOption, Callback)
        local Box = Instance.new("Frame")
        Box.Size = UDim2.new(1, -5, 0, 48)
        Box.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        Box.BorderSizePixel = 0
        Box.Parent = Page

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -110, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Color3.fromRGB(240, 240, 240)
        Label.TextSize = 13
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Box

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 95, 0, 27)
        Button.Position = UDim2.new(1, -107, 0.5, -13)
        Button.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
        Button.BorderSizePixel = 0
        Button.Text = DefaultOption
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 12
        Button.Font = Enum.Font.Gotham
        Button.Parent = Box

        local CurrentIdx = 1
        for i, opt in ipairs(Options) do if opt == DefaultOption then CurrentIdx = i end end

        Button.MouseButton1Click:Connect(function()
            CurrentIdx = CurrentIdx + 1
            if CurrentIdx > #Options then CurrentIdx = 1 end
            Button.Text = Options[CurrentIdx]
            Callback(Options[CurrentIdx])
            ToxConfig:Save()
        end)
        return Box
    end

    CreateDropdown("ESP Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Magenta", "Orange", "Purple"}, parentPage, ToxConfig.Settings.EspColorName, function(v)
        ToxConfig.Settings.EspColorName = v
        ToxConfig.Settings.EspColor = ToxConfig.ColorMap[v] or Color3.fromRGB(255, 255, 255)
        self:UpdateESP()
    end)
end

return ToxVisuals
