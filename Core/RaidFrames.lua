local _, JokUI = ...
local RaidFrames = JokUI:RegisterModule("Raid Frames")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local features = {}

local ABSORB_GLOW_ALPHA = 0.6;
local ABSORB_GLOW_OFFSET = -5;

local font = STANDARD_TEXT_FONT

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local raidframes_defaults = {
    profile = {
    	Buffs = {
        	debuffscale = 25,
        	buffscale = 25,
    	},   
        RaidFade = {
        	fadealpha = .3,	
			backgroundalpha = .7,
    	},        
		Cooldowns = {
    		enable = true,
			iconSize = 30, 
			iconGap = 5,
			position = "LEFT",
			x = -5,
			y = 0,
    	},            
    }
}

local raidframes_config = {
    title = {
        type = "description",
        name = "|cff64b4ffRaid Frames",
        fontSize = "large",
        order = 0,
    },
    desc = {
        type = "description",
        name = "Various useful options for Raid Frames.\n",
        fontSize = "medium",
        order = 1,
    },
    buffScale = {
		type = "range",
		isPercent = false,
		name = "Buff Size",
		desc = "",
		min = 20,
		max = 45,
		step = 1,
		order = 3,
		disabled = function() return true end,
		set = function(info,val) RaidFrames.settings.Buffs.buffscale = val
		end,
		get = function(info) return RaidFrames.settings.Buffs.buffscale end
	},
	debuffScale = {
		type = "range",
		isPercent = false,
		name = "Debuff Size",
		desc = "",
		min = 20,
		max = 45,
		step = 1,
		order = 4,
		disabled = function() return true end,
		set = function(info,val) RaidFrames.settings.Buffs.debuffscale = val
		end,
		get = function(info) return RaidFrames.settings.Buffs.debuffscale end
	},
	fadealpha = {
		type = "range",
		isPercent = false,
		name = "Alpha",
		desc = "",
		min = 0,
		max = 1,
		step = 0.05,
		order = 13,
		disabled = function(info) return not RaidFrames.settings.FadeMore end,
		set = function(info,val) RaidFrames.settings.RaidFade.fadealpha = val
		end,
		get = function(info) return RaidFrames.settings.RaidFade.fadealpha end
	},
	backgroundalpha = {
		type = "range",
		isPercent = false,
		name = "Background Alpha",
		desc = "",
		min = 0,
		max = 1,
		step = 0.05,
		order = 14,
		disabled = function(info) return not RaidFrames.settings.FadeMore end,
		set = function(info,val) RaidFrames.settings.RaidFade.backgroundalpha = val
		end,
		get = function(info) return RaidFrames.settings.RaidFade.backgroundalpha end
	},
	enableCooldowns = {
		type = "toggle",
		name = "Enable",
		width = "full",
		order = 15,
		set = function(info,val) RaidFrames.settings.Cooldowns.enable = val
		end,
		get = function(info) return RaidFrames.settings.Cooldowns.enable end
	},
	cooldowns = {
        name = "Raid Frame Cooldowns",
        type = "group",
        inline = true,
        order = 16,
        disabled = function() return not RaidFrames.settings.Cooldowns.enable end,
        args = {
        	iconSize = {
                type = "range",
                name = "Icon Size",
                desc = "",
                min = 20,
                max = 50,
                step = 1,
                order = 1,
                set = function(info,val) RaidFrames.settings.Cooldowns.iconSize = val
                JokUI.EditCDBar("size")
                end,
                get = function(info, val) return RaidFrames.settings.Cooldowns.iconSize end
            },
            iconGap = {
                type = "range",
                name = "Icon Space",
                desc = "",
                min = 0,
                max = 15,
                step = 1,
                order = 2,
                set = function(info,val) RaidFrames.settings.Cooldowns.iconGap = val
                JokUI.EditCDBar("pos")
                end,
                get = function(info, val) return RaidFrames.settings.Cooldowns.iconGap end
            },
            offsetX = {
                type = "range",
                name = "Offset X",
                desc = "",
                min = -30,
                max = 30,
                step = 1,
                order = 3,
                set = function(info,val) RaidFrames.settings.Cooldowns.x = val
                JokUI.EditCDBar("pos")
                end,
                get = function(info, val) return RaidFrames.settings.Cooldowns.x end
            },
            offsetY = {
                type = "range",
                name = "Offset Y",
                desc = "",
                min = -30,
                max = 30,
                step = 1,
                order = 4,
                set = function(info,val) RaidFrames.settings.Cooldowns.y = val
                JokUI.EditCDBar("pos")
                end,
                get = function(info, val) return RaidFrames.settings.Cooldowns.y end
            },
            position = {
                type = "select",
                style = "dropdown",
                name = "Position",
                desc = "",
                width = "full",
                values = {
							["BOTTOM"] = "BOTTOM",
							["TOP"] = "TOP",
							["RIGHT"] = "LEFT",
							["LEFT"] = "RIGHT",
						},
                order = 5,
                set = function(info,val) RaidFrames.settings.Cooldowns.position = val
                JokUI.EditCDBar("pos")
                end,
                get = function(info, val) return RaidFrames.settings.Cooldowns.position end
            },
        },
    },
}

