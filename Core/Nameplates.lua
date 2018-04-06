local _, JokUI = ...
local Nameplates = JokUI:RegisterModule("Nameplates")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local len = string.len
local gsub = string.gsub
local match = string.match
local format = format
local floor = floor
local ceil = ceil
local unpack = unpack

local borderColor = {0.40, 0.40, 0.40, 1}
local nameFont = SystemFont_NamePlate:GetFont()
local castbarFont = SystemFont_Shadow_Small:GetFont()
local texturePath = "Interface\\AddOns\\JokUI\\media\\"
local statusBar = texturePath.."UI-StatusBar"
local borderTexture = texturePath.."borderTexture"
local textureShadow = texturePath.."textureShadow"

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local nameplates_defaults = {
    profile = {
        enable = true,
        nameSize = 9,
        friendlyName = true,
        hideHealth = true,
        arenanumber = true,
        globalScale = 1,
        targetScale = 1,
        importantScale = 1,
        sticky = true,
        nameplateAlpha = 0.6,
        nameplateRange = 60,
        overlap = true,
        verticalOverlap = 0.7,
        horizontalOverlap = 0.7,
        friendlymotion = true, 
        enemytotem = true,
        enemypets = false,
        enemyguardian = false,
        enemyminus = false, 
        healthWidth = 1,
        healthHeight = 5,       
        aurasscale = 1,
        aurasoffset = -9,
                     
    }
}

