local _, JokUI = ...
local MythicPlus = JokUI:RegisterModule("Mythic +")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local features = {}

local challengeMapID

local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8

local rowCount = 4
local requestKeystoneCheck

-- 1: Overflowing, 2: Skittish, 3: Volcanic, 4: Necrotic, 5: Teeming, 6: Raging, 7: Bolstering, 8: Sanguine, 9: Tyrannical, 10: Fortified, 11: Bursting, 12: Grievous, 13: Explosive, 14: Quaking
local affixSchedule = {
	{ 6, 3, 9 }, -- Raging / Volcanic / Tyrannical
	{ 5, 13, 10 }, -- Teeming / Explosive / Fortified
	{ 7, 12, 9 }, -- Bolstering / Grievous / Tyrannical
	{ 8, 4, 10 }, -- Sanguine / Necrotic / Fortified
	{ 11, 2, 9 }, -- Bursting / Skittish / Tyrannical
	{ 5, 14, 10 }, -- Teeming / Quaking / Fortified
	{ 6, 4, 9 }, -- Raging / Necrotic / Tyrannical
	{ 7, 2, 10 }, -- Bolstering / Skittish / Fortified
	{ 5, 3, 9 }, -- Teeming / Volcanic / Tyrannical
	{ 8, 12, 10 }, -- Sanguine / Grievous / Fortified
	{ 7, 13, 9 }, -- Bolstering / Explosive / Tyrannical
	{ 11, 14, 10 }, -- Bursting / Quaking / Fortified
}

schedule = {
	Week1 = "This week",
	Week2 = "Next week",
	Week3 = "In two weeks",
	Week4 = "In three weeks",
}

local currentWeek

local ipairs = ipairs
local print = print
local select = select
local strsplit = strsplit
local strtrim = strtrim
local string = string
local table = table
local _GetTime = GetTime

local quantity = 0
local lastKill = {0} -- To be populated later, do not remove the initial value. The zero means inconclusive/invalid data.
local currentPullUpdateTimer = 0
local activeNameplates = {}

mppSimulationMode = false
local simulationMax = 220
local simulationCurrent = 28

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

-- Default npc's progress values
defaultProgressValues = {{100216,4,"Hatecoil Wrangler"},{97182,6,"Night Watch Mariner"},{92168,8,"Target Dummy Test2"},{114716,1,"Boulangère fantôme"},{122413,4,"Traque-faille ombre-garde"},{91785,2,"Wandering Shellback"},{96480,1,"Viletongue Belcher"},{97087,2,"Valarjar Champion"},{96608,2,"Ebonclaw Worg"},{96640,2,"Valarjar Marksman"},{121711,4,"Flagellant vénéneux"},{95842,2,"Valarjar Thundercaller"},{91786,4,"Gritslime Snail"},{119923,4,"Soigneuse érédar"},{114334,4,"Golem endommagé"},{115388,5,"Roi"},{115484,4,"Gangroptère"},{114526,1,"Doublure fantomatique"},{100250,4,"Lieuse Ashioi"},{98813,4,"Bloodscent Felhound"},{95779,10,"Festerhide Grizzly"},{98366,4,"Ghostly Retainer"},{95843,4,"Roi Haldor"},{91787,1,"Mouette de la crique"},{98973,1,"Skeletal Warrior"},{95939,10,"Skrog Tidestomper"},{121553,4,"Chasseur de l'effroi"},{113537,10,"Unknown"},{114783,4,"Damoiselle repentie"},{105617,4,"Eredar Chaosbringer"},{95940,1,"Pillard mer-amère"},{102104,4,"Enslaved Shieldmaiden"},{115486,8,"Tueuse érudite"},{102232,4,"Rockbound Trapper"},{114624,8,"Gardien arcanique"},{99358,4,"Rotheart Dryad"},{98368,4,"Ghostly Protector"},{120405,4,"Aile de l'effroi"},{102584,4,"Malignant Defiler"},{105682,8,"Felguard Destroyer"},{104277,4,"Legion Hound"},{98177,12,"Glayvianna Soulrender"},{118713,4,"Lance-orbe gangrerôdeur"},{122322,4,"Roué affamé"},{99359,3,"Rotheart Keeper"},{113699,8,"Forgotten Spirit"},{120374,4,"Destructeur gangregarde"},{91790,4,"Mak'rana Siltwalker"},{114338,10,"Confluence de mana"},{105715,4,"Watchful Inquisitor"},{115488,4,"Pyromancien imprégné"},{104278,10,"Felbound Enforcer"},{118714,4,"Tentatrice feu-d'enfer"},{99360,9,"Vilethorn Blossom"},{98370,4,"Ghostly Councilor"},{104247,4,"Arcaniste de la Garde crépusculaire"},{105876,1,"Enchanted Broodling"},{98243,4,"Soul-Torn Champion"},{114627,4,"Terreur hurleuse"},{91792,10,"Stormwake Hydra"},{96934,2,"Valarjar Trapper"},{99649,12,"Dreadlord Mendacius"},{98691,4,"Risen Scout"},{118716,4,"Flagellant vénéneux"},{101438,4,"Vileshard Chunk"},{122421,8,"Adepte de la guerre ombreux"},{91793,1,"Seaspray Crab"},{119930,4,"Aile de l'effroi"},{96584,4,"Immoliant Fury"},{98756,4,"Arcane Anomaly"},{111563,4,"Duskwatch Guard"},{91794,1,"Saltscale Lurker"},{98533,10,"Foul Mother"},{102781,4,"Jeune gangroptère"},{102430,1,"Tarspitter Slug"},{98406,4,"Scorpion éclat-ardent"},{95947,4,"Mak'rana Hardshell"},{105720,4,"Understone Drudge"},{104251,4,"Duskwatch Sentry"},{90997,4,"Mightstone Breaker"},{118719,4,"Pillard langue-de-wyrm"},{99365,4,"Taintheart Stalker"},{124947,1,"Ecorcheur du Vide"},{100451,3,"Target Dummy Test"},{91796,10,"Skrog Wavecrasher"},{96587,4,"Felsworn Infester"},{90998,4,"Blightshard Shaper"},{98759,4,"Vicious Manafang"},{114632,4,"Domestique spectral"},{99366,4,"Taintheart Summoner"},{98919,4,"Seacursed Swiftblade"},{114792,4,"Dame vertueuse"},{116549,4,"Choriste"},{98728,7,"Bile acide"},{98792,4,"Wyrmtongue Scavenger"},{97068,5,"Drake-tempête"},{91000,8,"Vileshard Hulk"},{105915,4,"Nightborne Reclaimer"},{114634,4,"Serviteur immortel"},{114794,4,"Molosse squelettique"},{98538,10,"Dame Velandras Corvaltus"},{91001,4,"Tarspitter Lurker"},{97197,2,"Valarjar Purifier"},{118723,10,"Scrutax"},{114252,4,"Dévoreur de mana"},{98954,4,"Felsworn Myrmidon"},{95920,2,"Animated Storm"},{97677,1,"Barbed Spiderling"},{114636,4,"Garde fantôme"},{102404,4,"Stoneclaw Grubmaster"},{101414,2,"Saltscale Skulker"},{114796,4,"Hôtesse saine"},{113966,40,"Test NPC"},{113998,4,"Mightstone Breaker"},{102788,4,"Felspite Dominator"},{98732,1,"Plagued Rat"},{99307,12,"Skjal"},{114542,4,"Philanthrope fantomatique"},{97200,4,"Seacursed Soulkeeper"},{101991,4,"Nightmare Dweller"},{102566,12,"Grimhorn the Enslaver"},{121569,4,"Marcheur vilécorce"},{102375,3,"Runecarver Slave"},{115757,8,"Porte-flamme garde-courroux"},{98926,4,"Shadow Hunter"},{99629,1,"Pillard mer-amère"},{91006,4,"Rockback Gnasher"},{114544,4,"Ouvreur squelettique"},{105921,4,"Nightborne Spellsword"},{100364,4,"Spirit of Vengeance"},{122401,8,"Entourloupeur ombre-garde"},{95861,4,"Hatecoil Oracle"},{97043,4,"Seacursed Slaver"},{99630,1,"Pillard mer-amère"},{97171,10,"Hatecoil Arcanist"},{95766,4,"Crazed Razorbeak"},{114801,4,"Apprenti spectral"},{105699,3,"Mana Saber"},{120550,4,"Garde-courroux envahisseur"},{106785,1,"Bitterbrine Slave"},{91008,4,"Rockbound Pelter"},{97172,1,"Saltsea Droplet"},{122403,4,"Champion ombre-garde"},{114802,4,"Compagnon spectral"},{92350,4,"Understone Drudge"},{106786,1,"Bitterbrine Slave"},{104295,1,"Blazing Imp"},{98706,6,"Commander Shemdah'sohn"},{98770,4,"Wrathguard Felblade"},{96247,1,"Vileshard Crawler"},{95832,2,"Valarjar Shieldmaiden"},{114803,4,"Palefrenière spectrale"},{100527,3,"Dreadfire Imp"},{119977,4,"Flagellant constricteur"},{106787,1,"Bitterbrine Slave"},{118700,2,"Traqueur sylvechancre"},{95769,4,"Mindshattered Screecher"},{122405,4,"Adjuratrice ombre-garde"},{98963,1,"Blazing Imp"},{119978,1,"Flagellant fulminant"},{102253,4,"Understone Demolisher"},{96664,2,"Valarjar Runecarver"},{98900,4,"Wyrmtongue Trickster"},{100529,1,"Hatespawn Slime"},{102094,4,"Risen Swordsman"},{105703,1,"Mana Wyrm"},{101679,4,"Dreadsoul Poisoner"},{99188,4,"Waterlogged Soul Guard"},{102583,4,"Brûleur gangrené"},{101839,4,"Risen Companion"},{2,35,"Test NPC"},{95771,4,"Dreadsoul Ruiner"},{105629,1,"Wyrmtongue Scavenger"},{122407,4,"Traqueur dimensionnel"},{101549,1,"Arcane Minion"},{118717,4,"Diablotin feu-d'enfer"},{91332,4,"Stoneclaw Hunter"},{102095,4,"Lancier ressuscité"},{114629,4,"Factotum spectral"},{114804,4,"Destrier spectral"},{97081,5,"Roi Bjorn"},{114541,1,"Cliente spectrale"},{114628,4,"Serveur squelettique"},{102287,10,"Unknown"},{92610,4,"Batteur pierre-basse"},{118703,4,"Botaniste gangrenuit"},{122423,8,"Grand tisseur d'ombre"},{95772,4,"Frenzied Nightclaw"},{115765,4,"Annulateur abstrait"},{122408,4,"Traqueur des ombres"},{118724,4,"Gangréneur feu-d'enfer"},{100539,4,"Mornœil cœur-corrompu"},{100531,8,"Bloodtainted Fury"},{98173,4,"Mystique Ssa’veh"},{105705,4,"Bound Energy"},{120556,4,"Aile de l'effroi"},{111901,3,"Unknown"},{100248,4,"Ritualiste Lesha"},{104300,4,"Shadow Mistress"},{98275,4,"Risen Archer"},{114584,1,"Machiniste fantôme"},{118704,10,"Dul'zak"},{97097,4,"Helarjar Champion"},{105845,4,"Glowing Spiderling"},{115417,8,"Rat"},{97678,8,"Aranasi Broodmother"},{91781,4,"Hatecoil Warrior"},{98733,4,"Withered Fiend"},{122404,4,"Arqueur du Vide ombre-garde"},{91783,4,"Hatecoil Stormweaver"},{105706,10,"Prêtresse de misère"},{105651,10,"Dreadborne Seer"},{97083,5,"Roi Ranulf"},{114626,4,"Esprit lugubre"},{118690,4,"Garde-courroux envahisseur"},{98677,1,"Rook Spiderling"},{125860,8,"Gardien de la faille"},{118705,10,"Nal'asha"},{97365,4,"Seacursed Mistmender"},{114625,1,"Invité fantôme"},{98425,4,"Unstable Amalgamation"},{120366,4,"Tentatrice feu-d'enfer"},{91782,10,"Hatecoil Crusher"},{115831,4,"Dévoreur de mana"},{100526,4,"Tormented Bloodseeker"},{98521,10,"Lord Etheldrin Ravencrest"},{105636,4,"Understone Drudge"},{124171,4,"Subjugateur ombre-garde"},{97084,5,"Roi Tor"},{104270,8,"Guardian Construct"},{98681,6,"Rook Spinner"},{122410,1,"Ciaileron"},{97173,4,"Restless Tides"},{118706,2,"Jeune araignée nécrotique"},{95834,2,"Valarjar Mystic"},{96657,12,"Danse-lames Illianna"},{114714,4,"Régisseuse fantomatique"},{106059,4,"Warp Shade"},{98426,4,"Limon instable"},{106546,4,"Etincelle astrale"},{119952,4,"Destructeur gangregarde"},{99033,4,"Helarjar Mistcaller"},{122571,8,"Gardien de la faille"},{102351,1,"Mana Wyrm"},{96574,5,"Stormforged Sentinel"},{100441,1,"Unknown"},{116550,4,"Client spectral"},{100249,4,"Canaliste Varisz"},{104246,4,"Duskwatch Guard"},{114633,4,"Servante spectrale"},{98810,6,"Wrathguard Bladelord"},{114637,4,"Factionnaire spectral"},{114715,4,"Cuistot fantomatique"},{105952,6,"Withered Manawraith"},{122478,2,"Décharge du Vide"},{97185,10,"The Grimewalker"},{96611,2,"Taureau sabot-furieux"},{114364,1,"Wyrm gavé de mana"},{115418,8,"Araignée"},{98280,4,"Risen Arcanist"},{97119,1,"Shroud Hound"},}

