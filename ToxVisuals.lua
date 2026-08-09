-- ========================================================
-- ToxVisuals.lua - Módulo para a Aba VISUALS
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local VisualsPage = env.VisualsPage
local Settings = env.Settings
local ColorMap = env.ColorMap

local CreateToggle = env.CreateToggle
local CreateToggleWithValue = env.CreateToggleWithValue
local CreateDropdown = env.CreateDropdown

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = env.Player

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "Tox_ESP_Folder"
pcall(function() ESPFolder.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)

local ESPStorage = {}

local function RemoveESP(p)
    if ESPStorage[p] then
        for _, v in pairs(ESPStorage[p]) do pcall(function() v:Destroy() end) end
        ESPStorage[p] = nil
    end
end

local function ClearESP()
    for p in pairs(ESPStorage) do RemoveESP(p) end
    ESPFolder:ClearAllChildren()
end

local function UpdateESP()
    if env.Destroyed or (not Settings.ESP and not Settings.Chams) then
        ClearESP()
        return
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if root and hum and hum.Health > 0 then
                local cache = ESPStorage[p] or {}
                local color = ColorMap[Settings.EspColorName] or Color3.fromRGB(255, 255, 255)

                -- ESP NAMES
                if Settings.ESP then
                    if not cache.Billboard or not cache.Billboard.Parent then
                        local BB = Instance.new("BillboardGui")
                        BB.Name = p.Name .. "_ESP"
                        BB.Adornee = root
                        BB.Size = UDim2.new(0, 200, 0, 50)
                        BB.StudsOffset = Vector3.new(0, 3, 0)
                        BB.AlwaysOnTop = true
                        BB.Parent = ESPFolder

                        local Label = Instance.new("TextLabel")
                        Label.Size = UDim2.new(1, 0, 1, 0)
                        Label.BackgroundTransparency = 1
                        Label.TextColor3 = color
                        Label.TextSize = Settings.EspSize
                        Label.Font = Enum.Font.GothamBold
                        Label.Parent = BB

                        cache.Billboard = BB; cache.Label = Label
                    end
                    cache.Label.Text = Settings.ShowHealth and string.format("%s [%d HP]", p.DisplayName, math.floor(hum.Health)) or p.DisplayName
                    cache.Label.TextColor3 = color
                else
                    if cache.Billboard then cache.Billboard:Destroy(); cache.Billboard = nil end
                end

                -- CHAMS (HIGHLIGHT)
                if Settings.Chams then
                    if not cache.Highlight or not cache.Highlight.Parent then
                        local HL = Instance.new("Highlight")
                        HL.Adornee = char
                        HL.FillColor = color
                        HL.FillTransparency = Settings.ChamOpacity
                        HL.OutlineColor = Color3.fromRGB(255, 255, 255)
                        HL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        HL.Parent = ESPFolder
                        cache.Highlight = HL
                    else
                        cache.Highlight.FillColor = color
                        cache.Highlight.Adornee = char
                    end
                else
                    if cache.Highlight then cache.Highlight:Destroy(); cache.Highlight = nil end
                end

                ESPStorage[p] = cache
            else
                RemoveESP(p)
            end
        else
            RemoveESP(p)
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- FULLBRIGHT
local origAmbient = Lighting.Ambient
RunService.RenderStepped:Connect(function()
    if not env.Destroyed and Settings.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
    end
end)

-- FOV CHANGER
RunService.RenderStepped:Connect(function()
    if not env.Destroyed and Settings.FOVEnabled then
        workspace.CurrentCamera.FieldOfView = Settings.FOVValue
    end
end)

-- BOTÕES DA UI
CreateToggle("Name ESP", VisualsPage, Settings.ESP, function(v) Settings.ESP = v end)
CreateToggle("Show Health", VisualsPage, Settings.ShowHealth, function(v) Settings.ShowHealth = v end)
CreateDropdown("ESP Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Purple"}, VisualsPage, Settings.EspColorName, function(v) Settings.EspColorName = v end)

CreateToggle("Chams (Highlight)", VisualsPage, Settings.Chams, function(v) Settings.Chams = v end)
CreateToggle("Fullbright", VisualsPage, Settings.Fullbright, function(v) 
    Settings.Fullbright = v 
    if not v then Lighting.Ambient = origAmbient end
end)

CreateToggleWithValue("FOV Changer", VisualsPage, Settings.FOVEnabled, Settings.FOVValue, function(v)
    Settings.FOVEnabled = v
    if not v then workspace.CurrentCamera.FieldOfView = 70 end
end, function(v) Settings.FOVValue = v end)
