local _, JokUI = ...
local RaidFrames = JokUI:RegisterModule("Raid Frames")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local features = {}

local ABSORB_GLOW_ALPHA = 0.5;
local ABSORB_GLOW_OFFSET = -5;

local font = STANDARD_TEXT_FONT

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local raidframes_defaults = {
    profile = {        
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
}

function RaidFrames:OnInitialize()
    self.db = JokUI.db:RegisterNamespace("Raid Frames", raidframes_defaults)
    self.settings = self.db.profile
    --JokUI.Config:Register("Raid Frames", raidframes_config)
end

function RaidFrames:OnEnable()
	-- for name in pairs(features) do
	-- 	self:SyncFeature(name)
	-- end

	-- RAID FRAMES SIZE DEFAULT SLIDER
	local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame" h,w=
	_G[n.."HeightSlider"],
	_G[n.."WidthSlider"] 
	h:SetMinMaxValues(1,200) 
	w:SetMinMaxValues(1,200)
end

-- do
-- 	local order = 10
-- 	function RaidFrames:RegisterFeature(name, short, long, default, reload, fn)
-- 		raidframes_config[name] = {
-- 			type = "toggle",
-- 			name = short,
-- 			descStyle = "inline",
-- 			desc = "|cffaaaaaa" .. long,
-- 			width = "full",
-- 			get = function() return RaidFrames.settings[name] end,
-- 			set = function(_, v)
-- 				RaidFrames.settings[name] = v
-- 				RaidFrames:SyncFeature(name)
-- 				if reload then
-- 					StaticPopup_Show ("ReloadUI_Popup")
-- 				end
-- 			end,
-- 			order = order
-- 		}
-- 		raidframes_defaults.profile[name] = default
-- 		order = order + 1
-- 		features[name] = fn
-- 	end
-- end

-- function RaidFrames:SyncFeature(name)
-- 	features[name](RaidFrames.settings[name])
-- end

-- do
-- 	RaidFrames:RegisterFeature("ShowAbsorb",
-- 		"Show Absorb",
-- 		"Show an absorb texture on Raid Frames.",
-- 		true,
-- 		true,
-- 		function(state)
-- 			if state then
-- 				RaidFrames:ShowAbsorb()
-- 			end
-- 		end)
-- end

-- -------------------------------------------------------------------------------
-- -- Functions
-- -------------------------------------------------------------------------------

-- function RaidFrames:ShowAbsorb()

-- 	hooksecurefunc("CompactUnitFrame_UpdateAll",
-- 		function(frame)
-- 			local absorbBar = frame.totalAbsorb;
-- 			if ( not absorbBar or absorbBar:IsForbidden()  ) then return end
			
-- 			local absorbOverlay = frame.totalAbsorbOverlay;
-- 			if ( not absorbOverlay or absorbOverlay:IsForbidden() ) then return end
			
-- 			local healthBar = frame.healthBar;
-- 			if ( not healthBar or healthBar:IsForbidden() ) then return end
			
-- 			absorbOverlay:SetParent(healthBar);
-- 			absorbOverlay:ClearAllPoints();		--we'll be attaching the overlay on heal prediction update.
			
-- 			local absorbGlow = frame.overAbsorbGlow;
-- 		  	if ( absorbGlow and not absorbGlow:IsForbidden() ) then
-- 				absorbGlow:ClearAllPoints();
-- 				absorbGlow:SetDrawLayer("ARTWORK", 2)
-- 				absorbGlow:SetPoint("TOPLEFT", absorbOverlay, "TOPLEFT", ABSORB_GLOW_OFFSET, 0);
-- 			  	absorbGlow:SetPoint("BOTTOMLEFT", absorbOverlay, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, 0);
-- 			  	absorbGlow:SetAlpha(ABSORB_GLOW_ALPHA);
-- 		  	end
-- 		end
-- 	)

-- 	hooksecurefunc("CompactUnitFrame_UpdateHealPrediction",
-- 		function(frame)
-- 			local absorbBar = frame.totalAbsorb;
-- 			if ( not absorbBar or absorbBar:IsForbidden()  ) then return end
			
-- 			local absorbOverlay = frame.totalAbsorbOverlay;
-- 			if ( not absorbOverlay or absorbOverlay:IsForbidden() ) then return end
			
-- 			local healthBar = frame.healthBar;
-- 			if ( not healthBar or healthBar:IsForbidden() ) then return end
			
-- 			local _, maxHealth = healthBar:GetMinMaxValues();
-- 			if ( maxHealth <= 0 ) then return end
			
-- 			local totalAbsorb = UnitGetTotalAbsorbs(frame.displayedUnit) or 0;
-- 			if( totalAbsorb > maxHealth ) then
-- 				totalAbsorb = maxHealth;
-- 			end
			
-- 			if( totalAbsorb > 0 ) then	--show overlay when there's a positive absorb amount
-- 				if ( absorbBar:IsShown() ) then		--If absorb bar is shown, attach absorb overlay to it; otherwise, attach to health bar.
-- 			  		absorbOverlay:SetPoint("TOPRIGHT", absorbBar, "TOPRIGHT", 0, 0);
-- 			  		absorbOverlay:SetPoint("BOTTOMRIGHT", absorbBar, "BOTTOMRIGHT", 0, 0);
-- 				else
-- 					absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0);
-- 		    		absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0);	    			
-- 				end

-- 				local totalWidth, totalHeight = healthBar:GetSize();			
-- 				local barSize = totalAbsorb / maxHealth * totalWidth;
				
-- 				absorbOverlay:SetWidth( barSize );
-- 				absorbOverlay:SetDrawLayer("ARTWORK", 2)
-- 	    		absorbOverlay:SetTexCoord(0, barSize / absorbOverlay.tileSize, 0, totalHeight / absorbOverlay.tileSize);
-- 			  	absorbOverlay:Show();
			  	
-- 			  	--frame.overAbsorbGlow:Show();	--uncomment this if you want to ALWAYS show the glow to the left of the shield overlay
-- 			end		
-- 		end)
-- end