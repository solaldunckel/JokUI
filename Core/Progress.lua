----------------------------------------------------
------  Mythic Plus Progress (code by Fakie) --------
----------------------------------------------------

local ipairs = ipairs
local print = print
local select = select
local strsplit = strsplit
local strtrim = strtrim
local string = string
local table = table
local _GetTime = GetTime

local loaded = false
local quantity = 0
local lastKill = {0} -- To be populated later, do not remove the initial value. The zero means inconclusive/invalid data.
local currentPullUpdateTimer = 0
local activeNameplates = {}

mppDebug = false
mppSimulationMode = false

local simulationMax = 220
local simulationCurrent = 28

local version = "0.3e"
local numVersion = 6
local defaultSettings = {
	version = version,
	dbVersion = numVersion,
	enabled = true,
	
	inconclusiveDataThreshold = 100, -- Mobs killed within this span of time (in milliseconds) will not be processed since we might not get the criteria update fast enough to know which mob gave what progress. Well, that's the theory anyway.
	maxTimeSinceKill = 600, -- Lag tolerance between a mob dying and the progress criteria updating, in milliseconds.
	
	enableTooltip = true,
	tooltipColor = "82E0FF", -- Color of the tooltip. Duh.
	
	enablePullEstimate = true,
	pullEstimateCombatOnly = true,
	
	nameplateUpdateRate = 200, -- Rate (in milliseconds) at which we update the progress we get from the current pull, as estimated by active name plates you're in combat with. Also the update rate of getting new values for nameplate text overlay if enabled.
	
	enableNameplateText = true,
	nameplateTextColor = "FFFFFF",
}

local warnings = {}

