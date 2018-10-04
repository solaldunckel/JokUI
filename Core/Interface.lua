local _, JokUI = ...
local Interface = JokUI:RegisterModule("Interface")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local features = {}

local font = STANDARD_TEXT_FONT

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local interface_defaults = {
    profile = {
    	UnitFrames = {
    		scale = 1.1,
    	},
    	CastBars = {
    		player = { x = 0, y = 175},
    		target = { x = 0, y = 550},
    	},
    	PlayerFrame = {
    		point = "TOPLEFT",
    		x = -19,
    		y = -6, 
    	},
    	TargetFrame = {
    		point = "TOPLEFT",
    		x = 250,
    		y = -6, 
    	},
    	BossFrame = {"TOPLEFT", nil, "TOPLEFT", 1250, -285},
    	SkinInterface = true,    	
    }
}

local interface_config = {
    title = {
        type = "description",
        name = "|cff64b4ffInterface",
        fontSize = "large",
        order = 0,
    },
    desc = {
        type = "description",
        name = "Various useful to customize interface.\n",
        fontSize = "medium",
        order = 1,
    },
    unitframes = {
        name = "Unit Frames",
        type = "group",
        inline = true,
        order = 2,
        args = {
            scale = {
                type = "range",
                isPercent = true,
                name = "Scale",
                desc = "",
                min = 0.5,
                max = 1.5,
                step = 0.05,
                order = 1,
                set = function(info,val) 
                    Interface.settings.UnitFrames.scale = val
                    PlayerFrame:SetScale(val)
					TargetFrame:SetScale(val)
					FocusFrame:SetScale(val)
                end,
                get = function(info) return Interface.settings.UnitFrames.scale end
            },			
        },
    },
}

function Interface:OnInitialize()
    self.db = JokUI.db:RegisterNamespace("Interface", interface_defaults)
    self.settings = self.db.profile
    JokUI.Config:Register("Interface", interface_config, 13)
end

function Interface:OnEnable()
	for name in pairs(features) do
		self:SyncFeature(name)
	end

	self:UnitFrames()
	self:BuffPlayerFrame()
	self:PlayerFrame()
	self:TargetFrame()	
	self:Chat()
	self:Minimap()
	self:Buffs()
	self:CastBars()
	self:ReAnchor()
	self:Mover()
end

do
	local order = 10
	function Interface:RegisterFeature(name, short, long, default, reload, fn)
		interface_config[name] = {
			type = "toggle",
			name = short,
			descStyle = "inline",
			desc = "|cffaaaaaa" .. long,
			width = "full",
			get = function() return Interface.settings[name] end,
			set = function(_, v)
				Interface.settings[name] = v
				self:SyncFeature(name)
				if reload then
					StaticPopup_Show ("ReloadUI_Popup")
				end
			end,
			order = order
		}
		interface_defaults.profile[name] = default
		order = order + 1
		features[name] = fn
	end
end

function Interface:SyncFeature(name)
	features[name](Interface.settings[name])
end

do
	Interface:RegisterFeature("AutoQuest",
		"Auto Turn/Pick Quests",
		"Automatically pick and turn in quests. (Use SHIFT to bypass)",
		false,
		true,
		function(state)
			if state then
				Interface:AutoQuest()
			end
		end)
end

do
	Interface:RegisterFeature("Hide ExtraActionButton Texture",
		"Hide ExtraActionButton Texture",
		"Hide ExtraActionButton Texture.",
		false,
		true,
		function(state)
			if state then
				local ZoneAbilityFrame = ZoneAbilityFrame.SpellButton.Style
				hooksecurefunc(ZoneAbilityFrame, "SetTexture", function(self, texture)
      				if texture then
        				self:SetTexture(nil)
      				end
   				end)
   				local style = ExtraActionButton1.style
				hooksecurefunc(style, "SetTexture", function(self, texture)
      				if texture then
        				self:SetTexture(nil)
      				end
   				end)
			end
		end)
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

function Interface:UnitFrames()
	-- SCALE
	PlayerFrame:SetScale(Interface.settings.UnitFrames.scale)
	TargetFrame:SetScale(Interface.settings.UnitFrames.scale)
	FocusFrame:SetScale(Interface.settings.UnitFrames.scale)

	PlayerPVPIcon:SetAlpha(0)
	FocusFrameTextureFramePVPIcon:SetAlpha(0)

	--HIDE COLORS BEHIND NAME
	hooksecurefunc("TargetFrame_CheckFaction", function(self)
	    self.nameBackground:SetVertexColor(0, 0, 0, 0.5);
	end)

	-- CLASS COLOR HP BAR
	local function colour(statusbar, unit)
		if self.isBossFrame then return end
        local _, class, c
        if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
            _, class = UnitClass(unit)
            c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
            statusbar:SetStatusBarColor(c.r, c.g, c.b)
        end
	end

	hooksecurefunc("UnitFrameHealthBar_Update", colour)
	hooksecurefunc("HealthBar_OnValueChanged", function(self)
	    colour(self, self.unit)
	end)

	-- HIT INDICATOR
	PlayerFrame:UnregisterEvent("UNIT_COMBAT")
	PetFrame:UnregisterEvent("UNIT_COMBAT")

	-- AURA POSITION
	local AURA_START_X = 5;
	local AURA_START_Y = 32;
	local AURA_OFFSET_X = 2;
	local AURA_OFFSET_Y = 1;
	local LARGE_AURA_SIZE = 21;
	local SMALL_AURA_SIZE = 21;
	local AURA_ROW_WIDTH = 122;
	local TOT_AURA_ROW_WIDTH = 101;
	local NUM_TOT_AURA_ROWS = 2;	-- TODO: replace with TOT_AURA_ROW_HEIGHT functionality if this becomes a problem

	function TargetFrame_UpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
		-- a lot of this complexity is in place to allow the auras to wrap around the target of target frame if it's shown

		-- Position auras
		local size;
		local offsetY = AURA_OFFSET_Y;
		local offsetX = AURA_OFFSET_X;
		-- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
		local rowWidth = 0;
		local firstBuffOnRow = 1;
		for i=1, numAuras do
			-- update size and offset info based on large aura status
			if ( largeAuraList[i] ) then
				size = LARGE_AURA_SIZE;
				offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
			else
				size = SMALL_AURA_SIZE;
			end

			-- anchor the current aura
			if ( i == 1 ) then
				rowWidth = size;
				self.auraRows = self.auraRows + 1;
			else
				rowWidth = rowWidth + size + offsetX;
			end
			if ( rowWidth > maxRowWidth ) then
				-- this aura would cause the current row to exceed the max row width, so make this aura
				-- the start of a new row instead
				updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY, mirrorAurasVertically);

				rowWidth = size;
				self.auraRows = self.auraRows + 1;
				firstBuffOnRow = i;
				offsetY = AURA_OFFSET_Y;

				if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
					-- if we exceed the number of tot rows, then reset the max row width
					-- note: don't have to check if we have tot because AURA_ROW_WIDTH is the default anyway
					maxRowWidth = AURA_ROW_WIDTH;
				end
			else
				updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically);
			end
		end
	end
end 

