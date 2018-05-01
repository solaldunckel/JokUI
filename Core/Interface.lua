local _, JokUI = ...
local Interface = JokUI:RegisterModule("Interface")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local features = {}

textures = {
    normal            = "Interface\\AddOns\\JokUI\\media\\textures\\gloss",
    flash             = "Interface\\AddOns\\JokUI\\media\\textures\\flash",
    hover             = "Interface\\AddOns\\JokUI\\media\\textures\\hover",
    pushed            = "Interface\\AddOns\\JokUI\\media\\textures\\pushed",
    checked           = "Interface\\AddOns\\JokUI\\media\\textures\\checked",
    equipped          = "Interface\\AddOns\\JokUI\\media\\textures\\gloss_grey",
    buttonback        = "Interface\\AddOns\\JokUI\\media\\textures\\button_background",
    buttonbackflat    = "Interface\\AddOns\\JokUI\\media\\textures\\button_background_flat",
    outer_shadow      = "Interface\\AddOns\\JokUI\\media\\textures\\outer_shadow",
}

background = {
    showbg            = true,   --show an background image?
    showshadow        = true,   --show an outer shadow?
    useflatbackground = false,  --true uses plain flat color instead
    backgroundcolor   = { r = 0.2, g = 0.2, b = 0.2, a = 0.3},
    shadowcolor       = { r = 0, g = 0, b = 0, a = 0.9},
    classcolored      = false,
    inset             = 5,
}

hotkeys = {
    fontsize          = 12,
    pos1              = { a1 = "TOPRIGHT", x = 0, y = 0 },
    pos2              = { a1 = "TOPLEFT", x = 0, y = 0 }, --important! two points are needed to make the hotkeyname be inside of the button
}

macroname = {
    show              = true,
    fontsize          = 10,
    pos1              = { a1 = "BOTTOMLEFT", x = 0, y = 0 },
    pos2              = { a1 = "BOTTOMRIGHT", x = 0, y = 0 }, --important! two points are needed to make the macroname be inside of the button
}
itemcount = {
    show              = true,
    fontsize          = 12,
    pos1              = { a1 = "BOTTOMRIGHT", x = 0, y = 0 },
}
cooldown = {
    spacing           = 0,
  }

color = {
    normal            = { r = 0.37, g = 0.3, b = 0.3, },
    equipped          = { r = 0.1, g = 0.5, b = 0.1, },
    classcolored      = false,
}

adjustOneletterAbbrev = true
font = STANDARD_TEXT_FONT

	-- buff frame settings