mppDefaultValues = {{100216,4,"Hatecoil Wrangler"},{97182,6,"Night Watch Mariner"},{92168,8,"Target Dummy Test2"},{114716,1,"Boulangère fantôme"},{122413,4,"Traque-faille ombre-garde"},{91785,2,"Wandering Shellback"},{96480,1,"Viletongue Belcher"},{97087,2,"Valarjar Champion"},{96608,2,"Ebonclaw Worg"},{96640,2,"Valarjar Marksman"},{121711,4,"Flagellant vénéneux"},{95842,2,"Valarjar Thundercaller"},{91786,4,"Gritslime Snail"},{119923,4,"Soigneuse érédar"},{114334,4,"Golem endommagé"},{115388,5,"Roi"},{115484,4,"Gangroptère"},{114526,1,"Doublure fantomatique"},{100250,4,"Lieuse Ashioi"},{98813,4,"Bloodscent Felhound"},{95779,10,"Festerhide Grizzly"},{98366,4,"Ghostly Retainer"},{95843,4,"Roi Haldor"},{91787,1,"Mouette de la crique"},{98973,1,"Skeletal Warrior"},{95939,10,"Skrog Tidestomper"},{121553,4,"Chasseur de l'effroi"},{113537,10,"Unknown"},{114783,4,"Damoiselle repentie"},{105617,4,"Eredar Chaosbringer"},{95940,1,"Pillard mer-amère"},{102104,4,"Enslaved Shieldmaiden"},{115486,8,"Tueuse érudite"},{102232,4,"Rockbound Trapper"},{114624,8,"Gardien arcanique"},{99358,4,"Rotheart Dryad"},{98368,4,"Ghostly Protector"},{120405,4,"Aile de l'effroi"},{102584,4,"Malignant Defiler"},{105682,8,"Felguard Destroyer"},{104277,4,"Legion Hound"},{98177,12,"Glayvianna Soulrender"},{118713,4,"Lance-orbe gangrerôdeur"},{122322,4,"Roué affamé"},{99359,3,"Rotheart Keeper"},{113699,8,"Forgotten Spirit"},{120374,4,"Destructeur gangregarde"},{91790,4,"Mak'rana Siltwalker"},{114338,10,"Confluence de mana"},{105715,4,"Watchful Inquisitor"},{115488,4,"Pyromancien imprégné"},{104278,10,"Felbound Enforcer"},{118714,4,"Tentatrice feu-d'enfer"},{99360,9,"Vilethorn Blossom"},{98370,4,"Ghostly Councilor"},{104247,4,"Arcaniste de la Garde crépusculaire"},{105876,1,"Enchanted Broodling"},{98243,4,"Soul-Torn Champion"},{114627,4,"Terreur hurleuse"},{91792,10,"Stormwake Hydra"},{96934,2,"Valarjar Trapper"},{99649,12,"Dreadlord Mendacius"},{98691,4,"Risen Scout"},{118716,4,"Flagellant vénéneux"},{101438,4,"Vileshard Chunk"},{122421,8,"Adepte de la guerre ombreux"},{91793,1,"Seaspray Crab"},{119930,4,"Aile de l'effroi"},{96584,4,"Immoliant Fury"},{98756,4,"Arcane Anomaly"},{111563,4,"Duskwatch Guard"},{91794,1,"Saltscale Lurker"},{98533,10,"Foul Mother"},{102781,4,"Jeune gangroptère"},{102430,1,"Tarspitter Slug"},{98406,4,"Scorpion éclat-ardent"},{95947,4,"Mak'rana Hardshell"},{105720,4,"Understone Drudge"},{104251,4,"Duskwatch Sentry"},{90997,4,"Mightstone Breaker"},{118719,4,"Pillard langue-de-wyrm"},{99365,4,"Taintheart Stalker"},{124947,1,"Ecorcheur du Vide"},{100451,3,"Target Dummy Test"},{91796,10,"Skrog Wavecrasher"},{96587,4,"Felsworn Infester"},{90998,4,"Blightshard Shaper"},{98759,4,"Vicious Manafang"},{114632,4,"Domestique spectral"},{99366,4,"Taintheart Summoner"},{98919,4,"Seacursed Swiftblade"},{114792,4,"Dame vertueuse"},{116549,4,"Choriste"},{98728,7,"Bile acide"},{98792,4,"Wyrmtongue Scavenger"},{97068,5,"Drake-tempête"},{91000,8,"Vileshard Hulk"},{105915,4,"Nightborne Reclaimer"},{114634,4,"Serviteur immortel"},{114794,4,"Molosse squelettique"},{98538,10,"Dame Velandras Corvaltus"},{91001,4,"Tarspitter Lurker"},{97197,2,"Valarjar Purifier"},{118723,10,"Scrutax"},{114252,4,"Dévoreur de mana"},{98954,4,"Felsworn Myrmidon"},{95920,2,"Animated Storm"},{97677,1,"Barbed Spiderling"},{114636,4,"Garde fantôme"},{102404,4,"Stoneclaw Grubmaster"},{101414,2,"Saltscale Skulker"},{114796,4,"Hôtesse saine"},{113966,40,"Test NPC"},{113998,4,"Mightstone Breaker"},{102788,4,"Felspite Dominator"},{98732,1,"Plagued Rat"},{99307,12,"Skjal"},{114542,4,"Philanthrope fantomatique"},{97200,4,"Seacursed Soulkeeper"},{101991,4,"Nightmare Dweller"},{102566,12,"Grimhorn the Enslaver"},{121569,4,"Marcheur vilécorce"},{102375,3,"Runecarver Slave"},{115757,8,"Porte-flamme garde-courroux"},{98926,4,"Shadow Hunter"},{99629,1,"Pillard mer-amère"},{91006,4,"Rockback Gnasher"},{114544,4,"Ouvreur squelettique"},{105921,4,"Nightborne Spellsword"},{100364,4,"Spirit of Vengeance"},{122401,8,"Entourloupeur ombre-garde"},{95861,4,"Hatecoil Oracle"},{97043,4,"Seacursed Slaver"},{99630,1,"Pillard mer-amère"},{97171,10,"Hatecoil Arcanist"},{95766,4,"Crazed Razorbeak"},{114801,4,"Apprenti spectral"},{105699,3,"Mana Saber"},{120550,4,"Garde-courroux envahisseur"},{106785,1,"Bitterbrine Slave"},{91008,4,"Rockbound Pelter"},{97172,1,"Saltsea Droplet"},{122403,4,"Champion ombre-garde"},{114802,4,"Compagnon spectral"},{92350,4,"Understone Drudge"},{106786,1,"Bitterbrine Slave"},{104295,1,"Blazing Imp"},{98706,6,"Commander Shemdah'sohn"},{98770,4,"Wrathguard Felblade"},{96247,1,"Vileshard Crawler"},{95832,2,"Valarjar Shieldmaiden"},{114803,4,"Palefrenière spectrale"},{100527,3,"Dreadfire Imp"},{119977,4,"Flagellant constricteur"},{106787,1,"Bitterbrine Slave"},{118700,2,"Traqueur sylvechancre"},{95769,4,"Mindshattered Screecher"},{122405,4,"Adjuratrice ombre-garde"},{98963,1,"Blazing Imp"},{119978,1,"Flagellant fulminant"},{102253,4,"Understone Demolisher"},{96664,2,"Valarjar Runecarver"},{98900,4,"Wyrmtongue Trickster"},{100529,1,"Hatespawn Slime"},{102094,4,"Risen Swordsman"},{105703,1,"Mana Wyrm"},{101679,4,"Dreadsoul Poisoner"},{99188,4,"Waterlogged Soul Guard"},{102583,4,"Brûleur gangrené"},{101839,4,"Risen Companion"},{2,35,"Test NPC"},{95771,4,"Dreadsoul Ruiner"},{105629,1,"Wyrmtongue Scavenger"},{122407,4,"Traqueur dimensionnel"},{101549,1,"Arcane Minion"},{118717,4,"Diablotin feu-d'enfer"},{91332,4,"Stoneclaw Hunter"},{102095,4,"Lancier ressuscité"},{114629,4,"Factotum spectral"},{114804,4,"Destrier spectral"},{97081,5,"Roi Bjorn"},{114541,1,"Cliente spectrale"},{114628,4,"Serveur squelettique"},{102287,10,"Unknown"},{92610,4,"Batteur pierre-basse"},{118703,4,"Botaniste gangrenuit"},{122423,8,"Grand tisseur d'ombre"},{95772,4,"Frenzied Nightclaw"},{115765,4,"Annulateur abstrait"},{122408,4,"Traqueur des ombres"},{118724,4,"Gangréneur feu-d'enfer"},{100539,4,"Mornœil cœur-corrompu"},{100531,8,"Bloodtainted Fury"},{98173,4,"Mystique Ssa’veh"},{105705,4,"Bound Energy"},{120556,4,"Aile de l'effroi"},{111901,3,"Unknown"},{100248,4,"Ritualiste Lesha"},{104300,4,"Shadow Mistress"},{98275,4,"Risen Archer"},{114584,1,"Machiniste fantôme"},{118704,10,"Dul'zak"},{97097,4,"Helarjar Champion"},{105845,4,"Glowing Spiderling"},{115417,8,"Rat"},{97678,8,"Aranasi Broodmother"},{91781,4,"Hatecoil Warrior"},{98733,4,"Withered Fiend"},{122404,4,"Arqueur du Vide ombre-garde"},{91783,4,"Hatecoil Stormweaver"},{105706,10,"Prêtresse de misère"},{105651,10,"Dreadborne Seer"},{97083,5,"Roi Ranulf"},{114626,4,"Esprit lugubre"},{118690,4,"Garde-courroux envahisseur"},{98677,1,"Rook Spiderling"},{125860,8,"Gardien de la faille"},{118705,10,"Nal'asha"},{97365,4,"Seacursed Mistmender"},{114625,1,"Invité fantôme"},{98425,4,"Unstable Amalgamation"},{120366,4,"Tentatrice feu-d'enfer"},{91782,10,"Hatecoil Crusher"},{115831,4,"Dévoreur de mana"},{100526,4,"Tormented Bloodseeker"},{98521,10,"Lord Etheldrin Ravencrest"},{105636,4,"Understone Drudge"},{124171,4,"Subjugateur ombre-garde"},{97084,5,"Roi Tor"},{104270,8,"Guardian Construct"},{98681,6,"Rook Spinner"},{122410,1,"Ciaileron"},{97173,4,"Restless Tides"},{118706,2,"Jeune araignée nécrotique"},{95834,2,"Valarjar Mystic"},{96657,12,"Danse-lames Illianna"},{114714,4,"Régisseuse fantomatique"},{106059,4,"Warp Shade"},{98426,4,"Limon instable"},{106546,4,"Etincelle astrale"},{119952,4,"Destructeur gangregarde"},{99033,4,"Helarjar Mistcaller"},{122571,8,"Gardien de la faille"},{102351,1,"Mana Wyrm"},{96574,5,"Stormforged Sentinel"},{100441,1,"Unknown"},{116550,4,"Client spectral"},{100249,4,"Canaliste Varisz"},{104246,4,"Duskwatch Guard"},{114633,4,"Servante spectrale"},{98810,6,"Wrathguard Bladelord"},{114637,4,"Factionnaire spectral"},{114715,4,"Cuistot fantomatique"},{105952,6,"Withered Manawraith"},{122478,2,"Décharge du Vide"},{97185,10,"The Grimewalker"},{96611,2,"Taureau sabot-furieux"},{114364,1,"Wyrm gavé de mana"},{115418,8,"Araignée"},{98280,4,"Risen Arcanist"},{97119,1,"Shroud Hound"},}