function Interface:BuffPlayerFrame()
	local MAX_BUFFS = 32;
	local MAX_DEBUFFS = 32;

	local AURA_START_X = 107;
	local AURA_START_Y = 32
	local AURA_ICON_SIZE = 21;
	local AURA_SPACING_X = 2;
	local AURA_SPACING_Y = 2;
	local MAX_ROW_SIZE = 5;

	local BuffsFrame = CreateFrame("Frame", "PlayerFrameBuffs");
	local DebuffsFrame = CreateFrame("Frame", "PlayerFrameDebuffs");
	BuffsFrame:SetSize(10, 10);
	DebuffsFrame:SetSize(10, 10);

	local function UpdateBuffAnchor(self, buffName, index, numDebuffs, newRow, startX, startY)
		local buff = _G[buffName..index];
		
		if ( index == 1 ) then
			buff:SetPoint("TOPLEFT", self, "BOTTOMLEFT", startX, startY);
			BuffsFrame:SetPoint("TOPLEFT", buff, "TOPLEFT", 0, 0);
			BuffsFrame:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_SPACING_Y);
		elseif ( newRow ) then
			buff:SetPoint("TOPLEFT", _G[buffName..(index - MAX_ROW_SIZE)], "BOTTOMLEFT", 0, -AURA_SPACING_Y);
			BuffsFrame:SetPoint("BOTTOMLEFT", buff, "BOTTOMLEFT", 0, -AURA_SPACING_Y);
		else
			buff:SetPoint("TOPLEFT", _G[buffName..(index - 1)], "TOPRIGHT", AURA_SPACING_X, 0);
		end

		-- Resize
		buff:SetWidth(AURA_ICON_SIZE);
		buff:SetHeight(AURA_ICON_SIZE);
	end

	local function UpdateDebuffAnchor(self, debuffName, index, numBuffs, newRow, startX, startY)
		local debuff = _G[debuffName..index];

		if ( index == 1 ) then
			debuff:SetPoint("TOPLEFT", BuffsFrame, "BOTTOMLEFT", 0, -AURA_SPACING_Y);
			DebuffsFrame:SetPoint("TOPLEFT", debuff, "TOPLEFT", 0, 0);
			DebuffsFrame:SetPoint("BOTTOMLEFT", debuff, "BOTTOMLEFT", 0, -AURA_SPACING_Y);
		elseif ( newRow ) then
			debuff:SetPoint("TOPLEFT", _G[debuffName..(index - MAX_ROW_SIZE)], "BOTTOMLEFT", 0, -AURA_SPACING_Y);
			DebuffsFrame:SetPoint("BOTTOMLEFT", debuff, "BOTTOMLEFT", 0, -AURA_SPACING_Y);
		else
			debuff:SetPoint("TOPLEFT", _G[debuffName..(index - 1)], "TOPRIGHT", AURA_SPACING_X + 1, 0);
		end

		-- Resize
		debuff:SetWidth(AURA_ICON_SIZE);
		debuff:SetHeight(AURA_ICON_SIZE);
		
		local debuffFrame =_G[debuffName..index.."Border"];
		debuffFrame:SetWidth(AURA_ICON_SIZE+2);
		debuffFrame:SetHeight(AURA_ICON_SIZE+2);
	end

	local function UpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, updateFunc)
		local startX, startY;
		if ( PetFrame and PetFrame:IsShown() ) then
			startX, startY = AURA_START_X, -8;
		elseif ( PlayerFrameAlternateManaBar and PlayerFrameAlternateManaBar:IsShown() ) then -- Manabar
			startX, startY = AURA_START_X, AURA_START_Y-12;
		elseif ( ComboPointPlayerFrame and ComboPointPlayerFrame:IsShown() ) then -- Combos
			startX, startY = AURA_START_X, AURA_START_Y-18;
		elseif ( RuneFrame and RuneFrame:IsShown() ) then 
			startX, startY = AURA_START_X, AURA_START_Y-23;
		else
			startX, startY = AURA_START_X, AURA_START_Y;
		end

		-- current width of a row, increases as auras are added and resets when a new aura's width exceeds the max row width
		local rowSize = 0;
		for i=1, numAuras do
			-- anchor the current aura
			if ( i == 1 ) then
				rowSize = 1;
			else
				rowSize = rowSize + 1;
			end
			if ( rowSize > MAX_ROW_SIZE ) then
				-- this aura would cause the current row to exceed the max row size, so make this aura
				-- the start of a new row instead
				rowSize = 1;
				updateFunc(self, auraName, i, numOppositeAuras, true, startX, startY);
			else
				updateFunc(self, auraName, i, numOppositeAuras, false, startX, startY);
			end
		end
	end

	local function UpdateAuras()
		local self = PlayerFrame;
		local frame, frameName;
		local frameIcon, frameCount, frameCooldown;
		local numBuffs = 0;
		
		for i = 1, 32 do
			local buffName, icon, count, _, duration, expirationTime = UnitBuff(self.unit, i, nil);
			if ( buffName ) then
				frameName = "PlayerFrameBuff"..(i);
				frame = _G[frameName];
				if ( not frame ) then
					if ( not icon ) then
						break;
					else
						frame = CreateFrame("Button", frameName, self, "TargetBuffFrameTemplate");
						frame.unit = self.unit;
					end
				end
				if ( icon ) then
					frame:SetID(i);
					
					-- set the icon
					frameIcon = _G[frameName.."Icon"];
					frameIcon:SetTexture(icon);
					
					-- set the count
					frameCount = _G[frameName.."Count"];
					if ( count > 1 ) then
						frameCount:SetText(count);
						frameCount:Show();
					else
						frameCount:Hide();
					end
					
					-- Handle cooldowns
					frameCooldown = _G[frameName.."Cooldown"];
					CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);
					
					numBuffs = numBuffs + 1;

					frame:ClearAllPoints();
					frame:Show();
				else
					frame:Hide();
				end
			else
				break;
			end
		end
		
		for i = numBuffs + 1, MAX_BUFFS do
			local frame = _G["PlayerFrameBuff"..i];
			if ( frame ) then
				frame:Hide();
			else
				break;
			end
		end
		
		local color;
		local frameBorder;
		local numDebuffs = 0;
		
		for i = 1, 16 do
			local debuffName, icon, count, debuffType, duration, expirationTime = UnitDebuff(self.unit, i, nil);
			if ( debuffName ) then
				frameName = "PlayerFrameDebuff"..(i);
				frame = _G[frameName];
				if ( not frame ) then
					if ( not icon ) then
						break;
					else
						frame = CreateFrame("Button", frameName, self, "TargetDebuffFrameTemplate");
						frame.unit = self.unit;
					end
				end
				if ( icon ) then
					frame:SetID(i);
					
					-- set the icon
					frameIcon = _G[frameName.."Icon"];
					frameIcon:SetTexture(icon);
					
					-- set the count
					frameCount = _G[frameName.."Count"];
					if ( count > 1 ) then
						frameCount:SetText(count);
						frameCount:Show();
					else
						frameCount:Hide();
					end
					
					-- Handle cooldowns
					frameCooldown = _G[frameName.."Cooldown"];
					CooldownFrame_Set(frameCooldown, expirationTime - duration, duration, duration > 0, true);
					
					-- set debuff type color
					if ( debuffType ) then
						color = DebuffTypeColor[debuffType];
					else
						color = DebuffTypeColor["none"];
					end
					frameBorder = _G[frameName.."Border"];
					frameBorder:SetVertexColor(color.r, color.g, color.b);
					
					numDebuffs = numDebuffs + 1;

					frame:ClearAllPoints();
					frame:Show();
				else
					frame:Hide();
				end
			else
				break;
			end
		end
		
		for i = numDebuffs + 1, MAX_DEBUFFS do
			local frame = _G["PlayerFrameDebuff"..i];
			if ( frame ) then
				frame:Hide();
			else
				break;
			end
		end
		
		-- update buff positions
		UpdateAuraPositions(self, "PlayerFrameBuff", numBuffs, numDebuffs, UpdateBuffAnchor);
		
		-- update debuff positions
		UpdateAuraPositions(self, "PlayerFrameDebuff", numDebuffs, numBuffs, UpdateDebuffAnchor);
	end

	local frame = CreateFrame("Frame", nil, UIParent)

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("UNIT_AURA")
	frame:RegisterEvent("UNIT_PET")
	frame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	frame:RegisterEvent("UNIT_EXITED_VEHICLE")

	frame:SetScript("OnEvent", function(self, event, ...)
		local arg1 = ...;

		if ( event == "PLAYER_ENTERING_WORLD" ) then
			UpdateAuras();
		elseif ( event == "UNIT_AURA" ) then
			if ( arg1 == "player" ) then
				UpdateAuras();
			end
		elseif ( event == "UNIT_PET" ) then
			if ( arg1 == "player" ) then
				UpdateAuras();
			end
		elseif ( event == "UNIT_ENTERED_VEHICLE" ) then
			if ( arg1 == "player" ) then
				UpdateAuras();
			end
		elseif ( event == "UNIT_EXITED_VEHICLE" ) then
			if ( arg1 == "player" ) then
				UpdateAuras();
			end
		end
	end)
