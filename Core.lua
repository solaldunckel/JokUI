local _, Core = ...

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local callbacks = {}

JokUI = LibStub("AceAddon-3.0"):NewAddon(Core, "JokUI")

LibStub("AceEvent-3.0"):Embed(JokUI)
LibStub("AceConsole-3.0"):Embed(JokUI)
LibStub("AceHook-3.0"):Embed(JokUI)

JokUI:SetDefaultModuleLibraries("AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")

function Core:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("JokUIDB", nil, true)

	AceConfigDialog:SetDefaultSize("JokUI", 700, 650)
	AceConfigDialog:AddToBlizOptions("JokUI", "|cffFF7D0AJok|rUI", options)
end

function Core:OnEnable()
    self:RegisterChatCommand("JokUI", "OpenGUI")
	self:RegisterChatCommand("Jok", "OpenGUI")
	self:RegisterChatCommand("rl", "ReloadUI")

	if not (IsAddOnLoaded("MoveAnything")) then
		self:RegisterChatCommand("Move", "MoveAllFrames")
	end
	self:RegisterChatCommand("Jokmove", "MoveAllFrames")
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

function Core:ReloadUI(cmd)
	ReloadUI()
end

function Core:MoveAllFrames(cmd)
	PowerBarAlt:Move()
    ExtraActionButton:Move()
    PlayerFrame:Move()
    TargetFrame:Move()
    SGrid(64)
    --BossFrameMove()

    StaticPopup_Show ("Lock")
	if not MoveBackgroundFrame:IsShown() then
		StaticPopup_Hide ("Lock")
	end
end

function Core:OpenGUI(cmd)
	AceConfigDialog:Open("JokUI")
end

-----
-- RELOAD UI POPUP
-----

StaticPopupDialogs["ReloadUI_Popup"] = {
	text = "Reload your UI to apply changes?",
	button1 = "Reload",
	button2 = "Later",
	OnAccept = function()
	    ReloadUI()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-----
-- LOCK POPUP
-----

StaticPopupDialogs["Lock"] = {
	text = "Do you want to lock frames?",
	button1 = "Lock",
	OnAccept = function()
	    Core:MoveAllFrames()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-----
-- Move All Background Frame
-----

MoveBackgroundFrame = CreateFrame("Frame", nil, UIParent)
MoveBackgroundFrame:SetFrameStrata("BACKGROUND")
MoveBackgroundFrame:SetBackdrop({
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
})
MoveBackgroundFrame:SetAllPoints(UIParent)
MoveBackgroundFrame:SetBackdropColor(0, 0, 0, 1)
MoveBackgroundFrame:Hide()

-----
-- HonorFrame Taint Workaround
-- Credit: https://www.townlong-yak.com/bugs/afKy4k-HonorFrameLoadTaint

if ( UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0 ) < 2 then
	UIDROPDOWNMENU_VALUE_PATCH_VERSION = 2
	hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
		if UIDROPDOWNMENU_VALUE_PATCH_VERSION ~= 2 then
			return
		end
		for i=1, UIDROPDOWNMENU_MAXLEVELS do
			for j=1, UIDROPDOWNMENU_MAXBUTTONS do
				local b = _G["DropDownList" .. i .. "Button" .. j]
				if ( not (issecurevariable(b, "value") or b:IsShown()) ) then
					b.value = nil
					repeat
						j, b["fx" .. j] = j+1
					until issecurevariable(b, "value")
				end
			end
		end
	end)
end