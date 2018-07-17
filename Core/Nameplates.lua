local _, JokUI = ...
local Nameplates = JokUI:RegisterModule("Nameplates")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local match = string.match
local format = format
local floor = floor
local ceil = ceil

local castbarFont = SystemFont_Shadow_Small:GetFont()
local texturePath = "Interface\\AddOns\\JokUI\\media\\nameplates\\"
local statusBar = texturePath.."UI-StatusBar"

local nameplates_aura_spells = {
    -- [339] = true,
    -- [980] = true,
    -- [164812] = true,
    -- [164815] = true,
    -- [197277] = true,
};

local nameplateScale = GetCVar("nameplateGlobalScale")

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local nameplates_defaults = {
    profile = {
        enable = true,
        nameSize = 10,
        friendlyName = true,
        hideHealth = true,
        arenanumber = true,
        globalScale = 1,
        targetScale = 1,
        importantScale = 1,
        sticky = true,
        nameplateAlpha = 1,
        nameplateRange = 50,
        overlap = true,
        verticalOverlap = 0.8,
        horizontalOverlap = 0.8,
        friendlymotion = true,
        clickthroughfriendly = true,
        enemytotem = true,
        enemypets = false,
        enemyguardian = false,
        enemyminus = false, 
        healthWidth = 1.1,
        healthHeight = 9,                         
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
            Nameplates.settings.enable = v
            StaticPopup_Show ("ReloadUI_Popup")
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
        order = 3,
        disabled = function(info) return not Nameplates.settings.enable end,
        get = function() return Nameplates.settings.nameSize end,
        set = function(_, value)
            Nameplates.settings.nameSize = value
            Nameplates:ForceUpdate()
        end,
    },
    arenanumber = {
        type = "toggle",
        name = "Arena Number",
        desc = "|cffaaaaaa Replace names on Nameplates with arena numbers. |r",
        descStyle = "inline",
        width = "full",
        order = 4,
        disabled = function(info) return not Nameplates.settings.enable end,
        set = function(info,val) Nameplates.settings.arenanumber = val
        Nameplates:ForceUpdate()
        end,
        get = function(info) return Nameplates.settings.arenanumber end
    },
    friendlyoptions = {
        name = "Friendly Options",
        type = "group",
        inline = true,
        order = 9,
        disabled = function(info) return not Nameplates.settings.enable end,
        args = {
            friendlyName = {
                type = "toggle",
                name = "Color Friendly Name",
                desc = "|cffaaaaaa Color Friendly names by class. |r",
                descStyle = "inline",
                width = "full",
                order = 1,
                set = function(info,val) Nameplates.settings.friendlyName = val
                Nameplates:ForceUpdate()
                end,
                get = function(info) return Nameplates.settings.friendlyName end
            },
            clickthroughfriendly = {
                type = "toggle",
                name = "Clickthrough Friendly Nameplates",
                desc = "|cffaaaaaa Clickthrough Friendly Nameplates. |r",
                descStyle = "inline",
                width = "full",
                order = 1,
                set = function(info,val) Nameplates.settings.clickthroughfriendly = val
                Nameplates:ForceUpdate()
                end,
                get = function(info) return Nameplates.settings.clickthroughfriendly end
            },
            hideHealth = {
                type = "toggle",
                name = "Hide Friendly Health",
                desc = "|cffaaaaaa Hide the health bar for Friendly Nameplates. |r",
                descStyle = "inline",
                width = "full",
                order = 2,
                set = function(info,val) Nameplates.settings.hideHealth = val
                Nameplates:ForceUpdate()
                end,
                get = function(info) return Nameplates.settings.hideHealth end
            },
        },
    },
    scale = {
        name = "Scale Options",
        type = "group",
        inline = true,
        order = 10,
        disabled = function(info) return not Nameplates.settings.enable end,
        args = {
            globalScale = {
                type = "range",
                isPercent = true,
                name = "Global Scale",
                desc = "",
                min = 0.5,
                max = 1.5,
                step = 0.1,
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
        disabled = function(info) return not Nameplates.settings.enable end,
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
        disabled = function(info) return not Nameplates.settings.enable end,
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
                disabled = function(info) return  not Nameplates.settings.overlap or not Nameplates.settings.enable end,
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
                disabled = function(info) return  not Nameplates.settings.overlap or not Nameplates.settings.enable end,
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
        disabled = function(info) return not Nameplates.settings.enable end,
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
        disabled = function(info) return not Nameplates.settings.enable end,
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
}

function Nameplates:OnInitialize()
    self.db = JokUI.db:RegisterNamespace("Nameplates", nameplates_defaults)
    self.settings = self.db.profile
    JokUI.Config:Register("Nameplates", nameplates_config)

    -- Set CVAR
    SetCVar("nameplateGlobalScale", Nameplates.settings.globalScale)
    SetCVar("nameplateSelectedScale", Nameplates.settings.targetScale)
    SetCVar("nameplateLargerScale", Nameplates.settings.importantScale)
    SetCVar("nameplateOverlapV", Nameplates.settings.verticalOverlap)
    SetCVar("nameplateOverlapH", Nameplates.settings.horizontalOverlap)
    SetCVar("nameplateHorizontalScale", Nameplates.settings.healthWidth)        
    SetCVar("nameplateMotion", Nameplates.settings.overlap)

    SetCVar("nameplateMinScale", 1)
    SetCVar("nameplateMaxScale", 1)
    SetCVar("nameplateShowDebuffsOnFriendly", 0)

    SetCVar("nameplateShowAll", 1)
    SetCVar("NameplatePersonalShowAlways", 0)

    -- Remove Larger Nameplates Function (thx Plater)
    InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Disable()
    InterfaceOptionsNamesPanelUnitNameplatesMakeLarger.setFunc = function() end

end

function Nameplates:OnEnable()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("RAID_TARGET_UPDATE")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    self:ExtraAuras()

end

-------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------

local markerColors = {
    ["1"] = { r = 0.85, g = 0.81, b = 0.27 },
    ["2"] = { r = 0.93, g = 0.51, b = 0.06 },
    ["3"] = { r = 0.7, g = 0.06, b = 0.84 },
    ["4"] = { r = 0.14, g = 0.66, b = 0.14 },
    ["5"] = { r = 0.60, g = 0.75, b = 0.85 },
    ["6"] = { r = 0.0, g = 0.64, b = 1 },
    ["7"] = { r = 0.82, g = 0.18, b = 0.18 },
    ["8"] = { r = 0.89, g = 0.83, b = 0.74 },
}

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
    if ( type(unit) ~= "string" ) then 
    	return false 
    end
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

-- Raid Marker Coloring Update

function Nameplates:UpdateRaidMarkerColoring()
    for i, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
        CompactUnitFrame_UpdateHealthColor(frame.UnitFrame)
    end
end

-- Check for threat.

function Nameplates:IsOnThreatListWithPlayer(unit)
    local _, threatStatus = UnitDetailedThreatSituation("player", unit)
    return threatStatus ~= nil
end

-- Checks to see if unit has tank role.

local function PlayerIsTank(unit)
    local assignedRole = UnitGroupRolesAssigned(unit)
    return assignedRole == "TANK"
end

-- Off Tank Color Checks

function Nameplates:UseOffTankColor(unit)
    if ( UnitPlayerOrPetInRaid(unit) or UnitPlayerOrPetInParty(unit) ) then
        if ( not UnitIsUnit("player", unit) and PlayerIsTank("player") and PlayerIsTank(unit) ) then
            return true
        end
    end
    return false
end

function Nameplates:SetTextColorByClass(unit, text)
    local _, class = UnitClass (unit)
    if (class) then
        local color = RAID_CLASS_COLORS [class]
        if (color) then
            text = "|c" .. color.colorStr .. " [" .. text:gsub (("%-.*"), "") .. "]|r"
        end
    end
    return text
end

function Nameplates:GroupMembers(reversed, forceParty)
    local unit  = (not forceParty and IsInRaid()) and 'raid' or 'party'
    local numGroupMembers = forceParty and GetNumSubgroupMembers()  or GetNumGroupMembers()
    local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
    return function()
        local ret 
        if i == 0 and unit == 'party' then 
            ret = 'player'
        elseif i <= numGroupMembers and i > 0 then
            ret = unit .. i
        end
        i = i + (reversed and -1 or 1)
        return ret
    end
end

-- Update CastBar Timer

function Nameplates:UpdateCastbarTimer(frame)
    if ( frame.unit ) then
        if ( frame.castBar.casting ) then
            local current = frame.castBar.maxValue - frame.castBar.value
            if ( current > 0 ) then
                frame.castBar.CastTime:SetText(Nameplates:FormatTime(current))
            end
        else
            if ( frame.castBar.value > 0 ) then
                frame.castBar.CastTime:SetText(Nameplates:FormatTime(frame.castBar.value))
            end
        end
    end
end

local ResourceFrameOffset

function Nameplates:RAID_TARGET_UPDATE()
    self:UpdateRaidMarkerColoring()
end

function Nameplates:PLAYER_ENTERING_WORLD()

    NamePlateTargetResourceFrame:SetScale(0.8)

    -- Friendly Force Stacking
    if Nameplates.settings.friendlymotion and Nameplates.settings.overlap then
        local _, instanceType = IsInInstance()
        if (not InCombatLockdown()) and instanceType == "party" or instanceType == "raid" then
            C_NamePlate.SetNamePlateFriendlySize(80, 1)
        else
            C_NamePlate.SetNamePlateFriendlySize(80, 1)
        end
    end

    if Nameplates.settings.clickthroughfriendly then
        C_NamePlate.SetNamePlateFriendlyClickThrough(true)
    end

    -- Nameplate Class Bar
    if not InCombatLockdown() then
        local _, class = UnitClass("player")
        if class == "WARLOCK" or class == "DEATHKNIGHT" or class == "ROGUE" then
            SetCVar("nameplateResourceOnTarget", 1)
            SetCVar("nameplateShowSelf", 1)
            ResourceFrameOffset = true
        else
            SetCVar("nameplateResourceOnTarget", 0)
            SetCVar("nameplateShowSelf", 0)
            ResourceFrameOffset = false
        end
    end

    hooksecurefunc(NamePlateDriverFrame, "OnLoad", function()
        if UnitExists("target") and not UnitIsPlayer("target") and ResourceFrameOffset then
            local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target", issecure());
            NamePlateTargetResourceFrame:SetPoint("BOTTOM", namePlateTarget.UnitFrame.name, "TOP", 0, -2);
        end
    end)

end

-- Current Target Opacity

function Nameplates:PLAYER_TARGET_CHANGED()
    for _, frame in pairs(C_NamePlate.GetNamePlates()) do
        if frame == C_NamePlate.GetNamePlateForUnit("target") or not UnitExists("target") or frame == C_NamePlate.GetNamePlateForUnit("player") then
            frame.UnitFrame:SetAlpha(1)
        else
            frame.UnitFrame:SetAlpha(Nameplates.settings.nameplateAlpha)
        end
    end
end

-- Add Interrupter's Name and Targeted Player

function Nameplates:COMBAT_LOG_EVENT_UNFILTERED()
    if IsInGroup() then
        local time, event, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical = CombatLogGetCurrentEventInfo()
        if event == "SPELL_INTERRUPT" then
            for _, plateFrame in ipairs (C_NamePlate.GetNamePlates()) do
                local token = plateFrame.namePlateUnitToken
                if (plateFrame.UnitFrame.castBar:IsShown()) then
                    if (plateFrame.UnitFrame.castBar.Text:GetText() == INTERRUPTED) then
                        if (UnitGUID(token) == targetGUID) then
                            plateFrame.UnitFrame.castBar.Text:SetText (INTERRUPTED .. Nameplates:SetTextColorByClass(sourceName, sourceName))
                        end
                    end
                end
            end
        elseif event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" or event == "SPELL_CAST_FAILED" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "NAME_PLATE_UNIT_ADDED" or event == "NAME_PLATE_UNIT_REMOVED" then
            for _, plateFrame in ipairs (C_NamePlate.GetNamePlates()) do
                local castingUnit = plateFrame.namePlateUnitToken
                if (plateFrame.UnitFrame.castBar:IsShown()) then
                    local name = UnitCastingInfo(castingUnit)
                    if not name then                    
                        name = UnitChannelInfo(castingUnit)
                    end 
                    if name then
                        local targetUnit = castingUnit.."-target"
                        for u in Nameplates:GroupMembers() do
                            if UnitIsUnit(targetUnit, u) then
                                local targetName = UnitName(targetUnit)
                                local targetRole = UnitGroupRolesAssigned(targetUnit)
                                if targetRole ~= "TANK" then
                                    plateFrame.UnitFrame.castBar.Text:SetText(name .. Nameplates:SetTextColorByClass(targetName, targetName))
                                end
                            end
                        end
                    end  
                end
            end
        end       
    end
end

-- UPDATE BUFFS 

local function UpdateBuffFrame(...)
    for _,v in pairs(C_NamePlate.GetNamePlates(issecure())) do
        if ( not v.UnitFrame:IsForbidden() ) then
            local bf = v.UnitFrame.BuffFrame
            if v.UnitFrame.BuffFrame:GetWidth() == 99 then
                bf:SetHeight(0)
            end
            if ( v.UnitFrame.displayedUnit and UnitShouldDisplayName(v.UnitFrame.displayedUnit) ) and not ResourceFrameOffset then
            	bf:SetPoint("BOTTOM", v.UnitFrame.name, "TOP", 0, 0)
            elseif ( v.UnitFrame.displayedUnit ) then               
            	bf:SetPoint("BOTTOM", v.UnitFrame.healthBar, "TOP", 0, 0)
            end
            bf:UpdateAnchor()
        end
    end
end
NamePlateDriverFrame:HookScript("OnEvent", UpdateBuffFrame)

-- function Nameplates:UpdateBuffFrameAnchorsByUnit(unit)
--     local frame = C_NamePlate.GetNamePlateForUnit(unit, issecure())
--     if ( not frame ) then return end

--     local BuffFrame = frame.UnitFrame.BuffFrame

--     if ( frame.UnitFrame.displayedUnit and UnitShouldDisplayName(frame.UnitFrame.displayedUnit) ) then
--         BuffFrame:SetPoint("BOTTOM", frame.UnitFrame.name, "TOP", 0, 2)
--     elseif ( frame.UnitFrame.displayedUnit ) then
--         BuffFrame:SetPoint("BOTTOM", frame.UnitFrame.healthBar, "TOP", 0, 2)
--     end

--     BuffFrame:UpdateAnchor()
-- end

-- function Nameplates:UpdateAllBuffFrameAnchors()
--     for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
--         if ( not frame.UnitFrame:IsForbidden() ) then
--             local BuffFrame = frame.UnitFrame.BuffFrame

--             if ( frame.UnitFrame.displayedUnit and UnitShouldDisplayName(frame.UnitFrame.displayedUnit) ) then
--                 BuffFrame:SetPoint("BOTTOM", frame.UnitFrame.name, "TOP", 0, 20)
--             elseif ( frame.UnitFrame.displayedUnit ) then
--                 BuffFrame.baseYOffset = 0
--             end

--             BuffFrame:UpdateAnchor()
--         end
--     end
-- end

-- local f = CreateFrame("frame")
-- f:RegisterEvent("UNIT_AURA")
-- f:RegisterEvent("PLAYER_TARGET_CHANGED")
-- f:SetScript("OnEvent", function(self, event, ...)
--     if event == "UNIT_AURA" then
--         local unit = ...
--         Nameplates:UpdateBuffFrameAnchorsByUnit(unit)
--     elseif event == "PLAYER_TARGET_CHANGED" then
--         Nameplates:UpdateAllBuffFrameAnchors()
--     end
-- end)

-- NAMEPLATE HEALTH COLOR

hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
    if ( frame:IsForbidden() ) then return end

    local r, g, b
    if ( not UnitIsConnected(frame.unit) ) then
        r, g, b = 0.5, 0.5, 0.5
    else
        if ( frame.optionTable.healthBarColorOverride ) then
            local healthBarColorOverride = frame.optionTable.healthBarColorOverride
            r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b
        else
            local localizedClass, englishClass = UnitClass(frame.unit)
            local classColor = RAID_CLASS_COLORS[englishClass]
            local raidMarker = GetRaidTargetIndex(frame.displayedUnit)

            if ( frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit) and classColor ) then
                r, g, b = classColor.r, classColor.g, classColor.b
            elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
                r, g, b = 0.1, 0.1, 0.1
            elseif raidMarker then
                local markerColor = markerColors[tostring(raidMarker)]
                r, g, b = markerColor.r, markerColor.g, markerColor.b
            elseif ( frame.optionTable.colorHealthBySelection ) then
                if ( frame.optionTable.considerSelectionInCombatAsHostile and Nameplates:IsOnThreatListWithPlayer(frame.displayedUnit) ) then
                    local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
                    if ( isTanking and threatStatus ) then
                        if ( threatStatus >= 3 ) then
                            r, g, b = 0.5, 0.75, 0.95
                        elseif ( threatStatus == 2 ) then
                            r, g, b = 1.0, 0.6, 0.2
                        end
                    else
                        r, g, b = 1.0, 0.0, 0.0
                    end
                else
                    r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors)
                end
            elseif ( UnitIsFriend("player", frame.unit) ) then
                r, g, b = 0.0, 1.0, 0.0
            else
                r, g, b = 1.0, 0.0, 0.0
            end
        end
    end

    local cR,cG,cB = frame.healthBar:GetStatusBarColor()
    if ( r ~= cR or g ~= cG or b ~= cB ) then

        if ( frame.optionTable.colorHealthWithExtendedColors ) then
            frame.selectionHighlight:SetVertexColor(r, g, b)
        else
            frame.selectionHighlight:SetVertexColor(1.0, 1.0, 1.0)
        end

        frame.healthBar:SetStatusBarColor(r, g, b)
    end

end)

