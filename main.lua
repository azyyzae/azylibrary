--[[

	Rayfield Interface Suite
	by Sirius

	shlex  | Designing + Programming
	iRay   | Programming
	Max    | Programming
	Damian | Programming

]]

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

local HttpService = getService('HttpService')
local RunService = getService('RunService')
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

local IS_STUDIO = RunService:IsStudio() or false

local function loadWithTimeout(url: string, timeout: number?): ...any
	assert(type(url) == "string", "Expected string, got " .. type(url))
	timeout = timeout or 5
	local requestCompleted = false
	local success, result = false, nil

	local requestThread = task.spawn(function()
		local fetchSuccess, fetchResult = pcall(game.HttpGet, game, url)
		if not fetchSuccess or #fetchResult == 0 then
			local errorMessage = fetchSuccess and "Empty response" or fetchResult
			success, result = false, errorMessage
			requestCompleted = true
			return
		end
		
		local execSuccess, execResult = pcall(function()
			return loadstring(fetchResult)()
		end)
		success, result = execSuccess, execResult
		requestCompleted = true
	end)

	local timeoutThread = task.delay(timeout, function()
		if not requestCompleted then
			task.cancel(requestThread)
			result = "Request timed out"
			requestCompleted = true
		end
	end)

	while not requestCompleted do
		task.wait()
	end
	
	if coroutine.status(timeoutThread) ~= "dead" then
		task.cancel(timeoutThread)
	end
	
	if not success then
		warn(`Failed to process {url}: {result}`)
	end
	
	return if success then result else nil
end

local requestsDisabled = getgenv and getgenv().DISABLE_RAYFIELD_REQUESTS
local InterfaceBuild = '3K3W'
local Release = "Build 1.68"
local RayfieldFolder = "Rayfield"
local ConfigurationFolder = RayfieldFolder.."/Configurations"
local ConfigurationExtension = ".rfld"
local settingsTable = {
	General = {
		rayfieldOpen = {Type = 'bind', Value = 'K', Name = 'Rayfield Keybind'},
	},
	System = {
		usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
	}
}

local overriddenSettings: { [string]: any } = {}
local function overrideSetting(category: string, name: string, value: any)
	overriddenSettings[`{category}.{name}`] = value
end

local function getSetting(category: string, name: string): any
	if overriddenSettings[`{category}.{name}`] ~= nil then
		return overriddenSettings[`{category}.{name}`]
	elseif settingsTable[category] and settingsTable[category][name] then
		return settingsTable[category][name].Value
	end
end

if requestsDisabled then
	overrideSetting("System", "usageAnalytics", false)
end

local settingsCreated = false
local settingsInitialized = false
local cachedSettings
local prompt = IS_STUDIO and require(script.Parent.prompt) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua')
local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request

if not prompt and not IS_STUDIO then
	warn("Failed to load prompt library, using fallback")
	prompt = { create = function() end }
end

local function loadSettings()
	local fileContent = nil
	local success = pcall(function()
		task.spawn(function()
			if isfolder and isfolder(RayfieldFolder) and isfile and isfile(RayfieldFolder..'/settings'..ConfigurationExtension) then
				fileContent = readfile(RayfieldFolder..'/settings'..ConfigurationExtension)
			end

			local decodedFile = {}
			if fileContent then
				local decodeSuccess, result = pcall(HttpService.JSONDecode, HttpService, fileContent)
				if decodeSuccess then
					decodedFile = result
				end
			end

			if not settingsCreated then 
				cachedSettings = decodedFile
				return
			end

			if decodedFile then
				for categoryName, settingCategory in pairs(settingsTable) do
					if decodedFile[categoryName] then
						for settingName, setting in pairs(settingCategory) do
							if decodedFile[categoryName][settingName] then
								setting.Value = decodedFile[categoryName][settingName].Value
								if setting.Element and setting.Element.Set then
									setting.Element:Set(getSetting(categoryName, settingName))
								end
							end
						end
					end
				end
			end
			settingsInitialized = true
		end)
	end)

	if not success and writefile then
		warn('Rayfield had an issue accessing configuration saving capability.')
	end
end

loadSettings()

local RayfieldLibrary = {
	Flags = {},
	Theme = {}
}

local analyticsLib
local sendReport = function() end
if not requestsDisabled then
	analyticsLib = loadWithTimeout("https://analytics.sirius.menu/script")
	if analyticsLib and type(analyticsLib.load) == "function" then
		analyticsLib:load()
	else
		analyticsLib = nil
	end
	
	sendReport = function(eventName, scriptName)
		if not (type(analyticsLib) == "table" and type(analyticsLib.isLoaded) == "function" and analyticsLib:isLoaded()) then
			return
		end
		
		if not IS_STUDIO then
			analyticsLib:report(
				{
					["name"] = eventName,
					["script"] = {["name"] = scriptName, ["version"] = Release}
				},
				{
					["version"] = InterfaceBuild
				}
			)
		end
	end
	
	if cachedSettings and (next(cachedSettings) == nil or (cachedSettings.System and cachedSettings.System.usageAnalytics and cachedSettings.System.usageAnalytics.Value)) then
		sendReport("execution", "Rayfield")
	elseif not cachedSettings then
		sendReport("execution", "Rayfield")
	end
end

if prompt and type(prompt.create) == "function" and false then
	prompt.create('Be cautious when running scripts', [[Please be careful when running scripts from unknown developers. This script has already been ran.<font transparency='0.3'>Some scripts may steal your items or in-game goods.</font>]],'Okay','',function() end)
end