local dbFixes = {}
dbFixes[4] = {{1, 40, "Test NPC"}, {99307, 12, "Skjal"}}
dbFixes[5] = {{2, 35, "Test NPC"}, {95947, 4, "Mak'rana Hardshell"}}

-- New to lua, don't judge too hard pls.

function mppGetLastKill()
	return lastKill
end

--
-- GENERAL ADDON UTILITY
-- And by "utility" I mostly mean creating a bunch of shit that should really be built-in.

local function debugLog(s)
	if mppDebug then
		print(s)
	end
end

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

local function hasWarned(message)
	for _,warning in pairs(warnings) do
		if warning == message then
			return true
		end
	end
	return false
end

local function warning(message)
	if not hasWarned(message) then
		print(message)
		table.insert(warnings, message)
		return true
	end
	return false
end

local function getSetting(setting)
	if (not setting or JokUIDB[setting] == nil) then
		warning("MPP attempted to get missing setting: " .. setting or "nil")
		return
	end
	return JokUIDB[setting]
end

function mppGetSetting(setting)
	return getSetting(setting)
end

local function setSetting(setting, value)
	if (not setting or JokUIDB[setting] == nil) then
		warning("MPP attempted to set missing setting: " .. setting or "nil")
		return
	end
	JokUIDB[setting] = value
	return value
