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
	{ 10, 8, 4 }, -- Fortified / Sanguine / Necrotic / Infested
	{ 9, 11, 2 }, -- Tyrannical / Bursting / Skittish / Infested
	{ 10, 5, 14 }, -- Fortified / Teeming / Quaking / Infested
	{ 9, 6, 4 }, -- Tyrannical / Raging / Necrotic / Infested
	{ 10, 7, 2 }, -- Fortified / Bolstering / Skittish / Infested
	{ 9, 5, 3 }, -- Tyrannical / Teeming / Volcanic / Infested
	{ 10, 8, 12 }, -- Fortified / Sanguine / Grievous / Infested
	{ 9, 7, 13 }, -- Tyrannical / Bolstering / Explosive / Infested
	{ 10, 14, 11 }, -- Fortified / Bursting / Quaking / Infested
	{ 9, 6, 3 }, -- Tyrannical / Raging / Volcanic / Infested
	{ 10, 5, 13 }, -- Fortified / Teeming / Explosive / Infested
	{ 9, 7, 12 }, -- Tyrannical / Bolstering / Grievous / Infested
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
    progress = {
        name = "Mythic + Progress",
        type = "group",
        inline = true,
        order = 3,
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

	self:Progress()

	self:Timer()
	self:Schedule()
	self:GuildBest()
	C_MythicPlus.RequestCurrentAffixes()

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
				    for container=BACKPACK_CONTAINER, NUM_BAG_SLOTS do
						local slots = GetContainerNumSlots(container)
						for slot=1, slots do
							local _, _, _, _, _, _, slotLink, _, _, slotItemID = GetContainerItemInfo(container, slot)
							if slotLink and slotLink:match("|Hkeystone:") then
								PickupContainerItem(container, slot)
								if (CursorHasItem()) then
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

	hooksecurefunc("Scenario_ChallengeMode_UpdateTime", UpdateTime)

	local function ProgressBar_SetValue(self, percent)
		if self.criteriaIndex then
			local _, _, _, _, totalQuantity, _, _, quantityString, _, _, _, _, _ = C_Scenario.GetCriteriaInfo(self.criteriaIndex)
			local currentQuantity = quantityString and tonumber( strsub(quantityString, 1, -2) )
			if currentQuantity and totalQuantity then
				self.Bar.Label:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
				self.Bar.Label:SetPoint("CENTER", self.Bar, "CENTER", 0, 0)
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
		local weeklyBest = C_MythicPlus.GetWeeklyChestRewardLevel()		

		if keyLevel then
			ownedKeystone = true
		else
			ownedKeystone = false
		end

		if ownedKeystone then
			local MythicFrame = ChallengesFrame.WeeklyInfo.Child

			local dungeonName = C_ChallengeMode.GetMapUIInfo(keyMapID)

			ChallengesFrame.WeeklyInfo.Child.RunStatus:ClearAllPoints()
			ChallengesFrame.WeeklyInfo.Child.RunStatus:SetScale(0.8)
			ChallengesFrame.WeeklyInfo.Child.Label:SetPoint("TOP", ChallengesFrame.WeeklyInfo.Child, "TOP", -100, -25)

			-- Move the big center chest visual to the left
	    	MythicFrame.WeeklyChest:SetPoint("LEFT", MythicFrame, "LEFT", 70, -100)
	    	MythicFrame.WeeklyChest:SetScale(0.9)
	    	MythicFrame.RunStatus:SetPoint("TOP", MythicFrame.WeeklyChest, "TOP", 0, 5)
	    	-- Center status text to mid if its the long one
	    	if MythicFrame.WeeklyChest.CollectChest:IsShown() or MythicFrame.WeeklyChest.MissingKeystoneChest:IsShown() then
	        	MythicFrame.RunStatus:ClearAllPoints()
	        	MythicFrame.RunStatus:SetPoint("CENTER", MythicFrame, "TOP", 0, -90)
	    	end

			local key = CreateFrame('Frame', nil, MythicFrame)
			key:SetPoint("BOTTOM", MythicFrame.RunStatus, "TOP", 0, 10)
			key:SetWidth(200)
			key:SetHeight(14)

			key.text = key:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			key.text:SetPoint("CENTER", key)
			key.text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
			key.text:SetText("|cffF0CE1CKey: |r"..dungeonName .. " (" .. keyLevel .. ")")
			key.text:SetTextColor(1,1,1)

			local frame = CreateFrame("Frame", nil, ChallengesFrame)
			frame:SetSize(200, 110)
			frame:SetPoint("CENTER", MythicFrame, "CENTER", 0, 20)
			MythicPlus.Frame = frame

			local entries = {}
			for i = 1, rowCount do
				local entry = CreateFrame("Frame", nil, frame)
				entry:SetSize(120, 56)

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
				for j = 3, 1, -1 do
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
					entry:SetPoint("TOPRIGHT", ChallengesFrame.WeeklyInfo.Child, "TOPRIGHT", -50, -45)
				else
					entry:SetPoint("TOP", entries[i-1], "BOTTOM", 0, -22)
				end

				entries[i] = entry
			end
			frame.Entries = entries

			hooksecurefunc("ChallengesFrame_Update", UpdateAffixes)
		else
			ChallengesFrame.WeeklyInfo.Child.RunStatus:ClearAllPoints()
			ChallengesFrame.WeeklyInfo.Child.RunStatus:SetPoint("CENTER", ChallengesFrame, "CENTER", 0, 10)
		end
	end

	function MythicPlus:CheckCurrentAffixes()
		currentWeek = nil		
		C_MythicPlus.RequestCurrentAffixes()

		local weeklyAffixes = C_MythicPlus.GetCurrentAffixes()
		
		if weeklyAffixes then
			for index, affixes in ipairs(affixSchedule) do
				local matches = 0
				for _, affix in ipairs(weeklyAffixes) do
					if affix.id == affixes[1] or affix.id == affixes[2] or affix.id == affixes[3] then
						matches = matches + 1
					end
				end
				if matches >= 3 then
					currentWeek = index
				end
			end
		end	
	end
end

function MythicPlus:GuildBest()
	local function CreateLabel(text, parent, fontSize)
	    local frame = CreateFrame("Frame", nil, parent)
	    frame:SetWidth(190)
	    frame:SetHeight(25)
	    local fontString = frame:CreateFontString(nil, "OVERLAY", fontSize or "GameFontNormal")
	    fontString:SetText(text)
	    fontString:SetPoint("LEFT", frame, "LEFT", 0, 0)
	    frame.label = fontString

	    return frame
	end

	local function ChallengesFrame_AddGuildBest()
		local keyLevel = C_MythicPlus.GetOwnedKeystoneLevel()
		
	    if not ChallengesFrame or not ChallengesFrame:IsShown() or not keyLevel then
	        return
	    end

	    local frame = ChallengesFrame.WeeklyInfo.Child

	    local container = _G["ChallengesFrameGuildBestFrame"]
	    if not container then
	        container = CreateFrame("Frame", "ChallengesFrameGuildBestFrame", frame)
	        container:SetPoint("CENTER", frame, "CENTER", 160, -85)
	        container:SetFrameStrata("DIALOG")
	        container:SetSize(210, 130)

	        container.bg = container:CreateTexture(nil, "BACKGROUND")
	        container.bg:SetAllPoints()
	        container.bg:SetAtlas("ChallengeMode-guild-background")
	        container.bg:SetAlpha(0.4)

	        container.TitleLabel = CreateLabel("Guild Best:", container, "GameFontNormalLarge")
	        container.TitleLabel.label:ClearAllPoints()
	        container.TitleLabel.label:SetPoint("CENTER", container.TitleLabel, "CENTER")
	        container.TitleLabel:SetPoint("CENTER", container, "TOP", 0, -15)

	        container.divider = container:CreateTexture(nil, "ARTWORK")
	        container.divider:SetSize(192, 9)
	        container.divider:SetAtlas("ChallengeMode-RankLineDivider", false)
	        container.divider:SetPoint("TOP", 0, -26)
	    end

	    local guildsBest = C_ChallengeMode.GetGuildLeaders()

	    if not guildsBest or #guildsBest == 0 then
	        local unavail = container.Unavail or CreateLabel("No data available", container)
	        unavail:SetPoint("CENTER", container, "TOP", 0, -50)
	        unavail.label:ClearAllPoints()
	        unavail.label:SetPoint("CENTER", unavail, "CENTER")
	        unavail:Show()
	        container.Unavail = unavail
	        return
	    elseif container.Unavail then
	        container.Unavail.label:SetText("")
	        container.Unavail.label:Hide()
	    end

	    for i, attempt in ipairs(guildsBest) do
	        local dungeonName = C_ChallengeMode.GetMapUIInfo(attempt.mapChallengeModeID) or "Unknown"
	        if dungeonName:len() > 25 then
	            dungeonName = strsub(dungeonName, 1, 22) .. "..."
	        end

	        local keystoneLevel = " +" .. tostring(attempt.keystoneLevel)

	        local labelFrame = container["Dungeon" .. tostring(i)] or CreateLabel(dungeonName, container)
	        container["Dungeon" .. tostring(i)] = labelFrame
	        labelFrame.label:SetText(dungeonName)

	        labelFrame.keyLabel = labelFrame.keyLabel or labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	        labelFrame.keyLabel:SetText(keystoneLevel)
	        labelFrame.keyLabel:SetPoint("RIGHT", labelFrame, "RIGHT", 0, 0)

	        labelFrame:SetPoint("LEFT", container, "TOPLEFT", 10, -26 + (-i * 20))
	        labelFrame:SetScript("OnEnter", function(self) 
	            GameTooltip:SetText(" ");
	            GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -45, 5);

	            GameTooltip_SetTitle(GameTooltip, dungeonName .. " +" .. tostring(attempt.keystoneLevel), NORMAL_FONT_COLOR);
	            for j, member in ipairs(attempt.members) do
	                GameTooltip:AddLine(RAID_CLASS_COLORS[member.classFileName]:WrapTextInColorCode(member.name)); 
	            end

	            GameTooltip:Show();
	        end)
	        labelFrame:SetScript("OnLeave", function() 
	            GameTooltip:Hide();
	        end)
	    end
	end

	-- Hook load and open of the Challenges frame
	local GuildBestListenerFrame = _G["MythicPlusGuildBestListener"] or CreateFrame("Frame", "MythicPlusGuildBestListener", UIParent)
	GuildBestListenerFrame:RegisterEvent('ADDON_LOADED')
	GuildBestListenerFrame:SetScript('OnEvent', function(self, event, name)
	    if event == "ADDON_LOADED" and name == "Blizzard_ChallengesUI" then
	        hooksecurefunc("ChallengesFrame_Update", ChallengesFrame_AddGuildBest)
	    end
	end)