local nameplates_config = {
    title = {
        type = "description",
        name = "|cff64b4ffNameplates",
        fontSize = "large",
        order = 0,
    },
    desc = {
        type = "description",
        name = "Various useful options for Nameplates.\n",
        fontSize = "medium",
        order = 1,
    },
    enable = {
        type = "toggle",
        name = "Enable",
        descStyle = "inline",
        width = "full",
        get = function() return Nameplates.settings.enable end,
        set = function(_, v)
        end,
        order = 2,
    },
    nameSize = {
        type = "range",
        isPercent = false,
        name = "Name Size",
        desc = "",
        min = 6,
        max = 16,
        step = 1,
        order = 2,
        get = function() return Nameplates.settings.nameSize end,
        set = function(_, value)
            Nameplates.settings.nameSize = value
            Nameplates:ForceUpdate()
        end,
    },
    friendlyName = {
        type = "toggle",
        name = "Color Friendly Name",
        desc = "|cffaaaaaa Color Friendly names by class. |r",
        descStyle = "inline",
        width = "full",
        order = 3,
        set = function(info,val) Nameplates.settings.friendlyName = val
        Nameplates:ForceUpdate()
        end,
        get = function(info) return Nameplates.settings.friendlyName end
    },
    hideHealth = {
        type = "toggle",
        name = "Hide HealthBar on Friendly",
        desc = "|cffaaaaaa Hide the health bar for Friendly Nameplates. |r",
        descStyle = "inline",
        width = "full",
        order = 4,
        set = function(info,val) Nameplates.settings.hideHealth = val
        Nameplates:ForceUpdate()
        end,
        get = function(info) return Nameplates.settings.hideHealth end
    },
    arenanumber = {
        type = "toggle",
        name = "Arena Number",
        desc = "|cffaaaaaa Replace names on Nameplates with arena numbers. |r",
        descStyle = "inline",
        width = "full",
        order = 5,
        set = function(info,val) Nameplates.settings.arenanumber = val
        Nameplates:ForceUpdate()
        end,
        get = function(info) return Nameplates.settings.arenanumber end
    },
    scale = {
        name = "Scale Options",
        type = "group",
        inline = true,
        order = 10,
        args = {
            globalScale = {
                type = "range",
                isPercent = true,
                name = "Global Scale",
                desc = "",
                min = 0.5,
                max = 1.5,
                step = 0.05,
                order = 1,
                set = function(info,val) 
                    Nameplates.settings.globalScale = val
                    SetCVar("nameplateGlobalScale", val)
                end,
                get = function(info) return Nameplates.settings.globalScale end
            },
            targetScale = {
                type = "range",
                isPercent = true,
                name = "Target Scale",
                desc = "",
                min = 0.5,
                max = 1.5,
                step = 0.1,
                order = 2,
                set = function(info,val) Nameplates.settings.targetScale = val
                    SetCVar("nameplateSelectedScale", val)
                end,
                get = function(info) return Nameplates.settings.targetScale end
            },
            importantScale = {
                type = "range",
                isPercent = true,
                name = "Important Scale",
                desc = "",
                min = 0.5,
                max = 1.5,
                step = 0.1,
                order = 3,
                set = function(info,val) Nameplates.settings.importantScale = val
                    SetCVar("nameplateLargerScale", val)
                end,
                get = function(info) return Nameplates.settings.importantScale end
            },
        },
    },
    frame = {
        name = "Frame Options",
        type = "group",
        inline = true,
        order = 20,
        args = {
            sticky = {
                name = "Sticky Nameplates",
                desc = "|cffaaaaaa Nameplates will stick to the screen if not in view angle. |r",
                descStyle = "inline",
                width = "full",
                type = "toggle",
                order = 1,
                set = function(info,checked)
                    if not checked then
                        Nameplates.settings.sticky = false
                        SetCVar("nameplateOtherTopInset", -1,true)
                        SetCVar("nameplateOtherBottomInset", -1,true)
                        else
                        for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do SetCVar(v, GetCVarDefault(v),true) end
                    end
                    Nameplates.settings.sticky = checked
                end,
                get = function(info) return Nameplates.settings.sticky end
            },
            nameplateAlpha = {
                type = "range",
                isPercent = true,
                name = "Nameplate Alpha",
                desc = "",
                min = 0,
                max = 1,
                step = 0.1,
                order = 3,
                set = function(info,val) Nameplates.settings.nameplateAlpha = val
                    SetCVar("nameplateMinAlpha", val)
                end,
                get = function(info) return Nameplates.settings.nameplateAlpha end
            },
            nameplateRange = {
                type = "range",
                isPercent = false,
                name = "Nameplate Range",
                desc = "",
                min = 40,
                max = 80,
                step = 1,
                order = 4,
                set = function(info,val) Nameplates.settings.nameplateRange = val
                    SetCVar("nameplateMaxDistance", val)
                end,
                get = function(info) return Nameplates.settings.nameplateRange end
            },
        },
    },
    overlap = {
        name = "Overlap Options",
        type = "group",
        inline = true,
        order = 30,
        args = {
            stacking = {
                type = "toggle",
                name = "Stacking Nameplates",
                desc = "|cffaaaaaa Nameplates will stack on top of each other. |r",
                descStyle = "inline",
                width = "full",
                order = 1,
                set = function(info,val) Nameplates.settings.overlap = val
                    SetCVar("nameplateMotion", val)
                end,
                get = function(info) return Nameplates.settings.overlap end
            },
            friendlyName = {
                type = "toggle",
                name = "Overlap Friendly Names",
                desc = "|cffaaaaaa Force Friendly Nameplates to not stack. |r",
                descStyle = "inline",
                width = "full",
                order = 2,
                set = function(info,val) Nameplates.settings.friendlymotion = val
                StaticPopup_Show ("ReloadUI_Popup")
                end,
                get = function(info) return Nameplates.settings.friendlymotion end
            },
            verticalOverlap = {
                type = "range",
                isPercent = false,
                name = "Vertical Overlap",
                desc = "",
                min = 0.3,
                max = 1.3,
                step = 0.1,
                order = 3,
                disabled = function(info) return  not Nameplates.settings.overlap end,
                set = function(info,val) Nameplates.settings.verticalOverlap = val
                    SetCVar("nameplateOverlapV", val)
                end,
                get = function(info) return Nameplates.settings.verticalOverlap end
            },
            horizontalOverlap = {
                type = "range",
                isPercent = false,
                name = "Horizontal Overlap",
                desc = "",
                min = 0.3,
                max = 1.3,
                step = 0.1,
                order = 4,
                disabled = function(info) return  not Nameplates.settings.overlap end,
                set = function(info,val) Nameplates.settings.horizontalOverlap = val
                    SetCVar("nameplateOverlapH", val)
                end,
                get = function(info) return Nameplates.settings.horizontalOverlap end
            },
        },
    },
    visibility = {
        name = "Visibility Options",
        type = "group",
        inline = true,
        order = 40,
        args = {
            enemytotem = {
                type = "toggle",
                name = "Show Enemy Totems",
                desc = "",
                order = 1,
                set = function(info,val) Nameplates.settings.enemytotem = val
                    SetCVar("nameplateShowEnemyTotems", val)
                end,
                get = function(info) return Nameplates.settings.enemytotem end
            },
            enemypets = {
                type = "toggle",
                name = "Show Enemy Pets",
                desc = "",
                order = 1,
                set = function(info,val) Nameplates.settings.enemypets = val
                    SetCVar("nameplateShowEnemyPets", val)
                end,
                get = function(info) return Nameplates.settings.enemypets end
            },
            enemyguardian = {
                type = "toggle",
                name = "Show Enemy Guardians",
                desc = "",
                order = 1,
                set = function(info,val) Nameplates.settings.enemyguardian = val
                    SetCVar("nameplateShowEnemyGuardians", val)
                end,
                get = function(info) return Nameplates.settings.enemyguardian end
            },
            enemyminus = {
                type = "toggle",
                name = "Show Enemy Minus",
                desc = "",
                order = 1,
                set = function(info,val) Nameplates.settings.enemyminus = val
                    SetCVar("nameplateShowEnemyMinus", val)
                end,
                get = function(info) return Nameplates.settings.enemyminus end
            },
        },
    },
    health = {
        name = "Health Options",
        type = "group",
        inline = true,
        order = 50,
        args = {
            healthHeight = {
                type = "range",
                isPercent = false,
                name = "Health Bar Height",
                desc = "",
                min = 3,
                max = 12,
                step = 1,
                order = 1,
                set = function(info,val) Nameplates.settings.healthHeight = val 
                Nameplates:ForceUpdate()
                end,
                get = function(info, val) return Nameplates.settings.healthHeight end
            },
            healthWidth = {
                type = "range",
                isPercent = false,
                name = "Health Bar Width",
                desc = "",
                min = 0.7,
                max = 2,
                step = 0.1,
                order = 2,
                set = function(info,val) Nameplates.settings.healthWidth = val
                    SetCVar("nameplateHorizontalScale", val)
                end,
                get = function(info, val) return Nameplates.settings.healthWidth end
            },
        },
    },
    nameplatesauras = {
        name = "Auras Options",
        type = "group",
        inline = true,
        order = 60,
        args = {
            aurasscale = {
                type = "range",
                isPercent = false,
                name = "Auras Scale",
                desc = "",
                min = 0.5,
                max = 1.5,
                step = 0.1,
                order = 1,
                set = function(info,val) Nameplates.settings.aurasscale = val 
                Nameplates:ForceUpdate()
                end,
                get = function(info, val) return Nameplates.settings.aurasscale end
            },
            aurasoffset = {
                type = "range",
                isPercent = false,
                name = "Auras Offset",
                desc = "",
                min = -15,
                max = 10,
                step = 1,
                order = 2,
                set = function(info,val) Nameplates.settings.aurasoffset = val 
                Nameplates:ForceUpdate()
                end,
                get = function(info, val) return Nameplates.settings.aurasoffset end
            },
        },
    },
}

