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
		icon:SetDrawLayer("BACKGROUND",-7)
		b.icon = icon
		--border
		local border = b:CreateTexture(name.."Border", "BACKGROUND", nil, -7)
		border:SetTexture("Interface\\AddOns\\JokUI\\media\\textures\\gloss")
		border:SetTexCoord(0, 1, 0, 1)
		border:SetDrawLayer("BACKGROUND",- 7)
		border:ClearAllPoints()
		border:SetPoint("TOPLEFT", b, "TOPLEFT", -1, 1)
		border:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 1, -1)
		b.border = border
    end
    
  --   hooksecurefunc("CompactUnitFrame_UpdateAll",function(f) 
	 -- 	if CompactRaidFrameContainer.groupMode == "flush" then
		-- 	for i=1,10 do
		-- 		local b = _G["CompactRaidFrame1Buff"..i]
		-- 		applySkin(b)
		-- 	end 
		-- end	
	 -- end)

	

end