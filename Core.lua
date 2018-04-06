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

	-- Set CVar
	SetCVar("nameplateResourceOnTarget", 0)
	SetCVar("nameplateShowSelf", 0)
end

function Core:OnEnable()
    self:RegisterChatCommand("JokUI", "OnSlash")
	self:RegisterChatCommand("Jok", "OnSlash")
end

function Core:OnSlash(cmd)
	AceConfigDialog:Open("JokUI")
end

function Core:RegisterModule(name, ...)
	local mod = self:NewModule(name, ...)
	self[name] = mod
	return mod
end

-- SLASH COMMANDS

 SlashCmdList['RELOAD'] = function() ReloadUI() end
 SLASH_RELOAD1 = '/rlo'