RayfieldLibrary.Theme = {
	Default = { TextColor = Color3.fromRGB(240, 240, 240), Background = Color3.fromRGB(25, 25, 25), Topbar = Color3.fromRGB(34, 34, 34), Shadow = Color3.fromRGB(20, 20, 20), NotificationBackground = Color3.fromRGB(20, 20, 20), NotificationActionsBackground = Color3.fromRGB(230, 230, 230), TabBackground = Color3.fromRGB(80, 80, 80), TabStroke = Color3.fromRGB(85, 85, 85), TabBackgroundSelected = Color3.fromRGB(210, 210, 210), TabTextColor = Color3.fromRGB(240, 240, 240), SelectedTabTextColor = Color3.fromRGB(50, 50, 50), ElementBackground = Color3.fromRGB(35, 35, 35), ElementBackgroundHover = Color3.fromRGB(40, 40, 40), SecondaryElementBackground = Color3.fromRGB(25, 25, 25), ElementStroke = Color3.fromRGB(50, 50, 50), SecondaryElementStroke = Color3.fromRGB(40, 40, 40), SliderBackground = Color3.fromRGB(50, 138, 220), SliderProgress = Color3.fromRGB(50, 138, 220), SliderStroke = Color3.fromRGB(58, 163, 255), ToggleBackground = Color3.fromRGB(30, 30, 30), ToggleEnabled = Color3.fromRGB(0, 146, 214), ToggleDisabled = Color3.fromRGB(100, 100, 100), ToggleEnabledStroke = Color3.fromRGB(0, 170, 255), ToggleDisabledStroke = Color3.fromRGB(125, 125, 125), ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100), ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65), DropdownSelected = Color3.fromRGB(40, 40, 40), DropdownUnselected = Color3.fromRGB(30, 30, 30), InputBackground = Color3.fromRGB(30, 30, 30), InputStroke = Color3.fromRGB(65, 65, 65), PlaceholderColor = Color3.fromRGB(178, 178, 178) },
	Ocean = { TextColor = Color3.fromRGB(230, 240, 240), Background = Color3.fromRGB(20, 30, 30), Topbar = Color3.fromRGB(25, 40, 40), Shadow = Color3.fromRGB(15, 20, 20), NotificationBackground = Color3.fromRGB(25, 35, 35), NotificationActionsBackground = Color3.fromRGB(230, 240, 240), TabBackground = Color3.fromRGB(40, 60, 60), TabStroke = Color3.fromRGB(50, 70, 70), TabBackgroundSelected = Color3.fromRGB(100, 180, 180), TabTextColor = Color3.fromRGB(210, 230, 230), SelectedTabTextColor = Color3.fromRGB(20, 50, 50), ElementBackground = Color3.fromRGB(30, 50, 50), ElementBackgroundHover = Color3.fromRGB(40, 60, 60), SecondaryElementBackground = Color3.fromRGB(30, 45, 45), ElementStroke = Color3.fromRGB(45, 70, 70), SecondaryElementStroke = Color3.fromRGB(40, 65, 65), SliderBackground = Color3.fromRGB(0, 110, 110), SliderProgress = Color3.fromRGB(0, 140, 140), SliderStroke = Color3.fromRGB(0, 160, 160), ToggleBackground = Color3.fromRGB(30, 50, 50), ToggleEnabled = Color3.fromRGB(0, 130, 130), ToggleDisabled = Color3.fromRGB(70, 90, 90), ToggleEnabledStroke = Color3.fromRGB(0, 160, 160), ToggleDisabledStroke = Color3.fromRGB(85, 105, 105), ToggleEnabledOuterStroke = Color3.fromRGB(50, 100, 100), ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 65), DropdownSelected = Color3.fromRGB(30, 60, 60), DropdownUnselected = Color3.fromRGB(25, 40, 40), InputBackground = Color3.fromRGB(30, 50, 50), InputStroke = Color3.fromRGB(50, 70, 70), PlaceholderColor = Color3.fromRGB(140, 160, 160) },
	AmberGlow = { TextColor = Color3.fromRGB(255, 245, 230), Background = Color3.fromRGB(45, 30, 20), Topbar = Color3.fromRGB(55, 40, 25), Shadow = Color3.fromRGB(35, 25, 15), NotificationBackground = Color3.fromRGB(50, 35, 25), NotificationActionsBackground = Color3.fromRGB(245, 230, 215), TabBackground = Color3.fromRGB(75, 50, 35), TabStroke = Color3.fromRGB(90, 60, 45), TabBackgroundSelected = Color3.fromRGB(230, 180, 100), TabTextColor = Color3.fromRGB(250, 220, 200), SelectedTabTextColor = Color3.fromRGB(50, 30, 10), ElementBackground = Color3.fromRGB(60, 45, 35), ElementBackgroundHover = Color3.fromRGB(70, 50, 40), SecondaryElementBackground = Color3.fromRGB(55, 40, 30), ElementStroke = Color3.fromRGB(85, 60, 45), SecondaryElementStroke = Color3.fromRGB(75, 50, 35), SliderBackground = Color3.fromRGB(220, 130, 60), SliderProgress = Color3.fromRGB(250, 150, 75), SliderStroke = Color3.fromRGB(255, 170, 85), ToggleBackground = Color3.fromRGB(55, 40, 30), ToggleEnabled = Color3.fromRGB(240, 130, 30), ToggleDisabled = Color3.fromRGB(90, 70, 60), ToggleEnabledStroke = Color3.fromRGB(255, 160, 50), ToggleDisabledStroke = Color3.fromRGB(110, 85, 75), ToggleEnabledOuterStroke = Color3.fromRGB(200, 100, 50), ToggleDisabledOuterStroke = Color3.fromRGB(75, 60, 55), DropdownSelected = Color3.fromRGB(70, 50, 40), DropdownUnselected = Color3.fromRGB(55, 40, 30), InputBackground = Color3.fromRGB(60, 45, 35), InputStroke = Color3.fromRGB(90, 65, 50), PlaceholderColor = Color3.fromRGB(190, 150, 130) },
	Light = { TextColor = Color3.fromRGB(40, 40, 40), Background = Color3.fromRGB(245, 245, 245), Topbar = Color3.fromRGB(230, 230, 230), Shadow = Color3.fromRGB(200, 200, 200), NotificationBackground = Color3.fromRGB(250, 250, 250), NotificationActionsBackground = Color3.fromRGB(240, 240, 240), TabBackground = Color3.fromRGB(235, 235, 235), TabStroke = Color3.fromRGB(215, 215, 215), TabBackgroundSelected = Color3.fromRGB(255, 255, 255), TabTextColor = Color3.fromRGB(80, 80, 80), SelectedTabTextColor = Color3.fromRGB(0, 0, 0), ElementBackground = Color3.fromRGB(240, 240, 240), ElementBackgroundHover = Color3.fromRGB(225, 225, 225), SecondaryElementBackground = Color3.fromRGB(235, 235, 235), ElementStroke = Color3.fromRGB(210, 210, 210), SecondaryElementStroke = Color3.fromRGB(210, 210, 210), SliderBackground = Color3.fromRGB(150, 180, 220), SliderProgress = Color3.fromRGB(100, 150, 200), SliderStroke = Color3.fromRGB(120, 170, 220), ToggleBackground = Color3.fromRGB(220, 220, 220), ToggleEnabled = Color3.fromRGB(0, 146, 214), ToggleDisabled = Color3.fromRGB(150, 150, 150), ToggleEnabledStroke = Color3.fromRGB(0, 170, 255), ToggleDisabledStroke = Color3.fromRGB(170, 170, 170), ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100), ToggleDisabledOuterStroke = Color3.fromRGB(180, 180, 180), DropdownSelected = Color3.fromRGB(230, 230, 230), DropdownUnselected = Color3.fromRGB(220, 220, 220), InputBackground = Color3.fromRGB(240, 240, 240), InputStroke = Color3.fromRGB(180, 180, 180), PlaceholderColor = Color3.fromRGB(140, 140, 140) },
	Amethyst = { TextColor = Color3.fromRGB(240, 240, 240), Background = Color3.fromRGB(30, 20, 40), Topbar = Color3.fromRGB(40, 25, 50), Shadow = Color3.fromRGB(20, 15, 30), NotificationBackground = Color3.fromRGB(35, 20, 40), NotificationActionsBackground = Color3.fromRGB(240, 240, 250), TabBackground = Color3.fromRGB(60, 40, 80), TabStroke = Color3.fromRGB(70, 45, 90), TabBackgroundSelected = Color3.fromRGB(180, 140, 200), TabTextColor = Color3.fromRGB(230, 230, 240), SelectedTabTextColor = Color3.fromRGB(50, 20, 50), ElementBackground = Color3.fromRGB(45, 30, 60), ElementBackgroundHover = Color3.fromRGB(50, 35, 70), SecondaryElementBackground = Color3.fromRGB(40, 30, 55), ElementStroke = Color3.fromRGB(70, 50, 85), SecondaryElementStroke = Color3.fromRGB(65, 45, 80), SliderBackground = Color3.fromRGB(100, 60, 150), SliderProgress = Color3.fromRGB(130, 80, 180), SliderStroke = Color3.fromRGB(150, 100, 200), ToggleBackground = Color3.fromRGB(45, 30, 55), ToggleEnabled = Color3.fromRGB(120, 60, 150), ToggleDisabled = Color3.fromRGB(94, 47, 117), ToggleEnabledStroke = Color3.fromRGB(140, 80, 170), ToggleDisabledStroke = Color3.fromRGB(124, 71, 150), ToggleEnabledOuterStroke = Color3.fromRGB(90, 40, 120), ToggleDisabledOuterStroke = Color3.fromRGB(80, 50, 110), DropdownSelected = Color3.fromRGB(50, 35, 70), DropdownUnselected = Color3.fromRGB(35, 25, 50), InputBackground = Color3.fromRGB(45, 30, 60), InputStroke = Color3.fromRGB(80, 50, 110), PlaceholderColor = Color3.fromRGB(178, 150, 200) },
	Green = { TextColor = Color3.fromRGB(30, 60, 30), Background = Color3.fromRGB(235, 245, 235), Topbar = Color3.fromRGB(210, 230, 210), Shadow = Color3.fromRGB(200, 220, 200), NotificationBackground = Color3.fromRGB(240, 250, 240), NotificationActionsBackground = Color3.fromRGB(220, 235, 220), TabBackground = Color3.fromRGB(215, 235, 215), TabStroke = Color3.fromRGB(190, 210, 190), TabBackgroundSelected = Color3.fromRGB(245, 255, 245), TabTextColor = Color3.fromRGB(50, 80, 50), SelectedTabTextColor = Color3.fromRGB(20, 60, 20), ElementBackground = Color3.fromRGB(225, 240, 225), ElementBackgroundHover = Color3.fromRGB(210, 225, 210), SecondaryElementBackground = Color3.fromRGB(235, 245, 235), ElementStroke = Color3.fromRGB(180, 200, 180), SecondaryElementStroke = Color3.fromRGB(180, 200, 180), SliderBackground = Color3.fromRGB(90, 160, 90), SliderProgress = Color3.fromRGB(70, 130, 70), SliderStroke = Color3.fromRGB(100, 180, 100), ToggleBackground = Color3.fromRGB(215, 235, 215), ToggleEnabled = Color3.fromRGB(60, 130, 60), ToggleDisabled = Color3.fromRGB(150, 175, 150), ToggleEnabledStroke = Color3.fromRGB(80, 150, 80), ToggleDisabledStroke = Color3.fromRGB(130, 150, 130), ToggleEnabledOuterStroke = Color3.fromRGB(100, 160, 100), ToggleDisabledOuterStroke = Color3.fromRGB(160, 180, 160), DropdownSelected = Color3.fromRGB(225, 240, 225), DropdownUnselected = Color3.fromRGB(210, 225, 210), InputBackground = Color3.fromRGB(235, 245, 235), InputStroke = Color3.fromRGB(180, 200, 180), PlaceholderColor = Color3.fromRGB(120, 140, 120) },
	Bloom = { TextColor = Color3.fromRGB(60, 40, 50), Background = Color3.fromRGB(255, 240, 245), Topbar = Color3.fromRGB(250, 220, 225), Shadow = Color3.fromRGB(230, 190, 195), NotificationBackground = Color3.fromRGB(255, 235, 240), NotificationActionsBackground = Color3.fromRGB(245, 215, 225), TabBackground = Color3.fromRGB(240, 210, 220), TabStroke = Color3.fromRGB(230, 200, 210), TabBackgroundSelected = Color3.fromRGB(255, 225, 235), TabTextColor = Color3.fromRGB(80, 40, 60), SelectedTabTextColor = Color3.fromRGB(50, 30, 50), ElementBackground = Color3.fromRGB(255, 235, 240), ElementBackgroundHover = Color3.fromRGB(245, 220, 230), SecondaryElementBackground = Color3.fromRGB(255, 235, 240), ElementStroke = Color3.fromRGB(230, 200, 210), SecondaryElementStroke = Color3.fromRGB(230, 200, 210), SliderBackground = Color3.fromRGB(240, 130, 160), SliderProgress = Color3.fromRGB(250, 160, 180), SliderStroke = Color3.fromRGB(255, 180, 200), ToggleBackground = Color3.fromRGB(240, 210, 220), ToggleEnabled = Color3.fromRGB(255, 140, 170), ToggleDisabled = Color3.fromRGB(200, 180, 185), ToggleEnabledStroke = Color3.fromRGB(250, 160, 190), ToggleDisabledStroke = Color3.fromRGB(210, 180, 190), ToggleEnabledOuterStroke = Color3.fromRGB(220, 160, 180), ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 180), DropdownSelected = Color3.fromRGB(250, 220, 225), DropdownUnselected = Color3.fromRGB(240, 210, 220), InputBackground = Color3.fromRGB(255, 235, 240), InputStroke = Color3.fromRGB(220, 190, 200), PlaceholderColor = Color3.fromRGB(170, 130, 140) },
	DarkBlue = { TextColor = Color3.fromRGB(230, 230, 230), Background = Color3.fromRGB(20, 25, 30), Topbar = Color3.fromRGB(30, 35, 40), Shadow = Color3.fromRGB(15, 20, 25), NotificationBackground = Color3.fromRGB(25, 30, 35), NotificationActionsBackground = Color3.fromRGB(45, 50, 55), TabBackground = Color3.fromRGB(35, 40, 45), TabStroke = Color3.fromRGB(45, 50, 60), TabBackgroundSelected = Color3.fromRGB(40, 70, 100), TabTextColor = Color3.fromRGB(200, 200, 200), SelectedTabTextColor = Color3.fromRGB(255, 255, 255), ElementBackground = Color3.fromRGB(30, 35, 40), ElementBackgroundHover = Color3.fromRGB(40, 45, 50), SecondaryElementBackground = Color3.fromRGB(35, 40, 45), ElementStroke = Color3.fromRGB(45, 50, 60), SecondaryElementStroke = Color3.fromRGB(40, 45, 55), SliderBackground = Color3.fromRGB(0, 90, 180), SliderProgress = Color3.fromRGB(0, 120, 210), SliderStroke = Color3.fromRGB(0, 150, 240), ToggleBackground = Color3.fromRGB(35, 40, 45), ToggleEnabled = Color3.fromRGB(0, 120, 210), ToggleDisabled = Color3.fromRGB(70, 70, 80), ToggleEnabledStroke = Color3.fromRGB(0, 150, 240), ToggleDisabledStroke = Color3.fromRGB(75, 75, 85), ToggleEnabledOuterStroke = Color3.fromRGB(20, 100, 180), ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 65), DropdownSelected = Color3.fromRGB(30, 70, 90), DropdownUnselected = Color3.fromRGB(25, 30, 35), InputBackground = Color3.fromRGB(25, 30, 35), InputStroke = Color3.fromRGB(45, 50, 60), PlaceholderColor = Color3.fromRGB(150, 150, 160) },
	Serenity = { TextColor = Color3.fromRGB(50, 55, 60), Background = Color3.fromRGB(240, 245, 250), Topbar = Color3.fromRGB(215, 225, 235), Shadow = Color3.fromRGB(200, 210, 220), NotificationBackground = Color3.fromRGB(210, 220, 230), NotificationActionsBackground = Color3.fromRGB(225, 230, 240), TabBackground = Color3.fromRGB(200, 210, 220), TabStroke = Color3.fromRGB(180, 190, 200), TabBackgroundSelected = Color3.fromRGB(175, 185, 200), TabTextColor = Color3.fromRGB(50, 55, 60), SelectedTabTextColor = Color3.fromRGB(30, 35, 40), ElementBackground = Color3.fromRGB(210, 220, 230), ElementBackgroundHover = Color3.fromRGB(220, 230, 240), SecondaryElementBackground = Color3.fromRGB(200, 210, 220), ElementStroke = Color3.fromRGB(190, 200, 210), SecondaryElementStroke = Color3.fromRGB(180, 190, 200), SliderBackground = Color3.fromRGB(200, 220, 235), SliderProgress = Color3.fromRGB(70, 130, 180), SliderStroke = Color3.fromRGB(150, 180, 220), ToggleBackground = Color3.fromRGB(210, 220, 230), ToggleEnabled = Color3.fromRGB(70, 160, 210), ToggleDisabled = Color3.fromRGB(180, 180, 180), ToggleEnabledStroke = Color3.fromRGB(60, 150, 200), ToggleDisabledStroke = Color3.fromRGB(140, 140, 140), ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140), ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130), DropdownSelected = Color3.fromRGB(220, 230, 240), DropdownUnselected = Color3.fromRGB(200, 210, 220), InputBackground = Color3.fromRGB(220, 230, 240), InputStroke = Color3.fromRGB(180, 190, 200), PlaceholderColor = Color3.fromRGB(150, 150, 150) },
}