end

local function toggleSetting(setting)
	return setSetting(setting, not getSetting(setting))
end

--
-- WOW GENERAL WRAPPERS/EZUTILITIES
--

local function getNPCID(guid)
	local targetType, _,_,_,_, npcID = strsplit("-", guid)
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
--	debugLog("getEnemyForcesProgress called.")
	-- Returns exact float value of current enemies killed progress (1-100).
	local quantity, maxQuantity = getCurrentQuantity(), getMaxQuantity()
	local progress = quantity / maxQuantity
	return progress * 100
end

--
-- DB READ/WRITES
--

local function getValue(npcID)
	debugLog("getValue called. Args: " .. npcID)
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
	--debugLog("updateValue called. Args: " .. npcID or "nil" .. ", " .. value or "nil" .. ", " .. npcName or "nil" .. ", " .. forceQuantity or "nil")
	if value <= 0 then
		debugLog("Discarding update for " .. toString(npcName) .. "(" .. npcID .. ") due to value being " .. tovalue)
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
	local a = string.format("Export ver %s (%s) - %i mobs: {", getSetting("version"), getSetting("dbVersion"), tlen(JokUIDB["npcData"]))
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
	debugLog("getEstimatedProgress called. Args: " .. npcID)
	local npcValue, maxQuantity = getValue(npcID), getMaxQuantity()
	if npcValue and maxQuantity then
		return (npcValue / maxQuantity) * 100
	end
end

--
-- TRIGGERS/HOOKS
--