end

function Interface:PlayerFrame()

	local IsMoveAnythingLoaded

	if (IsAddOnLoaded("MoveAnything")) then
		IsMoveAnythingLoaded = " |cffffd100/jokmove r" 
	else
		IsMoveAnythingLoaded = " |cffffd100/move |r"
	end
	
	local PlayerFrame = PlayerFrame
	PlayerFrame:SetMovable(true)
	PlayerFrame:SetUserPlaced(true)

	-- Remove integrated movement functions to avoid conflicts
	_G.PlayerFrame_ResetUserPlacedPosition = function() 
		Interface.settings.PlayerFrame = {
			point = "TOPLEFT",
			x = -19,
			y = -6,
		}
		PlayerFrame:SetPoint(Interface.settings.PlayerFrame.point, Interface.settings.PlayerFrame.x, Interface.settings.PlayerFrame.y)
	end

	
	_G.PlayerFrame_SetLocked = function() print("use /move") end

	local locked = true
	local moving = nil

	PlayerFrame:SetScript("OnMouseDown", function(self, button)
		if locked then return end
		if button == "LeftButton" then
			PlayerFrame:ClearAllPoints()
			PlayerFrame:StartMoving()
			moving = true
		end
	end)

	PlayerFrame:SetScript("OnMouseUp", function(self, button)
		if moving then
			moving = nil
			PlayerFrame:StopMovingOrSizing()

			local point, _, _, x, y = PlayerFrame:GetPoint(1)
			Interface.settings.PlayerFrame.point = point
			Interface.settings.PlayerFrame.x = x
			Interface.settings.PlayerFrame.y = y
		end
	end)

	PlayerFrame:ClearAllPoints()
	PlayerFrame:SetPoint(Interface.settings.PlayerFrame.point, Interface.settings.PlayerFrame.x, Interface.settings.PlayerFrame.y)

	function PlayerFrame:Move()
		if locked == false then
			locked = true
			PlayerFrame:SetFrameStrata("MEDIUM")
			PlayerFrame:SetMovable(false)
			MoveBackgroundFrame:Hide()
		else
			locked = false
			PlayerFrame:SetFrameStrata("TOOLTIP")
			PlayerFrame:SetMovable(true)
			MoveBackgroundFrame:SetFrameStrata("DIALOG")
			MoveBackgroundFrame:Show()
		end
	end
end

function Interface:TargetFrame()
	_G.TargetFrame_ResetUserPlacedPosition = function() 
	Interface.settings.TargetFrame = {
			point = "TOPLEFT",
			x = 250,
			y = -6,
		}
		TargetFrame:SetPoint(Interface.settings.TargetFrame.point, Interface.settings.TargetFrame.x, Interface.settings.TargetFrame.y)
	end
	_G.TargetFrame_SetLocked = function() print("use /move") end

	local TargetFrame = TargetFrame
	TargetFrame:SetMovable(true)
	TargetFrame:SetUserPlaced(true)

	local locked = true
	local moving = nil

	TargetFrame:SetScript("OnMouseDown", function(self, button)
		if locked then return end
		if button == "LeftButton" then
			TargetFrame:ClearAllPoints()
			TargetFrame:StartMoving()
			moving = true
		end
	end)

	TargetFrame:SetScript("OnMouseUp", function(self, button)
		if moving then
			moving = nil
			TargetFrame:StopMovingOrSizing()

			local point, _, _, x, y = TargetFrame:GetPoint(1)
			Interface.settings.TargetFrame.point = point
			Interface.settings.TargetFrame.x = x
			Interface.settings.TargetFrame.y = y
		end
	end)

	TargetFrame:ClearAllPoints()
	TargetFrame:SetPoint(Interface.settings.TargetFrame.point, Interface.settings.TargetFrame.x, Interface.settings.TargetFrame.y)

	function TargetFrame:Move()
		if locked == false then
			locked = true
			TargetFrame:SetMovable(false)
			TargetFrame:SetFrameStrata("MEDIUM")
			MoveBackgroundFrame:Hide()
		else
			locked = false
			TargetFrame:SetFrameStrata("TOOLTIP")
			TargetFrame:SetMovable(true)
			MoveBackgroundFrame:SetFrameStrata("DIALOG")
			MoveBackgroundFrame:Show()
			if not UnitExists("target") then
				SetPortraitTexture(TargetFramePortrait, "player")
				TargetFrameTextureFrameName:SetText("test")
				TargetFrameHealthBar:SetMinMaxValues(1, 99999999)
				TargetFrameHealthBar:SetValue(random(11111111, 88888888))
				
				TargetFrame:Show()
			end
		end
	end
end

