-- ========================================================
-- ToxConfig.lua - Aba CONFIG
-- ========================================================

local env = getgenv().ToxEnv
if not env then return end

local ConfigPage = env.ConfigPage
local Settings = env.Settings

local CreateToggle = env.CreateToggle
local CreateKeybind = env.CreateKeybind
local CreateButton = env.CreateButton

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = env.Player

-- ANTI AFK
local antiAFKConn
local function StartAntiAFK()
	if antiAFKConn then antiAFKConn:Disconnect(); antiAFKConn = nil end
	antiAFKConn = LocalPlayer.Idled:Connect(function()
		if Settings.AntiAFK and not env.Destroyed then
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new(0, 0))
		end
	end)
end

-- 3D RENDERING
local function Toggle3DRendering(v)
	Settings.Render3D = v
	pcall(function() RunService:Set3dRenderingEnabled(v) end)
end

-- QUEUE ON TELEPORT / REJOIN
local function ApplyTeleportQueue()
	local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (Fluxus and Fluxus.queue_on_teleport) or (http and http.queue_on_teleport)
	if queueteleport then
		local url = getgenv().ToxScriptUrl
		local code = ""
		if url and url ~= "" then
			code = string.format([[
				repeat task.wait() until game:IsLoaded()
				pcall(function() loadstring(game:HttpGet("%s"))() end)
			]], url)
		else
			code = [[
				repeat task.wait() until game:IsLoaded()
				if getgenv().ToxScriptUrl then
					pcall(function() loadstring(game:HttpGet(getgenv().ToxScriptUrl))() end)
				end
			]]
		end
		pcall(function() queueteleport(code) end)
	end
end

-- CONSTRUÇÃO DOS ELEMENTOS DA ABA CONFIG (EXATAMENTE COMO NO SEU SCRIPT ANTIGO)
CreateToggle("Anti AFK", ConfigPage, Settings.AntiAFK, function(v)
    Settings.AntiAFK = v
    if v then StartAntiAFK() end
end)

CreateToggle("Chat Logs", ConfigPage, Settings.ChatLogs, function(v) 
    Settings.ChatLogs = v 
    if env.ChatLogGui then env.ChatLogGui.Visible = v end
end)

CreateToggle("3D Rendering", ConfigPage, Settings.Render3D, function(v)
    Toggle3DRendering(v)
end)

CreateKeybind("GUI Keybind", ConfigPage, Settings.GUIKeybind, function(key)
    Settings.GUIKeybind = key
end)

CreateButton("Rejoin", ConfigPage, function()
	ApplyTeleportQueue()
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
end)

CreateButton("DESTROY", ConfigPage, function()
	env.Destroyed = true
	Toggle3DRendering(true)
    if env.Gui then env.Gui:Destroy() end
    if env.NotifGui then env.NotifGui:Destroy() end
end)

if Settings.AntiAFK then StartAntiAFK() end