-- Called when our enemy forces criteria increases, no matter how small the increase (but >0).
local function onProgressUpdated(deltaProgress)
	debugLog("onProgressUpdated called. Args: " .. deltaProgress)
	if currentQuantity == getMaxQuantity() then
		return -- Disregard data that caps us as we don't know if we got the full value.
	end
	local timestamp, npcID, npcName, isDataUseful = unpack(lastKill) -- See what the last mob we killed was
	if timestamp and npcID and deltaProgress and isDataUseful then -- Assert that we have some useful data to work with
		local timeSinceKill = GetTime() - timestamp
		debugLog("timeSinceKill: " .. timestamp .. " Current Time: " .. GetTime() .. "Timestamp of kill: " .. timeSinceKill)
		if timeSinceKill <= getSetting("maxTimeSinceKill") then
			debugLog(string.format("Gained %f%s. Last mob killed was %s (%i) %fs ago", deltaProgress, "%", npcName, npcID, timeSinceKill/1000))
			updateValue(npcID, deltaProgress, npcName) -- Looks like we have ourselves a valid entry. Set this in our database/list/whatever.
		else
			debugLog(string.format("Gained %f%s. Last mob killed was %s (%i) %fs ago (PAST CUTOFF!)", deltaProgress, "%", npcName, npcID, timeSinceKill))
		end
	end
end

-- Called directly by our hook
local function onCriteriaUpdate()
	debugLog("onCriteriaUpdate called")
	if not currentQuantity then
		currentQuantity = 0
	end
	if not isMythicPlus() or not loaded or not getSetting("enabled") then return end
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
		if mppDebug then
			--foreach(args, print)
		end
		local npcID = getNPCID(destGUID)
		if npcID then
			local isDataUseful = true
			local timeSinceLastKill = GetTime() - lastKill[1]
			if timeSinceLastKill <= getSetting("inconclusiveDataThreshold") then
				debugLog("Data not useful: " .. timeSinceLastKill .. " - " .. lastKill[1] .. " - " .. GetTime())
				isDataUseful = false
			end
			lastKill = {GetTime(), npcID, destName, isDataUseful} -- timestamp is not at all accurate, we use GetTime() instead.
			if mppDebug then
				foreach(lastKill, print)
			end
		end
	end
end

local function verifySettings(forceWipe)
	for setting, value in pairs(defaultSettings) do
		if JokUIDB[setting] == nil or forceWipe then
			JokUIDB[setting] = value
		end
	end
	-- At last, update version string
	
	setSetting("version", version)
end

local function upgradeDB()
	local oldVer = JokUIDB["dbVersion"]
	for ver, fixes in pairs(dbFixes) do
		if ver > oldVer then
			for _,fixTable in pairs(fixes) do
				local npcID, value, name = unpack(fixTable)
				deleteEntry(npcID)
				updateValue(npcID, value, name)
			end
		end
	end
	setSetting("dbVersion", numVersion)
end
				

local function verifyDB(forceWipe)
	if not JokUIDB["npcData"] then
		JokUIDB["npcData"] = {}
	end
	verifySettings()
	if mppDefaultValues ~= nil then
		for k,v in pairs(mppDefaultValues) do
			local npcID, value, name = unpack(v)
			if getValue(npcID) == nil then
				updateValue(npcID, value, name, 1)
			end
		end
	end
	
	-- DB Fixes per version
	upgradeDB()
end

-- Called directly by our hook
local function onAddonLoad(addonName)
	if addonName == "JokUI" then
		verifyDB()
		if isMythicPlus() then
			quantity = getEnemyForcesProgress()
			debugLog("MPP Loaded in progress: " .. quantity .. "in.")
		else
			quantity = 0
			debugLog("MPP loaded not in progress.")
		end
		loaded = true
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
	if loaded and getSetting("enabled") and getSetting("enableTooltip") and isMythicPlus() and isValidTarget(unit) then
		return true
	end
	return false
end