function Nameplates:OnInitialize()
    self.db = JokUI.db:RegisterNamespace("Nameplates", nameplates_defaults)
    self.settings = self.db.profile
    JokUI.Config:Register("Nameplates", nameplates_config)
end

	----------------------
	------FUNCTIONS-------
	----------------------

    -- Format Time

function Nameplates:FormatTime(s)
    if s > 86400 then
        -- Days
        return ceil(s/86400) .. "d", s%86400
    elseif s >= 3600 then
        -- Hours
        return ceil(s/3600) .. "h", s%3600
    elseif s >= 60 then
        -- Minutes
        return ceil(s/60) .. "m", s%60
    elseif s <= 3 then
        -- Seconds
        return format("%.1f", s)
    end

    return floor(s), s - floor(s)
end

    -- Abbreviate Function

function Nameplates:Abbrev(str,length)
    if ( str ~= nil and length ~= nil ) then
        return str:len()>length and str:sub(1,length)..".." or str
    end
    return ""
end

    -- Check if the frame is a nameplate.

function Nameplates:FrameIsNameplate(unit)
    if ( type(unit) ~= "string" ) then return false end
    if ( match(unit,"nameplate") ~= "nameplate" and match(unit,"NamePlate") ~= "NamePlate" ) then
        return false
    else
        return true
    end
