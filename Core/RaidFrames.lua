local _, JokUI = ...
local RaidFrames = JokUI:RegisterModule("Raid Frames")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local features = {}

local ABSORB_GLOW_ALPHA = 0.6;
local ABSORB_GLOW_OFFSET = -5;

local group = {
	part = true, -- party, only check char 1 to 4
	raid = true,
}

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local raidframes_defaults = {
    profile = {
        enable = true,
        debuffscale = 25,
        buffscale = 25,

        fadealpha = .3,	
		backgroundalpha = .7,              
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
		min = 25,
		max = 45,
		step = 1,
		order = 3,
		set = function(info,val) RaidFrames.settings.buffscale = val
		end,
		get = function(info) return RaidFrames.settings.buffscale end
	},
	debuffScale = {
		type = "range",
		isPercent = false,
		name = "Debuff Size",
		desc = "",
		min = 25,
		max = 45,
		step = 1,
		order = 4,
		set = function(info,val) RaidFrames.settings.debuffscale = val
		end,
		get = function(info) return RaidFrames.settings.debuffscale end
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
		set = function(info,val) RaidFrames.settings.fadealpha = val
		end,
		get = function(info) return RaidFrames.settings.fadealpha end
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
		set = function(info,val) RaidFrames.settings.backgroundalpha = val
		end,
		get = function(info) return RaidFrames.settings.backgroundalpha end
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
	RaidFrames:RegisterFeature("Antidote",
		"Raid Antidote",
		"Fix raid frames when a player quit the group in combat.",
		false,
		true,
		function(state)
			if state then
				RaidFrames:Antidote()
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
	hooksecurefunc("CompactUnitFrame_UpdateInRange", function(frame)
		if not group[strsub(frame.displayedUnit, 1, 4)] then return end -- ignore player, nameplates
		local inRange, checkedRange = UnitInRange(frame.displayedUnit)
		
		if checkedRange and not inRange then
			frame:SetAlpha(RaidFrames.settings.fadealpha)
			frame.background:SetAlpha(RaidFrames.settings.backgroundalpha)
		else
			frame:SetAlpha(1)
			frame.background:SetAlpha(1)
		end
	end)
end

function RaidFrames:Antidote()
	-- This makes frames transparent when refering to non-existing units.
	local old_CompactUnitFrame_UpdateInRange = CompactUnitFrame_UpdateInRange
	CompactUnitFrame_UpdateInRange = function(frame)
		if not UnitExists(frame.displayedUnit) then
			frame:SetAlpha(0.1) -- TODO: doesn't seem to work correctly yet
		else
			old_CompactUnitFrame_UpdateInRange(frame)
		end
	end

	-- This clears widgets and prevents the frame from displaying tooltips with nil/non-existing units (no moar lua errors yay!).
	hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
		if frame:GetName() and frame:GetName():find("^NamePlate%d") then
			return -- Fix to avoid affecting nameplates (courtesy of Emrus)
		end
		if UnitExists(frame.unit) then
			frame:SetScript("OnEnter", UnitFrame_OnEnter)
		else
			frame:SetScript("OnEnter", nil)
			frame.healthBar:SetValue(0)
			frame.powerBar:SetValue(0)
			frame.name:SetText("???")
			frame.selectionHighlight:Hide()
			frame.aggroHighlight:Hide()
			frame.statusText:Hide()
			frame.myHealPrediction:Hide()
			frame.otherHealPrediction:Hide()
			frame.totalAbsorb:Hide()
			frame.totalAbsorbOverlay:Hide()
			frame.overAbsorbGlow:Hide()
			frame.myHealAbsorb:Hide()
			frame.myHealAbsorbLeftShadow:Hide()
			frame.myHealAbsorbRightShadow:Hide()
			frame.overHealAbsorbGlow:Hide()
			frame.roleIcon:Hide()
			frame.readyCheckIcon:Hide()
			frame.centerStatusIcon:Hide()
			CompactUnitFrame_HideAllBuffs(frame)
			CompactUnitFrame_HideAllDebuffs(frame)
			CompactUnitFrame_HideAllDispelDebuffs(frame)
			CompactUnitFrame_UpdateInRange(frame)
			-- This might have to be completed if Blizzard adds new widgets to the frame.
		end
	end)

	-- This prevents the default raid interface from making restricted adjustments in combat and delays them until the player leaves combat. It's certainly the most important/awesome fix.
	do
		local DEFERRED = {} -- The set of deferred function calls

		-- Create a restrictive proxy for CompactRaidFrameContainer_TryUpdate function
		local old_CompactRaidFrameContainer_TryUpdate = CompactRaidFrameContainer_TryUpdate
		CompactRaidFrameContainer_TryUpdate = function(self)
			if InCombatLockdown() then
				DEFERRED[self:GetName()] = "CompactRaidFrameContainer_TryUpdate" -- Block the update and save it for later
			else
				old_CompactRaidFrameContainer_TryUpdate(self)
			end
		end

		-- Create a restrictive proxy for CompactRaidGroup_UpdateUnits function
		local old_CompactRaidGroup_UpdateUnits = CompactRaidGroup_UpdateUnits
		CompactRaidGroup_UpdateUnits = function(self)
			if InCombatLockdown() then
				DEFERRED[self:GetName()] = "CompactRaidGroup_UpdateUnits" -- Block the update and save it for later
			else
				old_CompactRaidGroup_UpdateUnits(self)
			end
		end

		-- Create a deferred failsafe for CompactUnitFrame_UpdateAll function (we want to protect UpdateInVehicle and UpdateVisible)
		hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
			if InCombatLockdown() then
				DEFERRED[frame:GetName()] = "CompactUnitFrame_UpdateAll" -- Save the call for later
			end
		end)

		-- Create the frame that will watch for combat leave event
		local trigger = CreateFrame("Frame")
		trigger:RegisterEvent("PLAYER_REGEN_ENABLED")
		trigger:SetScript("OnEvent", function()
			for k, v in pairs(DEFERRED) do
				DEFERRED[k] = nil
				_G[v](_G[k])
			end
		end)

		-- Correctness proof
		--[[
		hooksecurefunc("CompactUnitFrame_SetUnit", function(frame)
			assert( not InCombatLockdown() )
		end)
		]]
	end
end

function RaidFrames:Misc()
	-- RAID BUFFS

	for i=1,4 do
		local f = _G["PartyMemberFrame"..i]
		f:UnregisterEvent("UNIT_AURA")
		local g = CreateFrame("Frame")
		g:RegisterEvent("UNIT_AURA")
		g:SetScript("OnEvent",function(self,event,a1)
				if a1 == f.unit then
						RefreshDebuffs(f,a1,20,nil,1)
				else
						if a1 == f.unit.."pet" then
								PartyMemberFrame_RefreshPetDebuffs(f)
						end
				end
		end)
		local b = _G[f:GetName().."Debuff1"]
		b:ClearAllPoints()
		b:SetPoint("LEFT",f,"RIGHT",-7,5)
		for j=5,20 do
				local l = f:GetName().."Debuff"
				local n = l..j
				local c = CreateFrame("Frame",n,f,"PartyDebuffFrameTemplate")
				c:SetPoint("LEFT",_G[l..(j-1)],"RIGHT")
		end
	end

	for i=1,4 do
		local f = _G["PartyMemberFrame"..i]
		f:UnregisterEvent("UNIT_AURA")
		local g = CreateFrame("Frame")
		g:RegisterEvent("UNIT_AURA")
		g:SetScript("OnEvent",function(self,event,a1)
				if a1 == f.unit then
						RefreshBuffs(f,a1,20,nil,1)
				end
		end)
		for j=1,20 do
				local l = f:GetName().."Buff"
				local n = l..j
				local c = CreateFrame("Frame",n,f,"TargetBuffFrameTemplate")
				c:EnableMouse(false)
				if j == 1 then
						c:SetPoint("TOPLEFT",48,-32)
				else
						c:SetPoint("LEFT",_G[l..(j-1)],"RIGHT",1,0)
				end
		end
	end

	-- BUFF/DEBUFF SIZE

	if CompactRaidFrameContainer.groupMode == "flush" then

		hooksecurefunc("CompactUnitFrame_UpdateAll",function(f) 
			for _,d in pairs(f.debuffFrames) do 
				d.baseSize = RaidFrames.settings.debuffscale
			end 
			for _,d in pairs(f.buffFrames) do
				d:SetSize(RaidFrames.settings.buffscale,RaidFrames.settings.buffscale)
			end 
		end)

	else

		hooksecurefunc("DefaultCompactUnitFrameSetup",function(f) 
			for _,d in pairs(f.debuffFrames) do 
				d.baseSize = RaidFrames.settings.debuffscale-3
			end 
			for _,d in pairs(f.buffFrames) do 
				d:SetSize(RaidFrames.settings.buffscale-3,RaidFrames.settings.buffscale-3) 
			end 
		end)

	end

	-- RAID FRAMES SIZE DEFAULT SLIDER
	local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame" h,w=
	_G[n.."HeightSlider"],
	_G[n.."WidthSlider"] 
	h:SetMinMaxValues(1,200) 
	w:SetMinMaxValues(1,200)
end