local function getTooltipMessage(npcID)
	local tempMessage = "|cFF"..getSetting("tooltipColor").."Progress : "
	local estProg = getEstimatedProgress(npcID)
	if not estProg then
		return tempMessage .. "No record."
	end
	mobsLeft = (100 - getEnemyForcesProgress()) / estProg
	tempMessage = string.format("%s%.2f%s (%i left)", tempMessage, estProg, "%", math.ceil(mobsLeft))
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
currentPullFrame:SetPoint("CENTER", UIParent, 400, 300)
currentPullFrame:SetMovable(false)
currentPullFrame:RegisterForDrag("LeftButton")
currentPullFrame:SetScript("OnDragStart", currentPullFrame.StartMoving)
currentPullFrame:SetScript("OnDragStop", currentPullFrame.StopMovingOrSizing)
currentPullFrame:SetWidth(50)
currentPullFrame:SetHeight(50)
currentPullFrame:SetScale(1)
--currentPullFrame:SetAllPoints()
--currentPullFrame:SetClampRectInsets(200, 400, 200, 500)
currentPullText = currentPullFrame:CreateFontString("currentPullString", "BACKGROUND", "GameFontHighlightLarge")
currentPullText:SetPoint("CENTER");
currentPullText:SetText("MPP String Uninitialized.")

---
--- NAMEPLATES
---

local function isTargetPulled(target)
	-- debugLog("isTargetPulled with args: " ..target)
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
	if getSetting("enabled") and getSetting("enablePullEstimate") and isMythicPlus() and not isDungeonFinished() then
		if getSetting("pullEstimateCombatOnly") and not UnitAffectingCombat("player") then
			return false
		end
		return true
	end
	return false
end

local function setCurrentPullEstimateLabel(s)
	currentPullString:SetText(s)
	currentPullFrame:SetWidth(currentPullString:GetStringWidth())
	currentPullFrame:SetHeight(currentPullString:GetStringHeight())
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
	-- debugLog(tlen(pulledUnits) .. "/" .. tlen(activeNameplates).." active nameplates for an estimated " .. estProg .. "%")
	local curProg = getEnemyForcesProgress()
	local totProg = estProg + curProg
	if estProg == 0 then
		tempMessage = "No recorded mobs pulled or nameplates inactive."
	else
		tempMessage = string.format("Current pull: %.2f%s + %.2f%s = %.2f%s", curProg, "%", estProg, "%", (math.floor(totProg*100)/100), "%")
	end
	setCurrentPullEstimateLabel(tempMessage)
end

local function createNameplateText(token)
	local npcID = getNPCID(UnitGUID(token))
	if npcID then
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
		if estProg and estProg > 0 then
			local tempMessage = "|cFF"..getSetting("nameplateTextColor").."+"
			tempMessage = string.format("%s%.2f%s", tempMessage, estProg, "%")
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
		activeNameplates[token]:SetPoint("LEFT", nameplate.UnitFrame.healthBar, "RIGHT", 2, 0)
		activeNameplates[token]:SetFont("Fonts\\FRIZQT__.TTF", 9)
	else
		removeNameplateText(token)
		debugLog("Token " .. token or "nil" .. "does not seem to exist. Why are we trying to update it?")
	end
end

local function shouldShowNameplateTexts()
	if getSetting("enabled") and getSetting("enableNameplateText") and isMythicPlus() and not isDungeonFinished() then
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

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

function frame:OnEvent(event, ...)
	args={...}
	if event == "ADDON_LOADED" then
		onAddonLoad(args[1])
	elseif event == "SCENARIO_CRITERIA_UPDATE" then
		onCriteriaUpdate()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		onCombatLogEvent(args)
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		onAddNameplate(...)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		onRemoveNameplate(...)
	else
		if warning("JokUI unhandled event: " .. event) then
			for k,v in ipairs(args) do
				print(k,v)
			end
		end
	end
end

function frame:OnUpdate(elapsed)
	currentPullUpdateTimer = currentPullUpdateTimer + elapsed * 1000 -- Not using milliseconds in 2016? WutFace
	if currentPullUpdateTimer >= getSetting("nameplateUpdateRate") then
		currentPullUpdateTimer = 0
		updateCurrentPullEstimate()
		updateNameplateValues()
	end
	updateNameplates()
end

frame:SetScript("OnEvent", frame.OnEvent)
frame:SetScript("OnUpdate", frame.OnUpdate)
GameTooltip:HookScript("OnTooltipSetUnit", onNPCTooltip)