end

function MythicPlus:Progress()

	local quantity = 0
	local activeNameplates = {}

	--
	-- MYTHIC+ FUNCTION
	--

	local function isUsingMdt()
		if IsAddOnLoaded("MethodDungeonTools") then
			return true
		else
			return false
		end
	end

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
			local progress = currentQuantity
			return progress
		end
	end

	local function getEnemyForcesPercentage()
		-- Returns exact float value of current enemies killed progress (1-100).
		local quantity, maxQuantity = getCurrentQuantity(), getMaxQuantity()
		local progress = quantity / maxQuantity
		return progress * 100
	end

	--
	-- DB
	--

	local function getValue(npcID)
		if (isUsingMdt() and MethodDungeonTools ~= nil and MethodDungeonTools.GetEnemyForces ~= nil) then
	      	local count, max, maxTeeming = MethodDungeonTools:GetEnemyForces(npcID);

	      	if (count ~= nil and max ~= nil and maxTeeming ~= nil) then
	        	return count      	
	      	end
	    end
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
		local text
		local rawProg = getExactProgress(npcID)
		if not rawProg then
			text = string.format("%s : +%s", "- Enemy Forces", "n/a")
		else
			text = string.format("%s : +%s", "- Enemy Forces", rawProg)
		end
		return text
	end
		
	local function onNPCTooltip(self)
		if isMythicPlus() then
			local unit = select(2, self:GetUnit())
			if unit then
				local guid = UnitGUID(unit)
				local npcID = getNPCID(guid)
				if npcID then
					local tooltipMessage = getTooltipMessage(npcID)
					local forcesFormat = format(" - %s: %%s", "Enemy Forces")
					if tooltipMessage then
						local matcher = format(forcesFormat, "%d+%%")
						for i=2, self:NumLines() do
							local tiptext = _G["GameTooltipTextLeft"..i]
							local linetext = tiptext and tiptext:GetText()

							if linetext and linetext:match(matcher) then
								tiptext:SetText(tooltipMessage)
								self:Show()
							end
						end
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

	local function removeNameplates()
		for token,_ in pairs(activeNameplates) do
			removeNameplateText(token)
		end
	end

	local function updateNameplates()
		if isMythicPlus() then
			for token,_ in pairs(activeNameplates) do
				updateNameplatePosition(token)
			end
		else
			removeNameplates()
		end
	end

	---
	--- HOOKS
	---

	local function onAddonLoad()
		if isMythicPlus() then
			quantity = getEnemyForcesProgress()
		else
			quantity = 0
		end
	end

	local MythicProgress = CreateFrame("FRAME")
	MythicProgress:RegisterEvent("PLAYER_ENTERING_WORLD")
	MythicProgress:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	MythicProgress:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

	function MythicProgress:OnEvent(event, ...)
		args={...}
		if event == "PLAYER_ENTERING_WORLD" then
			onAddonLoad(args[1])
		elseif event == "NAME_PLATE_UNIT_ADDED" then
			onAddNameplate(...)
		elseif event == "NAME_PLATE_UNIT_REMOVED" then
			onRemoveNameplate(...)
		end
	end

	MythicProgress:SetScript("OnEvent", MythicProgress.OnEvent)
	GameTooltip:HookScript("OnTooltipSetUnit", onNPCTooltip)
end