local Icons = IS_STUDIO and require(script.Parent.icons) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua')

local Rayfield = IS_STUDIO and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local rayfieldDestroyed = false

repeat
	if Rayfield:FindFirstChild('Build') and Rayfield.Build.Value == InterfaceBuild then
		correctBuild = true
		break
	end

	if not warned then
		warn('Rayfield | Build Mismatch')
		print('Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.')
		warned = true
	end

	local toDestroy = Rayfield
	Rayfield = IS_STUDIO and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
	if toDestroy and not IS_STUDIO then toDestroy:Destroy() end

	buildAttempts += 1
until buildAttempts >= 2

Rayfield.Enabled = false

if gethui then
	Rayfield.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(Rayfield)
	Rayfield.Parent = CoreGui
elseif not IS_STUDIO and CoreGui:FindFirstChild("RobloxGui") then
	Rayfield.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not IS_STUDIO then
	Rayfield.Parent = CoreGui
end

local parentContainer = Rayfield.Parent or CoreGui
for _, Interface in ipairs(parentContainer:GetChildren()) do
	if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
		Interface.Enabled = false
		Interface.Name = "Rayfield-Old"
	end
end

local minSize = Vector2.new(1024, 768)
local useMobileSizing = Rayfield.AbsoluteSize.X < minSize.X and Rayfield.AbsoluteSize.Y < minSize.Y
local useMobilePrompt = UserInputService.TouchEnabled

