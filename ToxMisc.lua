-- ToxMisc.lua
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxMisc = {}

function ToxMisc:Init(parentPage, hub)
    local MAIN_COLOR = Color3.fromRGB(9, 0, 136)

    -- Janela de Chat Logs com Botão de Minimizar "-"
    local ChatLogGui = Instance.new("Frame")
    ChatLogGui.Name = "ChatLogFrame"
    ChatLogGui.Size = UDim2.new(0, 350, 0, 230)
    ChatLogGui.Position = UDim2.new(0.5, 180, 0.5, -115)
    ChatLogGui.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    ChatLogGui.BorderSizePixel = 0
    ChatLogGui.ClipsDescendants = true
    ChatLogGui.Visible = false
    ChatLogGui.Parent = hub.Gui

    local ChatLogCorner = Instance.new("UICorner")
    ChatLogCorner.CornerRadius = UDim.new(0, 8)
    ChatLogCorner.Parent = ChatLogGui

    local ChatLogStroke = Instance.new("UIStroke")
    ChatLogStroke.Color = MAIN_COLOR
    ChatLogStroke.Thickness = 2
    ChatLogStroke.Parent = ChatLogGui

    local ChatLogTopBar = Instance.new("Frame")
    ChatLogTopBar.Size = UDim2.new(1, 0, 0, 32)
    ChatLogTopBar.BackgroundColor3 = MAIN_COLOR
    ChatLogTopBar.BorderSizePixel = 0
    ChatLogTopBar.Parent = ChatLogGui

    local ChatLogTitle = Instance.new("TextLabel")
    ChatLogTitle.Size = UDim2.new(1, -110, 1, 0)
    ChatLogTitle.Position = UDim2.new(0, 10, 0, 0)
    ChatLogTitle.BackgroundTransparency = 1
    ChatLogTitle.Text = "Chat Logs"
    ChatLogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ChatLogTitle.Font = Enum.Font.GothamBold
    ChatLogTitle.TextSize = 13
    ChatLogTitle.TextXAlignment = Enum.TextXAlignment.Left
    ChatLogTitle.Parent = ChatLogTopBar

    local ChatLogContent = Instance.new("Frame")
    ChatLogContent.Size = UDim2.new(1, 0, 1, -32)
    ChatLogContent.Position = UDim2.new(0, 0, 0, 32)
    ChatLogContent.BackgroundTransparency = 1
    ChatLogContent.Parent = ChatLogGui

    hub:AddMinimizeButton(ChatLogTopBar, ChatLogContent)

    -- Janela do Music Player com Botão de Minimizar "-"
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

    -- Botão para abrir o Music Player na Aba MISC
    local musicBtn = Instance.new("TextButton")
    musicBtn.Size = UDim2.new(1, -5, 0, 39)
    musicBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    musicBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    musicBtn.Text = "Music Player"
    musicBtn.Font = Enum.Font.GothamMedium
    musicBtn.TextSize = 13
    musicBtn.Parent = parentPage

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 4)
    mCorner.Parent = musicBtn

    musicBtn.MouseButton1Click:Connect(function()
        MusicGui.Visible = not MusicGui.Visible
    end)
end

return ToxMisc