buffFrame = {
    pos                 = { a1 = "TOPRIGHT", af = "Minimap", a2 = "TOPLEFT", x = -40, y = 0 },
    gap                 = 30, --gap between buff and debuff rows
    userplaced          = true, --want to place the bar somewhere else?
    rowSpacing          = 10,
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
  
-- debuff frame settings

debuffFrame = {    
	pos             = { a1 = "TOPRIGHT", af = "Minimap", a2 = "TOPLEFT", x = -40, y = -85 },
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

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local interface_defaults = {
    profile = {
    	unitframes = {
    		righttext = 16,
    		lefttext = 11,
    		scale = 1.1,
    		formatHealth = true,
    	},
    	castbars = {
    		player = { x = 0, y = 150},
    		target = { x = 0, y = 550},
    	}     
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
                    Interface.settings.unitframes.scale = val
                end,
                get = function(info) return Interface.settings.unitframes.scale end
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
                    Interface.settings.unitframes.righttext = val
                end,
                get = function(info) return Interface.settings.unitframes.righttext end
            },
            formatHealth = {
				type = "toggle",
				name = "Format Health",
				width = "full",
				desc = "|cffaaaaaa Show health in M |r",
		        descStyle = "inline",
				order = 3,
				set = function(info,val) Interface.settings.unitframes.formatHealth = val
				end,
				get = function(info) return Interface.settings.unitframes.formatHealth end
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
	self:AfterEnable()
end

function Interface:AfterEnable()
	self:UnitFrames()
	self:Chat()
	self:Colors()
	self:Minimap()
	self:Buffs()
	self:CastBars()
	self:ItemLevel()
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
	Interface:RegisterFeature("BFAUI",
		"Use Battle For Azeroth UI",
		"Use Battle For Azeroth UI style.",
		false,
		true,
		function(state)
			if state then
				Interface:Bfa()
			else
				MicroMenuArt:Hide()
				ActionBarArtTexture:Hide()
				ActionBarArtSmallTexture:Hide() 
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
	local LARGE_AURA_SIZE = 23
	local SMALL_AURA_SIZE = 21
	local AURA_ROW_WIDTH = 122;

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
		hooksecurefunc("UnitFrameHealthBar_Update", ClassColor)
		hooksecurefunc("HealthBar_OnValueChanged", function(self)
			ClassColor(self, self.unit)
		end)

		function unit_ToVehicleArt(self, vehicleType)
		
		PlayerFrame.state = "vehicle";

		UnitFrame_SetUnit(self, "vehicle", PlayerFrameHealthBar, PlayerFrameManaBar);
		UnitFrame_SetUnit(PetFrame, "player", PetFrameHealthBar, PetFrameManaBar);
		PetFrame_Update(PetFrame);
		PlayerFrame_Update();
		BuffFrame_Update();
		ComboFrame_Update(ComboFrame);

		PlayerFrameTexture:Hide();
		if ( vehicleType == "Natural" ) then
			PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic");
			PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Organic-Flash");
			PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86);
			PlayerFrameHealthBar:SetSize(103,12);
			PlayerFrameHealthBar:SetPoint("TOPLEFT",116,-41);
			PlayerFrameManaBar:SetSize(103,12);
			PlayerFrameManaBar:SetPoint("TOPLEFT",116,-52);
		else
			PlayerFrameVehicleTexture:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame");
			PlayerFrameFlash:SetTexture("Interface\\Vehicles\\UI-Vehicle-Frame-Flash");
			PlayerFrameFlash:SetTexCoord(-0.02, 1, 0.07, 0.86);
			PlayerFrameHealthBar:SetSize(100,12);
			PlayerFrameHealthBar:SetPoint("TOPLEFT",119,-41);
			PlayerFrameManaBar:SetSize(100,12);
			PlayerFrameManaBar:SetPoint("TOPLEFT",119,-52);
		end
		PlayerFrame_ShowVehicleTexture();

		PlayerName:SetPoint("CENTER",50,23);
		PlayerLeaderIcon:SetPoint("TOPLEFT",40,-12);
		PlayerMasterIcon:SetPoint("TOPLEFT",86,0);
		PlayerFrameGroupIndicator:SetPoint("BOTTOMLEFT", PlayerFrame, "TOPLEFT", 97, -13);

		PlayerFrameBackground:SetWidth(114);
		PlayerLevelText:Hide();
	end
	hooksecurefunc("PlayerFrame_ToVehicleArt", unit_ToVehicleArt)
		
	hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",function(self,_,value,_,maxValue)
	  if self.RightText and value and maxValue>0 and not self.showPercentage and GetCVar("statusTextDisplay")=="BOTH" and Interface.settings.unitframes.formatHealth then
	    local k,m=1e3 
	    m=k*k
	 	self.RightText:SetText( (value>1e3 and  value<1e5 and  format("%1.3f",value/k))  or (value>=1e5 and  value<1e6 and  format("%1.0f K",value/k))  or (value>=1e6 and  value<1e9 and  format("%1.1f M",value/m))  or (value>=1e9 and  format("%1.1f M",value/m))  or value )
		end
	end)

	-- -- Hide
	-- hooksecurefunc("PlayerFrame_UpdateStatus",function()
	-- 	PlayerStatusTexture:Hide()
	-- 	PlayerRestGlow:Hide()
	--     PlayerStatusGlow:Hide() 
	--     PlayerPrestigeBadge:SetAlpha(0)
	--     PlayerPrestigePortrait:SetAlpha(0)
	--     TargetFrameTextureFramePrestigeBadge:SetAlpha(0)
	--     TargetFrameTextureFramePrestigePortrait:SetAlpha(0)
	--     FocusFrameTextureFramePrestigeBadge:SetAlpha(0)
	--     FocusFrameTextureFramePrestigePortrait:SetAlpha(0)
	-- end)

	--PLAYER
	function wPlayerFrame_ToPlayerArt(self)
		PlayerFrame:SetScale(Interface.settings.unitframes.scale) -- Scale
		PlayerName:SetPoint("CENTER", PlayerFrameHealthBar, 0, 23);
		PlayerFrameTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame");
		PlayerFrameGroupIndicatorText:ClearAllPoints();
		PlayerFrameGroupIndicatorText:SetPoint("BOTTOMLEFT", PlayerFrame,"TOP",0,-20);
		PlayerFrameGroupIndicatorLeft:Hide();
		PlayerFrameGroupIndicatorMiddle:Hide();
		PlayerFrameGroupIndicatorRight:Hide();
		PlayerFrameHealthBar:SetPoint("TOPLEFT",106,-24);
		PlayerFrameHealthBar:SetHeight(26);
		PlayerFrameHealthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
		PlayerFrameHealthBar.LeftText:ClearAllPoints();
		PlayerFrameHealthBar.LeftText:SetPoint("LEFT",PlayerFrameHealthBar,"LEFT",10,0);
		PlayerFrameHealthBar.LeftText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE") -- Left Text Size
		PlayerFrameHealthBar.RightText:ClearAllPoints();
		PlayerFrameHealthBar.RightText:SetPoint("RIGHT",PlayerFrameHealthBar,"RIGHT",-5,0);
		PlayerFrameHealthBar.RightText:SetFont("Fonts\\FRIZQT__.TTF", Interface.settings.unitframes.righttext, "OUTLINE") -- Right Text Size
		PlayerFrameHealthBarText:SetPoint("CENTER", PlayerFrameHealthBar, "CENTER", 0, 0);
		PlayerFrameManaBar:SetPoint("TOPLEFT",106,-52);
		PlayerFrameManaBar:SetHeight(13);
		PlayerFrameManaBar.LeftText:ClearAllPoints();
		PlayerFrameManaBar.LeftText:SetPoint("LEFT",PlayerFrameManaBar,"LEFT",10,0)		;
		PlayerFrameManaBar.RightText:ClearAllPoints();
		PlayerFrameManaBar.RightText:SetPoint("RIGHT",PlayerFrameManaBar,"RIGHT",-5,0);
		PlayerFrameManaBarText:SetPoint("CENTER",PlayerFrameManaBar,"CENTER",0,0);
		PlayerFrameManaBar.FeedbackFrame:ClearAllPoints();
		PlayerFrameManaBar.FeedbackFrame:SetPoint("CENTER",PlayerFrameManaBar,"CENTER",0,0);
		PlayerFrameManaBar.FeedbackFrame:SetHeight(13);
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:ClearAllPoints();
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:SetPoint("CENTER", PlayerFrameManaBar.FullPowerFrame, "RIGHT", -6, -3);
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.AlertSpikeStay:SetSize(30,29);
		PlayerFrameManaBar.FullPowerFrame.PulseFrame:ClearAllPoints();
		PlayerFrameManaBar.FullPowerFrame.PulseFrame:SetPoint("CENTER", PlayerFrameManaBar.FullPowerFrame,"CENTER",-6,-2);
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.BigSpikeGlow:ClearAllPoints();
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.BigSpikeGlow:SetPoint("CENTER",PlayerFrameManaBar.FullPowerFrame,"RIGHT",5,-4);
		PlayerFrameManaBar.FullPowerFrame.SpikeFrame.BigSpikeGlow:SetSize(30,50);
	end
	hooksecurefunc("PlayerFrame_ToPlayerArt", wPlayerFrame_ToPlayerArt)

	--TARGET
	function original_CheckClassification (self, forceNormalTexture)
		local classification = UnitClassification(self.unit);
		if not InCombatLockdown() then
			self:SetScale(Interface.settings.unitframes.scale) -- Scale
		end
		self.deadText:ClearAllPoints();
		self.deadText:SetPoint("CENTER", self.healthbar, "CENTER",0,0);
		self.nameBackground:Hide();
		self.Background:SetSize(119,42);

		self.manabar.pauseUpdates = false;
		self.manabar:Show();
		TextStatusBar_UpdateTextString(self.manabar);
		self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash");

		self.name:SetPoint("LEFT", self, 15, 36);
		self.healthbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");

		self.healthbar:SetSize(119, 26);
		self.healthbar:ClearAllPoints();
		self.healthbar:SetPoint("TOPLEFT", 5, -24);
		
		self.healthbar.LeftText:ClearAllPoints();
		self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 8, 0);
		self.healthbar.RightText:ClearAllPoints();
		self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -5, 0);
		self.healthbar.RightText:SetFont("Fonts\\FRIZQT__.TTF", Interface.settings.unitframes.righttext, "OUTLINE") -- Right Text Size
		self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0);
			
		self.manabar:ClearAllPoints();
		self.manabar:SetPoint("TOPLEFT", 5, -52);
		self.manabar:SetSize(119, 13);
			
		self.manabar.LeftText:ClearAllPoints();
		self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 8, 0);	
		self.manabar.RightText:ClearAllPoints();
		self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -5, 0);
		self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0);

		if ( forceNormalTexture ) then
			self.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame");
		elseif ( classification == "minus" ) then
			self.borderTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame");
			forceNormalTexture = true;
		elseif ( classification == "worldboss" or classification == "elite" ) then
			self.borderTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame-Elite");
		elseif ( classification == "rareelite" ) then
			self.borderTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame-Rare-Elite");
		elseif ( classification == "rare" ) then
			self.borderTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame-Rare");
		else
			self.borderTexture:SetTexture("Interface\\Addons\\JokUI\\media\\textures\\unitframes\\UI-TargetingFrame");
			forceNormalTexture = true;
		end
			
		if ( forceNormalTexture ) then
			self.haveElite = nil;
			if ( classification == "minus" ) then
				self.Background:SetSize(119,42);
				self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35);
				--
				self.nameBackground:Hide();
				self.name:SetPoint("LEFT", self, 15, 36);
				self.healthbar:ClearAllPoints();
				self.healthbar:SetPoint("LEFT", 5, 13);
			else
				self.Background:SetSize(119,42);
				self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35);
				
			end
			if ( self.threatIndicator ) then
				if ( classification == "minus" ) then
					self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash");
					self.threatIndicator:SetTexCoord(0, 1, 0, 1);
					self.threatIndicator:SetWidth(256);
					self.threatIndicator:SetHeight(128);
					self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
				else
					self.threatIndicator:SetTexCoord(0, 0.9453125, 0, 0.181640625);
					self.threatIndicator:SetWidth(242);
					self.threatIndicator:SetHeight(93);
					self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
					self.threatNumericIndicator:SetPoint("BOTTOM", PlayerFrame, "TOP", 75, -22);
				end
			end	
		else
			self.haveElite = true;
			TargetFrameBackground:SetSize(119,42);
			self.Background:SetSize(119,42);
			self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35);
			if ( self.threatIndicator ) then
				self.threatIndicator:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
				self.threatIndicator:SetWidth(242);
				self.threatIndicator:SetHeight(112);
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -22, 9);
			end		
		end
		
		if (self.questIcon) then
			if (UnitIsQuestBoss(self.unit)) then
				self.questIcon:Show();
			else
				self.questIcon:Hide();
			end
		end
	end
	hooksecurefunc("TargetFrame_CheckClassification", original_CheckClassification)

	--TargetOfTarget
		TargetFrameToTHealthBar:ClearAllPoints()
		TargetFrameToTHealthBar:SetPoint("TOPLEFT", 44, -15)
		TargetFrameToTHealthBar:SetHeight(10)
		TargetFrameToTManaBar:ClearAllPoints()
		TargetFrameToTManaBar:SetPoint("TOPLEFT", 44, -25)
		TargetFrameToTManaBar:SetHeight(5)
		FocusFrameToTHealthBar:ClearAllPoints()
		FocusFrameToTHealthBar:SetPoint("TOPLEFT", 45, -15)
		FocusFrameToTHealthBar:SetHeight(10)
		FocusFrameToTManaBar:ClearAllPoints()
		FocusFrameToTManaBar:SetPoint("TOPLEFT", 45, -25)
		FocusFrameToTManaBar:SetHeight(5)
		FocusFrameToT.deadText:SetWidth(0.01)

	--PET	
		PetFrameHealthBar:ClearAllPoints()
		PetFrameHealthBar:SetPoint("TOPLEFT", 45, -22)
		PetFrameHealthBar:SetHeight(10)
		PetFrameManaBar:ClearAllPoints()
		PetFrameManaBar:SetPoint("TOPLEFT", 45, -32)
		PetFrameManaBar:SetHeight(5)
		
	--BUFFS
	function unit:targetUpdateAuraPositions(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
		local size
		local offsetY = AURA_OFFSET_Y
		local rowWidth = 0
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

	--classcolor

    local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

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

	--apply aura frame texture func

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
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:SetDrawLayer("BACKGROUND",-8)
	b.icon = icon
	--border
	local border = _G[name.."Border"] or b:CreateTexture(name.."Border", "BACKGROUND", nil, -7)
	border:SetTexture("Interface\\AddOns\\JokUI\\media\\textures\\gloss")
	border:SetTexCoord(0, 1, 0, 1)
	border:SetDrawLayer("BACKGROUND",- 7)
	if b.buff then
		border:SetVertexColor(0.4, 0.35, 0.35)
	end
	border:ClearAllPoints()
	border:SetPoint("TOPLEFT", b, "TOPLEFT", -1, 1)
	border:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 1, -1)
	b.border = border
	--shadow
	local back = CreateFrame("Frame", nil, b)
	back:SetPoint("TOPLEFT", b, "TOPLEFT", -4, 4)
	back:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 4, -4)
	back:SetFrameLevel(b:GetFrameLevel() - 1)
	back:SetBackdrop(backdrop)
	back:SetBackdropBorderColor(0, 0, 0, 0.9)
	b.bg = back
	--set button styled variable
	b.styled = true
    end

	--apply castbar texture

    local function applycastSkin(b)
	if not b or (b and b.styled) then return end
	-- parent
	if b == CastingBarFrame.Icon then
		b.parent = CastingBarFrame
	elseif b == FocusFrameSpellBar.Icon then
		b.parent = FocusFrameSpellBar
	else
		b.parent = TargetFrameSpellBar
	end
	-- frame
	frame = CreateFrame("Frame", nil, b.parent)
    	--icon
    	b:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    	--border
    	local border = frame:CreateTexture(nil, "BACKGROUND")
    	border:SetTexture("Interface\\AddOns\\JokUI\\media\\textures\\gloss")
    	border:SetTexCoord(0, 1, 0, 1)
    	border:SetDrawLayer("BACKGROUND",- 7)
	    border:SetVertexColor(0.4, 0.35, 0.35)
    	border:ClearAllPoints()
	    border:SetPoint("TOPLEFT", b, "TOPLEFT", -1, 1)
      	border:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 1, -1)
    	b.border = border
	--shadow
	local back = CreateFrame("Frame", nil, b.parent)
	back:SetPoint("TOPLEFT", b, "TOPLEFT", -4, 4)
	back:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 4, -4)
	back:SetFrameLevel(frame:GetFrameLevel() - 1)
	back:SetBackdrop(backdrop)
	back:SetBackdropBorderColor(0, 0, 0, 0.9)
	b.bg = back
	--set button styled variable
	b.styled = true
    end

    -- setting timer for castbar icons

    function UpdateTimer(self, elapsed)
	total = total + elapsed
	if CastingBarFrame.Icon then
		applycastSkin(CastingBarFrame.Icon)
	end
	if TargetFrameSpellBar.Icon then
		applycastSkin(TargetFrameSpellBar.Icon)
	end
	if FocusFrameSpellBar.Icon then
		applycastSkin(FocusFrameSpellBar.Icon)
	end
	if CastingBarFrame.Icon.styled and TargetFrameSpellBar.Icon.styled then
		cf:SetScript("OnUpdate", nil)
	end
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

    total = 0
    cf = CreateFrame("Frame")
	cf:SetScript("OnUpdate", UpdateTimer)
