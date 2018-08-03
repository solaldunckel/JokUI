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
    		righttext = 16,
    		scale = 1.1,
    		enable = true, 
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
    	BossFrame = {"TOPLEFT", nil, "TOPLEFT", 1340, -300},
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
        	enable = {
				type = "toggle",
				name = "Enable",
				width = "full",
		        descStyle = "inline",
				order = 0,
				set = function(info,val) Interface.settings.UnitFrames.enable = val
				StaticPopup_Show ("ReloadUI_Popup")
				end,
				get = function(info) return Interface.settings.UnitFrames.enable end
			},
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
                end,
                get = function(info) return Interface.settings.UnitFrames.scale end
            },
            righttext = {
                type = "range",
                name = "Right Text",
                desc = "",
                min = 8,
                max = 20,
                step = 1,
                order = 2,
                set = function(info,val) 
                    Interface.settings.UnitFrames.righttext = val
                    StaticPopup_Show ("ReloadUI_Popup")
                end,
                get = function(info) return Interface.settings.UnitFrames.righttext end
            },			
        },
    },
    skinInterface = {
		type = "toggle",
		name = "Skin Interface",
		width = "full",
		desc = "|cffaaaaaa Skin Interface in Black |r",
        descStyle = "inline",
		order = 3,
		set = function(info,val) Interface.settings.SkinInterface = val
		StaticPopup_Show ("ReloadUI_Popup")
		end,
		get = function(info) return Interface.settings.SkinInterface end
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
	self:AfterEnable()
end

function Interface:AfterEnable()
	if Interface.settings.UnitFrames.enable then
		self:UnitFrames()
		self:PlayerFrame()
		self:TargetFrame()
	else
		self:ColorUnitFrames()
	end

	if Interface.settings.SkinInterface then
		self:Colors()
	end
	
	self:Chat()
	self:Minimap()
	self:Buffs()
	self:CastBars()
	self:ReAnchor()
	self:BossFrame()
	self:ActionBars()
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
	local unit = {}
	local AURA_START_X = 6;
	local AURA_START_Y = 28;
	local AURA_OFFSET_Y = 3;
	local AURA_OFFSET_X = 4;
	local LARGE_AURA_SIZE = 23
	local SMALL_AURA_SIZE = 20
	local AURA_ROW_WIDTH = 119;

	local function ClassColor(statusbar, unit)
		local _, class, c
		if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
			_, class = UnitClass(unit);
			c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
			statusbar:SetStatusBarColor(c.r, c.g, c.b);
		end
		if not UnitIsPlayer("target") then
			color = FACTION_BAR_COLORS[UnitReaction("target", "player")]
			if ( not UnitPlayerControlled("target") and UnitIsTapDenied("target") ) then
				TargetFrameHealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
			else
				if color then
					TargetFrameHealthBar:SetStatusBarColor(color.r, color.g, color.b)
					TargetFrameHealthBar.lockColor = true
				end
			end
		end
		if not UnitIsPlayer("focus") then
			color = FACTION_BAR_COLORS[UnitReaction("focus", "player")]
			if ( not UnitPlayerControlled("focus") and UnitIsTapDenied("focus") ) then
				FocusFrameHealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
			else
				if color then
					FocusFrameHealthBar:SetStatusBarColor(color.r, color.g, color.b)
					FocusFrameHealthBar.lockColor = true
				end
			end
		end
		if not UnitIsPlayer("targettarget") then
			color = FACTION_BAR_COLORS[UnitReaction("targettarget", "player")]
			if ( not UnitPlayerControlled("targettarget") and UnitIsTapDenied("targettarget") ) then
				TargetFrameToTHealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
			else
				if color then
					TargetFrameToTHealthBar:SetStatusBarColor(color.r, color.g, color.b)
					TargetFrameToTHealthBar.lockColor = true
				end
			end
		end
		if not UnitIsPlayer("focustarget") then
			color = FACTION_BAR_COLORS[UnitReaction("focustarget", "player")]
			if ( not UnitPlayerControlled("focustarget") and UnitIsTapDenied("focustarget") ) then
				FocusFrameToTHealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
			else
				if color then
					FocusFrameToTHealthBar:SetStatusBarColor(color.r, color.g, color.b)
					FocusFrameToTHealthBar.lockColor = true
				end
			end
		end
	end
	hooksecurefunc("UnitFrameHealthBar_Update", function(self)
		ClassColor(self, self.unit)
	end)

	hooksecurefunc("HealthBar_OnValueChanged", function(self)
		ClassColor(self, self.unit)
	end)

	-- hooksecurefunc("UnitFrameManaBar_UpdateType", function(manaBar)
	-- 	ClassColor(self, self.unit)
	--  end)

	TargetFrame:SetScale(Interface.settings.UnitFrames.scale)
	FocusFrame:SetScale(Interface.settings.UnitFrames.scale)

	function wPlayerFrame_ToPlayerArt(self)
		PlayerFrame:SetScale(Interface.settings.UnitFrames.scale)
		PlayerFrameTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame");
		PlayerStatusTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-Player-Status")
		PlayerName:SetPoint("CENTER", PlayerFrameHealthBar, 0, 23);
		PlayerFrameHealthBar:SetPoint("TOPLEFT",PlayerFrame, 106, -24);
		PlayerFrameHealthBar:SetHeight(26);
		PlayerFrameHealthBarTextLeft:SetPoint("LEFT", PlayerFrameHealthBar, "LEFT", 8, 0)
		PlayerFrameHealthBarTextRight:SetPoint("RIGHT", PlayerFrameHealthBar, "RIGHT", -5, 0)
		PlayerFrameHealthBarTextRight:SetFont(font, 14, "OUTLINE")
		PlayerFrameHealthBarText:SetPoint("CENTER", PlayerFrameHealthBar, "CENTER", 0, 0);
	end
	hooksecurefunc("PlayerFrame_ToPlayerArt", wPlayerFrame_ToPlayerArt)
	
	--TARGET
	function original_CheckClassification (self, forceNormalTexture)
		self.name:SetPoint("LEFT", self, 15, 36);
		self.deadText:ClearAllPoints();
		TargetFrameTextureFrameTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame")
		FocusFrameTextureFrameTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame")
		self.deadText:SetPoint("CENTER", self.healthbar, "CENTER",0,0);
		self.nameBackground:Hide();
		self.Background:SetSize(119,42);
		self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35);
		self.healthbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
		self.healthbar:SetSize(119, 26);
		self.healthbar:ClearAllPoints();
		self.healthbar:SetPoint("TOPLEFT", 5, -24);

		self.levelText:SetPoint("CENTER", self, "CENTER", 63, -17)
		
		self.healthbar.LeftText:ClearAllPoints();
		self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 6, 0);
		self.healthbar.RightText:ClearAllPoints();
		self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -5, 0);
		self.healthbar.RightText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Right Text Size
		self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0);

		self.manabar:ClearAllPoints();
		self.manabar:SetPoint("TOPLEFT", 5, -52);
		self.manabar:SetSize(119, 13);
		self.manabar.LeftText:ClearAllPoints();
		self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 8, 0);	
		self.manabar.RightText:ClearAllPoints();
		self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -5, 0);
		self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0);

		--TargetOfTarget
		TargetFrameToTHealthBar:ClearAllPoints()
		TargetFrameToTHealthBar:SetPoint("TOPLEFT", 44, -15)
		TargetFrameToTHealthBar:SetHeight(8)
		TargetFrameToTManaBar:ClearAllPoints()
		TargetFrameToTManaBar:SetPoint("TOPLEFT", 44, -24)
		TargetFrameToTManaBar:SetHeight(5)
		FocusFrameToTHealthBar:ClearAllPoints()
		FocusFrameToTHealthBar:SetPoint("TOPLEFT", 45, -15)
		FocusFrameToTHealthBar:SetHeight(8)
		FocusFrameToTManaBar:ClearAllPoints()
		FocusFrameToTManaBar:SetPoint("TOPLEFT", 45, -25)
		FocusFrameToTManaBar:SetHeight(3)
		FocusFrameToT.deadText:SetWidth(0.01)
	end
	hooksecurefunc("TargetFrame_CheckClassification", original_CheckClassification)

	function StyleVehicle(self, vehicleType)
		PlayerFrame.state = "vehicle"

		UnitFrame_SetUnit(self, "vehicle", PlayerFrameHealthBar, PlayerFrameManaBar)
		UnitFrame_SetUnit(PetFrame, "player", PetFrameHealthBar, PetFrameManaBar)
		PetFrame_Update(PetFrame)
		PlayerFrame_Update()
		BuffFrame_Update()
		ComboFrame_Update(ComboFrame)

		PlayerFrameTexture:Hide()
		if (vehicleType == "Natural") then
			PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic")
			PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic-Flash")
			PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86)
			PlayerFrameHealthBar:SetSize(103, 12)
			PlayerFrameHealthBar:SetPoint("TOPLEFT", 116, -41)
			PlayerFrameManaBar:SetSize(103, 12)
			PlayerFrameManaBar:SetPoint("TOPLEFT", 116, -52)
		else
			PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame")
			PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash")
			PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86)
			PlayerFrameHealthBar:SetSize(100, 12)
			PlayerFrameHealthBar:SetPoint("TOPLEFT", 119, -41)
			PlayerFrameManaBar:SetSize(100, 12)
			PlayerFrameManaBar:SetPoint("TOPLEFT", 119, -52)
		end
		PlayerFrame_ShowVehicleTexture()

		PlayerName:SetPoint("CENTER", 50, 23)
		PlayerLeaderIcon:SetPoint("TOPLEFT", 40, -12)
		PlayerFrameGroupIndicator:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 97, -13)

		PlayerFrameBackground:SetWidth(114)
		PlayerLevelText:Hide()
	end
	hooksecurefunc("PlayerFrame_ToVehicleArt", StyleVehicle)
		
	--BUFFS
	function unit:targetUpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
		local size
		local offsetY = AURA_OFFSET_Y
		local offsetX = AURA_OFFSET_X
		local rowWidth = 0
		local maxRowWidth = AURA_ROW_WIDTH
		local firstBuffOnRow = 1
		for i=1, numAuras do
			if ( largeAuraList[i] ) then
				size = LARGE_AURA_SIZE
				offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y
			else
				size = SMALL_AURA_SIZE
			end
			if ( i == 1 ) then
				rowWidth = size
				self.auraRows = self.auraRows + 1
			else
				rowWidth = rowWidth + size + offsetX
			end
			if ( rowWidth > maxRowWidth ) then
				updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY, mirrorAurasVertically)
				rowWidth = size
				self.auraRows = self.auraRows + 1
				firstBuffOnRow = i
				offsetY = AURA_OFFSET_Y
			else
				updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically)
			end
		end
	end

	local function unit_targetUpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
		unit:targetUpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
	end
	hooksecurefunc("TargetFrame_UpdateAuraPositions", unit_targetUpdateAuraPositions)

	function unit:targetUpdateBuffAnchor(self, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
		local point, relativePoint
		local startY, auraOffsetY
		if ( mirrorVertically ) then
			point = "BOTTOM"
			relativePoint = "TOP"
			startY = -6
			offsetY = -offsetY
			auraOffsetY = -AURA_OFFSET_Y
		else
			point = "TOP"
			relativePoint="BOTTOM"
			startY = AURA_START_Y
			auraOffsetY = AURA_OFFSET_Y
		end
		 
		local buff = _G[buffName..index]
		if ( index == 1 ) then
			if ( UnitIsFriend("player", self.unit) or numDebuffs == 0 ) then
				-- unit is friendly or there are no debuffs...buffs start on top
				buff:SetPoint(point.."LEFT", self, relativePoint.."LEFT", AURA_START_X, startY)		   
			else
				-- unit is not friendly and we have debuffs...buffs start on bottom
				buff:SetPoint(point.."LEFT", self.debuffs, relativePoint.."LEFT", 0, -offsetY)
			end
			self.buffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0)
			self.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY)
			self.spellbarAnchor = buff
		elseif ( anchorIndex ~= (index-1) ) then
			-- anchor index is not the previous index...must be a new row
			buff:SetPoint(point.."LEFT", _G[buffName..anchorIndex], relativePoint.."LEFT", 0, -offsetY)
			self.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY)
			self.spellbarAnchor = buff
		else
			-- anchor index is the previous index
			buff:SetPoint(point.."LEFT", _G[buffName..anchorIndex], point.."RIGHT", offsetX, 0)
		end

		buff:SetWidth(size)
		buff:SetHeight(size)
	end

	local function unit_targetUpdateBuffAnchor(self, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
		unit:targetUpdateBuffAnchor(self, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	end
	hooksecurefunc("TargetFrame_UpdateBuffAnchor", unit_targetUpdateBuffAnchor)

	function unit:targetUpdateDebuffAnchor(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
		local buff = _G[debuffName..index];
		local isFriend = UnitIsFriend("player", self.unit);
		 
		--For mirroring vertically
		local point, relativePoint;
		local startY, auraOffsetY;
		if ( mirrorVertically ) then
			point = "BOTTOM";
			relativePoint = "TOP";
			startY = -8;
			offsetY = - offsetY;
			auraOffsetY = -AURA_OFFSET_Y;
		else
			point = "TOP";
			relativePoint="BOTTOM";
			startY = AURA_START_Y;
			auraOffsetY = AURA_OFFSET_Y;
		end
		 
		if ( index == 1 ) then
			if ( isFriend and numBuffs > 0 ) then
				-- unit is friendly and there are buffs...debuffs start on bottom
				buff:SetPoint(point.."LEFT", self.buffs, relativePoint.."LEFT", 0, -offsetY);
			else
				-- unit is not friendly or there are no buffs...debuffs start on top
				buff:SetPoint(point.."LEFT", self, relativePoint.."LEFT", AURA_START_X, startY);
			end
			self.debuffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
			self.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
			if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
				self.spellbarAnchor = buff;
			end
		elseif ( anchorIndex ~= (index-1) ) then
			-- anchor index is not the previous index...must be a new row
			buff:SetPoint(point.."LEFT", _G[debuffName..anchorIndex], relativePoint.."LEFT", 0, -offsetY);
			self.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
			if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
				self.spellbarAnchor = buff;
			end
		else
			-- anchor index is the previous index
			buff:SetPoint(point.."LEFT", _G[debuffName..(index-1)], point.."RIGHT", offsetX, 0);
		end
	 
		-- Resize
		buff:SetWidth(size);
		buff:SetHeight(size);
		local debuffFrame =_G[debuffName..index.."Border"];
		debuffFrame:SetWidth(size+2);
		debuffFrame:SetHeight(size+2);
	end

	local function unit_targetUpdateDebuffAnchor(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
		unit:targetUpdateDebuffAnchor(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	end
	hooksecurefunc("TargetFrame_UpdateDebuffAnchor", unit_targetUpdateDebuffAnchor)

	--backdrop

    local backdrop = {
		bgFile = nil,
		edgeFile = "Interface\\AddOns\\JokUI\\media\\textures\\outer_shadow",
		tile = false,
		tileSize = 32,
		edgeSize = 4,
		insets = {
			left = 4,
			right = 4,
			top = 4,
			bottom = 4,
		},
    }

	-- apply aura frame texture func

    local function applySkin(b)
		if not b or (b and b.styled) then return end
		--button name
		local name = b:GetName()
		if (name:match("Debuff")) then
			b.debuff = true
	   	else
	   		b.buff = true
		end
		--icon
		local icon = _G[name.."Icon"]
		icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		icon:SetDrawLayer("BACKGROUND",-7)
		b.icon = icon
		--border
		local border = _G[name.."Border"] or b:CreateTexture(name.."Border", "BACKGROUND", nil, -7)
		border:SetTexture("Interface\\AddOns\\JokUI\\media\\textures\\gloss")
		border:SetTexCoord(0, 1, 0, 1)
		border:SetDrawLayer("BACKGROUND",- 7)
		if b.buff then
			border:SetAlpha(0.5)
		end
		border:ClearAllPoints()
		border:SetPoint("TOPLEFT", b, "TOPLEFT", -1, 1)
		border:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 1, -1)
		b.border = border
    end
  
    hooksecurefunc("TargetFrame_UpdateAuras", function(self)
		for i = 1, MAX_TARGET_BUFFS do
			b = _G["TargetFrameBuff"..i]
			applySkin(b)
		end
		for i = 1, MAX_TARGET_DEBUFFS do
			b = _G["TargetFrameDebuff"..i]
			applySkin(b)
		end
		for i = 1, MAX_TARGET_BUFFS do
			b = _G["FocusFrameBuff"..i]
			applySkin(b)
		end
		for i = 1, MAX_TARGET_DEBUFFS do
			b = _G["FocusFrameDebuff"..i]
			applySkin(b)
		end
    end)

    if not Interface.settings.SkinInterface then return end

	for i,v in pairs({
		PlayerFrameTexture,
		TargetFrameTextureFrameTexture,
		PlayerFrameAlternateManaBarBorder,
		PlayerFrameAlternateManaBarLeftBorder,
		PlayerFrameAlternateManaBarRightBorder,
		PaladinPowerBarFrameBG,
        PaladinPowerBarFrameBankBG,
		ComboPointPlayerFrame.Background,
		ComboPointPlayerFrame.Combo1.PointOff,
		ComboPointPlayerFrame.Combo2.PointOff,
		ComboPointPlayerFrame.Combo3.PointOff,
		ComboPointPlayerFrame.Combo4.PointOff,
		ComboPointPlayerFrame.Combo5.PointOff,
		ComboPointPlayerFrame.Combo6.PointOff,
		AlternatePowerBarBorder,
		AlternatePowerBarLeftBorder,
		AlternatePowerBarRightBorder,
		PetFrameTexture,
		PartyMemberFrame1Texture,
		PartyMemberFrame2Texture,
		PartyMemberFrame3Texture,
		PartyMemberFrame4Texture,
		PartyMemberFrame1PetFrameTexture,
		PartyMemberFrame2PetFrameTexture,
		PartyMemberFrame3PetFrameTexture,
		PartyMemberFrame4PetFrameTexture,
		FocusFrameTextureFrameTexture,
		TargetFrameToTTextureFrameTexture,
		FocusFrameToTTextureFrameTexture,
		Boss1TargetFrameTextureFrameTexture,
		Boss2TargetFrameTextureFrameTexture,
		Boss3TargetFrameTextureFrameTexture,
		Boss4TargetFrameTextureFrameTexture,
		Boss5TargetFrameTextureFrameTexture,
		Boss1TargetFrameSpellBar.Border,
		Boss2TargetFrameSpellBar.Border,
		Boss3TargetFrameSpellBar.Border,
		Boss4TargetFrameSpellBar.Border,
		Boss5TargetFrameSpellBar.Border,
		CastingBarFrame.Border,
		FocusFrameSpellBar.Border,
		TargetFrameSpellBar.Border,

	}) do
        v:SetVertexColor(.15, .15, .15)
	end
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

function Interface:ColorUnitFrames()
	--HIDE COLORS BEHIND NAME
	hooksecurefunc("TargetFrame_CheckFaction", function(self)
	    self.nameBackground:SetVertexColor(0, 0, 0, 0);
	end)

	-- CLASS COLOR HP BAR
	local function colour(statusbar, unit)
	        local _, class, c
	        if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
	                _, class = UnitClass(unit)
	                c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	                statusbar:SetStatusBarColor(c.r, c.g, c.b)
	                --PlayerFrameHealthBar:SetStatusBarColor(0,1,0)
	        end
	end

	hooksecurefunc("UnitFrameHealthBar_Update", colour)
	hooksecurefunc("HealthBar_OnValueChanged", function(self)
	        colour(self, self.unit)
	end)
end

function Interface:ActionBars()

	local textures = {
	    normal            = "Interface\\AddOns\\JokUI\\media\\textures\\gloss",
	    flash             = "Interface\\AddOns\\JokUI\\media\\textures\\flash",
	    hover             = "Interface\\AddOns\\JokUI\\media\\textures\\hover",
	    pushed            = "Interface\\AddOns\\JokUI\\media\\textures\\pushed",
	    outer_shadow      = "Interface\\AddOns\\JokUI\\media\\textures\\outer_shadow",
	}

	local background = {
	    inset             = 5,
	}

		--backdrop settings
	local bgfile, edgefile = "", textures.outer_shadow

	--backdrop
	local backdrop = {
	    bgFile = bgfile,
	    edgeFile = edgefile,
	    tile = false,
	    tileSize = 32,
	    edgeSize = background.inset,
	    insets = {
	      left = background.inset,
	      right = background.inset,
	      top = background.inset,
	      bottom = background.inset,
	    },
	}

	  ---------------------------------------
	  -- FUNCTIONS
	  ---------------------------------------

	local function applyBackground(bu)
	  if not bu or (bu and bu.bg) then return end
	  --shadows+background
	  if bu:GetFrameLevel() < 1 then bu:SetFrameLevel(1) end
	    bu.bg = CreateFrame("Frame", nil, bu)
	    bu.bg:SetPoint("TOPLEFT", bu, "TOPLEFT", -4, 4)
	    bu.bg:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 4, -4)
	    bu.bg:SetFrameLevel(bu:GetFrameLevel()-1)

	    local t = bu.bg:CreateTexture(nil,"BACKGROUND",-8)
	    t:SetTexture(textures.buttonback)
	    t:SetVertexColor(0.2, 0.2, 0.2, 0.3)

	    bu.bg:SetBackdrop(backdrop)
	    bu.bg:SetBackdropBorderColor(0, 0, 0, 0.7)
	end

	  --initial style func
	local function styleActionButton(bu)
	    if not bu or (bu and bu.rabs_styled) then
	      return
	    end
	    local action = bu.action
	    local name = bu:GetName()
	    local ic  = _G[name.."Icon"]
	    local bo  = _G[name.."Border"]
	    local ho  = _G[name.."HotKey"]
	    local na  = _G[name.."Name"]
	    local fl = _G[name.."Flash"]
	    local nt  = _G[name.."NormalTexture"]
	    local fob = _G[name.."FlyoutBorder"]
	    local fobs = _G[name.."FlyoutBorderShadow"]
	    --flyout border stuff
	    if fob then fob:SetTexture(nil) end
	    if fobs then fobs:SetTexture(nil) end
	    bo:SetTexture(nil) --hide the border (plain ugly, sry blizz)

	    --hotkey
	    ho:SetFont(font, 12, "OUTLINE")
	    ho:ClearAllPoints()
	    ho:SetPoint("TOPRIGHT", bu, "TOPRIGHT", 0, 0)

	    --macro name
	    na:SetFont(font, 10, "OUTLINE")

	    --applying the textures
	    fl:SetTexture(textures.flash)
	    bu:SetPushedTexture(textures.pushed)
	    bu:SetNormalTexture(textures.normal)

	    if not nt then
	      --fix the non existent texture problem (no clue what is causing this)
	      nt = bu:GetNormalTexture()
	    end

	    --cut the default border of the icons and make them shiny
	    ic:SetTexCoord(0.1,0.9,0.1,0.9)
	    ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
	    ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)

	    --make the normaltexture match the buttonsize
	    nt:SetAllPoints(bu)

	    --hook to prevent Blizzard from reseting our colors
	    hooksecurefunc(nt, "SetVertexColor", function(nt, r, g, b, a)
	      local bu = nt:GetParent()
	      local action = bu.action
	      --print("bu"..bu:GetName().."R"..r.."G"..g.."B"..b)
	      if r==1 and g==1 and b==1 and action and (IsEquippedAction(action)) then
	          nt:SetVertexColor(0.999,0.999,0.999,1)
	      elseif r==0.5 and g==0.5 and b==1 then
	        --blizzard oom color
	          nt:SetVertexColor(0.499,0.499,0.999,1)
	      elseif r==1 and g==1 and b==1 then
	          nt:SetVertexColor(0.5,0.5,0.5,1)
	      end
	    end)
	    --shadows+background
	    if not bu.bg then applyBackground(bu) end
	    bu.rabs_styled = true
	  end

	  -- style leave button
	  local function styleLeaveButton(bu)
	    if not bu or (bu and bu.rabs_styled) then return end
		  --local region = select(1, bu:GetRegions())
		  local name = bu:GetName()
	  	local nt = bu:GetNormalTexture()
		  local bo = bu:CreateTexture(name.."Border", "BACKGROUND", nil, -7)
	  	nt:SetTexCoord(0.2,0.8,0.2,0.8)
	  	nt:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
	    nt:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	  	bo:SetTexture(textures.normal)
	  	bo:SetTexCoord(0, 1, 0, 1)
	  	bo:SetDrawLayer("BACKGROUND",- 7)
	  	bo:SetVertexColor(0.4, 0.35, 0.35)
		  bo:ClearAllPoints()
		  bo:SetAllPoints(bu)
	    --shadows+background
	    if not bu.bg then applyBackground(bu) end
	    bu.rabs_styled = true
	  end

	  --style pet buttons
	  local function stylePetButton(bu)
	    if not bu or (bu and bu.rabs_styled) then return end
	    local name = bu:GetName()
	    local ic  = _G[name.."Icon"]
	    local fl  = _G[name.."Flash"]
	    local nt  = _G[name.."NormalTexture2"]
	    nt:SetAllPoints(bu)

	    --applying color
	    nt:SetVertexColor(0.37, 0.3, 0.3, 1)

	    --setting the textures
	    fl:SetTexture(textures.flash)
	    bu:SetPushedTexture(textures.pushed)
	    bu:SetNormalTexture(textures.normal)
	    hooksecurefunc(bu, "SetNormalTexture", function(self, texture)
	      --make sure the normaltexture stays the way we want it
	      if texture and texture ~= textures.normal then
	        self:SetNormalTexture(textures.normal)
	      end
	    end)
	    --cut the default border of the icons and make them shiny
	    ic:SetTexCoord(0.1,0.9,0.1,0.9)
	  	ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
		  ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	    --shadows+background
	    if not bu.bg then applyBackground(bu) end
	    bu.rabs_styled = true
	    end

	--style stance buttons

	  local function styleStanceButton(bu)
	    if not bu or (bu and bu.rabs_styled) then return end
	    local name = bu:GetName()
	    local ic  = _G[name.."Icon"]
	    local fl  = _G[name.."Flash"]
	    local nt  = _G[name.."NormalTexture2"]
	    nt:SetAllPoints(bu)

	    --applying color
	    nt:SetVertexColor(0.37, 0.3, 0.3, 1)

	    --setting the textures
	    fl:SetTexture(textures.flash)
	    bu:SetPushedTexture(textures.pushed)
	    bu:SetNormalTexture(textures.normal)

	    --cut the default border of the icons and make them shiny
	    ic:SetTexCoord(0.1,0.9,0.1,0.9)
	    ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
	    ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	    --shadows+background
	    if not bu.bg then applyBackground(bu) end
	    bu.rabs_styled = true
	    end

	--style possess buttons

	  local function stylePossessButton(bu)
	    if not bu or (bu and bu.rabs_styled) then return end
	      local name = bu:GetName()
	      local ic  = _G[name.."Icon"]
	      local fl  = _G[name.."Flash"]
	      local nt  = _G[name.."NormalTexture"]
	      nt:SetAllPoints(bu)

	      --applying color
	      nt:SetVertexColor(0.37, 0.3, 0.3, 1)

	      --setting the textures
	      fl:SetTexture(textures.flash)
	      bu:SetPushedTexture(textures.pushed)
	      bu:SetNormalTexture(textures.normal)

	      --cut the default border of the icons and make them shiny
	      ic:SetTexCoord(0.1,0.9,0.1,0.9)
	      ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
	      ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	      --shadows+background
	      if not bu.bg then applyBackground(bu) end
	      bu.rabs_styled = true
	  end

	-- style bags

	  local function styleBag(bu)
	  	if not bu or (bu and bu.rabs_styled) then return end
		    local name = bu:GetName()
		    local ic  = _G[name.."IconTexture"]
		    local nt  = _G[name.."NormalTexture"]
		    nt:SetTexCoord(0,1,0,1)
		    nt:SetDrawLayer("BACKGROUND", -7)
		    nt:SetVertexColor(0.4, 0.35, 0.35)
		    nt:SetAllPoints(bu)
		    local bo = bu.IconBorder
		    bo:Hide()
		    bo.Show = function() end
		    ic:SetTexCoord(0.1,0.9,0.1,0.9)
	      ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
	      ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	  	  bu:SetNormalTexture(textures.normal)
		    --bu:SetHighlightTexture(textures.hover)
	      bu:SetPushedTexture(textures.pushed)
	      --bu:SetCheckedTexture(textures.checked)
	 	
	      --make sure the normaltexture stays the way we want it
	  	  hooksecurefunc(bu, "SetNormalTexture", function(self, texture)
	      if texture and texture ~= textures.normal then
	        	self:SetNormalTexture(textures.normal)
	      end
	   	  end)
		    bu.Back = CreateFrame("Frame", nil, bu)
			  bu.Back:SetPoint("TOPLEFT", bu, "TOPLEFT", -4, 4)
			  bu.Back:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 4, -4)
			  bu.Back:SetFrameLevel(bu:GetFrameLevel() - 1)
			  bu.Back:SetBackdrop(backdrop)
	      bu.Back:SetBackdropBorderColor(0, 0, 0, 0.9)
	  end

	  if not Interface.settings.SkinInterface then return end

	    --style the actionbar buttons
	    for i = 1, NUM_ACTIONBAR_BUTTONS do
	      styleActionButton(_G["ActionButton"..i])
	      styleActionButton(_G["MultiBarBottomLeftButton"..i])
	      styleActionButton(_G["MultiBarBottomRightButton"..i])
	      styleActionButton(_G["MultiBarRightButton"..i])
	      styleActionButton(_G["MultiBarLeftButton"..i])
	    end
		  --style bags
	    for i = 0, 3 do
			styleBag(_G["CharacterBag"..i.."Slot"])
	    end
		  styleBag(MainMenuBarBackpackButton)
	    for i = 1, 6 do
	      styleActionButton(_G["OverrideActionBarButton"..i])
	    end

	    --style leave button
		styleLeaveButton(MainMenuBarVehicleLeaveButton)
	    styleLeaveButton(rABS_LeaveVehicleButton)

	    --petbar buttons
	    for i=1, NUM_PET_ACTION_SLOTS do
	      stylePetButton(_G["PetActionButton"..i])
	    end

	    --stancebar buttons
	    for i=1, NUM_STANCE_SLOTS do
	      styleStanceButton(_G["StanceButton"..i])
	    end

	    --possess buttons
	    for i=1, NUM_POSSESS_SLOTS do
	      stylePossessButton(_G["PossessButton"..i])
	    end

	    --spell flyout
	    SpellFlyoutBackgroundEnd:SetTexture(nil)
	    SpellFlyoutHorizontalBackground:SetTexture(nil)
	    SpellFlyoutVerticalBackground:SetTexture(nil)

	    local function checkForFlyoutButtons(self)
	      local NUM_FLYOUT_BUTTONS = 10
	      for i = 1, NUM_FLYOUT_BUTTONS do
	        styleActionButton(_G["SpellFlyoutButton"..i])
	      end
	    end
	    SpellFlyout:HookScript("OnShow",checkForFlyoutButtons)
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
end

function Interface:Colors()

	for i=1,5 do
		local BagTop = _G["ContainerFrame"..i.."BackgroundTop"]
		local BagMid1 = _G["ContainerFrame"..i.."BackgroundMiddle1"]
		local BagMid2 = _G["ContainerFrame"..i.."BackgroundMiddle2"]
		local BagBot = _G["ContainerFrame"..i.."BackgroundBottom"]
		for k,v in pairs({		
			BagTop,
			BagMid1,
			BagMid2,
			BagBot,
		}) do
			v:SetVertexColor(.2, .2, .2)
		end
	end 

	for i,v in pairs({
		MinimapBorder,
		MiniMapMailBorder,
		QueueStatusMinimapButtonBorder,
		select(1, TimeManagerClockButton:GetRegions()),
      		}) do
         		v:SetVertexColor(.14, .14, .14)
    end
    select(2, TimeManagerClockButton:GetRegions()):SetVertexColor(1,1,1)

	local CF=CreateFrame("Frame")
	CF:RegisterEvent("PLAYER_ENTERING_WORLD")
	CF:RegisterEvent("GROUP_ROSTER_UPDATE")

	function ColorRaid()
		for g = 1, NUM_RAID_GROUPS do
			local group = _G["CompactRaidGroup"..g.."BorderFrame"]
			if group then
				for _, region in pairs({group:GetRegions()}) do
					if region:IsObjectType("Texture") then
						region:SetVertexColor(.15, .15, .15)
					end
				end
			end
			-- Groups Title
			local group = _G["CompactRaidGroup"..g.."Title"]
			if group then
				for _, region in pairs({group:GetRegions()}) do
					region:SetText(g)
				end
			end
			for m = 1, 5 do
				local frame = _G["CompactRaidGroup"..g.."Member"..m]
				if frame then
					groupcolored = true
					for _, region in pairs({frame:GetRegions()}) do
						if region:GetName():find("Border") then
							region:SetVertexColor(.15, .15, .15)
						end
					end
				end
				local frame = _G["CompactRaidFrame"..m]
				if frame then
					singlecolored = true
					for _, region in pairs({frame:GetRegions()}) do
						if region:GetName():find("Border") then
							region:SetVertexColor(.15, .15, .15)
						end
					end
				end
			end
		end
		for _, region in pairs({CompactRaidFrameContainerBorderFrame:GetRegions()}) do
			if region:IsObjectType("Texture") then
				region:SetVertexColor(.15, .15, .15)
			end
		end
	end
	
	CF:SetScript("OnEvent", function(self, event)
		ColorRaid()
		CF:SetScript("OnUpdate", function()
			if CompactRaidGroup1 and not groupcolored == true then
				ColorRaid()
			end
			if CompactRaidFrame1 and not singlecolored == true then
				ColorRaid()
			end
		end)
	end)

	for i,v in pairs({
		Boss1TargetFrameSpellBar.BorderShield,
		Boss2TargetFrameSpellBar.BorderShield,
		Boss3TargetFrameSpellBar.BorderShield,
		Boss4TargetFrameSpellBar.BorderShield,
		Boss5TargetFrameSpellBar.BorderShield,
	}) do
        v:SetAlpha(0)
	end

	for i,v in pairs({
		SlidingActionBarTexture0,
		SlidingActionBarTexture1,
        MainMenuBarTexture0,
		MainMenuBarTexture1,
		MainMenuBarTexture2,
		MainMenuBarTexture3,
        MainMenuMaxLevelBar0,
        MainMenuMaxLevelBar1,
		MainMenuMaxLevelBar2,
		MainMenuMaxLevelBar3,
		MainMenuXPBarTextureLeftCap,
		MainMenuXPBarTextureRightCap,
		MainMenuXPBarTextureMid,
		ReputationWatchBarTexture0,
		ReputationWatchBarTexture1,
		ReputationWatchBarTexture2,
		ReputationWatchBarTexture3,
		ReputationXPBarTexture0,
		ReputationXPBarTexture1,
		ReputationXPBarTexture2,
		ReputationXPBarTexture3,
	}) do

		v:SetVertexColor(.15, .15, .15)
  
	end 	

    for i,v in pairs({
		MainMenuBarArtFrame.LeftEndCap,
        MainMenuBarArtFrame.RightEndCap,
        MainMenuBarArtFrameBackground.BackgroundLarge,
        MainMenuBarArtFrameBackground.BackgroundSmall,
		StanceBarLeft,
		StanceBarMiddle,
		StanceBarRight, 
	}) do
        v:SetVertexColor(.2, .2, .2)
	end 

	for _, region in pairs({StopwatchFrame:GetRegions()}) do
			region:SetVertexColor(.15, .15, .15)
		end
	
	for _, region in pairs({CompactRaidFrameManager:GetRegions()}) do
		if region:IsObjectType("Texture") then
			region:SetVertexColor(.15, .15, .15)
		end
	end

	for _, region in pairs({StatusTrackingBarManager:GetRegions()}) do
		if region:IsObjectType("Texture") then
			region:SetVertexColor(.15, .15, .15)
		end
	end

	for _, region in pairs({MicroButtonAndBagsBar:GetRegions()}) do
		if region:IsObjectType("Texture") then
			region:SetVertexColor(.15, .15, .15)
		end
	end

	for _, region in pairs({CompactRaidFrameManagerContainerResizeFrame:GetRegions()}) do
		if region:GetName():find("Border") then
			region:SetVertexColor(.15, .15, .15)
		end
	end
	CompactRaidFrameManagerToggleButton:SetNormalTexture("Interface\\AddOns\\JokUI\\media\\textures\\raid\\RaidPanel-Toggle")
	
	hooksecurefunc("GameTooltip_ShowCompareItem", function(self, anchorFrame)
		if self then
			local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips)
			shoppingTooltip1:SetBackdropBorderColor(.15, .15, .15)
			shoppingTooltip2:SetBackdropBorderColor(.15, .15, .15)
		end
	end)	
	
	GameTooltip:SetBackdropBorderColor(.15, .15, .15)
	GameTooltip.SetBackdropBorderColor = function() end
	
	for i,v in pairs({
		PlayerPVPIcon,
		TargetFrameTextureFramePVPIcon,
		FocusFrameTextureFramePVPIcon,
	}) do
		v:SetAlpha(0)
	end
	for i=1,4 do 
		_G["PartyMemberFrame"..i.."PVPIcon"]:SetAlpha(0)
		_G["PartyMemberFrame"..i.."NotPresentIcon"]:Hide()
		_G["PartyMemberFrame"..i.."NotPresentIcon"].Show = function() end
	end
	for i=1,12 do 
		_G["ActionButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
		_G["ActionButton"..i.."NormalTexture"]:SetVertexColor(0.25, 0.25, 0.15, 1)
		_G["MultiBarBottomLeftButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
		_G["MultiBarBottomLeftButton"..i.."NormalTexture"]:SetVertexColor(0.25, 0.25, 0.15, 1)
		_G["MultiBarBottomRightButton"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9)
		_G["MultiBarBottomRightButton"..i.."NormalTexture"]:SetVertexColor(0.25, 0.25, 0.15, 1)
	end
	PlayerFrameGroupIndicator:SetAlpha(0)
	PlayerHitIndicator:SetText(nil) 
	PlayerHitIndicator.SetText = function() end
	PetHitIndicator:SetText(nil) 
	PetHitIndicator.SetText = function() end
		for _, child in pairs({WarlockPowerFrame:GetChildren()}) do
		for _, region in pairs({child:GetRegions()}) do
				if region:GetDrawLayer() == "BORDER" then
					region:SetVertexColor(.15, .15, .15)
				end
		end
	end
end

function Interface:CastBars()
	local max = math.max
	local format = string.format

	if not InCombatLockdown() then

		-- Channels Ticks

		local sparkfactory = {
			__index = function(t,k)
				local spark = CastingBarFrame:CreateTexture(nil, 'OVERLAY')
				t[k] = spark
				spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
				spark:SetVertexColor(1, 1, 1, 1)
				spark:SetBlendMode('ADD')
				spark:SetWidth(10)
				spark:SetHeight(15*2.2)
				return spark
			end
		}
		local barticks = setmetatable({}, sparkfactory)

		local function setBarTicks(ticknum)
			if( ticknum and ticknum > 0) then
				local delta = ( CastingBarFrame:GetWidth() / ticknum )
				for k = 1,ticknum do
					local t = barticks[k]
					t:ClearAllPoints()
					t:SetPoint("CENTER", CastingBarFrame, "LEFT", delta * k, 0 )
					t:Show()
				end
			else
				barticks[1].Hide = nil
				for i=1,#barticks do
					barticks[i]:Hide()
				end
			end
		end

		-- TODO: this will need updates for Cataclysm
		local channelingTicks = {
			-- warlock
			[GetSpellInfo(198590)] = 5, -- drain soul
			[GetSpellInfo(234153)] = 5, -- drain life
			-- druid
			[GetSpellInfo(740)] = 4, -- Tranquility
			-- priest
			[GetSpellInfo(15407)] = 3, -- mind flay
			[GetSpellInfo(48045)] = 5, -- mind sear
			[GetSpellInfo(47540)] = 2, -- penance
			-- mage
			[GetSpellInfo(5143)] = 5, -- arcane missiles
			[GetSpellInfo(12051)] = 4, -- evocation
		}

		local function getChannelingTicks(spell)			
			return channelingTicks[spell] or 0
		end

		local function isTalentSelected(class, spec, talentID)
			local specIndex = GetSpecialization()
			local _, className = UnitClass("player")
			if className == class and specIndex == spec then 
				local _, _, _, selected = GetTalentInfoByID(talentID, specIndex)
				if selected then
					return true
				else
					return false
				end
			end
		end

		local frame = CreateFrame("Frame", "ChannelTicks", UIParent)

		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
		frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		frame:RegisterEvent("UNIT_SPELLCAST_START")
		frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		frame:RegisterEvent("PLAYER_TALENT_UPDATE")		

		frame:SetScript("OnEvent", function(self, event, ...)
			if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TALENT_UPDATE" then
				if isTalentSelected("PRIEST", 1, 19752) then
					channelingTicks[GetSpellInfo(47540)] = 3
				else
					channelingTicks[GetSpellInfo(47540)] = 2
				end
			elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
				local unit = ...
				if unit == "player" then
					local spell = UnitChannelInfo(unit)
					CastingBarFrame.channelingTicks = getChannelingTicks(spell)
					setBarTicks(CastingBarFrame.channelingTicks)
				end
			elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
				local unit = ...
				if unit == "player" then
					setBarTicks(0)
				end
			end
		end)

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
	hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
		self:GetNormalTexture():SetTexture(nil)
		self:GetPushedTexture():SetTexture(nil)
		if not gb then
			gb = CreateFrame("Frame", nil, GarrisonLandingPageMinimapButton)
			gb:SetFrameLevel(GarrisonLandingPageMinimapButton:GetFrameLevel() - 1)
			gb:SetPoint("CENTER", 0, 0)
			gb:SetSize(36,36)

			gb.icon = gb:CreateTexture(nil, "ARTWORK")
			gb.icon:SetPoint("CENTER", 0, 0)
			gb.icon:SetSize(36,36)
	
			gb.border = CreateFrame("Frame", nil, gb)
			gb.border:SetFrameLevel(gb:GetFrameLevel() + 1)
			gb.border:SetAllPoints()

			gb.border.texture = gb.border:CreateTexture(nil, "ARTWORK")
			gb.border.texture:SetTexture("Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Ring")
			gb.border.texture:SetVertexColor(.1,.1,.1)
			gb.border.texture:SetPoint("CENTER", 1, -2)
			gb.border.texture:SetSize(45,45)
		end
		if (C_Garrison.GetLandingPageGarrisonType() == 2) then
			if select(1,UnitFactionGroup("player")) == "Alliance" then	
				SetPortraitToTexture(gb.icon, select(3,GetSpellInfo(61573)))
			elseif select(1,UnitFactionGroup("player")) == "Horde" then
				SetPortraitToTexture(gb.icon, select(3,GetSpellInfo(61574)))
			end
		else
			local t = CLASS_ICON_TCOORDS[select(2,UnitClass("player"))]
        	gb.icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        	gb.icon:SetTexCoord(unpack(t))
		end
	end)

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

	-- Objective Frame
	-- these three lines define where to position the topright corner
	-- negative x values go left, positive x values go right
	-- negative y values go down, positive y values go up
	local anchor = "TOPRIGHT"
	local xOff = -3
	local yOff = 0

 	if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
    	local tracker = ObjectiveTrackerFrame
    	tracker:ClearAllPoints()
    	tracker:SetPoint(anchor,UIParent,xOff,yOff)
    	hooksecurefunc(ObjectiveTrackerFrame,"SetPoint",function(self,anchorPoint,relativeTo,x,y)
      		if anchorPoint~=anchor and x~=xOff and y~=yOff then
      			if MultiBarLeft:IsShown() then
        			self:SetPoint("TOPRIGHT",MultiBarLeft, "TOPLEFT", xOff,yOff)
        		end
      		end
    	end)
  	end

  	-- ETC
  	VerticalMultiBarsContainer:SetPoint("TOP", MinimapCluster, "BOTTOM", -2, -58)

  	MicroButtonAndBagsBar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 5, -4)

	DurabilityFrame:SetScale(0.8)

  	for i,v in pairs({
		MainMenuBarBackpackButton,
  		CharacterBag0Slot,
  		CharacterBag1Slot,
  		CharacterBag2Slot,
  		CharacterBag3Slot,
  		MicroButtonAndBagsBar.MicroBagBar,
  		MainMenuBarArtFrame.RightEndCap,
		MainMenuBarArtFrame.LeftEndCap,
		--MainMenuBarArtFrameBackground,
	}) do
        v:Hide()
	end	 	
