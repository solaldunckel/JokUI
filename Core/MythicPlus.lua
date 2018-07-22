local _, JokUI = ...
local MythicPlus = JokUI:RegisterModule("Mythic +")

-------------------------------------------------------------------------------
-- Locals
-------------------------------------------------------------------------------

local features = {}

--[[ 
	1: Overflowing, 
	2: Skittish, 
	3: Volcanic, 
	4: Necrotic, 
	5: Teeming, 
	6: Raging, 
	7: Bolstering,
	8: Sanguine, 
	9: Tyrannical, 
	10: Fortified, 
	11: Bursting, 
	12: Grievous, 
	13: Explosive, 
	14: Quaking, 
	15 : ??,
	16 : Infested 
--]]

local affixSchedule = {
	{ 10, 8, 4, 16 }, -- Fortified / Sanguine / Necrotic / Infested
	{ 9, 11, 2, 16 }, -- Tyrannical / Bursting / Skittish / Infested
	{ 10, 5, 14, 16 }, -- Fortified / Teeming / Quaking / Infested
	{ 9, 6, 4, 16 }, -- Tyrannical / Raging / Necrotic / Infested
	{ 10, 7, 2, 16 }, -- Fortified / Bolstering / Skittish / Infested
	{ 9, 5, 3, 16 }, -- Tyrannical / Teeming / Volcanic / Infested
	{ 10, 8, 12, 16 }, -- Fortified / Sanguine / Grievous / Infested
	{ 9, 7, 13, 16 }, -- Tyrannical / Bolstering / Explosive / Infested
	{ 10, 11, 14, 16 }, -- Fortified / Bursting / Quaking / Infested
	{ 9, 6, 3, 16 }, -- Tyrannical / Raging / Volcanic / Infested
	{ 10, 5, 13, 16 }, -- Fortified / Teeming / Explosive / Infested
	{ 9, 7, 12, 16 }, -- Tyrannical / Bolstering / Grievous / Infested
}

local schedule = {
	Week1 = "Next Week",
	Week2 = "In Two Weeks",
}

-- Default npc's progress values
local MythicProgressValues = {{131812,4,"Heartsbane Soulcharmer"},{135474,4,"Thistle Acolyte"},{134600,4,"Sandswept Marksman"},{135049,2,"Dreadwing Raven"},{134616,2,"Krolusk Pup"},{131585,4,"Enthralled Guard"},{137830,4,"Pallid Gorger"},{135846,2,"Sand-Crusted Striker"},{134602,4,"Shrouded Fang"},{131586,4,"Banquet Steward"},{133870,4,"Diseased Lasher"},{139422,6,"Scaled Krolusk Tamer"},{131492,4,"Devout Blood Priest"},{135240,2,"Soul Essence"},{134364,4,"Faithless Tender"},{131666,4,"Coven Thornshaper"},{135052,1,"Blight Toad"},{131847,4,"Waycrest Reveler"},{136076,6,"Agitated Nimbus"},{134617,1,"Krolusk Hatchling"},{135562,2,"Venomous Ophidian"},{131587,5,"Bewitched Captain"},{138187,4,"Grotesque Horror"},{135234,2,"Diseased Mastiff"},{134990,4,"Charged Dust Devil"},{134599,4,"Imbued Stormcaller"},{141495,1,"Kul Tiran Footman"},{135329,6,"Matron Bryndle"},{131819,4,"Coven Diviner"},{130909,4,"Fetid Maggot"},{139110,9,"Spark Channeler"},{133912,6,"Bloodsworn Defiler"},{134991,6,"Sandfury Stonefist"},{131849,1,"Crazed Marksman"},{134629,6,"Scaled Krolusk Rider"},{139425,4,"Crazed Incubator"},{135365,6,"Matron Alma"},{131818,4,"Marked Sister"},{131858,4,"Thornguard"},{131669,1,"Jagged Hound"},{134024,1,"Devouring Maggot"},{131850,4,"Maddened Survivalist"},{133685,4,"Befouled Spirit"},{131677,4,"Heartsbane Runeweaver"},{131685,4,"Runic Disciple"},{133835,4,"Feral Bloodswarmer"},{134284,4,"Fallen Deathspeaker"},{131436,6,"Chosen Blood Matron"},{133663,4,"Fanatical Headhunter"},{133836,4,"Reanimated Guardian"},{138281,6,"Faceless Corruptor"},{133852,4,"Living Rot"},{134041,4,"Infected Peasant"},}

-------------------------------------------------------------------------------
-- Config
-------------------------------------------------------------------------------