local Main = Rayfield.Main
local MPrompt = Rayfield:FindFirstChild('Prompt')
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList
local dragBar = Rayfield:FindFirstChild('Drag')
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil

local dragOffset = 255
local dragOffsetMobile = 150

Rayfield.DisplayOrder = 100
LoadingFrame.Version.Text = Release

local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false
local Notifications = Rayfield.Notifications

local SelectedTheme = RayfieldLibrary.Theme.Default

local function ChangeTheme(Theme)
	if type(Theme) == 'string' then
		SelectedTheme = RayfieldLibrary.Theme[Theme]
	elseif type(Theme) == 'table' then
		SelectedTheme = Theme
	end

	Main.BackgroundColor3 = SelectedTheme.Background
	Main.Topbar.BackgroundColor3 = SelectedTheme.Topbar
	Main.Topbar.CornerRepair.BackgroundColor3 = SelectedTheme.Topbar
	Main.Shadow.Image.ImageColor3 = SelectedTheme.Shadow
	Main.Topbar.ChangeSize.ImageColor3 = SelectedTheme.TextColor
	Main.Topbar.Hide.ImageColor3 = SelectedTheme.TextColor
	Main.Topbar.Search.ImageColor3 = SelectedTheme.TextColor
	if Topbar:FindFirstChild('Settings') then
		Main.Topbar.Settings.ImageColor3 = SelectedTheme.TextColor
		Main.Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
	end
	Main.Search.BackgroundColor3 = SelectedTheme.TextColor
	Main.Search.Shadow.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Search.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Input.PlaceholderColor3 = SelectedTheme.TextColor
	Main.Search.UIStroke.Color = SelectedTheme.SecondaryElementStroke
	if Main:FindFirstChild('Notice') then
		Main.Notice.BackgroundColor3 = SelectedTheme.Background
	end

	for _, text in ipairs(Rayfield:GetDescendants()) do
		if text.Parent.Parent ~= Notifications and (text:IsA('TextLabel') or text:IsA('TextBox')) then
			text.TextColor3 = SelectedTheme.TextColor
		end
	end

	for _, TabPage in ipairs(Elements:GetChildren()) do
		for _, Element in ipairs(TabPage:GetChildren()) do
			if Element:IsA("Frame") and Element.Name ~= "Placeholder" and Element.Name ~= "SectionSpacing" and Element.Name ~= "Divider" and Element.Name ~= "SectionTitle" and not string.match(Element.Name, "SearchTitle") then
				Element.BackgroundColor3 = SelectedTheme.ElementBackground
				Element.UIStroke.Color = SelectedTheme.ElementStroke
			end
		end
	end
end

local function getIconAsset(name: string)
	if not Icons then
		warn("Lucide Icons: Cannot use icons as icons library is not loaded")
		return
	end
	name = string.match(string.lower(name), "^%s*(.*)%s*$") :: string
	local sizedicons = Icons['48px']
	local r = sizedicons[name]
	if not r then
		error(`Lucide Icons: Failed to find icon by the name of "{name}"`, 2)
	end
	return { id = r[1], imageRectSize = Vector2.new(r[2][1], r[2][2]), imageRectOffset = Vector2.new(r[3][1], r[3][2]) }
end

local function applyIcon(imageObject: ImageLabel | ImageButton, iconIdentifier: any)
	if type(iconIdentifier) == "string" and Icons then
		local asset = getIconAsset(iconIdentifier)
		if asset then
			imageObject.Image = `rbxassetid://{asset.id}`
			imageObject.ImageRectOffset = asset.imageRectOffset
			imageObject.ImageRectSize = asset.imageRectSize
		end
	elseif type(iconIdentifier) == "number" then
		imageObject.Image = `rbxassetid://{iconIdentifier}`
	else
		warn("Rayfield: The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
		imageObject.Image = ""
	end
end

local function makeDraggable(object, dragObject, enableTaptic, tapticOffset)
	local dragging = false
	local relative = nil
	local offset = Vector2.zero
	local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset then
		offset += getService('GuiService'):GetGuiInset()
	end

	local function connectFunctions()
		if dragBar and enableTaptic then
			dragBar.MouseEnter:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4)}):Play()
				end
			end)
			dragBar.MouseLeave:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4)}):Play()
				end
			end)
		end
	end
	connectFunctions()

	dragObject.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - UserInputService:GetMouseLocation()
			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0}):Play()
			end
		end
	end)

	local inputEnded = UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			connectFunctions()
			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7}):Play()
			end
		end
	end)

	local renderStepped = RunService.RenderStepped:Connect(function()
		if dragging and not Hidden then
			local position = UserInputService:GetMouseLocation() + relative + offset
			if enableTaptic and tapticOffset then
				TweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y)}):Play()
				TweenService:Create(dragObject.Parent, TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))}):Play()
			else
				if dragBar and tapticOffset then
					dragBar.Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))
				end
				object.Position = UDim2.fromOffset(position.X, position.Y)
			end
		end
	end)

	object.Destroying:Connect(function()
		if inputEnded then inputEnded:Disconnect() end
		if renderStepped then renderStepped:Disconnect() end
	end)
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadConfiguration(Configuration)
	local success, Data = pcall(HttpService.JSONDecode, HttpService, Configuration)
	if not success then
		warn('Rayfield had an issue decoding the configuration file.')
		return
	end

	local changed = false
	for FlagName, Flag in pairs(RayfieldLibrary.Flags) do
		local FlagValue = Data[FlagName]
		if FlagValue ~= nil then
			local currentValue = Flag.CurrentValue or Flag.CurrentKeybind or Flag.CurrentOption or Flag.Color
			local valueToSet = FlagValue
			
			if Flag.Type == "ColorPicker" then
				valueToSet = UnpackColor(FlagValue)
			end
			
			if currentValue ~= valueToSet then
				changed = true
				if Flag.Set then
					task.spawn(Flag.Set, Flag, valueToSet)
				end
			end
		end
	end
	return changed
