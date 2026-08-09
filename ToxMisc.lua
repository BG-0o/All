-- ToxMisc.lua
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxMisc = {}

function ToxMisc:Init(parentPage, hub)
    hub:CreateToggle("Ctrl Click TP", parentPage, ToxConfig.Settings.CtrlClickTP, function(v) ToxConfig.Settings.CtrlClickTP = v end)
    hub:CreateToggle("No Fall Damage", parentPage, ToxConfig.Settings.NoFallDamage, function(v) ToxConfig.Settings.NoFallDamage = v end)
    hub:CreateToggle("Anti Void", parentPage, ToxConfig.Settings.AntiVoid, function(v) ToxConfig.Settings.AntiVoid = v end)
    hub:CreateToggle("Anti Fling", parentPage, ToxConfig.Settings.AntiFling, function(v) ToxConfig.Settings.AntiFling = v end)
    
    hub:CreateInputWithButton("Target Fling", parentPage, "", "Fling", function(text)
        if hub.Modules.Combat then
            hub.Modules.Combat:ExecuteFling(text, hub)
        end
    end)

    -- Janela do Music Player com Botão de Minimizar "-"
    local MAIN_COLOR = Color3.fromRGB(9, 0, 136)
    local MusicGui = Instance.new("Frame")
    MusicGui.Name = "MusicPlayerFrame"
    MusicGui.Size = UDim2.new(0, 330, 0, 350)
    MusicGui.Position = UDim2.new(0.5, -165, 0.5, -175)
    MusicGui.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    MusicGui.BorderSizePixel = 0
    MusicGui.ClipsDescendants = true
    MusicGui.Visible = false
    MusicGui.Parent = hub.Gui

    local MusicCorner = Instance.new("UICorner")
    MusicCorner.CornerRadius = UDim.new(0, 8)
    MusicCorner.Parent = MusicGui

    local MusicTopBar = Instance.new("Frame")
    MusicTopBar.Size = UDim2.new(1, 0, 0, 32)
    MusicTopBar.BackgroundColor3 = MAIN_COLOR
    MusicTopBar.BorderSizePixel = 0
    MusicTopBar.Parent = MusicGui

    local MusicContent = Instance.new("Frame")
    MusicContent.Size = UDim2.new(1, 0, 1, -32)
    MusicContent.Position = UDim2.new(0, 0, 0, 32)
    MusicContent.BackgroundTransparency = 1
    MusicContent.Parent = MusicGui

    hub:AddMinimizeButton(MusicTopBar, MusicContent)

    hub:CreateButton("Music Player", parentPage, function()
        MusicGui.Visible = not MusicGui.Visible
    end)
end

return ToxMisc