local mythicplus_defaults = {
    profile = {
    	enableProgress = true,
    	showRawProgress = true,
		enableNameplateText = true,
		enablePullEstimate = true,
		enableTimer = true,
		cooldowns = {
    		enableCooldowns = true,
			iconSize = 30, 
			iconGap = 5,
			position = "LEFT",
			x = -5,
			y = 0,
    	},
    }
}

local mythicplus_config = {
    title = {
        type = "description",
        name = "|cff64b4ffMythic +",
        fontSize = "large",
        order = 0,
    },
    desc = {
        type = "description",
        name = "Various useful options for Mythic+.\n",
        fontSize = "medium",
        order = 1,
    },
    enableProgress = {
				type = "toggle",
				name = "Enable",
				width = "full",
				order = 2,
				set = function(info,val) MythicPlus.settings.enableProgress = val
				end,
				get = function(info) return MythicPlus.settings.enableProgress end
			},
    progress = {
        name = "Mythic + Progress",
        type = "group",
        inline = true,
        order = 3,
        disabled = function() return not MythicPlus.settings.enableProgress end,
        args = {
	        nameplateProgress = {
				type = "toggle",
				name = "Show Progress on Nameplates",
				width = "full",
				desc = "|cffaaaaaa Adds percentage progress on Nameplates |r",
		        descStyle = "inline",
				order = 2,
				set = function(info,val) MythicPlus.settings.enableNameplateText = val
				end,
				get = function(info) return MythicPlus.settings.enableNameplateText end
			},
			currentPull = {
				type = "toggle",
				name = "Show Current Pull Progress",
				width = "full",
				desc = "|cffaaaaaa Show a frame displaying current pull's progress |r",
		        descStyle = "inline",
				order = 3,
				set = function(info,val) MythicPlus.settings.enablePullEstimate = val
				end,
				get = function(info) return MythicPlus.settings.enablePullEstimate end
			},
			exportProgress = {
				type = "execute",
				name = "Export Progress",
				desc = "",
				order = 4,
				func = function(info,val) exportData() 
				end,
			},
			toggleProgress = {
				type = "execute",
				name = "Move Progress Frame",
				desc = "",
				order = 5,
				func = function(info,val) ProgressToggleFrame() 
				end,
			},
        },
    },
    inline = {
        type = "description",
        name = "",
        fontSize = "large",
        order = 4,
    },
    enableTimer = {
		type = "toggle",
		name = "Enable",
		width = "full",
		order = 5,
		set = function(info,val) MythicPlus.settings.enableTimer = val
		end,
		get = function(info) return MythicPlus.settings.enableTimer end
	},
    timer = {
        name = "Mythic + Timer",
        type = "group",
        inline = true,
        order = 6,
        disabled = function() return not MythicPlus.settings.enableTimer end,
        args = {
        	rawProgress = {
				type = "toggle",
				name = "Show Raw Progress",
				width = "full",
				desc = "|cffaaaaaa Show raw progress |r",
		        descStyle = "inline",
				order = 3,
				set = function(info,val) MythicPlus.settings.showRawProgress = val
				end,
				get = function(info) return MythicPlus.settings.showRawProgress end
			},
        },
    },
    enableCooldowns = {
		type = "toggle",
		name = "Enable",
		width = "full",
		order = 7,
		set = function(info,val) MythicPlus.settings.cooldowns.enableCooldowns = val
		end,
		get = function(info) return MythicPlus.settings.cooldowns.enableCooldowns end
	},
    cooldowns = {
        name = "Mythic + Cooldowns",
        type = "group",
        inline = true,
        order = 8,
        disabled = function() return not MythicPlus.settings.cooldowns.enableCooldowns end,
        args = {
        	iconSize = {
                type = "range",
                name = "Icon Size",
                desc = "",
                min = 20,
                max = 50,
                step = 1,
                order = 1,
                set = function(info,val) MythicPlus.settings.cooldowns.iconSize = val
                JokUI.EditCDBar("size")
                end,
                get = function(info, val) return MythicPlus.settings.cooldowns.iconSize end
            },
            iconGap = {
                type = "range",
                name = "Icon Space",
                desc = "",
                min = 0,
                max = 15,
                step = 1,
                order = 2,
                set = function(info,val) MythicPlus.settings.cooldowns.iconGap = val
                JokUI.EditCDBar("pos")
                end,
                get = function(info, val) return MythicPlus.settings.cooldowns.iconGap end
            },
            offsetX = {
                type = "range",
                name = "Offset X",
                desc = "",
                min = -20,
                max = 20,
                step = 1,
                order = 3,
                set = function(info,val) MythicPlus.settings.cooldowns.x = val
                JokUI.EditCDBar("pos")
                end,
                get = function(info, val) return MythicPlus.settings.cooldowns.x end
            },
            offsetY = {
                type = "range",
                name = "Offset Y",
                desc = "",
                min = -30,
                max = 30,
                step = 1,
                order = 4,
                set = function(info,val) MythicPlus.settings.cooldowns.y = val
                JokUI.EditCDBar("pos")
                end,
                get = function(info, val) return MythicPlus.settings.cooldowns.y end
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
                set = function(info,val) MythicPlus.settings.cooldowns.position = val
                JokUI.EditCDBar("pos")
                end,
                get = function(info, val) return MythicPlus.settings.cooldowns.position end
            },
        },
    },
    misc = {
        type = "description",
        name = "\n |cff64b4ffMisc",
        fontSize = "large",
        order = 9,
    },
}