end

local function SaveConfiguration()
	if not CEnabled or not globalLoaded or not writefile then return end

	local Data = {}
	for i, v in pairs(RayfieldLibrary.Flags) do
		if v.Type == "ColorPicker" then
			Data[i] = PackColor(v.Color)
		else
			Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
		end
	end

	pcall(writefile, ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension, HttpService:JSONEncode(Data))
end

function RayfieldLibrary:Notify(data)
	task.spawn(function()
		local newNotification = Notifications.Template:Clone()
		newNotification.Name = data.Title or 'No Title Provided'
		newNotification.Parent = Notifications
		newNotification.LayoutOrder = #Notifications:GetChildren()
		newNotification.Visible = false

		newNotification.Title.Text = data.Title or "Unknown Title"
		newNotification.Description.Text = data.Content or "Unknown Content"

		if data.Image then
			applyIcon(newNotification.Icon, data.Image)
		end

		newNotification.Title.TextColor3 = SelectedTheme.TextColor
		newNotification.Description.TextColor3 = SelectedTheme.TextColor
		newNotification.BackgroundColor3 = SelectedTheme.NotificationBackground
		newNotification.UIStroke.Color = SelectedTheme.TextColor
		newNotification.Icon.ImageColor3 = SelectedTheme.TextColor

		newNotification.BackgroundTransparency = 1
		newNotification.Title.TextTransparency = 1
		newNotification.Description.TextTransparency = 1
		newNotification.UIStroke.Transparency = 1
		newNotification.Shadow.ImageTransparency = 1
		newNotification.Icon.ImageTransparency = 1

		task.wait()
		newNotification.Visible = true

		local bounds = {newNotification.Title.TextBounds.Y, newNotification.Description.TextBounds.Y}
		local targetHeight = math.max(bounds[1] + bounds[2] + 31, 60)
		
		TweenService:Create(newNotification, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
		task.wait(0.15)
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.45}):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
		task.wait(0.05)
		TweenService:Create(newNotification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
		task.wait(0.05)
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.35}):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.95}):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.82}):Play()

		local waitDuration = data.Duration or math.clamp((#newNotification.Description.Text * 0.1) + 2.5, 3, 10)
		task.wait(waitDuration)

		if not newNotification.Parent then return end

		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
		TweenService:Create(newNotification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()

		TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, 0)}):Play()
		task.wait(1)
		newNotification:Destroy()
	end)
end