end

function Interface:Chat()

	--URL COPY
	local find = string.find
	local gsub = string.gsub

	local found = false

	local function ColorURL(text, url)
	    found = true
	    return ' |H'..'url'..':'..tostring(url)..'|h'..'|cff0099FF'..tostring(url)..'|h|r '
	end

	local function ScanURL(frame, text, ...)
	    found = false

	    if (find(text:upper(), '%pTINTERFACE%p+')) then
	        found = true
	    end

	        -- 192.168.2.1:1234
	    if (not found) then
	        text = gsub(text, '(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)', ColorURL)
	    end
	        -- 192.168.2.1
	    if (not found) then
	        text = gsub(text, '(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)', ColorURL)
	    end
	        -- www.url.com:3333
	    if (not found) then
	        text = gsub(text, '(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)', ColorURL)
	    end
	        -- http://www.google.com
	    if (not found) then
	        text = gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", ColorURL)
	    end
	        -- www.google.com
	    if (not found) then
	        text = gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", ColorURL)
	    end
	        -- url@domain.com
	    if (not found) then
	        text = gsub(text, '(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)', ColorURL)
	    end

	    frame.add(frame, text,...)
	end

	local function EnableURLCopy()
	    for _, v in pairs(CHAT_FRAMES) do
	        local chat = _G[v]
	        if (chat and not chat.hasURLCopy and (chat ~= 'ChatFrame2')) then
	            chat.add = chat.AddMessage
	            chat.AddMessage = ScanURL
	            chat.hasURLCopy = true
	        end
	    end
	end
	hooksecurefunc('FCF_OpenTemporaryWindow', EnableURLCopy)

	local orig = ChatFrame_OnHyperlinkShow
	function ChatFrame_OnHyperlinkShow(frame, link, text, button)
	    local type, value = link:match('(%a+):(.+)')
	    if (type == 'url') then
	        local editBox = _G[frame:GetName()..'EditBox']
	        if (editBox) then
	            editBox:Show()
	            editBox:SetText(value)
	            editBox:SetFocus()
	            editBox:HighlightText()
	        end
	    else
	        orig(self, link, text, button)
	    end
	end

	EnableURLCopy()
end