end

function Interface:BossFrame()

	-- initialize addon table
	Interface.events = Interface.events or {}
	Interface.commands = Interface.commands or {}

	local db

	local BF = {
		scale = 1,
		scale_delta = 0.005,
		space = 4, -- vertical space
		backdrop = {
			edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],	-- Dialog style
	--		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],		-- Tooltip style
			edgeSize = 17,
			tile = true
		},
		bordercolor = {1, 1, 0.3, 1}, -- Red, Green, Blue, Alpha (0.0-1.0)
		texture = "Otravi", -- Name of texture of Health and Mana in Shared Media.
		raidicon = {
			pos = "Left",
			anchors = {
				Top = {"CENTER", nil, "TOP", 0, 3},	-- Top
				Left = {"CENTER", nil, "LEFT", -3, 0},	-- Left
				Right = {"CENTER", nil, "TOPRIGHT", 20, -2},	-- Right
				Bottom = {"CENTER", nil, "BOTTOM", 0, -3}-- Bottom
			}
		},
		buff = {
			-- enabled = true,
			offset = {x = 0, y = 2},
			size = {W = 26, H = 18},
			borderSize = 1,
			filterEnemy = "HARMFUL|PLAYER",
			filterFriendly = "HELPFUL|RAID",
		},
	}

	Interface.anchorFrame = Interface.anchorFrame or CreateFrame("Frame", nil, _G.UIParent)

	local events = Interface.events
	local commands = Interface.commands
	local anchorFrame = Interface.anchorFrame
	local frames = {}

	local buff_prototype = {}
	local buff_MT = {__index = buff_prototype}

	local function InterfaceSpellBar_OnSetPoint(self)
		if self.boss then
			self:SetPoint("TOP", self:GetParent(), "BOTTOM", 5.5, 26.5)
		end
	end

	local function FrameBorder_OnUpdate(self)
		self:SetScript("OnUpdate", nil)
		self.highlight:SetShown(UnitIsUnit("target", self.unit))
		if self.buffs then
			for i = 1, #self.buffs do
				self.buffs[i]:SetStyle()
			end
		end
	end

	local UpdateBuffs do

		local function ShouldShowBuff(id, nameplate, caster, isBoss, duration)
			return id and (caster == "player" and duration <= 40 or isBoss)
		end

		local function ShouldShowDebuff(id, nameplate, caster, isBoss, duration)
			return id and duration ~= 0 and (nameplate or isBoss)
		end

		local BUFF_MAX_DISPLAY, CooldownFrame_Set = BUFF_MAX_DISPLAY, CooldownFrame_Set
		local _, filter, ShouldShowFunc, unit, index, buff, name, texture, count, duration, expire, caster, nameplatePersonal, spellID, isBoss, nameplateAll

		UpdateBuffs = function(frame)
			unit = frame.unit
			if frame.reaction <= 4 then
				filter = BF.buff.filterEnemy
				ShouldShowFunc = ShouldShowDebuff
			else
				filter = BF.buff.filterFriendly
				ShouldShowFunc = ShouldShowBuff
			end
			-- unit = "player"
			-- filter = "HELPFUL"
			index = 1
			for i = 1, BUFF_MAX_DISPLAY do
				name, texture, count, _, duration, expire, caster, _, nameplatePersonal, spellID, _, isBoss, _, nameplateAll = UnitAura(unit, i, filter)
				if ShouldShowFunc(spellID, nameplatePersonal or nameplateAll, caster, isBoss, duration) then
					if not frame.buffs[index] then
						frame.buffs[index] = buff_prototype:New(frame, index)
					end
					buff = frame.buffs[index]
					if buff.spellID ~= spellID or buff.expire ~= expire or buff.count ~= count or buff.duration ~= duration then
						buff.spellID = spellID
						buff.expire = expire
						buff.count = count
						buff.duration = duration
						buff:SetIcon(texture)
						buff:SetCount(count)
						CooldownFrame_Set(buff.cooldown, expire - duration, duration, true, true)
					end
					buff:Show()
					index = index + 1
					if index > 5 then break end
				end
			end
			for i = index, #frame.buffs do
				frame.buffs[i]:Hide()
			end
		end
	end

	local function FrameBorder_OnEvent(self, event)
		if event == "UNIT_AURA" then
			UpdateBuffs(self)
		elseif event == "UNIT_FACTION" then
			self.reaction = UnitReaction(self.unit, "player") or 0
		elseif self:IsVisible() then
			self:RegisterUnitEvent("UNIT_AURA", self.unit)
			self.reaction = UnitReaction(self.unit, "player") or 0
			UpdateBuffs(self)
		else
			self:UnregisterEvent("UNIT_AURA")
			self.reaction = 0
		end
	end

	local function Interfaces_SetStyle()
		local p
		for i = 1, MAX_BOSS_FRAMES do
			local boss = _G["Boss"..i.."TargetFrame"]
			local bossPortrait = _G["Boss"..i.."TargetFramePortrait"]
			local bossTexture = _G["Boss"..i.."TargetFrameTextureFrameTexture"]

			if BF.scale then boss:SetScale(BF.scale) end -- taint

			boss.highLevelTexture:SetPoint("CENTER", 62, -16);
			boss.threatIndicator:SetTexture(nil)

			if BF.space and i > 1 and boss:GetNumPoints() > 0 then
				p = {boss:GetPoint(1)}
				p[5] = BF.space
				boss:ClearAllPoints() -- taint
				boss:SetPoint(unpack(p)) -- taint
			end

			if BF.raidicon.pos then
				p = {unpack(BF.raidicon.anchors[BF.raidicon.pos])}
				boss.raidTargetIcon:ClearAllPoints()
				p[2] = frameBorder
				boss.raidTargetIcon:SetPoint(unpack(p))
			end

			boss.healthbar:SetPoint("TOPLEFT", boss, "TOPLEFT", 6, -24)
			boss.healthbar:SetHeight(26)
			boss.healthbar:SetStatusBarColor(1,1,1)
			boss.name:SetPoint("BOTTOM", boss.healthbar, "TOP", 0, 4)
			boss.healthbar.LeftText:SetPoint("LEFT", boss.healthbar, "LEFT", 6, 0);
			boss.highLevelTexture:SetPoint("CENTER", 62, -16);

			boss.healthbar.RightText:SetPoint("RIGHT", boss.healthbar, "RIGHT", -5, 0);
			boss.healthbar.RightText:SetFont(font, 14, "OUTLINE")
			boss.manabar.LeftText:SetPoint("LEFT", boss.manabar, "LEFT", 6, 0);
			boss.deadText:SetPoint("CENTER", boss.healthbar, "CENTER", 0, 0);
			boss.unconsciousText:SetPoint("CENTER", boss.healthbar, "CENTER", 0, 0);
			boss.nameBackground:Hide()

			local frame = CreateFrame("Frame", nil, boss)
			frame:SetHeight(64)
			frame:SetWidth(64)
			frame:SetPoint("TOPRIGHT", boss, "TOPRIGHT", -42, -12)

			portrait = frame:CreateTexture(nil, "BACKGROUND")
			portrait:SetHeight(64)
			portrait:SetWidth(64)
			portrait:SetPoint("TOPLEFT", 0, 0)

			local frameBorder = CreateFrame("Frame", nil, boss)
			local borderFrameLevel = frameBorder:GetFrameLevel()
			boss.textureFrame:SetFrameLevel(borderFrameLevel + 1)
			bossTexture:SetTexture("Interface\\AddOns\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame")
			_G["Boss"..i.."TargetFrameDropDown"]:SetFrameLevel(borderFrameLevel + 1)
			frameBorder:SetPoint("TOPLEFT", boss.Background, "TOPLEFT", -4, 3)
			frameBorder:SetPoint("BOTTOMRIGHT", boss.Background, "BOTTOMRIGHT", 4, -5)

			local highlight = frameBorder:CreateTexture(nil, "OVERLAY")
			frameBorder.highlight = highlight
			frameBorder.unit = "boss"..i
			frameBorder:SetScript("OnEvent", FrameBorder_OnEvent)
			frameBorder:RegisterEvent("PLAYER_TARGET_CHANGED")
			frameBorder:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			frameBorder:RegisterEvent("ENCOUNTER_START")
			frameBorder:RegisterEvent("PLAYER_REGEN_DISABLED")

			frameBorder:RegisterUnitEvent("UNIT_FACTION", frameBorder.unit)
			frameBorder.buffs = {}
		end
		wipe(p)
		hooksecurefunc("Target_Spellbar_AdjustPosition", InterfaceSpellBar_OnSetPoint)
	end

	hooksecurefunc("BossTargetFrame_OnLoad", function(self, unit, event)
		self.maxBuffs = 3;
		self.maxDebuffs = 3;
		self.levelText:SetPoint("CENTER", 62, select(5, self.levelText:GetPoint("CENTER")));

	end)

	local function Interfaces_SetScale(scale)
		for i = 1, MAX_BOSS_FRAMES do
			_G["Boss"..i.."TargetFrame"]:SetScale(scale)
		end
	end

	function Interface:Enable()
		Interfaces_SetStyle()

		self.bossFrame = _G["Boss1TargetFrame"]
		self.defaultScale = self.bossFrame:GetScale()
		self.bossFrame.OrgSetPoint = self.bossFrame.SetPoint
		self.bossFrame.SetPoint = function() end
		self.bossFrame:HookScript("OnHide", function() anchorFrame:Hide() end)

		anchorFrame:SetMovable(true)
		anchorFrame:SetScale(self.defaultScale)
		anchorFrame:SetSize(self.bossFrame:GetWidth(), self.bossFrame:GetHeight() * 5 - (BF.space * 4))
		anchorFrame:SetScript("OnMouseDown", anchorFrame.OnMouseDown)
		anchorFrame:SetScript("OnMouseUp", anchorFrame.OnMouseUp)
		anchorFrame:SetScript("OnDragStop", anchorFrame.OnMouseUp)
		anchorFrame:SetScript("OnUpdate", anchorFrame.OnUpdate)
		anchorFrame:SetScript("OnMouseWheel", anchorFrame.OnMouseWheel)
		anchorFrame:SetScript("OnShow", anchorFrame.OnShow)
		anchorFrame:Hide()
		if Interface.settings.BossFrame and Interface.settings.BossFrame[1] and Interface.settings.BossFrame[4] and Interface.settings.BossFrame[5] then
			anchorFrame:ClearAllPoints()
			anchorFrame:SetPoint(unpack(Interface.settings.BossFrame))
			self.bossFrame:ClearAllPoints() -- taint
			self.bossFrame:OrgSetPoint(unpack(Interface.settings.BossFrame)) -- taint
		else
			anchorFrame:ClearAllPoints()
			anchorFrame:SetPoint(unpack(Interface.settings.BossFrame))
			self.bossFrame:ClearAllPoints() -- taint
			self.bossFrame:OrgSetPoint(unpack(Interface.settings.BossFrame)) -- taint
		end

		self.testMode = false
	end

	function Interface:UnregisterEvent(...)
		anchorFrame:UnregisterEvent(...)
	end

	function Interface:SetMode(mode, index)
		mode = mode or "Health"
		for i = 1, #frames do
			if not index or i == index then
				frames[i].mode = mode
				Text_Refresh(frames[i])
			end
		end
	end

	function anchorFrame:OnMouseDown(button)
		if button == "LeftButton" then
			self.moving = true
			self:StartMoving()
		end
	end

	function anchorFrame:OnMouseUp(button)
		if button == "LeftButton" then
			self.moving = false
			self:StopMovingOrSizing()
		end
	end

	function anchorFrame:OnUpdate(elapsed)
		if not InCombatLockdown() and self.moving then
			Interface.settings.BossFrame = {self:GetPoint(1)}
			Interface.bossFrame:ClearAllPoints()
			Interface.bossFrame:OrgSetPoint(unpack(Interface.settings.BossFrame))
		end
	end

	function anchorFrame:OnShow()
		if not self.bkgndFrame then
			self.bkgndFrame = CreateFrame("Frame", nil, self)
			self.bkgndFrame:SetFrameStrata("DIALOG")
			self.bkgndFrame:SetBackdrop({
				bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
			})
			self.bkgndFrame:SetAllPoints(self)
			self.bkgndFrame:SetBackdropColor(0, 0.75, 0, 0.5)
		end
		self:EnableMouse(true)
		self:EnableMouseWheel(true)
		self:SetBackdrop({
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
			tile = true,
			edgeSize = 14,
			tileSize = 16,
			insets = {left = 3, right = 3, top = 3, bottom = 3},
		})
		self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	end

	function events:PLAYER_LOGIN(...)
		self:UnregisterEvent("PLAYER_LOGIN")
		self:UnregisterEvent("SPELLS_CHANGED")

		self:Enable()
	end
	events.SPELLS_CHANGED = events.PLAYER_LOGIN

	function events:PLAYER_REGEN_DISABLED()
		if anchorFrame:IsShown() then
			anchorFrame:Hide()
		end
		Interface.testMode = false
	end

	function events:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
		events:PLAYER_REGEN_DISABLED()
		-- -- --
		for i = 1, MAX_BOSS_FRAMES do
			local boss = _G["Boss"..i.."TargetFrame"]
			local healthBar = _G["Boss"..i.."TargetFrameHealthBar"]
			local portrait = _G["Boss"..i.."TargetFramePortrait"]

			if not UnitIsFriend("player", "boss"..i) then
				healthBar:SetStatusBarColor(0.8, 0.3, 0.22)
			else
				healthBar:SetStatusBarColor(0, 1, 0)
			end
			SetPortraitTexture(portrait, "boss"..i)			
		end
		for i = 1, #frames do
			frames[i].value = nil
			frames[i].elapsed = 1
		end
	end

	local function BossColor()
		for i = 1, MAX_BOSS_FRAMES do
			local boss = _G["Boss"..i.."TargetFrame"]
			local healthBar = _G["Boss"..i.."TargetFrameHealthBar"]

			if not UnitIsFriend("player", "boss"..i) then
				healthBar:SetStatusBarColor(0.8, 0.3, 0.22)
			else
				healthBar:SetStatusBarColor(0, 1, 0)
			end
		end
	end

	hooksecurefunc("HealthBar_OnValueChanged", function(self)
		if Boss1TargetFrame:IsShown() then
			BossColor()
		end
	end)

	hooksecurefunc("BossTargetFrame_UpdateLevelTextAnchor", function(self, targetLevel)
		if ( targetLevel >= 100 ) then
			self.levelText:SetPoint("CENTER", 61, -16);
			self.highLevelTexture:SetPoint("CENTER", 61, -16);
		else
			self.levelText:SetPoint("CENTER", 62, -16);
			self.highLevelTexture:SetPoint("CENTER", 61, -16);
		end
	end)

	function buff_prototype:New(parent, index)
		local buff = setmetatable({}, buff_MT)
		buff.index = index
		buff.cooldown = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
		buff.cooldown:SetHideCountdownNumbers(true)
		buff.cooldown:SetReverse(true)
		buff.cooldown:SetDrawEdge(true)
		buff.cooldown:SetDrawBling(false)
		buff.bg = buff.cooldown:CreateTexture(nil, "BACKGROUND", nil, 2)
		buff.bg:SetColorTexture(0, 0, 0, 1)
		buff.icon = buff.cooldown:CreateTexture(nil, "BACKGROUND", nil, 3)
		buff.icon:SetTexCoord(0.05, 0.95, 0.15, 0.75)
		buff.counter = buff.cooldown:CreateFontString(nil, "ARTWORK", "NumberFontNormalSmall")
		buff.counter:SetJustifyH("LEFT")
		buff:SetStyle()
		return buff
	end

	function buff_prototype:SetStyle()
		self.cooldown:SetScale(1 / BF.scale)
		self.cooldown:ClearAllPoints()
		self.cooldown:SetPoint("TOPLEFT", self.cooldown:GetParent(), "BOTTOMLEFT", BF.buff.offset.x + (0 * BF.scale) + (self.index - 1) * (BF.buff.size.W + 2), BF.buff.offset.y)
		self.cooldown:SetSize(BF.buff.size.W, BF.buff.size.H)
		self.bg:SetAllPoints()
		self.icon:SetPoint("TOPLEFT", BF.buff.borderSize, -BF.buff.borderSize)
		self.icon:SetPoint("BOTTOMRIGHT", -BF.buff.borderSize, BF.buff.borderSize)
		self.counter:SetPoint("BOTTOMRIGHT", 3, -3)
	end

	function buff_prototype:Hide()
		self.cooldown:Hide()
		self.spellID = nil
		self.expire = nil
		self.count = nil
		self.duration = nil
	end

	function buff_prototype:Show()
		self.cooldown:Show()
	end

	function buff_prototype:SetIcon(texture)
		self.icon:SetTexture(texture)
	end

	function buff_prototype:SetCount(count)
		if count > 1 then
			self.counter:SetText(count)
			self.counter:Show()
		else
			self.counter:Hide()
		end
	end

	local function RandomFactionColor()
		local colors = {
			RED_FONT_COLOR,
			GREEN_FONT_COLOR,
			YELLOW_FONT_COLOR,
			ORANGE_FONT_COLOR
		}
		local c = colors[random(1, 4)]
		return c.r, c.g, c.b
	end

	function BossFrameMove()
		if InCombatLockdown() then return end
		local shown = anchorFrame:IsShown()
		Interface.testMode = not shown
		for i = 1, MAX_BOSS_FRAMES do
			local b = "Boss"..i.."TargetFrame"
			if shown then
				_G[b]:Hide()
				anchorFrame:Hide()
				_G[b]:SetFrameStrata("HIGH")
			else
				SetPortraitTexture(_G[b.."Portrait"], "player")
				_G[b.."TextureFrameName"]:SetText("Boss"..i.."Name")
				_G[b.."NameBackground"]:SetVertexColor(RandomFactionColor())
				_G[b.."HealthBar"]:SetMinMaxValues(1, 99999999)
				_G[b.."HealthBar"]:SetValue(random(11111111, 88888888))
				_G[b.."ManaBar"]:SetMinMaxValues(1, 100)
				_G[b.."ManaBar"]:SetValue(random(15, 85))
				_G[b.."TextureFrameLevelText"]:SetText(112)
				-- _G[b.."ManaBar"]:SetStatusBarColor(0.2, 0.2, 1)
				_G[b]:Show()
				_G[b]:SetFrameStrata("DIALOG")
				anchorFrame:Show()
			end
		end
		for i = 1, #frames do
			Text_Refresh(frames[i])
		end
	end

	do
		anchorFrame:SetScript("OnEvent", function(self, event, ...)
			events[event](Interface, event, ...)
		end)
		for event, func in pairs(events) do
			if type(func) == "function" then anchorFrame:RegisterEvent(event) end
		end
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