function MythicPlus:OnInitialize()
    self.db = JokUI.db:RegisterNamespace("Mythic +", mythicplus_defaults)
    self.settings = self.db.profile
    JokUI.Config:Register("Mythic +", mythicplus_config, 11)
end

function MythicPlus:OnEnable()
	for name in pairs(features) do
		self:SyncFeature(name)
	end

	if MythicPlus.settings.enableProgress then
		self:Progress()
	end

	if MythicPlus.settings.enableTimer then
		self:Timer()
	end

	if MythicPlus.settings.cooldowns.enableCooldowns then
		self:Cooldowns()
	end

	self:Schedule()

	self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	self:RegisterEvent("CHALLENGE_MODE_START")
	self:RegisterEvent("CHALLENGE_MODE_RESET")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("BAG_UPDATE")

	self:AfterEnable()
end

function MythicPlus:AfterEnable()
	requestKeystoneCheck = true

	challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
	ObjectiveTracker_Update()
end

function MythicPlus:Blizzard_TalkingHeadUI()
	hooksecurefunc("TalkingHeadFrame_PlayCurrent", PlayCurrent)
end

function MythicPlus:ADDON_LOADED(event, addon)
	if addon == "Blizzard_TalkingHeadUI" then
		self:SyncFeature("MythicTalkingHead")
	end
	if addon == "Blizzard_ChallengesUI" then
		self:Blizzard_ChallengesUI()
	end
end

do
	local order = 10
	function MythicPlus:RegisterFeature(name, short, long, default, reload, fn)
		mythicplus_config[name] = {
			type = "toggle",
			name = short,
			descStyle = "inline",
			desc = "|cffaaaaaa" .. long,
			width = "full",
			get = function() return MythicPlus.settings[name] end,
			set = function(_, v)
				MythicPlus.settings[name] = v
				self:SyncFeature(name)
				if reload then
					StaticPopup_Show ("ReloadUI_Popup")
				end
			end,
			order = order
		}
		mythicplus_defaults.profile[name] = default
		order = order + 1
		features[name] = fn
	end
end

function MythicPlus:SyncFeature(name)
	features[name](MythicPlus.settings[name])
end

do
	MythicPlus:RegisterFeature("KeySlot",
		"Add keystone to mythic+ fountain",
		"Automatically puts your keystone into the font inside mythic dungeons.",
		true,
		false,
		function(state)
			if state then
				local slot = CreateFrame("frame")
				slot:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN");
				slot:SetScript("OnEvent", function()
				    for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS, 1 do
				        for j = 0, GetContainerNumSlots(i), 1 do
				            local link = GetContainerItemLink(i, j)
				            if link and link:find("keystone:") then
				                ClearCursor()
				                PickupContainerItem(i, j)
				                if CursorHasItem() then
				                    C_ChallengeMode.SlotKeystone()
				                end
				            end
				        end
				    end
				end)
			end
		end)
end

do
	local enabled = false
	MythicPlus:RegisterFeature("MythicTalkingHead",
		"Hide Talking Head in Mythic+",
		"Automatically hides Talking Head inside mythic dungeons.",
		true,
		false,
		function(state)
			if state then
				if not enabled and TalkingHeadFrame_PlayCurrent and select(10, C_Scenario.GetInfo()) == LE_SCENARIO_TYPE_CHALLENGE_MODE then
					enabled = true
					hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
						if state then TalkingHeadFrame:Hide() end
					end)
				end
			end
		end)
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

function MythicPlus:Timer()

	local function timeFormat(seconds)
		local hours = floor(seconds / 3600)
		local minutes = floor((seconds / 60) - (hours * 60))
		seconds = seconds - hours * 3600 - minutes * 60

		if hours == 0 then
			return format("%d:%.2d", minutes, seconds)
		else
			return format("%d:%.2d:%.2d", hours, minutes, seconds)
		end
	end
	MythicPlus.timeFormat = timeFormat

	local function timeFormatMS(timeAmount)
		local seconds = floor(timeAmount / 1000)
		local ms = timeAmount - seconds * 1000
		local hours = floor(seconds / 3600)
		local minutes = floor((seconds / 60) - (hours * 60))
		seconds = seconds - hours * 3600 - minutes * 60

		if hours == 0 then
			return format("%d:%.2d.%.3d", minutes, seconds, ms)
		else
			return format("%d:%.2d:%.2d.%.3d", hours, minutes, seconds, ms)
		end
	end
	MythicPlus.timeFormatMS = timeFormatMS

	local function GetTimerFrame(block)
		if not block.TimerFrame then
			local TimerFrame = CreateFrame("Frame", nil, block)
			TimerFrame:SetAllPoints(block)
			
			TimerFrame.Text = TimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
			TimerFrame.Text:SetPoint("LEFT", block.TimeLeft, "RIGHT", 4, 0)
			
			TimerFrame.Text2 = TimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
			TimerFrame.Text2:SetPoint("LEFT", TimerFrame.Text, "RIGHT", 4, 0)

			TimerFrame.Bar3 = TimerFrame:CreateTexture(nil, "OVERLAY")
			TimerFrame.Bar3:SetPoint("TOPLEFT", block.StatusBar, "TOPLEFT", block.StatusBar:GetWidth() * (1 - TIME_FOR_3) - 4, 0)
			TimerFrame.Bar3:SetSize(8, 10)
			TimerFrame.Bar3:SetTexture("Interface\\Addons\\JokUI\\media\\mythicplus\\bar")
			TimerFrame.Bar3:SetTexCoord(0, 0.5, 0, 1)

			TimerFrame.Bar2 = TimerFrame:CreateTexture(nil, "OVERLAY")
			TimerFrame.Bar2:SetPoint("TOPLEFT", block.StatusBar, "TOPLEFT", block.StatusBar:GetWidth() * (1 - TIME_FOR_2) - 4, 0)
			TimerFrame.Bar2:SetSize(8, 10)
			TimerFrame.Bar2:SetTexture("Interface\\Addons\\JokUI\\media\\mythicplus\\bar")
			TimerFrame.Bar2:SetTexCoord(0.5, 1, 0, 1)

			TimerFrame:Show()

			block.TimerFrame = TimerFrame
		end
		return block.TimerFrame
	end

	local function UpdateTime(block, elapsedTime)
		local TimerFrame = GetTimerFrame(block)

		local time3 = block.timeLimit * TIME_FOR_3
		local time2 = block.timeLimit * TIME_FOR_2

		TimerFrame.Bar3:SetShown(elapsedTime < time3)
		TimerFrame.Bar2:SetShown(elapsedTime < time2)

		if elapsedTime < time3 then
			TimerFrame.Text:SetText( timeFormat(time3 - elapsedTime) )
			TimerFrame.Text:SetTextColor(1, 0.843, 0)
			TimerFrame.Text:Show()
			TimerFrame.Text:SetFont("Fonts\\FRIZQT__.TTF", 15)
			
			TimerFrame.Text2:SetText( timeFormat(time2 - elapsedTime) )
			TimerFrame.Text2:SetTextColor(0.78, 0.78, 0.812)
			TimerFrame.Text2:Show()
			TimerFrame.Text2:SetFont("Fonts\\FRIZQT__.TTF", 11)

		elseif elapsedTime < time2 then
			TimerFrame.Text:SetText( timeFormat(time2 - elapsedTime) )
			TimerFrame.Text:SetTextColor(0.78, 0.78, 0.812)
			TimerFrame.Text:Show()
			TimerFrame.Text:SetFont("Fonts\\FRIZQT__.TTF", 15)
			TimerFrame.Text2:Hide()
		else
			TimerFrame.Text:Hide()
			TimerFrame.Text2:Hide()
		end

		if elapsedTime > block.timeLimit then
			block.TimeLeft:SetText(GetTimeStringFromSeconds(elapsedTime - block.timeLimit, false, true))
		end
	end

	local function GetElapsedTime()
		for i = 1, select("#", GetWorldElapsedTimers()) do
			local timerID = select(i, GetWorldElapsedTimers())
			local _, elapsedTime, type = GetWorldElapsedTime(timerID)
			if type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then
				return elapsedTime
			end
		end
	end

	local function IsInActiveInstance()
		return select(10, C_Scenario.GetInfo()) == LE_SCENARIO_TYPE_CHALLENGE_MODE
	end

	local function ProgressBar_SetValue(self, percent)
		if self.criteriaIndex then
			local _, _, _, _, totalQuantity, _, _, quantityString, _, _, _, _, _ = C_Scenario.GetCriteriaInfo(self.criteriaIndex)
			local currentQuantity = quantityString and tonumber( strsub(quantityString, 1, -2) )
			if currentQuantity and totalQuantity then
				self.Bar.Label:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
				if MythicPlus.settings.showRawProgress then
					self.Bar.Label:SetFormattedText("%.2f%% - %d/%d", currentQuantity/totalQuantity*100, currentQuantity, totalQuantity)
				else
					self.Bar.Label:SetFormattedText("%.2f%%", currentQuantity/totalQuantity*100)
				end
			end
		end
	end

	hooksecurefunc("ScenarioTrackerProgressBar_SetValue", ProgressBar_SetValue)

	local function ShowBlock(timerID, elapsedTime, timeLimit)
		local block = ScenarioChallengeModeBlock
		local level, affixes, wasEnergized = C_ChallengeMode.GetActiveKeystoneInfo()
		local dmgPct, healthPct = C_ChallengeMode.GetPowerLevelDamageHealthMod(level)
		block.Level:SetText( format("%s, +%d%%", CHALLENGE_MODE_POWER_LEVEL:format(level), dmgPct) )
		block.Level:SetFont("Fonts\\FRIZQT__.TTF", 14)
	end

	hooksecurefunc("Scenario_ChallengeMode_UpdateTime", UpdateTime)
	hooksecurefunc("Scenario_ChallengeMode_ShowBlock", ShowBlock)

	local keystoneWasCompleted = false
	function MythicPlus:PLAYER_ENTERING_WORLD()
		if keystoneWasCompleted and IsInGroup() and UnitIsGroupLeader("player") then
			StaticPopup_Show("CONFIRM_RESET_INSTANCES")
		end
		keystoneWasCompleted = false			
	end

	function MythicPlus:CHALLENGE_MODE_START()
		keystoneWasCompleted = false
		challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
		-- self:HideQuestModule()
	end

	function MythicPlus:CHALLENGE_MODE_RESET()
		keystoneWasCompleted = false
	end

	function MythicPlus:CHALLENGE_MODE_COMPLETED()
		keystoneWasCompleted = true
		if not challengeMapID then return end

		local mapID, level, time, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()
		local name, _, timeLimit = C_ChallengeMode.GetMapInfo(challengeMapID)

		timeLimit = timeLimit * 1000
		local timeLimit2 = timeLimit * TIME_FOR_2
		local timeLimit3 = timeLimit * TIME_FOR_3

		if time <= timeLimit3 then
			print( format("|cff33ff99<%s>|r |cffffd700%s|r", "JokUI", format("Beat the timer for +3 %s in %s. You were %s ahead of the +3 timer.", name, timeFormatMS(time), timeFormatMS(timeLimit3 - time))) )
		elseif time <= timeLimit2 then
			print( format("|cff33ff99<%s>|r |cffc7c7cf%s|r", "JokUI", format("Beat the timer for +2 %s in %s. You were %s ahead of the +2 timer, and missed +3 by %s.", name, timeFormatMS(time), timeFormatMS(timeLimit2 - time), timeFormatMS(time - timeLimit3))) )
		elseif onTime then
			print( format("|cff33ff99<%s>|r |cffeda55f%s|r", "JokUI", format("Beat the timer for %s in %s. You were %s ahead of the timer, and missed +2 by %s.", name, timeFormatMS(time), timeFormatMS(timeLimit - time), timeFormatMS(time - timeLimit2))) )
		else
			print( format("|cff33ff99<%s>|r |cffff2020%s|r", "JokUI", format("Timer expired for %s with %s, you were %s over the time limit.", name, timeFormatMS(time), timeFormatMS(time - timeLimit))) )
		end

		-- ScenarioTimer_CheckTimers(GetWorldElapsedTimers())
		-- ObjectiveTracker_Update()		
	end

	local function SkinProgressBars(self, _, line)
		local progressBar = line and line.ProgressBar
		local bar = progressBar and progressBar.Bar
		if not bar then return end
		local icon = bar.Icon
		local label = bar.Label

		if not progressBar.isSkinned then
			if bar.BarFrame then bar.BarFrame:Hide() end
			if bar.BarFrame2 then bar.BarFrame2:Hide() end
			if bar.BarFrame3 then bar.BarFrame3:Hide() end
			if bar.BarGlow then bar.BarGlow:Hide() end
			if bar.Sheen then bar.Sheen:Hide() end
			if bar.IconBG then bar.IconBG:SetAlpha(0) end
			if bar.BorderLeft then bar.BorderLeft:SetAlpha(0.5) end
			if bar.BorderRight then bar.BorderRight:SetAlpha(0.5) end
			if bar.BorderMid then bar.BorderMid:SetAlpha(0.5) end

			-- bar:CreateBackdrop("Transparent")
			ObjectiveTrackerFrame:SetScale(1.2)
			bar:SetWidth(210)
			bar:SetHeight(20)
			bar:SetStatusBarTexture("Interface\\Addons\\JokUI\\media\\mythicplus\\normTex2")
			
			ObjectiveTrackerBlocksFrame.ScenarioHeader.Background:Hide()
			ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)

			progressBar.isSkinned = true
		elseif icon and progressBar.backdrop then
			progressBar.backdrop:SetShown(icon:IsShown())
		end
	end
	hooksecurefunc(SCENARIO_TRACKER_MODULE,"AddProgressBar",SkinProgressBars)