function Interface:Colors()

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
		ReputationWatchBar.StatusBar.XPBarTexture0,
		ReputationWatchBar.StatusBar.XPBarTexture1,	
		ReputationWatchBar.StatusBar.XPBarTexture2,	
		ReputationWatchBar.StatusBar.XPBarTexture3,
		ReputationWatchBar.StatusBar.WatchBarTexture0,
		ReputationWatchBar.StatusBar.WatchBarTexture1,
		ReputationWatchBar.StatusBar.WatchBarTexture2,
		ReputationWatchBar.StatusBar.WatchBarTexture3,	
		ArtifactWatchBar.StatusBar.XPBarTexture0,
		ArtifactWatchBar.StatusBar.XPBarTexture1,
		ArtifactWatchBar.StatusBar.XPBarTexture2,
		ArtifactWatchBar.StatusBar.XPBarTexture3,
		ArtifactWatchBar.StatusBar.WatchBarTexture0,
		ArtifactWatchBar.StatusBar.WatchBarTexture1,
		ArtifactWatchBar.StatusBar.WatchBarTexture2,
		ArtifactWatchBar.StatusBar.WatchBarTexture3,
		HonorWatchBar.StatusBar.XPBarTexture0,
		HonorWatchBar.StatusBar.XPBarTexture1,
		HonorWatchBar.StatusBar.XPBarTexture2,
		HonorWatchBar.StatusBar.XPBarTexture3,
		HonorWatchBar.StatusBar.WatchBarTexture0,
		HonorWatchBar.StatusBar.WatchBarTexture1,
		HonorWatchBar.StatusBar.WatchBarTexture2,
		HonorWatchBar.StatusBar.WatchBarTexture3,
	}) do

		v:SetVertexColor(.15, .15, .15)
  
	end 	

	for i=1,19 do 
		_G["MainMenuXPBarDiv"..i]:SetTexture(Empty_Art) 
	end
	
	ArtifactWatchBar.Tick.Normal:SetVertexColor(0.4, 0.4, 0.4)
	ExhaustionTick:SetAlpha(0)
        for i,v in pairs({
			MainMenuBarLeftEndCap,
	        MainMenuBarRightEndCap, 
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

function Interface:Bfa()

	local function null()
	    -- I do nothing (for a reason)
	end

	--efficiant way to remove frames (does not work on textures)
	local function Kill(frame)
	    if type(frame) == 'table' and frame.SetScript then
	        frame:UnregisterAllEvents()
	        frame:SetScript('OnEvent',nil)
	        frame:SetScript('OnUpdate',nil)
	        frame:SetScript('OnHide',nil)
	        frame:Hide()
	        frame.SetScript = null
	        frame.RegisterEvent = null
	        frame.RegisterAllEvents = null
	        frame.Show = null
	    end
	end

	Kill(ReputationWatchBar)
	Kill(HonorWatchBar)
	Kill(MainMenuBarMaxLevelBar) --Fixed visual bug when unequipping artifact weapon at max level

	--disable "Show as Experience Bar" checkbox
	ReputationDetailMainScreenCheckBox:Disable()
	ReputationDetailMainScreenCheckBoxText:SetTextColor(.5,.5,.5)

	--------------------==≡≡[ XP BAR ]≡≡==-----------------------------------

	for i = 1, 19 do --for loop, hides MainMenuXPBarDiv (1-19)
	   _G["MainMenuXPBarDiv" .. i]:Hide()
	end

	MainMenuXPBarTextureMid:Hide()
	MainMenuXPBarTextureLeftCap:Hide()
	MainMenuXPBarTextureRightCap:Hide()
	MainMenuExpBar:SetFrameStrata("LOW")
	ExhaustionTick:SetFrameStrata("MEDIUM")

	MainMenuBarExpText:ClearAllPoints()
	MainMenuBarExpText:SetPoint("CENTER",MainMenuExpBar,0,-1)

	MainMenuBarOverlayFrame:SetFrameStrata("MEDIUM") --changes xp bar text strata

	--------------------==≡≡[ ARTIFACT BAR ]≡≡==-----------------------------------

	ArtifactWatchBar.StatusBar.XPBarTexture0:SetTexture(nil)
	ArtifactWatchBar.StatusBar.XPBarTexture1:SetTexture(nil)
	ArtifactWatchBar.StatusBar.XPBarTexture2:SetTexture(nil)
	ArtifactWatchBar.StatusBar.XPBarTexture3:SetTexture(nil)

	--stops Artiact bar from moving around
	local function UpdateArtifactWatchBar()
		ArtifactWatchBar:ClearAllPoints()
		ArtifactWatchBar:SetPoint("BOTTOM",UIParent,"BOTTOM",0,0)
		ArtifactWatchBar:SetFrameStrata("MEDIUM")
		ArtifactWatchBar.StatusBar.Background:SetAlpha(0)
		ArtifactWatchBar.OverlayFrame.Text:ClearAllPoints()
		ArtifactWatchBar.OverlayFrame.Text:SetPoint("CENTER",ArtifactWatchBar.OverlayFrame,0,-1)
		local WeaponQuality = GetInventoryItemQuality("player", 16) --artifact quality is 6
		if ( UnitLevel("player") ~= MAX_PLAYER_LEVEL and IsXPUserDisabled() == false ) or ( WeaponQuality ~= 6 ) then
			ArtifactWatchBar:Hide()
		else
			ArtifactWatchBar:Show()
		end
	end
	local f=CreateFrame("Frame")
	hooksecurefunc("MainMenuBar_UpdateExperienceBars", UpdateArtifactWatchBar) --prevents movement on BGs, and most events

	--------------------==≡≡[ MICRO MENU MOVEMENT, POSITIONING AND SIZING ]≡≡==----------------------------------

	local function MoveMicroButtons_Hook(...)
		local hasVehicleUI = UnitHasVehicleUI("player")
		local isInBattle = C_PetBattles.IsInBattle("player")
		if hasVehicleUI == false and isInBattle == false then
			MoveMicroButtonsToBottomRight()
		else --set micro menu to vehicle ui + pet battle positions and sizes:
			for i=1, #MICRO_BUTTONS do
				_G[MICRO_BUTTONS[i]]:SetSize(28,58)
			end
			MainMenuBarPerformanceBar:SetPoint("CENTER",MainMenuMicroButton,0,0)
			MicroButtonPortrait:SetPoint("TOP",CharacterMicroButton,0,-28)
			MicroButtonPortrait:SetSize(18,25)
			GuildMicroButtonTabard:SetPoint("TOPLEFT",GuildMicroButton,0,0)
			GuildMicroButtonTabard:SetSize(28,58)
			GuildMicroButtonTabardEmblem:SetPoint("CENTER",GuildMicroButtonTabard,0,-9)
			GuildMicroButtonTabardEmblem:SetSize(16,16)
			GuildMicroButtonTabardBackground:SetSize(30,60)

			CharacterMicroButtonFlash:SetSize(64,64)
			CharacterMicroButtonFlash:SetPoint("TOPLEFT",CharacterMicroButton,-2,-18)
			SpellbookMicroButtonFlash:SetSize(64,64)
			SpellbookMicroButtonFlash:SetPoint("TOPLEFT",SpellbookMicroButton,-2,-18)
			TalentMicroButtonFlash:SetSize(64,64)
			TalentMicroButtonFlash:SetPoint("TOPLEFT",TalentMicroButton,-2,-18)
			AchievementMicroButtonFlash:SetSize(64,64)
			AchievementMicroButtonFlash:SetPoint("TOPLEFT",AchievementMicroButton,-2,-18)
			QuestLogMicroButtonFlash:SetSize(64,64)
			QuestLogMicroButtonFlash:SetPoint("TOPLEFT",QuestLogMicroButton,-2,-18)
			GuildMicroButtonFlash:SetSize(64,64)
			GuildMicroButtonFlash:SetPoint("TOPLEFT",GuildMicroButton,-2,-18)
			LFDMicroButtonFlash:SetSize(64,64)
			LFDMicroButtonFlash:SetPoint("TOPLEFT",LFDMicroButton,-2,-18)
			CollectionsMicroButtonFlash:SetSize(64,64)
			CollectionsMicroButtonFlash:SetPoint("TOPLEFT",CollectionsMicroButton,-2,-18)
			EJMicroButtonFlash:SetSize(64,64)
			EJMicroButtonFlash:SetPoint("TOPLEFT",EJMicroButton,-2,-18)
			StoreMicroButtonFlash:SetSize(64,64)
			StoreMicroButtonFlash:SetPoint("TOPLEFT",StoreMicroButton,-2,-18)
			MainMenuMicroButtonFlash:SetSize(64,64)
			MainMenuMicroButtonFlash:SetPoint("TOPLEFT",MainMenuMicroButton,-2,-18)

			MicroMenuArt:Hide()
		end
	end
	hooksecurefunc("MoveMicroButtons", MoveMicroButtons_Hook)
	hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", MoveMicroButtons_Hook)


	function MoveMicroButtonsToBottomRight()
		for i=1, #MICRO_BUTTONS do --select micro menu buttons
		  v = _G[MICRO_BUTTONS[i]]
		  v:ClearAllPoints()
		  v:SetSize(24,44) --Originally w=28 h=58
		end
		QuickJoinToastButton:Hide()
		CharacterMicroButton:SetPoint("BOTTOMRIGHT",UIParent,-244,4)
		SpellbookMicroButton:SetPoint("BOTTOMRIGHT",CharacterMicroButton,24,0)
		TalentMicroButton:SetPoint("BOTTOMRIGHT",SpellbookMicroButton,24,0)
		AchievementMicroButton:SetPoint("BOTTOMRIGHT",TalentMicroButton,24,0)
		QuestLogMicroButton:SetPoint("BOTTOMRIGHT",AchievementMicroButton,24,0)
		GuildMicroButton:SetPoint("BOTTOMRIGHT",QuestLogMicroButton,24,0)
		LFDMicroButton:SetPoint("BOTTOMRIGHT",GuildMicroButton,24,0)
		CollectionsMicroButton:SetPoint("BOTTOMRIGHT",LFDMicroButton,24,0)
		EJMicroButton:SetPoint("BOTTOMRIGHT",CollectionsMicroButton,24,0)
		StoreMicroButton:SetPoint("BOTTOMRIGHT",EJMicroButton,24,0)
		MainMenuMicroButton:SetPoint("BOTTOMRIGHT",StoreMicroButton,24,0)

		MicroButtonPortrait:SetPoint("TOP",CharacterMicroButton,0,-20) --Originally "TOP",CharacterMicroButton", "TOP", 0, -28
		MicroButtonPortrait:SetSize(16,20) --Originally w=18 h=25
		GuildMicroButtonTabard:SetPoint("CENTER",GuildMicroButton,0,0) --Originally "TOPLEFT",GuildMicroButton", "TOPLEFT", 0, 0
		GuildMicroButtonTabard:SetSize(24,44) --Originally w=28 h=58
		GuildMicroButtonTabardEmblem:SetPoint("CENTER",GuildMicroButtonTabard,0,-7) --Originally "CENTER",GuildMicroButtonTabard", "CENTER", 0, -9
		GuildMicroButtonTabardEmblem:SetSize(11,11) --Originally w=16 h=16
		GuildMicroButtonTabardBackground:SetSize(24,50) --Originally w=30 h=60
		MainMenuBarPerformanceBar:SetPoint("CENTER",MainMenuMicroButton,0,5) --Originally "CENTER",MainMenuMicroButton", "CENTER", 0, 0
		MicroMenuArt:Show()
		MicroMenuArtTexture:SetVertexColor(.25,.25,.25)
		MicroMenuArt:SetFrameStrata("BACKGROUND")

		CharacterMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		CharacterMicroButtonFlash:SetPoint("TOPLEFT",CharacterMicroButton,-1,-14) -- Originally ("TOPLEFT",CharacterMicroButton,"TOPLEFT",-2,-18)
		SpellbookMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		SpellbookMicroButtonFlash:SetPoint("TOPLEFT",SpellbookMicroButton,-1,-14) -- Originally ("TOPLEFT",SpellbookMicroButton,"TOPLEFT",-2,-18)
		TalentMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		TalentMicroButtonFlash:SetPoint("TOPLEFT",TalentMicroButton,-1,-14) -- Originally ("TOPLEFT",TalentMicroButton,"TOPLEFT",-2,-18)
		AchievementMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		AchievementMicroButtonFlash:SetPoint("TOPLEFT",AchievementMicroButton,-1,-14) -- Originally ("TOPLEFT",AchievementMicroButton,"TOPLEFT",-2,-18)
		QuestLogMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		QuestLogMicroButtonFlash:SetPoint("TOPLEFT",QuestLogMicroButton,-1,-14) -- Originally ("TOPLEFT",QuestLogMicroButton,"TOPLEFT",-2,-18)
		GuildMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		GuildMicroButtonFlash:SetPoint("TOPLEFT",GuildMicroButton,-1,-14) -- Originally ("TOPLEFT",GuildMicroButton,"TOPLEFT",-2,-18)
		LFDMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		LFDMicroButtonFlash:SetPoint("TOPLEFT",LFDMicroButton,-1,-14) -- Originally ("TOPLEFT",LFDMicroButton,"TOPLEFT",-2,-18)
		CollectionsMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		CollectionsMicroButtonFlash:SetPoint("TOPLEFT",CollectionsMicroButton,-1,-14) -- Originally ("TOPLEFT",CollectionsMicroButton,"TOPLEFT",-2,-18)
		EJMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		EJMicroButtonFlash:SetPoint("TOPLEFT",EJMicroButton,-1,-14) -- Originally ("TOPLEFT",EJMicroButton,"TOPLEFT",-2,-18)
		StoreMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		StoreMicroButtonFlash:SetPoint("TOPLEFT",StoreMicroButton,-1,-14) -- Originally ("TOPLEFT",StoreMicroButton,"TOPLEFT",-2,-18)
		MainMenuMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
		MainMenuMicroButtonFlash:SetPoint("TOPLEFT",MainMenuMicroButton,-1,-14) -- Originally ("TOPLEFT",MainMenuMicroButton,"TOPLEFT",-2,-18)
	end
	local f=CreateFrame("Frame")
	f:RegisterEvent("PET_BATTLE_CLOSE")
	f:SetScript("OnEvent", MoveMicroButtonsToBottomRight)


	--------------------==≡≡[ ACTIONBARS/BUTTONS POSITIONING AND SCALING ]≡≡==-----------------------------------

		if not InCombatLockdown() then
			--reposition bottom left actionbuttons
			MultiBarBottomLeftButton1:SetPoint("BOTTOMLEFT",MultiBarBottomLeft,0,-6)

			--reposition bottom right actionbar
			MultiBarBottomRight:SetPoint("LEFT",MultiBarBottomLeft,"RIGHT",43,-6)

			--reposition second half of top right bar, underneath
			MultiBarBottomRightButton7:SetPoint("LEFT",MultiBarBottomRight,0,-48)

			--reposition right bottom
			MultiBarLeftButton1:SetPoint("TOPRIGHT",MultiBarLeft,0,200)

			--reposition bags
			MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT",UIParent,-4,39)

			--reposition pet actionbuttons
			SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,1,-5) -- pet bar texture (displayed when bottom left bar is hidden)
			PetActionButton1:ClearAllPoints()
			PetActionButton1:SetPoint("TOP",PetActionBarFrame,"LEFT",51,4)

			--stance buttons
			StanceBarLeft:SetPoint("BOTTOMLEFT",StanceBarFrame,0,-5) --stance bar texture for when Bottom Left Bar is hidden
			StanceButton1:ClearAllPoints()
		end


	local function ActivateLongBar()
		ActionBarArt:Show()
		ActionBarArtSmall:Hide()
		ActionBarArtTexture:SetVertexColor(.25,.25,.25)
		if not InCombatLockdown() then
			--arrows and page number
			ActionBarUpButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-23)
			ActionBarDownButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-42)
			MainMenuBarPageNumber:SetPoint("CENTER",MainMenuBarArtFrame,28,-5)

			--exp bar sizing and positioning
			MainMenuExpBar:SetSize(800,11)
			MainMenuExpBar:ClearAllPoints()
			MainMenuExpBar:SetPoint("BOTTOM",UIParent,0,0)

			--artifact bar sizing
			ArtifactWatchBar:SetSize(800,11)
			ArtifactWatchBar.StatusBar:SetSize(800,11)

			--reposition ALL actionbars (right bars not affected)
			MainMenuBar:SetPoint("BOTTOM",UIParent,110,11)

			--xp bar background (the one I made)
			XPBarBackground:SetSize(800,11)
			XPBarBackground:SetPoint("BOTTOM",MainMenuBar,-110,-11)

			MainMenuBar_ArtifactUpdateTick() --Blizzard function

			if ExhaustionTick:IsShown() then
				ExhaustionTick_OnEvent(ExhaustionTick, "UPDATE_EXHAUSTION") --Blizzard function, updates exhaustion tick position on XP bar resize
			end
		end
	end

	function ActivateShortBar()
		ActionBarArt:Hide()
		ActionBarArtSmall:Show()
		ActionBarArtSmallTexture:SetVertexColor(.25,.25,.25)
		if not InCombatLockdown() then
			--arrows and page number
			ActionBarUpButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-23)
			ActionBarDownButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-42)
			MainMenuBarPageNumber:SetPoint("CENTER",MainMenuBarArtFrame,29,-5)

			--exp bar sizing and positioning
			MainMenuExpBar:SetSize(542,10)
			MainMenuExpBar:ClearAllPoints()
			MainMenuExpBar:SetPoint("BOTTOM",UIParent,0,0)

			--artifact bar sizing
			ArtifactWatchBar:SetSize(542,10)
			ArtifactWatchBar.StatusBar:SetSize(542,10)

			--reposition ALL actionbars (right bars not affected)
			MainMenuBar:SetPoint("BOTTOM",UIParent,237,11)

			--xp bar background (the one I made)
			XPBarBackground:SetSize(542,10)
			XPBarBackground:SetPoint("BOTTOM",MainMenuBar,-237,-11)

			MainMenuBar_ArtifactUpdateTick() --Blizzard function

			if ExhaustionTick:IsShown() then
				ExhaustionTick_OnEvent(ExhaustionTick, "UPDATE_EXHAUSTION") --Blizzard function, updates exhaustion tick position on XP bar resize
			end
		end
	end

	local function Update_ActionBars()
		if not InCombatLockdown() then
			--Bottom Left Bar:
			if MultiBarBottomLeft:IsShown() then
				PetActionButton1:SetPoint("TOP",PetActionBarFrame,"LEFT",51,4)
				StanceButton1:SetPoint("LEFT",StanceBarFrame,2,-4)
			else
				PetActionButton1:SetPoint("TOP",PetActionBarFrame,"LEFT",51,7)
				StanceButton1:SetPoint("LEFT",StanceBarFrame,12,-2)
			end

			-- --Right Bar:
			-- if MultiBarRight:IsShown() then
			-- 	--do
			-- else
			-- end

			--Right Bar 2:
			if MultiBarLeft:IsShown() then
				--make MultiBarRight smaller 
				MultiBarRightButton1:SetPoint("TOPRIGHT",MultiBarRight,0,200)
			else
				--make MultiBarRight bigger and vertically more centered, maybe also move objective frame
				MultiBarRightButton1:SetPoint("TOPRIGHT",MultiBarRight,-2,64)
			end
		end

		--Bottom Right Bar: (needs to be run in or out of combat, this is for the art when exiting vehicles in combat)
		if MultiBarBottomRight:IsShown() == true then
			ActivateLongBar()
		else
			ActivateShortBar()
		end
	end
	MultiBarBottomLeft:HookScript('OnShow', Update_ActionBars)
	MultiBarBottomLeft:HookScript('OnHide', Update_ActionBars)
	MultiBarBottomRight:HookScript('OnShow', Update_ActionBars)
	MultiBarBottomRight:HookScript('OnHide', Update_ActionBars)
	MultiBarRight:HookScript('OnShow', Update_ActionBars)
	MultiBarRight:HookScript('OnHide', Update_ActionBars)
	MultiBarLeft:HookScript('OnShow', Update_ActionBars)
	MultiBarLeft:HookScript('OnHide', Update_ActionBars)
	local f=CreateFrame("Frame")
	f:RegisterEvent("PLAYER_LOGIN") --Required to check bar visibility on load
	f:SetScript("OnEvent", Update_ActionBars)



	local function PlayerEnteredCombat()
		InterfaceOptionsActionBarsPanelTitle:SetText("ActionBars - |cffFF0000You must leave combat to toggle the ActionBars")
		InterfaceOptionsActionBarsPanelBottomLeft:Disable()
		InterfaceOptionsActionBarsPanelBottomRight:Disable()
		InterfaceOptionsActionBarsPanelRight:Disable()
		InterfaceOptionsActionBarsPanelRightTwo:Disable()
	end
	local f=CreateFrame("Frame")
	f:RegisterEvent("PLAYER_REGEN_DISABLED")
	f:SetScript("OnEvent", PlayerEnteredCombat)

	local function PlayerLeftCombat()
		InterfaceOptionsActionBarsPanelTitle:SetText("ActionBars")
		InterfaceOptionsActionBarsPanelBottomLeft:Enable()
		InterfaceOptionsActionBarsPanelBottomRight:Enable()
		InterfaceOptionsActionBarsPanelRight:Enable()
		InterfaceOptionsActionBarsPanelRightTwo:Enable()

		Update_ActionBars()
	end
	local f=CreateFrame("Frame")
	f:RegisterEvent("PLAYER_REGEN_ENABLED")
	f:SetScript("OnEvent", PlayerLeftCombat)



	--------------------==≡≡[ OBJECTIVE TRACKER, VEHICLE SEAT INDICATOR, ENEMY ARENA FRAMES ]≡≡==-----------------------------------

	--fixes Blizzard's bug by removing all achievements that are tracked but not visible on the objective tracker:
	--the "bug" seems to occur when completing an achievement on one character, while it is tracked on another
	--code example; if GetNumTrackedAchievements() = 1 but no visible achievements, then remove the invisible tracked achievement
	local function RemoveInvisibleTrackedAchievements()
		local t1,t2,t3,t4,t5,t6,t7,t8,t9,t10 = GetTrackedAchievements()
		local table = {t1,t2,t3,t4,t5,t6,t7,t8,t9,t10}
		for i = 1, 10 do
		   if table[i] ~= nil then
		      local _, _, _, _, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(table[i])
		      if wasEarnedByMe then
		         RemoveTrackedAchievement(table[i])
		      end
		   end
		end
	end
	local f=CreateFrame("Frame")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", RemoveInvisibleTrackedAchievements)

	ObjectiveTrackerBlocksFrame:SetPoint("TOPRIGHT",UIParent,-54,-700)


	local function VehicleSeatIndicator_Positioning()
		if VehicleSeatIndicator:IsShown() then
			VehicleSeatIndicator:ClearAllPoints()
			point3 = "TOPRIGHT"
			relativeTo3 = MinimapCluster
			relativePoint3 = "BOTTOMRIGHT"
			xOffset3 = -99
			yOffset3 = 0
			if ArenaEnemyFrames ~= nil and ArenaEnemyFrames:IsShown() then --ArenaEnemyFrames visible:
				VehicleSeatIndicator:SetPoint(point3,relativeTo3,relativePoint3,xOffset3,yOffset3)
				print("ArenaEnemyFrames visible")
			elseif ObjectiveTrackerFrame.HeaderMenu:IsShown() then --active Objectives (minimize button shown):
				if ObjectiveTrackerFrame.collapsed then --minimized Objectives:
					point1 = "TOPRIGHT"
					relativeTo1 = ObjectiveTrackerBlocksFrame
					relativePoint1 = "TOPLEFT"
					xOffset1 = 160
					yOffset1 = 0
					VehicleSeatIndicator:SetPoint(point1,relativeTo1,relativePoint1,xOffset1,yOffset1)
				else --expanded Objectives:
					point2 = "TOPRIGHT"
					relativeTo2 = ObjectiveTrackerBlocksFrame
					relativePoint2 = "TOPLEFT"
					xOffset2 = -15
					yOffset2 = 0
					VehicleSeatIndicator:SetPoint(point2,relativeTo2,relativePoint2,xOffset2,yOffset2)
				end
			else --no active Objectives (minimize button not shown):
				VehicleSeatIndicator:SetPoint(point3,relativeTo3,relativePoint3,xOffset3,yOffset3)
			end
		end
	end
	hooksecurefunc("ObjectiveTracker_Update", VehicleSeatIndicator_Positioning) --also works on clicking the minimise/expand button

	hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(self,_,_,_,xOffset)
		if (xOffset~=xOffset1) and (xOffset~=xOffset2) and (xOffset~=xOffset3) then
			VehicleSeatIndicator_Positioning()
		end
	end)
	--Objective Tracker positioning .. reference: https://us.battle.net/forums/en/wow/topic/15141304174#2
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent",function(self,event,addon)
		if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
			ObjectiveTrackerBlocksFrame:SetPoint("TOPRIGHT",UIParent,-54,-700)
			hooksecurefunc(ObjectiveTrackerFrame,"SetPoint",function(self,Point,RelativeTo)
				if IsAddOnLoaded("Blizzard_ArenaUI") and ArenaEnemyFrames:IsShown() then  --ArenaEnemyFrames visible:
					--[[
					for i = 1, 5 do
	   					if (Point~="TOPRIGHT") and (RelativeTo~="ArenaEnemyFrame"..i) and (_G["ArenaEnemyFrame"..i]:IsShown()) then
					    ObjectiveTrackerFrame:SetPoint("TOPRIGHT",_G["ArenaEnemyFrame"..i],"BOTTOM",45,-20)
					    print("RelativeTo, set to ArenaEnemyFrame"..i)
					   end
					end
					]]
				else --ArenaEnemyFrames NOT visible:
					if (Point~="TOPRIGHT") and (RelativeTo~=UIParent) then
						ObjectiveTrackerBlocksFrame:SetPoint("TOPRIGHT",UIParent,-54,-700)
					end
				end
			end)
	    	self:UnregisterEvent("ADDON_LOADED")
		else
	    	self:RegisterEvent("ADDON_LOADED")
	  	end
	end)
	f:RegisterEvent("PLAYER_LOGIN")

	--------------------==≡≡[ BLIZZARD TEXTURES ]≡≡==-----------------------------------

	--hide Blizzard art textures
	MainMenuBarLeftEndCap:Hide()
	MainMenuBarRightEndCap:Hide()

	for i = 0, 3 do --for loop, hides MainMenuBarTexture (0-3)
	   _G["MainMenuBarTexture" .. i]:Hide()
	end