function RaidFrames:OnInitialize()
    self.db = JokUI.db:RegisterNamespace("Raid Frames", raidframes_defaults)
    self.settings = self.db.profile
    JokUI.Config:Register("Raid Frames", raidframes_config)
end

function RaidFrames:OnEnable()
	for name in pairs(features) do
		self:SyncFeature(name)
	end

	if RaidFrames.settings.Cooldowns.enable then
		self:Cooldowns()
	end

	self:Misc()
end

do
	local order = 10
	function RaidFrames:RegisterFeature(name, short, long, default, reload, fn)
		raidframes_config[name] = {
			type = "toggle",
			name = short,
			descStyle = "inline",
			desc = "|cffaaaaaa" .. long,
			width = "full",
			get = function() return RaidFrames.settings[name] end,
			set = function(_, v)
				RaidFrames.settings[name] = v
				RaidFrames:SyncFeature(name)
				if reload then
					StaticPopup_Show ("ReloadUI_Popup")
				end
			end,
			order = order
		}
		raidframes_defaults.profile[name] = default
		order = order + 1
		features[name] = fn
	end
end

function RaidFrames:SyncFeature(name)
	features[name](RaidFrames.settings[name])
end

do
	RaidFrames:RegisterFeature("ShowAbsorb",
		"Show Absorb",
		"Show an absorb texture on Raid Frames.",
		true,
		true,
		function(state)
			if state then
				RaidFrames:ShowAbsorb()
			end
		end)
end

do
	RaidFrames:RegisterFeature("FadeMore",
		"Raid Fade More",
		"Improve the range fade on Raid Frames.",
		true,
		true,
		function(state)
			if state then
				RaidFrames:FadeMore()
			end
		end)
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

function RaidFrames:ShowAbsorb()
	hooksecurefunc("UnitFrame_Update", function(frame)
		local absorbBar = frame.totalAbsorbBar;
		if ( not absorbBar or absorbBar:IsForbidden()  ) then return end

		local absorbOverlay = frame.totalAbsorbBarOverlay;
		if ( not absorbOverlay or absorbOverlay:IsForbidden() ) then return end
		
		local healthBar = frame.healthbar;
		if ( not healthBar or healthBar:IsForbidden() ) then return end
		
		absorbOverlay:SetParent(healthBar);
		absorbOverlay:ClearAllPoints();		--we'll be attaching the overlay on heal prediction update.
	  	
	  	local absorbGlow = frame.overAbsorbGlow;
	  	if ( absorbGlow and not absorbGlow:IsForbidden() ) then
			absorbGlow:ClearAllPoints();
			absorbGlow:SetPoint("TOPLEFT", absorbOverlay, "TOPLEFT", ABSORB_GLOW_OFFSET, 0);
		  	absorbGlow:SetPoint("BOTTOMLEFT", absorbOverlay, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, 0);
		  	absorbGlow:SetAlpha(ABSORB_GLOW_ALPHA);
	  	end
	end)

	hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
		local absorbBar = frame.totalAbsorb;
		if ( not absorbBar or absorbBar:IsForbidden()  ) then return end
		
		local absorbOverlay = frame.totalAbsorbOverlay;
		if ( not absorbOverlay or absorbOverlay:IsForbidden() ) then return end
		
		local healthBar = frame.healthBar;
		if ( not healthBar or healthBar:IsForbidden() ) then return end
		
		absorbOverlay:SetParent(healthBar);
		absorbOverlay:ClearAllPoints();		--we'll be attaching the overlay on heal prediction update.
		
		local absorbGlow = frame.overAbsorbGlow;
	  	if ( absorbGlow and not absorbGlow:IsForbidden() ) then
			absorbGlow:ClearAllPoints();
			absorbGlow:SetPoint("TOPLEFT", absorbOverlay, "TOPLEFT", ABSORB_GLOW_OFFSET, 0);
		  	absorbGlow:SetPoint("BOTTOMLEFT", absorbOverlay, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, 0);
		  	absorbGlow:SetAlpha(ABSORB_GLOW_ALPHA);
	  	end
	end)

	hooksecurefunc("UnitFrameHealPredictionBars_Update", function(frame)
		local absorbBar = frame.totalAbsorbBar;
		if ( not absorbBar or absorbBar:IsForbidden()  ) then return end
		
		local absorbOverlay = frame.totalAbsorbBarOverlay;
		if ( not absorbOverlay or absorbOverlay:IsForbidden() ) then return end
		
		local healthBar = frame.healthbar;
		if ( not healthBar or healthBar:IsForbidden() ) then return end
		
		local _, maxHealth = healthBar:GetMinMaxValues();
		if ( maxHealth <= 0 ) then return end
		
		local totalAbsorb = UnitGetTotalAbsorbs(frame.unit) or 0;
		if( totalAbsorb > maxHealth ) then
			totalAbsorb = maxHealth;
		end
				
		if( totalAbsorb > 0 ) then	--show overlay when there's a positive absorb amount
			if ( absorbBar:IsShown() ) then		--If absorb bar is shown, attach absorb overlay to it; otherwise, attach to health bar.
		  		absorbOverlay:SetPoint("TOPRIGHT", absorbBar, "TOPRIGHT", 0, 0);
		  		absorbOverlay:SetPoint("BOTTOMRIGHT", absorbBar, "BOTTOMRIGHT", 0, 0);
			else
				absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0);
	    		absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0);	    			
			end

			local totalWidth, totalHeight = healthBar:GetSize();			
			local barSize = totalAbsorb / maxHealth * totalWidth;
			
			absorbOverlay:SetWidth( barSize );
    		absorbOverlay:SetTexCoord(0, barSize / absorbOverlay.tileSize, 0, totalHeight / absorbOverlay.tileSize);
		  	absorbOverlay:Show();			
		  		
			--frame.overAbsorbGlow:Show();	--uncomment this if you want to ALWAYS show the glow to the left of the shield overlay
		end
	end)

	hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", function(frame)
		local absorbBar = frame.totalAbsorb;
		if ( not absorbBar or absorbBar:IsForbidden()  ) then return end
		
		local absorbOverlay = frame.totalAbsorbOverlay;
		if ( not absorbOverlay or absorbOverlay:IsForbidden() ) then return end
		
		local healthBar = frame.healthBar;
		if ( not healthBar or healthBar:IsForbidden() ) then return end
		
		local _, maxHealth = healthBar:GetMinMaxValues();
		if ( maxHealth <= 0 ) then return end
		
		local totalAbsorb = UnitGetTotalAbsorbs(frame.displayedUnit) or 0;
		if( totalAbsorb > maxHealth ) then
			totalAbsorb = maxHealth;
		end
		
		if( totalAbsorb > 0 ) then	--show overlay when there's a positive absorb amount
			if ( absorbBar:IsShown() ) then		--If absorb bar is shown, attach absorb overlay to it; otherwise, attach to health bar.
		  		absorbOverlay:SetPoint("TOPRIGHT", absorbBar, "TOPRIGHT", 0, 0);
		  		absorbOverlay:SetPoint("BOTTOMRIGHT", absorbBar, "BOTTOMRIGHT", 0, 0);
			else
				absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0);
	    		absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0);	    			
			end

			local totalWidth, totalHeight = healthBar:GetSize();			
			local barSize = totalAbsorb / maxHealth * totalWidth;
			
			absorbOverlay:SetWidth( barSize );
    		absorbOverlay:SetTexCoord(0, barSize / absorbOverlay.tileSize, 0, totalHeight / absorbOverlay.tileSize);
		  	absorbOverlay:Show();
		  	
		  	--frame.overAbsorbGlow:Show();	--uncomment this if you want to ALWAYS show the glow to the left of the shield overlay
		end		
	end)
