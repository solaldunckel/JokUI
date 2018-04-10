local _, Core = ...

local AceConfigDialog = LibStub("AceConfigDialog-3.0")

JokUI = LibStub("AceAddon-3.0"):NewAddon(Core, "JokUI")

LibStub("AceEvent-3.0"):Embed(JokUI)
LibStub("AceConsole-3.0"):Embed(JokUI)

JokUI:SetDefaultModuleLibraries("AceEvent-3.0", "AceConsole-3.0")

local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("font", "Fira Mono Medium", "Interface\\Addons\\JokUI\\media\\FiraMono-Medium.ttf")

function Core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("JokUIDB", nil, true)

	AceConfigDialog:SetDefaultSize("JokUI", 700, 650)
	AceConfigDialog:AddToBlizOptions("JokUI", "JokUI", options)
end

function Core:OnEnable()
    self:RegisterChatCommand("JokUI", "OpenGUI")
	self:RegisterChatCommand("Jok", "OpenGUI")
	self:RegisterChatCommand("rl", "ReloadUI")
end

function Core:OpenGUI(cmd)
	AceConfigDialog:Open("JokUI")
end

function Core:ReloadUI(cmd)
	ReloadUI()
end

function Core:RegisterModule(name, ...)
	local mod = self:NewModule(name, ...)
	self[name] = mod
	return mod
end

-- local Listener = CreateFrame('Frame', 'JokUI' .. 'Listener')
-- local EventListeners = {}
-- local function Core_OnEvent(frame, event, ...)
-- 	if EventListeners[event] then
-- 		for callback, func in pairs(EventListeners[event]) do
-- 			if func == 0 then
-- 				callback[event](callback, ...)
-- 			else
-- 				callback[func](callback, event, ...)
-- 			end
-- 		end
-- 	end
-- end
-- Listener:SetScript('OnEvent', Core_OnEvent)
-- function Core:RegisterEvent(event, callback, func)
-- 	if func == nil then func = 0 end
-- 	if EventListeners[event] == nil then
-- 		Listener:RegisterEvent(event)
-- 		EventListeners[event] = { [callback]=func }
-- 	else
-- 		EventListeners[event][callback] = func
-- 	end
-- end

-- function Core:UnregisterEvent(event, callback)
-- 	local listeners = EventListeners[event]
-- 	if listeners then
-- 		local count = 0
-- 		for index,_ in pairs(listeners) do
-- 			if index == callback then
-- 				listeners[index] = nil
-- 			else
-- 				count = count + 1
-- 			end
-- 		end
-- 		if count == 0 then
-- 			EventListeners[event] = nil
-- 			Listener:UnregisterEvent(event)
-- 		end
-- 	end
-- end

-- local AddOnListeners = {}
-- function Core:ADDON_LOADED(name)
-- 	if AddOnListeners[name] then
-- 		for callback, func in pairs(AddOnListeners[name]) do
-- 			if func == 0 then
-- 				callback[name](callback)
-- 			else
-- 				callback[func](callback, name)
-- 			end
-- 		end
-- 	end
-- end

-- function Core:RegisterAddOnLoaded(name, callback, func)
-- 	if func == nil then func = 0 end
-- 	if IsAddOnLoaded(name) then
-- 		if func == 0 then
-- 			callback[name](callback)
-- 		else
-- 			callback[func](callback, name)
-- 		end
-- 	else
-- 		self:RegisterEvent('ADDON_LOADED', self)
-- 		if AddOnListeners[name] == nil then
-- 			AddOnListeners[name] = { [callback]=func }
-- 		else
-- 			AddOnListeners[name][callback] = func
-- 		end
-- 	end
-- end

-- function Core:UnregisterAddOnLoaded(name, callback)
-- 	local listeners = AddOnListeners[name]
-- 	if listeners then
-- 		local count = 0
-- 		for index,_ in pairs(listeners) do
-- 			if index == callback then
-- 				listeners[index] = nil
-- 			else
-- 				count = count + 1
-- 			end
-- 		end
-- 		if count == 0 then
-- 			AddOnListeners[name] = nil
-- 		end
-- 	end
-- end