end

function Interface:CastBars()
	local max = math.max
	local format = string.format

	if not InCombatLockdown() then

		UIPARENT_MANAGED_FRAME_POSITIONS["CastingBarFrame"] = nil

		-- Player Castbar
		CastingBarFrame:SetMovable(true)
		CastingBarFrame:ClearAllPoints()
		CastingBarFrame:SetScale(1)
		-- CastingBarFrame:SetPoint("BOTTOM", UIParent,"BOTTOM", 0, Interface.settings.castbars.playery)
		CastingBarFrame:SetUserPlaced(true)
		CastingBarFrame:SetMovable(false)
		CastingBarFrame:SetScale(1)
 		CastingBarFrame.Icon:Show()
		CastingBarFrame.Icon:ClearAllPoints()
		CastingBarFrame.Icon:SetTexCoord(.08, .92, .08, .92)
		CastingBarFrame.Icon:SetSize(20, 20)
    	CastingBarFrame.Icon:SetPoint("RIGHT", CastingBarFrame, "LEFT", -7, 0)
  		CastingBarFrame.Text:ClearAllPoints()
  		CastingBarFrame.Text:SetPoint("CENTER", 0, 1)
  		CastingBarFrame.BorderShield:SetWidth(CastingBarFrame.BorderShield:GetWidth() + 4)
  		CastingBarFrame.Border:SetPoint("TOP", 0, 26)
 		CastingBarFrame.Flash:SetPoint("TOP", 0, 26)
		CastingBarFrame.BorderShield:SetPoint("TOP", 0, 26)
		
		-- Player Timer
		CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
		CastingBarFrame.timer:SetFont(STANDARD_TEXT_FONT, 14,'THINOUTLINE')
		CastingBarFrame.timer:SetPoint("LEFT", CastingBarFrame, "RIGHT", 7, 0)
		CastingBarFrame.update = 0.1

  		-- Target Castbar
		TargetFrameSpellBar:SetMovable(true)
  		TargetFrameSpellBar:ClearAllPoints()
 		TargetFrameSpellBar:SetScale(1.4)
 		TargetFrameSpellBar:SetPoint("CENTER",CastingBarFrame,"CENTER", 0, Interface.settings.castbars.target.y)
		TargetFrameSpellBar:SetUserPlaced(true)
		TargetFrameSpellBar:SetMovable(false)
		TargetFrameSpellBar.Icon:SetTexCoord(.08, .92, .08, .92)
  		TargetFrameSpellBar.Icon:SetPoint("RIGHT", TargetFrameSpellBar, "LEFT", -3, 0)
  		TargetFrameSpellBar.SetPoint = function() end

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
	if not (IsAddOnLoaded("SexyMap")) then
		for i,v in pairs({
			MinimapBorder,
			MiniMapMailBorder,
			QueueStatusMinimapButtonBorder,
			select(1, TimeManagerClockButton:GetRegions()),
          		}) do
             		v:SetVertexColor(.14, .14, .14)
	    end
		select(2, TimeManagerClockButton:GetRegions()):SetVertexColor(1,1,1)

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
end