end

function MythicPlus:HideQuestModule()
	ObjectiveTracker_Update_Old = ObjectiveTracker_Update
	function ObjectiveTracker_Update(...)
		if IsInActiveInstance() then
			local tracker = ObjectiveTrackerFrame
			local modules_old = tracker.MODULES
			local modules_ui_old = tracker.MODULES_UI_ORDER

			tracker.MODULES = { SCENARIO_CONTENT_TRACKER_MODULE }
			tracker.MODULES_UI_ORDER = { SCENARIO_CONTENT_TRACKER_MODULE }

			for i = 1, #modules_old do
				local module = modules_old[i]
				if module ~= SCENARIO_CONTENT_TRACKER_MODULE then
					module:BeginLayout()
					module:EndLayout()
					module.Header:Hide()
					if module.Header.animating then
						module.Header.animating = nil
						module.Header.HeaderOpenAnim:Stop()
					end
				end
			end

			ObjectiveTracker_Update_Old(...)

			tracker.MODULES = modules_old
			tracker.MODULES_UI_ORDER = modules_ui_old
		else
			ObjectiveTracker_Update_Old(...)
		end
	end

	ObjectiveTracker_ReorderModules_Old = ObjectiveTracker_ReorderModules
	function ObjectiveTracker_ReorderModules()
		if IsInActiveInstance() then
			local modules = ObjectiveTrackerFrame.MODULES;
			local modulesUIOrder = ObjectiveTrackerFrame.MODULES_UI_ORDER;
		else
			ObjectiveTracker_ReorderModules_Old()
		end
	end
end

function MythicPlus:Schedule()
	local function UpdateAffixes()
		if requestKeystoneCheck then
			self:CheckInventoryKeystone()
		end
		if currentWeek then
			for i = 1, rowCount do
				local entry = MythicPlus.Frame.Entries[i]
				entry:Show()

				local scheduleWeek = (currentWeek - 2 + i) % (#affixSchedule) + 1
				local affixes = affixSchedule[scheduleWeek]
				for j = 1, #affixes do
					local affix = entry.Affixes[j]
					affix:SetUp(affixes[j])
				end
			end
			MythicPlus.Frame.Label:Hide()
		else
			for i = 1, rowCount do
				MythicPlus.Frame.Entries[i]:Hide()
			end
			MythicPlus.Frame.Label:Show()
		end
	end

	local function makeAffix(parent)
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetSize(16, 16)

		local border = frame:CreateTexture(nil, "OVERLAY")
		border:SetAllPoints()
		border:SetAtlas("ChallengeMode-AffixRing-Sm")
		frame.Border = border

		local portrait = frame:CreateTexture(nil, "ARTWORK")
		portrait:SetSize(14, 14)
		portrait:SetPoint("CENTER", border)
		frame.Portrait = portrait

		frame.SetUp = ScenarioChallengeModeAffixMixin.SetUp
		frame:SetScript("OnEnter", ScenarioChallengeModeAffixMixin.OnEnter)
		frame:SetScript("OnLeave", GameTooltip_Hide)

		return frame
	end

	function MythicPlus:Blizzard_ChallengesUI()
		ChallengesFrame.GuildBest:ClearAllPoints()
		ChallengesFrame.GuildBest:SetPoint("TOPLEFT", ChallengesFrame.WeeklyBest.Child.Star, "BOTTOMRIGHT", 9, 30)

		local frame = CreateFrame("Frame", nil, ChallengesFrame)
		frame:SetSize(206, 110)
		frame:SetPoint("TOP", ChallengesFrame.WeeklyBest.Child.Star, "BOTTOM", 0, 30)
		frame:SetPoint("LEFT", ChallengesFrame, "LEFT", 40, 0)
		MythicPlus.Frame = frame

		local bg = frame:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetAtlas("ChallengeMode-guild-background")
		bg:SetAlpha(0.4)

		local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
		title:SetText("Schedule")
		title:SetPoint("TOPLEFT", 15, -7)

		local line = frame:CreateTexture(nil, "ARTWORK")
		line:SetSize(192, 9)
		line:SetAtlas("ChallengeMode-RankLineDivider", false)
		line:SetPoint("TOP", 0, -20)

		local entries = {}
		for i = 1, rowCount do
			local entry = CreateFrame("Frame", nil, frame)
			entry:SetSize(176, 18)

			local text = entry:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			text:SetWidth(120)
			text:SetJustifyH("LEFT")
			text:SetWordWrap(false)
			text:SetText( schedule["Week"..i] )
			text:SetPoint("LEFT")
			entry.Text = text

			local affixes = {}
			local prevAffix
			for j = 3, 1, -1 do
				local affix = makeAffix(entry)
				if prevAffix then
					affix:SetPoint("RIGHT", prevAffix, "LEFT", -4, 0)
				else
					affix:SetPoint("RIGHT")
				end
				prevAffix = affix
				affixes[j] = affix
			end
			entry.Affixes = affixes

			if i == 1 then
				entry:SetPoint("TOP", line, "BOTTOM")
			else
				entry:SetPoint("TOP", entries[i-1], "BOTTOM")
			end

			entries[i] = entry
		end
		frame.Entries = entries

		local label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		label:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 10, 0)
		label:SetPoint("TOPRIGHT", line, "BOTTOMRIGHT", -10, 0)
		label:SetJustifyH("CENTER")
		label:SetJustifyV("MIDDLE")
		label:SetHeight(72)
		label:SetWordWrap(true)
		label:SetText("Requires a level 7+ Mythic Keystone in your inventory to display.")
		frame.Label = label

		hooksecurefunc("ChallengesFrame_Update", UpdateAffixes)
	end

	function MythicPlus:CheckInventoryKeystone()
		currentWeek = nil
		for container=BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			local slots = GetContainerNumSlots(container)
			for slot=1, slots do
				local _, _, _, _, _, _, slotLink = GetContainerItemInfo(container, slot)
				local itemString = slotLink and slotLink:match("|Hkeystone:([0-9:]+)|h(%b[])|h")
				if itemString then
					local info = { strsplit(":", itemString) }
					local mapLevel = tonumber(info[2])
					if mapLevel >= 7 then
						local affix1, affix2 = tonumber(info[3]), tonumber(info[4])
						for index, affixes in ipairs(affixSchedule) do
							if affix1 == affixes[1] and affix2 == affixes[2] then
								currentWeek = index
							end
						end
					end
				end
			end
		end
		requestKeystoneCheck = false
	end

	function MythicPlus:BAG_UPDATE()
		requestKeystoneCheck = true
	end