-- Update Name

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not Nameplates:FrameIsNameplate(frame.displayedUnit) ) then return end
	
	-- Name

	frame.name:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 4)   		
    frame.name:SetFont("Fonts\\FRIZQT__.TTF", Nameplates.settings.nameSize)
	
	-- Abbreviate Long Names. 

    local newName = frame.name:GetText()
    newName = Nameplates:Abbrev(newName,32)
	frame.name:SetText(newName)

    -- Only Name Fix

    if not UnitIsPlayer(frame.displayedUnit) then
        frame.healthBar:Show()
    end

    -- Friendly Player Name.
	
	if ( UnitIsPlayer(frame.displayedUnit) and not UnitCanAttack(frame.displayedUnit,"player") and Nameplates.settings.friendlyName) then
		local friendly_name = GetUnitName(frame.displayedUnit,true)
		local _, class = UnitClass(frame.displayedUnit)
        local color = select(4, GetClassColor(class))
    	local text = "|c"..color..friendly_name:match("[^-]+")..""				
		frame.name:SetFont("Fonts\\FRIZQT__.TTF", Nameplates.settings.nameSize, "OUTLINE")
		frame.name:SetText(text)
        -- 
		if Nameplates.settings.hideHealth and not frame:IsForbidden() then
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
	
	-- Enemy Player Name.
	
	if ( UnitIsPlayer(frame.displayedUnit) and UnitCanAttack(frame.displayedUnit,"player") ) then
		local enemy_name = GetUnitName(frame.displayedUnit,true)
		local _, class = UnitClass(frame.displayedUnit)
        local color = select(4, GetClassColor(class))
    	local text = "|c"..color..enemy_name:match("[^-]+")..""				
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