function Interface:Buffs()

	--rCreateDragFrame func
	function rCreateDragFrame(self, dragFrameList, inset, clamp)
	    if not self or not dragFrameList then return end
	    self.defaultPoint = rGetPoint(self)
	    table.insert(dragFrameList,self)

	    local df = CreateFrame("Frame",nil,self)
	    df:SetAllPoints(self)
	    df:SetFrameStrata("HIGH")
	    df:SetHitRectInsets(inset or 0,inset or 0,inset or 0,inset or 0)
	    df:EnableMouse(true)
	    df:RegisterForDrag("LeftButton")
	    df:SetScript("OnDragStart", function(self) if IsAltKeyDown() and IsShiftKeyDown() then self:GetParent():StartMoving() end end)
	    df:SetScript("OnDragStop", function(self) self:GetParent():StopMovingOrSizing() end)
	    df:SetScript("OnEnter", function(self)
	      GameTooltip:SetOwner(self, "ANCHOR_TOP")
	      GameTooltip:AddLine(self:GetParent():GetName(), 0, 1, 0.5, 1, 1, 1)
	      GameTooltip:AddLine("Hold down ALT+SHIFT to drag!", 1, 1, 1, 1, 1, 1)
	      GameTooltip:Show()
	    end)
	    df:SetScript("OnLeave", function(s) GameTooltip:Hide() end)
	    df:Hide()

	    local t = df:CreateTexture(nil,"OVERLAY",nil,6)
	    t:SetAllPoints(df)
	    t:SetTexture(0,1,0)
	    t:SetAlpha(0.2)
	    df.texture = t

	    self.dragFrame = df
	    self:SetClampedToScreen(clamp or false)
	    self:SetMovable(true)
	    self:SetUserPlaced(true)
	end

	--rewrite the oneletter shortcuts

	  if adjustOneletterAbbrev then
	    HOUR_ONELETTER_ABBR = "%dh"
	    DAY_ONELETTER_ABBR = "%dd"
	    MINUTE_ONELETTER_ABBR = "%dm"
	    SECOND_ONELETTER_ABBR = "%ds"
	  end

	--classcolor

	  local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

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
	  local ShouldShowConsolidatedBuffFrame = ShouldShowConsolidatedBuffFrame
	  
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
	  if buffFrame.userplaced then
	    rCreateDragFrame(bf, dragFrameList, -2 , true) --frame, dragFrameList, inset, clamp
	  end

	--debuff drag frame

	    local df = CreateFrame("Frame", "rBFS_DebuffDragFrame", UIParent)
	    df:SetSize(debuffFrame.button.size,debuffFrame.button.size)
	    df:SetPoint(debuffFrame.pos.a1,debuffFrame.pos.af,debuffFrame.pos.a2,debuffFrame.pos.x,debuffFrame.pos.y)
	    if debuffFrame.userplaced then
	      rCreateDragFrame(df, dragFrameList, -2 , true) --frame, dragFrameList, inset, clamp
	    end

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