local function openSearch()
	if searchOpen then return end
	searchOpen = true
	Main.Search.Visible = true
	Main.Search.Input.Interactable = true

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn:IsA("Frame") and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = false
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1}):Play()
		end
	end

	Main.Search.Input:CaptureFocus()
	TweenService:Create(Main.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, 57), BackgroundTransparency = 0.9, Size = UDim2.new(1, -35, 0, 35)}):Play()
	TweenService:Create(Main.Search.Input, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
	TweenService:Create(Main.Search.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()
end

local function closeSearch()
	if not searchOpen then return end
	searchOpen = false

	local animInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)
	TweenService:Create(Main.Search, animInfo, {BackgroundTransparency = 1, Size = UDim2.new(1, -55, 0, 30)}):Play()
	TweenService:Create(Main.Search.Search, animInfo, {ImageTransparency = 1}):Play()
	TweenService:Create(Main.Search.Input, animInfo, {TextTransparency = 1}):Play()

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn:IsA("Frame") and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = true
			local isSelected = tostring(Elements.UIPageLayout.CurrentPage.Name) == tabbtn.Name
			TweenService:Create(tabbtn, animInfo, {BackgroundTransparency = isSelected and 0 or 0.7}):Play()
			TweenService:Create(tabbtn.Image, animInfo, {ImageTransparency = isSelected and 0 or 0.2}):Play()
			TweenService:Create(tabbtn.Title, animInfo, {TextTransparency = isSelected and 0 or 0.2}):Play()
		end
	end

	Main.Search.Input.Text = ''
	Main.Search.Input.Interactable = false
	task.delay(animInfo.Time, function() if not searchOpen then Main.Search.Visible = false end end)
end

local function Hide(notify: boolean?)
	if Debounce or Hidden then return end
	Debounce = true
	Hidden = true
	if searchOpen then closeSearch() end
	
	if notify then
		local keybind = getSetting("General", "rayfieldOpen")
		local content = useMobilePrompt 
			and "The interface is hidden. Tap 'Show' to unhide." 
			or `The interface is hidden. Press {keybind} to unhide.`
		RayfieldLibrary:Notify({Title = "Interface Hidden", Content = content, Duration = 7, Image = "eye-off"})
	end

	local animInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential)
	
	TweenService:Create(Main, animInfo, {Size = UDim2.new(0, 470, 0, 0), BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar, animInfo, {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar.Title, animInfo, {TextTransparency = 1}):Play()
	TweenService:Create(Main.Shadow.Image, animInfo, {ImageTransparency = 1}):Play()
	if dragBarCosmetic then TweenService:Create(dragBarCosmetic, animInfo, {BackgroundTransparency = 1}):Play() end

	if useMobilePrompt and MPrompt then
		MPrompt.Visible = true
		TweenService:Create(MPrompt, animInfo, {Size = UDim2.new(0, 120, 0, 30), Position = UDim2.new(0.5, 0, 0, 20), BackgroundTransparency = 0.3}):Play()
		TweenService:Create(MPrompt.Title, animInfo, {TextTransparency = 0.3}):Play()
	end

	for _, child in ipairs(Topbar:GetChildren()) do if child:IsA("ImageButton") then TweenService:Create(child, animInfo, {ImageTransparency = 1}):Play() end end
	for _, child in ipairs(TabList:GetChildren()) do if child:IsA("Frame") and child.Name ~= "Template" then TweenService:Create(child, animInfo, {BackgroundTransparency = 1}):Play() end end
	if dragInteract then dragInteract.Visible = false end

	for _, page in ipairs(Elements:GetChildren()) do
		if page:IsA("ScrollingFrame") then
			for _, element in ipairs(page:GetChildren()) do
				element.Visible = false
			end
		end
	end

	task.delay(animInfo.Time, function()
		if Hidden then Main.Visible = false end
		Debounce = false
	end)
end

local function Unhide()
	if Debounce or not Hidden then return end
	Debounce = true
	Hidden = false

	Main.Visible = true
	local animInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
	local finalSize = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)

	TweenService:Create(Main, animInfo, {Size = finalSize, BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar, animInfo, {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Shadow.Image, animInfo, {ImageTransparency = 0.6}):Play()
	TweenService:Create(Main.Topbar.Title, animInfo, {TextTransparency = 0}):Play()
	if dragBarCosmetic then TweenService:Create(dragBarCosmetic, animInfo, {BackgroundTransparency = 0.7}):Play() end

	if MPrompt then
		TweenService:Create(MPrompt, animInfo, {Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 1}):Play()
		TweenService:Create(MPrompt.Title, animInfo, {TextTransparency = 1}):Play()
		task.delay(animInfo.Time, function() if MPrompt then MPrompt.Visible = false end end)
	end
	
	if dragInteract then dragInteract.Visible = true end

	for _, child in ipairs(Topbar:GetChildren()) do if child:IsA("ImageButton") then TweenService:Create(child, animInfo, {ImageTransparency = child.Name == 'Icon' and 0 or 0.8}):Play() end end
	for _, page in ipairs(Elements:GetChildren()) do if page:IsA("ScrollingFrame") then for _, element in ipairs(page:GetChildren()) do element.Visible = true end end end

	task.delay(0.2, function()
		if not Hidden then
			for _, tabButton in ipairs(TabList:GetChildren()) do
				if tabButton:IsA("Frame") and tabButton.Name ~= "Template" then
					local isSelected = tostring(Elements.UIPageLayout.CurrentPage.Name) == tabButton.Name
					TweenService:Create(tabButton, animInfo, {BackgroundTransparency = isSelected and 0 or 0.7}):Play()
					TweenService:Create(tabButton.Title, animInfo, {TextTransparency = isSelected and 0 or 0.2}):Play()
					TweenService:Create(tabButton.Image, animInfo, {ImageTransparency = isSelected and 0 or 0.2}):Play()
				end
			end
		end
	end)

	if Minimised then
		Minimised = false
		Topbar.ChangeSize.Image = "rbxassetid://"..10137941941
	end

	task.delay(animInfo.Time, function() Debounce = false end)
end

local function Maximise()
	if Debounce or not Minimised then return end
	Debounce = true
	Minimised = false
	Topbar.ChangeSize.Image = "rbxassetid://"..10137941941
	
	local animInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
	local finalSize = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)

	TweenService:Create(Main, animInfo, {Size = finalSize}):Play()
	TweenService:Create(Main.Shadow.Image, animInfo, {ImageTransparency = 0.6}):Play()

	Elements.Visible = true
	TabList.Visible = true

	task.delay(animInfo.Time, function() Debounce = false end)
end

local function Minimise()
	if Debounce or Minimised then return end
	Debounce = true
	Minimised = true
	if searchOpen then closeSearch() end
	Topbar.ChangeSize.Image = "rbxassetid://"..11036884234

	local animInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
	TweenService:Create(Main, animInfo, {Size = UDim2.new(0, 495, 0, 45)}):Play()
	TweenService:Create(Main.Shadow.Image, animInfo, {ImageTransparency = 1}):Play()
	
	task.delay(0.2, function()
		Elements.Visible = false
		TabList.Visible = false
	end)

	task.delay(animInfo.Time, function() Debounce = false end)
end

local function saveSettings()
	if not settingsInitialized then return end
	local success, encoded = pcall(HttpService.JSONEncode, HttpService, settingsTable)
	if success and writefile then
		writefile(RayfieldFolder..'/settings'..ConfigurationExtension, encoded)
	end
end

local function updateSetting(category: string, setting: string, value: any)
	if not settingsInitialized then return end
	settingsTable[category][setting].Value = value
	overriddenSettings[`{category}.{setting}`] = nil
	saveSettings()
end

local function createSettings(window)
	if not (writefile and isfile and readfile and isfolder and makefolder) and not IS_STUDIO then
		if Topbar['Settings'] then Topbar.Settings.Visible = false end
		Topbar['Search'].Position = UDim2.new(1, -75, 0.5, 0)
		return
	end

	local newTab = window:CreateTab('Rayfield Settings', "settings", true)
	if TabList['Rayfield Settings'] then TabList['Rayfield Settings'].LayoutOrder = 1000 end
	if Elements['Rayfield Settings'] then Elements['Rayfield Settings'].LayoutOrder = 1000 end

	for categoryName, settingCategory in pairs(settingsTable) do
		newTab:CreateSection(categoryName)
		for settingName, setting in pairs(settingCategory) do
			if setting.Type == 'toggle' then
				setting.Element = newTab:CreateToggle({
					Name = setting.Name, CurrentValue = setting.Value, Ext = true,
					Callback = function(Value) updateSetting(categoryName, settingName, Value) end,
				})
			elseif setting.Type == 'bind' then
				setting.Element = newTab:CreateKeybind({
					Name = setting.Name, CurrentKeybind = setting.Value, Ext = true, CallOnChange = true,
					Callback = function(Value) updateSetting(categoryName, settingName, Value) end,
				})
			end
		end
	end

	settingsCreated = true
	loadSettings()
	saveSettings()
end

function RayfieldLibrary:CreateWindow(Settings)
	if getgenv then getgenv().rayfieldCached = true end

	if not correctBuild and not Settings.DisableBuildWarnings then
		task.delay(3, function() 
			RayfieldLibrary:Notify({
				Title = 'Build Mismatch', Content = `UI build mismatch detected. Expected '{InterfaceBuild}', got '{(Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or "Unknown"}'. Issues may occur.`, Image = "alert-triangle", Duration = 15
			})		
		end)
	end

	if Settings.ToggleUIKeybind then
		local keybind = Settings.ToggleUIKeybind
		if type(keybind) == "string" then
			overrideSetting("General", "rayfieldOpen", string.upper(keybind))
		elseif typeof(keybind) == "EnumItem" and keybind.EnumType == Enum.KeyCode then
			overrideSetting("General", "rayfieldOpen", keybind.Name)
		else
			error("ToggleUIKeybind must be a string or KeyCode enum")
		end
	end

	if isfolder and not isfolder(RayfieldFolder) then makefolder(RayfieldFolder) end
	sendReport("window_created", Settings.Name or "Unknown")

	local Passthrough = false
	Topbar.Title.Text = Settings.Name
	Main.Visible = true
	LoadingFrame.Title.Text = Settings.LoadingTitle or "Rayfield"
	LoadingFrame.Subtitle.Text = Settings.LoadingSubtitle or "Interface Suite"
	if Settings.ShowText then MPrompt.Title.Text = 'Show '..Settings.ShowText end
	if Settings.LoadingTitle ~= "Rayfield Interface Suite" then LoadingFrame.Version.Text = "Rayfield UI" end

	if Settings.Icon and Settings.Icon ~= 0 and Topbar:FindFirstChild('Icon') then
		Topbar.Icon.Visible = true
		Topbar.Title.Position = UDim2.new(0, 47, 0.5, 0)
		applyIcon(Topbar.Icon, Settings.Icon)
	end
	
	if dragBar then dragBar.Visible = true end
	ChangeTheme(Settings.Theme or "Default")

	Topbar.Visible = false
	Elements.Visible = false
	LoadingFrame.Visible = true

	if not Settings.DisableRayfieldPrompts then
		task.spawn(function()
			while not rayfieldDestroyed do
				task.wait(math.random(180, 600))
				if not rayfieldDestroyed then
					RayfieldLibrary:Notify({Title = "Rayfield Interface", Content = "Enjoying this UI library? Find it at sirius.menu/discord", Duration = 7, Image = "star"})
				end
			end
		end)
	end
	
	pcall(function()
		CFileName = Settings.ConfigurationSaving.FileName or tostring(game.PlaceId)
		CEnabled = Settings.ConfigurationSaving.Enabled
		if CEnabled then
			ConfigurationFolder = Settings.ConfigurationSaving.FolderName or ConfigurationFolder
			if not isfolder(ConfigurationFolder) then makefolder(ConfigurationFolder) end	
		end
	end)

	makeDraggable(Main, Topbar, false, {dragOffset, dragOffsetMobile})
	if dragBar then
		dragBar.Position = useMobileSizing and UDim2.new(0.5, 0, 0.5, dragOffsetMobile) or UDim2.new(0.5, 0, 0.5, dragOffset)
		makeDraggable(Main, dragInteract, true, {dragOffset, dragOffsetMobile})
	end

	if Settings.Discord and Settings.Discord.Enabled and not IS_STUDIO then
		if isfolder and not isfolder(RayfieldFolder.."/Discord Invites") then makefolder(RayfieldFolder.."/Discord Invites") end
		if isfile and not isfile(RayfieldFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension) then
			if requestFunc then
				pcall(requestFunc, { Url = 'http://127.0.0.1:6463/rpc?v=1', Method = 'POST', Headers = {['Content-Type'] = 'application/json', Origin = 'https://discord.com'}, Body = HttpService:JSONEncode({ cmd = 'INVITE_BROWSER', nonce = HttpService:GenerateGUID(false), args = {code = Settings.Discord.Invite} }) })
			end
			if Settings.Discord.RememberJoins then
				writefile(RayfieldFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension,"")
			end
		end
	end

	if Settings.KeySystem then
		if not Settings.KeySettings then Passthrough = true else
			if isfolder and not isfolder(RayfieldFolder.."/Key System") then makefolder(RayfieldFolder.."/Key System") end
			if type(Settings.KeySettings.Key) == "string" then Settings.KeySettings.Key = {Settings.KeySettings.Key} end

			if Settings.KeySettings.GrabKeyFromSite then
				for i, Key in ipairs(Settings.KeySettings.Key) do
					local Success, Response = pcall(function()
						Settings.KeySettings.Key[i] = string.gsub(tostring(game:HttpGet(Key):gsub("[\n\r]", " ")), " ", "")
					end)
				end
			end

			local keyFileName = Settings.KeySettings.FileName or "DefaultKey"
			if isfile and isfile(RayfieldFolder.."/Key System".."/"..keyFileName..ConfigurationExtension) then
				local savedKey = readfile(RayfieldFolder.."/Key System".."/"..keyFileName..ConfigurationExtension)
				for _, MKey in ipairs(Settings.KeySettings.Key) do
					if savedKey == MKey then Passthrough = true break end
				end
			end

			if not Passthrough then
				local AttemptsRemaining = math.random(2, 5)
				local KeyUI = IS_STUDIO and script.Parent:FindFirstChild('Key') or game:GetObjects("rbxassetid://11380036235")[1]
				KeyUI.Enabled = true
				if gethui then KeyUI.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(KeyUI); KeyUI.Parent = CoreGui else KeyUI.Parent = CoreGui end
				local KeyMain = KeyUI.Main
				KeyMain.Title.Text = Settings.KeySettings.Title or Settings.Name
				KeyMain.Subtitle.Text = Settings.KeySettings.Subtitle or "Key System"
				KeyMain.NoteMessage.Text = Settings.KeySettings.Note or "No instructions"

				local animInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)
				TweenService:Create(KeyMain, animInfo, {BackgroundTransparency = 0, Size = UDim2.new(0, 500, 0, 187)}):Play()
				for _, child in ipairs(KeyMain:GetDescendants()) do if child:IsA("GuiObject") and ("TextTransparency" in child or "ImageTransparency" in child) then task.wait(0.05); TweenService:Create(child, animInfo, {[child:IsA("TextLabel") and "TextTransparency" or "ImageTransparency"] = 0}):Play() end end

				KeyUI.Main.Input.InputBox.FocusLost:Connect(function()
					local KeyFound = false
					local FoundKey = ''
					for _, MKey in ipairs(Settings.KeySettings.Key) do
						if KeyMain.Input.InputBox.Text == MKey then
							KeyFound = true
							FoundKey = MKey
							break
						end
					end
					
					if KeyFound then
						TweenService:Create(KeyMain, animInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 467, 0, 175)}):Play()
						task.wait(animInfo.Time)
						Passthrough = true
						KeyUI:Destroy()
						if Settings.KeySettings.SaveKey and writefile then
							writefile(RayfieldFolder.."/Key System".."/"..keyFileName..ConfigurationExtension, FoundKey)
							RayfieldLibrary:Notify({Title = "Key System", Content = "The key has been saved.", Image = "key"})
						end
					else
						AttemptsRemaining -= 1
						if AttemptsRemaining <= 0 then
							Players.LocalPlayer:Kick("No attempts remaining.")
						else
							KeyMain.Input.InputBox.Text = ""
							local tween = TweenService:Create(KeyMain, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Position = UDim2.new(0.49, 0, 0.5, 0)})
							tween:Play()
							tween.Completed:Wait()
							tween = TweenService:Create(KeyMain, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Position = UDim2.new(0.51, 0, 0.5, 0)})
							tween:Play()
							tween.Completed:Wait()
							TweenService:Create(KeyMain, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
						end
					end
				end)
				KeyMain.Hide.MouseButton1Click:Connect(function() RayfieldLibrary:Destroy(); KeyUI:Destroy() end)
			else
				Passthrough = true
			end
		end
	end

	if Settings.KeySystem then repeat task.wait() until Passthrough end

	Notifications.Visible = true
	Rayfield.Enabled = true

	task.wait(0.5)
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
	task.wait(0.1)
	TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.05)
	TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.05)
	TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

	Elements.Template.Visible = false
	TabList.Template.Visible = false

	local FirstTab = true
	local Window = {}
	function Window:CreateTab(Name, Image, Ext)
		local isSectionCreated = false
		local TabButton = TabList.Template:Clone()
		TabButton.Name = Name
		TabButton.Title.Text = Name
		TabButton.Parent = TabList
		TabButton.Visible = not Ext or false

		if Image then
			applyIcon(TabButton.Image, Image)
			TabButton.Image.Visible = true
			TabButton.Title.Position = UDim2.new(0, 37, 0.5, 0)
			TabButton.Title.TextXAlignment = Enum.TextXAlignment.Left
			TabButton.Size = UDim2.new(0, TabButton.Title.TextBounds.X + 52, 0, 30)
		else
			TabButton.Size = UDim2.new(0, TabButton.Title.TextBounds.X + 30, 0, 30)
		end

		local TabPage = Elements.Template:Clone()
		TabPage.Name = Name
		TabPage.Visible = true
		TabPage.Parent = Elements
		TabPage.LayoutOrder = #Elements:GetChildren()

		if FirstTab and not Ext then
			Elements.UIPageLayout.Animated = false
			Elements.UIPageLayout:JumpTo(TabPage)
			Elements.UIPageLayout.Animated = true
			FirstTab = false
		end

		TabButton.UIStroke.Color = SelectedTheme.TabStroke

		local function updateTabVisuals()
			local isSelected = Elements.UIPageLayout.CurrentPage == TabPage
			TabButton.BackgroundColor3 = isSelected and SelectedTheme.TabBackgroundSelected or SelectedTheme.TabBackground
			TabButton.Image.ImageColor3 = isSelected and SelectedTheme.SelectedTabTextColor or SelectedTheme.TabTextColor
			TabButton.Title.TextColor3 = isSelected and SelectedTheme.SelectedTabTextColor or SelectedTheme.TabTextColor
			if not Hidden and not Minimised then
				TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = isSelected and 0 or 0.7}):Play()
				TweenService:Create(TabButton.Image, TweenInfo.new(0.3), {ImageTransparency = isSelected and 0 or 0.2}):Play()
				TweenService:Create(TabButton.Title, TweenInfo.new(0.3), {TextTransparency = isSelected and 0 or 0.2}):Play()
			end
		end

		updateTabVisuals()

		TabButton.Interact.MouseButton1Click:Connect(function()
			if Minimised or Elements.UIPageLayout.CurrentPage == TabPage then return end
			Elements.UIPageLayout:JumpTo(TabPage)
			for _, otherTab in ipairs(TabList:GetChildren()) do if otherTab:IsA("Frame") and otherTab.Name ~= "Template" and otherTab.Parent == TabList and otherTab:FindFirstChild("__updateVisuals") then otherTab.__updateVisuals() end end
		end)
		TabButton:SetAttribute("__updateVisuals", updateTabVisuals)

		local Tab = {}
		function Tab:CreateButton(ButtonSettings) return {} end
		function Tab:CreateColorPicker(ColorPickerSettings) return {} end
		function Tab:CreateSection(SectionName) return {} end
		function Tab:CreateDivider() return {} end
		function Tab:CreateLabel(LabelText, Icon, Color, IgnoreTheme) return {} end
		function Tab:CreateParagraph(ParagraphSettings) return {} end
		function Tab:CreateInput(InputSettings) return {} end
		function Tab:CreateDropdown(DropdownSettings) return {} end
		function Tab:CreateKeybind(KeybindSettings) return {} end
		function Tab:CreateToggle(ToggleSettings) return {} end
		function Tab:CreateSlider(SliderSettings) return {} end
		
		return Tab
	end

	task.wait(1.1)
	TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)}):Play()
	task.wait(0.2)
	LoadingFrame.Visible = false
	
	Topbar.Visible = true
	TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	task.wait(0.1)
	TweenService:Create(Topbar.Title, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	for _, button in ipairs(Topbar:GetChildren()) do if button:IsA("ImageButton") then task.wait(0.05); TweenService:Create(button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play() end end
	if dragBarCosmetic then TweenService:Create(dragBarCosmetic, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play() end

	function Window.ModifyTheme(NewTheme)
		ChangeTheme(NewTheme)
		RayfieldLibrary:Notify({Title = 'Theme Changed', Content = 'Successfully changed theme.', Image = "palette"})
	end

	pcall(createSettings, Window)
	return Window
end

local function setVisibility(visibility: boolean, notify: boolean?)
	if Debounce then return end
	if visibility then
		Unhide()
	else
		Hide(notify)
	end
end

function RayfieldLibrary:SetVisibility(visibility: boolean)
	setVisibility(visibility, false)
end

function RayfieldLibrary:IsVisible(): boolean
	return not Hidden
end

local hideHotkeyConnection
function RayfieldLibrary:Destroy()
	rayfieldDestroyed = true
	if hideHotkeyConnection then hideHotkeyConnection:Disconnect() end
	Rayfield:Destroy()
end

Topbar.ChangeSize.MouseButton1Click:Connect(function()
	if Debounce then return end
	if Minimised then Maximise() else Minimise() end
end)

Main.Search.Input:GetPropertyChangedSignal('Text'):Connect(function()
	local query = string.lower(Main.Search.Input.Text)
	local page = Elements.UIPageLayout.CurrentPage
	if not page then return end
	
	local searchTitle = page:FindFirstChild("SearchTitle-fsefsefesfsefesfesfThanks")
	if #query > 0 then
		if not searchTitle then
			searchTitle = Elements.Template.SectionTitle:Clone()
			searchTitle.Parent = page
			searchTitle.Name = 'SearchTitle-fsefsefesfsefesfesfThanks'
			searchTitle.LayoutOrder = -100
			searchTitle.Visible = true
		end
		searchTitle.Title.Text = "Results from '"..page.Name.."'"
	elseif searchTitle then
		searchTitle:Destroy()
	end

	for _, element in ipairs(page:GetChildren()) do
		if element.ClassName ~= 'UIListLayout' and element.Name ~= 'Placeholder' and element.Name ~= 'SearchTitle-fsefsefesfsefesfesfThanks' then
			if element.Name == 'SectionTitle' then
				element.Visible = #query == 0
			else
				element.Visible = #query == 0 or string.find(string.lower(element.Name), query, 1, true)
			end
		end
	end
end)

Main.Search.Input.FocusLost:Connect(function()
	if #Main.Search.Input.Text == 0 and searchOpen then task.wait(0.12); closeSearch() end
end)

Topbar.Search.MouseButton1Click:Connect(function() if searchOpen then closeSearch() else openSearch() end end)

if Topbar:FindFirstChild('Settings') then
	Topbar.Settings.MouseButton1Click:Connect(function() Elements.UIPageLayout:JumpTo(Elements['Rayfield Settings']) end)
end

Topbar.Hide.MouseButton1Click:Connect(function() setVisibility(Hidden, not useMobileSizing) end)

hideHotkeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode.Name == getSetting("General", "rayfieldOpen") then
		setVisibility(Hidden)
	end
end)

if MPrompt then MPrompt.Interact.MouseButton1Click:Connect(function() if Hidden then Unhide() end end) end

for _, TopbarButton in ipairs(Topbar:GetChildren()) do
	if TopbarButton:IsA("ImageButton") and TopbarButton.Name ~= 'Icon' then
		TopbarButton.MouseEnter:Connect(function() TweenService:Create(TopbarButton, TweenInfo.new(0.3), {ImageTransparency = 0}):Play() end)
		TopbarButton.MouseLeave:Connect(function() TweenService:Create(TopbarButton, TweenInfo.new(0.3), {ImageTransparency = 0.8}):Play() end)
	end
end

function RayfieldLibrary:LoadConfiguration()
	if CEnabled then
		if isfile and isfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) then
			if LoadConfiguration(readfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension)) then
				RayfieldLibrary:Notify({Title = "Configuration Loaded", Content = "Settings loaded from a previous session.", Image = "folder-down"})
			end
		elseif not isfile then
			RayfieldLibrary:Notify({Title = "Configuration", Content = "Configuration saving is unavailable in this environment.", Image = "folder-x"})
		end
	end
	globalLoaded = true
end

task.delay(4, function()
	RayfieldLibrary:LoadConfiguration()
	if Main:FindFirstChild('Notice') and Main.Notice.Visible then
		TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1}):Play()
		TweenService:Create(Main.Notice.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
		task.wait(0.5)
		Main.Notice.Visible = false
	end
end)

return RayfieldLibrary