hooksecurefunc("DefaultCompactNamePlateFrameSetup", function(frame, options)
    if ( frame:IsForbidden() ) then return end

    -- Health Bar Height

    frame.healthBar:SetHeight(Nameplates.settings.healthHeight)
    frame.healthBar:SetStatusBarTexture(statusBar)
    
    -- Elite Icon
        
    frame.ClassificationFrame:SetScale(0.9)

    -- Castbar.

    frame.castBar:SetStatusBarTexture(statusBar)
    frame.castBar.Text:SetShadowOffset(.5, -.5)
    frame.castBar.Text:SetFont("Fonts\\FRIZQT__.TTF", 8, "THINOUTLINE")
    frame.castBar:SetHeight(12)
    frame.castBar.Icon:SetSize(12, 12)
    frame.castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.castBar.Icon:SetPoint("RIGHT", frame.castBar, "LEFT", 2, 0)

    -- Castbar Timer.

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

end)

function Nameplates:ExtraAuras()

    ---
    --- NAMEPLATE BUFF FRAME
    ---

    -- icon inset amount
    local top = 1
    local right = 1
    local bottom = 1
    local left = 1

    -- border colour (RGBA values between0 and 1)
    local red = 0
    local green = 0
    local blue = 0
    local alpha = 1

    local Plate_IconHolders = {}

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

    local function PairsByKeys(t)
        local a = {}
        for n in pairs(t) do table.insert(a, n) end
        table.sort(a)
        local i = 0      -- iterator variable
        local iter = function ()   -- iterator function
            i = i + 1
            if a[i] == nil then return nil
            else return a[i], t[a[i]]
            end
          end
        return iter
    end

    ----------------------------------------------------------
    ---------------[[    Nameplate Icons    ]]----------------
    ----------------------------------------------------------

    local function CreateIcon(parent, tag)
        local button = CreateFrame("Frame", nil, parent)
        button:SetSize(20, 14.5)            
        button:SetScale(nameplateScale)
        
        button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
        button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
        button.icon:SetPoint("BOTTOMRIGHT", button,"BOTTOMRIGHT", -1, 1)
        button.icon:SetTexCoord(0.06, 0.94, 0.07, 0.62)

        --set the icon inset
        button.icon:ClearAllPoints()
        button.icon:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", left,bottom);
        button.icon:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0-right,0-top);

        button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
        button.overlay:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
        button.overlay:SetPoint("TOPLEFT", button, -3, 3)
        button.overlay:SetPoint("BOTTOMRIGHT", button, 3, -3)
        button.overlay:SetBlendMode("ADD")

        -- Border
        if not button.Backdrop then
            local backdrop = {
                bgFile = "Interface\\AddOns\\JokUI\\media\\textures\\Square_White.tga",
                edgeFile = "",
                tile = false,
                tileSize = 32,
                edgeSize = 0,
                insets = {
                    left = 0,
                    right = 0,
                    top = 0,
                    bottom = 0
                }
            }
            local Backdrop = CreateFrame("frame", nil, button);
            button.Backdrop = Backdrop;
            button.Backdrop:SetBackdrop(backdrop)
            button.Backdrop:SetAllPoints(button)
            button.Backdrop:Show();
        end
        button.Backdrop:SetBackdropColor(red, green, blue, alpha)

        local regionFrameLevel = button:GetFrameLevel() -- get strata for next bit
        button.Backdrop:SetFrameLevel(regionFrameLevel-2) -- put the border at the back

        button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        button.cd:SetAllPoints(button)
        button.cd:SetDrawEdge(false)
        button.cd:SetAlpha(1)
        button.cd:SetDrawSwipe(true)
        button.cd:SetReverse(true)
        
        if strfind(tag, "aura") then
            button.count = CreateText(button, "OVERLAY", 12, "OUTLINE", "RIGHT")
            button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -2)
            button.count:SetTextColor(1, 1, 1)
        end

        button:Hide()
        parent.QueueIcon(button, tag)
        
        return button
    end

    local function UpdateAuraIcon(button, unit, index, filter)
        local name, icon, count, debuffType, duration, expire, _, canStealOrPurge, _, spellID, _, _, _, nameplateShowAll = UnitAura(unit, index, filter)

        if button.spellID ~= spellID or button.expire ~= expire or button.count ~= count or buutton.duration ~= duration then
            CooldownFrame_Set(button.cd, expire - duration, duration, true, true)
        end

        button.icon:SetTexture(icon)
        button.expire = expire
        button.duration = duration
        button.spellID = spellID
        button.canStealOrPurge = canStealOrPurge
        button.nameplateShowAll = nameplateShowAll

        if canStealOrPurge then
            button.overlay:SetVertexColor(1, 1, 1)
            button.overlay:Show()
        else
            button.overlay:Hide()
        end

        if count and count > 1 then
            button.count:SetText(count)
        else
            button.count:SetText("")
        end

        --
        button:Show()
    end

    local function UpdateAuras(unitFrame)
        if not unitFrame.unit then return end
        local unit = unitFrame.unit 
        local i = 1
        
        for index = 1, BUFF_MAX_DISPLAY do
            if i <= 5 then          
                local name, _, _, _, duration, expire, caster, canStealOrPurge, _, spellID, _, _, _, nameplateShowAll = UnitAura(unit, index, 'HELPFUL')
                if canStealOrPurge or nameplates_aura_spells[spellID] then
                    if not unitFrame.icons.Aura_Icons[i] then
                        unitFrame.icons.Aura_Icons[i] = CreateIcon(unitFrame.icons, "aura"..i)
                    end
                    UpdateAuraIcon(unitFrame.icons.Aura_Icons[i], unit, index, 'HELPFUL')
                    i = i + 1
                end
            end
        end
        
        for index = 1, BUFF_MAX_DISPLAY do
            if i <= 5 then
                local name, _, _, _, duration, expire, caster, _, _, spellID, _, _, _, nameplateShowAll = UnitAura(unit, index, 'HARMFUL')  
                if nameplates_aura_spells[spellID] then
                    if not unitFrame.icons.Aura_Icons[i] then
                        unitFrame.icons.Aura_Icons[i] = CreateIcon(unitFrame.icons, "aura"..i)
                    end
                    UpdateAuraIcon(unitFrame.icons.Aura_Icons[i], unit, index, 'HARMFUL')
                    i = i + 1
                end
            end
        end
        
        for index = i, #unitFrame.icons.Aura_Icons do unitFrame.icons.Aura_Icons[index]:Hide() end
    end

    local function NamePlate_OnEvent(self, event, arg1, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            UpdateAuras(self)   
        elseif event == "UNIT_AURA" and arg1 == self.unit then
            UpdateAuras(self)
        end
    end

    local function SetUnit(unitFrame, unit)
        unitFrame.unit = unit
        if unit then
            unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            unitFrame:RegisterUnitEvent("UNIT_AURA", unitFrame.unit)
            unitFrame:SetScript("OnEvent", NamePlate_OnEvent)
            unitFrame.npcID = select(6, strsplit("-", UnitGUID(unit)))
        else
            unitFrame:UnregisterAllEvents()
            unitFrame:SetScript("OnEvent", nil)
            unitFrame.npcID = nil
        end
    end

    function NamePlates_UpdateAllNamePlates()
        for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
            local unitFrame = namePlate.suf
            UpdateAuras(unitFrame)
        end
    end

    local function OnNamePlateCreated(namePlate)
        namePlate.suf = CreateFrame("Button", "$parentUnitFrame", namePlate)
        namePlate.suf:SetAllPoints(namePlate)
        namePlate.suf:SetFrameLevel(namePlate:GetFrameLevel())
        
        namePlate.suf.icons = CreateFrame("Frame", nil, namePlate.suf)
        namePlate.suf.icons:SetPoint("BOTTOMLEFT", namePlate.UnitFrame.BuffFrame, "TOPLEFT", 1, 2)

        namePlate.suf.icons:SetWidth(100)
        namePlate.suf.icons:SetHeight(14.5)
        namePlate.suf.icons:SetFrameLevel(namePlate:GetFrameLevel()+1)

        namePlate.suf.icons.Aura_Icons = {}
        namePlate.suf.icons.Spell_Icons = {}
        
        namePlate.suf.icons.ActiveIcons = {}
        namePlate.suf.icons.LineUpIcons = function()
            local lastframe
            for v, frame in PairsByKeys(namePlate.suf.icons.ActiveIcons) do
                frame:ClearAllPoints()
                if not lastframe then
                    local num = 0
                    for k, j in pairs(namePlate.suf.icons.ActiveIcons) do
                        num = num + 1
                    end
                    frame:SetPoint("LEFT", namePlate.suf.icons, "LEFT", -0.5,0)
                else
                    frame:SetPoint("LEFT", lastframe, "RIGHT", 4, 0)
                end

                lastframe = frame
            end
        end
        
        namePlate.suf.icons.QueueIcon = function(frame, tag)
            frame.v = tag
            
            frame:HookScript("OnShow", function()
                namePlate.suf.icons.ActiveIcons[frame.v] = frame
                namePlate.suf.icons.LineUpIcons()
            end)
            
            frame:HookScript("OnHide", function()
                namePlate.suf.icons.ActiveIcons[frame.v] = nil
                namePlate.suf.icons.LineUpIcons()
            end)
        end
        
        table.insert(Plate_IconHolders, namePlate.suf.icons)
        
        namePlate.suf:EnableMouse(false)
    end

    local function OnNamePlateAdded(unit)
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        local unitFrame = namePlate.suf
        SetUnit(unitFrame, unit)
        UpdateAuras(unitFrame)
    end

    local function OnNamePlateRemoved(unit)
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        SetUnit(namePlate.suf, nil)
    end

    local function NamePlates_OnEvent(self, event, ...) 
        if ( event == "VARIABLES_LOADED" ) then
            NamePlates_UpdateAllNamePlates()
        elseif ( event == "NAME_PLATE_CREATED" ) then
            local namePlate = ...
            OnNamePlateCreated(namePlate)
        elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then 
            local unit = ...
            OnNamePlateAdded(unit)
        elseif ( event == "NAME_PLATE_UNIT_REMOVED" ) then 
            local unit = ...
            OnNamePlateRemoved(unit)
        end
    end

    local NamePlatesFrame = CreateFrame("Frame", "NamePlatesFrame", UIParent) 
    NamePlatesFrame:SetScript("OnEvent", NamePlates_OnEvent)
    NamePlatesFrame:RegisterEvent("VARIABLES_LOADED")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_CREATED")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end