end
	
function RaidFrames:FadeMore()

	local group = {
		part = true, -- party, only check char 1 to 4
		raid = true,	
	}

	hooksecurefunc("CompactUnitFrame_UpdateInRange", function(frame)
		if not group[strsub(frame.displayedUnit, 1, 4)] then return end -- ignore player, nameplates
		local inRange, checkedRange = UnitInRange(frame.displayedUnit)
		
		if checkedRange and not inRange then
			frame:SetAlpha(RaidFrames.settings.RaidFade.fadealpha)
			frame.background:SetAlpha(RaidFrames.settings.RaidFade.backgroundalpha)
		else
			frame:SetAlpha(1)
			frame.background:SetAlpha(1)
		end
	end)
end

function RaidFrames:Misc()
	-- RAID FRAMES SIZE DEFAULT SLIDER
	local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame" h,w=
	_G[n.."HeightSlider"],
	_G[n.."WidthSlider"] 
	h:SetMinMaxValues(1,200) 
	w:SetMinMaxValues(1,200)
end

function RaidFrames:Cooldowns()

	--[[------------------------
	--     Group Inspect     --
	------------------------]]--

	JokCooldowns = LibStub("AceAddon-3.0"):NewAddon("JokCooldowns")

	if not JokCooldowns then return end

	JokCooldowns.Roster = {}
	JokCooldowns.Frames = {}

	if not JokCooldowns.events then
		JokCooldowns.events = LibStub("CallbackHandler-1.0"):New(JokCooldowns)
	end

	--[[
		1 WAR - 
			ARMS = 71 
			FURY = 72  
			PROT = 73

		2 PALADIN - 
			RET = 70  
			HOLY = 65  
			PROT = 66

		3 HUNT - 
			MARKSMANSHIP = 254  
			BM = 253  
			SURVIVAL = 255

		4 ROGUE -
			SIN = 259  
			SUB = 260  
			OUTLAW = 261

		5 PRIEST -  
			DISC = 256  
			SHADOW = 258  
			HOLY = 257

		6 DK - 
			BLOOD = 250  
			FROST = 251  
			UNHOLY = 252

		7 SHAMAN - 
			ELEM = 262 
			EHNANCEMENT = 263  
			RESTO = 264

		8 MAGE - 
			ARCANE = 62  
			FIRE = 63  
			FROST = 64

		9 WARLOCK - 
			AFFLICTION = 265 
			DEMO = 266  
			DESTRO = 267

		10 MONK - 
			BREWMASTER = 268  
			WINDWALKER = 269
			MISTWEAVER = 270 

		11 DRUID - 
			BALANCE = 102  
			FERAL = 103  
			GUARDIAN = 104  
			RESTO = 105

		12 DH - 
			HAVOC = 577  
			VENGEANCE = 581
	]]--

	local Cooldowns = {
		-- 1 = WARRIOR
		["WARRIOR"] = {
			["871"] = {spellID = 871, cd = 240, spec = 73, talent = "all"}, -- SHIELD WALL
			["12975"] = {spellID = 12975, cd = 180, spec = 73, talent = "all"}, -- LAST STAND
			["118038"] = {spellID = 118038, cd = 180, spec = 71, talent = "all"}, -- DIE BY THE SWORD
			["184364"] = {spellID = 184364, cd = 120, spec = 72, talent = "all"}, -- ENRAGED REGENERATION
		},

		-- 2 = PALADIN
		["PALADIN"] = {
			-- HOLY = 65
			["642_11"] = {spellID = 642, cd = 210, spec =65, talent = 17575}, -- DIVINE SHIELD
			["642_12"] = {spellID = 642, cd = 300, spec =65, talent = 22176}, -- DIVINE SHIELD
			["642_13"] = {spellID = 642, cd = 300, spec =65, talent = 17577}, -- DIVINE SHIELD
			["1022_1"] = {spellID = 1022, cd = 240, spec =65, talent = "all"}, -- BLESSING OF PROTECTION
			["31821"] = {spellID = 31821, cd = 180, spec =65, talent = "all"}, -- AURA MASTERY

			-- PROT = 66
			["642_21"] = {spellID = 642, cd = 300, spec =66, talent = 22705}, -- DIVINE SHIELD_PROT
			["642_22"] = {spellID = 642, cd = 210, spec =66, talent = 21795}, -- DIVINE SHIELD_PROT
			["642_23"] = {spellID = 642, cd = 300, spec =66, talent = 17601}, -- DIVINE SHIELD_PROT		
			["1022_21"] = {spellID = 1022, cd = 300, spec =66, talent = 22433}, -- BLESSING OF PROTECTION_PROT
			["1022_22"] = {spellID = 1022, cd = 300, spec =66, talent = 22434}, -- BLESSING OF PROTECTION_PROT
			["204018"] = {spellID = 204018, cd = 180, spec =66, talent = 22435}, -- BLESSING OF SPELLWARDING			
			--["31850"] = {spellID = 31850, cd = 120, spec =66, talent = "all"}, -- ARDENT DEFENDER
			--["86659"] = {spellID = 86659, cd = 300, spec =66, talent = "all"}, -- GUARDIAN OF ANCIENTS KINGS

			-- RET = 70
			["642_31"] = {spellID = 642, cd = 210, spec =70, talent = 22185}, -- DIVINE SHIELD
			["642_32"] = {spellID = 642, cd = 300, spec =70, talent = 22595}, -- DIVINE SHIELD
			["642_33"] = {spellID = 642, cd = 300, spec =70, talent = 22186}, -- DIVINE SHIELD
			["1022_3"] = {spellID = 1022, cd = 240, spec =70, talent = "all"}, -- BLESSING OF PROTECTION
		},

		-- 3 = HUNTER
		["HUNTER"] = {
			-- ALL
			["186265"] = {spellID = 186265, cd = 180, spec = "all", talent = "all"}, -- TURTLE
		},

		-- 4 = ROGUE
		["ROGUE"] = {
			-- ALL
			["31224"] = {spellID = 31224, cd = 90, spec = "all", talent = "all"}, -- CLOAK OF SHADOW
		},

		-- 5 = PRIEST
		["PRIEST"] = {
			["47585"] = {spellID = 47585, cd = 80, spec = 258, talent = "all"}, -- DISPERSION
		},

		-- 6 = DEATH KNIGHT
		["DEATHKNIGHT"] = {
			["48707"] = {spellID = 48707, cd = 60, spec = "all", talent = "all"}, -- AMS
			["48792"] = {spellID = 48792, cd = 180, spec = "all", talent = "all"}, -- IBF
			["55233"] = {spellID = 55233, cd = 90, spec = 250, talent = "all"}, -- VAMPIRIC BLOOD
			["49028"] = {spellID = 49028, cd = 180, spec = 250, talent = "all"}, -- DANCING RUNIC WEAPON
			
		},	

		-- 7 = SHAMAN
		["SHAMAN"] = {
			-- ALL
			["108271"] = {spellID = 108271, cd = 90, spec = "all", talent = "all"}, -- ASTRAL SHIFT
		},

		-- 8 = MAGE
		["MAGE"] = {
			-- ALL
			["45438"] = {spellID = 45438, cd = 240, spec ="all", talent = "all"}, -- ICEBLOCK

			-- ARCANE = 62
			-- FIRE = 63

			-- FROST = 64
			["235219"] = {spellID = 235219, cd = 300, spec =64, talent = "all"}, -- COLD SNAP
		},		

		-- 9 = WARLOCK
		["WARLOCK"] = {
			["104773_1"] = {spellID = 104773, cd = 180, spec = 265, talent = "all"}, -- UNENDING RESOLVE
			["104773_2"] = {spellID = 104773, cd = 180, spec = 267, talent = "all"}, -- UNENDING RESOLVE	
		},
		
		-- 10 = MONK
		["MONK"] = {
			["115203"] = {spellID = 115203, cd = 420, spec = 268, talent = "all"}, -- FORTIFYING BREW
			["122470"] = {spellID = 122470, cd = 90, spec = 269, talent = "all"}, -- TOUCH OF KARMA
			["122783"] = {spellID = 122783, cd = 90, spec = 269, talent = 20173}, -- DIFFUSE MAGIC
		},
		
		-- 11 = DRUID
		["DRUID"] = {
			-- BALANCE = 102
			["22812_1"] = {spellID = 22812, cd = 60, spec = 102, talent = "all"}, -- BARSKIN_BALANCE

			-- FERAL = 103		
			["61336_2"] = {spellID = 61336, cd = 120, spec = 103, charge = 2, talent = "all"}, -- SURVIVAL_FERAL

			-- GUARDIAN = 104
			["22812_3"] = {spellID = 22812, cd = 90, spec = 104, talent = "all"}, -- BARSKIN_GUARDIAN
			["61336_3"] = {spellID = 61336, cd = 240, spec = 104, charge = 2, talent = "all"}, -- SURVIVAL_GUARDIAN

			-- RESTO = 105
			["22812_4"] = {spellID = 22812, cd = 60, spec = 105, talent = "all"}, -- BARSKIN_RESTO			
		},

		-- 12 = DEMON HUNTER
		["DEMONHUNTER"] = {
			-- HAVOC = 577
			["196555"] = {spellID = 196555, cd = 120, spec = 577, talent = 21863}, -- NETHERWALK
			["198589"] = {spellID = 198589, cd = 60, spec = 577, talent = "all"}, -- BLUR

			-- VENGEANCE = 581
		},			
	}

	for _, c in pairs(Cooldowns) do
		if IsActiveBattlefieldArena() then
			c["208683"] = {spellID = 208683, cd = 120, spec = "all", talent = "all"}
		end
	end

	local function CreateBorder(f, r, g, b)
		if f.style then return end
		
		f.sd = CreateFrame("Frame", nil, f)
		local lvl = f:GetFrameLevel()
		f.sd:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
		f.sd:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\AddOns\\SMT\\media\\glow",
			edgeSize = 3,
				insets = { left = 3, right = 3, top = 3, bottom = 3,}
			})
		f.sd:SetPoint("TOPLEFT", f, -3, 3)
		f.sd:SetPoint("BOTTOMRIGHT", f, 3, -3)
		if not (r and g and b) then
			f.sd:SetBackdropColor(.05, .05, .05, .5)
			f.sd:SetBackdropBorderColor(0, 0, 0)
		else
			f.sd:SetBackdropColor(r, g, b, .5)
			f.sd:SetBackdropBorderColor(r, g, b)
		end
		f.style = true
	end

	local function CreateText(frame, layer, fontsize, flag, justifyh, shadow)
		local text = frame:CreateFontString(nil, layer)
		text:SetFont(font, fontsize, flag)
		text:SetJustifyH(justifyh)
		
		if shadow then
			text:SetShadowColor(0, 0, 0)
			text:SetShadowOffset(1, -1)
		end
		
		return text
	end

	local function CreateIcon(f)
		local icon = CreateFrame("Frame", nil, f)
		icon:SetSize(RaidFrames.settings.Cooldowns.iconSize, RaidFrames.settings.Cooldowns.iconSize)
		CreateBorder(icon)
		
		icon.spellID = 0
		
		icon.cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
		icon.cd:SetAllPoints(icon)
        icon.cd:SetDrawEdge(false)
		icon.cd:SetAlpha(.9)
		icon.cd:SetScript("OnShow", function()
			if not JokCooldowns['Roster'][icon.player_name] or not JokCooldowns['Roster'][icon.player_name][icon.spellID] then return end
			if JokCooldowns['Roster'][icon.player_name][icon.spellID]["charge"] then
				icon:SetAlpha(1)
			else
				icon:SetAlpha(1)
			end
		end)
		icon.cd:SetScript("OnHide", function()	
			if JokCooldowns['Roster'][icon.player_name] and JokCooldowns['Roster'][icon.player_name][icon.spellID] and JokCooldowns['Roster'][icon.player_name][icon.spellID]["charge"] then
				if JokCooldowns['Roster'][icon.player_name][icon.spellID]["charge"] == JokCooldowns['Roster'][icon.player_name][icon.spellID]["max_charge"] then return end
				JokCooldowns['Roster'][icon.player_name][icon.spellID]["charge"] = JokCooldowns['Roster'][icon.player_name][icon.spellID]["charge"] + 1
				icon.count:SetText(JokCooldowns['Roster'][icon.player_name][icon.spellID]["charge"])
				if JokCooldowns['Roster'][icon.player_name][icon.spellID]["charge"] ~= JokCooldowns['Roster'][icon.player_name][icon.spellID]["max_charge"] then
					icon.cd:SetCooldown(GetTime(), JokCooldowns['Roster'][icon.player_name][icon.spellID]["dur"])
				end
			else
				icon:SetAlpha(1)
				f.lineup()
			end
		end)
		
		icon.tex = icon:CreateTexture(nil, "OVERLAY")
		icon.tex:SetAllPoints(icon)
		icon.tex:SetTexCoord( .1, .9, .1, .9)
		
		icon.count = CreateText(icon, "OVERLAY", 16, "OUTLINE", "RIGHT")
		icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)

		table.insert(f.icons, icon)
	end

	local function GetRemain(Cooldown)
		local startTime, duration = Cooldown:GetCooldownTimes()
		local remain
		if duration == 0 then
			remain = 0
		else
			remain = duration - (GetTime() - startTime)
		end
		return remain
	end

	local function CreateCDBar(unit)
		local f = CreateFrame("Frame", nil, UIParent)
		f:SetSize(RaidFrames.settings.Cooldowns.iconSize, RaidFrames.settings.Cooldowns.iconSize)
		f.icons = {}
		
		for i = 1, 6 do
			CreateIcon(f)
		end
		
		f.point = function()
			f:ClearAllPoints()			
			
			for i=1, 8 do
				for j=1, 5 do
					local uf = _G["CompactRaidGroup"..i.."Member"..j]
					if uf and uf:IsVisible() and uf.unit and UnitIsUnit(uf.unit, unit) then
						if RaidFrames.settings.Cooldowns.position == "RIGHT" then
							f:SetPoint("RIGHT", uf, "LEFT", RaidFrames.settings.Cooldowns.x, RaidFrames.settings.Cooldowns.y)
						elseif RaidFrames.settings.Cooldowns.position == "LEFT" then
							f:SetPoint("LEFT", uf, "RIGHT", -RaidFrames.settings.Cooldowns.x, RaidFrames.settings.Cooldowns.y)
						elseif RaidFrames.settings.Cooldowns.position == "BOTTOM" then
							f:SetPoint("BOTTOM", uf, "TOP", RaidFrames.settings.Cooldowns.x, RaidFrames.settings.Cooldowns.y)
						elseif RaidFrames.settings.Cooldowns.position == "TOP" then
							f:SetPoint("TOP", uf, "BOTTOM", RaidFrames.settings.Cooldowns.x, -RaidFrames.settings.Cooldowns.y)
						end
						break
					end
				end
			end

			if CompactRaidFrameContainer.groupMode == "flush" then
				for i=1, 40 do
				local uf = _G["CompactRaidFrame"..i]
				if uf and uf.unitExists and uf.unit and UnitIsUnit(uf.unit, unit) then
					if RaidFrames.settings.Cooldowns.position == "RIGHT" then
						f:SetPoint("RIGHT", uf, "LEFT", RaidFrames.settings.Cooldowns.x, RaidFrames.settings.Cooldowns.y)
					elseif RaidFrames.settings.Cooldowns.position == "LEFT" then
						f:SetPoint("LEFT", uf, "RIGHT", -RaidFrames.settings.Cooldowns.x, RaidFrames.settings.Cooldowns.y)
					elseif RaidFrames.settings.Cooldowns.position == "BOTTOM" then
						f:SetPoint("BOTTOM", uf, "TOP", RaidFrames.settings.Cooldowns.x, RaidFrames.settings.Cooldowns.y)
					elseif RaidFrames.settings.Cooldowns.position == "TOP" then
						f:SetPoint("TOP", uf, "BOTTOM", RaidFrames.settings.Cooldowns.x, -RaidFrames.settings.Cooldowns.y)
					end
					break
				end
			end
			else
				for j=1, 5 do
					local uf = _G["CompactPartyFrameMember"..j]
					if uf and uf.unitExists and uf.unit and UnitIsUnit(uf.unit, unit) then
						if RaidFrames.settings.Cooldowns.position == "RIGHT" then
							f:SetPoint("RIGHT", uf, "LEFT", RaidFrames.settings.Cooldowns.x, RaidFrames.settings.Cooldowns.y)
						elseif RaidFrames.settings.Cooldowns.position == "LEFT" then
							f:SetPoint("LEFT", uf, "RIGHT", -RaidFrames.settings.Cooldowns.x, RaidFrames.settings.Cooldowns.y)
						elseif RaidFrames.settings.Cooldowns.position == "BOTTOM" then
							f:SetPoint("BOTTOM", uf, "TOP", RaidFrames.settings.Cooldowns.x, RaidFrames.settings.Cooldowns.y)
						elseif RaidFrames.settings.Cooldowns.position == "TOP" then
							f:SetPoint("TOP", uf, "BOTTOM", RaidFrames.settings.Cooldowns.x, -RaidFrames.settings.Cooldowns.y)
						end
						break
					end
				end
			end
		end
		
		
		f.reset = function()
			for i = 1,6 do
				f.icons[i]:Hide()
				f.icons[i]["spellID"] = 0
				f.icons[i]["tex"]:SetTexture(nil)
				f.icons[i]["cd"]:SetCooldown(0,0)		
			end
		end
		
		f.update_size = function()
			for i = 1,6 do
				f.icons[i]:SetSize(RaidFrames.settings.Cooldowns.iconSize, RaidFrames.settings.Cooldowns.iconSize)
			end
		end
		
		f.update_unit = function()
			f.reset()
			
			f.name = UnitName(unit)

			if f.name then
				local spell_num = 0
				if JokCooldowns['Roster'][f.name] then
					for spellid, info in pairs(JokCooldowns['Roster'][f.name]) do
						if spellid ~= "spec" then
							spell_num = spell_num + 1
							f.icons[spell_num]["spellID"] = spellid
							f.icons[spell_num]["player_name"] = f.name
							f.icons[spell_num]["tex"]:SetTexture(select(3, GetSpellInfo(spellid)))
							if info["charge"] then
								f.icons[spell_num]["count"]:SetText(info["charge"])
							else
								f.icons[spell_num]["count"]:SetText("")
							end
							f.icons[spell_num]:Show()
						end
					end
				end
			end
			
		end
		
		f.update_cd = function(spellid)
			if f.name then
				if spellid then		
					for i = 1, 6 do
						if f.icons[i]["spellID"] == spellid and JokCooldowns['Roster'][f.name][spellid] then
							local info = JokCooldowns['Roster'][f.name][spellid]
							if info["start"] and info["start"] + info["dur"] > GetTime() then
								if JokCooldowns['Roster'][f.name][spellid]["charge"] then
									if JokCooldowns['Roster'][f.name][spellid]["charge"] == JokCooldowns['Roster'][f.name][spellid]["max_charge"] then
										f.icons[i]["cd"]:SetCooldown(info["start"], info["dur"])
									end
									JokCooldowns['Roster'][f.name][spellid]["charge"] = JokCooldowns['Roster'][f.name][spellid]["charge"] - 1
									f.icons[i]["count"]:SetText(JokCooldowns['Roster'][f.name][spellid]["charge"])
									if JokCooldowns['Roster'][f.name][spellid]["charge"] == 0 then
										f.icons[i]:SetAlpha(0.8)
									end
								else
									f.icons[i]["cd"]:SetCooldown(info["start"], info["dur"])
									f.icons[i]["count"]:SetText("")
								end
							else
								f.icons[i]["cd"]:SetCooldown(0,0)		
							end
							break
						end
						
					end
				else
					for i = 1, 6 do
						local icon_spellid = f.icons[i]["spellID"]
						if icon_spellid ~= 0 and JokCooldowns['Roster'][f.name][icon_spellid] then
							local info = JokCooldowns['Roster'][f.name][icon_spellid]
							if info["start"] and info["start"] + info["dur"] > GetTime() then
								f.icons[i]["cd"]:SetCooldown(info["start"], info["dur"])
							end
						end
					end
				end
			end
		end
		
		f.lineup = function()
			if not IsInGroup() then return end
			
			table.sort(f.icons, function(a,b)
				--if not a.cd or b.cd then return end
				if a.spellID ~= 0 and b.spellID ~= 0 then
					if GetRemain(a.cd) < GetRemain(b.cd) then
						return true
					elseif GetRemain(a.cd) == GetRemain(b.cd) and a.spellID < b.spellID then
						return true
					end
				elseif a.spellID ~= 0 and b.spellID == 0 then
					return true
				end
			end)

			for i = 1,6 do
				f.icons[i]:ClearAllPoints()

				if RaidFrames.settings.Cooldowns.position == "RIGHT" then
					f.icons[i]:SetPoint("RIGHT", f, "RIGHT", -(i-1)*(RaidFrames.settings.Cooldowns.iconSize+RaidFrames.settings.Cooldowns.iconGap), 0)
				elseif RaidFrames.settings.Cooldowns.position == "LEFT" then
					f.icons[i]:SetPoint("LEFT", f, "LEFT", (i-1)*(RaidFrames.settings.Cooldowns.iconSize+RaidFrames.settings.Cooldowns.iconGap), 0)
				elseif RaidFrames.settings.Cooldowns.position == "TOP" then
					f.icons[i]:SetPoint("TOP", f, "TOP", 0, (i-1)*(RaidFrames.settings.Cooldowns.iconSize+RaidFrames.settings.Cooldowns.iconGap))
				elseif RaidFrames.settings.Cooldowns.position == "BOTTOM" then
					f.icons[i]:SetPoint("BOTTOM", f, "BOTTOM", 0, -(i-1)*(RaidFrames.settings.Cooldowns.iconSize+RaidFrames.settings.Cooldowns.iconGap))
				end
			
				
				if f.icons[i].spellID ~= 0 and i<= 6 then
					f.icons[i]:Show()
				else
					f.icons[i]:Hide()
				end
			end
		end
		
		table.insert(JokCooldowns.Frames, f)
	end

	local function UpdateCDBar(tag)
		for i = 1, #JokCooldowns.Frames do
			local f = JokCooldowns.Frames[i]		
			if tag == "all" or tag == "unit" then
				f.update_unit()
				f.point()
			end
			
			if tag == "all" or tag == "cd" then
				f.update_cd()
				f.lineup()
			end
		end
	end

	local function UpdateCD(name, spellID)
		for i = 1, #JokCooldowns.Frames do
			local f = JokCooldowns.Frames[i]
			if f.name and f.name == name then
				f.update_cd(spellID)
				f.lineup()
			end
		end
	end

	JokUI.EditCDBar = function(tag)
		for i = 1, #JokCooldowns.Frames do
			local f = JokCooldowns.Frames[i]
			
			if tag == "show" then
				if not IsInRaid() then
					f:Show()
				elseif IsActiveBattlefieldArena() then
					f:Show()
				elseif IsInRaid() and not IsActiveBattlefieldArena() then
					f:Hide()
				end
			elseif tag == "size" then
				f.update_size()
				f.lineup()
			elseif tag == "pos" then
				f.point()
				f.lineup()
			elseif tag == "alpha" then
				for i = 1,6 do
					if f.icons[i].cd:GetCooldownDuration() > 0 then
						f.icons[i]:SetAlpha(0.8)
					end
				end
			end
		end
	end

	function JokCooldowns:OnUpdate(unit, info)
		if not info.name or not info.class or not info.global_spec_id or not info.talents then return end
		
		if Cooldowns[info.class] then	
			if UnitInParty(info.name) then
				if not JokCooldowns['Roster'][info.name] or JokCooldowns['Roster'][info.name]["spec"] ~= info.global_spec_id then
					JokCooldowns['Roster'][info.name] = {}
					JokCooldowns['Roster'][info.name]["spec"] = info.global_spec_id
				
					for tag, spell_info in pairs (Cooldowns[info.class]) do
						if (spell_info.spec == "all" or spell_info.spec == info.global_spec_id) and (spell_info.talent == "all" or info.talents[spell_info.talent]) then
							JokCooldowns['Roster'][info.name][spell_info.spellID] = {}
							JokCooldowns['Roster'][info.name][spell_info.spellID]["dur"] = spell_info.cd
							JokCooldowns['Roster'][info.name][spell_info.spellID]["tag"] = tag
							JokCooldowns['Roster'][info.name][spell_info.spellID]["max_charge"] = spell_info.charge
							JokCooldowns['Roster'][info.name][spell_info.spellID]["charge"] = spell_info.charge
						end
					end
				end
				UpdateCDBar("all")
			elseif JokCooldowns['Roster'][info.name] then
			
				JokCooldowns['Roster'][info.name] = nil
				UpdateCDBar("all")
				
			end
		end
	end

	function JokCooldowns:OnRemove(guid)
		if (guid) then
		    local name = select(6, GetPlayerInfoByGUID(guid))
			if JokCooldowns['Roster'][name] then
				JokCooldowns['Roster'][name] = nil
				UpdateCDBar("all")
			end
		else
			JokCooldowns['Roster'] = {}
			UpdateCDBar("all")
		end
	end

	local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")

	function JokCooldowns:OnInitialize()
		LGIST.RegisterCallback (JokCooldowns, "GroupInSpecT_Update", function(event, ...)
			JokCooldowns.OnUpdate(...)
		end)
		LGIST.RegisterCallback (JokCooldowns, "GroupInSpecT_Remove", function(...)
			JokCooldowns.OnRemove(...)
		end)
	end

	local Group_Update = CreateFrame("Frame")
	Group_Update:RegisterEvent("PLAYER_ENTERING_WORLD")

	hooksecurefunc("CompactRaidFrameContainer_LayoutFrames", function()
		UpdateCDBar("all")
	end)
	hooksecurefunc("CompactRaidFrameContainer_OnSizeChanged", function()
		UpdateCDBar("all")
	end)

	Group_Update:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_ENTERING_WORLD" then
		
			CreateCDBar("party1")
			CreateCDBar("party2")
			CreateCDBar("party3")
			CreateCDBar("party4")
			CreateCDBar("player")
			--ResetCD()
			JokUI.EditCDBar("show")
			UpdateCDBar("all")
			
			Group_Update:UnregisterEvent("PLAYER_ENTERING_WORLD")
			Group_Update:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			Group_Update:RegisterEvent("ENCOUNTER_END")
			Group_Update:RegisterEvent("GROUP_ROSTER_UPDATE")
			Group_Update:RegisterEvent("CHALLENGE_MODE_START")			
			
		elseif event == "ENCOUNTER_END" then		
			--ResetCD()
			UpdateCDBar("cd")
			
		elseif event == "GROUP_ROSTER_UPDATE" then
			JokUI.EditCDBar("show")
			UpdateCDBar("all")

		elseif event == "CHALLENGE_MODE_START" then
			JokUI.EditCDBar("show")
			UpdateCDBar("all")
			
		elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then		
			local _, event_type, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, spellName, _, _, amount = CombatLogGetCurrentEventInfo()			
			if not sourceName or not spellID then return end
			if IsInRaid() then return end
			local name = string.split("-", sourceName)
			if event_type == "SPELL_CAST_SUCCESS" and JokCooldowns['Roster'][name] then
				if JokCooldowns['Roster'][name][spellID] then
					JokCooldowns['Roster'][name][spellID]["start"] = GetTime()
					UpdateCD(name, spellID)
				end
				if spellID == 235219 then -- ICEBLOCK RESET
					JokCooldowns['Roster'][name][45438]["start"] = 0 -- ICEBLOCK
					UpdateCD(name, 45438)
				elseif spellID == 49998 then -- VAMPIRIC BLOOD
					local info = LGIST:GetCachedInfo (sourceGUID)
					if info.talents[22014] and JokCooldowns['Roster'][name][55233]["start"] then
						JokCooldowns['Roster'][name][55233]["start"] = JokCooldowns['Roster'][name][55233]["start"]-7.5
						UpdateCD(name, 55233)
					end
				end
			end
		end
	end)
end