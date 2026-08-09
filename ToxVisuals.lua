-- ToxVisuals.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxVisuals = {
    ESPEnabled = false,
    ESPColor = Color3.fromRGB(255, 0, 0)
}

-- Carregar Cor Salva
local savedColor = ToxConfig:Get("Visuals", "ESPColor", {1, 0, 0})
ToxVisuals.ESPColor = Color3.new(savedColor[1], savedColor[2], savedColor[3])

function ToxVisuals:SetESPColor(color3)
    self.ESPColor = color3
    ToxConfig:Set("Visuals", "ESPColor", {color3.R, color3.G, color3.B})
    self:ApplyESP()
end

function ToxVisuals:ToggleESP(state)
    self.ESPEnabled = state
    ToxConfig:Set("Visuals", "ESP", state)
    if not state then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ToxESP") then
                p.Character.ToxESP:Destroy()
            end
        end
    else
        self:ApplyESP()
    end
end

function ToxVisuals:ApplyESP()
    if not self.ESPEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("ToxESP") or Instance.new("Highlight")
            hl.Name = "ToxESP"
            hl.FillColor = self.ESPColor
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.Adornee = p.Character
            hl.Parent = p.Character
        end
    end
end

function ToxVisuals:Init(parentFrame, hub)
    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(1, -10, 0, 32)
    espBtn.BackgroundColor3 = ToxConfig:Get("Visuals", "ESP", false) and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    espBtn.Text = "ESP Highlight: " .. (ToxConfig:Get("Visuals", "ESP", false) and "ON" or "OFF")
    espBtn.Font = Enum.Font.SourceSansBold
    espBtn.TextSize = 14
    espBtn.Parent = parentFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = espBtn

    espBtn.MouseButton1Click:Connect(function()
        local state = not ToxConfig:Get("Visuals", "ESP", false)
        self:ToggleESP(state)
        espBtn.Text = "ESP Highlight: " .. (state and "ON" or "OFF")
        espBtn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(40, 40, 40)
    end)

    -- Botões de Seleção de Cores Rápidas (Salva Automaticamente)
    local colorsFrame = Instance.new("Frame")
    colorsFrame.Size = UDim2.new(1, -10, 0, 30)
    colorsFrame.BackgroundTransparency = 1
    colorsFrame.Parent = parentFrame

    local colorList = {
        { Name = "Vermelho", Color = Color3.fromRGB(255, 0, 0) },
        { Name = "Verde", Color = Color3.fromRGB(0, 255, 0) },
        { Name = "Azul", Color = Color3.fromRGB(0, 150, 255) },
        { Name = "Amarelo", Color = Color3.fromRGB(255, 255, 0) }
    }

    for i, c in ipairs(colorList) do
        local cBtn = Instance.new("TextButton")
        cBtn.Size = UDim2.new(0.23, 0, 1, 0)
        cBtn.Position = UDim2.new((i - 1) * 0.25, 0, 0, 0)
        cBtn.BackgroundColor3 = c.Color
        cBtn.Text = ""
        cBtn.Parent = colorsFrame

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 4)
        cCorner.Parent = cBtn

        cBtn.MouseButton1Click:Connect(function()
            self:SetESPColor(c.Color)
        end)
    end

    if ToxConfig:Get("Visuals", "ESP", false) then
        self:ToggleESP(true)
    end
end

return ToxVisuals