end

function MythicPlus:Progress()

	function mppGetLastKill()
		return lastKill
	end

	--
	-- GENERAL ADDON UTILITY
	-- And by "utility" I mostly mean creating a bunch of shit that should really be built-in.

	local function split(str)
		a = {}
		for s in string.gmatch(str, "%S+") do
			table.insert(a, s)
		end
		return a
	end

	local function round(number, decimals)
	    return (("%%.%df"):format(decimals)):format(number)
	end

	local function tlen(t)
		local length = 0
		for _ in pairs(t) do
			length = length + 1
		end
		return length
	end

	local function GetTime()
		return _GetTime() * 1000
	end

	--
	-- WOW GENERAL WRAPPERS/EZUTILITIES
	--

	local function getNPCID(guid)
		local targetType, _,_,_,_, npcID = strsplit("-", guid or "")
		if targetType == "Creature" or targetType == "Vehicle" and npcID then
			return tonumber(npcID)
		end
	end

	-- TODO: Figure out how to filter out bosses.
	local function isValidTarget(targetToken)
		if UnitCanAttack("player", targetToken) and not UnitIsDead(targetToken) then
			return true
		end
	end

	local function getSteps()
		return select(3, C_Scenario.GetStepInfo())
	end

	local function isDungeonFinished()
		if mppSimulationMode then return false end
		return (getSteps() and getSteps() < 1)
	end

	-- Will also return true in challenge modes if those are ever re-implemented as M+ is basically recycled Challenge Mode.
	local function isMythicPlus()
		if mppSimulationMode then return true end
		local difficulty = select(3, GetInstanceInfo()) or -1
		if difficulty == 8 and not isDungeonFinished() then
			return true
		else
			return false
		end
	end

	local function getProgressInfo()
		if isMythicPlus() then
			local numSteps = select(3, C_Scenario.GetStepInfo()) -- GetStepInfo tells us how many steps there are.
			if numSteps and numSteps > 0 then
				local info = {C_Scenario.GetCriteriaInfo(numSteps)} -- It should be the last step.
				if info[13] == true then -- if isWeightedProgress
					return info
				end
			end
		end
	end

	function mppGetProgressInfo()
		return getProgressInfo()
	end
		
	local function getMaxQuantity()
		if mppSimulationMode then return simulationMax end
		local progInfo = getProgressInfo()
		if progInfo then
			return getProgressInfo()[5]
		end
	end

	local function getCurrentQuantity()
		if mppSimulationMode then return simulationCurrent end
		return strtrim(getProgressInfo()[8], "%")
	end

	local function getEnemyForcesProgress()
		-- Returns exact float value of current enemies killed progress (1-100).
		local quantity, maxQuantity = getCurrentQuantity(), getMaxQuantity()
		local progress = quantity / maxQuantity
		return progress * 100
	end

	--
	-- DB READ/WRITES
	--

	local function getValue(npcID)
		local npcData = JokUIDB["npcData"][npcID]
		if npcData then
			local hiValue, hiOccurrence = nil, -1
			for value, occurrence in pairs(npcData["values"]) do
				if occurrence > hiOccurrence then
					hiValue, hiOccurrence = value, occurrence
				end
			end
			if hiValue ~= nil then
				return hiValue
			end
		end
	end

	local function deleteEntry(npcID)
		local exists = (JokUIDB["npcData"][npcID] ~= nil)
		JokUIDB["npcData"][npcID] = nil
		return exists
	end

	local function updateValue(npcID, value, npcName, forceQuantity)
		if value <= 0 then
			return
		end
		local npcData = JokUIDB["npcData"][npcID]
		if not npcData then
			JokUIDB["npcData"][npcID] = {values={}, name=npcName or "Unknown"}
			return updateValue(npcID, value, npcName, forceQuantity)
		end
		local values = npcData["values"]
		if values[value] == nil then
			values[value] = (forceQuantity or 1)
		else
			values[value] = values[value] + (forceQuantity or 1)
		end
		for val, occurrence in pairs(values) do
			if val ~= value then
				values[val] = occurrence * 0.75 -- Newer values will quickly overtake old ones
			end
		end
	end

	-- Temp testing global access
	function mppUpdateValue(npcID, value, npcName, forceQuantity)
		return updateValue(npcID, value, npcName, forceQuantity)
	end

	-- Temp testing global access
	function mppGetValue(npcID, value)
		return getValue(npcID)
	end

	function exportData()
		local a = string.format("{",  tlen(JokUIDB["npcData"]))
		for npcID,t in pairs(JokUIDB["npcData"]) do
		   local value = getValue(npcID)
		   local name = t["name"]
		   a = a .. "{".. npcID..","..value..",\""..name.."\"},"
		end
		a = a .. "}"
		local f = CreateFrame('EditBox', "MPPExportBox", UIParent, "InputBoxTemplate")
		f:SetSize(200, 50)
		f:SetPoint("CENTER", 0, 350)
		f:SetFrameStrata("TOOLTIP")
		f:SetScript("OnEnterPressed", f.Hide)
		f:SetScript("OnEscapePressed", f.Hide)
		f:SetText(a)
	end

	--
	-- Light DB wrap
	--

	-- Returns a nil-100 number representing the percentual progress that npcID is expected to give you.
	local function getEstimatedProgress(npcID)
		local npcValue, maxQuantity = getValue(npcID), getMaxQuantity()
		if npcValue and maxQuantity then
			return (npcValue / maxQuantity) * 100
		end
	end

	local function getRawProgress(npcID)
		local npcValue, maxQuantity = getValue(npcID), getMaxQuantity()
		if npcValue and maxQuantity then
			return npcValue
		end
	end


	--
	-- TRIGGERS/HOOKS
	--

	-- Called when our enemy forces criteria increases, no matter how small the increase (but >0).
	local function onProgressUpdated(deltaProgress)
		if currentQuantity == getMaxQuantity() then
			return -- Disregard data that caps us as we don't know if we got the full value.
		end
		local timestamp, npcID, npcName, isDataUseful = unpack(lastKill) -- See what the last mob we killed was
		if timestamp and npcID and deltaProgress and isDataUseful then -- Assert that we have some useful data to work with
			local timeSinceKill = GetTime() - timestamp
			if timeSinceKill <= 600 then
				updateValue(npcID, deltaProgress, npcName) -- Looks like we have ourselves a valid entry. Set this in our database/list/whatever.
			end
		end
	end

	-- Called directly by our hook
	local function onCriteriaUpdate()
		if not currentQuantity then
			currentQuantity = 0
		end
		if not isMythicPlus() then return end
		newQuantity = getCurrentQuantity()
		deltaQuantity = newQuantity - currentQuantity
		if deltaQuantity > 0 then
			currentQuantity = newQuantity
			onProgressUpdated(deltaQuantity)
		end
			
	end

	-- Called directly by our hook
	local function onCombatLogEvent(args)
		--local _,combatType,_,_,_,_,_, destGUID, destName = unpack(args)
		--if combatType == "UNIT_DIED" then
		local timestamp, combatType, something, srcGUID, srcName, srcFlags, something2, destGUID, destName, destFlags = unpack(args)
		if combatType == "PARTY_KILL" then
			if not isMythicPlus() then return end
			local npcID = getNPCID(destGUID)
			if npcID then
				local isDataUseful = true
				local timeSinceLastKill = GetTime() - lastKill[1]
				if timeSinceLastKill <= 50 then
					isDataUseful = false
				end
				lastKill = {GetTime(), npcID, destName, isDataUseful} -- timestamp is not at all accurate, we use GetTime() instead.
			end
		end
	end				

	local function verifyDB(forceWipe)
		if not JokUIDB["npcData"] then
			JokUIDB["npcData"] = {}
		end
		if defaultProgressValues ~= nil then
			for k,v in pairs(defaultProgressValues) do
				local npcID, value, name = unpack(v)
				if getValue(npcID) == nil then
					updateValue(npcID, value, name, 1)
				end
			end
		end
	end

	-- Called directly by our hook
	local function onAddonLoad()
			verifyDB()
			if isMythicPlus() then
				quantity = getEnemyForcesProgress()
			else
				quantity = 0
			end
	end

	---
	--- TOOLTIPS
	---
		
	local function addLineToTooltip(str)
	    GameTooltip:AddDoubleLine(str)
	    GameTooltip:Show()
	end

	local function shouldAddTooltip(unit)
		if isMythicPlus() and isValidTarget(unit) then
			return true
		end
		return false
	end

	local function getTooltipMessage(npcID)
		local tempMessage = "|cFF82E0FFProgress : "
		local estProg = getEstimatedProgress(npcID)
		local rawProg = getRawProgress(npcID)
		if not estProg then
			return tempMessage .. "No record."
		end
		mobsLeft = (100 - getEnemyForcesProgress()) / estProg
		tempMessage = string.format("%s%s / %.2f%s", tempMessage, rawProg, estProg, "%")
		return tempMessage
	end
		
	local function onNPCTooltip(self)
		local unit = select(2, self:GetUnit())
		if unit then
			local guid = UnitGUID(unit)
			npcID = getNPCID(guid)
			if npcID and shouldAddTooltip(unit) then
				local tooltipMessage = getTooltipMessage(npcID)
				if tooltipMessage then
					addLineToTooltip(tooltipMessage)
				end
			end
		end
	end

	---
	--- SHITTY CURRENT PULL FRAME
	---

	currentPullFrame = CreateFrame("frame", "currentPullFrame12", UIParent)
	mppFrame = currentPullFrame
	currentPullFrame:SetPoint("TOP", ObjectiveTrackerBlocksFrame.ScenarioHeader, 0, 45)
	currentPullFrame:SetMovable(false)
	currentPullFrame:RegisterForDrag("LeftButton")
	currentPullFrame:SetScript("OnDragStart", currentPullFrame.StartMoving)
	currentPullFrame:SetScript("OnDragStop", currentPullFrame.StopMovingOrSizing)
	currentPullFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", tile = true, tileSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	currentPullFrame:SetBackdropColor(0, 0, 0, 0.5);
	currentPullFrame:SetWidth(50)
	currentPullFrame:SetHeight(50)
	currentPullFrame:SetScale(1)
	currentPullTitle = currentPullFrame:CreateFontString("currentPullTitle", "BACKGROUND", "GameFontHighlightLarge")
	currentPullTitle:SetPoint("TOP", 0, 12);
	currentPullTitle:SetText("|cfff2c521Mythic+ Progress|r");
	currentPullTitle:SetFont("Fonts\\FRIZQT__.TTF", 13)
	currentPullText = currentPullFrame:CreateFontString("currentPullString", "BACKGROUND", "GameFontHighlightLarge")
	currentPullText:SetPoint("CENTER");
	currentPullText:SetText("")

	---
	--- NAMEPLATES
	---

	local function isTargetPulled(target)
		local threat = UnitThreatSituation("player", target) or -1 -- Is nil if we're not on their aggro table, so make it -1 instead.
		if isValidTarget(target) and (threat >= 0 or UnitPlayerControlled(target.."target")) then
			return true
		end
		return false
	end
		
	local function getPulledUnits()
		local tempList = {}
		for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
			if nameplate.UnitFrame.unitExists then
				if isTargetPulled(nameplate.UnitFrame.displayedUnit) then
					table.insert(tempList, UnitGUID(nameplate.UnitFrame.displayedUnit))
				end
			end
		end
		return tempList
	end

	local function getPulledProgress(pulledUnits)
		local estProg = 0
		for _, guid in pairs(pulledUnits) do
			npcID = getNPCID(guid)
			if npcID then
				estProg = estProg + (getEstimatedProgress(npcID) or 0)
			end
		end
		return estProg
	end

	local function shouldShowCurrentPullEstimate()
		if MythicPlus.settings.enablePullEstimate and isMythicPlus() and not isDungeonFinished() then
			if not UnitAffectingCombat("player") then
				return true
			end
			return true
		end
		return false
	end

	local function setCurrentPullEstimateLabel(s)
		currentPullString:SetText(s)
		currentPullFrame:SetWidth(currentPullString:GetStringWidth()+40)
		currentPullFrame:SetHeight(currentPullString:GetStringHeight()+30)
		--print(currentPullFrame:GetCenter())
	end

	local function updateCurrentPullEstimate()
		if not shouldShowCurrentPullEstimate() then
			currentPullFrame:Hide()
			return
		else
			currentPullFrame:Show()
		end
		local pulledUnits = getPulledUnits()
		local estProg = getPulledProgress(pulledUnits)
		local curProg = getEnemyForcesProgress()
		local totProg = estProg + curProg
		if estProg == 0 then
			currentPullText:SetFont("Fonts\\FRIZQT__.TTF", 12)
			tempMessage = "       n/a       "
		else
			currentPullText:SetFont("Fonts\\FRIZQT__.TTF", 14)
			tempMessage = string.format("%.2f%s + %.2f%s = %.2f%s", curProg, "%", estProg, "%", (math.floor(totProg*100)/100), "%")
		end
		setCurrentPullEstimateLabel(tempMessage)
	end

	local function createNameplateText(token)
		local npcID = getNPCID(UnitGUID(token))
		if npcID and MythicPlus.settings.enableNameplateText then
			if activeNameplates[token] then
				activeNameplates[token]:Hide() -- This should never happen...
			end
			local nameplate = C_NamePlate.GetNamePlateForUnit(token)
			if nameplate then
				activeNameplates[token] = nameplate:CreateFontString(token.."mppProgress", nameplate.UnitFrame.healthBar, "GameFontHighlightSmall")
				activeNameplates[token]:SetText("+?%")
			end
		end
	end

	local function removeNameplateText(token)
		if activeNameplates[token] ~= nil then
			activeNameplates[token]:SetText("")
			activeNameplates[token]:Hide()
			activeNameplates[token] = nil
		end
	end
		
	local function updateNameplateValue(token)
		local npcID = getNPCID(UnitGUID(token))
		if npcID then
			local estProg = getEstimatedProgress(npcID)
			local rawProg = getRawProgress(npcID)
			if estProg and estProg > 0 then
				local tempMessage = "|cFF82E0FF(+"
				tempMessage = string.format("%s%s)", tempMessage, rawProg, estProg, "%")
				activeNameplates[token]:SetText(tempMessage)
				activeNameplates[token]:SetText(tempMessage)
				activeNameplates[token]:Show()
				return true
			end
		end
		if activeNameplates[token] then -- If mob dies, a new nameplate is created but not shown, and this ui widget will then not exist.
			activeNameplates[token]:SetText("")
			activeNameplates[token]:Hide()
		end
		return false
	end

	local function updateNameplateValues()
		for token,_ in pairs(activeNameplates) do
			updateNameplateValue(token)
		end
	end

	local function updateNameplatePosition(token)
		local nameplate = C_NamePlate.GetNamePlateForUnit(token)
		if nameplate.UnitFrame.unitExists and activeNameplates[token] ~= nil then
			activeNameplates[token]:SetPoint("LEFT", nameplate.UnitFrame.name, "RIGHT", 3, -1)
			activeNameplates[token]:SetFont("Fonts\\FRIZQT__.TTF", 8)
		else
			removeNameplateText(token)
		end
	end

	local function shouldShowNameplateTexts()
		if MythicPlus.settings.enableNameplateText and isMythicPlus() and not isDungeonFinished() then
			return true
		end
		return false
	end

	local function onAddNameplate(token)
		if shouldShowNameplateTexts() then
			createNameplateText(token)
			updateNameplateValue(token)
			updateNameplatePosition(token)
		end
	end

	local function onRemoveNameplate(token)
		removeNameplateText(token)
		activeNameplates[token] = nil -- This line has been made superflous tbh.
	end

	local function removeNameplates()
		for token,_ in pairs(activeNameplates) do
			removeNameplateText(token)
		end
	end

		
	local function updateNameplates()
		if shouldShowNameplateTexts() then
			for token,_ in pairs(activeNameplates) do
				updateNameplatePosition(token)
			end
		else
			removeNameplates()
		end
	end

	---
	--- SET UP HOOKS
	---

	local z = CreateFrame("FRAME")
	z:RegisterEvent("PLAYER_ENTERING_WORLD")
	z:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
	z:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	z:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	z:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

	function z:OnEvent(event, ...)
		args={...}
		if event == "PLAYER_ENTERING_WORLD" then
			onAddonLoad(args[1])
		elseif event == "SCENARIO_CRITERIA_UPDATE" then
			onCriteriaUpdate()
		elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
			onCombatLogEvent(args)
		elseif event == "NAME_PLATE_UNIT_ADDED" then
			onAddNameplate(...)
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			onRemoveNameplate(...)
		end
	end

	function z:OnUpdate(elapsed)
		currentPullUpdateTimer = currentPullUpdateTimer + elapsed * 1000 -- Not using milliseconds in 2016? WutFace
		if currentPullUpdateTimer >= 300 then
			currentPullUpdateTimer = 0
			updateCurrentPullEstimate()
			updateNameplateValues()
		end
		updateNameplates()
	end

	z:SetScript("OnEvent", z.OnEvent)
	z:SetScript("OnUpdate", z.OnUpdate)
	GameTooltip:HookScript("OnTooltipSetUnit", onNPCTooltip)
