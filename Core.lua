local _, Core = ...

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local callbacks = {}

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

function Core:RegisterCallback(key, func)
	if type(key) == "table" then
		for _, key2 in ipairs(key) do
			if callbacks[key2] then
				table.insert(callbacks, func)
			else
				callbacks[key2] = { func }
			end
		end
	else
		if callbacks[key] then
			table.insert(callbacks, func)
		else
			callbacks[key] = { func }
		end
	end
end