end

    -- Force Nameplate Update
    
function Nameplates:ForceUpdate()
    for i, frame in ipairs(C_NamePlate.GetNamePlates(issecure())) do
        CompactUnitFrame_UpdateAll(frame.UnitFrame)
    end
end

    -- Update CastBar Timer

function Nameplates:UpdateCastbarTimer(frame)
    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            local current = frame.castBar.maxValue - frame.castBar.value
            if ( current > 0.0 ) then
                frame.castBar.CastTime:SetText(Nameplates:FormatTime(current))
            end
        else
            if ( frame.castBar.value > 0 ) then
                frame.castBar.CastTime:SetText(Nameplates:FormatTime(frame.castBar.value))
            end
        end
    end
end

	---------------------
    -- SKIN NAMEPLATES --
	---------------------
	
	-- UPDATE HEALTH COLOR

hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not Nameplates:FrameIsNameplate(frame.displayedUnit) ) then return end

    local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		r, g, b = 0.5, 0.5, 0.5;
	else
		if ( frame.optionTable.healthBarColorOverride ) then
			local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;
		else
			local localizedClass, englishClass = UnitClass(frame.unit);
			local classColor = RAID_CLASS_COLORS[englishClass];
			if ( (frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit)) and classColor and frame.optionTable.useClassColors ) then
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
				r, g, b = 0.9, 0.9, 0.9;
			elseif ( frame.optionTable.colorHealthBySelection ) then
				if ( frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit) ) then
					local target = frame.displayedUnit.."target"
                    local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
                        if ( isTanking and threatStatus ) then
                            if ( threatStatus >= 3 ) then
                                r, g, b = 0.5, 0.75, 0.95
                            end
                        else
                            r, g, b = 1.0, 0.0, 0.0
                        end
				elseif ( UnitIsPlayer(frame.displayedUnit) and UnitIsFriend("player", frame.displayedUnit) ) then
					r, g, b = 0.667, 0.667, 1.0;
				else
					r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors);
				end
			elseif ( UnitIsFriend("player", frame.unit) ) then
				r, g, b = 0.0, 1.0, 0.0;
			else
				r, g, b = 1.0, 0.0, 0.0;
			end
		end
	end
	if ( r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b ) then
		frame.healthBar:SetStatusBarColor(r, g, b);

		if (frame.optionTable.colorHealthWithExtendedColors) then
			frame.selectionHighlight:SetVertexColor(r, g, b);
		else
			frame.selectionHighlight:SetVertexColor(1, 1, 1);
		end
		
		frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b;
	end
end)

    -- UPDATE BUFFS 

local function UpdateBuffFrame(...)
    for _,v in pairs(C_NamePlate.GetNamePlates(issecure())) do
        if ( not v.UnitFrame:IsForbidden() ) then
            local bf = v.UnitFrame.BuffFrame
            bf:SetScale(Nameplates.settings.aurasscale) 
            if ( v.UnitFrame.displayedUnit and UnitShouldDisplayName(v.UnitFrame.displayedUnit) ) then
                bf.baseYOffset = Nameplates.settings.aurasoffset
            elseif ( v.UnitFrame.displayedUnit ) then
                bf.baseYOffset = 0
            end

            bf:UpdateAnchor()
        end
    end