end

function MythicPlus:Cooldowns()

	--[[------------------------
	--     Group Inspect     --
	------------------------]]--

	pab = LibStub("AceAddon-3.0"):NewAddon("pab")

	if not pab then return end

	pab.Roster = {}
	pab.Frames = {}

	if not pab.events then
		pab.events = LibStub("CallbackHandler-1.0"):New(pab)
	end

	--[[
		1 WAR - FURY = 72  ARMS = 71  PROT = 73
		2 PALADIN - RET = 70  PROT = 65  HOLY = 66
		3 HUNT - MARKSMANSHIP = 254  BM = 253  SURVIVAL = 255
		4 ROGUE - SIN = 259  SUB = 260  OUTLAW = 261
		5 PRIEST -  DISC = 256  SHADOW = 258  HOLY = 257
		6 DK - BLOOD = 250  FROST = 251  UNHOLY = 252
		7 SHAMAN - ELEM = 262 EHNANCEMENT = 263  RESTO = 264
		8 MAGE - ARCANE = 62  FIRE = 63  FROST = 64
		9 WARLOCK - AFFLICTION = 265  DEMO = 266  DESTRO = 267
		10 MONK - BREWMASTER = 268  MISTWEAVER = 270  WINDWALKER = 269
		11 DRUID - BALANCE = 102  FERAL = 103  GUARDIAN = 104  RESTO = 105
		12 DH - HAVOC = 577  VENGEANCE = 581
	]]--

	local Cooldowns = {
		["PALADIN"] = {
			["642_11"] = {spellID = 642, cd = 240, spec =70, talent = 22485}, -- 圣盾术 惩戒
			["642_12"] = {spellID = 642, cd = 300, spec =70, talent = 22483}, -- 圣盾术 惩戒
			["642_13"] = {spellID = 642, cd = 300, spec =70, talent = 22484}, -- 圣盾术 惩戒
			["642_21"] = {spellID = 642, cd = 210, spec =65, talent = 17575}, -- 圣盾术 神圣
			["642_22"] = {spellID = 642, cd = 300, spec =65, talent = 22176}, -- 圣盾术 神圣
			["642_23"] = {spellID = 642, cd = 300, spec =65, talent = 17577}, -- 圣盾术 神圣
			["642_31"] = {spellID = 642, cd = 300, spec =66, talent = "all"}, -- 圣盾术 防护
			["1022_1"] = {spellID = 1022, cd = 240, spec =70, talent = "all"}, -- 保护之手 惩戒
			["1022_2"] = {spellID = 1022, cd = 240, spec =65, talent = "all"}, -- 保护之手 神圣
			["1022_3"] = {spellID = 1022, cd = 300, spec =66, talent = "all"}, -- 保护之手 防护
			["31850"] = {spellID = 31850, cd = 80, spec =66, talent = "all"}, -- 炽热防御者
			["86659"] = {spellID = 86659, cd = 300, spec =66, talent = "all"}, -- 远古列王守卫
			["20473"] = {spellID = 20473, cd = 8, spec =65, talent = "all"}, -- 神圣震击
		},
		
		["MAGE"] = {
			["45438"] = {spellID = 45438, cd = 240, spec ="all", talent = "all"}, -- 寒冰屏障
			["235219"] = {spellID = 235219, cd = 300, spec =64, talent = "all"}, -- 急速冷却
		},
		
		["DEMONHUNTER"] = {
			["196555"] = {spellID = 196555, cd = 120, spec = 577, talent = 21863}, -- 虚空行走 浩劫
			["198589"] = {spellID = 198589, cd = 60, spec = 577, talent = "all"}, -- 疾影 浩劫
		},
		
		["HUNTER"] = {
			["186265"] = {spellID = 186265, cd = 180, spec = "all", talent = "all"}, -- 灵龟守护
		},
		
		["ROGUE"] = {
			["31224"] = {spellID = 31224, cd = 90, spec = "all", talent = "all"}, -- 暗影斗篷
		},
		
		["SHAMAN"] = {
			["108271"] = {spellID = 108271, cd = 90, spec = "all", talent = "all"}, -- 星界转移
		},
		
		["DRUID"] = {
			["22812_1"] = {spellID = 22812, cd = 60, spec = 102, talent = "all"}, -- 树皮术 鹌鹑
			["22812_2"] = {spellID = 22812, cd = 60, spec = 105, talent = "all"}, -- 树皮术 树
			["22812_3"] = {spellID = 22812, cd = 90, spec = 104, talent = "all"}, -- 树皮术 熊
			["61336_1"] = {spellID = 61336, cd = 120, spec = 103, charge = 2, talent = "all"}, -- 生存本能
			["61336_2"] = {spellID = 61336, cd = 240, spec = 104, charge = 2, talent = "all"}, -- 生存本能
			
		},
		
		["PRIEST"] = {
			["47585"] = {spellID = 47585, cd = 80, spec = 258, talent = "all"}, -- 消散
		},
		
		["MONK"] = {
			["115203"] = {spellID = 115203, cd = 420, spec = 268, talent = "all"}, -- 壮胆酒
			["122470"] = {spellID = 122470, cd = 90, spec = 269, talent = "all"}, -- 业报之触
			["122783"] = {spellID = 122783, cd = 90, spec = 269, talent = 20173}, -- 散魔功
		},
		
		["DEATHKNIGHT"] = {
			["48707"] = {spellID = 48707, cd = 60, spec = "all", talent = "all"}, -- AMS
			["48792_1"] = {spellID = 48792, cd = 180, spec = 251, talent = "all"}, -- IBF
			["48792_2"] = {spellID = 48792, cd = 180, spec = 252, talent = "all"}, -- IBF
			["55233"] = {spellID = 55233, cd = 90, spec = 250, talent = "all"}, -- VAMPIRIC BLOOD
			["49028"] = {spellID = 49028, cd = 180, spec = 250, talent = "all"}, -- DANCING RUNIC WEAPON
			
		},
		
		["WARRIOR"] = {
			["871"] = {spellID = 871, cd = 240, spec = 73, talent = "all"}, -- 盾墙
			["12975"] = {spellID = 12975, cd = 180, spec = 73, talent = "all"}, -- 破釜沉舟
			["118038"] = {spellID = 118038, cd = 180, spec = 71, talent = "all"}, -- 剑在人在
			["184364"] = {spellID = 184364, cd = 120, spec = 72, talent = "all"}, -- 狂怒回复	
		},
		
		["WARLOCK"] = {
			["104773_1"] = {spellID = 104773, cd = 60, spec = 267, talent = "all"}, -- 不灭决心
			["104773_2"] = {spellID = 104773, cd = 200, spec = 266, talent = "all"}, -- 不灭决心
			["104773_3"] = {spellID = 104773, cd = 240, spec = 265, talent = "all"}, -- 不灭决心
		}
		
	}

	JokUI.createborder = function(f, r, g, b)
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

	JokUI.createtext = function(frame, layer, fontsize, flag, justifyh, shadow)
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
		icon:SetSize(MythicPlus.settings.cooldowns.iconSize, MythicPlus.settings.cooldowns.iconSize)
		JokUI.createborder(icon)
		
		icon.spellID = 0
		
		icon.cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
		icon.cd:SetAllPoints(icon)
        icon.cd:SetDrawEdge(false)
		icon.cd:SetAlpha(.9)
		icon.cd:SetScript("OnShow", function()
			if not pab['Roster'][icon.player_name][icon.spellID] then return end
			if pab['Roster'][icon.player_name][icon.spellID]["charge"] then
				icon:SetAlpha(1)
			else
				icon:SetAlpha(1)
			end
		end)
		icon.cd:SetScript("OnHide", function()	
			if pab['Roster'][icon.player_name] and pab['Roster'][icon.player_name][icon.spellID] and pab['Roster'][icon.player_name][icon.spellID]["charge"] then
				if pab['Roster'][icon.player_name][icon.spellID]["charge"] == pab['Roster'][icon.player_name][icon.spellID]["max_charge"] then return end
				pab['Roster'][icon.player_name][icon.spellID]["charge"] = pab['Roster'][icon.player_name][icon.spellID]["charge"] + 1
				icon.count:SetText(pab['Roster'][icon.player_name][icon.spellID]["charge"])
				if pab['Roster'][icon.player_name][icon.spellID]["charge"] ~= pab['Roster'][icon.player_name][icon.spellID]["max_charge"] then
					icon.cd:SetCooldown(GetTime(), pab['Roster'][icon.player_name][icon.spellID]["dur"])
				end
			else
				icon:SetAlpha(1)
				f.lineup()
			end
		end)
		
		icon.tex = icon:CreateTexture(nil, "OVERLAY")
		icon.tex:SetAllPoints(icon)
		icon.tex:SetTexCoord( .1, .9, .1, .9)
		
		icon.count = JokUI.createtext(icon, "OVERLAY", 16, "OUTLINE", "RIGHT")
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
		f:SetSize(MythicPlus.settings.cooldowns.iconSize, MythicPlus.settings.cooldowns.iconSize)
		f.icons = {}
		
		for i = 1, 6 do
			CreateIcon(f)
		end
		
		f.point = function()
			f:ClearAllPoints()
			local hasGrid = IsAddOnLoaded("Grid")
			local hasGrid2 = IsAddOnLoaded("Grid2")
			local hasCompactRaid = IsAddOnLoaded("CompactRaid")
			local hasVuhDo = IsAddOnLoaded("VuhDo")
			local hasElvUI = _G["ElvUF_Raid"] and _G["ElvUF_Raid"]:IsVisible()
			local hasAltzUI = _G["Altz_HealerRaid"] and _G["Altz_HealerRaid"]:IsVisible()
			
			for i=1, 40 do
					local uf = _G["CompactRaidFrame"..i]
					if uf and uf.unitExists and uf.unit and UnitIsUnit(uf.unit, unit) then
						if MythicPlus.settings.cooldowns.position == "RIGHT" then
							f:SetPoint("RIGHT", uf, "LEFT", MythicPlus.settings.cooldowns.x, MythicPlus.settings.cooldowns.y)
						elseif MythicPlus.settings.cooldowns.position == "LEFT" then
							f:SetPoint("LEFT", uf, "RIGHT", -MythicPlus.settings.cooldowns.x, MythicPlus.settings.cooldowns.y)
						elseif MythicPlus.settings.cooldowns.position == "BOTTOM" then
							f:SetPoint("BOTTOM", uf, "TOP", MythicPlus.settings.cooldowns.x, MythicPlus.settings.cooldowns.y)
						elseif MythicPlus.settings.cooldowns.position == "TOP" then
							f:SetPoint("TOP", uf, "BOTTOM", MythicPlus.settings.cooldowns.x, -MythicPlus.settings.cooldowns.y)
						end
						break
					end
				end
				for i=1, 4 do
					for j=1, 5 do
						local uf = _G["CompactRaidGroup"..i.."Member"..j]
						if uf and uf.unitExists and uf.unit and UnitIsUnit(uf.unit, unit) then
							if MythicPlus.settings.cooldowns.position == "RIGHT" then
								f:SetPoint("RIGHT", uf, "LEFT", MythicPlus.settings.cooldowns.x, MythicPlus.settings.cooldowns.y)
							elseif MythicPlus.settings.cooldowns.position == "LEFT" then
								f:SetPoint("LEFT", uf, "RIGHT", -MythicPlus.settings.cooldowns.x, MythicPlus.settings.cooldowns.y)
							elseif MythicPlus.settings.cooldowns.position == "BOTTOM" then
								f:SetPoint("BOTTOM", uf, "TOP", MythicPlus.settings.cooldowns.x, MythicPlus.settings.cooldowns.y)
							elseif MythicPlus.settings.cooldowns.position == "TOP" then
								f:SetPoint("TOP", uf, "BOTTOM", MythicPlus.settings.cooldowns.x, -MythicPlus.settings.cooldowns.y)
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
				f.icons[i]:SetSize(MythicPlus.settings.cooldowns.iconSize, MythicPlus.settings.cooldowns.iconSize)
			end
		end
		
		f.update_unit = function()
			f.reset()
			
			f.name = UnitName(unit)

			if f.name then
				local spell_num = 0
				if pab['Roster'][f.name] then
					for spellid, info in pairs(pab['Roster'][f.name]) do
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
						if f.icons[i]["spellID"] == spellid and pab['Roster'][f.name][spellid] then
							local info = pab['Roster'][f.name][spellid]
							if info["start"] and info["start"] + info["dur"] > GetTime() then
								if pab['Roster'][f.name][spellid]["charge"] then
									if pab['Roster'][f.name][spellid]["charge"] == pab['Roster'][f.name][spellid]["max_charge"] then
										f.icons[i]["cd"]:SetCooldown(info["start"], info["dur"])
									end
									pab['Roster'][f.name][spellid]["charge"] = pab['Roster'][f.name][spellid]["charge"] - 1
									f.icons[i]["count"]:SetText(pab['Roster'][f.name][spellid]["charge"])
									if pab['Roster'][f.name][spellid]["charge"] == 0 then
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
						if icon_spellid ~= 0 and pab['Roster'][f.name][icon_spellid] then
							local info = pab['Roster'][f.name][icon_spellid]
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

				if MythicPlus.settings.cooldowns.position == "RIGHT" then
					f.icons[i]:SetPoint("RIGHT", f, "RIGHT", -(i-1)*(MythicPlus.settings.cooldowns.iconSize+MythicPlus.settings.cooldowns.iconGap), 0)
				elseif MythicPlus.settings.cooldowns.position == "LEFT" then
					f.icons[i]:SetPoint("LEFT", f, "LEFT", (i-1)*(MythicPlus.settings.cooldowns.iconSize+MythicPlus.settings.cooldowns.iconGap), 0)
				elseif MythicPlus.settings.cooldowns.position == "TOP" then
					f.icons[i]:SetPoint("TOP", f, "TOP", 0, (i-1)*(MythicPlus.settings.cooldowns.iconSize+MythicPlus.settings.cooldowns.iconGap))
				elseif MythicPlus.settings.cooldowns.position == "BOTTOM" then
					f.icons[i]:SetPoint("BOTTOM", f, "BOTTOM", 0, -(i-1)*(MythicPlus.settings.cooldowns.iconSize+MythicPlus.settings.cooldowns.iconGap))
				end
			
				
				if f.icons[i].spellID ~= 0 and i<= 6 then
					f.icons[i]:Show()
				else
					f.icons[i]:Hide()
				end
			end
		end
		
		table.insert(pab.Frames, f)
	end

	local function UpdateCDBar(tag)
		for i = 1, #pab.Frames do
			local f = pab.Frames[i]		
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
		for i = 1, #pab.Frames do
			local f = pab.Frames[i]
			if f.name and f.name == name then
				f.update_cd(spellID)
				f.lineup()
			end
		end
	end

	JokUI.EditCDBar = function(tag)
		for i = 1, #pab.Frames do
			local f = pab.Frames[i]
			
			if tag == "show" then
				if not IsInRaid() then
					f:Show()
				else
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

	function pab:OnUpdate(unit, info)
		if not info.name or not info.class or not info.global_spec_id or not info.talents then return end
		
		if Cooldowns[info.class] then	
			if UnitInParty(info.name) then
				if not pab['Roster'][info.name] or pab['Roster'][info.name]["spec"] ~= info.global_spec_id then
					pab['Roster'][info.name] = {}
					pab['Roster'][info.name]["spec"] = info.global_spec_id
				
					for tag, spell_info in pairs (Cooldowns[info.class]) do
						if (spell_info.spec == "all" or spell_info.spec == info.global_spec_id) and (spell_info.talent == "all" or info.talents[spell_info.talent]) then
							pab['Roster'][info.name][spell_info.spellID] = {}
							pab['Roster'][info.name][spell_info.spellID]["dur"] = spell_info.cd
							pab['Roster'][info.name][spell_info.spellID]["tag"] = tag
							pab['Roster'][info.name][spell_info.spellID]["max_charge"] = spell_info.charge
							pab['Roster'][info.name][spell_info.spellID]["charge"] = spell_info.charge
						end
					end
				end
				UpdateCDBar("all")
			elseif pab['Roster'][info.name] then
			
				pab['Roster'][info.name] = nil
				UpdateCDBar("all")
				
			end
		end
	end

	function pab:OnRemove(guid)
		if (guid) then
		    local name = select(6, GetPlayerInfoByGUID(guid))
			if pab['Roster'][name] then
				pab['Roster'][name] = nil
				UpdateCDBar("all")
			end
		else
			pab['Roster'] = {}
			UpdateCDBar("all")
		end
	end

	local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")

	function pab:OnInitialize()
		LGIST.RegisterCallback (pab, "GroupInSpecT_Update", function(event, ...)
			pab.OnUpdate(...)
		end)
		LGIST.RegisterCallback (pab, "GroupInSpecT_Remove", function(...)
			pab.OnRemove(...)
		end)
	end

	local Group_Update = CreateFrame("Frame")
	Group_Update:RegisterEvent("PLAYER_ENTERING_WORLD")

	local function ResetCD()
		for player, spells in pairs(pab['Roster']) do
			for spellid, info in pairs(pab['Roster'][player]) do
				if spellid ~= "spec" then
					pab['Roster'][player][spellid]["start"] = 0
				end
			end
		end
	end

	Group_Update:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_ENTERING_WORLD" then
		
			CreateCDBar("party1")
			CreateCDBar("party2")
			CreateCDBar("party3")
			CreateCDBar("party4")
			CreateCDBar("player")
			--ResetCD()
			JokUI.EditCDBar("show")
			
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
		
			local _, event_type, _, sourceGUID, sourceName, _, _, _, _, _, _, spellID = ...
			
			if not sourceName or not spellID then return end
			local name = string.split("-", sourceName)
			if event_type == "SPELL_CAST_SUCCESS" and pab['Roster'][name] then
				if pab['Roster'][name][spellID] then
					pab['Roster'][name][spellID]["start"] = GetTime()
					UpdateCD(name, spellID)
				end
				if spellID == 235219 then -- ICEBLOCK RESET
					pab['Roster'][name][45438]["start"] = 0 -- ICEBLOCK
					UpdateCD(name, 45438)
				elseif spellID == 49998 then -- VAMPIRIC BLOOD
					local info = LGIST:GetCachedInfo (sourceGUID)
					if info.talents[22014] and pab['Roster'][name][55233]["start"] then
							pab['Roster'][name][55233]["start"] = pab['Roster'][name][55233]["start"]-7.5
							UpdateCD(name, 55233)
					end
				elseif spellID == 191427 then -- METAMORPH RESET
					local info = LGIST:GetCachedInfo (sourceGUID)
					if info.talents[22767] then -- VOILE CORROMPU
						pab['Roster'][name][198589]["start"] = 0
						UpdateCD(name, 198589)
					end
				end
			end

			if event_type == "SPELL_DAMAGE" and pab['Roster'][name] then -- SHOCKWAVE
				if spellID == 46968 then
					state.hits = state.hits+1
            		if state.hits == 3 then
                		state.expirationTime = state.expirationTime-20
                		state.hits = 0
            		end
				end
			end

			if event_type == "SPELL_INTERRUPT" and pab['Roster'][name] then -- SOLAR BEAM
				if spellID == 97547	then
					pab['Roster'][name][78675]["start"] = pab['Roster'][name][78675]["start"]-15
				end
			end
			
		end
	end)
end