local _, Core = ...

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local callbacks = {}

JokUI = LibStub("AceAddon-3.0"):NewAddon(Core, "JokUI")

LibStub("AceEvent-3.0"):Embed(JokUI)
LibStub("AceConsole-3.0"):Embed(JokUI)

JokUI:SetDefaultModuleLibraries("AceEvent-3.0", "AceConsole-3.0")

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
	
	self:Debug()
end

function Core:OpenGUI(cmd)
	AceConfigDialog:Open("JokUI")
end

function Core:ReloadUI(cmd)
	ReloadUI()
end

function Core:MoveAllFrames(cmd)
	PowerBarAlt:Move()
    ExtraActionButton:Move()
    SGrid(64)
    BossFrameMove()

    StaticPopup_Show ("Lock")
	if not bkgndFrame:IsShown() then
		StaticPopup_Hide ("Lock")
	end
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

function Core:Debug()
	-- local debug = CreateFrame("FRAME")
	-- debug.text = debug:CreateFontString(nil, 'BACKGROUND')
	-- debug.text:SetPoint("TOP", UIParent, "TOP", 0, -20)
	-- debug.text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")

	-- debug:SetScript("OnUpdate", function()
	-- 	local time = GetTime()
	-- 	if not last or last < time - 0.3 then
 --    		last = time		
 --    		UpdateAddOnMemoryUsage()
 --    		local JokUIMemory = GetAddOnMemoryUsage("JokUI")
 --    		UpdateAddOnMemoryUsage()
			
	-- 		debug.text:SetText("|cffFF7D0AJok|rUI : "..memFormat(JokUIMemory))
	-- 	end
	-- end)

	local nb = 0

	function DebugTest()
		nb = nb+1
		print("FrameUpdate : "..nb)
	end

end

-----
-- Move All Background Frame
-----

bkgndFrame = CreateFrame("Frame", nil, UIParent)
bkgndFrame:SetFrameStrata("BACKGROUND")
bkgndFrame:SetBackdrop({
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
})
bkgndFrame:SetAllPoints(UIParent)
bkgndFrame:SetBackdropColor(0, 0, 0, 1)
bkgndFrame:Hide()

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