function Interface:Chat()

	-- Table to keep track of frames you already saw:
	local frames = {}

	-- Function to handle customzing a chat frame:
	local function ProcessFrame(frame)
		if frames[frame] then return end

		frame:SetClampRectInsets(0, 0, 0, 0)
		frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
		frame:SetMinResize(250, 100)

		frames[frame] = true
	end

	-- Loop Through Chat Windows
	for i = 1, NUM_CHAT_WINDOWS do
	    ProcessFrame(_G["ChatFrame" .. i])
		local chatWindowName = _G["ChatFrame"..i]:GetName();
		local name, size, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);

		-- Change Chat Tabs
		local chatTab = _G[chatWindowName.."Tab"];

		--Hide Tab Backgrounds
		_G[chatWindowName.."TabLeft"]:SetTexture( nil );
		_G[chatWindowName.."TabMiddle"]:SetTexture( nil );
		_G[chatWindowName.."TabRight"]:SetTexture( nil );
		_G[chatWindowName.."TabSelectedLeft"]:SetTexture(nil)
		_G[chatWindowName.."TabSelectedMiddle"]:SetTexture(nil)
		_G[chatWindowName.."TabSelectedRight"]:SetTexture(nil)

		_G[chatWindowName.."ButtonFrameBackground"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameLeftTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameRightTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameTopTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameTopRightTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameTopLeftTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameBottomTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameBottomRightTexture"]:SetTexture( nil );
		_G[chatWindowName.."ButtonFrameBottomLeftTexture"]:SetTexture( nil );
		chatTab:SetAlpha( 1.0 );
	end

	-- Set up a dirty hook to catch temporary windows and customize them when they are created:
	local old_OpenTemporaryWindow = FCF_OpenTemporaryWindow
	FCF_OpenTemporaryWindow = function(...)
		local frame = old_OpenTemporaryWindow(...)
		ProcessFrame(frame)
		return frame
	end

	----------------------------------------------------------------------
	-- Unclamp chat frame
	----------------------------------------------------------------------

	-- Process normal and existing chat frames on startup
	for i = 1, 50 do
		if _G["ChatFrame" .. i] then 
			_G["ChatFrame" .. i]:SetClampRectInsets(0, 0, 0, 0);
		end
	end

	-- Set local channel colors
	for i = 1, 18 do
		if _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"] then
			ToggleChatColorNamesByClassGroup(true, _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"]:GetParent().type)
		end
	end

	-- Set global channel colors
	for i = 1, 50 do
		ToggleChatColorNamesByClassGroup(true, "CHANNEL" .. i)
	end

	-- URL CLICK
	function formatURL(url)
	    url = "|cff".."149bfd".."|Hurl:"..url.."|h["..url.."]|h|r ";
	    return url;
	end

	-- derived from EasyUrl by jklaroe
	function makeClickable(self, event, msg, ...)
	    if string.find(msg, "(%a+)://(%S+)%s?") then
	        return false, string.gsub(msg, "(%a+)://(%S+)%s?", formatURL("%1://%2")), ...
	    end

	    if string.find(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?") then
	        return false, string.gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", formatURL("www.%1.%2")), ...
	    end

	    if string.find(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?") then
	        return false, string.gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", formatURL("%1@%2%3%4")), ...
	    end

	    if string.find(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?") then
	        return false, string.gsub(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?", formatURL("%1.%2.%3.%4:%5")), ...
	    end

	    if string.find(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?") then
	        return false, string.gsub(msg, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", formatURL("%1.%2.%3.%4")), ...
	    end
	end

	StaticPopupDialogs["CLICK_LINK_CLICKURL"] = {
	    text = "Copy/Paste the link into your browser",
	    button1 = "Close",
	    OnAccept = function()
	    end,
	    timeout = 0,
	    whileDead = true,
	    hideOnEscape = true,
	    preferredIndex = 3, 
	    OnShow = function (self, data)
	    self.editBox:SetText(data.url)
	    self.editBox:HighlightText()
	    end,
	    hasEditBox = true
	}

	local SetItemRef_orig = SetItemRef;
	function ClickURL_SetItemRef(link, text, button)
	    if (string.sub(link, 1, 3) == "url") then
	        local url = string.sub(link, 5);
	        local d = {}
	        d.url = url
	        StaticPopup_Show("CLICK_LINK_CLICKURL", "", "", d)
	    else
	        SetItemRef_orig(link, text, button);
	    end
	end
	SetItemRef = ClickURL_SetItemRef;

	ChatFrame_AddMessageEventFilter("CHAT_MSG_COMMUNITIES_CHANNEL", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", makeClickable)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN", makeClickable)
end

function Interface:CastBars()
	local max = math.max
	local format = string.format

	if not InCombatLockdown() then

		-- -- Channels Ticks

		-- local sparkfactory = {
		-- 	__index = function(t,k)
		-- 		local spark = CastingBarFrame:CreateTexture(nil, 'OVERLAY')
		-- 		t[k] = spark
		-- 		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		-- 		spark:SetVertexColor(1, 1, 1, 1)
		-- 		spark:SetBlendMode('ADD')
		-- 		spark:SetWidth(10)
		-- 		spark:SetHeight(15*2.2)
		-- 		return spark
		-- 	end
		-- }
		-- local barticks = setmetatable({}, sparkfactory)

		-- local function setBarTicks(ticknum)
		-- 	if( ticknum and ticknum > 0) then
		-- 		local delta = ( CastingBarFrame:GetWidth() / ticknum )
		-- 		for k = 1,ticknum do
		-- 			local t = barticks[k]
		-- 			t:ClearAllPoints()
		-- 			t:SetPoint("CENTER", CastingBarFrame, "LEFT", delta * k, 0 )
		-- 			t:Show()
		-- 		end
		-- 	else
		-- 		barticks[1].Hide = nil
		-- 		for i=1,#barticks do
		-- 			barticks[i]:Hide()
		-- 		end
		-- 	end
		-- end

		-- -- TODO: this will need updates for Cataclysm
		-- local channelingTicks = {
		-- 	-- warlock
		-- 	[GetSpellInfo(198590)] = 5, -- drain soul
		-- 	[GetSpellInfo(234153)] = 5, -- drain life
		-- 	-- druid
		-- 	[GetSpellInfo(740)] = 4, -- Tranquility
		-- 	-- priest
		-- 	[GetSpellInfo(15407)] = 3, -- mind flay
		-- 	[GetSpellInfo(48045)] = 5, -- mind sear
		-- 	[GetSpellInfo(47540)] = 2, -- penance
		-- 	-- mage
		-- 	[GetSpellInfo(5143)] = 5, -- arcane missiles
		-- 	[GetSpellInfo(12051)] = 4, -- evocation
		-- }

		-- local function getChannelingTicks(spell)			
		-- 	return channelingTicks[spell] or 0
		-- end

		-- local function isTalentSelected(class, spec, talentID)
		-- 	local specIndex = GetSpecialization()
		-- 	local _, className = UnitClass("player")
		-- 	if className == class and specIndex == spec then 
		-- 		local _, _, _, selected = GetTalentInfoByID(talentID, specIndex)
		-- 		if selected then
		-- 			return true
		-- 		else
		-- 			return false
		-- 		end
		-- 	end
		-- end

		-- local frame = CreateFrame("Frame", "ChannelTicks", UIParent)

		-- frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		-- frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
		-- frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		-- frame:RegisterEvent("UNIT_SPELLCAST_START")
		-- frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		-- frame:RegisterEvent("PLAYER_TALENT_UPDATE")		

		-- frame:SetScript("OnEvent", function(self, event, ...)
		-- 	if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TALENT_UPDATE" then
		-- 		if isTalentSelected("PRIEST", 1, 19752) then
		-- 			channelingTicks[GetSpellInfo(47540)] = 3
		-- 		else
		-- 			channelingTicks[GetSpellInfo(47540)] = 2
		-- 		end
		-- 	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
		-- 		local unit = ...
		-- 		if unit == "player" then
		-- 			local spell = UnitChannelInfo(unit)
		-- 			CastingBarFrame.channelingTicks = getChannelingTicks(spell)
		-- 			setBarTicks(CastingBarFrame.channelingTicks)
		-- 		end
		-- 	elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
		-- 		local unit = ...
		-- 		if unit == "player" then
		-- 			setBarTicks(0)
		-- 		end
		-- 	end
		-- end)

		UIPARENT_MANAGED_FRAME_POSITIONS["CastingBarFrame"] = nil

		-- Player Castbar
		CastingBarFrame:SetMovable(true)
		CastingBarFrame:ClearAllPoints()
		CastingBarFrame:SetScale(1)
		CastingBarFrame:SetPoint("BOTTOM", UIParent,"BOTTOM", 0, Interface.settings.CastBars.player.y)
		CastingBarFrame:SetUserPlaced(true)
		CastingBarFrame:SetMovable(false)
		CastingBarFrame:SetScale(1)

 		CastingBarFrame.Icon:Show()
		CastingBarFrame.Icon:ClearAllPoints()
		CastingBarFrame.Icon:SetSize(22, 22)
    	CastingBarFrame.Icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -7, 0)

  		CastingBarFrame.Text:ClearAllPoints()
  		CastingBarFrame.Text:SetPoint("CENTER", 0, 1)

  		CastingBarFrame.BorderShield:SetWidth(CastingBarFrame.BorderShield:GetWidth() + 4)
  		CastingBarFrame.BorderShield:SetPoint("TOP", 0, 26)
  		CastingBarFrame.Border:SetPoint("TOP", 0, 26)
 		CastingBarFrame.Flash:SetPoint("TOP", 0, 26)

 		-- Player Timer
		CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
		CastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT, 14,'THINOUTLINE')
		CastingBarFrame.timer:SetPoint("LEFT", CastingBarFrame, "RIGHT", 7, 0)
		CastingBarFrame.update = 0.1

		-- Target Castbar
		TargetFrameSpellBar:SetScale(1.1)
		TargetFrameSpellBar.Icon:SetTexCoord(.08, .92, .08, .92)
  		TargetFrameSpellBar.Icon:SetPoint("RIGHT", TargetFrameSpellBar, "LEFT", -3, 0)

		-- Target Timer
		TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
		TargetFrameSpellBar.timer:SetFont(STANDARD_TEXT_FONT, 11,'THINOUTLINE')
		TargetFrameSpellBar.timer:SetPoint("LEFT", TargetFrameSpellBar, "RIGHT", 4, 0)
		TargetFrameSpellBar.update = 0.1

	end

	-- CastBar timer function
	local function CastingBarFrame_OnUpdate_Hook(self, elapsed)
		if not self.timer then return end
		if self.update and self.update < elapsed then
			if self.casting then
				self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
			elseif self.channeling then
				self.timer:SetText(format("%.1f", max(self.value, 0)))
			else
				self.timer:SetText("")
			end
			self.update = .1
		  else
			self.update = self.update - elapsed
		end
	end

	CastingBarFrame:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
	TargetFrameSpellBar:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
end

function Interface:Minimap()

	-- GarrisonLandingPageMinimapButton:SetScript("OnMouseUp", function(self, button)
	-- 	if button == "RightButton" then
	-- 		if (GarrisonLandingPage and GarrisonLandingPage:IsShown()) then
	-- 			HideUIPanel(GarrisonLandingPage);
	-- 			print("test")
	-- 		else
	-- 			ShowGarrisonLandingPage(LE_GARRISON_TYPE_6_0)
	-- 		end
	-- 	end	
	-- end)

	MinimapBorderTop:Hide()	
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	MiniMapWorldMapButton:Hide()
	MinimapZoneText:SetPoint("CENTER", Minimap, 0, 80)
	MinimapCluster:SetScale(1.2)
	GameTimeFrame:Hide()
	GameTimeFrame:UnregisterAllEvents()
	GameTimeFrame.Show = kill
	MiniMapTracking:Hide()
	MiniMapTracking.Show = kill
	MiniMapTracking:UnregisterAllEvents()
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(self, z)
		local c = Minimap:GetZoom()
		if(z > 0 and c < 5) then
			Minimap:SetZoom(c + 1)
		elseif(z < 0 and c > 0) then
			Minimap:SetZoom(c - 1)
		end
	end)
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			_G.ToggleDropDownMenu(1, nil, _G.MiniMapTrackingDropDown, self)
		elseif btn == "MiddleButton" then
			_G.GameTimeFrame:Click()
		else
			_G.Minimap_OnClick(self)
		end
	end)
end

function Interface:Buffs()

	-- buff frame settings

	local buffFrame = {
	    pos                 = { a1 = "TOPRIGHT", af = "MinimapCluster", a2 = "TOPLEFT", x = 0, y = -20 },
	    gap                 = 30, --gap between buff and debuff rows
	    userplaced          = true, --want to place the bar somewhere else?
	    rowSpacing          = 12,
	    colSpacing          = 7,
	    buttonsPerRow       = 10,
	    button = {
	      size              = 45,
	    },

	    icon = {
	      padding           = -2,
	    },

	    border = {
	      texture           = "Interface\\AddOns\\JokUI\\media\\textures\\gloss",
	      color             = { r = 0.4, g = 0.35, b = 0.35, },
	      classcolored      = false,
	    },

	    background = {
	      show              = false,   --show backdrop
	      edgeFile          = "Interface\\AddOns\\JokUI\\media\\textures\\outer_shadow",
	      color             = { r = 0, g = 0, b = 0, a = 0.9},
	      classcolored      = false,
	      inset             = 6,
	      padding           = 2,
	    },

	    duration = {
	      font              = STANDARD_TEXT_FONT,
	      size              = 13,
	      pos               = { a1 = "BOTTOM", x = 0, y = -13 },
	    },

	    count = {
	      font              = STANDARD_TEXT_FONT,
	      size              = 11,
	      pos               = { a1 = "TOPRIGHT", x = 0, y = 0 },
	    },
	}
	  
	-- debuff frame settings

	local debuffFrame = {    
		pos             = { a1 = "TOPRIGHT", af = "MinimapCluster", a2 = "TOPLEFT", x = 0, y = -105 },
	    gap                 = 10, --gap between buff and debuff rows
	    userplaced          = true, --want to place the bar somewhere else?
	    rowSpacing          = 10,
	    colSpacing          = 7,
	    buttonsPerRow       = 10,

	    button = {
	      size              = 50,
	    },

	    icon = {
	      padding           = -2,
	    },

	    border = {
	      texture           = "Interface\\AddOns\\JokUI\\media\\textures\\gloss",
	      color             = { r = 0.4, g = 0.35, b = 0.35, },
	      classcolored      = false,
	    },

	    background = {
	      show              = true,   --show backdrop
	      edgeFile          = "Interface\\AddOns\\JokUI\\media\\textures\\outer_shadow",
	      color             = { r = 0, g = 0, b = 0, a = 0.9},
	      classcolored      = false,
	      inset             = 6,
	      padding           = 4,
	    },

	    duration = {
	      font              = STANDARD_TEXT_FONT,
	      size              = 13,
	      pos               = { a1 = "BOTTOM", x = 0, y = -13 },
	    },

	    count = {
	      font              = STANDARD_TEXT_FONT,
	      size              = 11,
	      pos               = { a1 = "TOPRIGHT", x = 0, y = 0 },
	    },
	}

	--rewrite the oneletter shortcuts

	HOUR_ONELETTER_ABBR = "%dh"
	DAY_ONELETTER_ABBR = "%dd"
	MINUTE_ONELETTER_ABBR = "%dm"
	--SECOND_ONELETTER_ABBR = "%ds"

	--backdrop debuff

	local backdropDebuff = {
	    bgFile = nil,
	    edgeFile = debuffFrame.background.edgeFile,
	    tile = false,
	    tileSize = 32,
	    edgeSize = debuffFrame.background.inset,
	    insets = {
	      left = debuffFrame.background.inset,
	      right = debuffFrame.background.inset,
	      top = debuffFrame.background.inset,
	      bottom = debuffFrame.background.inset,
	    },
	}

	--backdrop buff

	local backdropBuff = {
	    bgFile = nil,
	    edgeFile = buffFrame.background.edgeFile,
	    tile = false,
	    tileSize = 32,
	    edgeSize = buffFrame.background.inset,
	    insets = {
	      left = buffFrame.background.inset,
	      right = buffFrame.background.inset,
	      top = buffFrame.background.inset,
	      bottom = buffFrame.background.inset,
	    },
	}

	local ceil, min, max = ceil, min, max
	local buffFrameHeight = 0

	--apply aura frame texture func

	local function applySkin(b)
	    if not b or (b and b.styled) then return end

	    local name = b:GetName()

	    local tempenchant, consolidated, debuff, buff = false, false, false, false
	    if (name:match("TempEnchant")) then
	      tempenchant = true
	    elseif (name:match("Consolidated")) then
	      consolidated = true
	    elseif (name:match("Debuff")) then
	      debuff = true
	    else
	      buff = true
	    end

	    local cfg, backdrop
	    if debuff then
	      cfg = debuffFrame
	      backdrop = backdropDebuff
	    else
	      cfg = buffFrame
	      backdrop = backdropBuff
	    end

	--check class coloring options

	    --button
	    b:SetSize(buffFrame.button.size, buffFrame.button.size)

	    --icon
	    local icon = _G[name.."Icon"]
	    if consolidated then
	    if select(1,UnitFactionGroup("player")) == "Alliance" then  
	        icon:SetTexture(select(3,GetSpellInfo(61573)))
	    elseif select(1,UnitFactionGroup("player")) == "Horde" then
	    icon:SetTexture(select(3,GetSpellInfo(61574)))
	    end
	    end
	    icon:SetTexCoord(0.1,0.9,0.1,0.9)
	    icon:ClearAllPoints()
	    icon:SetPoint("TOPLEFT", b, "TOPLEFT", -buffFrame.icon.padding, buffFrame.icon.padding)
	    icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", buffFrame.icon.padding, -buffFrame.icon.padding)
	    icon:SetDrawLayer("BACKGROUND",-8)
	    b.icon = icon

	    --border
	    local border = _G[name.."Border"] or b:CreateTexture(name.."Border", "BACKGROUND", nil, -7)
	    border:SetTexture(border.texture)
	    border:SetTexCoord(0,1,0,1)
	    border:SetDrawLayer("BACKGROUND",-7)
	    if tempenchant then
	      border:SetVertexColor(0.7,0,1)
	    elseif not debuff then
	      border:SetVertexColor(buffFrame.border.color.r,buffFrame.border.color.g,buffFrame.border.color.b)
	    end
	    border:ClearAllPoints()
	    border:SetAllPoints(b)
	    b.border = border

	    --duration
	    b.duration:SetFont(buffFrame.duration.font, buffFrame.duration.size, "THINOUTLINE")
	    b.duration:ClearAllPoints()
	    b.duration:SetPoint(buffFrame.duration.pos.a1,buffFrame.duration.pos.x,buffFrame.duration.pos.y)

	    --count
	    b.count:SetFont(buffFrame.count.font, buffFrame.count.size, "THINOUTLINE")
	    b.count:ClearAllPoints()
	    b.count:SetPoint(buffFrame.count.pos.a1,buffFrame.count.pos.x,buffFrame.count.pos.y)

	    --shadow
	    if not buffFrame.background.show then
	      local back = CreateFrame("Frame", nil, b)
	      back:SetPoint("TOPLEFT", b, "TOPLEFT", -buffFrame.background.padding, buffFrame.background.padding)
	      back:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", buffFrame.background.padding, -buffFrame.background.padding)
	      back:SetFrameLevel(b:GetFrameLevel() - 1)
	      back:SetBackdrop(backdrop)
	      back:SetBackdropBorderColor(buffFrame.background.color.r,buffFrame.background.color.g,buffFrame.background.color.b,buffFrame.background.color.a)
	      b.bg = back
	    end

	    --set button styled variable
	    b.styled = true
	end

	--update debuff anchors

	local function updateDebuffAnchors(buttonName,index)
	    local button = _G[buttonName..index]
	    if not button then return end
	    --apply skin
	    if not button.styled then applySkin(button) end
	    --position button
	    button:ClearAllPoints()
	    if index == 1 then
	        --debuffs and buffs are not combined anchor the debuffs to its own frame
	        button:SetPoint("TOPRIGHT", rBFS_DebuffDragFrame, "TOPRIGHT", 0, -60)      
	    elseif index > 1 and mod(index, debuffFrame.buttonsPerRow) == 1 then
	      button:SetPoint("TOPRIGHT", _G[buttonName..(index-debuffFrame.buttonsPerRow)], "BOTTOMRIGHT", 0, -debuffFrame.rowSpacing)
	    else
	      button:SetPoint("TOPRIGHT", _G[buttonName..(index-1)], "TOPLEFT", -debuffFrame.colSpacing, 0)
	    end
	end

	--update buff anchors

	local function updateAllBuffAnchors()
	    --variables
	    local buttonName  = "BuffButton"
	    local numEnchants = BuffFrame.numEnchants
	    local numBuffs    = BUFF_ACTUAL_DISPLAY
	    local offset      = numEnchants
	    local realIndex, previousButton, aboveButton

	      TempEnchant1:ClearAllPoints()
	      TempEnchant1:SetPoint("TOPRIGHT", rBFS_BuffDragFrame, "TOPRIGHT", 0, 0)
	    
	    --calculate the previous button in case tempenchant or consolidated buff are loaded
	    if BuffFrame.numEnchants > 0 then
	      previousButton = _G["TempEnchant"..numEnchants]
	    end

	    if numEnchants > 0 then
	      aboveButton = TempEnchant1
	    end

	    --loop on all active buff buttons
	    local buffCounter = 0
	    for index = 1, numBuffs do
	      local button = _G[buttonName..index]
	      if not button then return end
	      if not button.consolidated then
	        buffCounter = buffCounter + 1
	        --apply skin
	        if not button.styled then applySkin(button) end
	        --position button
	        button:ClearAllPoints()
	        realIndex = buffCounter+offset
	        if realIndex == 1 then
	          button:SetPoint("TOPRIGHT", rBFS_BuffDragFrame, "TOPRIGHT", 0, 0)
	          aboveButton = button
	        elseif realIndex > 1 and mod(realIndex, buffFrame.buttonsPerRow) == 1 then
	          button:SetPoint("TOPRIGHT", aboveButton, "BOTTOMRIGHT", 0, -buffFrame.rowSpacing)
	          aboveButton = button
	        else
	          button:SetPoint("TOPRIGHT", previousButton, "TOPLEFT", -buffFrame.colSpacing, 0)
	        end
	        previousButton = button
	        
	      end
	    end
	    --calculate the height of the buff rows for the debuff frame calculation later
	    local rows = ceil((buffCounter+offset)/buffFrame.buttonsPerRow)
	    local height = buffFrame.button.size*rows + buffFrame.rowSpacing*rows + buffFrame.gap*min(1,rows)
	    buffFrameHeight = height
	end

	--buff drag frame

	local bf = CreateFrame("Frame", "rBFS_BuffDragFrame", UIParent)
	bf:SetSize(buffFrame.button.size,buffFrame.button.size)
	bf:SetPoint(buffFrame.pos.a1,buffFrame.pos.af,buffFrame.pos.a2,buffFrame.pos.x,buffFrame.pos.y)

	--debuff drag frame

	local df = CreateFrame("Frame", "rBFS_DebuffDragFrame", UIParent)
	df:SetSize(debuffFrame.button.size,debuffFrame.button.size)
	df:SetPoint(debuffFrame.pos.a1,debuffFrame.pos.af,debuffFrame.pos.a2,debuffFrame.pos.x,debuffFrame.pos.y)

	  --temp enchant stuff
	applySkin(TempEnchant1)
	applySkin(TempEnchant2)
	applySkin(TempEnchant3)

	  --position the temp enchant buttons
	TempEnchant1:ClearAllPoints()
	TempEnchant1:SetPoint("TOPRIGHT", rBFS_BuffDragFrame, "TOPRIGHT", 0, 0) --button will be repositioned later in case temp enchant and consolidated buffs are both available
	TempEnchant2:ClearAllPoints()
	TempEnchant2:SetPoint("TOPRIGHT", TempEnchant1, "TOPLEFT", -buffFrame.colSpacing, 0)
	TempEnchant3:ClearAllPoints()
	TempEnchant3:SetPoint("TOPRIGHT", TempEnchant2, "TOPLEFT", -buffFrame.colSpacing, 0)
	  
	  --hook Blizzard functions
	hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", updateAllBuffAnchors)
	hooksecurefunc("DebuffButton_UpdateAnchors", updateDebuffAnchors)
end

function Interface:ReAnchor()

  	-- ETC
  	VerticalMultiBarsContainer:SetPoint("TOP", MinimapCluster, "BOTTOM", -2, -58)
  	MicroButtonAndBagsBar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 5, -4)

  	for i,v in pairs({
		MainMenuBarBackpackButton,
  		CharacterBag0Slot,
  		CharacterBag1Slot,
  		CharacterBag2Slot,
  		CharacterBag3Slot,
  		MicroButtonAndBagsBar.MicroBagBar,
	}) do
        v:Hide()
	end	 	
end

function Interface:AutoQuest()

	----------------------------------------------------------------------
	--	Automate quests
	----------------------------------------------------------------------

	-- Function to show quest dialog for popup quests in the objective tracker
	local function PopupQuestComplete()
		if GetNumAutoQuestPopUps() > 0 then
			local questId, questType = GetAutoQuestPopUp(1)
			if questType == "COMPLETE" then
				local index = GetQuestLogIndexByID(questId)
				ShowQuestComplete(index)
			end
		end
	end

	-- Funcion to ignore specific NPCs
	local function isNpcBlocked(actionType)
		local npcGuid = UnitGUID("target") or nil
		if npcGuid then
			local void, void, void, void, void, npcID = strsplit("-", npcGuid)
			if npcID then
				-- Ignore specific NPCs for selecting, accepting and turning-in quests (required if automation has consequences)
				if npcID == "45400" 	-- Fiona's Caravan (Eastern Plaguelands)
				or npcID == "18166" 	-- Khadgar (Allegiance to Aldor/Scryer, Shattrath)
				or npcID == "114719" 	-- Trader Caelen (Obliterum Forge, Dalaran, Broken Isles)
				or npcID == "6294" 		-- Krom Stoutarm (Heirloom Curator, Ironforge)
				or npcID == "6566" 		-- Estelle Gendry (Heirloom Curator, Undercity)
				then
					return true
				end
				-- Ignore specific NPCs for selecting quests only (required if incomplete quest turn-ins are selected automatically)
				if actionType == "Select" then
					if npcID == "15192" 	-- Anachronos (Caverns of Time)
					or npcID == "111243" 	-- Archmage Lan'dalock (Seal quest, Dalaran)
					or npcID == "119388" 	-- Chieftain Hatuun (Krokul Hovel, Krokuun)
					or npcID == "87391" 	-- Fate-Twister Seress (Seal quest, Stormshield)
					or npcID == "88570"		-- Fate-Twister Tiklal (Seal quest, Horde)
					or npcID == "87706" 	-- Gazmolf Futzwangler (Reputation quests, Nagrand, Draenor)
					or npcID == "55402" 	-- Korgol Crushskull (Darkmoon Faire, Pit Master)
					or npcID == "70022" 	-- Ku'ma (Isle of Giants, Pandaria)
					or npcID == "12944" 	-- Lokhtos Darkbargainer (Thorium Brotherhood, Blackrock Depths)
					or npcID == "109227" 	-- Meliah Grayfeather (Tradewind Roost, Highmountain)
					or npcID == "99183" 	-- Renegade Ironworker (Tanaan Jungle, repeatable quest)
					or npcID == "87393" 	-- Sallee Silverclamp (Reputation quests, Nagrand, Draenor)
					then
						return true
					end
				end
			end
		end
	end

	-- Function to check if quest requires currency
	local function QuestRequiresCurrency()
		for i = 1, 6 do
			local progItem = _G["QuestProgressItem" ..i] or nil
			if progItem and progItem:IsShown() and progItem.type == "required" and progItem.objectType == "currency" then
				return true
			end
		end
	end

	-- Function to check if quest requires gold
	local function QuestRequiresGold()
		local goldRequiredAmount = GetQuestMoneyToGet()
		if goldRequiredAmount and goldRequiredAmount > 0 then
			return true
		end
	end

	-- Register events
	local qFrame = CreateFrame("FRAME")
	qFrame:RegisterEvent("QUEST_DETAIL")
	qFrame:RegisterEvent("QUEST_ACCEPT_CONFIRM")
	qFrame:RegisterEvent("QUEST_PROGRESS")
	qFrame:RegisterEvent("QUEST_COMPLETE")
	qFrame:RegisterEvent("QUEST_GREETING")
	qFrame:RegisterEvent("QUEST_AUTOCOMPLETE")
	qFrame:RegisterEvent("GOSSIP_SHOW")
	qFrame:RegisterEvent("QUEST_FINISHED")
	qFrame:SetScript("OnEvent", function(self, event)

		-- Clear progress items when quest interaction has ceased
		if event == "QUEST_FINISHED" then
			for i = 1, 6 do
				local progItem = _G["QuestProgressItem" ..i] or nil
				if progItem and progItem:IsShown() then
					progItem:Hide()
				end
			end
			return
		end

		-- Do nothing if SHIFT key is being held
		if IsShiftKeyDown() then return end

		----------------------------------------------------------------------
		-- Accept quests automatically
		----------------------------------------------------------------------

		-- Accept quests with a quest detail window
		if event == "QUEST_DETAIL" then
			-- Don't accept blocked quests
			if isNpcBlocked("Accept") then return end
			-- Accept quest
			if QuestGetAutoAccept() then
				-- Quest has already been accepted by Wow so close the quest detail window
				CloseQuest()
			else
				-- Quest has not been accepted by Wow so accept it
				AcceptQuest()
				HideUIPanel(QuestFrame)
			end
		end

		-- Accept quests which require confirmation (such as sharing escort quests)
		if event == "QUEST_ACCEPT_CONFIRM" then
			ConfirmAcceptQuest() 
			StaticPopup_Hide("QUEST_ACCEPT")
		end

		----------------------------------------------------------------------
		-- Turn-in quests automatically
		----------------------------------------------------------------------

		-- Turn-in progression quests
		if event == "QUEST_PROGRESS" and IsQuestCompletable() then
			-- Don't continue quests for blocked NPCs
			if isNpcBlocked("Complete") then return end
			-- Don't continue if quest requires currency
			if QuestRequiresCurrency() then return end
			-- Don't continue if quest requires gold
			if QuestRequiresGold() then return end
			-- Continue quest
			CompleteQuest()
		end

		-- Turn in completed quests if only one reward item is being offered
		if event == "QUEST_COMPLETE" then
			-- Don't complete quests for blocked NPCs
			if isNpcBlocked("Complete") then return end
			-- Don't complete if quest requires currency
			if QuestRequiresCurrency() then return end
			-- Don't complete if quest requires gold
			if QuestRequiresGold() then return end
			-- Complete quest
			if GetNumQuestChoices() <= 1 then
				GetQuestReward(GetNumQuestChoices())
			end
		end

		-- Show quest dialog for quests that use the objective tracker (it will be completed automatically)
		-- if event == "QUEST_AUTOCOMPLETE" then
		-- 	LeaPlusLC.PopupQuestTicker = C_Timer.NewTicker(0.25, PopupQuestComplete, 20)
		-- end

		----------------------------------------------------------------------
		-- Select quests automatically
		----------------------------------------------------------------------

		if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then

			-- Select quests
			if UnitExists("npc") or QuestFrameGreetingPanel:IsShown() or GossipFrameGreetingPanel:IsShown() then

				-- Don't select quests for blocked NPCs
				if isNpcBlocked("Select") then return end

				-- Select quests
				if event == "QUEST_GREETING" then
					-- Quest greeting
					local availableCount = GetNumAvailableQuests() + GetNumActiveQuests()
					if availableCount >= 1 then
						for i = 1, availableCount do
							if _G["QuestTitleButton" .. i].isActive == 0 then
								-- Select available quests
								C_Timer.After(0.01, function() SelectAvailableQuest(_G["QuestTitleButton" .. i]:GetID()) end)
							else
								-- Select completed quests
								local void, isComplete = GetActiveTitle(i)
								if isComplete then
									SelectActiveQuest(_G["QuestTitleButton" .. i]:GetID())
								end
							end
						end
					end
				else
					-- Gossip frame
					local availableCount = GetNumGossipAvailableQuests() + GetNumGossipActiveQuests()
					if availableCount >= 1 then
						for i = 1, availableCount do
							if _G["GossipTitleButton" .. i].type == "Available" then
								-- Select available quests
								C_Timer.After(0.01, function() SelectGossipAvailableQuest(i) end)
							else
								-- Select completed quests
								local isComplete = select(i * 6 - 5 + 3, GetGossipActiveQuests()) -- 4th argument of 6 argument line
								if isComplete then
									if _G["GossipTitleButton" .. i].type == "Active" then
										SelectGossipActiveQuest(_G["GossipTitleButton" .. i]:GetID())
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end

function Interface:Mover()
	function Interface:CreateOwnHandleFrame(frame, width, height, offX, offY, name)
	 local handle = CreateFrame("Frame", "Moverhandle"..name)
	 handle:SetWidth(width)
	 handle:SetHeight(height)
	 handle:SetParent(frame)
	 handle:EnableMouse(true)
	 handle:SetMovable(true)
	 handle:SetPoint("TOPLEFT", frame ,"TOPLEFT", offX, offY)
	 return handle
	end

	local function OnDragStart(self)
	 local frameToMove = self.frameToMove
	 if frameToMove:IsMovable() then
	    frameToMove:StartMoving()
	    frameToMove.isMoving = true
	  end
	end

	local function OnDragStop(self)
	 local frameToMove = self.frameToMove
	 frameToMove:StopMovingOrSizing()
	 frameToMove.isMoving = false
	end

	function Interface:CreateQuestTrackerHandle()
	 local handle = CreateFrame("Frame", "MoverhandleQuestTracker")
	 handle:SetParent(ObjectiveTrackerFrame)
	 handle:EnableMouse(true)
	 handle:SetMovable(true)
	 handle:SetAllPoints(ObjectiveTrackerFrame.HeaderMenu.Title)

	 ObjectiveTrackerFrame.BlocksFrame.QuestHeader:EnableMouse(true)
	 ObjectiveTrackerFrame.BlocksFrame.AchievementHeader:EnableMouse(true)
	 ObjectiveTrackerFrame.BlocksFrame.ScenarioHeader:EnableMouse(true)
	 return handle
	end

	function Interface:SetMoveHandle(frameToMove, handle)
	 if not frameToMove then
	  return
	 end
	 if not handle then handle = frameToMove end
	 handle.frameToMove = frameToMove

	 if not frameToMove.EnableMouse then return end
	 frameToMove:SetMovable(true)
	 handle:RegisterForDrag("LeftButton");

	 handle:SetScript("OnDragStart", OnDragStart)
	 handle:SetScript("OnDragStop", OnDragStop)
	end

	local movableFrames = {
	 BankFrame,
	 DressUpFrame,
	 FriendsFrame,
	 GameMenuFrame,
	 GossipFrame,
	 HelpFrame,
	 InterfaceOptionsFrame,
	 LootFrame,
	 MailFrame,
	 MerchantFrame,
	 PVEFrame,
	 QuestFrame,
	 QuestLogPopupDetailFrame,
	 RaidBrowserFrame,
	 SpellBookFrame,
	 SUFWrapperFrame,
	 TradeFrame,
	 VideoOptionsFrame
	}

	local movableFramesWithhandle = {
	 ["CharacterFrame"] =  { PaperDollFrame, fff, ReputationFrame, TokenFrame , PetPaperDollFrameCompanionFrame, ReputationFrame } ,
	 ["ColorPickerFrame"] = { Interface:CreateOwnHandleFrame(ColorPickerFrame, 132, 32, 117, 8, "ColorPickerFrame") },
	 ["MailFrame"] = {SendMailFrame},
	 ["WorldMapFrame"] = { WorldMapFrame },
	}

	local movableFramesLoD = {
	 ["Blizzard_AchievementUI"] = function() Interface:SetMoveHandle(AchievementFrame, AchievementFrameHeader) end,
	 ["Blizzard_ArchaeologyUI"] = function() Interface:SetMoveHandle(ArchaeologyFrame) end,
	 ["Blizzard_AuctionUI"] = function() Interface:SetMoveHandle(AuctionFrame) end,
	 ["Blizzard_BarbershopUI"] = function() Interface:SetMoveHandle(BarberShopFrame) end,
	 ["Blizzard_BindingUI"] = function() Interface:SetMoveHandle(KeyBindingFrame) end,
	 ["Blizzard_Calendar"] = function() Interface:SetMoveHandle(CalendarFrame) end,
	 ["Blizzard_Collections"] = function() Interface:SetMoveHandle(CollectionsJournal); Interface:SetMoveHandle(WardrobeFrame) end,
	 ["Blizzard_EncounterJournal"] = function() Interface:SetMoveHandle(EncounterJournal, Interface:CreateOwnHandleFrame(EncounterJournal, 775, 20, 0, 0, "EncounterJournal")) end,
	 ["Blizzard_GarrisonUI"] = function() Interface:SetMoveHandle(GarrisonMissionFrame); Interface:SetMoveHandle(GarrisonCapacitiveDisplayFrame); Interface:SetMoveHandle(GarrisonLandingPage) end,
	 ["Blizzard_GuildBankUI"] = function() Interface:SetMoveHandle(GuildBankFrame) end,
	 ["Blizzard_Communities"] = function() Interface:SetMoveHandle(CommunitiesFrame) end,
	 ["Blizzard_InspectUI"] = function() Interface:SetMoveHandle(InspectFrame) end,
	 ["Blizzard_ItemAlterationUI"] = function() Interface:SetMoveHandle(TransmogrifyFrame) end,
	 ["Blizzard_ItemSocketingUI"] = function() Interface:SetMoveHandle(ItemSocketingFrame) end,
	 ["Blizzard_LookingForGuildUI"] = function() Interface:SetMoveHandle(LookingForGuildFrame) end,
	 ["Blizzard_MacroUI"] = function() Interface:SetMoveHandle(MacroFrame) end,
	 ["Blizzard_OrderHallUI"] = function() Interface:SetMoveHandle(OrderHallMissionFrame) end,
	 ["Blizzard_TalentUI"] = function()  Interface:SetMoveHandle(PlayerTalentFrame) end,
	 ["Blizzard_TrainerUI"] = function() Interface:SetMoveHandle(ClassTrainerFrame) end,
	 ["Blizzard_TradeSkillUI"] = function() Interface:SetMoveHandle(TradeSkillFrame) end,
	 ["Blizzard_VoidStorageUI"] = function() Interface:SetMoveHandle(VoidStorageFrame) end,
	 ["Blizzard_ObliterumUI"] = function() Interface:SetMoveHandle(ObliterumForgeFrame) end,
	}

	 -- ["Blizzard_ArtifactUI"]=function() DTweaks_Mover:SetMoveHandle(ArtifactFrame.ForgeBadgeFrame) end,
	 
	function movableFramesLoD:Interface()
	 for _, frame in pairs(movableFrames) do
	   Interface:SetMoveHandle(frame)
	 end

	 for frame, handles in pairs(movableFramesWithhandle) do
	   for index, handle in pairs(handles) do
	     Interface:SetMoveHandle(_G[frame],handle)
	   end
	 end
	end

	local frame = CreateFrame("Frame")
	frame:SetScript("OnEvent", ADDON_LOADED)
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(self, event, addonName)
		if movableFramesLoD[addonName] then movableFramesLoD[addonName]() end
		movableFramesLoD:Interface()
	end)
end