end
NamePlateDriverFrame:HookScript("OnEvent", UpdateBuffFrame)

	-- UPDATE NAMEPLATE

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not Nameplates:FrameIsNameplate(frame.displayedUnit) ) then return end

        -- Health Bar Height

    frame.healthBar:SetHeight(Nameplates.settings.healthHeight)
    
       -- Elite Icon
        
    frame.ClassificationFrame:SetScale(1)

        -- Castbar.

    --frame.castBar:SetHeight(8)
    --frame.castBar:SetStatusBarTexture(statusBar)
    
       -- Hide Border Shield

    frame.castBar.BorderShield:Hide()
    frame.castBar.BorderShield:ClearAllPoints()
    
       -- Castbar Spell Name.
    
    frame.castBar.Text:SetShadowOffset(.5, -.5)

       -- Set Castbar Timer.

    if ( not frame.castBar.CastTime ) then
        frame.castBar.CastTime = frame.castBar:CreateFontString(nil, "OVERLAY")
        frame.castBar.CastTime:Hide()
        frame.castBar.CastTime:SetPoint("RIGHT", frame.castBar, "RIGHT", 17, 0)
        frame.castBar.CastTime:SetFont(castbarFont, 8, "OUTLINE")
        frame.castBar.CastTime:Show()
    end

       -- Update Castbar.
    
    frame.castBar:SetScript("OnValueChanged", function(self, value)
        Nameplates:UpdateCastbarTimer(frame)
    end)
	
	-- Name Position.

	frame.name:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 4)
		
	-- Name Size.
		
    frame.name:SetFont("Fonts\\FRIZQT__.TTF", Nameplates.settings.nameSize)
	
	-- Abbreviate Long Names.
	
    local newName = frame.name:GetText()
    newName = Nameplates:Abbrev(newName,32)
	frame.name:SetText(newName)

    -- Only Name Fix 

     if not UnitIsPlayer(frame.displayedUnit) then
        frame.healthBar:Show()
     end

    -- Friendly Nameplates Motion

    if Nameplates.settings.friendlymotion then
        if (not InCombatLockdown()) then
            C_NamePlate.SetNamePlateFriendlySize(90, 1)
            C_NamePlate.SetNamePlateFriendlyClickThrough(true)
        end

        if ( not UnitIsPlayer(frame.displayedUnit) and not UnitCanAttack(frame.displayedUnit,"player") ) then
            frame.healthBar:SetHeight(3)
        end
    end

    -- Color Friendly Player Name.
	
	if ( UnitIsPlayer(frame.displayedUnit) and not UnitCanAttack(frame.displayedUnit,"player") and Nameplates.settings.friendlyName) then
		local friendly_name = GetUnitName(frame.displayedUnit,true)
		local _, class = UnitClass(frame.displayedUnit)
        local colour = select(4, GetClassColor(class))
    	local text = "|c"..colour..friendly_name:match("[^-]+")..""				
		frame.name:SetFont("Fonts\\FRIZQT__.TTF", Nameplates.settings.nameSize, "OUTLINE")
		frame.name:SetText(text)
        C_NamePlate.SetNamePlateFriendlySize(90, 1)
		if Nameplates.settings.hideHealth then
			frame.name:SetPoint("BOTTOM", frame.castBar, "TOP", 0, 4)
			frame.healthBar:Hide()
			if IsActiveBattlefieldArena() then
				frame.healthBar:Show()
	            frame.healthBar:SetHeight(3)
	            frame.healthBar:SetScale(0.8)
				frame.name:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 3)
			end
        else
            frame.healthBar:Show()
            frame.healthBar:SetHeight(4)
		end
	end
	
	-- Color Enemy Player Name.
	
	if ( UnitIsPlayer(frame.displayedUnit) and UnitCanAttack(frame.displayedUnit,"player") ) then
		local enemy_name = GetUnitName(frame.displayedUnit,true)
		local _, class = UnitClass(frame.displayedUnit)
        local colour = select(4, GetClassColor(class))
    	local text = "|c"..colour..enemy_name:match("[^-]+")..""				
		frame.name:SetFont("Fonts\\FRIZQT__.TTF", Nameplates.settings.nameSize, "OUTLINE")
		frame.name:SetText(text)
		frame.name:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 2)
	end
	
	-- Arena Number on Nameplates.
	
	if IsActiveBattlefieldArena() and frame.displayedUnit:find("nameplate") and Nameplates.settings.arenanumber then 
		for i=1,5 do 
			if UnitIsUnit(frame.displayedUnit,"arena"..i) then 
				frame.name:SetText(i)
				frame.name:SetFont("Fonts\\FRIZQT__.TTF", 11)
				frame.name:SetTextColor(1,1,0)
				break 
			end 
		end 
	end 
		
end)