function Interface:ItemLevel()
	local MAJOR, MINOR = "LibItemLevel.7000", 1
	local lib = LibStub:NewLibrary(MAJOR, MINOR)

	if not lib then
	    return
	end

	local ItemLevelPattern = gsub(ITEM_LEVEL, "%%d", "(%%d+)")

	local tooltip = CreateFrame("GameTooltip", "LibItemLevelTooltip1", UIParent, "GameTooltipTemplate")
	local unittip = CreateFrame("GameTooltip", "LibItemLevelTooltip2", UIParent, "GameTooltipTemplate")

	function lib:hasLocally(ItemID)
	    if (not ItemID or ItemID == "" or ItemID == "0") then
	        return true
	    end
	    return select(10, GetItemInfo(tonumber(ItemID)))
	end

	function lib:itemLocally(ItemLink)
	    local id, gem1, gem2, gem3 = string.match(ItemLink, "item:(%d+):[^:]*:(%d-):(%d-):(%d-):")
	    return (self:hasLocally(id) and self:hasLocally(gem1) and self:hasLocally(gem2) and self:hasLocally(gem3))
	end

	function lib:GetItemInfo(ItemLink)
	    if (not ItemLink or ItemLink == "") then
	        return 0, 0
	    end
	    if (not string.match(ItemLink, "item:%d+:")) then
	        return -1, 0
	    end
	    if (not self:itemLocally(ItemLink)) then
	        return 1, 0
	    end
	    local level, text
	    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	    tooltip:ClearLines()
	    tooltip:SetHyperlink(ItemLink)
	    for i = 2, 5 do
	        text = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText() or ""
	        level = string.match(text, ItemLevelPattern)
	        if (level) then
	            break
	        end
	    end
	    return 0, tonumber(level) or 0, GetItemInfo(ItemLink)
	end

	LibItemLevel = LibStub:GetLibrary("LibItemLevel.7000");

	function lib:GetUnitItemInfo(unit, index)
	    if (not UnitExists(unit)) then
	        return 1, 0
	    end
	    unittip:SetOwner(UIParent, "ANCHOR_NONE")
	    unittip:ClearLines()
	    unittip:SetInventoryItem(unit, index)
	    local ItemLink = select(2, unittip:GetItem())
	    if (not ItemLink or ItemLink == "") then
	        return 0, 0
	    end
	    if (not self:itemLocally(ItemLink)) then
	        return 1, 0
	    end
	    local level, text
	    for i = 2, 5 do
	        text = _G[unittip:GetName() .. "TextLeft" .. i]:GetText() or ""
	        level = string.match(text, ItemLevelPattern)
	        if (level) then
	            break
	        end
	    end
	    return 0, tonumber(level) or 0, GetItemInfo(ItemLink)
	end

	function lib:GetUnitItemLevel(unit)
	    local total, counts = 0, 0
	    local _, count, level
	    for i = 1, 15 do
	        if (i ~= 4) then
	            count, level = self:GetUnitItemInfo(unit, i)
	            total = total + level
	            counts = counts + count
	        end
	    end
	    local mcount, mlevel, mquality, mslot, ocount, olevel, oquality, oslot
	    mcount, mlevel, _, _, mquality, _, _, _, _, _, mslot = self:GetUnitItemInfo(unit, 16)
	    ocount, olevel, _, _, oquality, _, _, _, _, _, oslot = self:GetUnitItemInfo(unit, 17)
	    counts = counts + mcount + ocount

	    if (mquality == 6 or oslot == "INVTYPE_2HWEAPON" or mslot == "INVTYPE_2HWEAPON" or mslot == "INVTYPE_RANGED" or mslot == "INVTYPE_RANGEDRIGHT") then
	        total = total + max(mlevel, olevel) * 2
	    else
	        total = total + mlevel + olevel
	    end
	    return counts, total / (16 - counts), total
	end

	function ShowPaperDollItemLevel(self, unit)
	    result = "";
	    id = self:GetID();
	    if id == 4 or id > 17 then
	        return
	    end;
	    if not self.levelString then
	        self.levelString = self:CreateFontString(nil, "OVERLAY");
	        self.levelString:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE");
	        self.levelString:SetPoint("TOP");
	        self.levelString:SetTextColor(1, 0.82, 0);
	    end;
	    if unit and self.hasItem then
	        _, level, _, _, quality = LibItemLevel:GetUnitItemInfo(unit, id);
	        if level > 0 and quality > 2 then
	            self.levelString:SetText(level);
	            result = true;
	        end;
	    else
	        self.levelString:SetText("");
	        result = true;
	    end;
	    if id == 16 or id == 17 then
	        _, offhand, _, _, quality = LibItemLevel:GetUnitItemInfo(unit, 17);
	        if quality == 6 then
	            _, mainhand = LibItemLevel:GetUnitItemInfo(unit, 16);
	            self.levelString:SetText(math.max(mainhand, offhand));
	        end;
	    end;
	    return result;
	end;
	hooksecurefunc("PaperDollItemSlotButton_Update", function(self)
	    ShowPaperDollItemLevel(self, "player");
	end);

	function SetContainerItemLevel(button, ItemLink)
	    if not button then
	        return
	    end;
	    if not button.levelString then
	        button.levelString = button:CreateFontString(nil, "OVERLAY");
	        button.levelString:SetFont(STANDARD_TEXT_FONT, 12, "THICKOUTLINE");
	        button.levelString:SetPoint("TOP");
	    end;
	    if button.origItemLink ~= ItemLink then
	        button.origItemLink = ItemLink;
	    else return
	    end;
	    if ItemLink then
	        count, level, _, _, quality, _, _, class, subclass, _, _ = LibItemLevel:GetItemInfo(ItemLink);
	        name, _ = GetItemSpell(ItemLink);
	        _, equipped, _ = GetAverageItemLevel();
	        if level >= (98 * equipped / 100) then
	            button.levelString:SetTextColor(0, 1, 0);
	        else
	            button.levelString:SetTextColor(1, 1, 1);
	        end;
	        if count == 0 and level > 0 and quality > 1 then
	            button.levelString:SetText(level);
	        else
	            button.levelString:SetText("");
	        end;
	    else
	        button.levelString:SetText("");
	    end;
	end;
	hooksecurefunc("ContainerFrame_Update", function(self)
	    local name = self:GetName();
	    for i = 1, self.size do
	        local button = _G[name .. "Item" .. i];
	        SetContainerItemLevel(button, GetContainerItemLink(self:GetID(), button:GetID()));
	    end;
	end);
end
