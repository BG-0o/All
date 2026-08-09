-- ToxHub.lua
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local ToxConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxConfig.lua"))()

local ToxHub = {
    Version = "2.1.0",
    Windows = {},
    Tabs = {},
    CurrentTab = nil
}

-- Torna qualquer Frame arrastável
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Botão de Minimizar ("-") Universal para qualquer Janela/GUI criada
function ToxHub:AddMinimizeButton(windowFrame, contentFrame)
    local header = windowFrame:FindFirstChild("Header") or windowFrame:FindFirstChild("TitleBar") or windowFrame:FindFirstChild("TopBar")
    if not header then
        header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        header.BorderSizePixel = 0
        header.Parent = windowFrame
    end

    if header:FindFirstChild("MinimizeBtn") then return end

    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeBtn"
    minBtn.Size = UDim2.new(0, 24, 0, 22)
    minBtn.Position = UDim2.new(1, -28, 0, 4)
    minBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.TextSize = 18
    minBtn.Parent = header

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = minBtn

    local isMinimized = false
    local originalSize = windowFrame.Size

    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if contentFrame then
            contentFrame.Visible = not isMinimized
        end
        if isMinimized then
            originalSize = windowFrame.Size
            windowFrame:TweenSize(UDim2.new(windowFrame.Size.X.Scale, windowFrame.Size.X.Offset, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
            minBtn.Text = "+"
        else
            windowFrame:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
            minBtn.Text = "-"
        end
    end)
end

-- ScreenGui Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ToxHub_MainGUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 380)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ToxHub | Multi-Script Suite v2.1"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

MakeDraggable(MainFrame, Header)

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, 0, 1, -32)
ContentContainer.Position = UDim2.new(0, 0, 0, 32)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = ContentContainer

local SidebarList = Instance.new("UIListLayout")
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 4)
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 6)
SidebarPadding.PaddingLeft = UDim.new(0, 6)
SidebarPadding.PaddingRight = UDim.new(0, 6)
SidebarPadding.Parent = Sidebar

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, -130, 1, 0)
TabContainer.Position = UDim2.new(0, 130, 0, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = ContentContainer

-- Aplica o Botão de Minimizar na Janela Principal
ToxHub:AddMinimizeButton(MainFrame, ContentContainer)

function ToxHub:CreateTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "TabBtn"
    tabBtn.Size = UDim2.new(1, 0, 0, 30)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.SourceSansBold
    tabBtn.TextSize = 14
    tabBtn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = tabBtn

    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "TabFrame"
    tabFrame.Size = UDim2.new(1, -12, 1, -12)
    tabFrame.Position = UDim2.new(0, 6, 0, 6)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false
    tabFrame.ScrollBarThickness = 4
    tabFrame.Parent = TabContainer

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 6)
    list.Parent = tabFrame

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(ToxHub.Tabs) do
            t.Frame.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            t.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        tabFrame.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToxHub.CurrentTab = name
    end)

    ToxHub.Tabs[name] = { Button = tabBtn, Frame = tabFrame }
    
    if not ToxHub.CurrentTab then
        tabFrame.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToxHub.CurrentTab = name
    end

    return tabFrame
end

-- Carregar Módulos dos Links
ToxHub.Modules = {
    Combat = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxCombat.lua"))(),
    Player = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxPlayer.lua"))(),
    Visuals = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxVisuals.lua"))(),
    Misc = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxMisc.lua"))(),
    Script = loadstring(game:HttpGet("https://raw.githubusercontent.com/BG-0o/All/refs/heads/main/ToxScript.lua"))(),
    Config = ToxConfig
}

-- Inicializar Abas
local combatTab = ToxHub:CreateTab("COMBAT")
local playerTab = ToxHub:CreateTab("PLAYER")
local visualsTab = ToxHub:CreateTab("VISUALS")
local miscTab = ToxHub:CreateTab("MISC")
local scriptsTab = ToxHub:CreateTab("SCRIPTS")
local configTab = ToxHub:CreateTab("CONFIG")

if ToxHub.Modules.Combat.Init then ToxHub.Modules.Combat:Init(combatTab, ToxHub) end
if ToxHub.Modules.Player.Init then ToxHub.Modules.Player:Init(playerTab, ToxHub) end
if ToxHub.Modules.Visuals.Init then ToxHub.Modules.Visuals:Init(visualsTab, ToxHub) end
if ToxHub.Modules.Misc.Init then ToxHub.Modules.Misc:Init(miscTab, ToxHub) end
if ToxHub.Modules.Script.Init then ToxHub.Modules.Script:Init(scriptsTab, ToxHub) end
if ToxConfig.InitUI then ToxConfig:InitUI(configTab, ToxHub) end

return ToxHub
