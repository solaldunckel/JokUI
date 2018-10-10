local _, JokUI = ...
local Nameplates = JokUI:RegisterModule("Nameplates")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local _, class = UnitClass("player")

local match = string.match
local format = format
local floor = floor
local ceil = ceil

local castbarFont = SystemFont_Shadow_Small:GetFont()
local texturePath = "Interface\\TargetingFrame\\"
local statusBar = texturePath.."UI-StatusBar"

local nameplates_aura_spells = {

    -- BUFFS/DEBUFFS

    	-- Add missing class debuffs 
    		[214621] = true, -- Schism
            [228358] = true, -- Flurry
            [79140] = true, -- Vendetta

            -- Azerite
            	[280817] = true, -- Battlefield Focus

        -- Mythic+ (Buffs)
            [277242] = true, -- Infested (G'huun)
            [209859] = true, -- Bolster (Affix)
            [226510] = true, -- Sanguine Ichor (Affix)
            [263246] = true, -- Lightning Shield (Temple of Sethralis)
            [260805] = true, -- Claim The Iris (Waycrest Manor)

        -- Mythic+ (Debuffs)
            [256493] = true, -- Blazing Azerite (The MOTHERLODE!!!)
            [277965] = true, -- Heavy Ordnance (Siege)

    -- PVP BUFFS

        -- Death Knight
            [47568] = true, -- Empower Runic Weapon
            [51271] = true, -- Pillar of Frost
            [48707] = true, -- AMS
            [48792] = true, -- IBF

        -- Demon Hunter
            [212800] = true, -- Blur

        -- Druid
            [194223] = true, -- Celestial Alignment
            [22812] = true, -- Barskin
            [61336] = true, -- Survival Instincts
            [102342] = true, -- Ironbark
            [102560] = true, -- Incarn (MK)
            [102543] = true, -- Incarn (Feral)

        -- Hunter
            [193526] = true, -- Trueshot
            [19574] = true, -- Bestial Wrath
            [186265] = true, -- Turtle

        -- Mage
            [12472] = true, -- Icy Veins
            [190319] = true, -- Combustion
            [12042] = true, -- Arcane Power
            [45438] = true, -- Ice Block
            [198111] = true, -- Temporal Shield

        -- Monk
            [201318] = true, -- Fortifying Brew
            [122470] = true, -- Touch of Karma
            [122783] = true, -- Diffuse Magic
            [216113] = true, -- Way of the Crane

        -- Paladin
            [31884] = true, -- Avenging Wrath
            [210294] = true, -- Divine Favor
            [1022] = true, -- Blessing of Protection
            [6940] = true, -- Sacrifice
            [498] = true, -- Divine Protection
            [642] = true, -- Divine Shield
            [184662] = true, -- Shield of Vengeance

        -- Priest
            [200183] = true, -- Apotheosis
            [33206] = true, -- Pain Suppression
            [47788] = true, -- Guardian Spirit
            [47536] = true, -- Rapture
            [47585] = true, -- Dispersion
            [197862] = true, -- Archangel

        -- Rogue
            [199754] = true, -- Riposte
            [5277] = true, -- Evasion
            [31224] = true, -- Cloak of Shadows
            [13750] = true, -- Adrenaline Rush
            [121471] = true, -- Shadow Blades

        -- Shaman
            [2825] = true, -- Bloodlust
            [108271] = true, -- Astral Shift

        -- Warlock
            [212295] = true, -- Nether Ward
            [104773] = true, -- Unending Resolve
            [196098] = true, -- Soul Harvest
            [113860] = true, -- Dark Soul : Misery

        -- Warrior 
            [118038] = true, -- Die by the Sword
            [184364] = true, -- Enraged Regeneration
            [23920] = true, -- Spell Reflect
            [107574] = true, -- Avatar
            [1719] = true, -- Recklessness
            [227847] = true, -- Bladestorm
            [197690] = true, -- Def Stance
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
        arenanumber = true,
        globalScale = 1,
        targetScale = 1,
        importantScale = 1,
        sticky = true,
        nameplateAlpha = 1,
        nameplateRange = 50,
        overlap = true,
        verticalOverlap = 0.6,
        horizontalOverlap = 0.8,
        friendlymotion = true,
        clickthroughfriendly = true,
        enemytotem = true,
        enemypets = false,
        enemyguardian = false,
        enemyminus = false, 
        healthWidth = 120,
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
                min = 10,
                max = 200,
                step = 1,
                order = 2,
                set = function(info,val) Nameplates.settings.healthWidth = val
                    C_NamePlate.SetNamePlateEnemySize(val,50)
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
end

function Nameplates:OnEnable()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT') 

    self:SecureHook('CompactUnitFrame_UpdateName')
    self:SecureHook('CompactUnitFrame_UpdateHealthColor')

    self:ExtraAuras()

    -- Set CVAR
    SetCVar("nameplateGlobalScale", Nameplates.settings.globalScale)
    SetCVar("nameplateSelectedScale", Nameplates.settings.targetScale)
    SetCVar("nameplateLargerScale", Nameplates.settings.importantScale)
    SetCVar("nameplateOverlapV", Nameplates.settings.verticalOverlap)
    SetCVar("nameplateOverlapH", Nameplates.settings.horizontalOverlap)
    SetCVar("nameplateHorizontalScale", 1)        
    SetCVar("nameplateMotion", Nameplates.settings.overlap)
    SetCVar("nameplateShowEnemyGuardians", Nameplates.settings.enemyguardian)
    SetCVar("nameplateShowEnemyTotems", Nameplates.settings.enemytotem)
    SetCVar("nameplateShowEnemyPets", Nameplates.settings.enemypets)

    SetCVar("nameplateMinScale", 1)
    SetCVar("nameplateMaxScale", 1)
    SetCVar("nameplateShowDebuffsOnFriendly", 0)

    SetCVar("nameplateShowAll", 1)
    --SetCVar("NameplatePersonalShowAlways", 0)
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

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

function Nameplates:IsPet(unit)
    return (not UnitIsPlayer(unit) and UnitPlayerControlled(unit))
end

-- Class Color Text

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

function Nameplates:SetPlayerNameByClass(unit, text)
    local _, class = UnitClass (unit)
    if (class) then
        local color = RAID_CLASS_COLORS [class]
        if (color) then
            text = "|c" .. color.colorStr .. text:gsub (("%-.*"), "") .. "|r"
        end
    end
    return text
end

-- Is Showing Resource Frame?

function Nameplates:IsShowingResourcesOnTarget()
    if GetCVar("nameplateResourceOnTarget") == "1" and GetCVar("nameplateShowSelf") == "1" then
        return true
    end
end

-- Group Members Snippet 

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

local function PlayerIsTank(unit)
    local assignedRole = UnitGroupRolesAssigned(unit)
    return assignedRole == "TANK"
end

function Nameplates:UseOffTankColor(unit)
    if ( UnitPlayerOrPetInRaid(unit) or UnitPlayerOrPetInParty(unit) ) then
        if ( not UnitIsUnit("player", unit) and PlayerIsTank("player") and PlayerIsTank(unit) ) then
            return true
        end
    end
    return false
end

local moblist = {
	-- Mythic +
		-- Atal'dazar	
			[127757] = {tag = "DANGEROUS"}, -- Reanimated Honor Guard
			[122971] = {tag = "DANGEROUS"}, -- Dazar'ai Juggernaut
			[128434] = {tag = "DANGEROUS"}, -- Feasting Skyscreamer

		-- Freehold
			[127111] = {tag = "DANGEROUS"}, -- Irontide Oarsman
			[129527] = {tag = "DANGEROUS"}, -- Bilge Rat Buccaneer

		-- King's Rest
			[134174] = {tag = "DANGEROUS"}, -- Shadow-Borne Witch Doctor
			[135167] = {tag = "DANGEROUS"}, -- Spectral Berserker	
			[135235] = {tag = "DANGEROUS"}, -- Spectral Beastmaster
			[137591] = {tag = "DANGEROUS"}, -- Healing Tide Totem
			[135764] = {tag = "DANGEROUS"}, -- Explosive Totem

		-- Siege of Boralus
			[138255] = {tag = "OTHER"}, -- Ashvane Spotter
			[128969] = {tag = "DANGEROUS"}, -- Ashvane Commander
			[138465] = {tag = "DANGEROUS"}, -- Ashvane Cannoneer
			[132530] = {tag = "DANGEROUS"}, -- Kul Tiran Vanguard

		-- Temple of Sethralis 
			[135846] = {tag = "OTHER"}, -- Sand-Crusted Striker
			[134364] = {tag = "DANGEROUS"}, -- Faithless Tender
			[139946] = {tag = "DANGEROUS"}, -- Heart Guardian
			[135007] = {tag = "DANGEROUS"}, -- Orb Guardian

		-- The Underrot
			[130909] = {tag = "DANGEROUS"}, -- Fetid Maggot
				
    [113966] = {tag = "DANGEROUS"}, -- Training Dummy
    [92166] = {tag = "OTHER"}, -- Training Dummy
}

function Nameplates:GetNpcID(unit)
    local npcID = select(6, strsplit("-", UnitGUID(unit)))

    return tonumber(npcID)
end

function Nameplates:IsDangerous(unit)
	local npcID = self:GetNpcID(unit)

	for k, npcs in pairs(moblist) do
		if k == npcID then
			return true
		end
    end
end

function Nameplates:DangerousColor(unit)
	local r, g, b
	local dangerousColor = {r = 1.0, g = 0.7, b = 0.0}
	local otherColor = {r = 0.0, g = 0.7, b = 1.0}

	local npcID = self:GetNpcID(unit)

	for k, npcs in pairs(moblist) do
		local tag = npcs["tag"]

		if k == npcID then
			if tag == "DANGEROUS" then			
				r, g, b = dangerousColor.r, dangerousColor.g, dangerousColor.b
			elseif tag == "OTHER" then
				r, g, b = otherColor.r, otherColor.g, otherColor.b
			end			
		end
    end
    return r, g, b
end

-----------------------------------------

function Nameplates:SkinPlates(frame)

	if self:IsDangerous(frame.displayedUnit) then
		frame.name:SetTextColor(self:DangerousColor(frame.displayedUnit))
		frame.healthBar:SetStatusBarColor(self:DangerousColor(frame.displayedUnit))
	end

    -- Only Name Fix

    frame.healthBar:Show()

    -- Name

    frame.name:SetPoint("BOTTOM", frame.healthBar, "TOP", 0, 4)         
    frame.name:SetFont("Fonts\\FRIZQT__.TTF", Nameplates.settings.nameSize)

     -- Health Bar Height

    frame.healthBar:SetHeight(Nameplates.settings.healthHeight)
    frame.healthBar:SetStatusBarTexture(statusBar)
    frame.selectionHighlight:SetTexture(statusBar)    
    
    -- Abbreviate Long Names. 

    frame.name:SetText(Nameplates:Abbrev(frame.name:GetText(),24))
   
    -- Friendly Player Name.
    
    if ( UnitIsPlayer(frame.displayedUnit) and not UnitCanAttack(frame.displayedUnit,"player")) then
        local name = GetUnitName(frame.displayedUnit,true)
        frame.name:SetFont("Fonts\\FRIZQT__.TTF", Nameplates.settings.nameSize, "OUTLINE")
        frame.name:SetText(Nameplates:SetPlayerNameByClass(frame.displayedUnit, name))
        frame:SetAlpha(1)
        -- 
        frame.name:SetPoint("BOTTOM", frame.castBar, "TOP", 0, 4)
        frame.healthBar:Hide()
    end
    
    --Enemy Player Name.
    
    if ( UnitCanAttack(frame.displayedUnit,"player") and UnitIsPlayer(frame.displayedUnit) ) then
        local name = GetUnitName(frame.displayedUnit,true)
        frame.name:SetFont("Fonts\\FRIZQT__.TTF", Nameplates.settings.nameSize, "OUTLINE")
        frame.name:SetText(Nameplates:SetPlayerNameByClass(frame.displayedUnit, name))
    end
    
    -- Arena Number on Nameplates.
    
    if IsActiveBattlefieldArena() and frame.displayedUnit:find("nameplate") and Nameplates.settings.arenanumber then 
        for i=1,3 do 
            if UnitIsUnit(frame.displayedUnit,"arena"..i) then 
                frame.name:SetText(i)
                frame.name:SetFont("Fonts\\FRIZQT__.TTF", 11)
                frame.name:SetTextColor(1,1,0)
                break 
            end 
        end 
    end
end

function Nameplates:SkinCastBar(frame)

    -- Castbar.

    frame.castBar:SetStatusBarTexture(statusBar)
    frame.castBar.Text:SetShadowOffset(.5, -.5)
    frame.castBar.Text:SetFont("Fonts\\FRIZQT__.TTF", 8, "THINOUTLINE")
    frame.castBar:SetHeight(10)
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
end

function Nameplates:ThreatColor(frame)
    local r, g, b
    local npcID = self:GetNpcID(frame.displayedUnit)

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
                r, g, b = 0.5, 0.5, 0.5
            elseif ( Nameplates:IsDangerous(frame.displayedUnit) ) then
				r, g, b = Nameplates:DangerousColor(frame.displayedUnit)
            elseif ( frame.optionTable.colorHealthBySelection ) then
                if ( frame.optionTable.considerSelectionInCombatAsHostile and Nameplates:IsOnThreatListWithPlayer(frame.displayedUnit) ) then    
                    local target = frame.displayedUnit.."target"
                    local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
                    if ( isTanking and threatStatus ) then
                        if ( threatStatus >= 3 ) then
                            r, g, b = 0.5, 0.75, 0.95
                        elseif ( threatStatus == 2 ) then
                            r, g, b = 1.0, 0.6, 0.2
                        end
                    elseif ( Nameplates:UseOffTankColor(target) ) then
                        r, g, b = 1.0, 0.0, 1.0
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
end

function Nameplates:Highlight(frame)
    if UnitIsUnit(frame.displayedUnit, "target") then return end
    if UnitIsPlayer(frame.displayedUnit) and not UnitCanAttack(frame.displayedUnit, "player") then return end

    local function SetBorderColor(frame, r, g, b, a)
        frame.healthBar.border:SetVertexColor(r, g, b, a);
        if frame.castBar and frame.castBar.border then
            frame.castBar.border:SetVertexColor(r, g, b, a);
        end
    end

    frame.selectionHighlight:Show()
    SetBorderColor(frame, frame.optionTable.selectedBorderColor:GetRGBA());

    frame:SetScript('OnUpdate', function(frame)
        if not UnitExists('mouseover') or not UnitIsUnit('mouseover', frame.displayedUnit) then   
            if not UnitIsUnit(frame.displayedUnit, "target") then
                frame.selectionHighlight:Hide()
                SetBorderColor(frame, frame.optionTable.defaultBorderColor:GetRGBA());
            end
            frame:SetScript('OnUpdate',nil)
        end
    end)
end

-------------------------------------------------------------------------------
-- SKIN
-------------------------------------------------------------------------------

function Nameplates:PLAYER_ENTERING_WORLD()

    -- Remove Larger Nameplates Function (thx Plater)
    InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Disable()
    InterfaceOptionsNamesPanelUnitNameplatesMakeLarger.setFunc = function() end

    C_NamePlate.SetNamePlateEnemySize(Nameplates.settings.healthWidth, 45)

    -- Friendly Force Stacking
    if Nameplates.settings.friendlymotion and Nameplates.settings.overlap then
        local _, instanceType = IsInInstance()
        if instanceType == "party" or instanceType == "raid" then
            SetCVar("nameplateShowOnlyNames", 1)
            C_NamePlate.SetNamePlateFriendlySize(80, 0.1)
        else
            SetCVar("nameplateShowOnlyNames", 0)
            C_NamePlate.SetNamePlateFriendlySize(120, 0.1)
        end
    end

    -- Clickthrough Friendly Nameplates
    if Nameplates.settings.clickthroughfriendly then
        C_NamePlate.SetNamePlateFriendlyClickThrough(true)
    end

    -- Nameplate Class Bar
    if not InCombatLockdown() then
        if class == "WARLOCK" or class == "DEATHKNIGHT" or class == "ROGUE" then
            SetCVar("nameplateResourceOnTarget", 1)
            SetCVar("nameplateShowSelf", 1)
        else
            SetCVar("nameplateResourceOnTarget", 0)
            SetCVar("nameplateShowSelf", 0)
        end
    end
end

function Nameplates:CompactUnitFrame_UpdateName(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not Nameplates:FrameIsNameplate(frame.displayedUnit) ) then return end

    self:SkinPlates(frame)
    self:SkinCastBar(frame)
end

function Nameplates:CompactUnitFrame_UpdateHealthColor(frame)
    if ( frame:IsForbidden() ) then return end
    if ( not Nameplates:FrameIsNameplate(frame.displayedUnit) ) then return end

    self:ThreatColor(frame) 
end

function Nameplates:UPDATE_MOUSEOVER_UNIT()
    local nameplate = C_NamePlate.GetNamePlateForUnit('mouseover')
    if not nameplate then return end
	local frame = nameplate.UnitFrame

    self:Highlight(frame)
end

function Nameplates:COMBAT_LOG_EVENT_UNFILTERED()
    if IsInGroup() then
        local time, event, hidding, sourceGUID, sourceName, sourceFlag, sourceFlag2, targetGUID, targetName, targetFlag, targetFlag2, spellID, spellName, spellType, amount, overKill, school, resisted, blocked, absorbed, isCritical = CombatLogGetCurrentEventInfo()
        if event == "SPELL_INTERRUPT" then
            for _, plateFrame in ipairs (C_NamePlate.GetNamePlates()) do
                local token = plateFrame.namePlateUnitToken
                if (plateFrame.UnitFrame.castBar:IsShown()) then
                    --for u in Nameplates:GroupMembers() do
                        --if UnitIsUnit(sourceName, u) then
                            if (plateFrame.UnitFrame.castBar.Text:GetText() == INTERRUPTED) then
                                if (UnitGUID(token) == targetGUID) then
                                    plateFrame.UnitFrame.castBar.Text:SetText (INTERRUPTED .. Nameplates:SetTextColorByClass(sourceName, sourceName))
                                end
                            end
                       -- end
                   -- end
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
                                plateFrame.UnitFrame.castBar.Text:SetText(name .. Nameplates:SetTextColorByClass(targetName, targetName))
                            end
                        end
                    end  
                end
            end
        end       
    end
end

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
        text:SetFont("Fonts\\FRIZQT__.TTF", fontsize, flag)
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
        button:SetSize(21, 15)            
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

        button:SetScript("OnEnter", function(self)
        	GameTooltip:ClearLines()
		    GameTooltip:SetOwner(button.icon, "ANCHOR_TOPRIGHT", -25);
        	GameTooltip:SetUnitAura(unit, index, filter)
        	GameTooltip:Show()
        end)

        button:SetScript("OnLeave", function(self)
        	GameTooltip:Hide()
        end)

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
        local j = 1

        -- Debuffs

        for index = 1, BUFF_MAX_DISPLAY do
            local name, _, _, _, duration, expire, caster, _, nameplateShowPersonal, spellID, _, _, castByPlayer, nameplateShowAll = UnitAura(unit, index, 'HARMFUL')  
            if (nameplates_aura_spells[spellID] and caster == "player") or (nameplateShowPersonal and caster == "player") or nameplateShowAll then
                if not unitFrame.debuff.Aura_Icons[i] then
                    unitFrame.debuff.Aura_Icons[i] = CreateIcon(unitFrame.debuff, "aura"..i)
                end
                UpdateAuraIcon(unitFrame.debuff.Aura_Icons[i], unit, index, 'HARMFUL')
                i = i + 1
            end
        end      
        
        for index = i, #unitFrame.debuff.Aura_Icons do unitFrame.debuff.Aura_Icons[index]:Hide() end

        -- Buffs
        
        for index = 1, BUFF_MAX_DISPLAY do         
            local name, _, _, _, duration, expire, caster, canStealOrPurge, _, spellID, _, _, _, nameplateShowAll = UnitAura(unit, index, 'HELPFUL')
            if canStealOrPurge or nameplates_aura_spells[spellID] then
                if not unitFrame.buff.Aura_Icons[j] then
                    unitFrame.buff.Aura_Icons[j] = CreateIcon(unitFrame.buff, "aura"..j)
                end
                UpdateAuraIcon(unitFrame.buff.Aura_Icons[j], unit, index, 'HELPFUL')
                j = j + 1
            end
        end

        for index = j, #unitFrame.buff.Aura_Icons do unitFrame.buff.Aura_Icons[index]:Hide() end

        -- Frame Size

        if i == 1 then
            unitFrame.debuff:SetHeight(0.1)
        elseif i > 1 then
            unitFrame.debuff:SetHeight(15)
        end

        if j == 1 then
            unitFrame.buff:SetHeight(0.1)
        elseif j > 1 then
            unitFrame.buff:SetHeight(15)
        end
       
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
        if namePlate.UnitFrame:IsForbidden() then return end

        namePlate.suf = CreateFrame("Button", "$parentUnitFrame", namePlate)
        namePlate.suf:SetAllPoints(namePlate)
        namePlate.suf:SetFrameLevel(namePlate:GetFrameLevel())

        -- Debuff Frame
        namePlate.suf.debuff = CreateFrame("Frame", nil, namePlate.suf)

        namePlate.suf.debuff:SetPoint("BOTTOM", namePlate.UnitFrame.name, "TOP", 0, 3)
        
        namePlate.suf.debuff:SetWidth(100)
        namePlate.suf.debuff:SetHeight(15)
        namePlate.suf.debuff:SetFrameLevel(namePlate:GetFrameLevel())

        namePlate.suf.debuff.Aura_Icons = {}
        namePlate.suf.debuff.Spell_Icons = {}
        
        namePlate.suf.debuff.ActiveIcons = {}
        namePlate.suf.debuff.LineUpIcons = function()
            local lastframe
            for v, frame in PairsByKeys(namePlate.suf.debuff.ActiveIcons) do
                frame:ClearAllPoints()
                if not lastframe then
                    local num = 0
                    for k, j in pairs(namePlate.suf.debuff.ActiveIcons) do
                        num = num + 1
                    end
                    frame:SetPoint("BOTTOMLEFT", namePlate.suf.debuff, "BOTTOMLEFT", 0,0)
                else
                    frame:SetPoint("BOTTOMLEFT", lastframe, "BOTTOMRIGHT", 3, 0)
                end

                lastframe = frame
            end
        end
        
        namePlate.suf.debuff.QueueIcon = function(frame, tag)
            frame.v = tag
            
            frame:HookScript("OnShow", function()
                namePlate.suf.debuff.ActiveIcons[frame.v] = frame
                namePlate.suf.debuff.LineUpIcons()
            end)
            
            frame:HookScript("OnHide", function()
                namePlate.suf.debuff.ActiveIcons[frame.v] = nil
                namePlate.suf.debuff.LineUpIcons()
            end)
        end

        -- Buff Frame
        namePlate.suf.buff = CreateFrame("Frame", nil, namePlate.suf)

        namePlate.suf.buff:SetPoint("BOTTOMLEFT", namePlate.suf.debuff, "TOPLEFT", 0, 3)
        
        namePlate.suf.buff:SetWidth(100)
        namePlate.suf.buff:SetHeight(15)
        namePlate.suf.buff:SetFrameLevel(namePlate:GetFrameLevel())

        namePlate.suf.buff.Aura_Icons = {}        
        namePlate.suf.buff.ActiveIcons = {}

        namePlate.suf.buff.LineUpIcons = function()
            local lastframe
            for v, frame in PairsByKeys(namePlate.suf.buff.ActiveIcons) do
                frame:ClearAllPoints()
                if not lastframe then
                    local num = 0
                    for k, j in pairs(namePlate.suf.buff.ActiveIcons) do
                        num = num + 1
                    end
                    frame:SetPoint("LEFT", namePlate.suf.buff, "LEFT", 0,0)
                else
                    frame:SetPoint("LEFT", lastframe, "RIGHT", 3, 0)
                end

                lastframe = frame
            end
        end
        
        namePlate.suf.buff.QueueIcon = function(frame, tag)
            frame.v = tag
            
            frame:HookScript("OnShow", function()
                namePlate.suf.buff.ActiveIcons[frame.v] = frame
                namePlate.suf.buff.LineUpIcons()
            end)
            
            frame:HookScript("OnHide", function()
                namePlate.suf.buff.ActiveIcons[frame.v] = nil
                namePlate.suf.buff.LineUpIcons()
            end)
        end
        
        table.insert(Plate_IconHolders, namePlate.suf.buff)
        table.insert(Plate_IconHolders, namePlate.suf.debuff)
        
        namePlate.suf:EnableMouse(false)
    end

    local function OnNamePlateAdded(unit)
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        local unitFrame = namePlate.suf

        if namePlate.UnitFrame:IsForbidden() then return end

        namePlate.UnitFrame.BuffFrame:Hide()
        SetUnit(unitFrame, unit)
        UpdateAuras(unitFrame)
    end

    local function OnNamePlateRemoved(unit)
        local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
        SetUnit(namePlate.suf, nil)
    end

    local function OnTargetChanged()
        for _, frame in pairs(C_NamePlate.GetNamePlates(issecure())) do
            if ( not frame.UnitFrame:IsForbidden() ) then
                if Nameplates:IsShowingResourcesOnTarget() and UnitIsUnit(frame.UnitFrame.displayedUnit, "target") then
                    frame.suf.debuff:SetPoint("BOTTOM", NamePlateTargetResourceFrame, "TOP", 0, 5)
                else   
                    if ( frame.UnitFrame.displayedUnit and UnitShouldDisplayName(frame.UnitFrame.displayedUnit) ) then
                        frame.suf.debuff:SetPoint("BOTTOM", frame.UnitFrame.name, "TOP", 0, 3)
                    elseif ( frame.UnitFrame.displayedUnit ) then
                        frame.suf.debuff:SetPoint("BOTTOM", frame.UnitFrame.healthBar, "TOP", 0, 5)
                    end
                end
            end
        end  
    end

    local function BuffFrameAnchor(unit)
        local frame = C_NamePlate.GetNamePlateForUnit(unit, issecure())
        if ( not frame ) then return end 
        if ( not frame.UnitFrame:IsForbidden() ) then
            if Nameplates:IsShowingResourcesOnTarget() and UnitIsUnit(frame.UnitFrame.displayedUnit, "target") then
                frame.suf.debuff:SetPoint("BOTTOM", NamePlateTargetResourceFrame, "TOP", 0, 5)
            else                      
                if ( frame.UnitFrame.displayedUnit and UnitShouldDisplayName(frame.UnitFrame.displayedUnit) ) then
                    frame.suf.debuff:SetPoint("BOTTOM", frame.UnitFrame.name, "TOP", 0, 3)
                elseif ( frame.UnitFrame.displayedUnit ) then
                    frame.suf.debuff:SetPoint("BOTTOM", frame.UnitFrame.healthBar, "TOP", 0, 5)
                end
            end
        end
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
            BuffFrameAnchor(unit)
        elseif ( event == "NAME_PLATE_UNIT_REMOVED" ) then 
            local unit = ...
            OnNamePlateRemoved(unit)
        elseif ( event == "PLAYER_TARGET_CHANGED" ) then 
            OnTargetChanged()
        elseif ( event == "UNIT_AURA" ) then
            local unit = ...
            BuffFrameAnchor(unit)
        end
    end

    local NamePlatesFrame = CreateFrame("Frame", "NamePlatesFrame", UIParent) 
    NamePlatesFrame:SetScript("OnEvent", NamePlates_OnEvent)
    NamePlatesFrame:RegisterEvent("VARIABLES_LOADED")
    NamePlatesFrame:RegisterEvent("UNIT_AURA")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_CREATED")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    NamePlatesFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end