local mythicplus_defaults = {
    profile = {
    	enableProgress = true,
		enableNameplateText = true,
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
			exportProgress = {
				type = "execute",
				name = "Export Progress",
				desc = "",
				order = 4,
				func = function(info,val) exportData() 
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

	self:Timer()
	--self:Schedule()

	self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	self:RegisterEvent("CHALLENGE_MODE_START")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ADDON_LOADED")

end

function MythicPlus:Blizzard_TalkingHeadUI()
	hooksecurefunc("TalkingHeadFrame_PlayCurrent", PlayCurrent)
end

function MythicPlus:ADDON_LOADED(event, addon)
	if addon == "Blizzard_TalkingHeadUI" then
		self:SyncFeature("MythicTalkingHead")
	end
	-- if addon == "Blizzard_ChallengesUI" then
	-- 	self:Blizzard_ChallengesUI()
	-- end
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

	local TIME_FOR_3 = 0.6
	local TIME_FOR_2 = 0.8

	local challengeMapID

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

	local function ProgressBar_SetValue(self, percent)
		if self.criteriaIndex then
			local _, _, _, _, totalQuantity, _, _, quantityString, _, _, _, _, _ = C_Scenario.GetCriteriaInfo(self.criteriaIndex)
			local currentQuantity = quantityString and tonumber( strsub(quantityString, 1, -2) )
			if currentQuantity and totalQuantity then
				self.Bar.Label:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
				self.Bar.Label:SetFormattedText("%.2f%% - %d/%d", currentQuantity/totalQuantity*100, currentQuantity, totalQuantity)
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

	function MythicPlus:PLAYER_ENTERING_WORLD()
		challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()			
	end

	function MythicPlus:CHALLENGE_MODE_START()
		challengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
	end

	function MythicPlus:CHALLENGE_MODE_COMPLETED()
		if not challengeMapID then return end

		local mapID, level, time, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()
		local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(challengeMapID)

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
	end

	local function SkinProgressBars(self, _, line)
		local progressBar = line and line.ProgressBar
		local bar = progressBar and progressBar.Bar
		if not bar then return end
		local icon = bar.Icon

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

			bar:SetWidth(210)
			bar:SetHeight(20)
			bar:SetStatusBarTexture("Interface\\Addons\\JokUI\\media\\mythicplus\\normTex2")
			
			ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)

			progressBar.isSkinned = true
		elseif icon and progressBar.backdrop then
			progressBar.backdrop:SetShown(icon:IsShown())
		end
	end
	hooksecurefunc(SCENARIO_TRACKER_MODULE,"AddProgressBar",SkinProgressBars)
end

function MythicPlus:Schedule()

	local rowCount = 2
	local currentWeek
	local ownedKeystone

	local function UpdateAffixes()
		self:CheckCurrentAffixes()
		if currentWeek then
			for i = 1, rowCount do
				local entry = MythicPlus.Frame.Entries[i]
				entry:Show()

				local scheduleWeek = (currentWeek - 1 + i) % (#affixSchedule) + 1
				local affixes = affixSchedule[scheduleWeek]
				for j = 1, #affixes do
					local affix = entry.Affixes[j]
					affix:SetUp(affixes[j])
				end
			end
		else
			for i = 1, rowCount do
				MythicPlus.Frame.Entries[i]:Hide()
			end
		end
	end

	local function makeAffix(parent)
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetSize(36, 36)

		local border = frame:CreateTexture(nil, "OVERLAY")
		border:SetAllPoints()
		border:SetAtlas("ChallengeMode-AffixRing-Lg")
		frame.Border = border

		local portrait = frame:CreateTexture(nil, "ARTWORK")
		portrait:SetSize(34, 34)
		portrait:SetPoint("CENTER", border)
		frame.Portrait = portrait

		frame.SetUp = ScenarioChallengeModeAffixMixin.SetUp
		frame:SetScript("OnEnter", ScenarioChallengeModeAffixMixin.OnEnter)
		frame:SetScript("OnLeave", GameTooltip_Hide)

		return frame
	end

	function MythicPlus:Blizzard_ChallengesUI()
		local keyLevel = C_MythicPlus.GetOwnedKeystoneLevel()
		local keyMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()

		if C_MythicPlus.IsWeeklyRewardAvailable() then return end

		if keyLevel then
			ownedKeystone = true
		else
			ownedKeystone = false
		end

		if ownedKeystone then
			local MythicFrame = ChallengesFrame.WeeklyInfo.Child

			MythicFrame.Label:SetPoint("TOPLEFT", MythicFrame, "TOPLEFT", 90, -55)

			MythicFrame.RunStatus:Hide()
			MythicFrame.WeeklyChest:SetPoint("TOPRIGHT", ChallengesFrame.WeeklyInfo.Child, "TOPRIGHT", -54,  -30)
			MythicFrame.WeeklyChest:SetScale(0.9)

			local frame = CreateFrame("Frame", nil, ChallengesFrame)
			frame:SetSize(200, 110)
			frame:SetPoint("CENTER", MythicFrame, "CENTER", 0, 20)
			MythicPlus.Frame = frame

			local entries = {}
			for i = 1, rowCount do
				local entry = CreateFrame("Frame", nil, frame)
				entry:SetSize(160, 56)

				local text = entry:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				text:SetWidth(150)
				text:SetJustifyH("TOP")
				text:SetWordWrap(false)
				text:SetText( schedule["Week"..i] )
				text:SetFont("Fonts\\FRIZQT__.TTF", 15)
				text:SetTextColor(1,1,1)
				text:SetPoint("TOP", 0, 2)
				entry.Text = text

				local affixes = {}
				local prevAffix
				for j = 4, 1, -1 do
					local affix = makeAffix(entry)
					if prevAffix then
						affix:SetPoint("RIGHT", prevAffix, "LEFT", -8, 0)
					else
						affix:SetPoint("BOTTOMRIGHT", entry, "BOTTOMRIGHT")
					end
					prevAffix = affix
					affixes[j] = affix
				end
				entry.Affixes = affixes

				if i == 1 then
					entry:SetPoint("TOP", ChallengesFrame.WeeklyInfo.Child.Label, "BOTTOM", 0, -85)
				else
					entry:SetPoint("TOP", entries[i-1], "BOTTOM", 0, -22)
				end

				entries[i] = entry
			end
			frame.Entries = entries

			hooksecurefunc("ChallengesFrame_Update", UpdateAffixes)
		end
	end

	function MythicPlus:CheckCurrentAffixes()

		currentWeek = nil
		affix = nil
		
		C_MythicPlus.RequestCurrentAffixes()
		local weeklyAffixes = C_MythicPlus.GetCurrentAffixes()

		for index, affixes in ipairs(affixSchedule) do
			if weeklyAffixes[1] == affixes[1] and weeklyAffixes[2] == affixes[2] and weeklyAffixes[3] == affixes[3] then
				currentWeek = index
			end
		end		
	end
end

function MythicPlus:Progress()

	local _GetTime = GetTime

	local quantity = 0
	local lastKill = {0} -- To be populated later, do not remove the initial value. The zero means inconclusive/invalid data.
	local activeNameplates = {}

	--
	-- GENERAL FUNCTION
	-- 

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
	-- MYTHIC+ FUNCTION
	--

	local function getNPCID(guid)
		local targetType, _,_,_,_, npcID = strsplit("-", guid or "")
		if targetType == "Creature" or targetType == "Vehicle" and npcID then
			return tonumber(npcID)
		end
	end

	local function isDungeonFinished()
		local steps = select(3, C_Scenario.GetStepInfo())
		return (steps and steps < 1)
	end

	-- Will also return true in challenge modes if those are ever re-implemented as M+ is basically recycled Challenge Mode.
	local function isMythicPlus()
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
            	else
                	info = {"Enemy Forces", "0", "false", "0", "100", "0", "0", "0%", "0", "0", "0", "false", "true"}
                	return info
            	end
			end
		end
	end
		
	local function getMaxQuantity()
		local progInfo = getProgressInfo()
		if progInfo then
			return getProgressInfo()[5] -- Max quantity (raw)
		end
	end

	local function getCurrentQuantity()
		local progInfo = strtrim(getProgressInfo()[8], "%")
		return progInfo
	end

	local function getEnemyForcesProgress()
		-- Returns exact float value of current enemies killed progress (1-100).
		local progInfo = getProgressInfo()
		if progInfo then
			local currentQuantity, maxQuantity = getCurrentQuantity(), getMaxQuantity()
			local progress = currentQuantity / maxQuantity
			return progress * 100
		end
	end

	--
	-- DB
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

	local function verifyDB(forceWipe)
		if not JokUIDB["npcData"] then
			JokUIDB["npcData"] = {}
		end
		if MythicProgressValues ~= nil then
			for k,v in pairs(MythicProgressValues) do
				local npcID, value, name = unpack(v)
				if getValue(npcID) == nil then
					updateValue(npcID, value, name, 1)
				end
			end
		end
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
		f:SetSize(400, 50)
		f:SetMultiLine()
		f:SetPoint("CENTER", 0, 350)
		f:SetFrameStrata("TOOLTIP")
		f:SetScript("OnEnterPressed", f.Hide)
		f:SetScript("OnEscapePressed", f.Hide)
		f:SetText(a)
	end

	local function getEstimatedProgress(npcID)
		local npcValue, maxQuantity = getValue(npcID), getMaxQuantity()
		if npcValue and maxQuantity then
			return (npcValue / maxQuantity) * 100
		end
	end

	local function getExactProgress(npcID)
		local npcValue, maxQuantity = getValue(npcID), getMaxQuantity()
		if npcValue and maxQuantity then
			return npcValue
		end
	end

	---
	--- TOOLTIPS
	---

	local function getTooltipMessage(npcID)
		local tempMessage = "|cFF82E0FFProgress : "
		local estProg = getEstimatedProgress(npcID)
		local rawProg = getExactProgress(npcID)
		if not estProg then
			return tempMessage .. "No record."
		end
		tempMessage = string.format("%s%s / %.2f%s", tempMessage, rawProg, estProg, "%")
		return tempMessage
	end
		
	local function onNPCTooltip(self)
		local unit = select(2, self:GetUnit())
		if unit then
			local time = GetTime()
			if not last or last < time - 0.3 then
    			last = time
				local guid = UnitGUID(unit)
				npcID = getNPCID(guid)
				if npcID and isMythicPlus() and UnitCanAttack("player", unit) and not UnitIsDead(unit) then
					local tooltipMessage = getTooltipMessage(npcID)
					if tooltipMessage then
						GameTooltip:AddDoubleLine(tooltipMessage)
	    				GameTooltip:Show()
					end
				end
			end
		end
	end

	---
	--- NAMEPLATES
	---

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
			local rawProg = getExactProgress(npcID)
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

	local function updateNameplatePosition(token)
		local nameplate = C_NamePlate.GetNamePlateForUnit(token)
		if nameplate.UnitFrame.unitExists and activeNameplates[token] ~= nil then
			activeNameplates[token]:SetPoint("LEFT", nameplate.UnitFrame.name, "RIGHT", 3, -1)
			activeNameplates[token]:SetFont("Fonts\\FRIZQT__.TTF", 8)
		else
			removeNameplateText(token)
		end
	end

	local function onAddNameplate(token)
		if MythicPlus.settings.enableNameplateText and isMythicPlus() and not isDungeonFinished() then
			createNameplateText(token)
			updateNameplateValue(token)
			updateNameplatePosition(token)
		end
	end

	local function onRemoveNameplate(token)
		removeNameplateText(token)
		activeNameplates[token] = nil -- This line has been made superflous tbh.
	end

	---
	--- HOOKS
	---

	local function onProgressUpdated(deltaProgress)
		if currentQuantity == getMaxQuantity() then
			return -- Disregard data that caps us as we don't know if we got the full value.
		end
		local timestamp, npcID, npcName, isDataUseful = unpack(lastKill) -- See what the last mob we killed was
		if timestamp and npcID and deltaProgress and isDataUseful then -- Assert that we have some useful data to work with
			local timeSinceKill = GetTime() - timestamp
			if timeSinceKill <= 400 then
				updateValue(npcID, deltaProgress, npcName) -- Looks like we have ourselves a valid entry. Set this in our database/list/whatever.
			end
		end
	end	

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

	local function onCombatLogEvent()
		--local _,combatType,_,_,_,_,_, destGUID, destName = unpack(args)
		--if combatType == "UNIT_DIED" then
		local timestamp, combatType, something, srcGUID, srcName, srcFlags, something2, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
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

	local function onAddonLoad()
		verifyDB()
		if isMythicPlus() then
			quantity = getEnemyForcesProgress()
		else
			quantity = 0
		end
	end

	local MythicProgress = CreateFrame("FRAME")
	MythicProgress:RegisterEvent("PLAYER_ENTERING_WORLD")
	MythicProgress:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
	MythicProgress:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	MythicProgress:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	MythicProgress:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

	function MythicProgress:OnEvent(event, ...)
		args={...}
		if event == "PLAYER_ENTERING_WORLD" then
			onAddonLoad(args[1])
		elseif event == "SCENARIO_CRITERIA_UPDATE" then
			onCriteriaUpdate()
		elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
			onCombatLogEvent()
		elseif event == "NAME_PLATE_UNIT_ADDED" then
			onAddNameplate(...)
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			onRemoveNameplate(...)
		end
	end

	MythicProgress:SetScript("OnEvent", MythicProgress.OnEvent)
	GameTooltip:HookScript("OnTooltipSetUnit", onNPCTooltip)
end